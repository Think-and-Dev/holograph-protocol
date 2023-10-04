declare var global: any;
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { DeployFunction } from '@holographxyz/hardhat-deploy-holographed/types';
import {
  LeanHardhatRuntimeEnvironment,
  hreSplit,
  genesisDeployHelper,
  generateInitCode,
  genesisDeriveFutureAddress,
  zeroAddress,
  getGasPrice,
  getGasLimit,
  txParams,
} from '../scripts/utils/helpers';
import { HolographERC721Event, ConfigureEvents } from '../scripts/utils/events';
import { SuperColdStorageSigner } from 'super-cold-storage-signer';
import { MultisigAwareTx } from '../scripts/utils/multisig-aware-tx';
import Web3 from 'web3';

const func: DeployFunction = async function (hre1: HardhatRuntimeEnvironment) {
  let { hre, hre2 } = await hreSplit(hre1, global.__companionNetwork);
  const accounts = await hre.ethers.getSigners();
  let deployer: SignerWithAddress | SuperColdStorageSigner = accounts[0];

  const salt = hre.deploymentSalt;

  // TODO: Figure out if we need to deploy this
  // const futureErc721Address = await genesisDeriveFutureAddress(
  //   hre,
  //   salt,
  //   'HolographERC721',
  //   generateInitCode(
  //     ['string', 'string', 'uint16', 'uint256', 'bool', 'bytes'],
  //     [
  //       'Holograph ERC721 Collection', // contractName
  //       'hNFT', // contractSymbol
  //       1000, // contractBps == 0%
  //       ConfigureEvents([]), // eventConfig
  //       true, // skipInit
  //       generateInitCode(['address'], [deployer.address]), // initCode
  //     ]
  //   )
  // );
  // hre.deployments.log('the future "HolographERC721" address is', futureErc721Address);

  // // HolographERC721
  // let erc721DeployedCode: string = await hre.provider.send('eth_getCode', [futureErc721Address, 'latest']);
  // if (erc721DeployedCode == '0x' || erc721DeployedCode == '') {
  //   hre.deployments.log('"HolographERC721" bytecode not found, need to deploy"');
  //   let holographErc721 = await genesisDeployHelper(
  //     hre,
  //     salt,
  //     'HolographERC721',
  //     generateInitCode(
  //       ['string', 'string', 'uint16', 'uint256', 'bool', 'bytes'],
  //       [
  //         'Holograph ERC721 Collection', // contractName
  //         'hNFT', // contractSymbol
  //         1000, // contractBps == 0%
  //         ConfigureEvents([]), // eventConfig
  //         true, // skipInit
  //         generateInitCode(['address'], [deployer.address]), // initCode
  //       ]
  //     ),
  //     futureErc721Address
  //   );
  // } else {
  //   hre.deployments.log('"HolographERC721" is already deployed.');
  // }

  const web3 = new Web3();

  const holographRegistryProxy = await hre.ethers.getContract('HolographRegistryProxy', deployer);
  const holographRegistry = ((await hre.ethers.getContract('HolographRegistry', deployer)) as Contract).attach(
    holographRegistryProxy.address
  );

  const futureCxipErc721Address = await genesisDeriveFutureAddress(
    hre,
    salt,
    'CxipERC721',
    generateInitCode(['address'], [deployer.address])
  );
  hre.deployments.log('the future "CxipERC721" address is', futureCxipErc721Address);

  // CxipERC721
  let cxipErc721DeployedCode: string = await hre.provider.send('eth_getCode', [futureCxipErc721Address, 'latest']);
  if (cxipErc721DeployedCode == '0x' || cxipErc721DeployedCode == '') {
    hre.deployments.log('"CxipERC721" bytecode not found, need to deploy"');
    let cxipErc721 = await genesisDeployHelper(
      hre,
      salt,
      'CxipERC721',
      generateInitCode(['address'], [deployer.address]),
      futureCxipErc721Address
    );
  } else {
    hre.deployments.log('"CxipERC721" is already deployed.');
  }

  // Register CxipERC721
  const cxipErc721Hash = '0x' + web3.utils.asciiToHex('CxipERC721').substring(2).padStart(64, '0');
  if ((await holographRegistry.getContractTypeAddress(cxipErc721Hash)) != futureCxipErc721Address) {
    const cxipErc721Tx = await MultisigAwareTx(
      hre,
      deployer,
      'HolographRegistry',
      holographRegistry,
      await holographRegistry.populateTransaction.setContractTypeAddress(cxipErc721Hash, futureCxipErc721Address, {
        ...(await txParams({
          hre,
          from: deployer,
          to: holographRegistry,
          data: holographRegistry.populateTransaction.setContractTypeAddress(cxipErc721Hash, futureCxipErc721Address),
        })),
      })
    );
    hre.deployments.log('Transaction hash:', cxipErc721Tx.hash);
    await cxipErc721Tx.wait();
    hre.deployments.log(
      `Registered "CxipERC721" to: ${await holographRegistry.getContractTypeAddress(cxipErc721Hash)}`
    );
  } else {
    hre.deployments.log('"CxipERC721" is already registered');
  }
};

export default func;
func.tags = ['TEMP_ERC721_UPGRADE'];
func.dependencies = [];
