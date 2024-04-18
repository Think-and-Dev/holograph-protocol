// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {DropsPriceOracleBase} from "../../src/drops/oracle/DropsPriceOracleBase.sol";
import {IQuoterV2} from "../../src/interface/IQuoterV2.sol";
import {MockQuoterV2} from "./utils/MockQuoterV2.sol";

contract DropsPriceOracleBaseTest is Test {
  DropsPriceOracleBase public oracle;
  MockQuoterV2 public quoterV2;

  function setUp() public {
    quoterV2 = new MockQuoterV2();
    oracle = new DropsPriceOracleBase();

    vm.prank(oracle.getAdmin());
    oracle.setQuoter(quoterV2); // Correctly setting the quoter to the mock
    oracle.init(new bytes(0)); // Ensure initialization is proper and only done once
  }

  function testInitialSetup() public {
    // Check if the oracle's quoterV2 address is not the zero address
    assertTrue(address(oracle.quoterV2()) != address(0), "QuoterV2 should be set");
  }

  function testPreventReinitialization() public {
    // Expect a revert when calling init function again
    vm.expectRevert("HOLOGRAPH: already initialized");
    oracle.init(new bytes(0));
  }

  function testInitializationConstants() public {
    assertEq(oracle.WETH9(), 0x4200000000000000000000000000000000000006, "WETH9 address is incorrect");
    assertEq(oracle.USDC(), 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, "USDC address is incorrect");
    assertEq(oracle.poolFee(), 3000, "Pool fee is incorrect");
  }

  function testConvertUsdToWei() public {
    uint256 usdAmount = 2500000000000000; // Example amount
    uint256 expectedWeiAmount = 0.0025 ether; // Expected result
    quoterV2.setMockedQuote(expectedWeiAmount, uint160(expectedWeiAmount), 0, 0);

    uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);
    assertEq(actualWeiAmount, expectedWeiAmount, "Conversion should be accurate.");
  }

  function testConvertUsdToFuzzedWei(uint256 usdAmount) public {
    // Skip very large numbers to avoid overflows in the test
    vm.assume(usdAmount < 1e10);

    // Mocked exchange rate: 1 USDC = 0.0025 ETH
    uint256 exchangeRate = 0.0025 ether;
    uint256 expectedWeiAmount = usdAmount * exchangeRate;

    quoterV2.setMockedQuote(
      expectedWeiAmount,
      uint160(exchangeRate), // Cast to uint160
      0, // Placeholder for simplicity
      0 // Placeholder for simplicity
    );

    uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);
    assertEq(actualWeiAmount, expectedWeiAmount, "Fuzzed conversion from USDC to wei should be accurate");
  }

  function testSpecificRates() public {
    uint256 usdAmount = 100e6; // 100 USDC
    uint256[] memory testRates = new uint256[](3);
    testRates[0] = 0.0025 ether; // Given rate
    testRates[1] = 0.003 ether; // Slightly higher rate
    testRates[2] = 0.0015 ether; // Slightly lower rate

    for (uint i = 0; i < testRates.length; i++) {
      uint256 expectedWeiAmount = usdAmount * testRates[i];
      quoterV2.setMockedQuote(expectedWeiAmount, uint160(testRates[i]), 0, 0);
      uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);
      assertEq(actualWeiAmount, expectedWeiAmount, "Conversion at specific rate should be accurate");
    }
  }

  function testFuzzingWithRandomRates(uint256 usdAmount, uint256 rate) public {
    // We'll skip very high rates to avoid overflows
    vm.assume(rate < 1e18);

    // We'll also skip very high usdAmount to avoid overflows
    vm.assume(usdAmount < 1e10);

    // Mock the rate and set the quote
    uint256 expectedWeiAmount = usdAmount * rate;
    quoterV2.setMockedQuote(expectedWeiAmount, uint160(rate), 0, 0);

    // Attempt the conversion
    uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);

    // Assert that the conversion is within a reasonable margin of error
    // This margin accounts for division truncation in the contract
    uint256 margin = usdAmount / 1e12; // A small margin of error
    bool isWithinMargin = actualWeiAmount <= expectedWeiAmount + margin &&
      actualWeiAmount >= expectedWeiAmount - margin;
    assertTrue(isWithinMargin, "Conversion with random rates should be within margin of error");
  }

  function testRevertIfQuoterNotSet() public {
    // Setup oracle with a zero address for the quoter
    vm.prank(oracle.getAdmin());
    oracle.setQuoter(IQuoterV2(address(0)));

    // Expect revert when attempting to convert with no quoter set
    vm.expectRevert("Quoter not set");
    oracle.convertUsdToWei(1e6);
  }

  function testRevertIfNonAdminSetsQuoter() public {
    vm.expectRevert("HOLOGRAPH: admin only function");
    oracle.setQuoter(IQuoterV2(address(0)));
  }
}
