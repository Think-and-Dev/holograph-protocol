// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CountdownERC721Fixture} from "test/foundry/fixtures/CountdownERC721Fixture.t.sol";

import {Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {MetadataParams} from "src/struct/MetadataParams.sol";

import {DEFAULT_BASE_URI, DEFAULT_PLACEHOLDER_URI, DEFAULT_ENCRYPT_DECRYPT_KEY, DEFAULT_MAX_SUPPLY} from "test/foundry/CountdownERC721/utils/Constants.sol";

import {ICountdownERC721} from "src/interface/ICountdownERC721.sol";
import {Strings} from "src/library/Strings.sol";
import {NFTMetadataRenderer} from "src/library/NFTMetadataRenderer.sol";

contract CountdownERC721PurchaseTest is CountdownERC721Fixture, ICustomERC721Errors {
  using Strings for uint256;

  constructor() {}

  function setUp() public override {
    super.setUp();
  }

  function test_tokenUri() public setupTestCountdownErc721(DEFAULT_MAX_SUPPLY) setUpPurchase {
    /* -------------------------------- Purchase -------------------------------- */
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), mintEthPrice);
    uint256 tokenId = countdownErc721.purchase{value: mintEthPrice}(1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Incorrect owner for newly minted token");
    assertEq(address(sourceContractAddress).balance, mintEthPrice);

    /* ----------------------------- Check tokenURI ----------------------------- */

    // Expected token URI for newly minted token
    // {
    //     "name": "Contract Name 115792089183396302089269705419353877679230723318366275194376439045705909141505",
    //     "description": "Description of the token",
    //     "external_url": "https://example.com",
    //     "image": ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png",
    //     "encrypted_media_url": "",
    //     "decryption_key": "",
    //     "hash": "",
    //     "decrypted_media_url": "",
    //     "animation_url": "",
    //     "properties": {
    //         "number": 115792089183396302089269705419353877679230723318366275194376439045705909141505,
    //         "name": "Contract Name"
    //     }
    // }
    string memory expectedTokenUri = NFTMetadataRenderer.encodeMetadataJSON(
      '{"name": "Contract Name 115792089183396302089269705419353877679230723318366275194376439045705909141505", "description": "Description of the token", "external_url": "https://example.com", "image": "ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png", "encrypted_media_url": "", "decryption_key": "", "hash": "", "decrypted_media_url": "", "animation_url": "", "properties": {"number": 115792089183396302089269705419353877679230723318366275194376439045705909141505, "name": "Contract Name"}}'
    );

    string memory base64TokenUri = countdownErc721.tokenURI(tokenId);

    console.log("base64TokenUri: ", base64TokenUri);

    assertEq(base64TokenUri, expectedTokenUri, "Incorrect tokenURI for newly minted token");
  }

  function test_setMetadataParams() public setupTestCountdownErc721(DEFAULT_MAX_SUPPLY) setUpPurchase {
    /* -------------------------------- Purchase -------------------------------- */
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    uint256 tokenId = countdownErc721.purchase{value: totalCost}(1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Incorrect owner for newly minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);

    /* ----------------------------- Check tokenURI ----------------------------- */

    // assertEq(base64TokenUri, expectedTokenUri, "Incorrect tokenURI for newly minted token");

    /* ----------------------------- Set Metadata Params ----------------------------- */

    // Expected token URI for newly minted token
    // {
    //     "name": "Contract Name 115792089183396302089269705419353877679230723318366275194376439045705909141505",
    //     "description": "Description of the token",
    //     "external_url": "https://example.com",
    //     "image": ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png",
    //     "encrypted_media_url": "ar://encryptedMediaUriHere",
    //     "decryption_key": "decryptionKeyHere",
    //     "hash": "uniqueHashHere",
    //     "decrypted_media_url": "ar://decryptedMediaUriHere",
    //     "animation_url": "ar://animationUriHere",
    //     "properties": {
    //         "number": 115792089183396302089269705419353877679230723318366275194376439045705909141505,
    //         "name": "Contract Name"
    //     }
    // }
    string memory expectedTokenUri = NFTMetadataRenderer.encodeMetadataJSON(
      '{"name": "Contract Name 115792089183396302089269705419353877679230723318366275194376439045705909141505", "description": "Description of the token", "external_url": "https://example.com", "image": "ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png", "encrypted_media_url": "ar://encryptedMediaUriHere", "decryption_key": "decryptionKeyHere", "hash": "uniqueHashHere", "decrypted_media_url": "ar://decryptedMediaUriHere", "animation_url": "ar://animationUriHere", "properties": {"number": 115792089183396302089269705419353877679230723318366275194376439045705909141505, "name": "Contract Name"}}'
    );

    // NOTE: The metadata params struct needs to have all it's values set,
    //       but the setMetadataParams function only sets the imageURI, externalUrl,
    //       encryptedMediaUrl, decryptionKey, hash, and decryptedMediaUrl
    MetadataParams memory metadataParams = MetadataParams({
      name: "Contract Name", // NOT USED
      description: "Description of the token", // NOT USED
      tokenOfEdition: 0, // NOT USED
      editionSize: 0, // NOT USED
      imageURI: "ar://o8eyC27OuSZF0z-zIen5NTjJOKTzOQzKJzIe3F7Lmg0/1.png",
      animationURI: "ar://animationUriHere",
      externalUrl: "https://example.com",
      encryptedMediaUrl: "ar://encryptedMediaUriHere",
      decryptionKey: "decryptionKeyHere",
      hash: "uniqueHashHere",
      decryptedMediaUrl: "ar://decryptedMediaUriHere"
    });

    vm.prank(address(DEFAULT_OWNER_ADDRESS));
    countdownErc721.setMetadataParams(metadataParams);

    string memory base64TokenUri = countdownErc721.tokenURI(tokenId);
    console.log("base64TokenUri: ", base64TokenUri);

    assertEq(base64TokenUri, expectedTokenUri, "Incorrect tokenURI for newly minted token");
  }
}
