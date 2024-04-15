// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";

import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {console2} from "forge-std/console2.sol";

import {Utils} from "test/foundry/utils/Utils.sol";
import {Constants} from "test/foundry/utils/Constants.sol";

import {HolographERC721} from "src/enforcer/HolographERC721.sol";

contract CustomERC721Test is CustomERC721Fixture, ICustomERC721Errors {
  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_DeployHolographCustomERC721() public {
    super.deployAndSetupProtocol();

    assertEq(customErc721.version(), 1);
  }

  function test_PurchaseWithoutLazyMint() public setupTestCustomERC21(10) {
    /* ------------------------------- Test setup ------------------------------- */

    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();

    /* -------------------------------- Purchase -------------------------------- */
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    uint256 tokenId = customErc721.purchase{value: totalCost}(1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Owner is wrong for new minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);

    /* ----------------------------- Check tokenURI ----------------------------- */

    // TokenURI call should revert because the metadata of the batch has not been set yet (need to call lazyMint before)
    vm.expectRevert(abi.encodeWithSelector(BatchMintInvalidTokenId.selector, tokenId));
    customErc721.tokenURI(tokenId);
    vm.expectRevert(abi.encodeWithSelector(BatchMintInvalidTokenId.selector, 0));
    customErc721.tokenURI(0);
  }

  /**
   * TODO: Fix nextTokenToLazyMint
   */
  function test_PurchaseWithLazyMint() public setupTestCustomERC21(10) {
    /* ------------------------------- Test setup ------------------------------- */

    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();
    uint256 firstBatchAmount = 5;

    /* -------------------------------- Lazy mint ------------------------------- */

    // Compute the encrypted URI using the secret key
    bytes memory encryptedUri = customErc721.encryptDecrypt(Constants.getBaseUri(), Constants.getEncryptDecryptKey());
    // Compute the provenance hash
    bytes32 provenanceHash = keccak256(
      abi.encodePacked(Constants.getBaseUri(), Constants.getEncryptDecryptKey(), block.chainid)
    );

    vm.prank(DEFAULT_OWNER_ADDRESS);
    customErc721.lazyMint(firstBatchAmount, Constants.getPlaceholderUri(), abi.encode(encryptedUri, provenanceHash));

    /* --------------------------- Check onchain data --------------------------- */

    bytes memory encryptedData = customErc721.encryptedData(firstBatchAmount);
    assertEq(encryptedData, abi.encode(encryptedUri, provenanceHash));

    /* -------------------------------- Purchase -------------------------------- */
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    uint256 tokenId = customErc721.purchase{value: totalCost}(1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Owner is wrong for new minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);

    /* ----------------------- Check tokenURI and BaseURI ----------------------- */
    assertEq(customErc721.tokenURI(0), string(abi.encodePacked(Constants.getPlaceholderUri(), "0")));
    assertEq(customErc721.tokenURI(0), "https://url.com/not_revealed/0");

    string memory baseUri = customErc721.baseURI(0);
    assertEq(baseUri, Constants.getPlaceholderUri());

    /* --------------------------------- Reveal --------------------------------- */
    vm.prank(DEFAULT_OWNER_ADDRESS);
    customErc721.reveal(0, Constants.getEncryptDecryptKey());

    /* ------------------------- Check revealed tokenURI ------------------------ */
    assertEq(customErc721.tokenURI(0), string(abi.encodePacked(Constants.getBaseUri(), "0")));
    assertEq(customErc721.tokenURI(0), "https://url.com/uri/0");
  }
}
