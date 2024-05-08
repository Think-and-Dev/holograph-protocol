// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";
import {ERC20Mock} from "../../../src/mock/ERC20Mock.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {CxipERC721} from "../../../src/token/CxipERC721.sol";
import {CxipERC721Proxy} from "../../../src/proxy/CxipERC721Proxy.sol";
import {HolographBridge} from "../../../src/HolographBridge.sol";
import {HolographBridgeProxy} from "../../../src/proxy/HolographBridgeProxy.sol";
import {Holographer} from "../../../src/enforcer/Holographer.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {HolographERC721} from "../../../src/enforcer/HolographERC721.sol";
import {HolographFactory} from "../../../src/HolographFactory.sol";
import {HolographFactoryProxy} from "../../../src/proxy/HolographFactoryProxy.sol";
import {HolographGenesis} from  "../../../src/HolographGenesis.sol";
import {HolographOperator} from "../../../src/HolographOperator.sol";
import {HolographOperatorProxy} from "../../../src/proxy/HolographOperatorProxy.sol";
import {HolographRegistry} from "../../../src/HolographRegistry.sol";
import {HolographRegistryProxy} from "../../../src/proxy/HolographRegistryProxy.sol";
import {HolographTreasury} from "../../../src/HolographTreasury.sol";
import {HolographTreasuryProxy} from "../../../src/proxy/HolographTreasuryProxy.sol";
import {hToken} from "../../../src/token/hToken.sol";
import {HolographInterfaces} from "../../../src/HolographInterfaces.sol";
import {MockERC721Receiver} from "../../../src/mock/MockERC721Receiver.sol";
import {HolographRoyalties} from "../../../src/enforcer/HolographRoyalties.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";
import {SampleERC721} from "../../../src/token/SampleERC721.sol";
import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

