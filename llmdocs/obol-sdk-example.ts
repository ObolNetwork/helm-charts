import { ethers } from "ethers";
import { Client, validateClusterLock, ClusterDefinition, ClusterLock, OperatorPayload, RewardsSplitPayload, ClusterValidator, TotalSplitPayload, ClaimIncentivesResponse, SignerType } from "@obolnetwork/obol-sdk";
import { ClaimableIncentives, ProviderType } from "@obolnetwork/obol-sdk/dist/types/src/types";

//To run the example in terminal, we can create a random privatekey to instanisiate obol-sdk Client
const clusterConfig = {
  name: "testSDK",
  operators:
    [
      { address: "0xC35CfCd67b9C27345a54EDEcC1033F2284148c81" },
      { address: "0x33807D6F1DCe44b9C599fFE03640762A6F08C496" },
      { address: "0xc6e76F72Ea672FAe05C357157CfC37720F0aF26f" },
      { address: "0x86B8145c98e5BD25BA722645b15eD65f024a87EC" }
    ],
  validators: [{
    fee_recipient_address: "0x3CD4958e76C317abcEA19faDd076348808424F99",
    withdrawal_address: "0xE0C5ceA4D3869F156717C66E188Ae81C80914a6e"
  }],
}

const mnemonic = ethers.Wallet.createRandom().mnemonic?.phrase || "";
const privateKey = ethers.Wallet.fromPhrase(mnemonic).privateKey;
const wallet = new ethers.Wallet(privateKey);
const signer = wallet.connect(null);
const client = new Client({ baseUrl: "https://api.obol.tech", chainId: 1 }, signer as any);

/** Instantiates Obol SDK CLient
 * @returns Obol SDK client
 */
const obolClient = async (): Promise<Client> => {
  const provider = new ethers.BrowserProvider((window as any).ethereum);
  try {
    const signer = await provider.getSigner();
    const client = new Client({ baseUrl: "https://api.obol.tech", chainId: 1 }, signer as any);
    return client
  } catch (err) {
    console.log(err, "err");
  }
}

/** Instantiates Obol SDK CLient with neither signer nor provider
 * @returns Obol SDK client
 */
const obolClientًWithoutProviderOrSigner = async () => {
  const client = new Client(
    { baseUrl: "https://api.obol.tech", chainId: 1 },
  );
  return client;
};

/** Instantiates Obol SDK CLient with provider only
 * @returns Obol SDK client
 */
const obolClientًWithProviderOnly = async () => {
  const provider = new ethers.BrowserProvider((window as any).ethereum);
  const client = new Client(
    { baseUrl: "https://api.obol.tech", chainId: 1 },
    null,
    provider as any
  );
  return client;
};

/**
 * Returns successful authorization on accepting latest terms and conditions on https://obol.tech/terms.pdf
 * @returns successful authorization
 */
