#!/usr/bin/env node
import { ethers } from 'ethers';
import { Client, ClusterDefinition, OperatorPayload } from '@obolnetwork/obol-sdk';
import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface Config {
  operatorAddress: string;
  enrFilePath: string;
  outputDefinitionFile: string;
  apiEndpoint: string;
  initialRetryDelaySeconds: number;
  maxRetryDelaySeconds: number;
  retryDelayFactor: number;
  pageLimit: number;
  dataDir: string;
  privateKeyPath?: string;
}

class DKGSidecar {
  private config: Config;
  private client: Client;
  private signer?: ethers.Signer;
  private podEnr!: string;
  private currentRetryDelay: number;

  constructor(config: Config) {
    this.config = config;
    this.currentRetryDelay = config.initialRetryDelaySeconds;
    
    // Initialize signer if private key is available
    if (config.privateKeyPath && fs.existsSync(config.privateKeyPath)) {
      const privateKey = fs.readFileSync(config.privateKeyPath, 'utf8').trim();
      const wallet = new ethers.Wallet(privateKey);
      this.signer = wallet.connect(null);
    }
    
    // Initialize Obol SDK client
    const baseUrl = config.apiEndpoint.replace(/\/v1\/definition\/operator\/.*$/, '');
    this.client = new Client({ 
      baseUrl, 
      chainId: 1 
    }, this.signer as any);
  }

  async run(): Promise<void> {
    console.log('DKG Sidecar Script: Starting...');
    console.log('Operator Address:', this.config.operatorAddress);
    console.log('ENR File Path:', this.config.enrFilePath);
    console.log('Output Definition File:', this.config.outputDefinitionFile);
    console.log('API Endpoint:', this.config.apiEndpoint);
    console.log('Initial Retry Delay:', this.config.initialRetryDelaySeconds, 'seconds');
    console.log('Max Retry Delay:', this.config.maxRetryDelaySeconds, 'seconds');
    console.log('Retry Delay Factor:', this.config.retryDelayFactor);
    console.log('Page Limit:', this.config.pageLimit);

    // Validate operator address
    if (!this.config.operatorAddress || this.config.operatorAddress === 'null') {
      throw new Error('ERROR: Operator address is not set or is invalid. Please set .Values.charon.operatorAddress');
    }

    // Read ENR from file
    if (!fs.existsSync(this.config.enrFilePath)) {
      throw new Error(`ERROR: ENR file ${this.config.enrFilePath} not found.`);
    }

    this.podEnr = fs.readFileSync(this.config.enrFilePath, 'utf8').trim();
    if (!this.podEnr) {
      throw new Error(`ERROR: ENR file ${this.config.enrFilePath} is empty.`);
    }
    console.log('Pod ENR to find:', this.podEnr);

    // Check if cluster-lock already exists
    const clusterLockPath = path.join(this.config.dataDir, 'cluster-lock.json');
    if (fs.existsSync(clusterLockPath)) {
      console.log('Cluster lock file already exists. Charon should start directly.');
      return;
    }

    // Check if cluster definition already exists
    if (fs.existsSync(this.config.outputDefinitionFile)) {
      console.log('Cluster definition already exists. Proceeding to DKG...');
      const definition = JSON.parse(fs.readFileSync(this.config.outputDefinitionFile, 'utf8'));
      const success = await this.processDKG(definition);
      if (success) {
        console.log('DKG Sidecar Script: Orchestration complete.');
        return;
      }
    }

    // Accept terms and conditions if we have a signer
    if (this.signer) {
      try {
        console.log('Accepting Obol terms and conditions...');
        await this.client.acceptObolLatestTermsAndConditions();
        console.log('Terms and conditions accepted.');
      } catch (error) {
        console.log('Could not accept terms and conditions:', error);
      }
    }

    // Start polling loop
    while (true) {
      console.log(`Starting new polling cycle... (current delay before next cycle: ${this.currentRetryDelay}s)`);
      
      const foundDefinition = await this.pollForDefinition();
      
      if (foundDefinition) {
        const success = await this.processDKG(foundDefinition);
        if (success) {
          console.log('DKG Sidecar Script: Orchestration complete.');
          process.exit(0);
        }
      }

      // Sleep before next retry
      console.log(`Polling cycle complete. Retrying in ${this.currentRetryDelay} seconds...`);
      await this.sleep(this.currentRetryDelay * 1000);

      // Apply backoff
      this.currentRetryDelay = Math.min(
        this.currentRetryDelay * this.config.retryDelayFactor,
        this.config.maxRetryDelaySeconds
      );
    }
  }

