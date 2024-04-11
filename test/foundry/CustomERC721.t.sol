// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {CustomERC721} from "src/token/CustomERC721.sol";

contract CustomERC721Test is CustomERC721Fixture, ICustomERC721Errors, Test {

    constructor() {
    }

    function setup() public override {
        super.setup();
        super._enablePurchase();
    }

    function testFullFlow() public {
        // Expect no token with id 0
        vm.expectRevert(abi.encodeWithSelector(BatchMintInvalidTokenId.selector, 0));
        customErc721.tokenURI(0);

        // Mint token with id 1
        customErc721.purchase{value: 1}(1);
    }
}
