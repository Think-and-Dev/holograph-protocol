// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {CustomERC721} from "./../../src/token/CustomERC721.sol";

contract CustomERC721Test is Test {
    CustomERC721 public customErc721;

    constructor() {
        customErc721 = new CustomERC721();
    }

    function testPurchase() public {
        customErc721.purchase(
            
        );
    }
}
