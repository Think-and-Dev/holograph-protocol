// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants, ErrorConstants} from "../utils/Constants.sol";
import {RandomAddress} from "../utils/Utils.sol";
import {HolographRoyalties} from "../../../src/enforcer/HolographRoyalties.sol";
import {MockExternalCall} from "../../../src/mock/MockExternalCall.sol";
import {HolographFactory} from "../../../src/HolographFactory.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";

contract RoyaltiesTests is Test {
  HolographRoyalties royalties;
  HolographRoyalties royaltiesNoDeployed;
  MockExternalCall mockExternalCall;
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  address owner = vm.addr(Constants.getPKDeployer());
  address notOwner = vm.addr(1);
  HolographFactory factory;
  HolographERC20 erc20;
  SampleERC20 sampleErc20;

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    royalties = HolographRoyalties(payable(Constants.getSampleERC721()));
    royaltiesNoDeployed = new HolographRoyalties();
    mockExternalCall = new MockExternalCall();
    factory = HolographFactory(payable(Constants.getHolographFactoryProxy()));
    erc20 = HolographERC20(payable(Constants.getSampleERC20()));
    sampleErc20 = SampleERC20(payable(Constants.getSampleERC20()));
  }

  /* -------------------------------------------------------------------------- */
  /*                                   init()                                   */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that calling `init()` when the contract is already initialized reverts
   * @dev This test checks that the contract reverts with the `ROYALTIES: already initialized`
   * error message when calling `init()` when the contract is already initialized.
   */
  function testAlreadyInitializedRevert() public {
    vm.expectRevert(bytes(ErrorConstants.HOLOGRAPHER_ALREADY_INITIALIZED_ERROR_MSG));
    vm.prank(owner);
    royalties.init(abi.encode(owner));
  }

  /* -------------------------------------------------------------------------- */
  /*                           initHolographRoyalties                           */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that calling `initHolographRoyalties()` when the royalties are already initialized reverts
   * @dev This test checks that the contract reverts with the `ROYALTIES: already initialized` error
   * message when calling `initHolographRoyalties()` when the royalties are already initialized.
   */
  function testInitializedTwiceRevert() public {
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_ALREADY_INITIALIZED_ERROR_MSG));
    vm.prank(owner);
    royalties.initHolographRoyalties(abi.encode(100, 0));
  }

  /* -------------------------------------------------------------------------- */
  /*                                   owner()                                  */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `owner()` function returns the correct owner address
   * @dev This test checks that the `owner()` function returns the correct owner address.
   */
  function testReturnCorrectOwnerAddress() public {
    address ownerAddress = royalties.owner();
    assertEq(ownerAddress, address(owner));
  }

  /**
   * @notice Tests that comparing the wrong address reverts
   * @dev This test checks that comparing the wrong address reverts.
   */
  function testComparingWrongAddressRevert() public {
    address ownerAddress = royalties.owner();
    assertNotEq(ownerAddress, address(notOwner));
  }

  /**
   * @notice Tests that an external contract can call the `owner()` function
   * @dev This test checks that an external contract can call the `owner()` function.
   */
  function testAllowExternalContractToCallFnOwner() public {
    bytes memory encodeSignature = abi.encodeWithSignature("owner()");
    mockExternalCall.callExternalFn(address(royalties), encodeSignature);
  }

  /* -------------------------------------------------------------------------- */
  /*                                  isOwner()                                 */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `isOwner()` function is private
   * @dev This test checks that the `isOwner()` function is private and cannot be called directly.
   */
  function testIsOwnerIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("isOwner()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                            _getDefaultReceiver()                           */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getDefaultReceiver()` function is private
   * @dev This test checks that the `_getDefaultReceiver()` function is private and cannot be called directly.
   */
  function testGetDefaultReceiverIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getDefaultReceiver()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                            _setDefaultReceiver()                           */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setDefaultReceiver()` function is private
   * @dev This test checks that the `_setDefaultReceiver()` function is private and cannot be called directly.
   */
  function testSetDefaultReceiverIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setDefaultReceiver()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _getDefaultBp()                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getDefaultBp()` function is private
   * @dev This test checks that the `_getDefaultBp()` function is private and cannot be called directly.
   */
  function testGetDefaultBpIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getDefaultBp()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _setDefaultBp()                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setDefaultBp()` function is private
   * @dev This test checks that the `_setDefaultBp()` function is private and cannot be called directly.
   */
  function testSetDefaultBpIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setDefaultBp()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _getReceiver()                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getReceiver()` function is private
   * @dev This test checks that the `_getReceiver()` function is private and cannot be called directly.
   */
  function testGetReceiverIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getReceiver()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _setReceiver()                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setReceiver()` function is private
   * @dev This test checks that the `_setReceiver()` function is private and cannot be called directly.
   */
  function testSetReceiverIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setReceiver()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                                  _getBp()                                  */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getBp()` function is private
   * @dev This test checks that the `_getBp()` function is private and cannot be called directly.
   */
  function testGetBpIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getBp()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                                   _setBp()                                 */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setBp()` function is private
   * @dev This test checks that the `_setBp()` function is private and cannot be called directly.
   */
  function testSetBpIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setBp()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                            _getPayoutAddresses()                           */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getPayoutAddresses()` function is private
   * @dev This test checks that the `_getPayoutAddresses()` function is private and cannot be called directly.
   */
  function testGetPayoutAddressesIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getPayoutAddresses()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                            _setPayoutAddresses()                           */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setPayoutAddresses()` function is private
   * @dev This test checks that the `_setPayoutAddresses()` function is private and cannot be called directly.
   */
  function testSetPayoutAddressesIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setPayoutAddresses()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _getPayoutBps()                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getPayoutBps()` function is private
   * @dev This test checks that the `_getPayoutBps()` function is private and cannot be called directly.
   */
  function testGetPayoutBpsIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getPayoutBps()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _setPayoutBps()                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setPayoutBps()` function is private
   * @dev This test checks that the `_setPayoutBps()` function is private and cannot be called directly.
   */
  function testSetPayoutBpsIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setPayoutBps()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                             _getTokenAddress()                             */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_getTokenAddress()` function is private
   * @dev This test checks that the `_getTokenAddress()` function is private and cannot be called directly.
   */
  function testGetTokenAddressIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_getTokenAddress()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                             _setTokenAddress()                             */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_setTokenAddress()` function is private
   * @dev This test checks that the `_setTokenAddress()` function is private and cannot be called directly.
   */
  function testSetTokenAddressIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_setTokenAddress()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                                 _payoutEth()                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_payoutEth()` function is private
   * @dev This test checks that the `_payoutEth()` function is private and cannot be called directly.
   */
  function testPayoutEthIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_payoutEth()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _payoutToken()                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_payoutToken()` function is private
   * @dev This test checks that the `_payoutToken()` function is private and cannot be called directly.
   */
  function testPayoutTokenIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_payoutToken()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                               _payoutTokens()                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_payoutTokens()` function is private
   * @dev This test checks that the `_payoutTokens()` function is private and cannot be called directly.
   */
  function testPayoutTokensIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_payoutTokens()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                         _validatePayoutRequestor()                         */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `_validatePayoutRequestor()` function is private
   * @dev This test checks that the `_validatePayoutRequestor()` function is private and cannot be called directly.
   */
  function testValidatePayoutRequestorIsPrivateFunction() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("_validatePayoutRequestor()");
    (bool success, bytes memory data) = address(royaltiesNoDeployed).call(encodedFunctionData);
    assertFalse(success);
  }

  /* -------------------------------------------------------------------------- */
  /*                              configurePayouts                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that the `configurePayouts` function can be called by the owner
   * @dev This test checks that the `configurePayouts` function can be called by the owner
   * and that the payout addresses and percentages are correctly set.
   */
  function testCallableByTheOwner() public {
    address payable[] memory addresses = new address payable[](2);
    addresses[0] = payable(owner);
    addresses[1] = payable(address(mockExternalCall));

    uint256[] memory bps = new uint256[](2);
    bps[0] = 5000;
    bps[1] = 5000;

    bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
    vm.prank(owner);
    factory.adminCall(address(royalties), data);

    (address payable[] memory payoutAddresses, uint256[] memory payoutBps) = royalties.getPayoutInfo();

    assertEq(addresses[0], payoutAddresses[0]);
    assertEq(addresses[1], payoutAddresses[1]);
    assertEq(bps[0], payoutBps[0]);
    assertEq(bps[1], payoutBps[1]);
  }

  /**
   * @notice Tests that the `configurePayouts` function reverts if the arguments arrays have different lengths
   * @dev This test checks that the `configurePayouts` function reverts with the `ROYALTIES: missmatched lenghts`
   * error message if the `addresses` and `bps` arrays have different lengths.
   */
  function testIfArgumentsArraysHaveDifferentLenghtsRevert() public {
    address payable[] memory addresses = new address payable[](1);
    addresses[0] = payable(RandomAddress.randomAddress());
    uint256[] memory bps = new uint256[](2);
    bps[0] = 1000;
    bps[1] = 9000;

    vm.prank(owner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_MISSMATCHED_LENGHTS_ERROR_MSG));
    bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
    factory.adminCall(address(royalties), data);
  }

  /**
   * @notice Tests that the `configurePayouts` function reverts if there are more than 10 payout addresses
   * @dev This test checks that the `configurePayouts` function reverts with the `ROYALTIES: max 10 addresses`
   * error message if there are more than 10 payout addresses.
   */
  function testIfThereAreMoreThanTenPayoutAddressesRevert() public {
    address payable[] memory addresses = new address payable[](11);
    uint256[] memory bps = new uint256[](11);

    for (uint256 i = 0; i < 11; i++) {
      addresses[i] = payable(RandomAddress.randomAddress());
      bps[i] = 10;

      vm.prank(owner);
      vm.expectRevert(bytes(ErrorConstants.ROYALTIES_MAX_TEN_ADDRESSES_MSG));
      bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
      factory.adminCall(address(royalties), data);
    }
  }

  /**
   * @notice Tests that the `configurePayouts` function reverts if the BPS do not equal 1000
   * @dev This test checks that the `configurePayouts` function reverts with the `ROYALTIES: bps must equal 10000`
   * error message if the BPS do not equal 1000.
   */
  function testIfBpsDontEqualRevert() public {
    address payable[] memory addresses = new address payable[](1);
    addresses[0] = payable(RandomAddress.randomAddress());
    uint256[] memory bps = new uint256[](1);
    bps[0] = 1000;

    vm.prank(owner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_BPS_MUST_EQUAL_1000));
    bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
    factory.adminCall(address(royalties), data);
  }

  /**
   * @notice Tests that the `configurePayouts` function reverts if it is not the owner calling
   * @dev This test checks that the `configurePayouts` function reverts with the `ROYALTIES: caller not an owner`
   * error message if it is not the owner calling the function.
   */
  function testIfItIsNotTheOwnerCallingRevert() public {
    address payable[] memory addresses = new address payable[](1);
    addresses[0] = payable(RandomAddress.randomAddress());
    uint256[] memory bps = new uint256[](1);
    bps[0] = 1000;

    vm.prank(notOwner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_ONLY_OWNER_ERROR_MSG));
    royalties.configurePayouts(addresses, bps);
  }

  /* -------------------------------------------------------------------------- */
  /*                                getPayoutInfo                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getPayoutInfo` function
   * @dev This test checks that the `getPayoutInfo` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetPayoutInfo() public {
    royalties.getPayoutInfo();
  }

  /**
   * @notice Tests that an external contract can call the `getPayoutInfo` function
   * @dev This test checks that an external contract can call the `getPayoutInfo` function.
   */
  function testAllowExternalContractToCallFnGetPayoutInfo() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("getPayoutInfo()");
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                getEthPayout                                */
  /* -------------------------------------------------------------------------- */

  /**
   * @notice Tests that the `getEthPayout` function reverts if the sender is not authorized
   * @dev This test checks that the `getEthPayout` function reverts with the `ROYALTIES: sender not authorized`
   * error message if the sender is not the owner.
   */
  function testIfSenderIsNotAuthorizedGetEtHPayputRevert() public {
    vm.prank(notOwner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_SENDER_NOT_AUTORIZED));
    royalties.getEthPayout();
  }

  /* -------------------------------------------------------------------------- */
  /*                               getTokenPayout                               */
  /* -------------------------------------------------------------------------- */

  /**
   * @notice Tests that the `getTokenPayout` function reverts if the sender is not authorized
   * @dev This test checks that the `getTokenPayout` function reverts with the `ROYALTIES: sender not authorized`
   * error message if the sender is not the owner.
   */
  function testIfSenderIsNotAuthorizedGetTokenPayoutRevert() public {
    vm.prank(notOwner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_SENDER_NOT_AUTORIZED));
    royalties.getTokenPayout(owner);
  }

  /* -------------------------------------------------------------------------- */
  /*                               getTokensPayout                              */
  /* -------------------------------------------------------------------------- */

  /**
   * @notice Tests that the `getTokensPayout` function reverts if the sender is not authorized
   * @dev This test checks that the `getTokensPayout` function reverts with the `ROYALTIES: sender not authorized`
   * error message if the sender is not the owner.
   */
  function testIfSenderIsNotAuthorizedGetTokensPayoutRevert() public {
    address[] memory addresses = new address[](2);
    addresses[0] = owner;
    addresses[1] = notOwner;
    vm.prank(notOwner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_SENDER_NOT_AUTORIZED));
    royalties.getTokensPayout(addresses);
  }

  /* -------------------------------------------------------------------------- */
  /*                                setRoyalties                                */
  /* -------------------------------------------------------------------------- */

  /**
   * @notice Tests that the `setRoyalties` function reverts if it is not the owner calling
   * @dev This test checks that the `setRoyalties` function reverts with the `ROYALTIES: caller not an owner`
   * error message if the sender is not the owner.
   */
  function testIfItIsNotTheOwnerCallingSetRoyaltiesRevert() public {
    address payable anyaddress = payable(RandomAddress.randomAddress());
    vm.prank(notOwner);
    vm.expectRevert(bytes(ErrorConstants.ROYALTIES_ONLY_OWNER_ERROR_MSG));
    royalties.setRoyalties(1, anyaddress, 1000);
  }

  /* -------------------------------------------------------------------------- */
  /*                                 royaltyInfo                                */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `royaltyInfo` function
   * @dev This test checks that the `royaltyInfo` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnRoyaltyInfo() public {
    royalties.royaltyInfo(1, 10);
  }

  /**
   * @notice Tests that an external contract can call the `royaltyInfo` function
   * @dev This test checks that an external contract can call the `royaltyInfo` function.
   */
  function testAllowExternalContractToCallFnRoyaltiInfo() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("royaltyInfo(uint256,uint256)", 1, 10);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                  getFeeBps                                 */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getFeeBps` function
   * @dev This test checks that the `getFeeBps` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetFeeBps() public {
    royalties.getFeeBps(1);
  }

  /**
   * @notice Tests that an external contract can call the `getFeeBps` function
   * @dev This test checks that an external contract can call the `getFeeBps` function.
   */
  function testAllowExternalContractToCallFnGetFeeBps() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("getFeeBps(uint256)", 1);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                              getFeeRecipients                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getFeeRecipients` function
   * @dev This test checks that the `getFeeRecipients` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetFeeRecipients() public {
    royalties.getFeeRecipients(1);
  }

  /**
   * @notice Tests that anyone can call the `getFeeRecipients` function
   * @dev This test checks that the `getFeeRecipients` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnGetFeeRecipients() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("getFeeRecipients(uint256)", 1);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                getRoyalties                                */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getRoyalties` function
   * @dev This test checks that the `getRoyalties` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetRoyalties() public {
    royalties.getRoyalties(1);
  }

  /**
   * @notice Tests that anyone can call the `getRoyalties` function
   * @dev This test checks that the `getRoyalties` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnGetRoyalties() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("getRoyalties(uint256)", 1);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                  getFees                                   */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getFees` function
   * @dev This test checks that the `getFees` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetFees() public {
    royalties.getFees(1);
  }

  /**
   * @notice Tests that anyone can call the `getFees` function
   * @dev This test checks that the `getFees` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnGetFees() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("getFees(uint256)", 1);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                tokenCreators                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `tokenCreators` function
   * @dev This test checks that the `tokenCreators` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnTokenCreator() public {
    royalties.tokenCreators(0);
  }

  /**
   * @notice Tests that anyone can call the `tokenCreators` function
   * @dev This test checks that the `tokenCreators` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnTokenCreator() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("tokenCreators(uint256)", 0);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                             calculateRoyaltyFee                            */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `calculateRoyaltyFee` function
   * @dev This test checks that the `calculateRoyaltyFee` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnCalculateRoyaltyFee() public {
    royalties.calculateRoyaltyFee(RandomAddress.randomAddress(), 1, 1);
  }

  /**
   * @notice Tests that anyone can call the `calculateRoyaltyFee` function
   * @dev This test checks that the `calculateRoyaltyFee` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnCalculateRoyaltyFee() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature(
      "calculateRoyaltyFee(address,uint256,uint256)",
      RandomAddress.randomAddress(),
      1,
      1
    );
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                marketContract                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `marketContract` function
   * @dev This test checks that the `marketContract` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnMarketContract() public {
    royalties.marketContract();
  }

  /**
   * @notice Tests that anyone can call the `marketContract` function
   * @dev This test checks that the `marketContract` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnMarketContract() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("marketContract()");
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                                tokenCreators                               */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `tokenCreators` function
   * @dev This test checks that the `tokenCreators` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnTokenCreators() public {
    royalties.tokenCreators(1);
  }

  /**
   * @notice Tests that anyone can call the `tokenCreators` function
   * @dev This test checks that the `tokenCreators` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnTokenCreators() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("tokenCreators(uint256)", 1);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                              bidSharesForToken                             */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `bidSharesForToken` function
   * @dev This test checks that the `bidSharesForToken` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnBidSharesForToken() public {
    royalties.bidSharesForToken(0);
  }

  /**
   * @notice Tests that anyone can call the `bidSharesForToken` function
   * @dev This test checks that the `bidSharesForToken` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnBidSharesForToken() public {
    bytes memory encodedFunctionData = abi.encodeWithSignature("bidSharesForToken(uint256)", 0);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                               getTokenAddress                              */
  /* -------------------------------------------------------------------------- */
  /**
   * @notice Tests that anyone can call the `getTokenAddress` function
   * @dev This test checks that the `getTokenAddress` function can be called by anyone without restrictions.
   */
  function testAnyoneShouldBeAbleToCallTheFnGetTokenAddress() public {
    // TODO change 4294967294 to Constants.getHolographIdL1()
    string memory tokenName = "Sample ERC721 Contract 4294967294";
    royalties.getTokenAddress(tokenName);
  }

  /**
   * @notice Tests that anyone can call the `getTokenAddress` function
   * @dev This test checks that the `getTokenAddress` function can be called by anyone without restrictions.
   */
  function testAllowExternalContractToCallFnGetTokenAddress() public {
    string memory tokenName = "Sample ERC721 Contract 4294967294";
    bytes memory encodedFunctionData = abi.encodeWithSignature("getTokenAddress(string)", tokenName);
    mockExternalCall.callExternalFn(address(royalties), encodedFunctionData);
  }

  /* -------------------------------------------------------------------------- */
  /*                      Royalties Distribution Validation                     */
  /* -------------------------------------------------------------------------- */

  /**
   * @notice Tests that the contract can withdraw all native token balance
   * @dev This test checks that the contract can withdraw all native token balance
   * and that the owner's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsNativeTokens() public {
    vm.prank(owner);
    payable(address(royalties)).transfer(1 ether);

    uint256 accountBalanceBefore = owner.balance;
    uint256 contractBalanceBefore = address(royalties).balance;

    bytes memory data = abi.encodeWithSignature("getEthPayout()");
    vm.prank(owner);
    factory.adminCall(address(royalties), data);

    uint256 accountBalanceAfter = owner.balance;
    uint256 contractBalanceAfter = address(royalties).balance;

    assertLt(contractBalanceAfter, contractBalanceBefore);
    assertGt(accountBalanceAfter, accountBalanceBefore);
  }

  /**
   * @notice Tests that the contract can withdraw balance of an ERC20 token
   * @dev This test checks that the contract can withdraw balance of an ERC20
   * token and that the owner's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsERC20Tokens() public {
    vm.prank(owner);
    sampleErc20.mint(owner, 1 ether);
    vm.prank(owner);
    erc20.transfer(address(royalties), 1 ether);

    uint256 contractBalanceBefore = erc20.balanceOf(address(royalties));
    uint256 accountBalanceBefore = erc20.balanceOf(owner);

    bytes memory data = abi.encodeWithSignature("getTokenPayout(address)", address(erc20));
    vm.prank(owner);
    factory.adminCall(address(royalties), data);

    uint256 contractBalanceAfter = erc20.balanceOf(address(royalties));
    uint256 accountBalanceAfter = erc20.balanceOf(owner);

    assertLt(contractBalanceAfter, contractBalanceBefore);
    assertGt(accountBalanceAfter, accountBalanceBefore);
  }

  /**
   * @notice Tests that the contract can withdraw all native token balance with multiple recipients
   * @dev This test checks that the contract can withdraw all native token balance with multiple
   * recipients and that each recipient's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsNativeTokensToMultipleRecipients() public {
    address anyAddress = RandomAddress.randomAddress();
    address payable[] memory addresses = new address payable[](2);
    addresses[0] = payable(anyAddress);
    addresses[1] = payable(notOwner);
    uint256[] memory bps = new uint256[](2);
    bps[0] = 6000;
    bps[1] = 4000;

    vm.prank(owner);
    royalties.configurePayouts(addresses, bps);
    vm.prank(owner);
    payable(address(royalties)).transfer(10 ether);

    uint256 accountABalanceBefore = anyAddress.balance;
    uint256 accountBBalanceBefore = notOwner.balance;
    uint256 contractBalanceBefore = address(royalties).balance;

    bytes memory data = abi.encodeWithSignature("getEthPayout()");
    vm.prank(owner);
    factory.adminCall(address(royalties), data);

    uint256 accountABalanceAfter = anyAddress.balance;
    uint256 accountBBalanceAfter = notOwner.balance;
    uint256 contractBalanceAfter = address(royalties).balance;

    uint256 sixtyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 60) / 100;
    uint256 fortyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 40) / 100;

    assertLe(contractBalanceAfter, contractBalanceBefore);
    assertEq(accountABalanceAfter, sixtyPercentOfRoyalties + accountABalanceBefore);
    assertEq(accountBBalanceAfter, fortyPercentOfRoyalties + accountBBalanceBefore);
  }

  /**
   * @notice Tests that the contract can withdraw balance of an ERC20 token with multiple recipients
   * @dev This test checks that the contract can withdraw balance of an ERC20 token with multiple
   * recipients and that each recipient's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsERC20TokensToMultipleRecipients() public {
    address anyAddress = RandomAddress.randomAddress();
    address payable[] memory addresses = new address payable[](2);
    addresses[0] = payable(anyAddress);
    addresses[1] = payable(notOwner);
    uint256[] memory bps = new uint256[](2);
    bps[0] = 6000;
    bps[1] = 4000;
    vm.prank(owner);
    royalties.configurePayouts(addresses, bps);

    vm.prank(owner);
    sampleErc20.mint(owner, 1 ether);
    vm.prank(owner);
    erc20.transfer(address(royalties), 1 ether);

    uint256 contractBalanceBefore = erc20.balanceOf(address(royalties));
    uint256 accountABalanceBefore = erc20.balanceOf(anyAddress);
    uint256 accountBBalanceBefore = erc20.balanceOf(notOwner);

    bytes memory data = abi.encodeWithSignature("getTokenPayout(address)", address(erc20));
    vm.prank(owner);
    factory.adminCall(address(royalties), data);

    uint256 contractBalanceAfter = erc20.balanceOf(address(royalties));
    uint256 accountABalanceAfter = erc20.balanceOf(anyAddress);
    uint256 accountBBalanceAfter = erc20.balanceOf(notOwner);

    uint256 sixtyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 60) / 100;
    uint256 fortyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 40) / 100;

    assertLt(contractBalanceAfter, contractBalanceBefore);
    assertEq(accountABalanceAfter, accountABalanceBefore + sixtyPercentOfRoyalties);
    assertEq(accountBBalanceAfter, accountBBalanceBefore + fortyPercentOfRoyalties);
  }

  /**
   * @notice Tests that the contract can withdraw all native token balance with multiple recipients and custom percentages
   * @dev This test checks that the contract can withdraw all native token balance with multiple recipients and custom
   * percentages, and that each recipient's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsNativeTokensToMultipleRecipientsWithCustomPercentages() public {
    address anyAddress = vm.addr(2);
    address mockAddress = vm.addr(3);
    address payable[] memory addresses = new address payable[](3);
    addresses[0] = payable(anyAddress);
    addresses[1] = payable(notOwner);
    addresses[2] = payable(mockAddress);
    uint256[] memory bps = new uint256[](3);
    bps[0] = 2000;
    bps[1] = 5000;
    bps[2] = 3000;
    bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
    vm.prank(owner);
    factory.adminCall(address(royalties), data);
    vm.prank(owner);
    payable(address(royalties)).transfer(10 ether);

    uint256 accountABalanceBefore = anyAddress.balance;
    uint256 accountBBalanceBefore = notOwner.balance;
    uint256 accountCBalanceBefore = mockAddress.balance;
    uint256 contractBalanceBefore = address(royalties).balance;

    bytes memory data2 = abi.encodeWithSignature("getEthPayout()");
    vm.prank(owner);
    factory.adminCall(address(royalties), data2);

    uint256 accountABalanceAfter = anyAddress.balance;
    uint256 accountBBalanceAfter = notOwner.balance;
    uint256 accountCBalanceAfter = mockAddress.balance;
    uint256 contractBalanceAfter = address(royalties).balance;

    uint256 twentyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 20) / 100;
    uint256 fiftyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 50) / 100;
    uint256 thirtyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 30) / 100;

    assertLe(contractBalanceAfter, contractBalanceBefore);
    assertEq(accountABalanceAfter, twentyPercentOfRoyalties + accountABalanceBefore);
    assertEq(accountBBalanceAfter, fiftyPercentOfRoyalties + accountBBalanceBefore);
    assertEq(accountCBalanceAfter, thirtyPercentOfRoyalties + accountCBalanceBefore);
  }

  /**
   * @notice Tests that the contract can withdraw balance of an ERC20 token with multiple recipients and custom percentages
   * @dev This test checks that the contract can withdraw balance of an ERC20 token with multiple recipients and custom
   * percentages, and that each recipient's balance increases accordingly.
   */
  function testRoyaltiesContractWithdrawsERC20TokensToMultipleRecipientsWithCustomPercentages() public {
    address anyAddress = vm.addr(2);
    address mockAddress = vm.addr(3);
    address payable[] memory addresses = new address payable[](3);
    addresses[0] = payable(anyAddress);
    addresses[1] = payable(notOwner);
    addresses[2] = payable(mockAddress);
    uint256[] memory bps = new uint256[](3);
    bps[0] = 2000;
    bps[1] = 5000;
    bps[2] = 3000;
    bytes memory data = abi.encodeWithSignature("configurePayouts(address[],uint256[])", addresses, bps);
    vm.prank(owner);
    factory.adminCall(address(royalties), data);
    vm.prank(owner);
    payable(address(royalties)).transfer(10 ether);

    vm.prank(owner);
    sampleErc20.mint(owner, 1 ether);
    vm.prank(owner);
    erc20.transfer(address(royalties), 1 ether);

    uint256 contractBalanceBefore = erc20.balanceOf(address(royalties));
    uint256 accountABalanceBefore = erc20.balanceOf(anyAddress);
    uint256 accountBBalanceBefore = erc20.balanceOf(notOwner);
    uint256 accountCBalanceBefore = erc20.balanceOf(mockAddress);

    bytes memory data2 = abi.encodeWithSignature("getTokenPayout(address)", address(erc20));
    vm.prank(owner);
    factory.adminCall(address(royalties), data2);

    uint256 contractBalanceAfter = erc20.balanceOf(address(royalties));
    uint256 accountABalanceAfter = erc20.balanceOf(anyAddress);
    uint256 accountBBalanceAfter = erc20.balanceOf(notOwner);
    uint256 accountCBalanceAfter = erc20.balanceOf(mockAddress);

    uint256 twentyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 20) / 100;
    uint256 fiftyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 50) / 100;
    uint256 thirtyPercentOfRoyalties = ((contractBalanceBefore - contractBalanceAfter) * 30) / 100;

    assertLt(contractBalanceAfter, contractBalanceBefore);
    assertEq(accountABalanceAfter, accountABalanceBefore + twentyPercentOfRoyalties);
    assertEq(accountBBalanceAfter, accountBBalanceBefore + fiftyPercentOfRoyalties);
    assertEq(accountCBalanceAfter, accountCBalanceBefore + thirtyPercentOfRoyalties);
  }
}
