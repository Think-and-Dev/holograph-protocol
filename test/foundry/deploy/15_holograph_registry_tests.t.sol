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

/**
 * @notice Test the successful deployment of the HolographRegistry contract.
 * @dev This test verifies that the address of the deployed HolographRegistry contract is not equal to the zero address.
 * Refers to the hardhat test with the description 'should successfully deploy'
 */
    function testSuccessfullyDeploy() public {
        assertNotEq(address(holographRegistry), zeroAddress);
    }

/*
    INIT()
*/

/**
 * @notice Test the successful initialization of the HolographRegistry contract once.
 * @dev This test initializes the HolographRegistry contract with the provided deployment address and an empty bytes32 array.
 * It then performs a prank operation on the deployer address and calls the init function of the contract.
 * Refers to the hardhat test with the description 'should successfully be initialized once'
 */
    function testSuccessfullyInitializedOnce() public {
        bytes32[] memory emptyBytes32Array;
        bytes memory initCode = abi.encode(deployer, emptyBytes32Array);
        vm.prank(deployer);
        holographRegistry.init(initCode);
    }

/**
 * @notice Test the failure of initializing the HolographRegistry contract twice.
 * @dev This test attempts to initialize the HolographRegistry contract twice with the same initialization code.
 * The first initialization is successful, and the second initialization is expected to revert with the message 'HOLOGRAPH: already initialized'.
 * Refers to the hardhat test with the description 'should fail be initialized twice'
 */
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

/**
 * @notice Test the revert behavior when trying to set a holographed hash address without a factory.
 * @dev This test attempts to set a holographed hash address for the 'HolographERC721' contract type using the deployer address.
 * It expects a revert with the message 'HOLOGRAPH: factory only function' when calling the setHolographedHashAddress function.
 * Refers to the hardhat test with the description 'Should return fail to add contract because it does not have a factory'
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

/**
 * @notice Test the return of valid holographable contracts from the registry.
 * @dev This test verifies that the registry returns a list of valid holographable contracts.
 * It checks that the length of the returned list matches the expected count and that the list includes a specific contract address.
 * Refers to the hardhat test with the description 'Should return valid contracts'
 */
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

/**
 * @notice Test allowing an external contract to call the getHolographableContracts function.
 * @dev This test verifies that an external contract can successfully call the getHolographableContracts function
 * of the registry contract with the parameters 0 and 1.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallGetHolographableContracts() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographableContracts(uint256,uint256)', 0 , 1);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
        
    }

/*
    getHolographableContractsLength
*/

/**
 * @notice Test the validity of the length of holographable contracts returned by the registry.
 * @dev This test verifies that the length of the list of holographable contracts returned by the registry
 * matches the expected count of 5.
 * Refers to the hardhat test with the description 'Should return valid _holographableContracts length'
 */    
    function testReturnValid_holographableContractsLength() public {
        uint16 expectedHolographableContractsCount = 5;
        uint256 length = registry.getHolographableContractsLength();
        assertEq(length, expectedHolographableContractsCount);
    }

/**
 * @notice Test allowing an external contract to call the getHolographableContractsLength function.
 * @dev This test verifies that an external contract can successfully call the getHolographableContractsLength function
 * of the registry contract.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallGetHolographableContractsLength() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographableContractsLength()');
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }

/*
    isHolographedContract
*/

/**
 * @notice Test the validation of a smart contract as a valid holographed contract.
 * @dev This test checks if the smart contract at the address of sampleErc721Holographer
 * is considered a valid holographed contract by the registry.
 * It verifies that the function returns true for a valid holographed contract.
 * Refers to the hardhat test with the description 'Should return true if smartContract is valid'
 */
    function testReturnTrueIfSmartContractIsValid() public {
        bool isHolographed = registry.isHolographedContract(address(sampleErc721Holographer));
        assertTrue(isHolographed);
    }

