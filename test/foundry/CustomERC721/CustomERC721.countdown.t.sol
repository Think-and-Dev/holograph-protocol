// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {console2} from "forge-std/console2.sol";

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Strings} from "src/library/Strings.sol";

import {DEFAULT_MAX_SUPPLY, DEFAULT_MINT_INTERVAL} from "test/foundry/CustomERC721/utils/Constants.sol";

contract CustomERC721CountdownTest is CustomERC721Fixture, ICustomERC721Errors {
  using Strings for uint256;

  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_getMintTimeCost() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) setUpPurchase {
    uint64 mintTimeCost = customErc721.getMintTimeCost();
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
  }

  function test_getCountdownEnd() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) setUpPurchase {
    uint96 countdownEnd = customErc721.getCountdownEnd();
    assertEq(countdownEnd, DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
  }

  function test_getInitialCountdownEnd() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) setUpPurchase {
    uint96 initialCountdownEnd = customErc721.getInitialCountdownEnd();
    assertEq(initialCountdownEnd, DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL, "Initial countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
  }

  function test_SubCountdown() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) setUpPurchase {
    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* -------------------------------- Purchase -------------------------------- */

    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    customErc721.purchase{value: totalCost}(1);

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mintTimeCost, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost,
      "Initial countdown end should be equal to countdown end + mint time cost"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_SubCountdownMultiplePurchase() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) setUpPurchase {
    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
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
      DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mintTimeCost * amountToPurchase,
      "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_CantExceedMaxSupply() public setupTestCustomERC21(2000) setUpPurchase {
    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 2000 * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");

    /* ----------------------- Purchases to the max supply ---------------------- */
    _purchaseAllSupply();

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(
      countdownEnd,
      customErc721.maxSupply() * DEFAULT_MINT_INTERVAL - mintTimeCost * customErc721.maxSupply(),
      "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertEq(
      initialCountdownEnd, countdownEnd + mintTimeCost * customErc721.maxSupply(),
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertEq(countdownEnd, 0, "Countdown end should be 0");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
    assertEq(customErc721.totalMinted() * mintTimeCost, initialCountdownEnd, "Max supply not reached");

    /* ------------------------- Check mint another one ------------------------- */

    vm.startPrank(alice);
    vm.deal(alice, totalCost);
    vm.expectRevert(abi.encodeWithSelector(Purchase_CountdownCompleted.selector));
    customErc721.purchase{value: totalCost}(1);
    vm.stopPrank();
  }

  /* -------------------------------------------------------------------------- */
  /*                                   Fuzzing                                  */
  /* -------------------------------------------------------------------------- */

  function test_Invariant_CountdownSupplySingleCall(
    uint256 amountToPurchase
  ) public setupTestCustomERC21(fuzzingMaxSupply) setUpPurchase {
    // Bounds the amount to purchase between 1 and the max supply
    /// @dev using bound instead of vm.assume prevent the fuzzing from calling the test with useless values
    ///      Every values is used but bounded
    amountToPurchase = bound(amountToPurchase, 1, customErc721.maxSupply());

    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, fuzzingMaxSupply * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
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
      fuzzingMaxSupply * DEFAULT_MINT_INTERVAL - mintTimeCost * amountToPurchase,
      "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_Invariant_CountdownSupplyMultiple(
    uint256 amountToPurchase
  ) public setupTestCustomERC21(fuzzingMaxSupply) setUpPurchase {
    // Bounds the amount to purchase between 1 and the max supply
    /// @dev using bound instead of vm.assume prevent the fuzzing from calling the test with useless values
    ///      Every values is used but bounded
    amountToPurchase = bound(amountToPurchase, 1, customErc721.maxSupply());

    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, fuzzingMaxSupply * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
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
      fuzzingMaxSupply * DEFAULT_MINT_INTERVAL - mintTimeCost * amountToPurchase,
      "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(
      initialCountdownEnd == countdownEnd + mintTimeCost * amountToPurchase,
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
  }

  function test_Invariant_CantExceedMaxSupply(uint256 forceAmount) public setupTestCustomERC21(100) setUpPurchase {
    forceAmount = bound(forceAmount, 1, customErc721.maxSupply());

    /* -------------------------- Initialization checks ------------------------- */
    (uint64 mintTimeCost, uint96 countdownEnd, uint96 initialCountdownEnd, , ) = customErc721.config();
    assertEq(countdownEnd, 100 * DEFAULT_MINT_INTERVAL, "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL");
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertTrue(initialCountdownEnd == countdownEnd, "Initial countdown end should be equal to countdown end");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
    
    /* ----------------------- Purchases to the max supply ---------------------- */
    _purchaseAllSupply();

    /* ----------------------------- Countdown checks ---------------------------- */
    (mintTimeCost, countdownEnd, initialCountdownEnd, , ) = customErc721.config();
    assertEq(
      countdownEnd,
      customErc721.maxSupply() * DEFAULT_MINT_INTERVAL - mintTimeCost * customErc721.maxSupply(),
      "Countdown end should be DEFAULT_MAX_SUPPLY * DEFAULT_MINT_INTERVAL - mint time cost * purchased amount"
    );
    assertEq(mintTimeCost, DEFAULT_MINT_INTERVAL, "Mint time cost should be DEFAULT_MINT_INTERVAL");
    assertEq(
      initialCountdownEnd, countdownEnd + mintTimeCost * customErc721.maxSupply(),
      "Initial countdown end should be equal to countdown end + mint time cost * purchased amount"
    );
    assertEq(countdownEnd, 0, "Countdown end should be 0");
    assertTrue(countdownEnd % mintTimeCost == 0, "Countdown end should be divisible by mint time cost");
    assertEq(customErc721.totalMinted() * mintTimeCost, initialCountdownEnd, "Max supply not reached");

    /* -------------------------------------------------------------------------- */
    /*                       Check mint more than max supply                      */
    /* -------------------------------------------------------------------------- */

    for (uint256 i = 0; i < forceAmount; i++) {
      address user = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
      vm.startPrank(address(user));
      vm.deal(address(user), totalCost);
      vm.expectRevert(abi.encodeWithSelector(Purchase_CountdownCompleted.selector));
      customErc721.purchase{value: totalCost}(1);
      vm.stopPrank();
    }
  }
}
