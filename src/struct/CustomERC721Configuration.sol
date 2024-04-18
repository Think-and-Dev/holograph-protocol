// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/// @notice General configuration for NFT Minting and bookkeeping
struct CustomERC721Configuration {
  /// @dev The time to subtract from the countdownEnd on each mint
  uint64 mintTimeCost;
  /// @dev The current countdown time
  uint96 countdownEnd;
  /// @dev The initial countdown end time
  uint96 initialCountdownEnd;
  /// @dev Royalty amount in bps (uint224+16 = 240)
  uint160 royaltyBPS;
  /// @dev Funds recipient for sale (new slot, uint160)
  address payable fundsRecipient;
}
