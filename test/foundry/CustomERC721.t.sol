// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";

import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {Utils} from "test/foundry/utils/Utils.sol";

import {HolographerInterface} from "src/interface/HolographerInterface.sol";
import {CustomERC721} from "src/token/CustomERC721.sol";
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

  function test_Purchase() public setupTestCustomERC21(10) {
    // We assume that the amount is at least one and less than or equal to the edition size given in modifier
    vm.prank(DEFAULT_OWNER_ADDRESS);

    HolographerInterface holographerInterface = HolographerInterface(address(customErc721));
    address sourceContractAddress = holographerInterface.getSourceContract();
    HolographERC721 erc721Enforcer = HolographERC721(payable(address(customErc721)));

    uint104 price = usd100;
    uint256 nativePrice = dummyPriceOracle.convertUsdToWei(price);
    uint256 holographFee = customErc721.getHolographFeeUsd(1);
    uint256 nativeFee = dummyPriceOracle.convertUsdToWei(holographFee);

    vm.prank(DEFAULT_OWNER_ADDRESS);

    CustomERC721(payable(sourceContractAddress)).setSaleConfiguration({
      publicSaleStart: 0,
      publicSaleEnd: type(uint64).max,
      presaleStart: 0,
      presaleEnd: 0,
      publicSalePrice: price,
      maxSalePurchasePerAddress: uint32(1),
      presaleMerkleRoot: bytes32(0)
    });

    uint256 totalCost = (nativePrice + nativeFee);

    vm.prank(address(TEST_ACCOUNT));
    vm.deal(address(TEST_ACCOUNT), totalCost);
    customErc721.purchase{value: totalCost}(1);

    assertEq(customErc721.saleDetails().maxSupply, 100);
    assertEq(customErc721.saleDetails().totalMinted, 1);

    // First token ID is this long number due to the chain id prefix
    require(erc721Enforcer.ownerOf(FIRST_TOKEN_ID) == address(TEST_ACCOUNT), "Owner is wrong for new minted token");
    assertEq(address(sourceContractAddress).balance, nativePrice);
  }
}
