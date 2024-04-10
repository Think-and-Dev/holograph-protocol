// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {SalesConfiguration} from "../drops/struct/SalesConfiguration.sol";

/// @param initialOwner User that owns and can mint the edition, gets royalty and sales payouts and can update the base url if needed.
/// @param fundsRecipient Wallet/user that receives funds from sale
/// @param royaltyBPS BPS of the royalty set on the contract. Can be 0 for no royalty.
/// @param salesConfiguration The initial SalesConfiguration
struct CustomERC721Initializer {
  address initialOwner;
  address payable fundsRecipient;
  uint64 editionSize;
  uint16 royaltyBPS;
  SalesConfiguration salesConfiguration;
}
