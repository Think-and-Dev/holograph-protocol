// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {Constants} from "../utils/Constants.sol";

import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

library HelperERC20Config {
  function getInitCodeHtokenETH() public pure returns (bytes memory) {
    return
      abi.encode(
        bytes32(0x000000000000000000000000000000000000000000000000000068546f6b656e), //htokenHash
        Constants.getHolographRegistryProxy(), //registry address
        abi.encode(Constants.getDeployer(), uint16(0))
      );
  }
  function getDeployConfig(
    uint32 chainType,
    bytes memory contractByteCode,
    string memory tokenName,
    string memory tokenSymbol,
    bytes memory initCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    deployConfig.contractType = bytes32(0x000000000000000000000000000000000000486f6c6f67726170684552433230);
    deployConfig.chainType = chainType; //holograph id
    deployConfig.salt = bytes32(0x00000000000000000000000000000000000000000000000000000000000003e8);
    deployConfig.byteCode = contractByteCode;
    deployConfig.initCode = abi.encode(
      tokenName, //token name
      tokenSymbol, //tokenSymbol
      uint8(18), //decimals
      uint256(0x0000000000000000000000000000000000000000000000000000000000000000), //eventConfig
      tokenName, //domainSeparator
      "1", //domainVersion
      false, //skipInit,
      initCode
    );
    return deployConfig;
  }

  function getDeployConfigHash(DeploymentConfig memory deployConfig, address deployer) public pure returns (bytes32) {
    return
      keccak256(
        abi.encodePacked(
          deployConfig.contractType,
          deployConfig.chainType,
          deployConfig.salt,
          keccak256(deployConfig.byteCode),
          keccak256(deployConfig.initCode),
          deployer
        )
      );
  }
  /*
   * @note This contract is used to get the DeploymentConfig for hToken ETH
   * @dev This contract provides helper functions  to get the DeploymentConfig by chainType (getHolographIdL1 or getHolographIdL2) for hToken ETH
   */
  function getHtokenEth(
    uint32 chainType,
    bytes memory contractByteCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfig(
        chainType,
        contractByteCode,
        "Holographed ETH",
        "hETH",
        getInitCodeHtokenETH()
      );
  }
}
