// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {Holograph} from "../../../src/Holograph.sol";
import {Faucet} from "../../../src/faucet/Faucet.sol";
import {ERC20} from "../../../src/interface/ERC20.sol";

contract FaucetTest is Test {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");

  HolographERC20 holographERC20;
  Holograph holograph;
  Faucet faucet;
  uint256 DEFAULT_DRIP_AMOUNT = 100 ether;
  uint256 DEFAULT_COOLDOWN = 24 hours;
  uint256 INITIAL_FAUCET_FUNDS = DEFAULT_DRIP_AMOUNT * 20;
  uint256 FAUCET_PREFUND_AMOUNT;

  // Revert msgs
  string REVERT_INITIALIZED = "Faucet contract is already initialized";
  string REVERT_COME_BACK_LATER = "Come back later";
  string REVERT_NOT_AN_OWNER = "Caller is not the owner";

  uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
  address deployer = vm.addr(privateKeyDeployer);
  address alice = vm.addr(1);
  address bob = vm.addr(2);

  function setUp() public {
    vm.startPrank(deployer);
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    holograph = Holograph(payable(Constants.getHolograph()));
    holographERC20 = HolographERC20(payable(holograph.getUtilityToken()));
    faucet = new Faucet();
    faucet.init(abi.encode(address(deployer), address(holographERC20)));
    FAUCET_PREFUND_AMOUNT = holographERC20.balanceOf(address(faucet));
    holographERC20.transfer(address(faucet), INITIAL_FAUCET_FUNDS);
    vm.stopPrank();
  }

  /*
   * INIT Section
   */

  /**
   * @notice This function tests the `init` function of the `Faucet` contract. Initialize the contract
   * @dev  Refers to the hardhat test with the description 'should fail initializing already initialized Faucet'
   */
  function testInitializerRevert() public {
    vm.expectRevert(bytes(REVERT_INITIALIZED));
    faucet.init(abi.encode(address(deployer), address(holographERC20)));
  }

  /*
   * DRIP Section
   */

  /**
   * @notice This function tests the `isAllowedToWithdraw` function of the `Faucet` contract. User is allowed to withdraw
   * @dev  Refers to the hardhat test with the description 'isAllowedToWithdraw(): User is allowed to withdraw for the first time'
   */
  function testIsAllowToWithdraw() public {
    faucet.isAllowedToWithdraw(alice);
  }

  /**
   * @notice This function tests the `requestTokens` function of the `Faucet` contract. User can withdraw token
   * @dev  Refers to the hardhat test with the description 'requestTokens(): User can withdraw for the first time'
   */
  function testRequestToken() public {
    vm.prank(alice);
    faucet.requestTokens();
  }

  /**
   * @notice This function tests the `requestTokens` function of the `Faucet` contract. User cannot is not allow to withdraw token twice
   * @dev  Refers to the hardhat test with the description 'isAllowedToWithdraw(): User is not allowed to withdraw for the second time'
   */
  function testIsAllowToWithdrawRevert() public {
    testRequestToken();
    assertEq(faucet.isAllowedToWithdraw(alice), false);
  }

  /**
   * @notice This function tests the `requestTokens` function of the `Faucet` contract. User cannot withdraw token twice
   * @dev  Refers to the hardhat test with the description 'requestTokens(): User cannot withdraw for the second time'
   */
  function testRequestTokenRevert() public {
    testRequestToken();
    vm.expectRevert();
    vm.prank(alice);
    faucet.requestTokens();
  }

  /*
   * OWNER DRIP Section
   */

  /**
   * @notice This function tests the `grantTokens` function of the `Faucet` contract. Owner can grant tokens
   * @dev  Refers to the hardhat test with the description 'grantTokens(): Owner can grant tokens'
   */
  function testGrantToken() public {
    vm.prank(deployer);
    faucet.grantTokens(alice);
    assertEq(holographERC20.balanceOf(alice), DEFAULT_DRIP_AMOUNT);
  }

  /**
   * @notice This function tests the `grantTokens` function of the `Faucet` contract. Owner can grant tokens with arbitrary amount
   * @dev  Refers to the hardhat test with the description 'grantTokens(): Owner can grant tokens again with arbitrary amount'
   */
  function testGrantTokenSpecificAmount() public {
    vm.prank(deployer);
    faucet.grantTokens(alice, 5);
    assertEq(holographERC20.balanceOf(alice), 5);
  }

  /**
   * @notice This function tests the `grantTokens` function of the `Faucet` contract. Revert because not owner call
   * @dev  Refers to the hardhat test with the description 'grantTokens(): Non Owner should fail to grant tokens'
   */
  function testGrantTokenRevert() public {
    vm.expectRevert();
    faucet.grantTokens(alice);
  }

  /**
   * @notice This function tests the `grantTokens` function of the `Faucet` contract. Revert because not have founds
   * @dev  Refers to the hardhat test with the description 'grantTokens(): Should fail if contract has insufficient funds'
   */
  function testGrantTokenRevertInsufficientFounds() public {
    vm.prank(deployer);
    faucet.grantTokens(alice, INITIAL_FAUCET_FUNDS);
    vm.expectRevert("Faucet is empty");
    vm.prank(deployer);
    faucet.grantTokens(alice);
  }

  /*
   * OWNER ADJUST Withdraw Cooldown
   */

  /**
   * @notice This function tests the `setWithdrawCooldown` function of the `Faucet` contract. Owner can adjust Withdraw Cooldown
   * @dev  Refers to the hardhat test with the description 'isAllowedToWithdraw(): Owner is not allowed to withdraw'
   */
  function testOwnerIsNotAllowedToWithdrawTwice() public {
    vm.prank(deployer);
    faucet.requestTokens();
    assertEq(faucet.isAllowedToWithdraw(deployer), false);
  }

  /**
   * @notice This function tests the `setWithdrawCooldown` function of the `Faucet` contract. Owner can adjust Withdraw Cooldown in Zero
   * @dev  Refers to the hardhat test with the description 'setWithdrawCooldown(): Owner adjusts Withdraw Cooldown to 0 seconds'
   */
  function testSetCooldownInZero() public {
    vm.prank(deployer);
    faucet.setWithdrawCooldown(0);
    assertEq(faucet.faucetCooldown(), 0);
  }

  /**
   * @notice This function tests the `setWithdrawCooldown` function of the `Faucet` contract. Owner can adjust Withdraw Cooldown in Zero and allow too withdraw
   * @dev  Refers to the hardhat test with the description 'isAllowedToWithdraw(): Owner is allowed to withdraw'
   */
  function testSetCooldownInZeroAndAllowTooWithdraw() public {
    testOwnerIsNotAllowedToWithdrawTwice();
    testSetCooldownInZero();
    assertEq(faucet.isAllowedToWithdraw(deployer), true);
  }

  /**
   * @notice This function tests the `setWithdrawCooldown` function of the `Faucet` contract. Not owner can't adjust Withdraw Cooldown
   * @dev  Refers to the hardhat test with the description 'setWithdrawCooldown(): User can't adjust Withdraw Cooldown'
   */
  function testSetCooldownRevert() public {
    vm.expectRevert(bytes(REVERT_NOT_AN_OWNER));
    faucet.setWithdrawCooldown(0);
  }

  /*
   * OWNER ADJUST Withdraw Amount
   */

  /**
   * @notice This function tests the `setWithdrawAmount` function of the `Faucet` contract. Owner can adjust Withdraw Amount
   * @dev  Refers to the hardhat test with the description 'setWithdrawAmount(): Owner adjusts Withdraw Amount'
   */
  function testChangeWithdrawAmount() public {
    vm.prank(deployer);
    faucet.setWithdrawAmount(DEFAULT_DRIP_AMOUNT - 2);
    assertEq(faucet.faucetDripAmount(), DEFAULT_DRIP_AMOUNT - 2);
  }

  /**
   * @notice This function tests the `setWithdrawAmount` function of the `Faucet` contract. User can withdraw increased amount
   * @dev  Refers to the hardhat test with the description 'requestTokens(): User can withdraw increased amount'
   */
  function testChangeWithdrawAmountAndRequestToken() public {
    //set the new amount with DEFAULT_DRIP_AMOUNT -2
    testChangeWithdrawAmount();
    // alice request token with the new amount
    testRequestToken();
    assertEq(holographERC20.balanceOf(alice), DEFAULT_DRIP_AMOUNT - 2);
  }

  /**
   * @notice This function tests the `setWithdrawAmount` function of the `Faucet` contract. Not owner can't adjust Withdraw Amount
   * @dev  Refers to the hardhat test with the description 'setWithdrawAmount(): User can't adjust Withdraw Amount'
   */
  function testChangeWithdrawAmountRevert() public {
    vm.prank(alice);
    vm.expectRevert(bytes(REVERT_NOT_AN_OWNER));
    faucet.setWithdrawAmount(DEFAULT_DRIP_AMOUNT - 2);
  }

  /*
   * OWNER can Withdraw funds
   */

  /**
   * @notice This function tests the `withdrawTokens` function of the `Faucet` contract. Owner can withdraw funds
   * @dev  Refers to the hardhat test with the description 'withdrawTokens()'
   */
  function testWithdrawTokens() public {
    vm.prank(deployer);
    faucet.withdrawTokens(bob, DEFAULT_DRIP_AMOUNT);
    assertEq(holographERC20.balanceOf(bob), DEFAULT_DRIP_AMOUNT);
  }

  /**
   * @notice This function tests the `withdrawTokens` function of the `Faucet` contract. Not owner can't withdraw funds
   */
  function testWithdrawTokensRevert() public {
    vm.prank(alice);
    vm.expectRevert(bytes(REVERT_NOT_AN_OWNER));
    faucet.withdrawTokens(bob, DEFAULT_DRIP_AMOUNT);
  }

  /**
   * @notice This function tests the `withdrawAllTokens` function of the `Faucet` contract. Owner can withdraw all the funds
   * @dev  Refers to the hardhat test with the description 'withdrawAllTokens()'
   */
  function testWithdrawAllTokens() public {
    vm.prank(deployer);
    faucet.withdrawAllTokens(bob);
    assertEq(holographERC20.balanceOf(bob), INITIAL_FAUCET_FUNDS);
    assertEq(holographERC20.balanceOf(address(faucet)), 0);
  }

  /**
   * @notice This function tests the `withdrawAllTokens` function of the `Faucet` contract. Not owner can't withdraw all the funds
   * @dev  Refers to the hardhat test with the description 'withdrawAllTokens()'
   */
  function testWithdrawAllTokensRevert() public {
    vm.prank(alice);
    vm.expectRevert(bytes(REVERT_NOT_AN_OWNER));
    faucet.withdrawAllTokens(bob);
  }
}
