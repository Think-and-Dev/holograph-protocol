// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Utils} from "test/foundry/utils/Utils.sol";

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Strings} from "src/library/Strings.sol";

contract CustomERC721CountdownTest is CustomERC721Fixture, ICustomERC721Errors {
  using Strings for uint256;

  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_SubCountdown() public setupTestCustomERC21(4e6) setUpPurchase {
    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 2200000000, "Countdown end should be 2200000000");
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* -------------------------------- Purchase -------------------------------- */

    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    customErc721.purchase{value: totalCost}(1);

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 2200000000 - mintTimeCost, "Countdown end should be 2200000000 - mint time cost");
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost,
      "Initial countdown end should be equal to countdown end + mint time cost"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_SubCountdownMultiplePurchase() public setupTestCustomERC21(4e6) setUpPurchase {
    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 2200000000, "Countdown end should be 2200000000");
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* -------------------------------- Purchase -------------------------------- */
    uint256 amountToPurchase = 10;
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost * amountToPurchase);
    customErc721.purchase{value: totalCost * amountToPurchase}(amountToPurchase);

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(
      countdownEnd,
      2200000000 - mintTimeCost * amountToPurchase,
      "Countdown end should be 2200000000 - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_Invariant_CountdownSupplySingleCall(
    uint256 amountToPurchase
  ) public setupTestCustomERC21(10) setUpPurchase {
    // Bounds the amount to purchase between 1 and the max supply
    /// @dev using bound instead of vm.assume prevent the fuzzing from calling the test with useless values
    ///      Every values is used but bounded
    amountToPurchase = bound(amountToPurchase, 1, customErc721.maxSupply());

    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 10 * 550, "Countdown end should be 2200000000");
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* -------------------------------- Purchase -------------------------------- */

    vm.startPrank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost * amountToPurchase);
    customErc721.purchase{value: totalCost * amountToPurchase}(amountToPurchase);
    vm.stopPrank();

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(
      countdownEnd,
      10 * 550 - mintTimeCost * amountToPurchase,
      "Countdown end should be 2200000000 - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_Invariant_CountdownSupplyMultiple(
    uint256 amountToPurchase
  ) public setupTestCustomERC21(10) setUpPurchase {
    // Bounds the amount to purchase between 1 and the max supply
    /// @dev using bound instead of vm.assume prevent the fuzzing from calling the test with useless values
    ///      Every values is used but bounded
    amountToPurchase = bound(amountToPurchase, 1, customErc721.maxSupply());

    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 10 * 550, "Countdown end should be 2200000000");
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* -------------------------------- Purchase -------------------------------- */

    for (uint256 i = 0; i < amountToPurchase; i++) {
      address user = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
      vm.startPrank(address(user));
      vm.deal(address(user), totalCost);
      customErc721.purchase{value: totalCost}(1);
      vm.stopPrank();
    }

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(
      countdownEnd,
      10 * 550 - mintTimeCost * amountToPurchase,
      "Countdown end should be 2200000000 - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, 550, "Mint time cost should be 550");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }
}
