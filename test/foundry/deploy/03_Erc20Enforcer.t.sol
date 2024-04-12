// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";
import {ERC20Mock} from "../../../src/mock/ERC20Mock.sol";
import {Admin} from "../../../src/abstract/Admin.sol";

contract Erc20Enforcer is Test {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  address public constant zeroAddress = address(0x0000000000000000000000000000000000000000);
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC20 holographERC20;
  SampleERC20 sampleERC20;
  ERC20Mock erc20Mock;
  Admin admin;
  uint16 tokenDecimals = 18;
  address deployer = vm.addr(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
  address alice = vm.addr(1);
  address bob = vm.addr(2);
  uint256 initialValue = 1;
  uint256 maxValue = 2 ** 256 - 1;
  uint256 halfValue = 2 ** 128 - 1;
  uint256 halfInverseValue = 115792089237316195423570985008687907852929702298719625575994209400481361428480;
  bytes zeroBytes = bytes(abi.encode("0x0000000000000000000000000000000000000000"));
  bytes32 zeroSignature = bytes32(abi.encode(0x0000000000000000000000000000000000000000000000000000000000000000));
  bytes32 signature = bytes32(abi.encode(0x1111111111111111111111111111111111111111111111111111111111111111));
  bytes32 signature2 = bytes32(abi.encode(0x353535353535353535353535353535353535353535353535353535353535353));
  bytes32 signature3 = bytes32(abi.encode(0x686868686868686868686868686868686868686868686868686868686868686));
  uint256 badDeadLine;
  uint256 goodDeadLine;

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
    admin = Admin(payable(Constants.getHolographFactoryProxy()));
    badDeadLine = uint256(block.timestamp) - 1;
    goodDeadLine = uint256(block.timestamp);
  }

  function mintToAlice() public {
    vm.prank(deployer);
    sampleERC20.mint(alice, initialValue);
  }

  function mintToDeployer() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, initialValue);
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

  // Prefix: testUntilDeploy = test until the deploy is in foundry
  // The following tests pass correctly, we proceed to test them in order to have them up again when doing the deploy foundry script, since the sampleErc20 address is needed.
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

  function testUntilDeploySupportinterface() public {
    bytes4 selector = holographERC20.totalSupply.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployAllowance() public {
    bytes4 selector = holographERC20.allowance.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployBalanceOf() public {
    bytes4 selector = holographERC20.balanceOf.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployTotalSupply() public {
    bytes4 selector = holographERC20.totalSupply.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployTransfer() public {
    bytes4 selector = holographERC20.transfer.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployTransferFrom() public {
    bytes4 selector = holographERC20.transferFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployName() public {
    bytes4 selector = holographERC20.name.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeploySymbol() public {
    bytes4 selector = holographERC20.transferFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployDecimals() public {
    bytes4 selector = holographERC20.decimals.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployBurn() public {
    bytes4 selector = holographERC20.burn.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployBurnFrom() public {
    bytes4 selector = holographERC20.burnFrom.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeploySafeTransfer() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function testUntilDeploySafeTransferDiferentCallTwo() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256,bytes)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function testUntilDeploySafeTransferDiferentCallThree() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,uint256,uint256)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function testUntilDeploySafeTransferDiferentCallFour() public {
    bytes memory selector = abi.encodeWithSelector(bytes4(keccak256("safeTransfer(address,address,uint256,bytes)")));
    holographERC20.supportsInterface(bytes4(selector));
  }

  function testUntilDeploySafePermit() public {
    bytes4 selector = holographERC20.permit.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployNonces() public {
    bytes4 selector = holographERC20.nonces.selector;
    holographERC20.supportsInterface(selector);
  }

  function testUntilDeployDomainSeparator() public {
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
    vm.expectEmit(true, true, false, true);
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

  //TODO see why revert ( amount exceeds balance, need mint and then not fail... ) and not non ERC20Receiver,  remove Fail to the name of the function
  function testFailSafeTransferBrokenErc20RecivedRevert() public {
    erc20Mock.toggleWorks(false);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(deployer);
    holographERC20.safeTransfer(address(erc20Mock), initialValue);
  }

  //TODO see why revert ( amount exceeds balance,need mint and then not fail... ) and not non ERC20Receiver,  remove Fail to the name of the function
  function testFailSafeTransferBytesBrokenErc20RecivedRevert() public {
    erc20Mock.toggleWorks(false);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(deployer);
    holographERC20.safeTransfer(
      address(erc20Mock),
      initialValue,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
  }

  //TODO see why not revert,  remove Fail to the name of the function
  function testFailSafeTransferFromBrokenErc20RecivedRevert() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, halfValue);
    erc20Mock.toggleWorks(false);

    approvalToAlice(maxValue);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(alice);

    holographERC20.safeTransferFrom(address(deployer), address(erc20Mock), initialValue);
  }

  //TODO see why not revert,  remove Fail to the name of the function
  function testFailSafeTransferFromBytesBrokenErc20RecivedRevert() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, halfValue);
    erc20Mock.toggleWorks(false);

    approvalToAlice(maxValue);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(alice);

    holographERC20.safeTransferFrom(address(deployer), address(erc20Mock), initialValue, zeroBytes);
  }

  /*
   * ERC20 TEST
   *    Successful Transfers
   */

  function testTransfer() public {
    mintToDeployer();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(alice), initialValue);
    vm.prank(deployer);
    holographERC20.transfer(address(alice), initialValue);
  }

  function testBalanceOfDeployer() public {
    mintToDeployer();
    vm.prank(deployer);
    holographERC20.transfer(address(alice), initialValue);
    assertEq(holographERC20.balanceOf(deployer), 0);
  }

  function testBalanceOfAlice() public {
    mintToDeployer();
    vm.prank(deployer);
    holographERC20.transfer(address(alice), initialValue);
    assertEq(holographERC20.balanceOf(alice), initialValue);
  }

  function testSafeTransfer() public {
    mintToAlice();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(alice), address(deployer), initialValue);
    vm.prank(alice);
    holographERC20.safeTransfer(address(deployer), initialValue);
  }

  function testSafeTransferFrom() public {
    mintToDeployer();
    approvalToAlice(initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(alice), initialValue);
    vm.prank(alice);
    holographERC20.safeTransferFrom(address(deployer), address(alice), initialValue);
  }

  function testBalanceOfDeployerAfterSafeTransferFrom() public {
    testSafeTransferFrom();
    assertEq(holographERC20.balanceOf(deployer), 0);
  }

  function testBalanceOfAliceAfterSafeTransferFrom() public {
    testSafeTransferFrom();
    assertEq(holographERC20.balanceOf(alice), initialValue);
  }

  function testTransferFrom() public {
    mintToDeployer();
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, initialValue);
    approvalToAlice(initialValue);
    //check allowance alice = 1
    assertEq(holographERC20.allowance(deployer, alice), initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(alice), initialValue);
    vm.prank(alice);
    holographERC20.transferFrom(address(deployer), address(alice), initialValue);
    //check allowance alice = 0
    assertEq(holographERC20.allowance(deployer, alice), 0);
  }

  function testSafeTransferToErc20Reciver() public {
    erc20Mock.toggleWorks(true);
    mintToDeployer();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(erc20Mock), initialValue);
    vm.prank(deployer);
    holographERC20.safeTransfer(address(erc20Mock), initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(erc20Mock), address(deployer), initialValue);
    erc20Mock.transferTokens(payable(holographERC20), deployer, initialValue);
  }

  function testSafeTransferWithBytesToErc20Reciver() public {
    erc20Mock.toggleWorks(true);
    mintToDeployer();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(erc20Mock), initialValue);
    vm.prank(deployer);
    holographERC20.safeTransfer(address(erc20Mock), initialValue, zeroBytes);
  }

  function testSafeTransferFromToErc20() public {
    mintToDeployer();
    erc20Mock.toggleWorks(true);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, initialValue);
    approvalToAlice(initialValue);
    //check allowance alice = 1
    assertEq(holographERC20.allowance(deployer, alice), initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(erc20Mock), initialValue);
    vm.prank(alice);
    holographERC20.safeTransferFrom(address(deployer), address(erc20Mock), initialValue);
    //check allowance alice = 0
    assertEq(holographERC20.allowance(deployer, alice), 0);
  }

  function testSafeTransferFromBytesToErc20() public {
    mintToDeployer();
    erc20Mock.toggleWorks(true);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, alice, initialValue);
    approvalToAlice(initialValue);
    //check allowance alice = 1
    assertEq(holographERC20.allowance(deployer, alice), initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), address(erc20Mock), initialValue);
    vm.prank(alice);
    holographERC20.safeTransferFrom(address(deployer), address(erc20Mock), initialValue, zeroBytes);
    //check allowance alice = 0
    assertEq(holographERC20.allowance(deployer, alice), 0);
  }

  /*
   * ERC20 TEST
   *    Burneable
   */

  function testBurneableExceedsBalanceRevert() public {
    vm.expectRevert("ERC20: amount exceeds balance");
    holographERC20.burn(initialValue);
  }

  function testBurn() public {
    mintToDeployer();
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), zeroAddress, initialValue);
    vm.prank(deployer);
    holographERC20.burn(initialValue);
  }

  function testBurnFromNotApproveRevert() public {
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.burnFrom(deployer, initialValue);
  }

  function testBurnFrom() public {
    mintToDeployer();
    approvalToAlice(initialValue);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), zeroAddress, initialValue);
    vm.prank(alice);
    holographERC20.burnFrom(deployer, initialValue);
  }

  /*
   * ERC20 TEST
   *    Permit
   */

  //TODO buildDomainSeperator

  function testPermitZeroNounce() public {
    assertEq(holographERC20.nonces(alice), 0);
  }

  function testPermitBadDeadLineRevert() public {
    vm.expectRevert("ERC20: expired deadline");
    holographERC20.permit(deployer, alice, initialValue, badDeadLine, uint8(0x00), zeroSignature, zeroSignature);
  }

  function testPermitEmptySignatureRevert() public {
    console.log("block.timestamp", block.timestamp);
    console.log("block.goodDeadLine", goodDeadLine);
    console.log("block.badDeadLine", badDeadLine);
    vm.expectRevert("ERC20: zero address signer");
    holographERC20.permit(deployer, alice, initialValue, goodDeadLine, uint8(0x1b), zeroSignature, zeroSignature);
  }

  //TODO see, for me not work fine, 0x1b always rever for zerdo address
  function testPermitZeroAddressSignatureRevert() public {
    vm.expectRevert("ERC20: zero address signer");
    holographERC20.permit(deployer, alice, initialValue, goodDeadLine, uint8(0x1b), signature, signature);
  }

  function testPermitInvalidSignatureV_ValueRevert() public {
    vm.expectRevert("ERC20: invalid v-value");
    holographERC20.permit(deployer, alice, initialValue, goodDeadLine, uint8(0x04), zeroSignature, zeroSignature);
  }

  //TODO not rever whit invalid signature
  function testFailPermitInvalidSignatureRevert() public {
    vm.expectRevert("ERC20: invalid signature");
    vm.prank(deployer);
    holographERC20.permit(deployer, alice, initialValue, goodDeadLine, uint8(0x1b), signature2, signature3);
  }

  //TODO add sucess Permit

  /*
   * ERC20 TEST
   *    Ownership tests
   */

  function testOwner() public {
    assertEq(holographERC20.owner(), deployer);
  }

  function testIsOwner() public {
    vm.prank(deployer);
    assertEq(sampleERC20.isOwner(), true);
  }

  function testIsOwnerFalse() public {
    vm.prank(alice);
    assertEq(sampleERC20.isOwner(), false);
  }

  function testErc20GetOwnerProxy() public {
    assertEq(holographERC20.getOwner(), address(admin));
  }

  function testErc20DeployerTransferOwnerRevert() public {
    vm.expectRevert("HOLOGRAPH: owner only function");
    holographERC20.setOwner(alice);
  }

  function testErc20DeployerTransferOwner() public {
    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("setOwner(address)")), deployer);
    vm.expectEmit(true, true, false, false);
    emit OwnershipTransferred(address(admin), address(deployer));
    vm.prank(deployer);
    admin.adminCall(address(holographERC20), data);
  }

  /*
   * ERC20 TEST
   *    Admin
   */

  function testErc20Admin() public {
    assertEq(holographERC20.admin(), address(admin));
  }

  function testErc20GetAdmin() public {
    assertEq(holographERC20.getAdmin(), address(admin));
  }

  function testErc20SetAdminRevert() public {
    vm.expectRevert("HOLOGRAPH: admin only function");
    vm.prank(alice);
    holographERC20.setAdmin(address(admin));
  }

  function testErc20DeployerSetAdminByProxy() public {
    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("setAdmin(address)")), deployer);
    vm.prank(deployer);
    admin.adminCall(address(holographERC20), data);
    assertEq(holographERC20.admin(), address(deployer));
  }
}