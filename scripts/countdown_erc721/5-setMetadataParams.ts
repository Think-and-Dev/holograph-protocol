import { Contract, Signer, ethers } from 'ethers';
import { LedgerSigner } from '@anders-t/ethers-ledger';
import { JsonRpcProvider, Log, TransactionReceipt, TransactionResponse } from '@ethersproject/providers';
import { parsedEnv } from './env.validation';
import { MetadataParams } from './types';
import { flattenObject } from '../utils/utils';

require('dotenv').config();

/**
 * Check out the README file
 */

async function main() {
  /*
   * STEP 1: LOAD SENSITIVE INFORMATION SAFELY
   */

  const privateKey = parsedEnv.PRIVATE_KEY;
  const providerURL = parsedEnv.CUSTOM_ERC721_PROVIDER_URL;
  const isHardwareWalletEnabled = parsedEnv.HARDWARE_WALLET_ENABLED;

  const provider: JsonRpcProvider = new JsonRpcProvider(providerURL);

  let deployer: Signer;
  if (isHardwareWalletEnabled) {
    deployer = new LedgerSigner(provider, "44'/60'/0'/0/0");
  } else {
    deployer = new ethers.Wallet(privateKey, provider);
  }

  /*
   * STEP 2: SET HARDCODED VALUES
   */

  const contractAddress = '';

  const params: MetadataParams = {
    name: 'NewCountdownERC721',
    description: 'Description of the token',
    imageURI: 'ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png',
    animationURI: 'ar://animationUriHere',
    externalUrl: 'https://your-nft-project.com',
    encryptedMediaUrl: 'ar://encryptedMediaUriHere',
    decryptionKey: 'decryptionKeyHere',
    hash: 'uniqueNftHashHere',
    decryptedMediaUrl: 'ar://decryptedMediaUriHere',
    tokenOfEdition: 0,
    editionSize: 0,
  };

  /*
   * STEP 3: CREATE THE TX
   */

  const countdownERC721ABI = [
    'function setMetadataParams(tuple(string,string,string,string,string,string,string,string,string,uint256,uint256) params) external',
  ];
  const countdownErc721Contract = new Contract(contractAddress, countdownERC721ABI, deployer);

  let tx: TransactionResponse;
  try {
    tx = await countdownErc721Contract.setMetadataParams(flattenObject(params));
  } catch (error) {
    throw new Error(`Failed to create transaction.`, { cause: error });
  }

  console.log('Transaction:', tx.hash);
  const receipt: TransactionReceipt = await tx.wait();

  if (receipt?.status !== 1) {
    throw new Error('Failed to confirm the transaction.');
  }

  console.log(`The transaction was executed successfully! Exiting script ✅\n`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
