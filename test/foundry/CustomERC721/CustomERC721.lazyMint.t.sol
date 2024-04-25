// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {console2} from "forge-std/console2.sol";

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Strings} from "src/library/Strings.sol";

import {DEFAULT_MAX_SUPPLY, DEFAULT_MINT_INTERVAL} from "test/foundry/CustomERC721/utils/Constants.sol";

contract CustomERC721LazyMintTest is CustomERC721Fixture, ICustomERC721Errors {
  using Strings for uint256;

  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_lazyMint() public setupTestCustomERC21(DEFAULT_MAX_SUPPLY) {
    assertEq(customErc721.encryptedData(DEFAULT_MAX_SUPPLY/2), "", "Encrypted data should be empty");
  }

}
