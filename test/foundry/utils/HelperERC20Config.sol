// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {Constants} from "../utils/Constants.sol";

import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

contract HelperERC20Config {
  constructor() {}

  function getDeployConfig(
    uint32 chainType,
    bytes memory contractByteCode,
    string memory tokenName,
    string memory tokenSymbol,
    bytes memory initCode,
    address deployer
  ) public returns (DeploymentConfig memory deployConfig) {
    initCode;
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
  /**
   * @note This contract is used to get the DeploymentConfig for hToken ETH
   * @dev This contract provides helper functions  to get the DeploymentConfig by chainType (getHolographIdL1 or getHolographIdL2) for hToken ETH
   */
  function getHtokenEth(uint32 chainType) public returns (DeploymentConfig memory deployConfig) {
    return
      helperERC20Config.getDeployConfig(
        chainType,
        vm.getCode("hTokenProxy.sol:hTokenProxy"),
        "Holographed ETH",
        "hETH",
        initCodeHtokenETH,
        deployer
      );
  }
}