/**
 * @notice Test the validation of an invalid smart contract as a holographed contract.
 * @dev This test checks if the registry correctly identifies a smart contract at the address of mockAddress
 * as an invalid holographed contract.
 * It verifies that the function returns false for an invalid holographed contract.
 * Refers to the hardhat test with the description 'Should return false if smartContract is INVALID'
 */
    function testReturnFalseIfSmartContractIsInvalid() public {
        vm.prank(deployer);
        bool isHolographed = registry.isHolographedContract(address(mockAddress));
        assertFalse(isHolographed);
    }

/**
 * @notice Test allowing an external contract to call the isHolographedContract function.
 * @dev This test verifies that an external contract can successfully call the isHolographedContract function
 * of the registry contract with the address of mockAddress as a parameter.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCalIsHolographableContract() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('isHolographedContract(address)', mockAddress);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }

/*
    isHolographedHashDeployed
*/

/**
 * @notice Test the validation of a contract hash as a valid holographed contract hash.
 * @dev This test checks if the contract hash of sampleErc721Holographer
 * is considered a valid holographed contract hash by the registry.
 * It verifies that the function returns true for a valid holographed contract hash.
 * Refers to the hardhat test with the description 'Should return true if hash is valid'
 */
    function testReturnTrueIfHashIsValid() public {
        vm.skip(true);
        //bool isHolographed = registry.isHolographedContract(sampleErc721Hash);
        //assertTrue(isHolographed);
    }    

/**
 * @notice Test the validation of an invalid contract hash as a deployed holographed contract hash.
 * @dev This test checks if the registry correctly identifies an invalid contract hash
 * as not being deployed as a holographed contract.
 * It verifies that the function returns false for an invalid holographed contract hash.
 * Refers to the hardhat test with the description 'should return false if hash is INVALID'
 */
    function testReturnFalseIfHashIsInvalid() public {
        bytes32 contractHash = getContractType('HolographERC721');
        bool isHolographed = registry.isHolographedHashDeployed(contractHash);
        assertFalse(isHolographed);
    }    

/**
 * @notice Test allowing an external contract to call the isHolographedHashDeployed function.
 * @dev This test verifies that an external contract can successfully call the isHolographedHashDeployed function
 * of the registry contract with the hash of sampleERC721Hash as a parameter.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCal_isHolographableHashDeployed() public {
        vm.skip(true);
        //bytes memory  encodeSignature = abi.encodeWithSignature('isHolographedHashDeployed(bytes32)', sampleERC721Hash);
        //mockExternalCall.callExternalFn(address(registry), encodeSignature);        
    }    

/*
    getHolographedHashAddress
*/

/**
 * @notice Test the validity of the holographed contracts hash map in the registry.
 * @dev This test checks if the registry correctly maps the hash of sampleErc721Holographer
 * to the address of the sampleErc721Holographer contract.
 * It verifies that the function returns the correct address for a given holographed contract hash.
 * Refers to the hardhat test with the description 'Should return valid _holographedContractsHashMap'
 */
    function testReturnValid_holographedContractsHashMap() public {
        vm.skip(true);
        //address add = registry.getHolographedHashAddress(sampleErc721Hash);
        //assertEq(add, address(sampleErc721Holographer));
    }    

/**
 * @notice Test the return of the zero address for an invalid holographed contract hash.
 * @dev This test checks if the registry correctly returns the zero address
 * when queried for the address of an invalid holographed contract hash.
 * It verifies that the function returns the zero address for an invalid hash.
 * Refers to the hardhat test with the description 'should return 0x0 for invalid hash'
 */
    function testReturn0x0ForInvalidHash() public {
        bytes32 contractHash = getContractType('HolographERC721');
        address add = registry.getHolographedHashAddress(contractHash);
        assertEq(add, zeroAddress);
    }    

/**
 * @notice Test allowing an external contract to call the getHolographedHashAddress function.
 * @dev This test verifies that an external contract can successfully call the getHolographedHashAddress function
 * of the registry contract with the hash of sampleERC721Hash as a parameter.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCalGetHolographedHashAddress() public {
        vm.skip(true);
        //bytes memory  encodeSignature = abi.encodeWithSignature('getHolographedHashAddress(bytes32)', sampleERC721Hash);
        //mockExternalCall.callExternalFn(address(registry), encodeSignature);         
    }

/*
    setReservedContractTypeAddress
*/

