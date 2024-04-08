// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "../utils/Constants.sol";
import {HolographERC20} from "../../../contracts/enforcer/HolographERC20.sol";

contract Erc20Enforcer is Test {
  uint256 localHostFork;
  string LOCALHOST_RPC_URL = vm.envString("LOCALHOST_RPC_URL");
  HolographERC20 holographERC20;
  string tokenName = "Holograph ERC20 Token";
  string tokenSymbol = "HolographERC20";
  uint16 tokenDecimals = 18;

  function setUp() public {
    localHostFork = vm.createFork(LOCALHOST_RPC_URL);
    vm.selectFork(localHostFork);
    holographERC20 = HolographERC20(payable(Constants.getHolographERC20()));
  }

  function testName() public {
    assertEq(holographERC20.name(), tokenName);
  }

  function testSymbol() public {
    assertEq(holographERC20.symbol(), tokenSymbol);
  }

  function testDecimals() public {
    assertEq(holographERC20.decimals(), tokenDecimals);
  }

}
