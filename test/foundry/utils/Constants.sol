// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// NOTE: These are the addresses of the Holograph Protocol that depends on a couple .env variables being set
//       Those variable are:
//         HOLOGRAPH_ENVIRONMENT="develop"
//         DEVELOP_DEPLOYMENT_SALT=1000
//         DEPLOYER=0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b
//         LOCALHOST_DEPLOYER_SECRET=something
//
// These addresses are for the develop environment ONLY on localhost and are not meant to be used in production.
// They are generated from a localhost deployment using the custom HolographGenesisLocal.sol contract that is a
// modified version of the HolographGenesis.sol contract.
//
// The reason we use a custom version of the HolographGenesis.sol contract is because the original contract has
// dedicated approved deployers that do not include local test accounts. This allows us to test the Holograph Protocol
// on localhost without having to modify the original HolographGenesis.sol contract.
library Constants {
  function getHolographGenesis() internal pure returns (address) {
    return address(0x4c3BA951A7ea09b5BB57230F63a89D36A07B2992);
  }

  function getHolograph() internal pure returns (address) {
    return address(0x17253175f447ca4B560a87a3F39591DFC7A021e3);
  }

  function getHolographBridge() internal pure returns (address) {
    return address(0x0af817Df693A292a4b8b9ACC698199333eB0DD9e);
  }

  function getHolographBridgeProxy() internal pure returns (address) {
    return address(0x53D2B46b341385bC7e022667Eb1860505073D43a);
  }

  function getHolographFactory() internal pure returns (address) {
    return address(0xa574B1A37c9235d19D942DD4393f728d2a646FDe);
  }

  function getHolographFactoryProxy() internal pure returns (address) {
    return address(0xcE2cDFDF0b9D45F8Bd2D3CCa4033527301903FDe);
  }

  function getHolographOperator() internal pure returns (address) {
    return address(0x443d6F2051716473e0849fb475e19f09ed488404);
  }

  function getHolographOperatorProxy() internal pure returns (address) {
    return address(0xABc5a4C81D3033cf920b982E75D1080b91AA0EF9);
  }

  function getHolographRegistry() internal pure returns (address) {
    return address(0x1052ae1742fc6878010a31aA53671fEF7D51bf65);
  }

  function getHolographRegistryProxy() internal pure returns (address) {
    return address(0xB47C0E0170306583AA979bF30c0407e2bFE234b2);
  }

  function getHolographTreasury() internal pure returns (address) {
    return address(0x76c4fC0627405741Db0959E66d64c0ECeAceDC94);
  }

  function getHolographTreasuryProxy() internal pure returns (address) {
    return address(0x65115A3Be2Aa1F267ccD7499e720088060c7ccd2);
  }

  function getHolographInterfaces() internal pure returns (address) {
    return address(0x67F6394693bd2B46BBE87627F0E581faD80C7B57);
  }

  function getHolographRoyalties() internal pure returns (address) {
    return address(0xbF8f7474D7aCbb87E270FEDA9A5CBB7f766887E3);
  }

  function getHolographUtilityToken() internal pure returns (address) {
    return address(0x56BA455232a82784F17C33c577124EF208D931ED);
  }

  function getDropsPriceOracleProxy() internal pure returns (address) {
    return address(0x655FC5B66322AEF43A01dBc7198e08ab163662c3);
  }

  function getDummyDropsPriceOracle() internal pure returns (address) {
    return address(0x98E2Ed9849B14E541454Ae6202b4cA06627269C1);
  }

  function getHolographERC20() internal pure returns (address) {
    return address(0xbC6Cf78c63d5f4C8D5aC56F096928AA742cbAC25);
  }

  function getHolographERC721() internal pure returns (address) {
    return address(0x3337B6e8eF94D36D21406c75Fe8d88E74381c071);
  }

  function getCxipERC721Proxy() internal pure returns (address) {
    return address(0x2869c23117e1432850a09dE5ea7eA294E8fa2431);
  }

  function getCxipERC721Proxy_L2() internal pure returns (address) {
    return address(0x56c1401d1b10BE49924e207c158618702ed90090);
  }

  function getCxipERC721() internal pure returns (address) {
    return address(0xE7AD7a544fa0262256F035Da6F77e396A271eA4C);
  }

  function getHToken() internal pure returns (address) {
    return address(0xEe7804e943659DB09338718F0B4123117A085109);
  }

  // NOTE: This has to be updated to the correct address every time a new contract is added to be
  //       deployed within the hardhat deploy pipeline
  function getERC20Mock() internal pure returns (address) {
    return address(0x71B7f5A882F25c7292d0Ae5fa6d78129f431b957);
  }

  // NOTE: This has to be updated to the correct address every time a new contract is added to be
  //       deployed within the hardhat deploy pipeline
  function getMockERC721Receiver() internal pure returns (address) {
    return address(0x3a95a5263bb12083088c0A11296B18655121C9Ec);
  }

  function getSampleERC20() internal pure returns (address) {
    return address(0x5a5DbB0515Cb2af1945E731B86BB5e34E4d0d3A3);
  }

  function getSampleERC20_L2() internal pure returns (address) {
    return address(0x5A919e00Ae425cebf7a836f703284026BBb51186);
  }

  function getSampleERC721() internal pure returns (address) {
    return address(0x846Af4c87F5Af1F303E5a5D215D83A611b08069c);
  }

  function getSampleERC721_L2() internal pure returns (address) {
    return address(0xB94053201514E26133770eA1351959AffF0DE684);
  }

  function getZeroAddress() internal pure returns (address) {
    return address(0x0000000000000000000000000000000000000000);
  }

  function getDropsEventConfig() internal pure returns (uint256) {
    return 0x0000000000000000000000000000000000000000000000000000000000040000;
  }
  function getHolographDropERC721V2() internal pure returns (address) {
    return address(0x30F9D1c28584e0874dEE1b2f0101D77077D316e4);
  }
  function getEditionsMetadataRendererProxy() internal pure returns (address) {
    return address(0xdF26982B2D5A4904757f6099b939c0eBcFE70668);
  }
  function getHolographDropERC721() internal pure returns (address) {
    return address(0xc4aE0619B36BC57227DC258472E57A7265C5f2aA);
  }
  function getHolographIdL1() internal pure returns (uint32) {
    return 4294967294;
  }

  function getHolographIdL2() internal pure returns (uint32) {
    return 4294967293;
  }

  function getDeployer() internal pure returns (address) {
    return address(0xdf5295149F367b1FBFD595bdA578BAd22e59f504);
  }

  function getPKDeployer() internal pure returns (uint256) {
    return uint256(0xff22437ccbedfffafa93a9f1da2e8c19c1711052799acf3b58ae5bebb5c6bd7b);
  }

  address public constant zeroAddress = address(0x0000000000000000000000000000000000000000);
  address public constant originAddress = address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
  bytes32 public constant saltHex = bytes32(0x00000000000000000000000000000000000000000000000000000000000003e8);
}

library ErrorConstants {
  string constant ONLY_ADMIN_ERROR_MSG = "HOLOGRAPH: admin only function";
  string constant ALREADY_INITIALIZED_ERROR_MSG = "HOLOGRAPH: already initialized";
  string constant ALREADY_DEPLOYED_ERROR_MSG = "HOLOGRAPH: already deployed";
  string constant INVALID_SIGNATURE_ERROR_MSG = "HOLOGRAPH: invalid signature";
  string constant HOLOGRAPHER_ALREADY_INITIALIZED_ERROR_MSG = "HOLOGRAPHER: already initialized";
  string constant ROYALTIES_ALREADY_INITIALIZED_ERROR_MSG = "ROYALTIES: already initialized";
  string constant FACTORY_ONLY_ERROR_MSG = "HOLOGRAPH: factory only function";
  string constant EMPTY_CONTRACT_ERROR_MSG = "HOLOGRAPH: empty contract";
  string constant CONTRACT_ALREADY_SET_ERROR_MSG = "HOLOGRAPH: contract already set";
  string constant ROYALTIES_ONLY_OWNER_ERROR_MSG = "ROYALTIES: caller not an owner";
}
