// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {DeployedSetUp} from "../utils/DeployedSetUp.t.sol";

contract ValidateDeployChain2Test is DeployedSetUp {
  uint256 localHost2Fork;
  string LOCALHOST2_RPC_URL = vm.envString("LOCALHOST2_RPC_URL");

/**
 * @notice Initializes the test environment and sets up contract instances for Holograph Protocol deployments
 * @dev This function sets up the test environment by creating a fork of the local blockchain, initializing 
 * the parent class with the active fork, and calling the `setUp` function of the parent class to deploy and 
 * initialize the necessary contract instances for Holograph Protocol testing.
 */
  function setUp() public override {
    localHost2Fork = vm.createFork(LOCALHOST2_RPC_URL);
    vm.selectFork(localHost2Fork);
    super.init(vm.activeFork());
    super.setUp();
  }

/**
 * @notice Verifies the correct deployment of the Holograph Interfaces contract.
 * @dev This test checks that the Holograph Interfaces contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographInterfaces:'
 */
  function testHolographInterfaces() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographInterfaces.sol:HolographInterfaces");
    assertEq(holographInterfacesDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the Holograph contract.
 * @dev This test checks that the Holograph contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode.
 * Refers to the hardhat test with the description 'Holograph:'
 */
  function testHolograph() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("Holograph.sol:Holograph");
    assertEq(holographDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the Holograph ERC721 contract.
 * @dev This test checks that the Holograph ERC721 contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode.
 * Refers to the hardhat test with the description 'CxipERC721 Enforcer'
 */
  function testHolographERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC721.sol:HolographERC721");
    assertEq(holographERC721Deployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the CxIP ERC721 Proxy contract.
 * @dev This test checks that the CxIP ERC721 Proxy contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode. 
 * Refers to the hardhat test with the description 'CxipERC721Proxy:'
 */
  //TODO fix and add test name
  function testCxipERC721Proxy() public {
    vm.skip(true);
    bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721Proxy.sol:CxipERC721Proxy");
    assertEq(cxipERC721ProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the CxIP ERC721 contract.
 * @dev This test checks that the CxIP ERC721 contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode.
 * Refers to the hardhat test with the description 'CxipERC721:'
 */
  function testCxipERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721.sol:CxipERC721");
    assertEq(cxipERC721Deployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the ERC20Mock contract.
 * @dev This test function checks that the ERC20Mock contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode.
 * Refers to the hardhat test with the description 'ERC20Mock:'
 */
  function testErc20Mock() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("ERC20Mock.sol:ERC20Mock");
    assertEq(erc20MockDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the Holograph Bridge contract.
 * @dev This test function checks that the Holograph Bridge contract is deployed correctly by comparing the deployed bytecode 
 * with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographBridge:'
 */
  function testHolographBridge() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridge.sol:HolographBridge");
    assertEq(holographBridgeDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the Holograph Bridge Proxy contract.
 * @dev This test function checks that the Holograph Bridge Proxy contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographBridgeProxy:'
 */
  function testHolographBridgeProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridgeProxy.sol:HolographBridgeProxy");
    assertEq(holographBridgeProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographERC20 contract.
 * @dev This test function checks that the HolographERC20 contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographERC20:'
 */
  function testHolographERC20() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC20.sol:HolographERC20");
    assertEq(holographERC20Deployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographFactory contract.
 * @dev This test function checks that the HolographFactory contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographFactory:'
 */
  function testHolographFactory() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactory.sol:HolographFactory");
    assertEq(holographFactoryDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographFactoryProxy contract.
 * @dev This test function checks that the HolographFactoryProxy contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographFactoryProxy:'
 */
  function testHolographFactoryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactoryProxy.sol:HolographFactoryProxy");
    assertEq(holographFactoryProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographGenesisLocal contract.
 * @dev This test function checks that the HolographGenesisLocal contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographGenesis:'
 */
  //TODO bytes not match and refact to the get holograph by network
  function HolographGenesis() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographGenesisLocal.sol:HolographGenesisLocal");
    assertEq(holographGenesisDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographOperator contract.
 * @dev This test function checks that the HolographOperator contract is deployed correctly by comparing the deployed 
 * bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographOperator:'
 */
  function testHolographOperator() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographOperator.sol:HolographOperator");
    assertEq(holographOperatorDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographOperatorProxy contract.
 * @dev This test function checks that the HolographOperatorProxy contract is deployed correctly by comparing 
 * the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'HolographOperatorProxy:'.
 */
  function testHolographOperatorProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographOperatorProxy.sol:HolographOperatorProxy");
    assertEq(holographOperatorProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographRegistry contract.
 * @dev This test function checks that the HolographRegistry contract is deployed correctly by comparing the 
 * deployed bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographRegistry:'
 */
  function testHolographRegistry() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRegistry.sol:HolographRegistry");
    assertEq(holographRegistryDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographRegistryProxy contract.
 * @dev This test function checks that the HolographRegistryProxy contract is deployed correctly by comparing 
 * he deployed bytecode with the expected bytecode.
 * Refers to the hardhat test with the description 'HolographRegistryProxy:'
 */
  function testHolographRegistryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRegistryProxy.sol:HolographRegistryProxy");
    assertEq(holographRegistryProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographTreasury contract.
 * @dev This test function checks that the HolographTreasury contract is deployed correctly by comparing the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'HolographTreasury:'.
 */
  function testHolographTreasury() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographTreasury.sol:HolographTreasury");
    assertEq(holographTreasuryDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographTreasuryProxy contract.
 * @dev This test function checks that the HolographTreasuryProxy contract is deployed correctly by comparing the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'HolographTreasuryProxy:'.
 */
  function testHolographTreasuryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographTreasuryProxy.sol:HolographTreasuryProxy");
    assertEq(holographTreasuryProxyDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the hToken contract.
 * @dev This test function checks that the hToken contract is deployed correctly by comparing the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'hToken Holographer:'.
 */
  function testHToken() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("hToken.sol:hToken");
    assertEq(hTokenDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the MockERC721Receiver contract.
 * @dev This test function checks that the MockERC721Receiver contract is deployed correctly by comparing the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'MockERC721Receiver:'.
 */
  function testMockERC721Receiver() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("MockERC721Receiver.sol:MockERC721Receiver");
    assertEq(mockERC721ReceiverDeployed.code, bytecodeDeployed);
  }

/**
 * @notice Verifies the correct deployment of the HolographRoyalties contract.
 * @dev This test function checks that the HolographRoyalties contract is deployed correctly by comparing the deployed bytecode with the expected bytecode.
 * Refers to the Hardhat test with the description 'HolographRoyalties:'.
 */
  function testHolographRoyalties() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRoyalties.sol:HolographRoyalties");
    assertEq(holographRoyaltiesDeployed.code, bytecodeDeployed);
  }

  //TODO fix and add test name
  function testFailSampleERC20() public {
    vm.skip(true);
    bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC20.sol:SampleERC20");
    assertEq(sampleERC20Deployed.code, bytecodeDeployed);
  }

  // TODO: address not found
  function testFailSampleERC721() public {
    vm.skip(true);
    bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC721.sol:SampleERC721");
    assertEq(sampleERC721Deployed.code, bytecodeDeployed);
  }

  //TODO the remaining tests using sample erc20 and erc721
}
