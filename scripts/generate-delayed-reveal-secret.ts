import { ethers } from 'ethers';
require('dotenv').config();

async function main() {
  const prefix = 'never-just-use-123';
  const chainId = '';
  const contractAddress = '';
  const idForDelayedRevealNFTs = '';

  if (!chainId || !contractAddress || !idForDelayedRevealNFTs) {
    throw new Error(`All parameters (chainId, contractAddress, idForDelayedRevealNFTs) are required`);
  }

  console.log(`Generating secret hash...`);

  // Concatenate all parts into a single string, assuming these values are strings
  const secretString = `${prefix},${chainId},${contractAddress},${idForDelayedRevealNFTs}`;

  // Convert the concatenated string to bytes and hash it
  const hashedString = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(secretString));

  console.log(`Concatenated String: ${secretString}`);
  console.log(`Hash: ${hashedString}`);
}

main();
