// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";

import {Holograph} from "../../../src/Holograph.sol";
import {HolographBridge} from "../../../src/HolographBridge.sol";
import {HolographRegistry} from "../../../src/HolographRegistry.sol";
import {HolographFactory} from "../../../src/HolographFactory.sol";
import {HolographOperator} from "../../../src/HolographOperator.sol";

import {LayerZeroModule} from "../../../src/module/LayerZeroModule.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {Holographer} from "../../../src/enforcer/Holographer.sol";
import {HolographERC721} from "../../../src/enforcer/HolographERC721.sol";
import {SampleERC721} from "../../../src/token/SampleERC721.sol";
import {MockLZEndpoint} from "../../../src/mock/MockLZEndpoint.sol";
import {Verification} from "../../../src/struct/Verification.sol";
import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

import {HolographRegistry} from "../../../src/HolographRegistry.sol";

import {HolographEvents} from "../utils/HolographEvents.sol";

contract CrossChainMinting is Test, HolographEvents {
  uint256 public chain1;
  uint256 public chain2;
  string public LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  string public LOCALHOST2_RPC_URL = vm.envString("LOCALHOST2_RPC_URL");
  uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
  address deployer = vm.addr(privateKeyDeployer);

  uint256 holographIdChain1 = 4294967294;
  uint256 holographIdChain2 = 4294967293;

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

  // address public deployer;
  address public alice;
  address public bob;
  address public charlie;

  struct ERC20ConfigParams {
    string network;
    address deployer;
    string contractName;
    string tokenName;
    string tokenSymbol;
    string domainSeparator;
    string domainVersion;
    uint8 decimals;
    bytes eventConfig;
    bytes initCodeParam;
    string salt;
  }

  struct EstimatedGas {
    bytes payload;
    uint256 estimatedGas;
    uint256 fee;
    uint256 hlgFee;
    uint256 msgFee;
    uint256 dstGasPrice;
  }

  struct GasParameters {
    uint256 msgBaseGas;
    uint256 msgGasPerByte;
    uint256 jobBaseGas;
    uint256 jobGasPerByte;
    uint256 minGasPrice;
    uint256 maxGasLimit;
}

  function getHlgMsgGas(uint256 _gasLimit, bytes memory _payload) public view returns (uint256) {
    vm.selectFork(chain1);
    vm.prank(deployer);
    return holographBridgeChain1.getHlgMsgGas(_gasLimit, _payload);
  }

  function getRequestPayload(address _target, bytes memory _data) public pure returns (bytes memory) {
    vm.selectFork(chain1);
    vm.prank(deployer);
    return holographBridgeChain1.getBridgeOutRequestPayload(holographIdChain2, _target, type(uint256).max, type(uint256).max, _data);
  }

  function getEstimatedGas(address _target, bytes memory _data, bytes memory _payload) public view returns (EstimatedGas memory) {
    vm.selectFork(chain2);
    (bool success, bytes memory result) = holographOperatorChain2.call{gas: TESTGASLIMIT}(
      abi.encodeWithSelector(holographOperatorChain2.jobEstimator.selector, _payload)
    );
    uint256 estimatedGas = TESTGASLIMIT - abi.decode(result, (uint256));

    vm.selectFork(chain1);
    vm.prank(deployer);
    bytes memory payload = holographBridgeChain1.getBridgeOutRequestPayload(holographIdChain2, _target, estimatedGas, GWEI, _data);

    (fee1, fee2, fee3) = holographBridgeChain1.getmessageFee(holographIdChain2, estimatedGas, GWEI, payload);

    uint256 total = fee1 + fee2;

    vm.selectFork(chain2);
    (bool success, bytes memory result2) = holographOperatorChain2.call{gas: TESTGASLIMIT, value: total}(
      abi.encodeWithSelector(holographOperatorChain2.jobEstimator.selector, payload)
    );

    estimatedGas = TESTGASLIMIT + abi.decode(result2, (uint256));

    estimatedGas = getHlgMsgGas(estimatedGas, _payload);

    return EstimatedGas({
      payload: payload,
      estimatedGas: estimatedGas,
      fee: total,
      hlgFee: fee1,
      msgFee: fee2,
      dstGasPrice: fee3
    });
  }

  function encodeInitParams(
    string memory tokenName,
    string memory tokenSymbol,
    uint16 decimals,
    bytes memory eventConfig,
    string memory domainSeparator,
    string memory domainVersion,
    bool skipInit,
    bytes memory initCodeParam
) public pure returns (bytes memory) {
    return abi.encode(
        'string', 'string', 'uint16', 'bytes', 'string', 'string', 'bool', 'bytes',
        tokenName,
        tokenSymbol,
        decimals,
        eventConfig,
        domainSeparator,
        domainVersion,
        skipInit,
        initCodeParam
    );
}

  function generateErc20Config(
    ERC20ConfigParams memory params
  ) public view returns (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash, bytes32 erc20ConfigHashBytes) {
    bytes32 erc20Hash = keccak256(abi.encodePacked("HolographERC20")); //REVISAR
    uint32 chainId = uint32(block.chainid);
    console.logBytes32(erc20Hash);
    bytes memory byteCode = vm.getCode(params.contractName);
    bytes memory initCode = encodeInitParams(
      params.tokenName,
      params.tokenSymbol,
      params.decimals,
      params.eventConfig,
      params.domainSeparator,
      params.domainVersion,
      false,
      params.initCodeParam
    );
    // Generate the ERC20 configuration
    DeploymentConfig memory erc20Config = DeploymentConfig({
      contractType: erc20Hash,
      chainType: chainId,
      salt: bytes32(bytes(params.salt)),
      byteCode: byteCode,
      initCode: initCode
    });

    // Calculate the ERC20 configuration hash
    erc20ConfigHash = keccak256(
      abi.encodePacked(
        erc20Config.contractType,
        keccak256(abi.encodePacked(erc20Config.chainType)),
        keccak256(abi.encodePacked(erc20Config.salt)),
        keccak256(erc20Config.byteCode),
        keccak256(erc20Config.initCode),
        bytes20(params.deployer)
      )
    );

    bytes memory data = abi.encodePacked(erc20ConfigHash);
    bytes32 erc20ConfigHashBytes = keccak256(data);

    return (erc20Config, erc20ConfigHash, erc20ConfigHashBytes);
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

    GasParameters memory gasParams = lzModuleChain1.getGasParameters(holographIdChain1);
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

    _setupAccounts();
  }

  /// @dev Initializes testing accounts.
  function _setupAccounts() private {
    deployer = vm.addr(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
    alice = vm.addr(1);
    bob = vm.addr(2);
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

    console.log("Operators added successfully");
  }

  // SampleERC20
  function testSampleERC20() public {
    // uint256[] memory events = new uint256[](2);
    // events[0] = uint256(HolographERC20Event.bridgeIn);
    // events[1] = uint256(HolographERC20Event.bridgeOut);

    // bytes memory eventConfig = configureEvents(events);

    // console.log("Solidity Output:");
    // console.logBytes(eventConfig);
    // ERC20ConfigParams memory params = ERC20ConfigParams({
    //   network: "localhost",
    //   deployer: deployer,
    //   contractName: "SampleERC20",
    //   tokenName: "Sample ERC20 Token (localhost)",
    //   tokenSymbol: "SMPL",
    //   domainSeparator: "Sample ERC20 Token",
    //   domainVersion: "1",
    //   decimals: 18,
    //   eventConfig: "0x0000000000000000000000000000000000000000000000000000000000000006",
    //   initCodeParam: abi.encodePacked(
    //     keccak256(abi.encodePacked("SampleERC20")),
    //     address(Constants.getHolographRegistry()),
    //     abi.encodePacked(deployer, uint16(0))
    //   ),
    //   salt: "0x0000000000000000000000000000000000000000000000000000000000001000"
    // });

    // (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash, bytes32 erc20ConfigHashBytes) = generateErc20Config(
    //   params
    // );

    // console.log("ERC20 Configuration:");
    // console.logBytes32(erc20ConfigHash);
    // console.logBytes32(erc20ConfigHashBytes);

    // console.log("erc20Config.contractType");
    // console.logBytes32(erc20Config.contractType);
    // console.log("erc20Config.chainType");
    // console.log(erc20Config.chainType);
    // console.log("erc20Config.salt");
    // console.logBytes32(erc20Config.salt);
    // console.log("erc20Config.byteCode");
    // console.logBytes(erc20Config.byteCode);
    // console.log("erc20Config.initCode");
    // console.logBytes(erc20Config.initCode);

    DeploymentConfig memory erc20Config = DeploymentConfig({
      contractType: 0x000000000000000000000000000000000000486f6c6f67726170684552433230,
      chainType: 0xfffffffe,
      salt: 0x00000000000000000000000000000000000000000000000000000000000003e8,
      byteCode: "0x608060405234801561001057600080fd5b50611746806100206000396000f3fe6080604052600436106101795760003560e01c80634ddf47d4116100cb578063900f66ef1161007f578063a03318da11610059578063a03318da146103ed578063f0f540731461040d578063f49062ca1461026b576101d7565b8063900f66ef1461026b57806395aae8bd14610300578063971c34b41461024b576101d7565b80638b1465c6116100b05780638b1465c6146103715780638da5cb5b1461039e5780638f32d59b146103d8576101d7565b80634ddf47d4146103205780638a2fa94c1461024b576101d7565b806336fff0621161012d57806345b596991161010757806345b596991461030057806347abf3be1461026b5780634a1fefbd1461024b576101d7565b806336fff0621461028b5780633ccfd60b146102cb57806340c10f19146102e0576101d7565b80631ffb811f1161015e5780631ffb811f1461026b5780632ca166761461028b5780632f54bf6e146102ab576101d7565b806301ffc9a7146102155780630628a2c01461024b576101d7565b366101d75761018661042d565b73ffffffffffffffffffffffffffffffffffffffff167f8e47b87b0ef542cdfa1659c551d88bad38aa7f452d2bbb349ab7530dfec8be8f346040516101cd91815260200190565b60405180910390a2005b337fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd54146001811461020857600080fd5b600160805260206080f35b005b34801561022157600080fd5b5061023661023036600461129b565b50600090565b60405190151581526020015b60405180910390f35b34801561025757600080fd5b506102366102663660046112ff565b61048b565b34801561027757600080fd5b5061023661028636600461132b565b610583565b34801561029757600080fd5b506102366102a63660046113b5565b610677565b3480156102b757600080fd5b506102366102c6366004611428565b61076d565b3480156102d757600080fd5b506102136107cc565b3480156102ec57600080fd5b506102136102fb3660046112ff565b6108f1565b34801561030c57600080fd5b5061023661031b366004611445565b610bf6565b34801561032c57600080fd5b5061034061033b3660046114f9565b610ced565b6040517fffffffff000000000000000000000000000000000000000000000000000000009091168152602001610242565b34801561037d57600080fd5b5061039161038c3660046115e1565b610d3e565b6040516102429190611630565b3480156103aa57600080fd5b506103b3610e6e565b60405173ffffffffffffffffffffffffffffffffffffffff9091168152602001610242565b3480156103e457600080fd5b50610236610e9d565b3480156103f957600080fd5b5061023661040836600461132b565b610f01565b34801561041957600080fd5b506102366104283660046116a3565b610fef565b60007fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd543314600081146104845750507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe036013590565b3391505090565b60006104b57fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161461054e576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c7900000000000000000060448201526064015b60405180910390fd5b50600080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0016600190811790915592915050565b60006105ad7fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610641576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b50600080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660019081179091559392505050565b60006106a17fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610735576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b50600080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0016600190811790915595945050505050565b60006107977fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775490565b73ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16149050919050565b7fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775473ffffffffffffffffffffffffffffffffffffffff1661080c61042d565b73ffffffffffffffffffffffffffffffffffffffff1614610889576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601a60248201527f45524332303a206f776e6572206f6e6c792066756e6374696f6e0000000000006044820152606401610545565b7fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775460405173ffffffffffffffffffffffffffffffffffffffff909116904780156108fc02916000818181858888f193505050501580156108ee573d6000803e3d6000fd5b50565b7fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5473ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146109a7576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b7fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775473ffffffffffffffffffffffffffffffffffffffff166109e761042d565b73ffffffffffffffffffffffffffffffffffffffff1614610a64576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601a60248201527f45524332303a206f776e6572206f6e6c792066756e6374696f6e0000000000006044820152606401610545565b7fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd546040517f66bd3d4500000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff84811660048301526024820184905291909116906366bd3d4590604401600060405180830381600087803b158015610af857600080fd5b505af1158015610b0c573d6000803e3d6000fd5b5050505073ffffffffffffffffffffffffffffffffffffffff8216600090815260016020526040902054610bf25781814243610b496001826116c5565b60405160609590951b7fffffffffffffffffffffffffffffffffffffffff00000000000000000000000016602086015260348501939093526054840191909152607483015240609482015260b401604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0818403018152918152815160209283012073ffffffffffffffffffffffffffffffffffffffff8516600090815260019093529120555b5050565b6000610c207fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610cb4576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b50600080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660019081179091559695505050505050565b60008082806020019051810190610d049190611703565b9050610d2e817fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf77277755565b610d37836110f4565b9392505050565b6060610d687fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610dfc576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b600280547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0016905573ffffffffffffffffffffffffffffffffffffffff831660009081526001602090815260409182902054825191820152016040516020818303038152906040529050949350505050565b6000610e987fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775490565b905090565b6000610ec77fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775490565b73ffffffffffffffffffffffffffffffffffffffff16610ee561042d565b73ffffffffffffffffffffffffffffffffffffffff1614905090565b6000610f2b7fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff1614610fbf576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b50600080547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001681559392505050565b60006110197fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd5490565b73ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146110ad576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f45524332303a20686f6c6f67726170686572206f6e6c790000000000000000006044820152606401610545565b60006110bb83850185611720565b73ffffffffffffffffffffffffffffffffffffffff87166000908152600160208190526040909120919091559150509695505050505050565b600061111e7f4e5f991bca30eca2d4643aaefa807e88f96a4a97398933d572a3c0d973004a015490565b15611185576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601a60248201527f45524332303a20616c726561647920696e697469616c697a65640000000000006044820152606401610545565b337fe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd8190557fb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf7727775473ffffffffffffffffffffffffffffffffffffffff8116611249576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601860248201527f484f4c4f47524150483a206f776e6572206e6f742073657400000000000000006044820152606401610545565b61127260017f4e5f991bca30eca2d4643aaefa807e88f96a4a97398933d572a3c0d973004a0155565b507f4ddf47d4000000000000000000000000000000000000000000000000000000009392505050565b6000602082840312156112ad57600080fd5b81357fffffffff0000000000000000000000000000000000000000000000000000000081168114610d3757600080fd5b73ffffffffffffffffffffffffffffffffffffffff811681146108ee57600080fd5b6000806040838503121561131257600080fd5b823561131d816112dd565b946020939093013593505050565b60008060006060848603121561134057600080fd5b833561134b816112dd565b9250602084013561135b816112dd565b929592945050506040919091013590565b60008083601f84011261137e57600080fd5b50813567ffffffffffffffff81111561139657600080fd5b6020830191508360208285010111156113ae57600080fd5b9250929050565b6000806000806000608086880312156113cd57600080fd5b85356113d8816112dd565b945060208601356113e8816112dd565b935060408601359250606086013567ffffffffffffffff81111561140b57600080fd5b6114178882890161136c565b969995985093965092949392505050565b60006020828403121561143a57600080fd5b8135610d37816112dd565b60008060008060008060a0878903121561145e57600080fd5b8635611469816112dd565b95506020870135611479816112dd565b94506040870135611489816112dd565b935060608701359250608087013567ffffffffffffffff8111156114ac57600080fd5b6114b889828a0161136c565b979a9699509497509295939492505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b60006020828403121561150b57600080fd5b813567ffffffffffffffff8082111561152357600080fd5b818401915084601f83011261153757600080fd5b813581811115611549576115496114ca565b604051601f82017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0908116603f0116810190838211818310171561158f5761158f6114ca565b816040528281528760208487010111156115a857600080fd5b826020860160208301376000928101602001929092525095945050505050565b803563ffffffff811681146115dc57600080fd5b919050565b600080600080608085870312156115f757600080fd5b611600856115c8565b93506020850135611610816112dd565b92506040850135611620816112dd565b9396929550929360600135925050565b600060208083528351808285015260005b8181101561165d57858101830151858201604001528201611641565b8181111561166f576000604083870101525b50601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe016929092016040019392505050565b60008060008060008060a087890312156116bc57600080fd5b611469876115c8565b6000828210156116fe577f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b500390565b60006020828403121561171557600080fd5b8151610d37816112dd565b60006020828403121561173257600080fd5b503591905056fea164736f6c634300080d000a",
      initCode: "0x0000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001e53616d706c6520455243323020546f6b656e20286c6f63616c686f73742900000000000000000000000000000000000000000000000000000000000000000004534d504c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001253616d706c6520455243323020546f6b656e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000df5295149f367b1fbfd595bda578bad22e59f5040000000000000000000000000000000000000000000000000000000000000000"
    });

    bytes32 erc20ConfigHash = 0xa3a2316b8119471cb8f7f5d293ef00c9a2544864c2cc4ac7efaadfb71736b99e;
    bytes32 erc20ConfigHashBytes = 0xa3a2316b8119471cb8f7f5d293ef00c9a2544864c2cc4ac7efaadfb71736b99e;

    // Sign the ERC20 configuration
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHashBytes);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address addr = holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash);
    console.log("Address holographRegistryChain1:");
    console.logAddress(address(holographRegistryChain1));
    console.log("Address 1:");
    console.logAddress(addr);

    vm.selectFork(chain2);
    addr = holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash);
    console.log("Address holographRegistryChain2:");
    console.logAddress(address(holographRegistryChain2));
    console.log("Address 2:");
    console.logAddress(addr);

    assertEq(addr, address(0), "ERC20 contract not deployed on chain2");

    bytes32 data = keccak256(abi.encode(
            erc20Config,
            signature,
            deployer
        ));
      
    console.log("Data:");
    console.logBytes32(data);

    address originalMessagingModule = holographOperatorChain2.getMessagingModule();
    console.log("originalMessagingModule:");
    console.logAddress(originalMessagingModule);

    vm.prank(deployer);
    holographOperatorChain2.setMessagingModule(Constants.getMockLZEndpoint());

  }
}
