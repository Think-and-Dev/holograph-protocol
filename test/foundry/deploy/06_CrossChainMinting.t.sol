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

  function getRequestPayload(address _target, bytes memory _data, bool isL1) public returns (bytes memory) {
    if (isL1) {
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
    } else {
      vm.selectFork(chain2);
      vm.prank(deployer);
      return
        holographBridgeChain2.getBridgeOutRequestPayload(
          holographIdL1,
          _target,
          type(uint256).max,
          type(uint256).max,
          _data
        );
    }
  }

  function getEstimatedGas(
    address _target,
    bytes memory _data,
    bytes memory _payload,
    bool isL1
  ) public returns (EstimatedGas memory) {
    if (isL1) {
      vm.selectFork(chain2);
      (bool success, bytes memory result) = address(holographOperatorChain2).call{gas: TESTGASLIMIT}(
        abi.encodeWithSelector(holographOperatorChain2.jobEstimator.selector, _payload)
      );
      uint256 jobEstimatorGas = abi.decode(result, (uint256));

      uint256 estimatedGas = TESTGASLIMIT - jobEstimatorGas + 150000;

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
    } else {
      vm.selectFork(chain1);
      (bool success, bytes memory result) = address(holographOperatorChain1).call{gas: TESTGASLIMIT}(
        abi.encodeWithSelector(holographOperatorChain1.jobEstimator.selector, _payload)
      );
      uint256 jobEstimatorGas = abi.decode(result, (uint256));

      uint256 estimatedGas = TESTGASLIMIT - jobEstimatorGas + 150000;

      vm.selectFork(chain2);
      vm.prank(deployer);
      bytes memory payload = holographBridgeChain2.getBridgeOutRequestPayload(
        holographIdL1,
        _target,
        estimatedGas,
        GWEI,
        _data
      );

      (uint256 fee1, uint256 fee2, uint256 fee3) = holographBridgeChain2.getMessageFee(
        holographIdL1,
        estimatedGas,
        GWEI,
        payload
      );

      uint256 total = fee1 + fee2;

      vm.selectFork(chain1);
      (bool success2, bytes memory result2) = address(holographOperatorChain1).call{gas: TESTGASLIMIT, value: total}(
        abi.encodeWithSelector(holographOperatorChain1.jobEstimator.selector, payload)
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

  function getConfigSampleERC20(bool isL1) public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getERC20(
      isL1 ? Constants.getHolographIdL1() : Constants.getHolographIdL2(),
      vm.getCode("SampleERC20.sol:SampleERC20"),
      isL1
    );

    bytes32 hashSampleERC20 = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashSampleERC20);
  }

  function getConfigSampleERC721(bool isL1) public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getERC721(
      isL1 ? Constants.getHolographIdL1() : Constants.getHolographIdL2(),
      vm.getCode("SampleERC721.sol:SampleERC721"),
      0x0000000000000000000000000000000000000000000000000000000000000086, // eventConfig,
      isL1
    );

    bytes32 hashSampleERC721 = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashSampleERC721);
  }

  function getConfigCxipERC721(bool isL1) public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getCxipERC721(
      isL1 ? Constants.getHolographIdL1() : Constants.getHolographIdL2(),
      vm.getCode("CxipERC721Proxy.sol:CxipERC721Proxy"),
      0x0000000000000000000000000000000000000000000000000000000000000086, // eventConfig,
      isL1
    );

    bytes32 hashSampleERC721 = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashSampleERC721);
  }

  function getConfigHtokenETH(bool isL1) public view returns (DeploymentConfig memory, bytes32) {
    DeploymentConfig memory deployConfig = HelperDeploymentConfig.getHtokenEth(
      isL1 ? Constants.getHolographIdL1() : Constants.getHolographIdL2(),
      vm.getCode("hTokenProxy.sol:hTokenProxy")
    );

    bytes32 hashHtokenEth = HelperDeploymentConfig.getDeployConfigHash(deployConfig, deployer);
    return (deployConfig, hashHtokenEth);
  }

  // SampleERC20
  // deploy chain1 equivalent on chain2
  function testSampleERC20Chain2() public {
    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash) = getConfigSampleERC20(true);
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

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, true);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, true);

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
    emit BridgeableContractDeployed(sampleErc20Address, erc20ConfigHash);

    (bool success2, ) = address(holographOperatorChain2).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain2.executeJob.selector, payload)
    );

    assertEq(
      sampleErc20Address,
      holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash),
      "ERC20 contract not deployed on chain2"
    );
  }

  // deploy chain2 equivalent on chain1
  function testSampleERC20Chain1() public {
    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash) = getConfigSampleERC20(false);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address sampleErc20Address = holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash);

    assertEq(sampleErc20Address, address(0), "ERC20 contract not deployed on chain1");

    vm.selectFork(chain2);
    sampleErc20Address = holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash);

    vm.selectFork(chain1);
    bytes memory data = abi.encode(erc20Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain1.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, false);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, false);

    payload = estimatedGas.payload;

    (bool success, ) = address(mockLZEndpointChain1).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(
        mockLZEndpointChain1.crossChainMessage.selector,
        address(holographOperatorChain1),
        getLzMsgGas(payload),
        payload
      )
    );

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(originalMessagingModule);

    vm.expectEmit(true, true, false, false);
    emit BridgeableContractDeployed(sampleErc20Address, erc20ConfigHash);

    (bool success2, ) = address(holographOperatorChain1).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain1.executeJob.selector, payload)
    );

    assertEq(
      sampleErc20Address,
      holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash),
      "ERC20 contract not deployed on chain1"
    );
  }

  // SampleERC721

  // deploy chain1 equivalent on chain2
  function testSampleERC721Chain2() public {
    (DeploymentConfig memory erc721Config, bytes32 erc721ConfigHash) = getConfigSampleERC721(true);
    console.log("erc721ConfigHash");
    console.logBytes32(erc721ConfigHash);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc721ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain2);
    address sampleErc721Address = holographRegistryChain2.getHolographedHashAddress(erc721ConfigHash);
    console.log("sampleErc721Address 1");

    assertEq(sampleErc721Address, address(0), "ERC721 contract not deployed on chain2");

    vm.selectFork(chain1);
    sampleErc721Address = holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash);
    console.log("sampleErc721Address 2");
    console.logAddress(sampleErc721Address);

    vm.selectFork(chain2);
    bytes memory data = abi.encode(erc721Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain2.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain2.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, true);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, true);

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
    emit BridgeableContractDeployed(sampleErc721Address, erc721ConfigHash);

    (bool success2, ) = address(holographOperatorChain2).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain2.executeJob.selector, payload)
    );

    assertEq(
      sampleErc721Address,
      holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash),
      "ERC721 contract not deployed on chain2"
    );
  }

  // deploy chain2 equivalent on chain1
  function testSampleERC721Chain1() public {
    (DeploymentConfig memory erc721Config, bytes32 erc721ConfigHash) = getConfigSampleERC721(false);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc721ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address sampleErc721Address = holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash);

    assertEq(sampleErc721Address, address(0), "ERC721 contract not deployed on chain1");

    vm.selectFork(chain2);
    sampleErc721Address = holographRegistryChain2.getHolographedHashAddress(erc721ConfigHash);

    vm.selectFork(chain1);
    bytes memory data = abi.encode(erc721Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain1.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, false);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, false);

    payload = estimatedGas.payload;

    (bool success, ) = address(mockLZEndpointChain1).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(
        mockLZEndpointChain1.crossChainMessage.selector,
        address(holographOperatorChain1),
        getLzMsgGas(payload),
        payload
      )
    );

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(originalMessagingModule);

    vm.expectEmit(true, true, false, false);
    emit BridgeableContractDeployed(sampleErc721Address, erc721ConfigHash);

    (bool success2, ) = address(holographOperatorChain1).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain1.executeJob.selector, payload)
    );

    assertEq(
      sampleErc721Address,
      holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash),
      "ERC721 contract not deployed on chain1"
    );
  }

  // CxipERC721

  // deploy chain1 equivalent on chain2
  function testCxipERC721Chain2() public {
    (DeploymentConfig memory erc721Config, bytes32 erc721ConfigHash) = getConfigCxipERC721(true);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc721ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    console.log("erc721ConfigHash");
    console.logBytes32(erc721ConfigHash);

    vm.selectFork(chain2);
    address sampleErc721Address = holographRegistryChain2.getHolographedHashAddress(erc721ConfigHash);

    assertEq(sampleErc721Address, address(0), "ERC721 contract not deployed on chain2");

    vm.selectFork(chain1);
    sampleErc721Address = holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash);

    console.log("sampleErc721Address 2");
    console.logAddress(sampleErc721Address);

    vm.selectFork(chain2);
    bytes memory data = abi.encode(erc721Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain2.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain2.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, true);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, true);

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
    emit BridgeableContractDeployed(sampleErc721Address, erc721ConfigHash);

    (bool success2, ) = address(holographOperatorChain2).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain2.executeJob.selector, payload)
    );

    assertEq(
      sampleErc721Address,
      holographRegistryChain2.getHolographedHashAddress(erc721ConfigHash),
      "ERC721 contract not deployed on chain2"
    );
  }

  // deploy chain2 equivalent on chain1
  function testCxipERC721Chain1() public {
    (DeploymentConfig memory erc721Config, bytes32 erc721ConfigHash) = getConfigCxipERC721(false);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc721ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address sampleErc721Address = holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash);

    assertEq(sampleErc721Address, address(0), "ERC721 contract not deployed on chain1");

    vm.selectFork(chain2);
    sampleErc721Address = holographRegistryChain2.getHolographedHashAddress(erc721ConfigHash);

    vm.selectFork(chain1);
    bytes memory data = abi.encode(erc721Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain1.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, false);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, false);

    payload = estimatedGas.payload;

    (bool success, ) = address(mockLZEndpointChain1).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(
        mockLZEndpointChain1.crossChainMessage.selector,
        address(holographOperatorChain1),
        getLzMsgGas(payload),
        payload
      )
    );

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(originalMessagingModule);

    vm.expectEmit(true, true, false, false);
    emit BridgeableContractDeployed(sampleErc721Address, erc721ConfigHash);

    (bool success2, ) = address(holographOperatorChain1).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain1.executeJob.selector, payload)
    );

    assertEq(
      sampleErc721Address,
      holographRegistryChain1.getHolographedHashAddress(erc721ConfigHash),
      "ERC721 contract not deployed on chain1"
    );
  }

  // hToken

  // deploy chain1 equivalent on chain2
  function testHTokenChain2() public {
    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash) = getConfigSampleERC20(true);
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

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, true);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, true);

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
    emit BridgeableContractDeployed(sampleErc20Address, erc20ConfigHash);

    (bool success2, ) = address(holographOperatorChain2).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain2.executeJob.selector, payload)
    );

    assertEq(
      sampleErc20Address,
      holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash),
      "ERC20 contract not deployed on chain2"
    );
  }

  // deploy chain2 equivalent on chain1
  function testHTokenChain1() public {
    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash) = getConfigSampleERC20(false);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHash);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address sampleErc20Address = holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash);

    assertEq(sampleErc20Address, address(0), "ERC20 contract not deployed on chain1");

    vm.selectFork(chain2);
    sampleErc20Address = holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash);

    vm.selectFork(chain1);
    bytes memory data = abi.encode(erc20Config, signature, deployer);

    address originalMessagingModule = holographOperatorChain1.getMessagingModule();

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(Constants.getMockLZEndpoint());

    bytes memory payload = getRequestPayload(Constants.getHolographFactoryProxy(), data, false);

    EstimatedGas memory estimatedGas = getEstimatedGas(Constants.getHolographFactoryProxy(), data, payload, false);

    payload = estimatedGas.payload;

    (bool success, ) = address(mockLZEndpointChain1).call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(
        mockLZEndpointChain1.crossChainMessage.selector,
        address(holographOperatorChain1),
        getLzMsgGas(payload),
        payload
      )
    );

    vm.prank(deployer);
    holographOperatorChain1.setMessagingModule(originalMessagingModule);

    vm.expectEmit(true, true, false, false);
    emit BridgeableContractDeployed(sampleErc20Address, erc20ConfigHash);

    (bool success2, ) = address(holographOperatorChain1).call{gas: estimatedGas.estimatedGas}(
      abi.encodeWithSelector(holographOperatorChain1.executeJob.selector, payload)
    );

    assertEq(
      sampleErc20Address,
      holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash),
      "ERC20 contract not deployed on chain1"
    );
  }
}
