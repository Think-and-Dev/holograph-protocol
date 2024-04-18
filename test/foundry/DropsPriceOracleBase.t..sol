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
    // Instantiate the MockQuoterV2 contract
    quoterV2 = new MockQuoterV2();

    // Pass the mock contract address to the DropsPriceOracleBase constructor
    oracle = new DropsPriceOracleBase(quoterV2);

    // Call the init function with an empty bytes argument
    oracle.init(new bytes(0));
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

  function testConvertUsdToWei() public {
    // Define the USDC amount
    uint256 usdAmount = 2500000000000000; // 1 USDC in smallest units (6 decimals)

    // Provide the expected values to the mock's setMockedQuote function
    uint256 expectedWeiAmount = 0.0025 ether; // Mocked ETH amount for 1 USDC
    quoterV2.setMockedQuote(
      usdAmount,
      uint160(expectedWeiAmount), // Cast to uint160
      0, // Assuming this is the sqrtPriceX96After placeholder
      0 // Assuming this is the gasEstimate placeholder
    );

    // Test the conversion from USDC to Wei
    uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);

    // Assert that the actual wei amount matches the expected amount
    assertEq(actualWeiAmount, expectedWeiAmount, "Conversion from USDC to wei should be accurate");
  }
}
