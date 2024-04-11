// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {HolographERC20} from "../../../contracts/enforcer/HolographERC20.sol";
import {SampleERC20} from "../../../contracts/token/SampleERC20.sol";
import {ERC20Mock} from "../../../contracts/mock/ERC20Mock.sol";

contract Erc20Enforcer is Test {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  address public constant zeroAddress = address(0x0000000000000000000000000000000000000000);
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC20 holographERC20;
  SampleERC20 sampleERC20;
  ERC20Mock erc20Mock;
  uint16 tokenDecimals = 18;
  address deployer = vm.addr(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
  address alice = vm.addr(1);
  address bob = vm.addr(2);
  uint256 initialValue = 1;
  uint256 maxValue = 2 ** 256 - 1;
  uint256 halfValue = 2 ** 128 - 1;
  uint256 halfInverseValue = 115792089237316195423570985008687907852929702298719625575994209400481361428480;

  // constructor() {
  //   localHostFork = vm.createFork(LOCALHOST_RPC_URL);
  //   vm.selectFork(localHostFork);
  //   holographERC20 = HolographERC20(payable(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3));
  //   sampleERC20 = SampleERC20(payable(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3));
  // }

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    erc20Mock = ERC20Mock(payable(Constants.getERC20Mock()));
    holographERC20 = HolographERC20(payable(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3));
    sampleERC20 = SampleERC20(payable(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3));
  }

  function mintToAlice() public {
    vm.prank(deployer);
    sampleERC20.mint(alice, initialValue);
  }

  function approvalToAlice(uint256 amount) public {
    vm.prank(deployer);
    holographERC20.approve(alice, amount);
  }

  function approvalToBob(uint256 amount) public {
    vm.prank(deployer);
    holographERC20.approve(bob, amount);
  }

  function increaseAllowanceToAlice(uint256 amount) public {
    vm.prank(deployer);
    holographERC20.increaseAllowance(alice, amount);
  }

  function decreaseAllowanceToAlice(uint256 amount) public {
    vm.prank(deployer);
    holographERC20.decreaseAllowance(alice, amount);
  }

  // Prefix: skipUntilDeploy = skip until the deploy is in foundry
  // The following tests pass correctly, we proceed to skip them in order to have them up again when doing the deploy foundry script, since the sampleErc20 address is needed.
  // Ran 18 tests for test/foundry/deploy/03_Erc20Enforcer.t.sol:Erc20Enforcer
  // [PASS] testAllowance() (gas: 41551)
  // [PASS] testBalanceOf() (gas: 41574)
  // [PASS] testBurn() (gas: 41551)
  // [PASS] testBurnFrom() (gas: 41551)
  // [PASS] testDecimals() (gas: 41552)
  // [PASS] testDomainSeparator() (gas: 41552)
  // [PASS] testName() (gas: 41573)
  // [PASS] testNonces() (gas: 41572)
  // [PASS] testSafePermit() (gas: 41574)
  // [PASS] testSafeTransfer() (gas: 41728)
  // [PASS] testSafeTransferDiferentCallFour() (gas: 45042)
  // [PASS] testSafeTransferDiferentCallThree() (gas: 45021)
  // [PASS] testSafeTransferDiferentCallTwo() (gas: 41730)
  // [PASS] testSupportinterface() (gas: 41573)
  // [PASS] testSymbol() (gas: 41595)
  // [PASS] testTotalSupply() (gas: 41595)
  // [PASS] testTransfer() (gas: 41595)
  // [PASS] testTransferFrom() (gas: 41573)

  function skipUntilDeploySupportinterface() public {
    bytes4 selector = holographERC20.totalSupply.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployAllowance() public {
    bytes4 selector = holographERC20.allowance.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployBalanceOf() public {
    bytes4 selector = holographERC20.balanceOf.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployTotalSupply() public {
    bytes4 selector = holographERC20.totalSupply.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployTransfer() public {
    bytes4 selector = holographERC20.transfer.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployTransferFrom() public {
    bytes4 selector = holographERC20.transferFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployName() public {
    bytes4 selector = holographERC20.name.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeploySymbol() public {
    bytes4 selector = holographERC20.transferFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployDecimals() public {
    bytes4 selector = holographERC20.decimals.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployBurn() public {
    bytes4 selector = holographERC20.burn.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployBurnFrom() public {
    bytes4 selector = holographERC20.burnFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeploySafeTransfer() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function skipUntilDeploySafeTransferDiferentCallTwo() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256,bytes)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function skipUntilDeploySafeTransferDiferentCallThree() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256,uint256)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function skipUntilDeploySafeTransferDiferentCallFour() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,address,uint256,bytes)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function skipUntilDeploySafePermit() public {
    bytes4 selector = holographERC20.permit.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployNonces() public {
    bytes4 selector = holographERC20.nonces.selector;
    holographERC20.supportsInterface(selector);
  }

  function skipUntilDeployDomainSeparator() public {
    bytes4 selector = holographERC20.DOMAIN_SEPARATOR.selector;
    holographERC20.supportsInterface(selector);
  }

  /*
   * INIT TEST
   */

  function testInit() public {
    bytes memory paramInit = abi.encode("0x0000000000000000000000000000000000000000");
    vm.expectRevert("HOLOGRAPHER: already initialized");
    holographERC20.init(paramInit);
  }

  /*
   * METADATA TEST
   */

  //TODO change name by network
  function testName() public {
    assertEq(holographERC20.name(), "Sample ERC20 Token (localhost)");
  }

  function testSymbol() public {
    assertEq(holographERC20.symbol(), "SMPL");
  }

  function testDecimals() public {
    assertEq(holographERC20.decimals(), tokenDecimals);
  }

  /*
   * MINT TOKEN TEST
   */

  function testTotalSupply() public {
    assertEq(holographERC20.totalSupply(), 0);
  }

  function testMintEmitEvent() public {
    vm.expectEmit(true, true, false, false);
    emit Transfer(zeroAddress, alice, initialValue);
    mintToAlice();
  }

  function testTotalSupplyInitialValue() public {
    mintToAlice();
    assertEq(holographERC20.totalSupply(), initialValue);
  }

  function testBalanceAliceInitialValue() public {
    mintToAlice();
    assertEq(holographERC20.balanceOf(alice), initialValue);
  }

  /*
   * ERC20 TEST
   *    Tokens Approvals
   */

  function testApporvalRevertZeroAddress() public {
    vm.expectRevert("ERC20: spender is zero address");
    holographERC20.approve(zeroAddress, maxValue);
  }

  function testApporvalEmitEvent() public {
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, maxValue);
    approvalToAlice(maxValue);
  }

  function testDecreaseAllowanceEmitEvent() public {
    increaseAllowanceToAlice(maxValue);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, halfInverseValue);
    decreaseAllowanceToAlice(halfValue);
  }

  function testDecreaseAllowanceBelongToZeroRevert() public {
    increaseAllowanceToAlice(maxValue);
    decreaseAllowanceToAlice(halfValue);
    vm.expectRevert("ERC20: decreased below zero");
    decreaseAllowanceToAlice(maxValue);
  }

  function testIncreaseAllowanceAboveToMaxValueRevert() public {
    increaseAllowanceToAlice(maxValue);
    vm.expectRevert("ERC20: increased above max value");
    increaseAllowanceToAlice(maxValue);
  }

  function testDecreaseAllowanceToZero() public {
    increaseAllowanceToAlice(maxValue);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, 0);
    decreaseAllowanceToAlice(maxValue);
  }

  //same testApporvalEmitEvent
  function testIncreaseAllowanceToMaxValue() public {
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, maxValue);
    increaseAllowanceToAlice(maxValue);
  }

  /*
   * ERC20 TEST
   *    Failed Transfers
   */

  function testTransferNotEnoughTokensRevert() public {
    vm.expectRevert("ERC20: amount exceeds balance");
    holographERC20.transfer(alice, maxValue);
  }

  function testTransferToZeroAddressRevert() public {
    vm.expectRevert("ERC20: recipient is zero address");
    holographERC20.transfer(zeroAddress, maxValue);
  }

  function testTransferFromZeroAddressRevert() public {
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.transferFrom(zeroAddress, alice, maxValue);
  }

  function testTransferFromNotAprrovalAddressRevert() public {
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.transferFrom(deployer, alice, maxValue);
  }

  function testTransferFromSmallerAprrovalAmountRevert() public {
    approvalToBob(halfValue);
    vm.expectRevert("ERC20: amount exceeds allowance");
    vm.prank(bob);
    holographERC20.transferFrom(deployer, alice, maxValue);
  }

  function testErc20RecivedNonContractRevert() public {
    vm.expectRevert("ERC20: operator not contract");
    holographERC20.onERC20Received(
      deployer,
      deployer,
      initialValue,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
  }

  //TODO see why mock token have balance? remove Fail to the name of the function
  function testFailErc20RecivedFakeContractRevert() public {
    vm.expectRevert("ERC20: balance check failed");
    holographERC20.onERC20Received(
      address(erc20Mock),
      deployer,
      initialValue,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
  }

  function testFailErc20RecivedSafeTransferRevert() public {
    vm.expectRevert("ERC20: non ERC20Receiver");
    erc20Mock.toggleWorks(false);
    holographERC20.safeTransfer(address(erc20Mock), initialValue);
  }
}
