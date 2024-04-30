# Custom ERC721 Contract Deployment

This script automates the deployment process of a custom ERC721 contract. Below are the steps required to run the script successfully.

## Prerequisites

- Node.js and npm installed (v20.11.1)
- Typescript (ES2022)
- Wallet private key
- Network provider URL
- Optional: Hardware wallet (e.g., Ledger)

## Steps

1. **Load Sensitive Information Safely:**
   - Ensure that you have set the required environment variables:
     - `PRIVATE_KEY`: Wallet private key
     - `CUSTOM_ERC721_SALT`: Salt for deterministic address generation (must be a 32-character hexadecimal string)
     - `CUSTOM_ERC721_PROVIDER_URL`: Network provider URL
     - `HARDWARE_WALLET_ENABLED`: Flag indicating whether a hardware wallet is enabled
     - `HOLOGRAPH_ENVIRONMENT`: Holograph environment (localhost, develop, testnet, mainnet)

2. **Set the Static Values:**
   - Configure the static values for the custom ERC721 contract:
     - `contractName`: Name of the ERC721 contract
     - `contractSymbol`: Symbol of the ERC721 contract
     - `customERC721Initializer`: Initializer object containing various parameters for the ERC721 contract

3. **CSV File Validation:**
   - Provide a CSV file with the required data for deployment.
   - Validate the CSV file header and content.
   - Generate provenance hash and encrypt URIs for lazy minting.

4. **Preparing to Deploy Contract:**
   - Encode contract initialization parameters.
   - Generate deployment configuration hash and sign it.

5. **Deploy the Contract:**
   - Execute the deployment process.
   - Upon successful deployment, the contract address will be displayed.

## Environment Variables

Ensure the following environment variables are set:

- `PRIVATE_KEY`: Ethereum private key
- `CUSTOM_ERC721_SALT`: Salt for deterministic address generation (32-character hexadecimal string)
- `CUSTOM_ERC721_PROVIDER_URL`: Ethereum network provider URL
- `HARDWARE_WALLET_ENABLED`: (Optional) Flag indicating whether a hardware wallet is enabled
- `HOLOGRAPH_ENVIRONMENT`: Holograph environment


## How to run it?

To run the script, use the following command in your terminal:

```sh
ts-node custom_delay_reveal_erc721/encrypt-batch-ranges.ts --file path-to-file.csv

```