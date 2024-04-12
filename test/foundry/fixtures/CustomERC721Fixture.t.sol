// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {Test} from "forge-std/Test.sol";

import {CustomERC721} from "src/token/CustomERC721.sol";

import {Constants} from "test/foundry/utils/Constants.sol";

contract CustomERC721Fixture is Test {
    CustomERC721 public customErc721;

    address public initialOwner = address(uint160(uint256(keccak256("initialOwner"))));
    address public fundsRecipient = address(uint160(uint256(keccak256("fundsRecipient"))));

    constructor() {
    }

    function setUp() public virtual {
        customErc721 = new CustomERC721();
        customErc721.init(abi.encode(
            initialOwner,
            fundsRecipient,
            2_000_000,
            1000,
            abi.encode(
            Constants.getPublicMintPrice(),
            Constants.getMaxSalePurchasePerAddress(),
            uint64(block.timestamp),
            Constants.getPublicSaleEnd(),
            Constants.getPresaleStart(),
            Constants.getPresaleEnd(),
            Constants.getPresaleMerkleRoot()
            )
        ));
    }

    function _enablePurchase() internal {   
        vm.prank(initialOwner);
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
