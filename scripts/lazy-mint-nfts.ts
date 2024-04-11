import { ethers } from 'ethers';
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';
dotenv.config();

async function main() {
  // Define the path to the contract's artifact
  const artifactPath = path.join(
    __dirname, // Adjust this path as necessary to point to your artifacts directory
    '../artifacts/contracts/CustomERC721.sol/CustomERC721.json'
  );

  // Read the contract artifact
  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));

  // Extract the ABI from the artifact
  const contractABI = artifact.abi;

  // Load sensitive information safely
  const privateKey = process.env.PRIVATE_KEY as string;
  const contractAddress = '';
  const providerURL = '';

  // Setup ethers provider and wallet
  const provider = new ethers.providers.JsonRpcProvider(providerURL);
  const wallet = new ethers.Wallet(privateKey, provider);
  const contract = new ethers.Contract(contractAddress, contractABI, wallet);

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
