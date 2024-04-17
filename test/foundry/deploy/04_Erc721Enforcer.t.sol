// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";

import {HolographERC721} from "../../../src/enforcer/HolographERC721.sol";
import {SampleERC721} from "../../../src/token/SampleERC721.sol";
import {MockERC721Receiver} from "../../../src/mock/MockERC721Receiver.sol";
import {Constants} from "../utils/Constants.sol";

contract Erc721Enforcer is Test {

  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC721 holographERC721;
  SampleERC721 sampleERC721;
  MockERC721Receiver mockERC721Receiver;
  address deployer = vm.addr(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
  address alice = vm.addr(1);
  address bob = vm.addr(2);
  address charlie = vm.addr(3);

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    holographERC721 = HolographERC721(payable(0x846Af4c87F5Af1F303E5a5D215D83A611b08069c));
    sampleERC721 = SampleERC721(payable(0x846Af4c87F5Af1F303E5a5D215D83A611b08069c));
    mockERC721Receiver = MockERC721Receiver(Constants.getMockERC721Receiver());
  }

  /*
   * CHECK INTERFACES
   */

  function testUntilDeployBalanceOf() public {
    bytes4 selector = holographERC721.balanceOf.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployOwnerOf() public {
    bytes4 selector = holographERC721.ownerOf.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeploySafeTransferFrom() public {
    bytes4 selector = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeploySafeTransferFromWithBytes() public {
    bytes4 selector = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployTransferFrom() public {
    bytes4 selector = bytes4(keccak256("transferFrom(address,address,uint256)"));
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployApprove() public {
    bytes4 selector = holographERC721.approve.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeploySetApprovalForAll() public {
    bytes4 selector = holographERC721.setApprovalForAll.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployGetApproved() public {
    bytes4 selector = holographERC721.getApproved.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployIsApprovedForAll() public {
    bytes4 selector = holographERC721.isApprovedForAll.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployInterfaceSupported() public {
    bytes4 computedId = bytes4(
      keccak256("balanceOf(address)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("isApprovedForAll(address,address)")
    );
    assertTrue(holographERC721.supportsInterface(computedId));
  }

  // ERC721Enumerable

  function testUntilDeployTotalSupply() public {
    bytes4 selector = holographERC721.totalSupply.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployTokenByIndex() public {
    bytes4 selector = holographERC721.tokenByIndex.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployTokenOfOwnerByIndex() public {
    bytes4 selector = holographERC721.tokenOfOwnerByIndex.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployInterfaceSupportedEnumerable() public {
    bytes4 computedId = bytes4(
      keccak256("totalSupply()") ^
        keccak256("tokenByIndex(uint256)") ^
        keccak256("tokenOfOwnerByIndex(address,uint256)")
    );
    assertTrue(holographERC721.supportsInterface(computedId));
  }

  // ERC721Metadata

  function testUntilDeployName() public {
    bytes4 selector = holographERC721.name.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeploySymbol() public {
    bytes4 selector = holographERC721.symbol.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployTokenURI() public {
    bytes4 selector = holographERC721.tokenURI.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployInterfaceSupportedMetadata() public {
    bytes4 computedId = bytes4(keccak256("name()") ^ keccak256("symbol()") ^ keccak256("tokenURI(uint256)"));
    assertTrue(holographERC721.supportsInterface(computedId));
  }

  // ERC721TokenReceiver

  function testUntilDeployOnERC721Received() public {
    bytes4 selector = holographERC721.onERC721Received.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployInterfaceSupportedReceiver() public {
    bytes4 computedId = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    assertTrue(holographERC721.supportsInterface(computedId));
  }

  // CollectionURI

  function testUntilDeployCollectionURI() public {
    bytes4 selector = holographERC721.contractURI.selector;
    assertTrue(holographERC721.supportsInterface(selector));
  }

  function testUntilDeployInterfaceSupportedCollectionURI() public {
    bytes4 computedId = bytes4(keccak256("contractURI()"));
    assertTrue(holographERC721.supportsInterface(computedId));
  }

  // Test Initializer

  function testReinitializationHolographer() public {
    bytes memory initData = abi.encodePacked(address(0));
    vm.expectRevert("HOLOGRAPHER: already initialized");
    holographERC721.init(initData);
  }

  // check why this is failing
  // function testReinitializationSample() public {
  //   bytes memory initData = abi.encode(
  //     address(this),
  //     "Another Title",
  //     "SMPL2",
  //     uint16(500),
  //     uint256(5000),
  //     false,
  //     bytes("new data")
  //   );
  //   vm.expectRevert("ERC721: already initialized");
  //   sampleERC721.init(initData);
  // }

  // Test ERC721Metadata

  function testName() public {
    assertEq(holographERC721.name(), "Sample ERC721 Contract (localhost)");
  }

  function testSymbol() public {
    assertEq(holographERC721.symbol(), "SMPLR");
  }

  // TODO: find a way to autogenerate the base64 string
  function testContractURI() public {
    string memory expectedURI = "data:application/json;base64,eyJuYW1lIjoiU2FtcGxlIEVSQzcyMSBDb250cmFjdCAobG9jYWxob3N0KSIsImRlc2NyaXB0aW9uIjoiU2FtcGxlIEVSQzcyMSBDb250cmFjdCAobG9jYWxob3N0KSIsImltYWdlIjoiIiwiZXh0ZXJuYWxfbGluayI6IiIsInNlbGxlcl9mZWVfYmFzaXNfcG9pbnRzIjoxMDAwLCJmZWVfcmVjaXBpZW50IjoiMHg4NDZhZjRjODdmNWFmMWYzMDNlNWE1ZDIxNWQ4M2E2MTFiMDgwNjljIn0";
    assertEq(holographERC721.contractURI(), expectedURI, "The contract URI does not match.");
  }

  // Mint ERC721 NFTs

  // should have a total supply of 0 SMPLR NFts
  function testTotalSupply() public {
    assertEq(holographERC721.totalSupply(), 0);
  }

  // should not exist #1 SMPLR NFT
  function testTokenByIndex() public {
    uint256 tokenId = 1;
    assertFalse(holographERC721.exists(tokenId));
  }

  // NFT index 0 should fail
  function testTokenIndex0() public {
    vm.expectRevert("ERC721: index out of bounds");
    holographERC721.tokenByIndex(0);
  }

  // NFT owner index 0 should fail
  function testTokenOwnerIndex0() public {
    vm.expectRevert("ERC721: index out of bounds");
    holographERC721.tokenOfOwnerByIndex(deployer, 0);
  }

  // should emit Transfer event for #1 SMPLR NFT
  function testMint() public {
    uint224 tokenId = 1;

    vm.expectEmit(true, true, true, false);
    emit Transfer(address(0), alice, tokenId);

    vm.prank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample1.json");

    assertEq(holographERC721.totalSupply(), 1);

    // should exist #1 SMPLR NFT
    assertTrue(holographERC721.exists(tokenId));

    // should not mark as burned #1 SMPLR NFT
    assertFalse(holographERC721.burned(tokenId));

    // should specify alice as owner of #1 SMPLR NFT
    assertEq(holographERC721.ownerOf(tokenId), alice);

    // NFT index 0 should return #1 SMPLR NFT
    assertEq(holographERC721.tokenByIndex(0), tokenId);

    // NFT owner index 0 should return #1 SMPLR NFT
    assertEq(holographERC721.tokenOfOwnerByIndex(alice, 0), tokenId);
  }

  // should emit Transfer event for #2 SMPLR NFT
  function testMint2() public {
    uint224 tokenId = 1;

    vm.startPrank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample1.json");

    tokenId = 2;

    vm.expectEmit(true, true, true, false);
    emit Transfer(address(0), bob, tokenId);

    sampleERC721.mint(bob, tokenId, "https://holograph.xyz/sample2.json");

    vm.stopPrank();
    assertEq(holographERC721.totalSupply(), 2);
  }

  // should fail minting to zero address
  function testMintToZeroAddress() public {
    vm.expectRevert("ERC721: minting to burn address");
    vm.prank(deployer);
    sampleERC721.mint(address(0), 1, "");
  }

  // should fail minting existing #1 SMPLR NFT
  function testMintExisting() public {
    vm.startPrank(deployer);
    sampleERC721.mint(alice, 1, "https://holograph.xyz/sample1.json");

    vm.expectRevert("ERC721: token already exists");
    sampleERC721.mint(alice, 1, "https://holograph.xyz/sample1.json");
  }
  
  // should fail minting burned #3 SMPLR NFT
  function testMintBurned() public {
    uint224 tokenId = 3;
    vm.prank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample3.json");

    vm.expectEmit(true, true, true, false);
    emit Transfer(alice, address(0), tokenId);

    vm.prank(alice);
    holographERC721.burn(tokenId);

    vm.expectRevert("ERC721: can't mint burned token");
    vm.prank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample3.json");

    // should mark as burned #3 SMPLR NFT
    assertTrue(holographERC721.burned(tokenId));
  }

  function testMintBalances() public {
    vm.startPrank(deployer);
    sampleERC721.mint(alice, 1, "https://holograph.xyz/sample1.json");
    sampleERC721.mint(alice, 2, "https://holograph.xyz/sample2.json");
    vm.stopPrank();

    // should have a total supply of 2 SMPLR NFts
    assertEq(holographERC721.totalSupply(), 2);

    // alice address should have 2 SMPLR NFts
    assertEq(holographERC721.balanceOf(alice), 2);

    // should return an array of token ids
    uint256[] memory tokenIds = holographERC721.tokens(0, 10);
    assertEq(tokenIds.length, 2);
    assertEq(tokenIds[0], 1);
    assertEq(tokenIds[1], 2);

    // should return an array of owner token ids
    uint256[] memory ownerTokenIds = holographERC721.tokensOfOwner(alice);
    assertEq(ownerTokenIds.length, 2);
    assertEq(ownerTokenIds[0], 1);
    assertEq(ownerTokenIds[1], 2);

    // check NFT data
    assertEq(holographERC721.tokenURI(1), "https://holograph.xyz/sample1.json");
    assertEq(holographERC721.tokenURI(2), "https://holograph.xyz/sample2.json");
  }

  // should return no approval for #1 SMPLR NFT
  function testApprove() public {
    uint224 tokenId = 1;

    vm.prank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample1.json");

    assertEq(holographERC721.getApproved(tokenId), address(0));

    // should succeed when approving bob for #1 SMPLR NFT
    vm.expectEmit(true, true, true, false);
    emit Approval(alice, bob, tokenId);

    vm.prank(alice);
    holographERC721.approve(bob, tokenId);

    // should return bob as approved for #1 SMPLR NFT
    assertEq(holographERC721.getApproved(tokenId), bob);

    // should succeed when unsetting approval for #1 SMPLR NFT
    vm.expectEmit(true, true, true, false);
    emit Approval(alice, address(0), tokenId);

    vm.prank(alice);
    holographERC721.approve(address(0), tokenId);

    // should return no approval for #1 SMPLR NFT
    assertEq(holographERC721.getApproved(tokenId), address(0));
  }

  // should clear approval on transfer #1 SMPLR NFT
  function testTransferApproval() public {
    uint224 tokenId = 1;

    vm.prank(deployer);
    sampleERC721.mint(alice, tokenId, "https://holograph.xyz/sample1.json");

    vm.startPrank(alice);
    holographERC721.approve(bob, tokenId);

    assertEq(holographERC721.getApproved(tokenId), bob);

    holographERC721.transfer(charlie, tokenId);

    assertEq(holographERC721.getApproved(tokenId), address(0));
  }

  // should bob not be approved operator for alice
  function testIsApprovedForAll() public {
    assertFalse(holographERC721.isApprovedForAll(alice, bob));
  }

  // should succeed setting bob as approved operator for alice
  function testSetApprovalForAll() public {
    vm.expectEmit(true, true, false, false);
    emit ApprovalForAll(alice, bob, true);

    vm.prank(alice);
    holographERC721.setApprovalForAll(bob, true);

    // should return bob as approved operator for alice
    assertTrue(holographERC721.isApprovedForAll(alice, bob));

    // should succeed unsetting bob as approved operator for alice
    vm.expectEmit(true, true, false, false);
    emit ApprovalForAll(alice, bob, false);

    vm.prank(alice);
    holographERC721.setApprovalForAll(bob, false);

    // should bob not be approved operator for alice
    assertFalse(holographERC721.isApprovedForAll(alice, bob));
  }

  // Failed transfer

  // should fail if sender doesn't own #1 SMPLR NFT
  function testTransfer() public {
    vm.prank(deployer);
    sampleERC721.mint(alice, 1, "https://holograph.xyz/sample1.json");

    vm.expectRevert("ERC721: not approved sender");
    holographERC721.transfer(bob, 1);

    // should fail if transferring to zero address
    vm.expectRevert("ERC721: use burn instead");

    vm.prank(alice);
    holographERC721.transfer(address(0), 1);

    // should fail if transferring from zero address
    vm.expectRevert("ERC721: token not owned");

    vm.prank(alice);
    holographERC721.transferFrom(address(0), bob, 1);

    // should fail if transferring not owned NFT
    vm.expectRevert("ERC721: not approved sender");

    holographERC721.transferFrom(alice, bob, 1);
  }

  // should fail if transferring non-existent #3 SMPLR NFT
  function testTransferNonExistent() public {
    vm.expectRevert("ERC721: token does not exist");
    holographERC721.transfer(alice, 3);
  }

  // should fail safe transfer for broken ERC721TokenReceiver
  function testSafeTransferBrokenReceiver() public {
    uint224 tokenId = 1;

    vm.startPrank(deployer);
    sampleERC721.mint(deployer, tokenId, "https://holograph.xyz/sample1.json");

    mockERC721Receiver.toggleWorks(false);

    vm.expectRevert("ERC721: onERC721Received fail");
    holographERC721.safeTransferFrom(deployer, address(mockERC721Receiver), tokenId);
  }

}
