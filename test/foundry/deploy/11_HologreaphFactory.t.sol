// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants, ErrorConstants} from "../utils/Constants.sol";
import {HelperDeploymentConfig} from "../utils/HelperDeploymentConfig.sol";
import {HelperSignEthMessage} from "../utils/HelperSignEthMessage.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {Holographer} from "../../../src/enforcer/Holographer.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {ERC20} from "../../../src/interface/ERC20.sol";
import {Mock} from "../../../src/mock/Mock.sol";
import {HolographFactory} from "../../../src/HolographFactory.sol";
import {HolographRegistry} from "../../../src/HolographRegistry.sol";
import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";
import {Verification} from "../../../src/struct/Verification.sol";

contract HologreaphFactory is Test {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");

  HolographERC20 holographERC20;
  HolographRegistry holographRegistry;
  HolographFactory holographFactory;
  Holograph holograph;
  Mock mock;

  uint256 privateKeyDeployer = Constants.getPKDeployer();
  address deployer = vm.addr(privateKeyDeployer);
  address owner = vm.addr(1);
  address newOwner = vm.addr(2);
  address alice = vm.addr(3);
  bytes constant invalidSignature = abi.encode(0x0000000000000000000000000000000000000000000000000000000000000000);

  function setUp() public {
    vm.prank(deployer);
    mock = new Mock();

    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    holographRegistry = HolographRegistry(payable(Constants.getHolographRegistryProxy()));
    holographFactory = HolographFactory(payable(Constants.getHolographFactory()));
    holograph = Holograph(payable(Constants.getHolograph()));
  }

  function getConfigHtokenETH() public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getHtokenEth(
      Constants.getHolographIdL1(),
      vm.getCode("hTokenProxy.sol:hTokenProxy")
    );

    bytes32 hashHtokenEth = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashHtokenEth);
  }
  function getConfigERC721() public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getERC721(
      Constants.getHolographIdL1(),
      vm.getCode("SampleERC721.sol:SampleERC721")
    );

    bytes32 hashSampleERC721 = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashSampleERC721);
  }
  /*
   * INIT Section
   */

  /**
   * @notice Test the initialization of the HolographFactory contract
   * @dev  Refers to the hardhat test with the description 'should fail if already initialized'
   */
  function testInitRevert() public {
    bytes memory init = abi.encode(Constants.getHolographFactory(), Constants.getHolographRegistry());
    vm.expectRevert(bytes(ErrorConstants.ALREADY_INITIALIZED_ERROR_MSG));
    holographFactory.init(abi.encode(address(deployer), address(holographERC20)));
  }

  /*
   * Deploy Holographable Contract Section
   */

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail with invalid signature if config is incorrect'
   */
  function testDeployRevertInvalidSignature() public {
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    Verification memory signature = Verification({v: v, r: r, s: s});

    vm.expectRevert(bytes(ErrorConstants.INVALID_SIGNATURE_ERROR_MSG));
    vm.prank(deployer);
    //TODO see this (owner), chain config// wrong in hardhat
    holographFactory.deployHolographableContract(deployConfig, signature, owner);
  }

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail contract was already deployed'
   */
  function testDeployRevertContractAlreadyDeployed() public {
    //TODO
    vm.skip(true);
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    console.logBytes32(hashHtokenEth);
    Verification memory signature = Verification({v: v, r: r, s: s});

    bytes32 hash = keccak256(
      abi.encodePacked(
        deployConfig.contractType,
        deployConfig.chainType,
        deployConfig.salt,
        keccak256(deployConfig.byteCode),
        keccak256(deployConfig.initCode),
        deployer
      )
    );
    console.logBytes32(hash);
    console.logBytes32(hashHtokenEth);
    bytes memory holographerBytecode = type(Holographer).creationCode;
    // console.logBytes32(bytes32(holographerBytecode));
    address holographerAddress = address(
      uint160(
        uint256(
          keccak256(abi.encodePacked(bytes1(0xff), address(holographFactory), hash, keccak256(holographerBytecode)))
        )
      )
    );
    bool isContract = _isContract(holographerAddress);
    console.log("holographerAddress", holographerAddress);
    console.log(isContract);

    vm.expectRevert(bytes(ErrorConstants.ALREADY_DEPLOYED_ERROR_MSG));
    // vm.prank(deployer);
    holographFactory.deployHolographableContract(deployConfig, signature, deployer);
  }
  //TODO remove this function, olny for test the previous test
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    console.logBytes32(codehash);
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail with invalid signature if signature.r is incorrect'
   */
  function testDeployRevertSignatureRIncorrect() public {
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    Verification memory signature = Verification({v: v, r: bytes32(invalidSignature), s: s});

    vm.expectRevert(bytes(ErrorConstants.INVALID_SIGNATURE_ERROR_MSG));
    vm.prank(deployer);
    holographFactory.deployHolographableContract(deployConfig, signature, deployer);
  }
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail with invalid signature if signature.s is incorrect'
   */
  function testDeployRevertSignatureSIncorrect() public {
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    Verification memory signature = Verification({v: uint8(bytes1(invalidSignature)), r: r, s: s});

    vm.expectRevert(bytes(ErrorConstants.INVALID_SIGNATURE_ERROR_MSG));
    vm.prank(deployer);
    holographFactory.deployHolographableContract(deployConfig, signature, deployer);
  }
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail with invalid signature if signature.s is incorrect'
   */
  function testDeployRevertSignatureVIncorrect() public {
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    Verification memory signature = Verification({v: uint8(bytes1(invalidSignature)), r: r, s: s});

    vm.expectRevert(bytes(ErrorConstants.INVALID_SIGNATURE_ERROR_MSG));
    vm.prank(deployer);
    holographFactory.deployHolographableContract(deployConfig, signature, deployer);
  }
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail with invalid signature if signer is incorrect'
   */
  function testDeployRevertSignatureSignIncorrect() public {
    (DeploymentConfig memory deployConfig, bytes32 hashHtokenEth) = getConfigHtokenETH();

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashHtokenEth)
    );
    Verification memory signature = Verification({v: uint8(bytes1(invalidSignature)), r: r, s: s});

    vm.expectRevert(bytes(ErrorConstants.INVALID_SIGNATURE_ERROR_MSG));
    vm.prank(deployer);
    holographFactory.deployHolographableContract(deployConfig, signature, deployer);
  }

  /*
   * BridgeIn Section
   */
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should return the expected selector from the input payload'
   */
  function testExpectedSelectorFromPayload() public {
    vm.skip(true);
    (DeploymentConfig memory deployConfig, bytes32 hashSampleERC721) = getConfigERC721();

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashSampleERC721)
    );
    Verification memory signature = Verification({v: uint8(bytes1(invalidSignature)), r: r, s: s});

    bytes memory payload = abi.encode(deployConfig, signature, address(deployer));
    console.log(block.chainid);
    console.log(block.chainid);
    vm.prank(deployer);
    holographFactory.bridgeIn(uint32(block.chainid), payload);
  }

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should revert if payload data is invalid'
   */
  function testRevertDataPayloadInvalid() public {
    bytes memory payload = "0x0000000000000000000000000000000000000000000000000000000000000000";

    vm.expectRevert();
    vm.prank(deployer);
    holographFactory.bridgeIn(uint32(block.chainid), payload);
  }

  /*
   * BridgeOut Section
   */
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should return selector and payload'
   */
  function testContemplateSelectorFromPayload() public {
    // vm.skip(true);
    (DeploymentConfig memory deployConfig, bytes32 hashSampleERC721) = getConfigERC721();

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(
      privateKeyDeployer,
      HelperSignEthMessage.toEthSignedMessageHash(hashSampleERC721)
    );
    Verification memory signature = Verification({v: uint8(bytes1(invalidSignature)), r: r, s: s});

    bytes memory payload = abi.encode(deployConfig, signature, address(deployer));
    vm.prank(alice);
    (bytes4 selector, bytes memory data) = holographFactory.bridgeOut(1, address(deployer), payload);
    data;
    assertEq(selector, bytes4(0xb7e03661));
  }

  /*
   * setHolograph Section
   */
  /**
   * @notice
   * @dev  Refers to the hardhat test with the description ' should allow admin to alter _holographSlot'
   */

  function testAllowAdminAlterHolographSlot() public {
    vm.prank(deployer);
    holographFactory.setHolograph(address(holograph));
    assertEq(holographFactory.getHolograph(), address(holograph));
  }

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail to allow not owner to alter _holographSlot'
   */

  function testRevertNotAdminAllowAlterHolographSlot() public {
    vm.prank(newOwner);
    vm.expectRevert(bytes(ErrorConstants.ONLY_ADMIN_ERROR_MSG));
    holographFactory.setHolograph(address(holograph));
  }

  /*
   * setRegestry Section
   */

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should allow admin to alter _registrySlot'
   */

  function testAllowAdminAlterRegistrySlot() public {
    vm.prank(deployer);
    holographFactory.setRegistry(address(holographRegistry));
    assertEq(holographFactory.getRegistry(), address(holographRegistry));
  }

  /**
   * @notice
   * @dev  Refers to the hardhat test with the description 'should fail to allow owner to alter _registrySlot'
   */

  function testRevertNotAdminAllowAlterRegistrySlot() public {
    vm.prank(newOwner);
    vm.expectRevert(bytes(ErrorConstants.ONLY_ADMIN_ERROR_MSG));
    holographFactory.setRegistry(address(holographRegistry));
  }

  /*
   * Receive/Fallback Section
   */

  function testRevertRecive() public {
    vm.prank(deployer);
    vm.expectRevert();
    payable(address(holographFactory)).transfer(1 ether);
  }
  function testRevertFallback() public {
    vm.prank(deployer);
    vm.expectRevert();
    payable(address(holographFactory)).transfer(0);
  }
}

// =======================================================================++++++++=======================================================================
// Holographed ETH
// hETH
// hTokenHash 0x000000000000000000000000000000000000000000000000000068546f6b656e
// registry.address 0xB47C0E0170306583AA979bF30c0407e2bFE234b2
// =======================================================================++++++++=======================================================================
// erc20ConfigHash 0xd2e71490b2d9867ac759230c85c08cd27b097aad31a554afaf3ea3b3bc11953e
// Deployed "hToken ETH" at: 0xd27712cBE6308536C23d41A097F8Be408c20bee3
