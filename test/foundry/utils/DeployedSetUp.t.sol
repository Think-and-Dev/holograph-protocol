// // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";
import {Constants} from "./Constants.sol";

contract DeployedSetUp is Test {
  address holographInterfacesDeployed;
  address holographDeployed;
  address holographERC721Deployed;
  address cxipERC721ProxyDeployed;
  address cxipERC721Deployed;
  address erc20MockDeployed;
  address holographBridgeDeployed;
  address holographBridgeProxyDeployed;
  address holographERC20Deployed;
  address holographFactoryDeployed;
  address holographFactoryProxyDeployed;
  address holographGenesisDeployed;
  address holographOperatorDeployed;
  address holographOperatorProxyDeployed;
  address holographRegistryDeployed;
  address holographRegistryProxyDeployed;
  address holographTreasuryDeployed;
  address holographTreasuryProxyDeployed;

  address hTokenDeployed;
  address mockERC721ReceiverDeployed;
  address holographRoyaltiesDeployed;
  address sampleERC20Deployed;
  address sampleERC721Deployed;

  function setUp() public virtual {
    holographInterfacesDeployed = Constants.getHolographInterfaces();
    holographDeployed = Constants.getHolograph();
    holographERC721Deployed = Constants.getHolographERC721();
    cxipERC721ProxyDeployed = Constants.getCxipERC721Proxy();
    cxipERC721Deployed = Constants.getCxipERC721();
    erc20MockDeployed = Constants.getERC20Mock();
    holographBridgeDeployed = Constants.getHolographBridge();
    holographBridgeProxyDeployed = Constants.getHolographBridgeProxy();
    holographERC20Deployed = Constants.getHolographERC20();
    holographFactoryDeployed = Constants.getHolographFactory();
    holographFactoryProxyDeployed = Constants.getHolographFactoryProxy();
    holographGenesisDeployed = Constants.getHolographGenesis();
    holographOperatorDeployed = Constants.getHolographOperator();
    holographOperatorProxyDeployed = Constants.getHolographOperatorProxy();
    holographRegistryDeployed = Constants.getHolographRegistry();
    holographRegistryProxyDeployed = Constants.getHolographRegistryProxy();
    holographTreasuryDeployed = Constants.getHolographTreasury();
    holographTreasuryProxyDeployed = Constants.getHolographTreasuryProxy();
    hTokenDeployed = Constants.getHToken();
    mockERC721ReceiverDeployed = Constants.getMockERC721Receiver();
    holographRoyaltiesDeployed = Constants.getHolographRoyalties();
    sampleERC20Deployed = Constants.getSampleERC20();
    sampleERC721Deployed = Constants.getSampleERC721();
  }
}
