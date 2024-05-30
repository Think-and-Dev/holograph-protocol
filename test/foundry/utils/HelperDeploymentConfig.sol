// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {Constants} from "../utils/Constants.sol";

import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

library HelperDeploymentConfig {
  function getInitCodeHtokenETH() public pure returns (bytes memory) {
    return
      abi.encode(
        bytes32(0x000000000000000000000000000000000000000000000000000068546f6b656e), //htokenHash
        Constants.getHolographRegistryProxy(), //registry address
        abi.encode(Constants.getDeployer(), uint16(0))
      );
  }

  function getInitCodeSampleErc721() public pure returns (bytes memory) {
    return abi.encode(Constants.getDeployer());
  }

  function getInitCodeSampleErc20() public pure returns (bytes memory) {
    return abi.encode(Constants.getDeployer(), uint16(0));
  }

  function getDeployConfigERC20(
    bytes32 contractType,
    uint32 chainType,
    bytes memory contractByteCode,
    string memory tokenName,
    string memory tokenSymbol,
    bytes32 eventConfig,
    string memory domainSeparator,
    bytes memory initCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    deployConfig.contractType = contractType; //hToken
    deployConfig.chainType = chainType; //holograph id
    deployConfig.salt = bytes32(0x00000000000000000000000000000000000000000000000000000000000003e8);
    deployConfig.byteCode = contractByteCode;
    deployConfig.initCode = abi.encode(
      tokenName, //token name
      tokenSymbol, //tokenSymbol
      uint8(18), //decimals
      eventConfig, //eventConfig
      domainSeparator, //domainSeparator
      "1", //domainVersion
      false, //skipInit,
      initCode
    );
    return deployConfig;
  }

  function getDeployConfigERC721(
    bytes32 contractType,
    uint32 chainType,
    bytes memory contractByteCode,
    string memory tokenName,
    string memory tokenSymbol,
    uint16 royaltyBps,
    bytes memory initCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    deployConfig.contractType = contractType;
    deployConfig.chainType = chainType; //holograph id
    deployConfig.salt = Constants.saltHex;
    deployConfig.byteCode = contractByteCode;
    deployConfig.initCode = abi.encode(
      tokenName, //token name
      tokenSymbol, //tokenSymbol
      royaltyBps, //royaltyBps
      uint256(0x0000000000000000000000000000000000000000000000000000000000000000), //eventConfig
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
      getDeployConfigERC20(
        bytes32(0x000000000000000000000000000000000000486f6c6f67726170684552433230), //hToken hash
        chainType,
        contractByteCode,
        "Holographed ETH",
        "hETH",
        0x0000000000000000000000000000000000000000000000000000000000000000,
        "Holographed ETH",
        getInitCodeHtokenETH()
      );
  }
  /*
   * @note This contract is used to get the DeploymentConfig for hToken ETH
   * @dev This contract provides helper functions  to get the DeploymentConfig by chainType (getHolographIdL1 or getHolographIdL2) for hToken ETH
   */
  function getERC721(
    uint32 chainType,
    bytes memory contractByteCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC721(
        bytes32(0x0000000000000000000000000000000000486f6c6f6772617068455243373231), //HolographERC721 hash,
        chainType,
        contractByteCode,
        "Sample ERC721 Contract (localhost)", //todo see localhost network, refact to param
        "SMPLR",
        1000, //royalty
        getInitCodeSampleErc721()
      );
  }

  function getERC20(
    uint32 chainType,
    bytes memory contractByteCode
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC20(
        bytes32(0x000000000000000000000000000000000000486f6c6f67726170684552433230), //hToken hash
        chainType,
        contractByteCode,
        "Sample ERC20 Token (localhost)",
        "SMPL",
        0x0000000000000000000000000000000000000000000000000000000000000006,
        "Sample ERC20 Token",
        getInitCodeSampleErc20()
      );
  }
}
