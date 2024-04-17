// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Admin} from "../../abstract/Admin.sol";
import {Initializable} from "../../abstract/Initializable.sol";

// import {IQuotorV2} from "

contract UniswapV3Oracle is Admin, Initializable {
  IQuoterV2 public immutable quoterV2;

  address public constant WETH9 = 0x4200000000000000000000000000000000000006;
  address public constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

  // Set the pool fee to 0.3%. (this is the lowest option)
  uint24 public constant poolFee = 3000;

  /**
   * @dev Constructor is left empty and init is used instead
   */
  constructor() {}

  /**
   * @notice Used internally to initialize the contract instead of through a constructor
   * @dev This function is called by the deployer/factory when creating a contract
   */
  function init(bytes memory) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    assembly {
      sstore(_adminSlot, origin())
    }
    _setInitialized();
    return Initializable.init.selector;
  }

  /**
   * @notice Converts USDC value to native gas token value in wei
   * @dev It is important to note that different USD stablecoins use different decimal places.
   * @param usdAmount in USDC (6 decimal places)
   */
  function convertUsdToWei(uint256 usdAmount) external pure returns (uint256 weiAmount) {
    IQuoterV2.QuoteExactOutputSingleParams memory params = IQuoterV2.QuoteExactOutputSingleParams({
      tokenIn: WETH9, // WETH address
      tokenOut: USDC, // USDC address
      fee: poolFee, // Representing 0.3% pool fee
      recipient: msg.sender, // Doesn't matter as this is only used to get the exchange rate without swap
      amount: usdAmount, // USDC (USDC has 6 decimals)
      sqrtPriceLimitX96: 0 // No specific price limit
    });

    (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate) = quoter
      .quoteExactOutputSingle(params);

    return amountIn; // this is the amount in wei to convert to the USDC value
  }
}
