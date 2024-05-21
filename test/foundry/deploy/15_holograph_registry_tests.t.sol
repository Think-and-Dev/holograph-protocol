// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {Holographer} from "../../../src/enforcer/Holographer.sol";
import {HolographRegistry} from "../../../src/HolographRegistry.sol";
import {MockExternalCall} from "../../../src/mock/MockExternalCall.sol";
import {HolographERC721} from "../../../src/enforcer/HolographERC721.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {DeploymentConfig} from "../../../src/struct/DeploymentConfig.sol";

contract HolographRegistryTests is Test {
    uint256 localHostFork;  
    string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
    Holograph holograph;
    HolographRegistry holographRegistry;
    HolographRegistry registry;
    MockExternalCall mockExternalCall;
    HolographERC721 holographERC721;
    HolographERC20 holographERC20;
    Holographer sampleErc721Holographer;

    uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
    address deployer = vm.addr(privateKeyDeployer);
    address public constant zeroAddress = address(0x0000000000000000000000000000000000000000); 
    address origin = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;  //default address origin in foundry       
    address mockAddress = 0xeB721f3E4C45a41fBdF701c8143E52665e67c76b;
    address utilityTokenAddress = 0x4b02422DC46bb21D657A701D02794cD3Caeb17d0;
    

    function randomAddress() public view returns (address) {
        uint256 randomNum = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        return address(uint160(randomNum));
    }

    function getContractType(string memory contractName) public returns (bytes32) {
        bytes32 contractType = keccak256(abi.encodePacked(contractName));
        return contractType;
    }

    function setUp() public {
        vm.startPrank(deployer);
        holographRegistry = new HolographRegistry();
        mockExternalCall = new MockExternalCall();
        vm.stopPrank();

        localHostFork = vm.createFork(LOCALHOST_RPC_URL);
        vm.selectFork(localHostFork);
        holograph = Holograph(payable(Constants.getHolograph()));
        registry = HolographRegistry(payable(holograph.getRegistry()));
        holographERC721 = HolographERC721(payable(Constants.getHolographERC721()));
        holographERC20 = HolographERC20(payable(Constants.getHolographERC20()));
        sampleErc721Holographer = Holographer(payable(Constants.getSampleERC721()));
    }

/*
    CONSTRUCTOR
*/
    function testSuccessfullyDeploy() public {
        assertNotEq(address(holographRegistry), zeroAddress);
    }

/*
    INIT()
*/
    function testSuccessfullyInitializedOnce() public {
        bytes32[] memory emptyBytes32Array;
        bytes memory initCode = abi.encode(deployer, emptyBytes32Array);
        vm.prank(deployer);
        holographRegistry.init(initCode);
    }

    function testInitializedTwiceFail() public {
        bytes32[] memory emptyBytes32Array;
        bytes memory initCode = abi.encode(deployer, emptyBytes32Array);
        vm.prank(deployer);
        holographRegistry.init(initCode);
        vm.expectRevert('HOLOGRAPH: already initialized');
        vm.prank(deployer);
        holographRegistry.init(initCode);
    }

/*
    setHolographedHashAddress
*/

    function testSetHolographedHashAddressNoFactoryRevert() public {
        bytes32 contractHash = getContractType('HolographERC721');
        vm.expectRevert('HOLOGRAPH: factory only function');
        vm.prank(deployer);
        registry.setHolographedHashAddress(contractHash, address(holographERC721));
    }

/*
    getHolographableContracts
*/

    // struct ERC721ConfigParams {
    //     string network;
    //     address deployer;
    //     string contractName;
    //     string collectionName;
    //     string collectionSymbol;
    //     uint royaltyBps;
    //     bytes eventConfig;
    //     bytes initCodeParam;
    //     string salt;
    // }

    // function encodeInitParams(
    //     string memory collectionName,
    //     string memory collectionSymbol,
    //     uint royaltyBps,
    //     bytes memory eventConfig,
    //     bool skipInit,
    //     bytes memory initCodeParam
    // ) public pure returns (bytes memory) {
    //     return abi.encode(
    //         collectionName, collectionSymbol, eventConfig, royaltyBps, skipInit, initCodeParam
    //     );
    // }

    // function generateErc721Config(ERC721ConfigParams memory params)
    //     public view returns (
    //         DeploymentConfig memory erc721Config,
    //         bytes32 erc721ConfigHash,
    //         bytes32 erc721ConfigHashBytes
    //         )
    //         {
    //         bytes32 erc721Hash = keccak256(abi.encodePacked("HolographERC721"));
    //         uint32 chainId = uint32(block.chainid); 
    //         bytes memory byteCode = vm.getCode(params.contractName);
    //         bytes memory initCode = encodeInitParams(
    //             params.collectionName,
    //             params.collectionSymbol,
    //             params.royaltyBps,
    //             params.eventConfig,
    //             false,
    //             params.initCodeParam
    //         );
    //         erc721Config = DeploymentConfig({
    //             contractType: erc721Hash,
    //             chainType: chainId,
    //             salt: bytes32(bytes(params.salt)),
    //             byteCode: byteCode,
    //             initCode: initCode        
    //         });
    //         erc721ConfigHash = keccak256(
    //             abi.encodePacked(
    //                 erc721Config.contractType,
    //                 keccak256(abi.encodePacked(erc721Config.chainType)),
    //                 keccak256(abi.encodePacked(erc721Config.salt)),
    //                 keccak256(erc721Config.byteCode),
    //                 keccak256(erc721Config.initCode),
    //                 bytes20(params.deployer)
    //                 )
    //         );
    //         bytes memory data = abi.encodePacked(erc721ConfigHash);
    //         erc721ConfigHashBytes = keccak256(data);
    //         return (erc721Config, erc721ConfigHash, erc721ConfigHashBytes);
    //         }

    function testReturnValidHolographableContract() public {
        uint16 expectedHolographableContractsCount = 5;
        address[] memory contracts = registry.getHolographableContracts(0, expectedHolographableContractsCount);
        assertEq(contracts.length, expectedHolographableContractsCount);

    //     ERC721ConfigParams memory params = ERC721ConfigParams({
    //         network: "Localhost",
    //         deployer: deployer,
    //         contractName: "SampleERC721",
    //         collectionName: "Sample ERC721 Contract (Localhost)",
    //         collectionSymbol: "SMPLR",
    //         royaltyBps: 1000,
    //         eventConfig: '0x0000000000000000000000000000000000000000000000000000000000000087',
    //         initCode: abi.encode(deployer),
    //         salt: "0x0000000000000000000000000000000000000000000000000000000000001000"
    //         });

    // (DeploymentConfig memory erc721Config, bytes32 erc721ConfigHash, bytes32 erc721ConfigHashBytes) = generateErc721Config(params);

        bool found = false;
        for (uint i = 0; i < contracts.length; i++) {
            if (contracts[i] == address(sampleErc721Holographer)) {
                found = true;
                break;
            }
        }
        assertTrue(found, "Expected contract address not found");
    }

    function testAllowExternalContractToCallGetHolographableContracts() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographableContracts(uint256,uint256)', 0 , 1);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
        
    }

