// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {Constants} from "./Constants.sol";
import {RandomAddress} from "./Utils.sol";
import {DummyMetadataRenderer} from "./DummyMetadataRenderer.sol";

import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";
import {DropsInitializerV2} from "../../../src/drops/struct/DropsInitializerV2.sol";
import {SalesConfiguration} from "../../../src/drops/struct/SalesConfiguration.sol";

library HelperDeploymentConfig {
  uint256 constant dropEventConfig = 0x0000000000000000000000000000000000000000000000000000000000040000;
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

  function getInitCodeCxipERC721() public pure returns (bytes memory) {
    bytes32 CxipERC721Hex = 0x0000000000000000000000000000000000000000000043786970455243373231;
    return abi.encode(CxipERC721Hex, Constants.getHolographRegistryProxy(), getInitCodeSampleErc721());
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
      eventConfig,
      // uint256(0x0000000000000000000000000000000000000000000000000000000000000000), //eventConfig
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
    bytes32 eventConfig,
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
      eventConfig,
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
    bytes memory contractByteCode,
    bytes32 eventConfig,
    bool isL1
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC20(
        bytes32(0x000000000000000000000000000000000000486f6c6f67726170684552433230), //hToken hash
        chainType,
        contractByteCode,
        "Holographed ETH",
        "hETH",
        bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),
        "Holographed ETH",
        getInitCodeHtokenETH()
      );
  }

  function getERC20(
    uint32 chainType,
    bytes memory contractByteCode,
    bool isL1
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC20(
        bytes32(0x000000000000000000000000000000000000486f6c6f67726170684552433230), //hToken hash
        chainType,
        contractByteCode,
        isL1 ? "Sample ERC20 Token (localhost)" : "Sample ERC20 Token (localhost2)",
        "SMPL",
        0x0000000000000000000000000000000000000000000000000000000000000006,
        "Sample ERC20 Token",
        getInitCodeSampleErc20()
      );
  }

  function getCxipERC721(
    uint32 chainType,
    bytes memory contractByteCode,
    bytes32 eventConfig,
    bool isL1
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC721(
        bytes32(0x0000000000000000000000000000000000486f6c6f6772617068455243373231), //HolographERC721 hash,
        chainType,
        contractByteCode,
        isL1 ? "CXIP ERC721 Collection (localhost)" : "CXIP ERC721 Collection (localhost2)",
        "CXIP",
        eventConfig, //eventConfig
        1000, //royalty
        getInitCodeCxipERC721()
      );
  }

  function getERC721(
    uint32 chainType,
    bytes memory contractByteCode,
    bytes32 eventConfig,
    bool isL1
  ) public pure returns (DeploymentConfig memory deployConfig) {
    return
      getDeployConfigERC721(
        bytes32(0x0000000000000000000000000000000000486f6c6f6772617068455243373231), //HolographERC721 hash,
        chainType,
        contractByteCode,
        isL1 ? "Sample ERC721 Contract (localhost)" : "Sample ERC721 Contract (localhost2)",
        "SMPLR",
        eventConfig, //eventConfig
        1000, //royalty
        getInitCodeSampleErc721()
      );
  }

  function getERC721WithConfigDropERC721V2(
    uint32 chainType,
    bytes memory contractByteCode,
    bytes32 eventConfig,
    bool isL1
  ) public pure returns (DeploymentConfig memory deployConfig) {
    SalesConfiguration memory salesConfiguration = SalesConfiguration({
      publicSaleStart: 0,
      publicSaleEnd: 0,
      presaleStart: 0,
      presaleEnd: 0,
      publicSalePrice: 0,
      maxSalePurchasePerAddress: 0,
      presaleMerkleRoot: bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
    });

    DropsInitializerV2 memory initializer = DropsInitializerV2({
      initialOwner: Constants.getDeployer(),
      fundsRecipient: payable(Constants.getDeployer()),
      editionSize: 0,
      royaltyBPS: 1000,
      salesConfiguration: salesConfiguration,
      metadataRenderer: Constants.getEditionsMetadataRendererProxy(),
      metadataRendererInit: abi.encode("decscription", "imageURI", "animationURI")
    });

    deployConfig.contractType = bytes32(0x0000000000000000000000486f6c6f677261706844726f704552433732315632); //Source contract type HolographDropERC721V2
    deployConfig.chainType = chainType; //holograph id
    deployConfig.salt = Constants.saltHex;
    deployConfig.byteCode = contractByteCode;
    deployConfig.initCode = abi.encode(initializer);
    return deployConfig;
  }

  // function getDeployConfigDropERC721(
  //   bytes32 contractType,
  //   uint32 chainType,
  //   bytes memory contractByteCode,
  //   string memory tokenName,
  //   string memory tokenSymbol,
  //   bytes32 eventConfig,
  //   uint16 royaltyBps,
  //   bytes memory initCode
  // ) public pure returns (DeploymentConfig memory deployConfig) {
  //   deployConfig.contractType = contractType;
  //   deployConfig.chainType = chainType; //holograph id
  //   deployConfig.salt = Constants.saltHex;
  //   deployConfig.byteCode = contractByteCode;
  //   deployConfig.initCode = abi.encode(
  //     tokenName, //token name
  //     tokenSymbol, //tokenSymbol
  //     royaltyBps, //royaltyBps
  //     eventConfig,
  //     false, //skipInit,
  //     initCode
  //   );
  //   return deployConfig;
  // }
  // function getDeployConfigDropERC721V2(
  //   bytes32 contractType,
  //   uint32 chainType,
  //   bytes memory contractByteCode,
  //   string memory tokenName,
  //   string memory tokenSymbol,
  //   bytes32 eventConfig,
  //   uint16 royaltyBps,
  //   bytes memory initCode
  // ) public pure returns (DeploymentConfig memory deployConfig) {
  //   deployConfig.contractType = contractType;
  //   deployConfig.chainType = chainType; //holograph id
  //   deployConfig.salt = Constants.saltHex;
  //   deployConfig.byteCode = contractByteCode;
  //   deployConfig.initCode = initCode;
  //   return deployConfig;
  // }

  // function getDropERC721Test(
  //   uint32 chainType,
  //   bytes memory contractByteCode,
  //   bytes32 eventConfig,
  //   bool isL1,
  //   address metadataRender
  // ) public view returns (DeploymentConfig memory deployConfig) {
  //   DropsInitializerV2 memory initializer = getDropInitializerV2(metadataRender);
  //   bytes memory initCode = abi.encode(
  //     bytes32(0x0000000000000000000000486f6c6f677261706844726f704552433732315632), // Source contract type HolographDropERC721V2
  //     address(Constants.getHolographRegistryProxy()),
  //     abi.encode(initializer) // actual init code for source contract (HolographDropERC721V2)
  //   );

  //   return
  //     getDeployConfigDropERC721(
  //       bytes32(0x0000000000000000000000000000000000486f6c6f6772617068455243373231), //hash v2
  //       chainType,
  //       contractByteCode,
  //       string.concat("Test NFT DropERC721 ", isL1 ? "(localhost)" : "(localhost2)"),
  //       "TNFT",
  //       eventConfig, //eventConfig
  //       1000, //royaltyBps
  //       initCode
  //     );
  // }

  // function getDropInitializerV2(address metadataRender) public view returns (DropsInitializerV2 memory) {
  //   // DummyMetadataRenderer dummyRenderer = new DummyMetadataRenderer();

  //   return
  //     DropsInitializerV2({
  //       initialOwner: RandomAddress.randomAddress(),
  //       fundsRecipient: payable(RandomAddress.randomAddress()),
  //       editionSize: 100,
  //       royaltyBPS: 1000,
  //       salesConfiguration: getSalesConfiguration(),
  //       metadataRenderer: metadataRender,
  //       metadataRendererInit: ""
  //     });
  // }

  // function getSalesConfiguration() public pure returns (SalesConfiguration memory) {
  //   //  return  SalesConfiguration memory saleConfig = SalesConfiguration({
  //   return
  //     SalesConfiguration({
  //       publicSaleStart: 0, // starts now
  //       publicSaleEnd: type(uint64).max, // never ends
  //       presaleStart: 0, // never starts
  //       presaleEnd: 0, // never ends
  //       publicSalePrice: 100, //usd
  //       maxSalePurchasePerAddress: 0, // no limit
  //       presaleMerkleRoot: bytes32(0) // no presale
  //     });
  // }

  // function getDropERC721(
  //   uint32 chainType,
  //   bytes memory contractByteCode,
  //   bytes32 eventConfig,
  //   bool isL1
  // ) public view returns (DeploymentConfig memory deployConfig) {
  //   SalesConfiguration memory salesConfiguration = SalesConfiguration({
  //     publicSaleStart: 0,
  //     publicSaleEnd: 0,
  //     presaleStart: 0,
  //     presaleEnd: 0,
  //     publicSalePrice: 0,
  //     maxSalePurchasePerAddress: 0,
  //     presaleMerkleRoot: bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)
  //   });

  //   DropsInitializerV2 memory initializer = DropsInitializerV2({
  //     initialOwner: Constants.getDeployer(),
  //     fundsRecipient: payable(Constants.getDeployer()),
  //     editionSize: 0,
  //     royaltyBPS: 1000,
  //     salesConfiguration: salesConfiguration,
  //     metadataRenderer: Constants.getEditionsMetadataRendererProxy(),
  //     metadataRendererInit: abi.encode("decscription", "imageURI", "animationURI")
  //   });

  //   bytes memory initCode = abi.encode(
  //     bytes32(0x0000000000000000000000486f6c6f677261706844726f704552433732315632), // Source contract type HolographDropERC721V2
  //     address(Constants.getHolographRegistryProxy()),
  //     abi.encode(initializer) // actual init code for source contract (HolographDropERC721V2)
  //   );

  //   return
  //     getDeployConfigDropERC721(
  //       bytes32(0x0000000000000000000000000000000000486f6c6f6772617068455243373231), //hash v2
  //       chainType,
  //       contractByteCode,
  //       // string.concat("Test NFT DropERC721 ", isL1 ? "(localhost)" : "(localhost2)"),
  //       "HolographDropERC721V2",
  //       "TNFT",
  //       eventConfig, //eventConfig
  //       1000, //royaltyBps
  //       abi.encode(initializer)
  //     );
  // }
}
