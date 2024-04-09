// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
// import {HolographInterfaces} from "../../../contracts/HolographInterfaces.sol";
// import {Holographer} from "../../../contracts/HolographInterfaces.sol";
import {Constants} from "../utils/Constants.sol";
import {DeployedSetUp} from "../utils/DeployedSetUp.t.sol";

contract ValidateDeployChain2 is DeployedSetUp {
  uint256 localHost2Fork;
  string LOCALHOST2_RPC_URL = vm.envString("LOCALHOST2_RPC_URL");

  function setUp() public override {
    super.setUp();
    localHost2Fork = vm.createFork(LOCALHOST2_RPC_URL);
    vm.selectFork(localHost2Fork);
  }

  function testHolographInterfaces() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographInterfaces.sol:HolographInterfaces");
    assertEq(holographInterfacesDeployed.code, bytecodeDeployed);
  }

  function testHolograph() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("Holograph.sol:Holograph");
    assertEq(holographDeployed.code, bytecodeDeployed);
  }

  function testHolographERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC721.sol:HolographERC721");
    assertEq(holographERC721Deployed.code, bytecodeDeployed);
  }

  //TO DO: fail, not found the sc
  function testCxipERC721Proxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721Proxy.sol:CxipERC721Proxy");
    assertEq(cxipERC721ProxyDeployed.code, bytecodeDeployed);
  }

  function testCxipERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721.sol:CxipERC721");
    assertEq(cxipERC721Deployed.code, bytecodeDeployed);
  }

  function testErc20Mock() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("ERC20Mock.sol:ERC20Mock");
    assertEq(erc20MockDeployed.code, bytecodeDeployed);
  }

  function testHolographBridge() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridge.sol:HolographBridge");
    assertEq(holographBridgeDeployed.code, bytecodeDeployed);
  }

  function testHolographBridgeProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridgeProxy.sol:HolographBridgeProxy");
    assertEq(holographBridgeProxyDeployed.code, bytecodeDeployed);
  }

  function testHolographERC20() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("holographERC20.sol:holographERC20");
    assertEq(holographERC20Deployed.code, bytecodeDeployed);
  }

  function testHolographFactory() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactory.sol:HolographFactory");
    assertEq(holographFactoryDeployed.code, bytecodeDeployed);
  }

  function testHolographFactoryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactoryProxy.sol:HolographFactoryProxy");
    assertEq(holographFactoryProxyDeployed.code, bytecodeDeployed);
  }

  // TODO refact local to use network
  function testHolographGenesis() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographGenesisLocal.sol:HolographGenesisLocal");
    assertEq(holographGenesisDeployed.code, bytecodeDeployed);
  }

  function testHolographOperator() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographOperator.sol:HolographOperator");
    assertEq(holographOperatorDeployed.code, bytecodeDeployed);
  }

  function testHolographOperatorProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographOperatorProxy.sol:HolographOperatorProxy");
    assertEq(holographOperatorProxyDeployed.code, bytecodeDeployed);
  }

  function testHolographRegistry() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRegistry.sol:HolographRegistry");
    assertEq(holographRegistryDeployed.code, bytecodeDeployed);
  }

  function testHolographRegistryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRegistryProxy.sol:HolographRegistryProxy");
    assertEq(holographRegistryProxyDeployed.code, bytecodeDeployed);
  }

  function testHolographTreasury() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographTreasury.sol:HolographTreasury");
    assertEq(holographTreasuryDeployed.code, bytecodeDeployed);
  }

  function testHolographTreasuryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographTreasuryProxy.sol:HolographTreasuryProxy");
    assertEq(holographTreasuryProxyDeployed.code, bytecodeDeployed);
  }

  function testHToken() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("hToken.sol:hToken");
    assertEq(hTokenDeployed.code, bytecodeDeployed);
  }

  function testMockERC721Receiver() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("MockERC721Receiver.sol:MockERC721Receiver");
    assertEq(mockERC721ReceiverDeployed.code, bytecodeDeployed);
  }

  function testHolographRoyalties() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRoyalties.sol:HolographRoyalties");
    assertEq(holographRoyaltiesDeployed.code, bytecodeDeployed);
  }

  function testSampleERC20() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC20.sol:SampleERC20");
    assertEq(sampleERC20Deployed.code, bytecodeDeployed);
  }

  function testSampleERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC721.sol:SampleERC721");
    assertEq(sampleERC721Deployed.code, bytecodeDeployed);
  }
}