/*
    getHolographableContractsLength
*/
    
    function testReturnValid_holographableContractsLength() public {
        uint16 expectedHolographableContractsCount = 5;
        uint256 length = registry.getHolographableContractsLength();
        assertEq(length, expectedHolographableContractsCount);
    }

    function testAllowExternalContractToCallGetHolographableContractsLength() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographableContractsLength()');
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }

/*
    isHolographedContract
*/

    function testReturnTrueIfSmartContractIsValid() public {
        bool isHolographed = registry.isHolographedContract(address(sampleErc721Holographer));
        assertTrue(isHolographed);
    }

    function testReturnFalseIfSmartContractIsInvalid() public {
        vm.prank(deployer);
        bool isHolographed = registry.isHolographedContract(address(mockAddress));
        assertFalse(isHolographed);
    }

    function testAllowExternalContractToCalIsHolographableContract() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('isHolographedContract(address)', mockAddress);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }

/*
    isHolographedHashDeployed
*/

    function testReturnTrueIfHashIsValid() public {
        vm.skip(true);
        //bool isHolographed = registry.isHolographedContract(sampleErc721Hash);
        //assertTrue(isHolographed);
    }    

    function testReturnFalseIfHashIsInvalid() public {
        bytes32 contractHash = getContractType('HolographERC721');
        bool isHolographed = registry.isHolographedHashDeployed(contractHash);
        assertFalse(isHolographed);
    }    

    function testAllowExternalContractToCal_isHolographableHashDeployed() public {
        vm.skip(true);
        //bytes memory  encodeSignature = abi.encodeWithSignature('isHolographedHashDeployed(bytes32)', ampleERC721Hash);
        //mockExternalCall.callExternalFn(address(registry), encodeSignature);        
    }    