const acceptObolLatestTermsAndConditions = async (): Promise<string> => {
  try {
    //const client = await obolClient();
    const isAuthorised = await client.acceptObolLatestTermsAndConditions();
    return isAuthorised;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Returns the cluster config hash after saving cluster definition
 * @param cluster The cluster defintion
 * @returns The config hash
 */
const createObolCluster = async (): Promise<string> => {
  try {
    //const client = await obolClient();
    const configHash = await client.createClusterDefinition(clusterConfig);
    return configHash;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Returns the cluster definition
 * @param configHash The cluster hash returned from createClusterDefinition
 * @returns The partial/complete cluster definition
 */
const getObolClusterDefinition = async (configHash: string): Promise<ClusterDefinition> => {
  try {
    //const client = await obolClient();
    const clusterDefinition = await client.getClusterDefinition(configHash);
    return clusterDefinition;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Returns the cluster lock
 * @param configHash The cluster hash returned from createClusterDefinition
 * @returns The cluster lock
 */
const getObolClusterLock = async (configHash: string): Promise<ClusterLock> => {
  try {
    //const client = await obolClient();
    const lockFile = await client.getClusterLock(configHash);
    return lockFile;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Accepts joining a cluster
 * @param operatorPayload.enr The operator enr
 * @param operatorPayload.version The cluster configuration version
 * @param configHash The cluster configHash
 * @returns the updated cluster
 */
const acceptClusterDefinition = async (operatorPayload: OperatorPayload, configHash: string): Promise<ClusterDefinition> => {
  try {
    //const client = await obolClient();
    const updatedClusterDefintiion = await client.acceptClusterDefinition(
      {
        enr: operatorPayload.enr,
        version: operatorPayload.version,
      },
      configHash
    );
    return updatedClusterDefintiion;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Returns if clusterLock is valid
 * @param clusterLock The clusterLock file that requires verification
 * @param rpcUrl Optional RPC URL to use for verification when cluster contains Safe wallet signatures
 * @remarks When the cluster uses Safe wallet for signatures, an RPC URL must be provided as a param or env var to verify
 * the transaction signatures against the blockchain.
 * @returns true if it is valid
 */
const validateObolClusterLock = async (clusterLock: ClusterLock, rpcUrl?: string) => {
  try {
    const isValidLock = await validateClusterLock(clusterLock, rpcUrl);
    return isValidLock;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * deployes an owr and a splitter and return their addreses to be used as withdrawal and feerecipient address
 * @param rewardsSplitPayload payload needed for OWR/Splitter deployment
 * @returns OWR address as withdrawal_address and splitter address as fee_recipient_address
 */
const createObolRewardsSplit = async ({
  splitRecipients, //{ account: 0xC35CfCd67b9C27345a54EDEcC1033F2284148c81, percentAllocation: 99},
  principalRecipient,
  etherAmount, //64
  ObolRAFSplit, // optional and defaults to 1
  distributorFee, // optional and defaults to 0
  controllerAddress, // optional and defaults to ZeroAddress
  recoveryAddress  // optional and defaults to ZeroAddress
}: RewardsSplitPayload): Promise<ClusterValidator> => {
  try {
    const { withdrawal_address, fee_recipient_address } =
      await client.createObolRewardsSplit({
        splitRecipients,
        principalRecipient,
        etherAmount,
      });
    return { withdrawal_address, fee_recipient_address }
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * deployes a splitter and return its address to be used as withdrawal and feerecipient address
 * @param TotalSplitPayload payload needed for Splitter deployment
 * @returns splitter address as withdrawal_address and as fee_recipient_address
 */
const createObolTotalSplit = async ({
  splitRecipients, //{ account: 0xC35CfCd67b9C27345a54EDEcC1033F2284148c81, percentAllocation: 99.0},
  ObolRAFSplit, // optional and defaults to 0.1
  distributorFee, // optional and defaults to 0
  controllerAddress, // optional and defaults to ZeroAddress
}: TotalSplitPayload): Promise<ClusterValidator> => {
  try {
    const { withdrawal_address, fee_recipient_address } = await client.createObolTotalSplit({
      splitRecipients
    })
    return { withdrawal_address, fee_recipient_address }
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Activates cluster by depositing 32 ethers
 * @param clusterLock The cluster lock that contains the validator to be activated
 * @param validatorIndex The validator index
 */
const activateValidator = async (
  clusterLock: ClusterLock,
  validatorIndex: number,
) => {
  try {
    let DEPOSIT_CONTRACT_ADDRESS: string; // 0x00000000219ab540356cBB839Cbe05303d7705Fa for Mainnet, "0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b" for GOERLI
    let depositContractABI; // https://etherscan.io/address/0x00000000219ab540356cBB839Cbe05303d7705Fa#code for Mainnet, and replace the address for Goerli
    const validatorDepositData =
      clusterLock.distributed_validators[validatorIndex].deposit_data;

    const depositContract = new ethers.Contract(
      DEPOSIT_CONTRACT_ADDRESS,
      depositContractABI,
      signer
    );

    const TX_VALUE = ethers.parseEther("32");

    const tx = await depositContract.deposit(
      validatorDepositData.pubkey,
      validatorDepositData.withdrawal_credentials,
      validatorDepositData.signature,
      validatorDepositData.deposit_data_root,
      { value: TX_VALUE }
    );

    await tx.wait();
    return;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Returns incentives data for a specific address
 * @param address The Ethereum address to check for incentives
 * @returns The incentives data including amount, index, merkle proof, and contract address
 */
const getObolIncentivesByAddress = async (address: string): Promise<ClaimableIncentives> => {
  try {
    //const client = await obolClientًWithoutProviderOrSigner();
    const incentivesData = await client.incentives.getIncentivesByAddress(address);
    return incentivesData;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Checks if incentives have already been claimed for a specific index
 * @param contractAddress The merkle distributor contract address
 * @param index The index in the merkle tree
 * @returns Boolean indicating if the incentives have been claimed
 */
const isObolIncentivesClaimed = async (contractAddress: string, index: number): Promise<boolean> => {
  try {
    //const client = await obolClientًWithProviderOnly();
    const claimed = await client.incentives.isClaimed(contractAddress, index);
    return claimed;
  } catch (err) {
    console.log(err, "err");
  }
};

/**
 * Claims incentives for a specific address
 * Note: This method is not yet enabled and will throw an error if called.
 * @param address The Ethereum address for which to claim incentives
 * @returns Object containing txHash if successful or null tsHash if already claimed
 */
const claimObolIncentives = async (address: string): Promise<ClaimIncentivesResponse> => {
  try {
    //const client = await obolClient();
    const claimResult = await client.incentives.claimIncentives(address);
    return claimResult;
  } catch (err) {
    console.log(err, "err");
  }
};


const testFunction = async () => {
  const isAuthorised = await acceptObolLatestTermsAndConditions();
  console.log(isAuthorised, "isAuthorised");
  const testingClusterDefinition = await createObolCluster();
  console.log(testingClusterDefinition, "testingClusterDefinition");
};

testFunction();