  private async pollForDefinition(): Promise<ClusterDefinition | null> {
    let currentPage = 1;

    while (true) {
      try {
        console.log(`Polling API for page ${currentPage}...`);
        
        // Fetch cluster definitions for the operator
        const response = await this.fetchClusterDefinitions(currentPage);
        
        if (!response || !response.cluster_definitions) {
          console.log(`Warning: Empty or invalid response from API (Page ${currentPage}).`);
          break;
        }

        console.log('DEBUG: Raw API Response:');
        console.log(JSON.stringify(response, null, 2));
        console.log('DEBUG: End of Raw API Response.');

        // Log all available definitions
        if (response.cluster_definitions.length > 0) {
          console.log(`Found ${response.cluster_definitions.length} cluster definition(s) for operator ${this.config.operatorAddress}:`);
          response.cluster_definitions.forEach((def: any, index: number) => {
            console.log(`  ${index + 1}. Config Hash: ${def.config_hash}, Name: ${def.name}, Created: ${def.timestamp}`);
          });
        }

        // Look for a definition where our ENR is signed by our operator
        const candidateDefinition = this.findSignedDefinition(response.cluster_definitions);
        
        if (candidateDefinition) {
          console.log(`Found candidate definition where our operator (${this.config.operatorAddress}) has signed our ENR on page ${currentPage}.`);
          console.log(`Config Hash: ${candidateDefinition.config_hash}`);
          
          // Try to accept the cluster definition if we haven't already and have a signer
          if (this.signer && candidateDefinition.config_hash) {
            await this.acceptDefinitionIfNeeded(candidateDefinition);
          }

          // Check if all operators have signed
          if (this.isFullySigned(candidateDefinition)) {
            console.log(`All ${candidateDefinition.operators.length} operators have signed. Definition ready for DKG!`);
            
            // Fetch the full definition using SDK if we have config_hash
            if (candidateDefinition.config_hash) {
              try {
                const fullDefinition = await this.client.getClusterDefinition(candidateDefinition.config_hash);
                return fullDefinition;
              } catch (error) {
                console.log('Could not fetch full definition via SDK, using current definition');
                return candidateDefinition;
              }
            }
            
            return candidateDefinition;
          } else {
            console.log('Not all operators in candidate have signed. Continuing search or will retry.');
          }
        }

        // Check if there are more pages
        if (!response.has_next_page) {
          console.log(`No fully signed definition for us found on page ${currentPage}, and no more pages available.`);
          break;
        }

        currentPage++;
      } catch (error) {
        console.error(`Error polling API on page ${currentPage}:`, error);
        break;
      }
    }

    return null;
  }

  private async acceptDefinitionIfNeeded(definition: any): Promise<void> {
    try {
      const ourOperator = definition.operators.find((op: any) => 
        op.address.toLowerCase() === this.config.operatorAddress.toLowerCase()
      );

      // Check if we've already accepted (signed) the definition
      if (ourOperator && ourOperator.enr === this.podEnr && 
          ourOperator.enr_signature && ourOperator.config_signature) {
        console.log('We have already accepted this cluster definition.');
        return;
      }

      // Accept the definition
      console.log('Accepting cluster definition...');
      const operatorPayload: OperatorPayload = {
        enr: this.podEnr,
        version: definition.version || 'v1.10.0'
      };

      const updatedDefinition = await this.client.acceptClusterDefinition(
        operatorPayload, 
        definition.config_hash
      );
      
      console.log('Successfully accepted cluster definition.');
    } catch (error) {
      console.error('Error accepting cluster definition:', error);
    }
  }

