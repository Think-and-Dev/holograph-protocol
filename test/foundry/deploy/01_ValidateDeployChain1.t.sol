// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {DeployedSetUp} from "../utils/DeployedSetUp.t.sol";

contract ValidateDeployChain1 is DeployedSetUp {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");

  function setUp() public override {
    super.setUp();
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
  }

  function testHolographInterfaces() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographInterfaces.sol:HolographInterfaces");
    assertEq(holographInterfacesDeployed.code, bytecodeDeployed);
  }

  // TODO: address not found
  // function testCxipERC721Holographer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("Holographer.sol:Holographer");
  //   assertEq(address(Constants.getCxipERC721Holographer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testCxipERC721Enforcer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC721.sol:HolographERC721");
  //   assertEq(address(Constants.getCxipERC721Enforcer()).code, bytecodeDeployed);
  // }

  function testCxipERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721.sol:CxipERC721");
    assertEq(cxipERC721Deployed.code, bytecodeDeployed);
  }

  // TO DO: fail, not found the sc
  // function testCxipERC721Proxy() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("CxipERC721Proxy.sol:CxipERC721Proxy");
  //   assertEq(address(Constants.getCxipERC721Proxy()).code, bytecodeDeployed);
  // }

  function testERC20Mock() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("ERC20Mock.sol:ERC20Mock");
    assertEq(erc20MockDeployed.code, bytecodeDeployed);
  }

  function testHolograph() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("Holograph.sol:Holograph");
    assertEq(holographDeployed.code, bytecodeDeployed);
  }

  function testHolographBridge() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridge.sol:HolographBridge");
    assertEq(holographBridgeDeployed.code, bytecodeDeployed);
  }

  function testHolographBridgeProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographBridgeProxy.sol:HolographBridgeProxy");
    assertEq(holographBridgeProxyDeployed.code, bytecodeDeployed);
  }

  // TODO: address not found
  // function testHolographer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("Holographer.sol:Holographer");
  //   assertEq(address(Constants.getHolographer()).code, bytecodeDeployed);
  // }

  function testHolographERC20() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC20.sol:HolographERC20");
    assertEq(holographERC20Deployed.code, bytecodeDeployed);
  }

  function testHolographERC721() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC721.sol:HolographERC721");
    assertEq(holographERC721Deployed.code, bytecodeDeployed);
  }

  function testHolographFactory() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactory.sol:HolographFactory");
    assertEq(holographFactoryDeployed.code, bytecodeDeployed);
  }

  function testHolographFactoryProxy() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographFactoryProxy.sol:HolographFactoryProxy");
    assertEq(holographFactoryProxyDeployed.code, bytecodeDeployed);
  }

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

  // TODO: address not found
  // function testHTokenHolographer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("Holographer.sol:Holographer");
  //   assertEq(address(Constants.getHTokenHolographer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testHTokenEnforcer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC20.sol:HolographERC20");
  //   assertEq(address(Constants.getHTokenEnforcer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testHToken() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("hToken.sol:hToken");
  //   assertEq(address(Constants.getHToken()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testMockERC721Receiver() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("MockERC721Receiver.sol:MockERC721Receiver");
  //   assertEq(address(Constants.getMockERC721Receiver()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testMockLZEndpoint() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("MockLZEndpoint.sol:MockLZEndpoint");
  //   assertEq(address(Constants.getMockLZEndpoint()).code, bytecodeDeployed);
  // }

  function testHolographRoyalties() public {
    bytes memory bytecodeDeployed = vm.getDeployedCode("HolographRoyalties.sol:HolographRoyalties");
    assertEq(holographRoyaltiesDeployed.code, bytecodeDeployed);
  }

  // TODO: address not found
  // function testSampleERC20Holographer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("Holographer.sol:Holographer");
  //   assertEq(address(Constants.getSampleERC20Holographer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testSampleERC20Enforcer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC20.sol:HolographERC20");
  //   assertEq(address(Constants.getSampleERC20Enforcer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testSampleERC20() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC20.sol:SampleERC20");
  //   assertEq(address(Constants.getSampleERC20()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testSampleERC721Holographer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("Holographer.sol:Holographer");
  //   assertEq(address(Constants.getSampleERC721Holographer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testSampleERC721Enforcer() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("HolographERC721.sol:HolographERC721");
  //   assertEq(address(Constants.getSampleERC721Enforcer()).code, bytecodeDeployed);
  // }

  // TODO: address not found
  // function testSampleERC721() public {
  //   bytes memory bytecodeDeployed = vm.getDeployedCode("SampleERC721.sol:SampleERC721");
  //   assertEq(address(Constants.getSampleERC721()).code, bytecodeDeployed);
  // }
}
