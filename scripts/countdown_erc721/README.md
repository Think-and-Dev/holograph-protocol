# CountdownERC721 Contract 

This folder contains three scripts:

- `1-deploy.ts`
- `2-update-admin.ts`

Below are the steps required to run the scripts successfully.

</br>

## Prerequisites

- Node.js and npm installed (v20.11.1)
- Typescript (ES2022)
- Wallet private key
- Network provider URL
- Optional: Hardware wallet (e.g., Ledger)
  
</br>

## Environment Variables

Ensure the following environment variables are set:
- `PRIVATE_KEY`: Wallet private key
- `CUSTOM_ERC721_SALT`: Salt for deterministic address generation (must be a 32-character hexadecimal string)
- `CUSTOM_ERC721_PROVIDER_URL`: Network provider URL
- `HARDWARE_WALLET_ENABLED`: (Optional)  Flag indicating whether a hardware wallet is enabled
- `HOLOGRAPH_ENVIRONMENT`: Holograph environment (localhost, develop, testnet, mainnet)

</br>

## Script 1: Contract Deploy

This script utilizes hardcoded values, which need to be updated, to generate the initialization parameters for deploying the contract.


### Steps

1. **Load Sensitive Information Safely:**
   - Ensure that you have set the required environment variables mentioned above.

2. **Set the Static Values:**
   - Configure the static values for the countdown ERC721 contract:
     - `contractName`: Name of the ERC721 contract
     - `contractSymbol`: Symbol of the ERC721 contract
     - `countdownERC721Initializer`: Initializer object containing various parameters for the ERC721 contract

3. **Preparing to Deploy Contract:**
   - Encode contract initialization parameters.
   - Generate deployment configuration hash and sign it.

4. **Deploy the Contract:**
   - Execute the deployment process.
   - Upon successful deployment, the contract address will be displayed.

</br>

To run the script, use the following command in your terminal:

```sh
ts-node countdown_erc721/deploy.ts
```

</br>

## Script 2: Update Admin

This is a straightforward script that invokes the contract to update the admin using predefined values.

### Steps

2. **Set the static values:**
   - Configure the static values:
     - `contractAddress`: The CountdownERC721 address
     - `newAdmin`: The wallet address of the new owner.
  
3. **Run the script update the admin:**
```sh
ts-node countdown_erc721/update-admin.ts 
```