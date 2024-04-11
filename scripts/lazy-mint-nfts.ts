import { ethers } from 'ethers';
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';

import { LedgerSigner } from '@anders-t/ethers-ledger';
dotenv.config();

async function main() {
  // Setup the path to the contract artifact
  const artifactPath = path.join(__dirname, '../artifacts/src/token/CustomERC721.sol/CustomERC721.json');

  // Read the contract artifact
  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));

  // Extract the ABI from the artifact
  const contractABI = artifact.abi;

  // Load sensitive information safely
  const privateKey = process.env.PRIVATE_KEY as string;
  const contractAddress = '';
  const providerURL = '';

  // Setup ethers provider
  const provider = new ethers.providers.JsonRpcProvider(providerURL);

  let signer;
  if (process.env.HARDWARE_WALLET_ENABLED === 'true') {
    signer = new LedgerSigner(provider, "44'/60'/0'/0/0");
  } else {
    signer = new ethers.Wallet(privateKey, provider);
  }

  const contract = new ethers.Contract(contractAddress, contractABI, signer);

  // Example parameters for lazyMint
  const amount = 1;
  const baseURIForTokens = 'https://example.com/baseuri/';
  const encryptedURI = 'https://example.com/nft/encrypted-data';
  const provenanceData = 'exampleProvenanceData'; // NOTE: This can be a JSON stringified object containing metadata about the batch
  const provenanceHash = ethers.utils.id(provenanceData);

  // Encode _data parameter
  const data = ethers.utils.defaultAbiCoder.encode(
    ['bytes', 'bytes32'],
    [ethers.utils.toUtf8Bytes(encryptedURI), provenanceHash]
  );

  // Call lazyMint
  const tx = await contract.lazyMint(amount, baseURIForTokens, data);
  console.log(`Transaction hash: ${tx.hash}`);

  // Wait for the transaction to be mined
  const receipt = await tx.wait();
  console.log(`Transaction confirmed in block ${receipt.blockNumber}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