/*
    getHolographedHashAddress
*/

    function testReturnValid_holographedContractsHashMap() public {
        //address add = registry.getHolographedHashAddress(sampleErc721Hash);
        //assertEq(add, address(sampleErc721Holographer));
    }    

    function testReturn0x0ForInvalidHash() public {
        bytes32 contractHash = getContractType('HolographERC721');
        address add = registry.getHolographedHashAddress(contractHash);
        assertEq(add, zeroAddress);
    }    

    function testAllowExternalContractToCalGetHolographedHashAddress() public {
        //bytes memory  encodeSignature = abi.encodeWithSignature('getHolographedHashAddress(bytes32)', sampleERC721Hash);
        //mockExternalCall.callExternalFn(address(registry), encodeSignature);         
    }

/*
    setReservedContractTypeAddress
*/

    function testAllowAdminToSetContractTypeAddress() public {
        bytes32 contractTypeHash = getContractType('HolographERC721');
        vm.prank(deployer);
        registry.setReservedContractTypeAddress(contractTypeHash, true);
    }

    function testAllowRandUserToAlterContractTypeAddressRevert() public {
        bytes32 contractTypeHash = getContractType('HolographERC721');
        address randUser = randomAddress();
        vm.expectRevert();
        vm.prank(randUser);
        registry.setReservedContractTypeAddress(contractTypeHash, true);
    }

/*
    getReservedContractTypeAddress
*/

    function testReturnExpectedContractTypeAddress() public {
        bytes32 contractTypeHash = getContractType('HolographERC721');
        address contractAddress = address(holographERC721);  
        vm.startPrank(deployer);
        registry.setReservedContractTypeAddress(contractTypeHash, true);
        registry.setContractTypeAddress(contractTypeHash,contractAddress);
        vm.stopPrank();
        address contractAddressR = registry.getReservedContractTypeAddress(contractTypeHash);
        assertEq(contractAddressR, address(holographERC721));
    }

/*
    setContractTypeAddress
*/

    function testAllowAdminToAlterSetContractTypeAddress() public {
        // TODO It is not a unit test
        bytes32 contractTypeHash = getContractType('HolographERC721');
        address contractAddress = randomAddress();
        vm.startPrank(deployer);
        registry.setReservedContractTypeAddress(contractTypeHash, true);
        registry.setContractTypeAddress(contractTypeHash,contractAddress);
        assertEq(registry.getReservedContractTypeAddress(contractTypeHash), contractAddress);
        vm.stopPrank();
    }

    function testAllowRandUserToAlterSetContractTypeAddressRevert() public {
        // TODO It is not a unit test
        bytes32 contractTypeHash = getContractType('HolographERC721');
        address contractAddress = randomAddress();
        vm.prank(deployer); 
        registry.setReservedContractTypeAddress(contractTypeHash,true);
        vm.prank(randomAddress());      
        vm.expectRevert(); 
        registry.setContractTypeAddress(contractTypeHash,contractAddress);
        assertNotEq(registry.getReservedContractTypeAddress(contractTypeHash), contractAddress);
    }

/*
    getContractTypeAddress
*/
    function testReturnValid_contractTypeAddresses() public {
        bytes32 contractTypeHash = getContractType('HolographERC721');
        address contractAddress = randomAddress();
        vm.prank(deployer); 
        registry.setReservedContractTypeAddress(contractTypeHash,true);
        vm.prank(deployer); 
        registry.setContractTypeAddress(contractTypeHash, contractAddress);
        assertEq(registry.getContractTypeAddress(contractTypeHash), contractAddress);
    }

    function testAllowExternalContractToCallFn_getContractTypeAddress() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getContractTypeAddress(bytes32)', getContractType('HolographERC721'));
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }  