/**
 * @notice Test allowing an admin to set a contract type address in the registry.
 * @dev This test verifies that an admin can successfully set a reserved contract type address
 * in the registry for the contract type 'HolographERC721'.
 * It simulates the admin (deployer) calling the setReservedContractTypeAddress function with the contract type hash and a boolean value.
 * Refers to the hardhat test with the description 'should allow admin to set contract type address'
 */
    function testAllowAdminToSetContractTypeAddress() public {
        bytes32 contractTypeHash = getContractType('HolographERC721');
        vm.prank(deployer);
        registry.setReservedContractTypeAddress(contractTypeHash, true);
    }

/**
 * @notice Test the revert when a random user tries to alter a contract type address in the registry.
 * @dev This test verifies that a random user (not an admin) cannot set a reserved contract type address
 * in the registry for the contract type 'HolographERC721'.
 * It simulates a random user calling the setReservedContractTypeAddress function with the contract type hash and a boolean value.
 * The test expects the function call to revert due to insufficient permissions.
 * Refers to the hardhat test with the description 'should fail to allow rand user to alter contract type address'

 */
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

/**
 * @notice Test the return of the expected contract type address from the registry.
 * @dev This test verifies that the registry correctly stores and returns the expected contract type address
 * for the contract type 'HolographERC721' after setting it as a reserved contract type address.
 * It simulates setting the reserved contract type address and the contract type address in the registry,
 * then retrieves the stored contract type address and compares it with the expected address.
 * Refers to the hardhat test with the description 'should return expected contract type address'
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

/**
 * @notice Test allowing an admin to alter and set a contract type address in the registry.
 * @dev This test verifies that an admin can successfully alter and set a contract type address
 * in the registry for the contract type 'HolographERC721' after setting it as a reserved contract type address.
 * It simulates the admin (deployer) setting the reserved contract type address and then updating it with a new address,
 * and checks if the registry correctly stores and returns the updated contract type address.
 * Refers to the hardhat test with the description 'should allow admin to alter setContractTypeAddress'
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

/**
 * @notice Test the revert when a random user tries to set a contract type address in the registry.
 * @dev This test verifies that a random user (not an admin) cannot set a contract type address
 * in the registry for the contract type 'HolographERC721' after it has been set as a reserved contract type address.
 * It simulates the admin (deployer) setting the reserved contract type address, and then a random user attempting to update the contract type address.
 * The test expects the function call to revert due to insufficient permissions.
 * It also checks that the stored contract type address remains unchanged after the failed attempt.
 * Refers to the hardhat test with the description 'should fail to allow rand user to alter setContractTypeAddress'
 */
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

/**
 * @notice Test the return of a valid contract type address from the registry.
 * @dev This test verifies that the registry correctly stores and returns the expected contract type address
 * for the contract type 'HolographERC721' after it has been set by an admin.
 * It simulates the admin (deployer) setting the reserved contract type address and then setting the contract type address,
 * and checks if the registry correctly returns the stored contract type address.
 * Refers to the hardhat test with the description 'Should return valid _contractTypeAddresses'
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

/**
 * @notice Test allowing an external contract to call the getContractTypeAddress function.
 * @dev This test verifies that an external contract can successfully call the getContractTypeAddress function
 * of the registry contract with the contract type hash of 'HolographERC721' as a parameter.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallFn_getContractTypeAddress() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getContractTypeAddress(bytes32)', getContractType('HolographERC721'));
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }  

/*
    referenceContractTypeAddress
*/

/**
 * @notice Test the return of a valid address from the registry.
 * @dev This test verifies that the registry correctly references the address of the holographERC20 contract.
 * It calls the referenceContractTypeAddress function in the registry with the address of the holographERC20 contract.
 * Refers to the hardhat test with the description 'should return valid address'
 */
    function testReturnValidAddress() public {
        registry.referenceContractTypeAddress(address(holographERC20));
    }

