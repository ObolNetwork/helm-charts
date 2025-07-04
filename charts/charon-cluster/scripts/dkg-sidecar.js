#!/usr/bin/env node
"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const ethers_1 = require("ethers");
const obol_sdk_1 = require("@obolnetwork/obol-sdk");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const child_process_1 = require("child_process");
// Logger implementation
var LogLevel;
(function (LogLevel) {
    LogLevel[LogLevel["DEBUG"] = 0] = "DEBUG";
    LogLevel[LogLevel["INFO"] = 1] = "INFO";
    LogLevel[LogLevel["WARN"] = 2] = "WARN";
    LogLevel[LogLevel["ERROR"] = 3] = "ERROR";
})(LogLevel || (LogLevel = {}));
class Logger {
    constructor(prefix = 'DKG-Sidecar') {
        this.prefix = prefix;
        const envLevel = process.env.LOG_LEVEL?.toUpperCase() || 'INFO';
        this.level = LogLevel[envLevel] ?? LogLevel.INFO;
    }
    log(level, levelStr, ...args) {
        if (level >= this.level) {
            const timestamp = new Date().toISOString();
            const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg, null, 2) : String(arg)).join(' ');
            console.log(`${timestamp} [${levelStr}] [${this.prefix}] ${message}`);
        }
    }
    debug(...args) {
        this.log(LogLevel.DEBUG, 'DEBUG', ...args);
    }
    info(...args) {
        this.log(LogLevel.INFO, 'INFO', ...args);
    }
    warn(...args) {
        this.log(LogLevel.WARN, 'WARN', ...args);
    }
    error(...args) {
        this.log(LogLevel.ERROR, 'ERROR', ...args);
    }
}
class DKGSidecar {
    constructor(config) {
        this.config = config;
        this.currentRetryDelay = config.initialRetryDelaySeconds;
        this.logger = new Logger();
        // Initialize signer if private key is available
        if (config.privateKeyPath && fs.existsSync(config.privateKeyPath)) {
            const privateKey = fs.readFileSync(config.privateKeyPath, 'utf8').trim();
            const wallet = new ethers_1.ethers.Wallet(privateKey);
            this.signer = wallet.connect(null);
        }
        // Initialize Obol SDK client
        const baseUrl = config.apiEndpoint.replace(/\/v1\/definition\/operator\/.*$/, '');
        this.client = new obol_sdk_1.Client({
            baseUrl,
            chainId: 1
        }, this.signer);
    }
    async run() {
        this.logger.info('Starting DKG Sidecar...');
        this.logger.info('Configuration:');
        this.logger.info('  Operator Address:', this.config.operatorAddress);
        this.logger.info('  ENR File Path:', this.config.enrFilePath);
        this.logger.info('  Output Definition File:', this.config.outputDefinitionFile);
        this.logger.info('  API Endpoint:', this.config.apiEndpoint);
        this.logger.debug('Retry Configuration:');
        this.logger.debug('  Initial Retry Delay:', this.config.initialRetryDelaySeconds, 'seconds');
        this.logger.debug('  Max Retry Delay:', this.config.maxRetryDelaySeconds, 'seconds');
        this.logger.debug('  Retry Delay Factor:', this.config.retryDelayFactor);
        this.logger.debug('  Page Limit:', this.config.pageLimit);
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
        this.logger.info('Pod ENR loaded:', this.podEnr);
        // Check if cluster-lock already exists
        const clusterLockPath = path.join(this.config.dataDir, 'cluster-lock.json');
        if (fs.existsSync(clusterLockPath)) {
            this.logger.info('Cluster lock file already exists. Charon should start directly.');
            return;
        }
        // Check if cluster definition already exists
        if (fs.existsSync(this.config.outputDefinitionFile)) {
            this.logger.info('Cluster definition already exists. Proceeding to DKG...');
            const definition = JSON.parse(fs.readFileSync(this.config.outputDefinitionFile, 'utf8'));
            const success = await this.processDKG(definition);
            if (success) {
                this.logger.info('DKG orchestration complete.');
                return;
            }
        }
        // Accept terms and conditions if we have a signer
        if (this.signer) {
            try {
                this.logger.info('Accepting Obol terms and conditions...');
                await this.client.acceptObolLatestTermsAndConditions();
                this.logger.info('Terms and conditions accepted.');
            }
            catch (error) {
                this.logger.warn('Could not accept terms and conditions:', error);
            }
        }
        // Start polling loop
        while (true) {
            this.logger.info(`Starting new polling cycle... (current delay before next cycle: ${this.currentRetryDelay}s)`);
            const foundDefinition = await this.pollForDefinition();
            if (foundDefinition) {
                const success = await this.processDKG(foundDefinition);
                if (success) {
                    this.logger.info('DKG orchestration complete.');
                    process.exit(0);
                }
            }
            // Sleep before next retry
            this.logger.info(`Polling cycle complete. Retrying in ${this.currentRetryDelay} seconds...`);
            await this.sleep(this.currentRetryDelay * 1000);
            // Apply backoff
            this.currentRetryDelay = Math.min(this.currentRetryDelay * this.config.retryDelayFactor, this.config.maxRetryDelaySeconds);
        }
    }
    async pollForDefinition() {
        let currentPage = 1;
        while (true) {
            try {
                this.logger.debug(`Polling API for page ${currentPage}...`);
                // Fetch cluster definitions for the operator
                const response = await this.fetchClusterDefinitions(currentPage);
                if (!response || !response.cluster_definitions) {
                    this.logger.warn(`Empty or invalid response from API (Page ${currentPage}).`);
                    break;
                }
                this.logger.debug('Raw API Response:', response);
                // Log all available definitions
                if (response.cluster_definitions.length > 0) {
                    this.logger.info(`Found ${response.cluster_definitions.length} cluster definition(s) for operator ${this.config.operatorAddress}:`);
                    response.cluster_definitions.forEach((def, index) => {
                        this.logger.info(`  ${index + 1}. Config Hash: ${def.config_hash}, Name: ${def.name}, Created: ${def.timestamp}`);
                    });
                }
                // Look for a definition where our ENR is signed by our operator
                const candidateDefinition = this.findSignedDefinition(response.cluster_definitions);
                if (candidateDefinition) {
                    this.logger.info(`Found candidate definition where our operator (${this.config.operatorAddress}) has signed our ENR on page ${currentPage}.`);
                    this.logger.info(`Config Hash: ${candidateDefinition.config_hash}`);
                    // Try to accept the cluster definition if we haven't already and have a signer
                    if (this.signer && candidateDefinition.config_hash) {
                        await this.acceptDefinitionIfNeeded(candidateDefinition);
                    }
                    // Check if all operators have signed
                    if (this.isFullySigned(candidateDefinition)) {
                        this.logger.info(`All ${candidateDefinition.operators.length} operators have signed. Definition ready for DKG!`);
                        // Fetch the full definition using SDK if we have config_hash
                        if (candidateDefinition.config_hash) {
                            try {
                                const fullDefinition = await this.client.getClusterDefinition(candidateDefinition.config_hash);
                                return fullDefinition;
                            }
                            catch (error) {
                                this.logger.debug('Could not fetch full definition via SDK, using current definition');
                                return candidateDefinition;
                            }
                        }
                        return candidateDefinition;
                    }
                    else {
                        this.logger.debug('Not all operators in candidate have signed. Continuing search or will retry.');
                    }
                }
                // Check if there are more pages
                if (!response.has_next_page) {
                    this.logger.debug(`No fully signed definition for us found on page ${currentPage}, and no more pages available.`);
                    break;
                }
                currentPage++;
            }
            catch (error) {
                this.logger.error(`Error polling API on page ${currentPage}:`, error);
                break;
            }
        }
        return null;
    }
    async acceptDefinitionIfNeeded(definition) {
        try {
            const ourOperator = definition.operators.find((op) => op.address.toLowerCase() === this.config.operatorAddress.toLowerCase());
            // Check if we've already accepted (signed) the definition
            if (ourOperator && ourOperator.enr === this.podEnr &&
                ourOperator.enr_signature && ourOperator.config_signature) {
                this.logger.debug('We have already accepted this cluster definition.');
                return;
            }
            // Accept the definition
            this.logger.info('Accepting cluster definition...');
            const operatorPayload = {
                enr: this.podEnr,
                version: definition.version || 'v1.10.0'
            };
            const updatedDefinition = await this.client.acceptClusterDefinition(operatorPayload, definition.config_hash);
            this.logger.info('Successfully accepted cluster definition.');
        }
        catch (error) {
            this.logger.error('Error accepting cluster definition:', error);
        }
    }
    async fetchClusterDefinitions(page) {
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
        }
        catch (error) {
            this.logger.error('Error fetching cluster definitions:', error);
            return null;
        }
    }
    findSignedDefinition(definitions) {
        for (const definition of definitions) {
            const ourOperator = definition.operators.find(op => op.address.toLowerCase() === this.config.operatorAddress.toLowerCase() &&
                op.enr === this.podEnr &&
                op.enr_signature && op.enr_signature.length > 0 &&
                op.config_signature && op.config_signature.length > 0);
            if (ourOperator) {
                return definition;
            }
        }
        return null;
    }
    isFullySigned(definition) {
        const totalOperators = definition.operators.length;
        const signedOperators = definition.operators.filter(op => op.enr_signature && op.enr_signature.length > 0 &&
            op.config_signature && op.config_signature.length > 0).length;
        this.logger.debug(`Total operators in candidate: ${totalOperators}, Signed: ${signedOperators}`);
        return totalOperators > 0 && signedOperators === totalOperators;
    }
    async processDKG(definition) {
        try {
            // Save definition to file
            const outputDir = path.dirname(this.config.outputDefinitionFile);
            if (!fs.existsSync(outputDir)) {
                fs.mkdirSync(outputDir, { recursive: true });
            }
            fs.writeFileSync(this.config.outputDefinitionFile, JSON.stringify(definition, null, 2));
            this.logger.info(`Fully signed cluster definition saved to ${this.config.outputDefinitionFile}.`);
            // Run charon DKG
            this.logger.info('Proceeding to DKG process...');
            const dkgCommand = `charon dkg --definition-file="${this.config.outputDefinitionFile}" --data-dir="${this.config.dataDir}"`;
            try {
                (0, child_process_1.execSync)(dkgCommand, { stdio: 'inherit' });
                this.logger.info('DKG process completed successfully.');
                return true;
            }
            catch (error) {
                this.logger.error(`DKG process failed with exit code ${error.status || 'unknown'}.`);
                // Clean up on failure
                fs.unlinkSync(this.config.outputDefinitionFile);
                this.logger.warn(`Removed ${this.config.outputDefinitionFile}. Will retry entire process.`);
                return false;
            }
        }
        catch (error) {
            this.logger.error('Error processing DKG:', error);
            return false;
        }
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
// Main execution
async function main() {
    const config = {
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
    const logger = new Logger('Main');
    try {
        await sidecar.run();
    }
    catch (error) {
        logger.error('Fatal error:', error);
        process.exit(1);
    }
}
// Run if executed directly
if (require.main === module) {
    main();
}
