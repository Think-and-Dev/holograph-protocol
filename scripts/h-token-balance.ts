import { NetworkType, networks } from '@holographxyz/networks';
import { ethers } from 'ethers';
import { task } from 'hardhat/config';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { TokenSymbol, getHTokenAddress } from './utils/addresses';

/**
 * Task to get the hToken Balance of an account
 * @param contract The address of the hToken contract
 * @param account The address of the account
 *
 * Run this task with:
 * npx hardhat hTokenBalance --token [hETh, hMatic, hAvax...] --account [accountAddress] --network [the target network]
 */
task('hTokenBalance', 'Get the hToken balance of the recipient')
  .addParam('token', 'The hToken symbol [hETh, hMatic, hAvax...]')
  .addParam('account', 'The address of the account')
  .setAction(async ({ token, account }, hre: HardhatRuntimeEnvironment) => {
    const signer = (await hre.ethers.getSigners())[0]; // Get the first signer

    // Get the address of the token to bridge
    const network = networks[hre.network.name];
    const currentNetworkType: NetworkType = network.type;

    // Get the hToken contract address
    const hTokenAddress = getHTokenAddress(currentNetworkType as NetworkType, token as TokenSymbol);
    if (!hTokenAddress) {
      throw new Error(`Invalid h token: ${token}`);
    }

    // Get the contract's ABI from the compiled artifacts
    const hTokenArtifact = await hre.artifacts.readArtifact('hToken');
    const balanceOfAbi = {
      inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
      name: 'balanceOf',
      outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
      stateMutability: 'view',
      type: 'function',
    };
    hTokenArtifact.abi.push(balanceOfAbi);

    // singer address does not matter. We are only reading
    const hTokenContract = new ethers.Contract(hTokenAddress, hTokenArtifact.abi, signer);

    // Log the account's balance
    const balanceOf = await hTokenContract.balanceOf(account);
    console.log(
      `hToken balance of ${account} is ${balanceOf.toString()} wei or ${ethers.utils.formatEther(balanceOf)} ETH`
    );
  });
