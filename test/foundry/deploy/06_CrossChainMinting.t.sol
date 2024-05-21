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

  Holograph holographChain1;
  Holograph holographChain2;
  HolographOperator holographOperatorChain1;
  HolographOperator holographOperatorChain2;
  Holographer utilityTokenHolographerChain1;
  Holographer utilityTokenHolographerChain2;
  
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
    holographRegistryChain1 = HolographRegistry(payable(Constants.getHolographRegistry()));

    vm.selectFork(chain2);
    holographChain2 = Holograph(payable(Constants.getHolograph()));
    holographOperatorChain2 = HolographOperator(payable(Constants.getHolographOperatorProxy()));
    holographRegistryChain2 = HolographRegistry(payable(Constants.getHolographRegistry()));

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

    bytes memory initCodeParam = abi.encodePacked(
        keccak256(abi.encodePacked("SampleERC20")),
        address(Constants.getHolographRegistry()),
        abi.encodePacked(deployer, uint16(0))
      );
    console.log("InitCodeParam:");
    console.logBytes(initCodeParam);

    ERC20ConfigParams memory params = ERC20ConfigParams({
      network: "localhost",
      deployer: deployer,
      contractName: "SampleERC20",
      tokenName: "Sample ERC20 Token (localhost)",
      tokenSymbol: "SMPL",
      domainSeparator: "Sample ERC20 Token",
      domainVersion: "1",
      decimals: 18,
      eventConfig: "0x0000000000000000000000000000000000000000000000000000000000000006",
      initCodeParam: "0x000000000000000000000000df5295149f367b1fbfd595bda578bad22e59f5040000000000000000000000000000000000000000000000000000000000000000",
      salt: "0x00000000000000000000000000000000000000000000000000000000000003e8"
    });

    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash, bytes32 erc20ConfigHashBytes) = generateErc20Config(
      params
    );

    console.log("ERC20 Configuration:");
    console.logBytes32(erc20ConfigHash);
    console.logBytes32(erc20ConfigHashBytes);

    // Sign the ERC20 configuration
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHashBytes);
    Verification memory signature = Verification({r: r, s: s, v: v});

    vm.selectFork(chain1);
    address addr = holographRegistryChain1.getHolographedHashAddress(erc20ConfigHash);
    console.log("Address 1:");
    console.logAddress(addr);

    vm.selectFork(chain2);
    addr = holographRegistryChain2.getHolographedHashAddress(erc20ConfigHash);
    console.log("Address 2:");
    console.logAddress(addr);
  }
}
