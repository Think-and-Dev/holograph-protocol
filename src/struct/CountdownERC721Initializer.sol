// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {CustomERC721SalesConfiguration} from "src/struct/CustomERC721SalesConfiguration.sol";

/// @title A struct for initializing a CountdownERC721 contract
/// @dev This struct is used during the deployment of a CountdownERC721 to set initial configuration parameters.
/// @param description The description of the token.
/// @param startDate The maximum start date
/// @param initialMaxSupply The maximum initial supply.
/// @param mintInterval The maximum interval between mints
/// @param initialOwner The user that owns the contract, can mint tokens, receives royalty and sales payouts, and can update the base URL if needed.
/// @param initialMinter The user that is allowed to mint tokens on behalf of others, typically for offchain purchasers.
/// @param fundsRecipient The wallet or user that receives funds from token sales.
/// @param contractURI The URI for the contract metadata.
/// @param salesConfiguration The initial sales configuration settings, defining how tokens are sold.
struct CountdownERC721Initializer {
  string description; // The description of the token.
  string imageURI; // The URI for the image associated with this contract.
  string externalLink; // The URI for the external metadata associated with this contract.
  string encryptedMediaURI; // The URI for the encrypted media associated with this contract.
  uint40 startDate; // The starting date for the countdown
  uint32 initialMaxSupply; // The theoretical initial maximum supply of tokens at the start of the countdown.
  uint24 mintInterval; // The interval between possible mints,
  address initialOwner; // Address of the initial owner, who has administrative privileges.
  address initialMinter; // Address of the initial minter, who can mint new tokens for those who purchase offchain.
  address payable fundsRecipient; // Address of the recipient for funds gathered from sales.
  string contractURI; // URI for the metadata associated with this contract.
  CustomERC721SalesConfiguration salesConfiguration; // Configuration of sales settings for this contract.
}
