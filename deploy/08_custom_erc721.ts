declare var global: any;
import path from 'path';

import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { DeployFunction, DeployOptions } from '@holographxyz/hardhat-deploy-holographed/types';
import {
  hreSplit,
  txParams,
  genesisDeployHelper,
  generateInitCode,
  genesisDeriveFutureAddress,
  zeroAddress,
  getDeployer,
} from '../scripts/utils/helpers';
import { MultisigAwareTx } from '../scripts/utils/multisig-aware-tx';
import { Contract } from 'ethers';

const func: DeployFunction = async function (hre1: HardhatRuntimeEnvironment) {
  console.log(`Starting deploy script: ${path.basename(__filename)} 👇`);

  let { hre, hre2 } = await hreSplit(hre1, global.__companionNetwork);
  const deployer = await getDeployer(hre);
  const deployerAddress = await deployer.signer.getAddress();

  // Salt is used for deterministic address generation
  const salt = hre.deploymentSalt;

  // Deploy the CustomERC721 custom contract source
  const CustomERC721InitCode = generateInitCode(
    [
      'tuple(uint64,uint96,address,address,string,uint16,tuple(uint104,uint32,uint64,uint64,uint64,uint64,bytes32),tuple(uint256,string,bytes)[])',
    ],
    [
      [
        1,
        10,
        deployerAddress, // initialOwner
        deployerAddress, // fundsRecipient
        '', // contractURI
        1000, // 10% royalty
        [0, 0, 0, 0, 0, 0, '0x' + '00'.repeat(32)], // salesConfig
        [
          [
            5,
            'https://placeholder-uri1.com/',
            '0x00000000000000000000000000000000000000000000000000000000000000406fb73a8c26bf89ea9a8fa8c927042b0c602dc7dffb4614376384cbe15ebc45b40000000000000000000000000000000000000000000000000000000000000014d74bef972bcac96c0d83b64734870bfe84912893000000000000000000000000',
          ],
          [
            5,
            'https://placeholder-uri2.com/',
            '0x00000000000000000000000000000000000000000000000000000000000000406fb73a8c26bf89ea9a8fa8c927042b0c602dc7dffb4614376384cbe15ebc45b40000000000000000000000000000000000000000000000000000000000000014d74bef972bcac96c0d83b64734870bfe84912893000000000000000000000000',
          ],
        ],
      ],
    ]
  );

  const futureCustomERC721Address = await genesisDeriveFutureAddress(hre, salt, 'CustomERC721', CustomERC721InitCode);
  console.log('the future "CustomERC721" address is', futureCustomERC721Address);

  let CustomERC721DeployedCode: string = await hre.provider.send('eth_getCode', [futureCustomERC721Address, 'latest']);

  if (CustomERC721DeployedCode === '0x' || CustomERC721DeployedCode === '') {
    console.log('"CustomERC721" bytecode not found, need to deploy"');
    let CustomERC721 = await genesisDeployHelper(
      hre,
      salt,
      'CustomERC721',
      CustomERC721InitCode,
      futureCustomERC721Address
    );
  } else {
    console.log('"CustomERC721" is already deployed.');
  }

  console.log(`Exiting script: ${__filename} ✅\n`);
};

export default func;
func.tags = ['CustomERC721'];
func.dependencies = ['HolographGenesis', 'DeploySources'];