/**
 * @notice Test the revert when trying to reference an empty contract in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: empty contract'
 * when attempting to reference an empty contract address.
 * It simulates calling the referenceContractTypeAddress function in the registry with a random empty contract address.
 * Refers to the hardhat test with the description 'should fail if contract is empty'
 */
    function testIfContractIsEmptyRevert() public {
        address contractAddress = randomAddress();
        vm.expectRevert('HOLOGRAPH: empty contract');
        registry.referenceContractTypeAddress(contractAddress);        
    }

/**
 * @notice Test the revert when trying to reference an already set contract in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: contract already set'
 * when attempting to reference a contract that has already been set in the registry.
 * It first references the address of the holographERC20 contract, then simulates trying to reference it again.
 * Refers to the hardhat test with the description 'should fail if contract is already set'
 */
    function testIfContractIsAlreadySetRevert() public {
        registry.referenceContractTypeAddress(address(holographERC20));          
        vm.expectRevert('HOLOGRAPH: contract already set');
        registry.referenceContractTypeAddress(address(holographERC20));          
    }

/**
 * @notice Test allowing an external contract to call the referenceContractTypeAddress function.
 * @dev This test verifies that an external contract can successfully call the referenceContractTypeAddress function
 * of the registry contract with the address of the holographERC20 contract as a parameter.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallFnReferenceContractTypeAddress() public {
        bytes memory encodeSignature = abi.encodeWithSignature('referenceContractTypeAddress(address)', address(holographERC20));
        mockExternalCall.callExternalFn(address(registry), encodeSignature);        
    }

/*
    setHolograph()
*/   

/**
 * @notice Test allowing an admin to alter the holograph slot in the registry.
 * @dev This test verifies that an admin can successfully update the holograph slot
 * in the registry with a new address.
 * It simulates the admin calling the setHolograph function with a mock address,
 * and then checks if the registry correctly stores and returns the updated holograph address.
 * Refers to the hardhat test with the description 'should allow admin to alter _holographSlot'
 */
    function testAllowAdminToAlter_holographSlot() public {
        // TODO Check which is the admin adddres
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setHolograph(address(mockAddress));
        assertEq(holographRegistry.getHolograph(), mockAddress);
        vm.stopPrank();
    }

/**
 * @notice Test the revert when the owner tries to alter the holograph slot in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when the owner (not the admin) attempts to alter the holograph slot.
 * It simulates the owner trying to call the setHolograph function with a mock address.
 * Refers to the hardhat test with the description 'should fail to allow owner to alter _holographSlot'
 */
    function testAllowOwnerToAlter_holographSlotFail() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHolograph(address(mockAddress));
    }

/**
 * @notice Test the revert when a random user tries to alter the holograph slot in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when a random user (not the admin) attempts to alter the holograph slot.
 * It simulates a random user calling the setHolograph function with a mock address.
 * Refers to the hardhat test with the description 'should fail to allow non-owner to alter _holographSlot'
 */
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

/**
 * @notice Test allowing an external contract to call the getHolograph function.
 * @dev This test verifies that an external contract can successfully call the getHolograph function
 * of the registry contract without any parameters.
 * It simulates an external contract calling the getHolograph function in the registry.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallFnGetHolograph() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolograph()');
        mockExternalCall.callExternalFn(address(registry), encodeSignature);           
    }

/*
    setHToken()
*/

/**
 * @notice Test allowing an admin to alter the hTokens mapping in the registry.
 * @dev This test verifies that an admin can successfully update the hToken address for a specific chain ID
 * in the registry with a new address.
 * It simulates the admin calling the setHToken function with a valid chain ID and hToken address,
 * and then checks if the registry correctly stores and returns the updated hToken address for the chain ID.
 */
    function testAllowAdminToAlter_hTokens() public {
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setHToken(validChainId, hTokenAddress);
        assertEq(holographRegistry.getHToken(validChainId), hTokenAddress);
        vm.stopPrank();
    }

/**
 * @notice Test the revert when the owner tries to alter the hTokens mapping in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when the owner (not the admin) attempts to alter the hToken address for a specific chain ID.
 * It simulates the owner trying to call the setHToken function with a valid chain ID and hToken address.
 * Refers to the hardhat test with the description 'should fail to allow owner to alter _hTokens'
 */
    function testAllowOwnerToAlter_hTokensRevert() public {
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setHToken(validChainId, hTokenAddress);
    }

