// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test} from "../../../lib/forge-std/src/Test.sol";
import {Vm} from "../../../lib/forge-std/src/Vm.sol";
import {console} from "../../../lib/forge-std/src/console.sol";
import {Constants} from "../utils/Constants.sol";
import {SampleERC20} from "../../../src/token/SampleERC20.sol";
import {HolographERC20} from "../../../src/enforcer/HolographERC20.sol";

contract Erc20Enforcer is Test {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC20 holographERC20;
  SampleERC20 sampleERC20;
  // TODO modificar tokenname en el setup()
  string tokenName = "Sample ERC20 Token (localhost)";
  string tokenSymbol = "SMPL";
  uint16 tokenDecimals = 18;
  string totalTokens = "12.34";
  uint256 totalTokensWei = 12340000000000000000;
  uint256 smallerAmount = 123400000000000000;
  uint256 initialToken = 1;
  //string privateKeyDeployer = vm.envString("DEPLOYER");
  address deployer = vm.addr(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
  address wallet1 = vm.addr(0x2315c2a66e6b3af2dca804fe89ce6b51fc6041f5486d9f4acd43921112c18891);
  address wallet2 = vm.addr(0x0223ee02bf483df57329ea337954be6bf39c107fd2e1f40c2a5059d3ed197f96);
  address wallet3 = vm.addr(0x09af83e24107abcca31a24e7a03cf5f1fff0d444daeba974c6a11ebe3ba0be7b);
  address zeroAddress = address(0);
  uint256 maxValue = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  uint256 halfValue = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 halfInverseValue = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  event Transfer(address indexed from, address indexed to, uint256 amount);
  event Approval(address indexed owner, address indexed spender, uint256 amount);

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    //holographERC20 = HolographERC20(payable(Constants.getHolographERC20()));
    //sampleERC20 = SampleERC20(payable(Constants.getHolographERC20()));
    // Modificar address cada vez que se vuelve a hacer el deploy
    holographERC20 = HolographERC20(payable(address(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3)));
    sampleERC20 = SampleERC20(payable(address(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3)));
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
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, halfInverseValue);
    vm.prank(deployer);
    holographERC20.approve(wallet2, halfInverseValue);
    //TODO Ver por que falla : Reason: revert: ERC20: decreased below zero
    holographERC20.decreaseAllowance(wallet2, halfValue);
  }

  function testDecreaseAllowanceBelowZero() public {
    // Verifica que el intento de disminuir el límite de aprobación por debajo de cero falle
    vm.expectRevert("ERC20: decreased below zero");
    holographERC20.decreaseAllowance(wallet2, maxValue);
  }

  function testIncreaseAllowanceBelowMaxValue() public {
    // Verifica que el intento de aumentar el límite de aprobación por debajo del valor máximo tenga éxito
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, maxValue);
    vm.prank(deployer);
    holographERC20.approve(wallet2, maxValue);
    holographERC20.increaseAllowance(wallet2, halfValue);
  }

  function testIncreaseAllowanceAboveMaxValue() public {
    // Verifica que aumentar el límite de aprobación por encima del valor máximo falle
    vm.expectRevert("ERC20: increased above max value");
    //TODO FAIL. Reason: call did not revert as expected
    holographERC20.increaseAllowance(wallet2, maxValue);
  }

  function testDecreaseAllowanceToZero() public {
    // Verifica que disminuir el límite de aprobación a cero tenga éxito
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, 0);
    vm.prank(deployer);
    holographERC20.approve(wallet2, 0);
    //TODO FAIL. Reason: revert: ERC20: decreased below zero
    holographERC20.decreaseAllowance(wallet2, maxValue);
  }

  function testIncreaseAllowanceToMaxValue() public {
    // Verifica que aumentar el límite de aprobación al valor máximo tenga éxito
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, maxValue);
    vm.prank(deployer);
    holographERC20.approve(wallet2, maxValue);
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
    //TODO En lugar de 1 poner el valor de tokensWei
    holographERC20.transfer(zeroAddress, 1);
  }

  function testTransferFromZeroAddress() public {
    // Verifica que el intento de transferir tokens desde una dirección cero falle
    vm.expectRevert("ERC20: amount exceeds allowance");
    //TODO En lugar de 1 poner el valor de tokensWei
    holographERC20.transferFrom(zeroAddress, wallet1, 1);
  }

  function testTransferFromUnapprovedAddress() public {
    // Verifica que el intento de transferir tokens desde una dirección no aprobada falle
    vm.expectRevert("ERC20: amount exceeds allowance");
    //TODO En lugar de 1 poner el valor de tokensWei
    holographERC20.transferFrom(wallet1, deployer, 1);
  }

  function testApproveSmallerAllowance() public {
    // TODO: Chequear, son tres test en uno? (335)
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, smallerAmount);
    vm.prank(deployer);
    holographERC20.approve(wallet2, smallerAmount);
    vm.expectRevert("ERC20: amount exceeds allowance");
    holographERC20.transferFrom(deployer, wallet1, totalTokensWei);
    vm.expectEmit(true, true, false, true);
    emit Approval(deployer, wallet2, 0);
    vm.prank(deployer);
    holographERC20.approve(wallet2, 0);
  }

  function testNonContractOnERC20ReceivedCall() public {
    // Verifies that calling onERC20Received with a non-contract address fails
    vm.expectRevert("ERC20: operator not contract");
    holographERC20.onERC20Received(deployer, deployer, totalTokensWei, "0x");
  }

  // function testFakeOnERC20Received() public {
  //   // Verifies that calling onERC20Received with a fake contract address fails
  //   vm.expectRevert("ERC20: balance check failed");
  //   holographERC20.onERC20Received(erc20Mock, deployer, totalTokensWei, "0x");
  // }
}
