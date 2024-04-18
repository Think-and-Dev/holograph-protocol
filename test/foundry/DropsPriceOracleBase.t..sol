// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import "../contracts/drops/DropsPriceOracleBase.sol";
import "../interfaces/IQuoterV2.sol";
import "./mocks/MockQuoterV2.sol";

contract DropsPriceOracleBaseTest is Test {
  UniswapV3Oracle public oracle;
  MockQuoterV2 public quoterV2;

  function setUp() public {
    quoterV2 = new MockQuoterV2();
    oracle = new UniswapV3Oracle();
    oracle.init();
  }

  function testInitialSetup() public {
    assertTrue(address(oracle.quoterV2()) != address(0), "QuoterV2 should be set");
  }

  function testPreventReinitialization() public {
    vm.expectRevert("HOLOGRAPH: already initialized");
    oracle.init();
  }

  function testConvertUsdToWei() public {
    // Setup: Define USDC amount
    uint256 usdAmount = 1e6; // 1 USDC in smallest units (6 decimals)

    // Mocking the expected response from quoterV2
    quoterV2.setMockedQuote(usdAmount, 0.0025 ether); // Mocked ETH amount for 1 USDC

    // Test: Convert USDC to Wei
    uint256 expectedWeiAmount = 0.0025 ether;
    uint256 actualWeiAmount = oracle.convertUsdToWei(usdAmount);

    assertEq(actualWeiAmount, expectedWeiAmount, "Conversion from USDC to wei should be accurate");
  }
}
