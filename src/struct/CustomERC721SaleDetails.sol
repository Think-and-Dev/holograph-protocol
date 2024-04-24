// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/// @notice Return value for sales details to use with front-ends
struct CustomERC721SaleDetails {
  // Synthesized status variables for sale and presale
  bool publicSaleActive;
  bool presaleActive;
  // Price for public sale
  uint256 publicSalePrice;
  // Timed sale actions for public sale
  uint256 publicSaleStart;
  // Timed sale actions for presale
  uint64 presaleStart;
  uint64 presaleEnd;
  // Merkle root (includes address, quantity, and price data for each entry)
  bytes32 presaleMerkleRoot;
  // Limit public sale to a specific number of mints per wallet
  uint256 maxSalePurchasePerAddress;
  // Information about the rest of the supply
  // Total that have been minted
  uint256 totalMinted;
  // The total supply available
  uint256 maxSupply;
}
