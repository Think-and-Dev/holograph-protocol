// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract DropPriceOracleMock {

  constructor() {}

  function convertUsdToWei(uint256 usdAmount) external view returns (uint256 weiAmount) {
    return usdAmount * 3000 * 10 ** 18;
  }
}
