// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test} from "../../../lib/forge-std/src/Test.sol";
import {Vm} from "../../../lib/forge-std/src/Vm.sol";
import {console} from "../../../lib/forge-std/src/console.sol";
import {Constants} from "../utils/Constants.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";
import {ERC20Mock} from "../../../src/mock/ERC20Mock.sol";
import {Admin} from "../../../src/abstract/Admin.sol";
import {PermitSigUtils} from "../utils/PermitSigUtils.sol";

contract Erc20Enforcer is Test {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC20 holographERC20;
  SampleERC20 sampleERC20;
  ERC20Mock erc20Mock;
  Admin admin;
  PermitSigUtils permitSigUtils;
  // TODO modificar tokenname en el setup()
  string tokenName = "Sample ERC20 Token (localhost)";
  string tokenSymbol = "SMPL";
  uint16 tokenDecimals = 18;
  string totalTokens = "12.34";
  uint256 totalTokensWei = 12340000000000000000;
  uint256 smallerAmount = 123400000000000000;
  uint256 initialToken = 1;
  //string privateKeyDeployer = vm.envString("DEPLOYER");
  uint256 privateKeyDeployer = 0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b;
  address deployer = vm.addr(privateKeyDeployer);
  address wallet1 = vm.addr(0x2315c2a66e6b3af2dca804fe89ce6b51fc6041f5486d9f4acd43921112c18891);
  address wallet2 = vm.addr(0x0223ee02bf483df57329ea337954be6bf39c107fd2e1f40c2a5059d3ed197f96);
  address wallet3 = vm.addr(0x09af83e24107abcca31a24e7a03cf5f1fff0d444daeba974c6a11ebe3ba0be7b);
  //address erc20Mock = vm.addr(0x6eF2a267742D2EdA91cE4f3D875a91c599e5e079);
  address zeroAddress = address(0);
  uint256 maxValue = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  uint256 halfValue = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 halfInverseValue = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 badDeadLine;
  uint256 goodDeadLine;
  bytes32 zeroSignature = bytes32(abi.encode(0x0000000000000000000000000000000000000000000000000000000000000000));
  bytes32 signature = bytes32(abi.encode(0x1111111111111111111111111111111111111111111111111111111111111111));
  bytes32 signature2 = bytes32(abi.encode(0x35353535353535353535353535353535353535353535353535353535353535));
  bytes32 signature3 = bytes32(abi.encode(0x68686868686868686868686868686868686868686868686868686868686868));
  event Transfer(address indexed from, address indexed to, uint256 amount);
  event Approval(address indexed owner, address indexed spender, uint256 amount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    //holographERC20 = HolographERC20(payable(Constants.getHolographERC20()));
    //sampleERC20 = SampleERC20(payable(Constants.getHolographERC20()));
    // Modificar address cada vez que se vuelve a hacer el deploy (pooner el address de Sample ERC20)
    holographERC20 = HolographERC20(payable(address(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3)));
    sampleERC20 = SampleERC20(payable(address(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3)));
    erc20Mock = ERC20Mock(payable(Constants.getERC20Mock()));
    badDeadLine = uint256(block.timestamp) - 1;
    goodDeadLine = uint256(block.timestamp);
    admin = Admin(payable(Constants.getHolographFactoryProxy()));
    permitSigUtils = new PermitSigUtils(holographERC20.DOMAIN_SEPARATOR());
  }

  function buildDomainSeparator(
    string memory name,
    string memory version,
    address contractAddress
  ) public view returns (bytes32) {
    bytes32 nameHash = keccak256(bytes(name));
    bytes32 versionHash = keccak256(bytes(version));
    bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    return
      keccak256(
        abi.encodePacked(
          typeHash,
          nameHash,
          versionHash,
          uint256(block.chainid),
          address(Constants.getHolographERC20())
        )
      );
  }

  ////////

  function testName() public {
    assertEq(holographERC20.name(), tokenName);
  }

  function testSymbol() public {
    assertEq(holographERC20.symbol(), tokenSymbol);
  }

  function testDecimals() public {
    assertEq(holographERC20.decimals(), tokenDecimals);
  }

  //////////////////////////////
  // Mint ERC20 tokens

  function testTotalSupply() public {
    assertEq(holographERC20.totalSupply(), 0);
  }

  function testTransferEvent() public {
    //Emite el evento Transfer al llamar a la función mint del contrato
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(0), deployer, 1000000);
    vm.prank(deployer);
    sampleERC20.mint(deployer, 1000000);
    //assertEq(holographERC20.totalSupply(), 1000000);
  }

  function testTotalSupplyAfterMint() public {
    // Verifica que el totalSupply sea igual a la cantidad de tokens
    vm.prank(deployer);
    sampleERC20.mint(deployer, 1000000);
    assertEq(holographERC20.totalSupply(), 1000000);
  }

  function testDeployerWalletBalance() public {
    // Verifica que el balance de la wallet del deployer sea igual a la cantidad de tokens
    vm.prank(deployer);
    sampleERC20.mint(deployer, 1000000);
    assertEq(holographERC20.balanceOf(deployer), 1000000);
  }

  ///////////////
  // Test ERC20

  function testApproveZeroAddress() public {
    // Verifica que el intento de aprobar una wallet con dirección cero falle
    vm.expectRevert("ERC20: spender is zero address");
    holographERC20.approve(zeroAddress, maxValue);
  }

  function testApproveValidAddress() public {
    // Verifica que el intento de aprobar una wallet válida tenga éxito
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, maxValue);
    vm.prank(deployer);
    holographERC20.approve(wallet2, maxValue);
  }

  function testDecreaseAllowanceAboveZero() public {
    // Verifica que el intento de disminuir el límite de aprobación por encima de cero tenga éxito
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, maxValue);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, halfInverseValue);
    vm.prank(deployer);
    holographERC20.decreaseAllowance(wallet2, halfValue);
  }

  function testDecreaseAllowanceBelowZero() public {
    // Verifica que el intento de disminuir el límite de aprobación por debajo de cero falle
    vm.expectRevert("ERC20: decreased below zero");
    holographERC20.decreaseAllowance(wallet2, maxValue);
  }

  function testIncreaseAllowanceBelowMaxValue() public {
    // Verifica que el intento de aumentar el límite de aprobación por debajo del valor máximo tenga éxito
    // vm.prank(deployer);
    // holographERC20.approve(wallet2, maxValue);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, maxValue);
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, maxValue);
  }

  function testIncreaseAllowanceAboveMaxValue() public {
    // Verifica que aumentar el límite de aprobación por encima del valor máximo falle
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, 1);
    vm.expectRevert("ERC20: increased above max value");
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, maxValue);
  }

  function testDecreaseAllowanceToZero() public {
    // Verifica que disminuir el límite de aprobación a cero tenga éxito
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, maxValue);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, 0);
    vm.prank(deployer);
    holographERC20.decreaseAllowance(wallet2, maxValue);
  }

  function testIncreaseAllowanceToMaxValue() public {
    // Verifica que aumentar el límite de aprobación al valor máximo tenga éxito
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, maxValue);
    vm.prank(deployer);
    holographERC20.increaseAllowance(wallet2, maxValue);
  }

  ////////////////////
  // failed transfer (linea 309)

  function testTransferExceedsBalance() public {
    // Verifica que el intento de transferir más tokens de los que se tienen falle
    vm.expectRevert("ERC20: amount exceeds balance");
    holographERC20.transfer(wallet1, totalTokensWei + 1);
  }

  function testTransferToZeroAddress() public {
    // Verifica que el intento de transferir tokens a una dirección cero falle
    vm.expectRevert("ERC20: recipient is zero address");
    holographERC20.transfer(zeroAddress, 1);
  }

  function testTransferFromZeroAddress() public {
    // Verifica que el intento de transferir tokens desde una dirección cero falle
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.transferFrom(zeroAddress, wallet1, 1);
  }

  function testTransferFromUnapprovedAddress() public {
    // Verifica que el intento de transferir tokens desde una dirección no aprobada falle
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.transferFrom(wallet1, deployer, 1);
  }

  function testApproveSmallerAllowance() public {
    // Revierte cuando el allowance es menor que el monto que se quiere transferir
    vm.prank(deployer);
    holographERC20.approve(wallet2, smallerAmount);
    vm.expectRevert("ERC20: amount exceeds allowance");
    vm.prank(wallet2);
    holographERC20.transferFrom(deployer, wallet1, totalTokensWei);
  }

  function testNonContractOnERC20ReceivedCall() public {
    // Verifies that calling onERC20Received with a non-contract address fails
    vm.expectRevert("ERC20: operator not contract");
    holographERC20.onERC20Received(deployer, deployer, totalTokensWei, "0x");
  }

  function skiptestFakeOnERC20Received() public {
    // Verifies that calling onERC20Received with a fake contract address fails (355)
    //vm.skip(true);
    vm.expectRevert("ERC20: balance check failed");
    holographERC20.onERC20Received(address(erc20Mock), deployer, totalTokensWei, "0x");
  }

  function skiptestSafeTransferForERC20Receiver() public {
    erc20Mock.toggleWorks(false);
    vm.expectRevert("ERC20: non ERC20Receiver");
    holographERC20.safeTransfer(address(erc20Mock), totalTokensWei);
    erc20Mock.toggleWorks(true);
  }

  function testFailSafeTransferForERC20ReceiverWithBytes() public {
    vm.expectRevert("ERC20: non ERC20Receiver");
    erc20Mock.toggleWorks(false);
    holographERC20.safeTransfer(
      address(erc20Mock),
      totalTokensWei,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
  }

  function skiptestSafeTransferFromErc20Receiver() public {
    erc20Mock.toggleWorks(false);
    holographERC20.approve(wallet1, maxValue);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(wallet1);
    holographERC20.safeTransferFrom(deployer, address(erc20Mock), totalTokensWei);
    erc20Mock.toggleWorks(true);
  }

  function skiptestSafeTransferFromErc20ReceiverWithBytes() public {
    erc20Mock.toggleWorks(false);
    holographERC20.approve(wallet1, maxValue);
    vm.expectRevert("ERC20: non ERC20Receiver");
    vm.prank(wallet1);
    holographERC20.safeTransferFrom(
      deployer,
      address(erc20Mock),
      totalTokensWei,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
    erc20Mock.toggleWorks(true);
  }

  //////////////////
  // successful transfer

  function testTransferAvailableTokens() public {
    // Verifies that transferring available tokens emits the Transfer event
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(deployer), wallet1, totalTokensWei);
    vm.prank(deployer);
    holographERC20.transfer(wallet1, totalTokensWei);
  }

  function testDeployerBalanceZeroTokens() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.transfer(wallet1, totalTokensWei);
    assertEq(holographERC20.balanceOf(deployer), 0);
  }

  function testWallet1TokensBalance() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.transfer(wallet1, totalTokensWei);
    assertEq(holographERC20.balanceOf(wallet1), totalTokensWei);
  }

  function testSafelyTransferAvailableTokens() public {
    vm.prank(deployer);
    sampleERC20.mint(wallet1, totalTokensWei);
    vm.prank(wallet1);
    holographERC20.safeTransfer(deployer, totalTokensWei);
  }

  function testSafelyTransferFromAvailableTokens() public {
    // should succeed when safely transferring from available tokens
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.approve(wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, wallet1, totalTokensWei);
    vm.prank(wallet1);
    holographERC20.safeTransferFrom(deployer, wallet1, totalTokensWei);
  }

  // dos test que dependen del anterior

  function testTransferingUsingApprovedSpender() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.approve(wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, wallet1, totalTokensWei);
    vm.prank(wallet1);
    holographERC20.transferFrom(deployer, wallet1, totalTokensWei);
    assertEq(holographERC20.allowance(deployer, wallet1), 0);
  }

  function testSafeTransferToERC20Reciver() public {
    erc20Mock.toggleWorks(true);
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.safeTransfer(address(erc20Mock), totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(address(erc20Mock), deployer, totalTokensWei);
    erc20Mock.transferTokens(payable(holographERC20), deployer, totalTokensWei);
  }

  function testSafeTransferToErc20ReciverWithBytes() public {
    erc20Mock.toggleWorks(true);
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, address(erc20Mock), totalTokensWei);
    vm.prank(deployer);
    holographERC20.safeTransfer(
      address(erc20Mock),
      totalTokensWei,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
  }

  function testSafeTransferFromToERC20Receiver() public {
    erc20Mock.toggleWorks(true);
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.approve(wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, address(erc20Mock), totalTokensWei);
    vm.prank(wallet1);
    holographERC20.safeTransferFrom(deployer, address(erc20Mock), totalTokensWei);
    assertEq(holographERC20.allowance(deployer, wallet1), 0);
  }

  function testSafeTransforToErc20FromBytes() public {
    erc20Mock.toggleWorks(true);
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.approve(wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, address(erc20Mock), totalTokensWei);
    vm.prank(wallet1);
    holographERC20.safeTransferFrom(
      deployer,
      address(erc20Mock),
      totalTokensWei,
      bytes(abi.encode("0x0000000000000000000000000000000000000000"))
    );
    assertEq(holographERC20.allowance(deployer, wallet1), 0);
  }

  ///// Test ERC20Burneable

  function testBurnMoreTokensThanCurrentBalance() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.expectRevert("ERC20: amount exceeds balance");
    vm.prank(wallet1);
    holographERC20.burn(totalTokensWei);
  }

  function testBurnCurrentBalance() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.burn(totalTokensWei);
    assertEq(holographERC20.totalSupply(), 0);
  }

  function testBurnNotApprovedSpencer() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.expectRevert("ERC20: amount exceeds allowance");
    vm.prank(wallet1);
    holographERC20.burnFrom(deployer, totalTokensWei);
  }

  function testBurnApprovedSpencer() public {
    vm.prank(deployer);
    sampleERC20.mint(deployer, totalTokensWei);
    vm.prank(deployer);
    holographERC20.approve(wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Transfer(deployer, zeroAddress, totalTokensWei);
    vm.prank(wallet1);
    holographERC20.burnFrom(deployer, totalTokensWei);
  }

  //// Test ERC20Permit

  function testCheckDomainSeparator() public {
    // Check domain seperator
    // TODO REVISAR
    assertEq(
      holographERC20.DOMAIN_SEPARATOR(),
      buildDomainSeparator("Sample ERC20 Token", "1", address(holographERC20))
    );
  }

  function testReturnZeroNounce() public {
    assertEq(holographERC20.nonces(wallet1), 0);
  }

  function testExpiredDadline() public {
    vm.expectRevert("ERC20: expired deadline");
    holographERC20.permit(deployer, wallet1, maxValue, badDeadLine, uint8(0x00), zeroSignature, zeroSignature);
  }

  function testEmptySignature() public {
    vm.expectRevert("ERC20: zero address signer");
    holographERC20.permit(deployer, wallet1, maxValue, goodDeadLine, uint8(0x1b), zeroSignature, zeroSignature);
  }

  function testZeroAddressSignature() public {
    vm.expectRevert("ERC20: zero address signer");
    holographERC20.permit(deployer, wallet1, maxValue, goodDeadLine, uint8(0x1b), signature, signature);
  }

  function testInvalidSignatureVValue() public {
    // V-Value tiene que valer 27 o 28
    vm.expectRevert("ERC20: invalid v-value");
    holographERC20.permit(deployer, wallet1, maxValue, goodDeadLine, uint8(0x04), zeroSignature, zeroSignature);
  }

  function testInvalidSignature() public {
    vm.expectRevert("ERC20: invalid signature");
    holographERC20.permit(deployer, wallet1, maxValue, goodDeadLine, uint8(0x1b), signature2, signature3);
  }

  function testValidSignature() public {
    PermitSigUtils.Permit memory permit = PermitSigUtils.Permit({
      owner: deployer,
      spender: wallet1,
      value: maxValue,
      nonce: holographERC20.nonces(wallet1),
      deadline: goodDeadLine
    });

    bytes32 digest = permitSigUtils.getTypedDataHash(permit);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKeyDeployer, digest);

    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet1, maxValue);
    holographERC20.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

    // assertEq(token.allowance(owner, spender), 1e18);
    // assertEq(token.nonces(owner), 1);
  }

  //////// Ownership Tests

  function testOwner() public {
    assertEq(holographERC20.owner(), deployer);
  }

  function testIsOwner() public {
    vm.prank(deployer);
    assertEq(sampleERC20.isOwner(), true);
  }

  function testIsNotOwner() public {
    vm.prank(wallet1);
    assertEq(sampleERC20.isOwner(), false);
  }

  function testHolopgraphFactoryProxyAddress() public {
    assertEq(holographERC20.getOwner(), address(admin));
  }

  function testTransferOwnershipFail() public {
    vm.expectRevert("HOLOGRAPH: owner only function");
    holographERC20.setOwner(wallet1);
  }

  function testSetOwnerToDeployer() public {
    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("setOwner(address)")), deployer);
    vm.expectEmit(true, true, false, false);
    emit OwnershipTransferred(address(admin), address(deployer));
    vm.prank(deployer);
    admin.adminCall(address(holographERC20), data);
  }

  function testTransferOwnership() public {
    testSetOwnerToDeployer();
    vm.expectEmit(true, true, false, true);
    emit OwnershipTransferred(address(deployer), address(admin));
    vm.prank(deployer);
    holographERC20.setOwner(address(admin));
  }

  /////// Test Admin

  function testERC20Admin() public {
    assertEq(holographERC20.admin(), address(admin));
  }

  function testERC20GetAdmin() public {
    assertEq(holographERC20.getAdmin(), address(admin));
  }

  function testERC20SetAdminRevert() public {
    vm.expectRevert("HOLOGRAPH: admin only function");
    vm.prank(wallet1);
    holographERC20.setAdmin(address(admin));
  }

  function testDeployerSetsAdminViaHolographFactoryProxy() public {
    bytes memory data = abi.encodeWithSelector(bytes4(keccak256("setOwner(address)")), deployer);
    vm.expectEmit(true, true, false, false);
    emit OwnershipTransferred(address(admin), address(deployer));
    vm.prank(deployer);
    admin.adminCall(address(holographERC20), data);
  }
}
