// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {MockExternalCall} from "../../../src/mock/MockExternalCall.sol";

    /**
    * @title Contract Test - Holograph
    * @notice This contract contains a series of tests to verify the functionality of the Holograph contract.
    * The tests cover the initialization process, getter functions, and setter functions.
    * @dev The tests include verifying initialization, admin functions, revert behaviors, and external contract interactions.
    * The tests check the validity of various contract slots like bridge, chainId, factory, interfaces, operator, registry, 
    * treasury, and utilityToken.
    * The tests also verify that only the admin can alter certain contract slots, while non-owners trigger revert behaviors.
    * Translation of a suite of Hardhat tests found in test/10_holograph_tests.ts
    */

contract HolographTests is Test {
    address admin = vm.addr(1);
    address user = vm.addr(2);
    address origin = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;  //default address origin in foundry
    uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
    address deployer = vm.addr(privateKeyDeployer);

    bytes initCode;
    uint32  holographChainId;
    address bridge;
    address factory;
    address interfaces;
    address operator;
    address registry;
    address treasury;
    address utilityToken;

    Holograph holograph;
    MockExternalCall mockExternalCall;

    function randomAddress() public view returns (address) {
        uint256 randomNum = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        return address(uint160(randomNum));
    }

    function setUp() public {
    
    // Deploy contracts
    vm.startPrank(deployer);
    holograph = new Holograph();
    mockExternalCall = new MockExternalCall();
    vm.stopPrank();

    holographChainId = 1;
    bridge = randomAddress();
    factory = randomAddress();
    interfaces = randomAddress();
    operator = randomAddress();
    registry = randomAddress();
    treasury = randomAddress();
    utilityToken = randomAddress();

    bytes memory initCode = generateInitCode(holographChainId, bridge, factory, interfaces, operator, registry, treasury, utilityToken);
    holograph.init(initCode);
    }

    function generateInitCode(
    uint32 holographChainId,
    address bridge,
    address factory,
    address interfaces,
    address operator,
    address registry,
    address treasury,
    address utilityToken
    ) public pure returns (bytes memory) {
        return abi.encode(
        holographChainId, bridge, factory, interfaces, operator, registry, treasury, utilityToken
        );
    }

/*
    INIT()
*/

    /**
    * @notice Test the initialization of the Holograph contract.
    * @dev This is a basic test to ensure the initialization process works as expected.
    * This test deploys a new instance of the Holograph contract, generates initialization code,
    * and initializes the contract with the provided parameters.
    */
    function testInit() public {
        Holograph holographTest;
        holographTest = new Holograph();
        bytes memory initCode = generateInitCode(holographChainId, bridge, factory, interfaces, operator, registry, treasury, utilityToken);
        holographTest.init(initCode);
    }

    /**
    * @notice Test the setAdmin function of the Holograph contract.
    * @dev This test is designed to verify the functionality of setting a new admin address in the contract.
    * This test retrieves the current admin address from the Holograph contract,
    * performs a prank operation on the admin address using the VM,
    * and then sets a new admin address to the contract.
    */
    function testSetAdmin() public {
        vm.prank(origin);
        holograph.setAdmin(admin);
    }

    /**
    * @notice Test the revert behavior when trying to initialize an already initialized Holograph contract.
    * @dev This test is designed to verify that the contract reverts as expected when the contract has already been initialized.
    * This test expects a revert with the message 'HOLOGRAPH: already initialized' when trying to initialize
    * a Holograph contract that is already initialized.
    */
    function testInitAlreadyInitializedRevert() public {
        vm.expectRevert('HOLOGRAPH: already initialized');
        holograph.init(initCode);
    }

/*
    GET BRIDGE
*/

    /**
    * @notice Test the validity of the bridge slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the bridge slot in the contract.
    * This test verifies that the value returned by `getBridge()` in the Holograph contract
    * matches the expected `bridge` address.
    */
    function testReturnValid_bridgeSlot() public {
        assertEq(holograph.getBridge(), bridge);
    }

    /**
    * @notice Test the ability of an external contract to call the getBridge function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getBridge 
    * function in the Holograph contract.
    * This test encodes the signature of the getBridge function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetBridge() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getBridge()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET BRIDGE
*/

    /**
    * @notice Test the ability of the admin to alter the bridge slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the bridge slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the bridge in the contract.
    */
    function testAllowAdminAlter_bridgeSlot() public {
        vm.prank(origin);
        holograph.setBridge(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the bridge slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the bridge slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the bridge slot in the Holograph contract.
    */
    function testAllowOwnerToAlter_bridgeSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setBridge(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the bridge slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the bridge slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the bridge slot in the Holograph contract.
    */
    function testAllowNonOwnerToAlter_bridgeSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setBridge(randomAddress());
    }

/*
    GET CHAINID
*/

    /**
    * @notice Test the validity of the chainId slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the chainId slot in the contract. 
    * This test verifies that the value returned by `getChainId()` in the Holograph contract
    * is not equal to zero.
    */
    function testReturnValid_chainIdSlot() public {
        //TODO Empty ChainId equals ChainId = 0 ??
        assertNotEq(holograph.getChainId(), 0);
    }

    /**
    * @notice Test the ability of an external contract to call the getChainId function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getChainId 
    * function in the Holograph contract.
    * This test encodes the signature of the getChainId function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetChainID() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getChainId()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);        
    }

/*
    SET CHAIN ID
*/

    /**
    * @notice Test the ability of the admin to alter the chainId slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the chainId slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the chainId in the contract.
    */
    function testAllowAdminAlter_chainIdSlot() public {
        vm.prank(origin);
        holograph.setChainId((2));
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the chainId slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the chainId slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the chainId slot in the Holograph contract.
    */
    function testAllowOwnerAlter_chainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setChainId(3);
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the chainId slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the chainId slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the chainId slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_chainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setChainId(4);
    }

/*
    GET FACTORY
*/

    /**
    * @notice Test the validity of the factory slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the factory slot in the contract.
    * This test verifies that the value returned by `getFactory()` in the Holograph contract
    * matches the expected `factory` address.
    */
    function testReturnValid_factorySlot() public {
        assertEq(holograph.getFactory(), factory);
    }

    /**
    * @notice Test the ability of an external contract to call the getFactory function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getFactory 
    * function in the Holograph contract.
    * This test encodes the signature of the getFactory function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetFactory() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getFactory()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET FACTORY
*/

    /**
    * @notice Test the ability of the admin to alter the factory slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the factory slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the factory in the contract.
    */
    function testAllowAdminAlter_factorySlot() public {
        vm.prank(origin);
        holograph.setFactory(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the factory slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the factory slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the factory slot in the Holograph contract.
    */
    function testAllowOwnerAlter_factorySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setFactory(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the factory slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the factory slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the factory slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_factorySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setFactory(randomAddress());
    }

/*
    GET HOLOGRAPH CHAINID
*/

    /**
    * @notice Test the validity of the holographChainId slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the holographChainId slot in the contract.
    * This test verifies that the value returned by `getHolographChainId()` in the Holograph contract
    * matches the expected `holographChainId` address.
    */
    function testReturnValid_holographChainIdSlot() public {
        assertEq(holograph.getHolographChainId(), holographChainId);
    }

    /**
    * @notice Test the ability of an external contract to call the getHolographChainId function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getHolographChainId 
    * function in the Holograph contract.
    * This test encodes the signature of the getHolographChainId function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetHolographChainId() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographChainId()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET HOLOGRAPH CHAINID
*/

    /**
    * @notice Test the ability of the admin to alter the holographChainId slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the holographChainId slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the holographChainId in the contract.
    */
    function testAllowAdminAlter_holographChainIdSlot() public {
        vm.prank(origin);
        holograph.setHolographChainId(2);
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the holographChainId slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the holographChainId slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the holographChainId slot in the Holograph contract.
    */
    function testAllowOwnerAlter_holographChainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setHolographChainId(3);
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the holographChainId slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the holographChainId slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the holographChainId slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_holographChainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setHolographChainId(4);
    }

/*
    GET INTERFACES
*/

    /**
    * @notice Test the validity of the interfaces slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the interfaces slot in the contract.
    * This test verifies that the value returned by `getInterfaces()` in the Holograph contract
    * matches the expected `interfaces` address.
    */
    function testReturnValid_interfacesSlot() public {
        assertEq(holograph.getInterfaces(), interfaces);
    }

    /**
    * @notice Test the ability of an external contract to call the getInterfaces function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getInterfaces 
    * function in the Holograph contract.
    * This test encodes the signature of the getInterfaces function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetInterfaces() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getInterfaces()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }    

/*
    SET INTERFACES
*/

    /**
    * @notice Test the ability of the admin to alter the interfaces slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the interfaces slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the interfaces in the contract.
    */
    function testAllowAdminAlter_interfacesSlot() public {
        vm.prank(origin);
        holograph.setInterfaces(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the interfaces slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the interfaces slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the interfaces slot in the Holograph contract.
    */
    function testAllowOwnerAlter_interfacesSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setInterfaces(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the interfaces slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the interfaces slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the interfaces slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_interfacesSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setInterfaces(randomAddress());
    }

/*
    GET OPERATOR
*/

    /**
    * @notice Test the validity of the operator slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the operator slot in the contract.
    * This test verifies that the value returned by `getOperator()` in the Holograph contract
    * matches the expected `operator` address.
    */
    function testReturnValid_operatorSlot() public {
        assertEq(holograph.getOperator(), operator);
    }

    /**
    * @notice Test the ability of an external contract to call the getOperator function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getOperator 
    * function in the Holograph contract.
    * This test encodes the signature of the getOperator function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetOperator() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getOperator()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET OPERATOR
*/

    /**
    * @notice Test the ability of the admin to alter the operator slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the operator slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the operator in the contract.
    */
    function testAllowAdminAlter_operatorSlot() public {
        vm.prank(origin);
        holograph.setOperator(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the operator slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the operator slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the operator slot in the Holograph contract.
    */
    function testAllowOwnerAlter_operatorSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setOperator(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the operator slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the operator slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the operator slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_operatorSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setOperator(randomAddress());
    }

/*
    GET REGISTRY
*/

    /**
    * @notice Test the validity of the registry slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the registry slot in the contract.
    * This test verifies that the value returned by `getRegistry()` in the Holograph contract
    * matches the expected `registry` address.
    */
    function testReturnValid_registrySlot() public {
        assertEq(holograph.getRegistry(), registry);
    }

    /**
    * @notice Test the ability of an external contract to call the getRegistry function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getRegistry 
    * function in the Holograph contract.
    * This test encodes the signature of the getRegistry function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetRegistry() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getRegistry()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET REGISTRY
*/

    /**
    * @notice Test the ability of the admin to alter the registry slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the registry slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the registry in the contract.
    */
    function testAllowAdminAlter_registrySlot() public {
        vm.prank(origin);
        holograph.setRegistry(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the registry slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the registry slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the registry slot in the Holograph contract.
    */
    function testAllowOwnerAlter_registrySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setRegistry(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the registry slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the registry slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the registry slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_registrySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setRegistry(randomAddress());
    }

/*
    GET TREASURY
*/

    /**
    * @notice Test the validity of the treasury slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the treasury slot in the contract.
    * This test verifies that the value returned by `getTreasury()` in the Holograph contract
    * matches the expected `treasury` address.
    */
    function testReturnValid_treasurySlot() public {
        assertEq(holograph.getTreasury(), treasury);
    }

    /**
    * @notice Test the ability of an external contract to call the getTreasury function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getTreasury 
    * function in the Holograph contract.
    * This test encodes the signature of the getTreasury function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetTreasury() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getTreasury()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET TREASURY
*/

    /**
    * @notice Test the ability of the admin to alter the treasury slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the treasury slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the treasury in the contract.
    */
    function testAllowAdminAlter_treasurySlot() public {
        vm.prank(origin);
        holograph.setTreasury(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the treasury slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the treasury slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the treasury slot in the Holograph contract.
    */
    function testAllowOwnerAlter_treasurySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setTreasury(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the treasury slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the treasury slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the treasury slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_treasurySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setTreasury(randomAddress());
    }

/*
    GET UTILITY TOKEN
*/

    /**
    * @notice Test the validity of the utilityToken slot in the Holograph contract.
    * @dev This test is designed to ensure the correct functionality of the utilityToken slot in the contract.
    * This test verifies that the value returned by `getUtilityToken()` in the Holograph contract
    * matches the expected `utilityToken` address.
    */
    function testReturnValid_utilityTokenSlot() public {
        assertEq(holograph.getUtilityToken(), utilityToken);
    }

    /**
    * @notice Test the ability of an external contract to call the getUtilityToken function in the Holograph contract.
    * @dev This test is designed to verify that an external contract can successfully call the getUtilityToken 
    * function in the Holograph contract.
    * This test encodes the signature of the getUtilityToken function and calls it from an external contract 
    * using mockExternalCall.
    */
    function testAllowExternalContractToCallGetUtilityToken() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getUtilityToken()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET UTILITY TOKEN
*/

    /**
    * @notice Test the ability of the admin to alter the utilityToken slot in the Holograph contract.
    * @dev This test is designed to verify that the admin can alter the utilityToken slot in the contract.
    * This test performs a prank operation on the current admin address of the Holograph contract,
    * and then sets a new random address as the utilityToken in the contract.
    */
    function testAllowAdminAlter_utilityTokenSlot() public {
        vm.prank(origin);
        holograph.setUtilityToken(randomAddress());
    }

    /**
    * @notice Test the revert behavior when the owner tries to alter the utilityToken slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the utilityToken slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when the owner attempts to
    * alter the utilityToken slot in the Holograph contract.
    */
    function testAllowOwnerAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setUtilityToken(randomAddress());
    }

    /**
    * @notice Test the revert behavior when a non-owner tries to alter the utilityToken slot in the Holograph contract.
    * @dev This test is designed to verify that only the admin can alter the utilityToken slot in the contract.
    * This test expects a revert with the message 'HOLOGRAPH: admin only function' when a non-owner attempts to
    * alter the utilityToken slot in the Holograph contract.
    */
    function testAllowNonOwnerAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setUtilityToken(randomAddress());
    }

}