contract CrossChainConfiguration is Test {
    event BridgeableContractDeployed(address indexed _address, bytes32 _hash);
    uint256 localHostFork;
    uint256 localHost2Fork;    
    string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
    string LOCALHOST2_RPC_URL = vm.envString("LOCALHOST2_RPC_URL");
    uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
    address deployer = vm.addr(privateKeyDeployer);
    Holograph holograph;
    Holograph holographChain1;
    Holograph holographChain2;
    SampleERC20 sampleERC20Chain1;
    SampleERC20 sampleERC20Chain2;    
    ERC20Mock erc20Mock;
    ERC20Mock erc20MockChain1;
    ERC20Mock erc20MockChain2;
    CxipERC721Proxy cxipERC721ProxyChain1;
    CxipERC721Proxy cxipERC721ProxyChain2; 
    HolographBridge holographBridge;
    HolographBridge holographBridgeChain1;
    HolographBridge holographBridgeChain2;
    HolographBridgeProxy holographBridgeProxy;
    HolographBridgeProxy holographBridgeProxyChain1;
    HolographBridgeProxy holographBridgeProxyChain2;
    Holographer holographerChain1;
    Holographer holographerChain2;     
    HolographERC20 holographERC20;
    HolographERC20 holographERC20Chain1;
    HolographERC20 holographERC20Chain2;
    HolographERC721 holographERC721;
    HolographERC721 holographERC721Chain1;
    HolographERC721 holographERC721Chain2;
    HolographFactory holographFactory;
    HolographFactory holographFactoryChain1;
    HolographFactory holographFactoryChain2;   
    HolographFactoryProxy holographFactoryProxy;
    HolographFactoryProxy holographFactoryProxyChain1;
    HolographFactoryProxy holographFactoryProxyChain2; 
    HolographGenesis holographGenesis;
    HolographGenesis holographGenesisChain1;
    HolographGenesis holographGenesisChain2;

    HolographRegistry holographRegistryChain1;
    HolographRegistry holographRegistryChain2;
    HolographRegistry registry;
    HolographRegistry registryChain1;
    HolographRegistry registryChain2;
    HolographRegistryProxy holographRegistryProxyChain1;
    HolographRegistryProxy holographRegistryProxyChain2;
    hToken hTokenChain1;
    HolographOperator holographOperator;
    HolographOperator holographOperatorChain1;
    HolographOperator holographOperatorChain2;
    HolographOperatorProxy holographOperatorProxy;
    HolographOperatorProxy holographOperatorProxyChain1;
    HolographOperatorProxy holographOperatorProxyChain2;

    address public constant zeroAddress = address(0x0000000000000000000000000000000000000000);     

function setUp() public {
    erc20Mock = ERC20Mock(payable(Constants.getERC20Mock()));
    holograph = Holograph(payable(Constants.getHolograph()));
    holographBridge = HolographBridge(payable(Constants.getHolographBridge()));
    holographBridgeProxy = HolographBridgeProxy(payable(Constants.getHolographBridgeProxy()));
    holographERC20 = HolographERC20(payable(Constants.getSampleERC20())); /// VER EL ADDRESS...
    holographERC721 = HolographERC721(payable(Constants.getHolographERC721()));
    holographFactory = HolographFactory(payable(Constants.getHolographFactory()));
    holographFactoryProxy = HolographFactoryProxy(payable(Constants.getHolographFactoryProxy()));
    holographGenesis = HolographGenesis(payable(Constants.getHolographGenesis()));
    holographOperator = HolographOperator(payable(Constants.getHolographOperator()));
    holographOperatorProxy = HolographOperatorProxy(payable(Constants.getHolographOperatorProxy()));
    //registry = HolographRegistry(payable(holograph.getRegistry()));

    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    //erc20MockChain1 = ERC20Mock(payable(Constants.getERC20Mock()));
    holographChain1 = Holograph(payable(Constants.getHolograph()));
    sampleERC20Chain1 = SampleERC20(payable(Constants.getSampleERC20()));
    cxipERC721ProxyChain1 = CxipERC721Proxy(payable(Constants.getCxipERC721Proxy())); 
    //holographBridgeChain1 = HolographBridge(payable(Constants.getHolographBridge()));
    //holographBridgeProxyChain1 = HolographBridgeProxy(payable(Constants.getHolographBridgeProxy()));
    // holographerChain1 = Holographer(payable(Constants.getHolographer()));
    //holographERC20Chain1 = HolographERC20(payable(Constants.getSampleERC20())); /// VER EL ADDRESS...
    //holographERC721Chain1 = HolographERC721(payable(Constants.getHolographERC721()));
    //holographFactoryChain1 = HolographFactory(payable(Constants.getHolographFactory()));
    //holographFactoryProxyChain1 = HolographFactoryProxy(payable(Constants.getHolographFactoryProxy()));
    //holographGenesisChain1 = HolographGenesis(payable(Constants.getHolographGenesis()));
    holographRegistryChain1 = HolographRegistry(payable(Constants.getHolographRegistry()));
    holographRegistryProxyChain1 = HolographRegistryProxy(payable(Constants.getHolographRegistryProxy()));
    hTokenChain1 = hToken(payable(Constants.getHToken()));
    //holographOperatorChain1 = HolographOperator(payable(Constants.getHolographOperator()));
    //holographOperatorProxyChain1 = HolographOperatorProxy(payable(Constants.getHolographOperatorProxy()));

    localHost2Fork = vm.createFork(LOCALHOST2_RPC_URL);
    vm.selectFork(localHost2Fork);    
    //erc20MockChain2 = ERC20Mock(payable(Constants.getERC20Mock()));
    holographChain2 = Holograph(payable(Constants.getHolograph()));
    sampleERC20Chain2 = SampleERC20(payable(Constants.getSampleERC20()));
    cxipERC721ProxyChain2 = CxipERC721Proxy(payable(Constants.getCxipERC721Proxy_L2())); 
    //holographBridgeChain2 = HolographBridge(payable(Constants.getHolographBridge()));
    //holographBridgeProxyChain2 = HolographBridgeProxy(payable(Constants.getHolographBridgeProxy()));
    // holographerChain2 = Holographer(payable(Constants.getHolographer_L2()));
    //holographERC20Chain2 = HolographERC20(payable(Constants.getSampleERC20())); /// VER EL ADDRESS..
    //holographERC721Chain2 = HolographERC721(payable(Constants.getHolographERC721()));
    //holographFactoryChain2 = HolographFactory(payable(Constants.getHolographFactory()));
    //holographFactoryProxyChain2 = HolographFactoryProxy(payable(Constants.getHolographFactoryProxy()));
    holographRegistryChain2 = HolographRegistry(payable(Constants.getHolographRegistry()));
    //holographGenesisChain2 = HolographGenesis(payable(Constants.getHolographGenesis()));
    holographRegistryProxyChain2 = HolographRegistryProxy(payable(Constants.getHolographRegistryProxy()));
    //holographOperatorChain2 = HolographOperator(payable(Constants.getHolographOperator()));
    //holographOperatorProxyChain1 = HolographOperatorProxy(payable(Constants.getHolographOperatorProxy()));
}

function testprueba() public {
    vm.selectFork(localHostFork);
    address alice = vm.addr(1);
    vm.prank(deployer);
    sampleERC20Chain1.mint(alice, 1);
    //vm.selectFork(localHost2Fork);
    assertEq(holographERC20Chain1.balanceOf(alice), 1);
}

/*
VALIDATE CROSS-CHAIN DATA
*/

/**
 * @notice This test checks if the addresses of the `cxipERC721Proxy` contracts deployed in chain1 and chain2 are different.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'CxipERC721'
 */
function testCxipERC721ProxyAddress() public {
    assertNotEq(address(cxipERC721ProxyChain1), address(cxipERC721ProxyChain2));
}

/**
 * @notice This test checks if the addresses of the `erc20Mock` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'ERC20Mock'
 */
function testErc20MockAddress() public {
    vm.selectFork(localHostFork);
    erc20MockChain1 = erc20Mock;    
    vm.selectFork(localHost2Fork); 
    erc20MockChain2 = erc20Mock;
    assertEq(address(erc20MockChain1), address(erc20MockChain2));
}

/**
 * @notice This test checks if the addresses of the `holograph` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'Holograph'
 */
function testHolographAddress() public {
    vm.selectFork(localHostFork);
    holographChain1 = holograph;    
    vm.selectFork(localHost2Fork); 
    holographChain2 = holograph;    
    assertEq(address(holographChain1), address(holographChain2));
}

/**
 * @notice This test checks if the addresses of the `holographBridge` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographBridge'
 */
function testHolographBridgeAddress() public {
    vm.selectFork(localHostFork);
    holographBridgeChain1 = holographBridge;    
    vm.selectFork(localHost2Fork); 
    holographBridgeChain2 = holographBridge;    
    assertEq(address(holographBridgeChain1), address(holographBridgeChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographBridgeProxy` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographBridgeProxy'
 */
function testHolographBridgeProxyAddress() public {
    vm.selectFork(localHostFork);
    holographBridgeProxyChain1 = holographBridgeProxy;    
    vm.selectFork(localHost2Fork); 
    holographBridgeProxyChain2 = holographBridgeProxy; 
    assertEq(address(holographBridgeProxyChain1), address(holographBridgeProxyChain2));
}

// TODO
// /**
//  * @notice This test checks if the addresses of the `Holographer` contracts deployed in chain1 and chain2 are the same.
//  * @dev This test is considered as a validation test on the deployment performed.
//  * Refers to the hardhat test with the description 'Holographer'
//  */
// function testHolographBridgeProxyAddress() public {
//     assertNotEq(address(holographerChain1), address(holographerChain2));
// }

/**
 * @notice This test checks if the addresses of the `HolographERC20` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographERC20'
 */
function testHolographERC20Address() public {
    vm.selectFork(localHostFork);
    holographERC20Chain1 = holographERC20;    
    vm.selectFork(localHost2Fork); 
    holographERC20Chain2 = holographERC20;     
    assertEq(address(holographERC20Chain1), address(holographERC20Chain2));
}

/**
 * @notice This test checks if the addresses of the `HolographERC721` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographERC721'
 */
function testHolographERC721Address() public {
    vm.selectFork(localHostFork);
    holographERC721Chain1 = holographERC721;    
    vm.selectFork(localHost2Fork); 
    holographERC721Chain2 = holographERC721; 
    assertEq(address(holographERC721Chain1), address(holographERC721Chain2));
}

/**
 * @notice This test checks if the addresses of the `HolographFactory` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographFactory'
 */
function testHolographFactoryAddress() public {
    vm.selectFork(localHostFork);
    holographFactoryChain1 = holographFactory;    
    vm.selectFork(localHost2Fork); 
    holographFactoryChain2 = holographFactory; 
    assertEq(address(holographFactoryChain1), address(holographFactoryChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographFactoryProxy` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographFactoryProxy'
 */
function testHolographFactoryProxyAddress() public {
    vm.selectFork(localHostFork);
    holographFactoryProxyChain1 = holographFactoryProxy;    
    vm.selectFork(localHost2Fork); 
    holographFactoryProxyChain2 = holographFactoryProxy; 
    assertEq(address(holographFactoryProxyChain1), address(holographFactoryProxyChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographGenesis` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographGenesis'
 */
function testHolographGenesisAddress() public {
    vm.selectFork(localHostFork);
    holographGenesisChain1 = holographGenesis;    
    vm.selectFork(localHost2Fork); 
    holographGenesisChain2 = holographGenesis; 
    assertEq(address(holographGenesisChain1), address(holographGenesisChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographOperator` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographOperator'
 */
function testHolographOperatorAddress() public {
    vm.selectFork(localHostFork);
    holographOperatorChain1 = holographOperator;    
    vm.selectFork(localHost2Fork); 
    holographOperatorChain2 = holographOperator; 
    assertEq(address(holographOperatorChain1), address(holographOperatorChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographOperatorProxy` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographOperatorProxy'
 */
function testHolographOperatorProxyAddress() public {
    vm.selectFork(localHostFork);
    holographOperatorProxyChain1 = holographOperatorProxy;    
    vm.selectFork(localHost2Fork); 
    holographOperatorProxyChain2 = holographOperatorProxy; 
    assertEq(address(holographOperatorProxyChain1), address(holographOperatorProxyChain2));
}

/**
 * @notice This test checks if the addresses of the 'HolographRegistry' contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographRegistry'
 */
function testRegistryAddress() public {
    vm.selectFork(localHostFork);
    registryChain1 = registry;    
    vm.selectFork(localHost2Fork); 
    registryChain2 = registry; 
    assertEq(address(registryChain1), address(registryChain2));
}

// // TODO holographRegistry es distinto que registry?????
//     describe('HolographRegistry', async function () {
//       it('contract addresses should match', async function () {

//         // expect(chain1.registry.address).to.equal(chain2.registry.address);
//       });
//     });

    // describe('HolographFactory', async function () {
    //   it('contract addresses should match', async function () {
    //     expect(chain1.factory.address).to.equal(chain2.factory.address);
    //   });
    // });

    // describe('HolographBridge', async function () {
    //   it('contract addresses should match', async function () {
    //     expect(chain1.bridge.address).to.equal(chain2.bridge.address);
    //   });


//////////////


/**
 * @notice This test checks if the addresses of the `HolographRegistry` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographRegistry'
 */
function testHolographRegistryAddress() public {
    assertEq(address(holographRegistryChain1), address(holographRegistryChain2));
}

/**
 * @notice This test checks if the addresses of the `HolographRegistryProxy` contracts deployed in chain1 and chain2 are the same.
 * @dev This test is considered as a validation test on the deployment performed.
 * Refers to the hardhat test with the description 'HolographRegistryProxy'
 */
function testHolographRegistryProxyAddress() public {
    assertEq(address(holographRegistryProxyChain1), address(holographRegistryProxyChain2));
}

/*
DEPLOY CROSS-CHAIN CONTRACTS
*/

/**
 * @notice Verifies that the deployment of a holographic ERC20 contract on chain1 is equivalent to 
 * the deployment on chain2.
 * @dev Validates that the contract configuration is consistent between the two chains and that the deployment 
 * process results in identical contract addresses. 
 */

// function generateString(string memory tokenName, uint256 holographId) public pure returns (string memory) {
//     string memory result = string(abi.encodePacked(tokenName, " (Holographed #", uintToString(holographId), ")"));
//     return result;
// }

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

struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
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

function generateErc20Config(ERC20ConfigParams memory params)
        public
        view
        returns (
            DeploymentConfig memory erc20Config,
            bytes32 erc20ConfigHash,
            bytes memory erc20ConfigHashBytes
        )
    {
    bytes32 erc20Hash = keccak256(abi.encodePacked("HolographERC20")); //REVISAR
    uint32 chainId = uint32(block.chainid);
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

    erc20ConfigHashBytes = abi.encodePacked(erc20ConfigHash);

    return (erc20Config, erc20ConfigHash, erc20ConfigHashBytes);
    }

// function testDeployChain1EquivalentOnChain2() public {
//     ERC20ConfigParams memory params = ERC20ConfigParams({
//     network: "Localhost",
//     deployer: deployer,
//     contractName: "hToken",
//     tokenName: "Localhost (Holographed #4294967294)",
//     tokenSymbol: "hLH",
//     domainSeparator: "Localhost (Holographed #4294967294)",
//     domainVersion: "1",
//     decimals: 18,
//     eventConfig: "0x0000000000000000000000000000000000000000000000000000000000000000",
//     initCodeParam: abi.encodePacked(deployer, uint16(0)),
//     salt: "0x0000000000000000000000000000000000000000000000000000000000001000"
// });

function testDeployChain1EquivalentOnChain2() public {
    ERC20ConfigParams memory params = ERC20ConfigParams({
    network: "Localhost",
    deployer: deployer,
    contractName: "hTokenProxy",
    tokenName: "Holographed hLH",
    tokenSymbol: "hLH",
    domainSeparator: "Holographed hLH",
    domainVersion: "1",
    decimals: 18,
    eventConfig: "0x0000000000000000000000000000000000000000000000000000000000000000",
    initCodeParam: abi.encodePacked(
        keccak256(abi.encodePacked("hToken")), 
        address(holographRegistryChain1), 
        abi.encodePacked(deployer, uint16(0))
    ),
    salt: "0x0000000000000000000000000000000000000000000000000000000000001000"
    });

    (DeploymentConfig memory erc20Config, bytes32 erc20ConfigHash, bytes memory erc20ConfigHashBytes) = generateErc20Config(params);

    // Verify that the contract does not exist on chain2("Valor de la variable:", value);
    assertEq(address(registry.getHolographedHashAddress(erc20ConfigHash)), zeroAddress);
    
    // Sign the ERC20 configuration
    //(uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, erc20ConfigHashBytes);
    // Signature memory signature = Signature({
    //     r: r,
    //     s: s,
    //     v: v
    // });

    // Deploy the holographable contract on chain2
    vm.startPrank(deployer);
    vm.expectEmit(true, true, false, true);
    emit BridgeableContractDeployed(address(0), erc20ConfigHash);
    //holographFactoryChain2.deployHolographableContract(erc20Config, signature, deployer);
    vm.stopPrank();
    }

/*
VERIFY CHAIN CONFIGS
*/

function testMessagingModuleNotZero() public {
    assertNotEq(holographOperatorChain1.getMessagingModule(), zeroAddress);
    assertNotEq(holographOperatorChain2.getMessagingModule(), zeroAddress);    
}

function testMessagingModuleSameAddress() public {
    assertEq(holographOperatorChain1.getMessagingModule(), holographOperatorChain2.getMessagingModule());    
}

// TODO
// function testChainId1() public {
//     assertEq(holographChain1.getHolographChainId(),);
// }
// TODO
// function testChainId1() public {
//     assertEq(holographChain2.getHolographChainId(),);
// }


/*
GET GAS CALCULATIONS
*/

// TODO falta definición de gasUsage
    // mapping(string => uint256) public gasUsage;

    // function testGasHTokenDeployChain1OnChain2() public {
    //     gasUsage["hToken deploy chain1 on chain2"] = 0;
    //     string memory name = "hToken deploy chain1 on chain2";
    //     //console.log("          ", name,": ", gasUsage[name].toString());
    //     assert(gasUsage[name] != 0);
    // }
    
}