/**
 * @notice Test the revert when a non-admin user tries to alter the hTokens mapping in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when a non-admin user attempts to alter the hToken address for a specific chain ID.
 * It simulates a random user calling the setHToken function with a valid chain ID and hToken address.
 * Refers to the hardhat test with the description 'should fail to allow non-owner to alter _hTokens'
 */
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

/**
 * @notice Test the return of a valid hToken address from the registry.
 * @dev This test verifies that the registry correctly returns the expected hToken address
 * for a specific chain ID after it has been set by an admin.
 * It first calls the testAllowAdminToAlter_hTokens test to set the hToken address,
 * then checks if the registry correctly returns the stored hToken address for the chain ID.
 * Refers to the hardhat test with the description 'Should return valid _hTokens'
 */

    function testReturnValid_hTokens() public {
        testAllowAdminToAlter_hTokens();
        uint32 validChainId = 5;
        address hTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        vm.prank(deployer);
        address hTokenAddr = holographRegistry.getHToken(validChainId);
        assertEq(hTokenAddr, hTokenAddress);    
    }

/**
 * @notice Test the return of 0x0 for an invalid chain ID from the registry.
 * @dev This test verifies that the registry returns 0x0 (zero address) when querying for an hToken address
 * with an invalid chain ID (0) that does not exist in the mapping.
 * It checks if the registry correctly returns 0x0 for the hToken address associated with the invalid chain ID.
 * Refers to the hardhat test with the description 'should return 0x0 for invalid chainId'
 */
    function testReturn0x0ForInvalidChainId() public {
        uint32 invalidChainId = 0;
        assertEq(holographRegistry.getHToken(invalidChainId), zeroAddress);
    }

/**
 * @notice Test allowing an external contract to call the getHToken function.
 * @dev This test verifies that an external contract can successfully call the getHToken function
 * of the registry contract with a valid chain ID as a parameter.
 * It simulates an external contract calling the getHToken function in the registry with a valid chain ID.
 * Refers to the hardhat test with the description 'Should allow external contract to call fn'
 */
    function testAllowExternalContractToCallFnGetHToken() public {
        uint32 validChainId = 5;
        bytes memory encodeSignature = abi.encodeWithSignature('getHToken(uint32)', validChainId);
        mockExternalCall.callExternalFn(address(registry), encodeSignature);
    }

/*
    setUtilityToken()
*/

/**
 * @notice Test allowing an admin to alter the utility token slot in the registry.
 * @dev This test verifies that an admin can successfully update the utility token slot
 * in the registry with a new address.
 * It simulates the admin calling the setUtilityToken function with a utility token address,
 * and then checks if the registry correctly stores and returns the updated utility token address.
 * Refers to the hardhat test with the description 'should allow admin to alter _utilityTokenSlot'
 */
    function testAllowAdminToAlter_utilityTokenSlot() public {
        vm.startPrank(holographRegistry.getAdmin());
        holographRegistry.setUtilityToken(utilityTokenAddress);
        assertEq(holographRegistry.getUtilityToken(), utilityTokenAddress);
        vm.stopPrank();
    }

/**
 * @notice Test the revert when the owner tries to alter the utility token slot in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when the owner (not the admin) attempts to alter the utility token slot.
 * It simulates the owner trying to call the setUtilityToken function with a utility token address.
 * Refers to the hardhat test with the description 'should fail to allow owner to alter _utilityTokenSlot'
 */
    function testAllowOwnerToAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holographRegistry.setUtilityToken(utilityTokenAddress);
    }

/**
 * @notice Test the revert when a random user tries to alter the utility token slot in the registry.
 * @dev This test verifies that the registry reverts with the message 'HOLOGRAPH: admin only function'
 * when a random user (not the admin) attempts to alter the utility token slot.
 * It simulates a random user calling the setUtilityToken function with a utility token address.
 * Refers to the hardhat test with the description 'should fail to allow non-owner to alter _utilityTokenSlot'
 */
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