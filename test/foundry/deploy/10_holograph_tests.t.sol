// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {MockExternalCall} from "../../../src/mock/MockExternalCall.sol";
import {HolographInterface} from "../../../src/interface/HolographInterface.sol";

contract HolographTests is Test {
    uint256 localHostFork;
    string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
    address admin = vm.addr(1);
    address user = vm.addr(2);
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
    HolographInterface holographInterface;

    function randomAddress() public view returns (address) {
        uint256 randomNum = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
        return address(uint160(randomNum));
    }

    function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    
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

    function testInit() public {
        Holograph holographTest;
        holographTest = new Holograph();
        bytes memory initCode = generateInitCode(holographChainId, bridge, factory, interfaces, operator, registry, treasury, utilityToken);
        holographTest.init(initCode);
    }

    function testSetAdmin() public {
        admin = holograph.getAdmin();
        vm.prank(admin);
        holograph.setAdmin(user);
    }

    function testInitAlreadyInitializedRevert() public {
        vm.expectRevert('HOLOGRAPH: already initialized');
        holograph.init(initCode);
    }

/*
    GET BRIDGE
*/

    function testReturnValidBridge() public {
        assertEq(holograph.getBridge(), bridge);
    }

    function testAllowExternalContract() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getBridge()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET BRIDGE
*/

    function testAllowAdminAlter_bridgeSlot() public {
        vm.prank(holograph.admin());
        holograph.setBridge(randomAddress());
    }

    function testAllowOwnerToAlter_bridgeSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setBridge(randomAddress());
    }

    function testAllowNonOwnerToAlter_bridgeSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setBridge(randomAddress());
    }

/*
    GET CHAINID
*/

    function testReturnValid_chainIdSlot() public {
        //TODO ChainId vació es igualo a ChainId = 0 ??
        assertNotEq(holograph.getChainId(), 0);
    }

    function testAllowExternalContractToCallFnGethainID() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getChainId()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);        
    }

/*
    SET CHAIN ID
*/

    function testAllowAdminAlter_chainIdSlot() public {
        vm.prank(holograph.admin());
        holograph.setChainId((2));
    }

    function testAllowOwnerAlter_chainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setChainId(3);
    }

    function testAllowNonOwnerAlter_chainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setChainId(4);
    }

/*
    GET FACTORY
*/

    function testReturnValid_factorySlot() public {
        assertEq(holograph.getFactory(), factory);
    }

    function testAllowExternalContractToCallFnGetFactory() public {
        bytes memory  encodeSignature = abi.encodeWithSignature('getFactory()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET FACTORY
*/

    function testAllowAdminAlter_factoryIdSlot() public {
        vm.prank(holograph.admin());
        holograph.setFactory(randomAddress());
    }

    function testAllowOwnerAlter_factorySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setFactory(randomAddress());
    }

    function testAllowNonOwnerAlter_factorySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setFactory(randomAddress());
    }

/*
    GET HOLOGRAPH CHAINID
*/

    function testReturnValid_holographChainIdSlot() public {
        assertEq(holograph.getHolographChainId(), holographChainId);
    }

    function testAllowExternalContractToCallFnGetHolographChainId() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getHolographChainId()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET HOLOGRAPH CHAINID
*/

    function testAllowAdminAlter_holographChainIdSlot() public {
        vm.prank(holograph.admin());
        holograph.setHolographChainId(2);
    }

    function testAllowOwnerAlter_holographChainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setHolographChainId(3);
    }

    function testAllowNonOwnerAlter_holographChainIdSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setHolographChainId(4);
    }

/*
    GET INTERFACES
*/

    function testReturnValid_interfacesSlot() public {
        assertEq(holograph.getInterfaces(), interfaces);
    }

    function testAllowExternalContractToCallFnGetInterfaces() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getInterfaces()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }    

/*
    SET INTERFACES
*/

    function testAllowAdminAlter_interfacesSlot() public {
        vm.prank(holograph.admin());
        holograph.setInterfaces(randomAddress());
    }

    function testAllowOwnerAlter_interfacesSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setInterfaces(randomAddress());
    }

    function testAllowNonOwnerAlter_interfacesSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setInterfaces(randomAddress());
    }

/*
    GET OPERATOR
*/

    function testReturnValid_operatorSlot() public {
        assertEq(holograph.getOperator(), operator);
    }

    function testAllowExternalContractToCallFnGetOperator() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getOperator()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET OPERATOR
*/

    function testAllowAdminAlter_operatorSlot() public {
        vm.prank(holograph.admin());
        holograph.setOperator(randomAddress());
    }

    function testAllowOwnerAlter_operatorSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setOperator(randomAddress());
    }

    function testAllowNonOwnerAlter_operatorSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setOperator(randomAddress());
    }

/*
    GET REGISTRY
*/

    function testReturnValid_registrySlot() public {
        assertEq(holograph.getRegistry(), registry);
    }

    function testAllowExternalContractToCallFnGetRegistry() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getRegistry()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET REGISTRY
*/

    function testAllowAdminAlter_registrySlot() public {
        vm.prank(holograph.admin());
        holograph.setRegistry(randomAddress());
    }

    function testAllowOwnerAlter_registrySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setRegistry(randomAddress());
    }

    function testAllowNonOwnerAlter_registrySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setRegistry(randomAddress());
    }

/*
    GET TREASURY
*/

    function testReturnValid_treasurySlot() public {
        assertEq(holograph.getTreasury(), treasury);
    }

    function testAllowExternalContractToCallFnGetTreasury() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getTreasury()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET TREASURY
*/

    function testAllowAdminAlter_treasurySlot() public {
        vm.prank(holograph.admin());
        holograph.setTreasury(randomAddress());
    }

    function testAllowOwnerAlter_treasurySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setTreasury(randomAddress());
    }

    function testAllowNonOwnerAlter_treasurySlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setTreasury(randomAddress());
    }

/*
    GET UTILITY TOKEN
*/

    function testReturnValid_utilityTokenSlot() public {
        assertEq(holograph.getTreasury(), treasury);
    }

    function testAllowExternalContractToCallFnGetUtilityToken() public {
        bytes memory encodeSignature = abi.encodeWithSignature('getUtilityToken()');
        mockExternalCall.callExternalFn(address(holograph), encodeSignature);
    }

/*
    SET UTILITY TOKEN
*/

    function testAllowAdminAlter_utilityTokenSlot() public {
        vm.prank(holograph.admin());
        holograph.setUtilityToken(randomAddress());
    }

    function testAllowOwnerAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        holograph.setUtilityToken(randomAddress());
    }

    function testAllowNonOwnerAlter_utilityTokenSlotRevert() public {
        vm.expectRevert('HOLOGRAPH: admin only function');
        vm.prank(user);
        holograph.setUtilityToken(randomAddress());
    }

}

