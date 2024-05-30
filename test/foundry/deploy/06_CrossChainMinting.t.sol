// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {HelperDeploymentConfig} from "../utils/HelperDeploymentConfig.sol";

import {Holograph} from "../../../src/Holograph.sol";
import {HolographBridge} from "../../../src/HolographBridge.sol";
import {HolographRegistry} from "../../../src/HolographRegistry.sol";
import {HolographFactory} from "../../../src/HolographFactory.sol";
import {HolographOperator, OperatorJob} from "../../../src/HolographOperator.sol";

import {LayerZeroModule, GasParameters} from "../../../src/module/LayerZeroModule.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {Holographer} from "../../../src/enforcer/Holographer.sol";
import {HolographERC721} from "../../../src/enforcer/HolographERC721.sol";
import {SampleERC721} from "../../../src/token/SampleERC721.sol";
import {MockLZEndpoint} from "../../../src/mock/MockLZEndpoint.sol";
import {Verification} from "../../../src/struct/Verification.sol";
import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";

contract CrossChainMinting is Test {
  event BridgeableContractDeployed(address indexed contractAddress, bytes32 indexed hash);

  uint256 public chain1;
  uint256 public chain2;
  string public LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  string public LOCALHOST2_RPC_URL = vm.envString("LOCALHOST2_RPC_URL");

  uint256 privateKeyDeployer = Constants.getPKDeployer();
  address deployer = vm.addr(privateKeyDeployer);

  uint32 holographIdL1 = Constants.getHolographIdL1();
  uint32 holographIdL2 = Constants.getHolographIdL2();

  uint256 constant BLOCKTIME = 60;
  uint256 constant GWEI = 1000000000; // 1 Gwei
  uint256 constant TESTGASLIMIT = 10000000; // Gas limit
  uint256 constant GASPRICE = 1000000000; // 1 Gwei as gas price

  uint256 msgBaseGas;
  uint256 msgGasPerByte;
  uint256 jobBaseGas;
  uint256 jobGasPerByte;

  Holograph holographChain1;
  Holograph holographChain2;
  HolographOperator holographOperatorChain1;
  HolographOperator holographOperatorChain2;
  Holographer utilityTokenHolographerChain1;
  Holographer utilityTokenHolographerChain2;
  MockLZEndpoint mockLZEndpointChain1;
  MockLZEndpoint mockLZEndpointChain2;
  HolographFactory holographFactoryChain1;
  HolographFactory holographFactoryChain2;
  HolographBridge holographBridgeChain1;
  HolographBridge holographBridgeChain2;
  LayerZeroModule lzModuleChain1;
  LayerZeroModule lzModuleChain2;

  HolographRegistry holographRegistryChain1;
  HolographRegistry holographRegistryChain2;

  struct EstimatedGas {
    bytes payload;
    uint256 estimatedGas;
    uint256 fee;
    uint256 hlgFee;
    uint256 msgFee;
    uint256 dstGasPrice;
  }

  function getLzMsgGas(bytes memory _payload) public view returns (uint256) {
    uint256 totalGas = msgBaseGas + (_payload.length * msgGasPerByte);
    return totalGas;
  }

  function getHlgMsgGas(uint256 _gasLimit, bytes memory _payload) public view returns (uint256) {
    uint256 totalGas = _gasLimit + jobBaseGas + (_payload.length * jobGasPerByte);
    return totalGas;
  }

  function getRequestPayload(address _target, bytes memory _data) public returns (bytes memory) {
    vm.selectFork(chain1);
    vm.prank(deployer);
    return
      holographBridgeChain1.getBridgeOutRequestPayload(
        holographIdL2,
        _target,
        type(uint256).max,
        type(uint256).max,
        _data
      );
  }

  function getEstimatedGas(
    address _target,
    bytes memory _data,
    bytes memory _payload
  ) public returns (EstimatedGas memory) {
    vm.selectFork(chain2);
    (bool success, bytes memory result) = address(holographOperatorChain2).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(holographOperatorChain2.jobEstimator.selector, _payload)
    );
    uint256 jobEstimatorGas = abi.decode(result, (uint256));

    uint256 estimatedGas = TESTGASLIMIT - jobEstimatorGas + 100000;

    vm.selectFork(chain1);
    vm.prank(deployer);
    bytes memory payload = holographBridgeChain1.getBridgeOutRequestPayload(
      holographIdL2,
      _target,
      estimatedGas,
      GWEI,
      _data
    );

    (uint256 fee1, uint256 fee2, uint256 fee3) = holographBridgeChain1.getMessageFee(
      holographIdL2,
      estimatedGas,
      GWEI,
      payload
    );

    uint256 total = fee1 + fee2;

    vm.selectFork(chain2);
    (bool success2, bytes memory result2) = address(holographOperatorChain2).call{gas: TESTGASLIMIT, value: total}(
      abi.encodeWithSelector(holographOperatorChain2.jobEstimator.selector, payload)
    );

    uint256 jobEstimatorGas2 = abi.decode(result2, (uint256));

    estimatedGas = TESTGASLIMIT - jobEstimatorGas2;

    estimatedGas = getHlgMsgGas(estimatedGas, payload);

    return
      EstimatedGas({
        payload: payload,
        estimatedGas: estimatedGas,
        fee: total,
        hlgFee: fee1,
        msgFee: fee2,
        dstGasPrice: fee3
      });
  }

  function setUp() public {
    chain1 = vm.createFork(LOCALHOST_RPC_URL);
    chain2 = vm.createFork(LOCALHOST2_RPC_URL);

    vm.selectFork(chain1);
    holographChain1 = Holograph(payable(Constants.getHolograph()));
    holographOperatorChain1 = HolographOperator(payable(Constants.getHolographOperatorProxy()));
    holographRegistryChain1 = HolographRegistry(payable(Constants.getHolographRegistryProxy()));
    mockLZEndpointChain1 = MockLZEndpoint(payable(Constants.getMockLZEndpoint()));
    holographFactoryChain1 = HolographFactory(payable(Constants.getHolographFactoryProxy()));
    holographBridgeChain1 = HolographBridge(payable(Constants.getHolographBridgeProxy()));
    lzModuleChain1 = LayerZeroModule(payable(Constants.getLayerZeroModuleProxy()));

    GasParameters memory gasParams = lzModuleChain1.getGasParameters(holographIdL1);
    msgBaseGas = gasParams.msgBaseGas;
    msgGasPerByte = gasParams.msgGasPerByte;
    jobBaseGas = gasParams.jobBaseGas;
    jobGasPerByte = gasParams.jobGasPerByte;

    vm.selectFork(chain2);
    holographChain2 = Holograph(payable(Constants.getHolograph()));
    holographOperatorChain2 = HolographOperator(payable(Constants.getHolographOperatorProxy()));
    holographRegistryChain2 = HolographRegistry(payable(Constants.getHolographRegistryProxy()));
    mockLZEndpointChain2 = MockLZEndpoint(payable(Constants.getMockLZEndpoint()));
    holographFactoryChain2 = HolographFactory(payable(Constants.getHolographFactoryProxy()));
    holographBridgeChain2 = HolographBridge(payable(Constants.getHolographBridgeProxy()));
    lzModuleChain2 = LayerZeroModule(payable(Constants.getLayerZeroModuleProxy()));

  }

  // Enable operators for chain1 and chain2

  // should add 10 operator wallets for each chain
  function testAddOperators() public {
    vm.selectFork(chain1);
    HolographERC20 HLGCHAIN1 = HolographERC20(payable(Constants.getHolographUtilityToken()));
    vm.selectFork(chain2);
    HolographERC20 HLGCHAIN2 = HolographERC20(payable(Constants.getHolographUtilityToken()));

    address[] memory wallets = new address[](10); // Array to hold operator addresses

    // generate 10 operator wallets
    for (uint i = 0; i < 10; i++) {
      wallets[i] = address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, i)))));
    }

    vm.selectFork(chain1);
    (uint256 bondAmount, ) = holographOperatorChain1.getPodBondAmounts(1);

    for (uint i = 0; i < wallets.length; i++) {
      address wallet = wallets[i];

      vm.selectFork(chain1);
      vm.prank(deployer);
      HLGCHAIN1.transfer(wallet, bondAmount);
      vm.startPrank(wallet);
      HLGCHAIN1.approve(address(holographOperatorChain1), bondAmount);
      holographOperatorChain1.bondUtilityToken(wallet, bondAmount, 1);
      vm.stopPrank();

      vm.selectFork(chain2);
      vm.prank(deployer);
      HLGCHAIN2.transfer(wallet, bondAmount);
      vm.startPrank(wallet);
      HLGCHAIN2.approve(address(holographOperatorChain2), bondAmount);
      holographOperatorChain2.bondUtilityToken(wallet, bondAmount, 1);
      vm.stopPrank();
    }
  }

  function getConfigSampleERC20() public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getERC20(
      Constants.getHolographIdL1(),
      vm.getCode("SampleERC20.sol:SampleERC20")
    );

    bytes32 hashSampleERC20 = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashSampleERC20);
  }


  // SampleERC20
  function testSampleERC20() public {
    console.log("---------------------- SampleERC20 ----------------------");

    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash) = getConfigSampleERC20();
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});
    
    vm.selectFork(chain2);
    address sampleErc20Address = holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash);

    assertEq(sampleErc20Address, address(0), "ERC20 contract not deployed on chain2");

    vm.selectFork(chain1);
    sampleErc20Address = holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash);

    vm.selectFork(chain2);
    bytes memory data = abi.encode(erc20Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain2.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain2.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload);

    payload = estimatedGas.payload;

    (bool success, ) = address(mockLZEndpointChain2).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(
        mockLZEndpointChain2.crossChainMessage.selector,
        address(holographOperatorChain2),
        getLzMsgGas(payload),
        payload
      )
    );

    vm.prank(deployer);
    holographOperatorChain2.setMessagingModule(originalMessagingModule);

    vm.expectEmit(true, true, false, false);
    emit BridgeableContractDeployed(
      sampleErc20Address,
      erc20ConfigHash
    );

    (bool success2,) = address(holographOperatorChain2).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain2.executeJob.selector, payload)
    );

    assertEq(sampleErc20Address, holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash), "ERC20 contract not deployed on chain2");
  }
}