/*
    referenceContractTypeAddress
*/

    function testReturnValidAddress() public {
        registry.referenceContractTypeAddress(address(holographERC20));
    }

    function testIfContractIsEmptyRevert() public {
        address contractAddress = randomAddress();
        vm.expectRevert('HOLOGRAPH: empty contract');
        registry.referenceContractTypeAddress(contractAddress);        
    }

    function testIfContractIsAlreadySetRevert() public {
        registry.referenceContractTypeAddress(address(holographERC20));          
        vm.expectRevert('HOLOGRAPH: contract already set');
        registry.referenceContractTypeAddress(address(holographERC20));          
    }

    function testAllowExternalContractToCallFnReferenceContractTypeAddress() public {
        bytes memory encodeSignature = abi.encodeWithSignature('referenceContractTypeAddress(address)', address(holographERC20));
        mockExternalCall.callExternalFn(address(registry), encodeSignature);        
    }

/*
    setHolograph()
*/   

    function testAllowAdminToAlter_holographSlot() public {
        // TODO Check which is the admin adddres
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setHolograph(address(mockAddress));
        assertEq(holographRegistry.getHolograph(), mockAddress);
        vm.stopPrank();
    }

    function testAllowOwnerToAlter_holographSlotFail() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHolograph(address(mockAddress));
    }

    function testAllowRandUserToAlter_holographSlotFail() public {
        vm.prank(randomAddress());
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHolograph(address(mockAddress));
    }

/*
    getHolograph()
*/

    function testReturnValid_holographSlot() public {
        // TODO: This test is not necessary. 
        // To make it work I have to use setHolograph() and it works 
        // identically to testAllowAdminToAlter_holographSlot().
        vm.skip(true);
        assertEq(holographRegistry.getHolograph(), mockAddress);
    }

    function testAllowExternalContractToCallFnGetHolograph() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolograph()');
        mockExternalCall.callExternalFn(address(registry), encodeSignature);           
    }

/*
    setHToken()
*/

    function testAllowAdminToAlter_hTokens() public {
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setHToken(validChainId, hTokenAddress);
        assertEq(holographRegistry.getHToken(validChainId), hTokenAddress);
        vm.stopPrank();
    }

    function testAllowOwnerToAlter_hTokensReturn() public {
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHToken(validChainId, hTokenAddress);
    }

    function testAllowNonOwnerToAlter_hTokensReturn() public {
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.prank(randomAddress());
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHToken(validChainId, hTokenAddress);
    }

/*
    getHToken()
*/

    function testReturnValid_hTokens() public {
        testAllowAdminToAlter_hTokens();
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.prank(deployer);
        address hTokenAddr = holographRegistry.getHToken(validChainId);
        assertEq(hTokenAddr, hTokenAddress);    
    }

    function testReturn0x0ForInvalidChainId() public {
        uint32 invalidChainId = 0;
        assertEq(holographRegistry.getHToken(invalidChainId), zeroAddress);
    }

    function testAllowExternalContractToCallFnGetHToken() public {
        uint32 validChainId = 5;
        bytes memory encodeSignature = abi.encodeWithSignature('getHToken(uint32)', validChainId);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);          
    }

/*
    setUtilityToken()
*/

    function testAllowAdminToAlter_utilityTokenSlot() public {
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setUtilityToken(utilityTokenAddress);
        assertEq(holographRegistry.getUtilityToken(), utilityTokenAddress);
        vm.stopPrank();
    }

    function testAllowOwnerToAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setUtilityToken(utilityTokenAddress);
    }

    function testAllowRandUserToAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(randomAddress());
        holographRegistry.setUtilityToken(utilityTokenAddress);
    }

    function testGetUtilityToken() public {
        // TODO: This test is not necessary. 
        // To make it work I have to use setUtilityToken() and it works 
        // identically to testAllowAdminToAlter_utilityTokenSlot()
        vm.skip(true);
        vm.prank(holographRegistry.getAdmin());
        assertEq(holographRegistry.getUtilityToken(), utilityTokenAddress);
    }
}