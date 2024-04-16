// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";
import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {console2} from "forge-std/console2.sol";

import {Utils} from "test/foundry/utils/Utils.sol";
import {Constants} from "test/foundry/utils/Constants.sol";

import {ICustomERC721} from "src/interface/ICustomERC721.sol";
import {HolographerInterface} from "src/interface/HolographerInterface.sol";
import {HolographERC721Interface} from "src/interface/HolographERC721Interface.sol";

import {HolographERC721} from "src/enforcer/HolographERC721.sol";
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

  function test_PurchaseWithoutLazyMint() public setupTestCustomERC21(10) {
    /* ------------------------------- Test setup ------------------------------- */

    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();

    /* -------------------------------- Purchase -------------------------------- */

    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    uint256 tokenId = customErc721.purchase{value: totalCost}(1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Incorrect owner for newly minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);

    /* ----------------------------- Check tokenURI ----------------------------- */

    // TokenURI call should revert because the metadata of the batch has not been set yet (need to call lazyMint before)
    vm.expectRevert(abi.encodeWithSelector(BatchMintInvalidTokenId.selector, tokenId));
    customErc721.tokenURI(tokenId);
    vm.expectRevert(abi.encodeWithSelector(BatchMintInvalidTokenId.selector, 0));
    customErc721.tokenURI(0);
  }


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
    uint256 batchId = customErc721.lazyMint(
      firstBatchAmount,
      Constants.getPlaceholderUri(),
      abi.encode(encryptedUri, provenanceHash)
    );
    assertEq(batchId, chainPrepend + firstBatchAmount);

    /* --------------------------- Check onchain data --------------------------- */

    bytes memory encryptedData = customErc721.encryptedData(batchId);
    assertEq(encryptedData, abi.encode(encryptedUri, provenanceHash));

    /* -------------------------------- Purchase -------------------------------- */

    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    uint256 tokenId = customErc721.purchase{value: totalCost}(1);
    assertEq(tokenId, chainPrepend);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(tokenId) == address(TEST_ACCOUNT), "Incorrect owner for newly minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);

    /* ----------------------- Check tokenURI and BaseURI ----------------------- */
    assertEq(customErc721.tokenURI(tokenId), string(abi.encodePacked(Constants.getPlaceholderUri(), tokenId.toString())));
    assertEq(customErc721.tokenURI(tokenId), string(abi.encodePacked("https://url.com/not-revealed/", tokenId.toString())));

    string memory baseUri = customErc721.baseURI(tokenId);
    assertEq(baseUri, Constants.getPlaceholderUri());

    /* --------------------------------- Reveal --------------------------------- */

    vm.prank(DEFAULT_OWNER_ADDRESS);
    customErc721.reveal(0, Constants.getEncryptDecryptKey());

    /* ------------------------- Check revealed tokenURI ------------------------ */
    assertEq(customErc721.tokenURI(tokenId), string(abi.encodePacked(Constants.getBaseUri(), tokenId.toString())));
    assertEq(customErc721.tokenURI(tokenId), string(abi.encodePacked("https://url.com/uri/", tokenId.toString())));
  }

  // TODO: Fix this test (It's reverting but not with the matching correct price in the error message)
  function test_PurchaseWrongPrice() public setupTestCustomERC21(10) {
    /* ------------------------------- Test setup ------------------------------- */

    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();

    /* -------------------------------- Purchase -------------------------------- */

    uint256 amount = 1;
    uint104 price = usd100;
    uint256 holographFee = customErc721.getHolographFeeUsd(amount);
    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost - 1);
    vm.expectRevert(abi.encodeWithSelector(ICustomERC721.Purchase_WrongPrice.selector, uint256(price + holographFee)));

    customErc721.purchase{value: totalCost - 1}(amount);
  }

  function test_GetContractURI() public setupTestCustomERC21(1) {
    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();
    string memory expectedURI = "https://example.com/metadata.json";

    assertEq(customErc721.contractURI(), expectedURI);
  }

  function test_SetContractURI() public setupTestCustomERC21(1) {
    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();

    string memory expectedURI = "https://example.com/new-metadata.json";

    vm.prank(DEFAULT_OWNER_ADDRESS);
    vm.recordLogs();

    customErc721.setContractURI(expectedURI);
    assertEq(customErc721.contractURI(), expectedURI);

    Vm.Log[] memory entries = vm.getRecordedLogs();
    assertEq(entries.length, 1);
    assertEq(entries[0].topics[0], keccak256("ContractURIUpdated(string,string)"));
    assertEq(abi.decode(entries[0].data, (string)), "https://example.com/metadata.json");

    // TODO: Figure out how to get the second parameter from the event
    // assertEq(abi.decode(entries[0].data, (string)), "https://example.com/new-metadata.json");
  }

  function test_GetSourceChainPrepend() public setupTestCustomERC21(1) {
    HolographerInterface holographerInterface = HolographerInterface(address(customErc721));

    // address sourceContractAddress = holographerInterface.getSourceContract();
    // uint32 currentChain = HolographInterface(HolographerInterface(payable(address(this))).getHolograph())
    //   .getHolographChainId();

    (uint256 totalCost, HolographERC721 erc721Enforcer, address sourceContractAddress, uint256 nativePrice) = super
      .setUpPurchase();

    // Calls must come from the source contract via the onlySource modifier
    vm.prank(sourceContractAddress);
    uint256 sourceChainPrepend = erc721Enforcer.sourceGetChainPrepend();

    console.log("sourceChainPrepend", sourceChainPrepend);
  }
}