  private async fetchClusterDefinitions(page: number): Promise<any> {
    try {
      // Make direct API call since SDK might not have paginated endpoint
      const url = `${this.config.apiEndpoint}?page=${page}&limit=${this.config.pageLimit}`;
      const response = await fetch(url, {
        headers: { 'Accept': 'application/json' }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error fetching cluster definitions:', error);
      return null;
    }
  }

  private findSignedDefinition(definitions: ClusterDefinition[]): ClusterDefinition | null {
    for (const definition of definitions) {
      const ourOperator = definition.operators.find(op => 
        op.address.toLowerCase() === this.config.operatorAddress.toLowerCase() &&
        op.enr === this.podEnr &&
        op.enr_signature && op.enr_signature.length > 0 &&
        op.config_signature && op.config_signature.length > 0
      );

      if (ourOperator) {
        return definition;
      }
    }
    return null;
  }

  private isFullySigned(definition: ClusterDefinition): boolean {
    const totalOperators = definition.operators.length;
    const signedOperators = definition.operators.filter(op => 
      op.enr_signature && op.enr_signature.length > 0 &&
      op.config_signature && op.config_signature.length > 0
    ).length;

    console.log(`Total operators in candidate: ${totalOperators}, Signed: ${signedOperators}`);
    return totalOperators > 0 && signedOperators === totalOperators;
  }

  private async processDKG(definition: ClusterDefinition): Promise<boolean> {
    try {
      // Save definition to file
      const outputDir = path.dirname(this.config.outputDefinitionFile);
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }
      
      fs.writeFileSync(this.config.outputDefinitionFile, JSON.stringify(definition, null, 2));
      console.log(`Fully signed cluster definition saved to ${this.config.outputDefinitionFile}.`);

      // Run charon DKG
      console.log('Proceeding to DKG process...');
      const dkgCommand = `charon dkg --definition-file="${this.config.outputDefinitionFile}" --data-dir="${this.config.dataDir}"`;
      
      try {
        execSync(dkgCommand, { stdio: 'inherit' });
        console.log('DKG process completed successfully.');
        return true;
      } catch (error: any) {
        console.error(`ERROR: DKG process failed with exit code ${error.status || 'unknown'}.`);
        
        // Clean up on failure
        fs.unlinkSync(this.config.outputDefinitionFile);
        console.log(`Removed ${this.config.outputDefinitionFile}. Will retry entire process.`);
        return false;
      }
    } catch (error) {
      console.error('Error processing DKG:', error);
      return false;
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Main execution
async function main() {
  const config: Config = {
    operatorAddress: process.argv[2] || process.env.OPERATOR_ADDRESS || '',
    enrFilePath: process.argv[3] || process.env.ENR_FILE_PATH || '/enr-from-job/enr.txt',
    outputDefinitionFile: process.env.OUTPUT_DEFINITION_FILE || '/charon-data/cluster-definition.json',
    apiEndpoint: process.env.API_ENDPOINT || 'https://api.obol.tech',
    initialRetryDelaySeconds: parseInt(process.env.INITIAL_RETRY_INTERVAL_SECONDS || '10'),
    maxRetryDelaySeconds: parseInt(process.env.MAX_RETRY_INTERVAL_SECONDS || '300'),
    retryDelayFactor: parseFloat(process.env.BACKOFF_FACTOR || '2'),
    pageLimit: parseInt(process.env.PAGE_LIMIT || '10'),
    dataDir: process.env.CHARON_NODE_ID_DIR || '/charon-data',
    privateKeyPath: process.env.CHARON_PRIVATE_KEY_FILE || '/charon-data/charon-enr-private-key'
  };

  // Construct full API endpoint if needed
  if (!config.apiEndpoint.includes('/v1/definition/operator/')) {
    config.apiEndpoint = `${config.apiEndpoint}/v1/definition/operator/${config.operatorAddress}`;
  }

  const sidecar = new DKGSidecar(config);
  
  try {
    await sidecar.run();
  } catch (error) {
    console.error('Fatal error:', error);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}
