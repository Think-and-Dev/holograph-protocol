// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {CustomERC721} from "src/token/CustomERC721.sol";

import {Constants} from "test/foundry/utils/Constants.sol";

contract CustomERC721Fixture {
    CustomERC721 public customErc721;

    constructor() {
    }

    function setup() public virtual {
        customErc721 = new CustomERC721();
    }

    function _enablePurchase() internal {
        customErc721.setSaleConfiguration(
            Constants.getPublicMintPrice(),
            Constants.getMaxSalePurchasePerAddress(),
            uint64(block.timestamp),
            Constants.getPublicSaleEnd(),
            Constants.getPresaleStart(),
            Constants.getPresaleEnd(),
            Constants.getPresaleMerkleRoot()
        );
    }
}
