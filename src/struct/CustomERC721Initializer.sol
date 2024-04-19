// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {SalesConfiguration} from "../drops/struct/SalesConfiguration.sol";
import {LazyMintConfiguration} from "../drops/struct/LazyMintConfiguration.sol";

/// @param initialOwner User that owns and can mint the edition, gets royalty and sales payouts and can update the base url if needed.
/// @param fundsRecipient Wallet/user that receives funds from sale
/// @param mintTimeCost The time to subtract from the countdownEnd on each mint
/// @param countdownEnd The countdown end time
/// @param royaltyBPS BPS of the royalty set on the contract. Can be 0 for no royalty.
/// @param salesConfiguration The initial SalesConfiguration
/// @param lazyMintsConfigurations The initial Lazy mints configurations
struct CustomERC721Initializer {
  uint64 mintTimeCost;
  uint96 countdownEnd;
  address initialOwner;
  address payable fundsRecipient;
  string contractURI;
  uint16 royaltyBPS;
  SalesConfiguration salesConfiguration;
  LazyMintConfiguration[] lazyMintsConfigurations;
}
