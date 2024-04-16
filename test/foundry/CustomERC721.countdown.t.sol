// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Utils} from "test/foundry/utils/Utils.sol";
import {Strings} from "src/library/Strings.sol";

contract CustomERC721Test is CustomERC721Fixture, ICustomERC721Errors {
  using Strings for uint256;

  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_DeployHolographCustomERC721() public {
    super.deployAndSetupProtocol();
    assertEq(customErc721.version(), 1);
  }

  function test_PurchaseWithoutLazyMint() public setupTestCustomERC21(10) {}
}
