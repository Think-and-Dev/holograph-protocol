// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {ICustomERC721Errors} from "test/foundry/interface/ICustomERC721Errors.sol";

import {CustomERC721Fixture} from "test/foundry/fixtures/CustomERC721Fixture.t.sol";

import {Test, Vm} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {DeploymentConfig} from "../../src/struct/DeploymentConfig.sol";
import {Verification} from "../../src/struct/Verification.sol";
import {DropsInitializerV2} from "../../src/drops/struct/DropsInitializerV2.sol";
import {CustomERC721Initializer} from "../../src/struct/CustomERC721Initializer.sol";
import {SalesConfiguration} from "../../src/drops/struct/SalesConfiguration.sol";

import {HolographFactory} from "../../src/HolographFactory.sol";
import {HolographTreasury} from "../../src/HolographTreasury.sol";

import {MockUser} from "./utils/MockUser.sol";
import {Constants} from "./utils/Constants.sol";
import {Utils} from "./utils/Utils.sol";
import {HolographerInterface} from "../../src/interface/HolographerInterface.sol";

import {CustomERC721} from "src/token/CustomERC721.sol";
import {HolographERC721} from "../../src/enforcer/HolographERC721.sol";
import {HolographDropERC721V2} from "../../src/drops/token/HolographDropERC721V2.sol";

import {IMetadataRenderer} from "../../src/drops/interface/IMetadataRenderer.sol";
import {DummyMetadataRenderer} from "./utils/DummyMetadataRenderer.sol";
import {DropsMetadataRenderer} from "../../src/drops/metadata/DropsMetadataRenderer.sol";
import {EditionsMetadataRenderer} from "../../src/drops/metadata/EditionsMetadataRenderer.sol";

import {DropsPriceOracleProxy} from "../../src/drops/proxy/DropsPriceOracleProxy.sol";
import {DummyDropsPriceOracle} from "../../src/drops/oracle/DummyDropsPriceOracle.sol";

contract CustomERC721Test is ICustomERC721Errors, Test {
  /// @notice Event emitted when the funds are withdrawn from the minting contract
  /// @param withdrawnBy address that issued the withdraw
  /// @param withdrawnTo address that the funds were withdrawn to
  /// @param amount amount that was withdrawn
  event FundsWithdrawn(address indexed withdrawnBy, address indexed withdrawnTo, uint256 amount);

  address public alice;
  MockUser public mockUser;

  CustomERC721 public customErc721;
  HolographTreasury public treasury;

  DummyMetadataRenderer public dummyRenderer = new DummyMetadataRenderer();
  EditionsMetadataRenderer public editionsMetadataRenderer;
  DropsMetadataRenderer public dropsMetadataRenderer;
  DummyDropsPriceOracle public dummyPriceOracle;

  uint104 constant usd10 = 10 * (10 ** 6); // 10 USD (6 decimal places)
  uint104 constant usd100 = 100 * (10 ** 6); // 100 USD (6 decimal places)
  uint104 constant usd1000 = 1000 * (10 ** 6); // 1000 USD (6 decimal places)

  address public constant DEFAULT_OWNER_ADDRESS = address(0x1);
  address payable public constant DEFAULT_FUNDS_RECIPIENT_ADDRESS = payable(address(0x2));
  address payable public constant HOLOGRAPH_TREASURY_ADDRESS = payable(address(0x3));
  address payable constant TEST_ACCOUNT = payable(address(0x888));
  address public constant MEDIA_CONTRACT = address(0x666);

  uint256 public constant FIRST_TOKEN_ID =
    115792089183396302089269705419353877679230723318366275194376439045705909141505; // large 256 bit number due to chain id prefix

  struct Configuration {
    uint64 editionSize;
    uint16 royaltyBPS;
    address payable fundsRecipient;
  }

  constructor() {}

  modifier setupTestCustomERC21(uint64 editionSize) {
    // Setup sale config for edition
    SalesConfiguration memory saleConfig = SalesConfiguration({
      publicSaleStart: 0, // starts now
      publicSaleEnd: type(uint64).max, // never ends
      presaleStart: 0, // never starts
      presaleEnd: 0, // never ends
      publicSalePrice: usd100,
      maxSalePurchasePerAddress: 0, // no limit
      presaleMerkleRoot: bytes32(0) // no presale
    });

    // Create initializer
    CustomERC721Initializer memory initializer = CustomERC721Initializer({
      initialOwner: payable(DEFAULT_OWNER_ADDRESS),
      fundsRecipient: payable(DEFAULT_FUNDS_RECIPIENT_ADDRESS),
      contractURI: "https://example.com",
      editionSize: 100,
      royaltyBPS: 1000,
      salesConfiguration: saleConfig
    });

    // Get deployment config, hash it, and then sign it
    DeploymentConfig memory config = getDeploymentConfig(
      "Testing Init", // contractName
      "BOO", // contractSymbol
      1000, // contractBps
      type(uint256).max, // eventConfig
      false, // skipInit
      initializer
    );
    bytes32 hash = keccak256(
      abi.encodePacked(
        config.contractType,
        config.chainType,
        config.salt,
        keccak256(config.byteCode),
        keccak256(config.initCode),
        alice
      )
    );

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);
    Verification memory signature = Verification(r, s, v);
    address signer = ecrecover(hash, v, r, s);
    require(signer == alice, "Invalid signature");

    HolographFactory factory = HolographFactory(payable(Constants.getHolographFactoryProxy()));

    // Deploy the drop / edition
    vm.recordLogs();
    factory.deployHolographableContract(config, signature, alice); // Pass the payload hash, with the signature, and signer's address
    Vm.Log[] memory entries = vm.getRecordedLogs();
    address newDropAddress = address(uint160(uint256(entries[2].topics[1])));

    // Connect the drop implementation to the drop proxy address
    customErc721 = CustomERC721(payable(newDropAddress));

    _;
  }

  function setUp() public {
    // Setup VM
    // NOTE: These tests rely on the Holograph protocol being deployed to the local chain
    //       At the moment, the deploy pipeline is still managed by Hardhat, so we need to
    //       first run it via `npx hardhat deploy --network localhost` or `yarn deploy:localhost` if you need two local chains before running the tests.
    uint256 forkId = vm.createFork("http://localhost:8545");
    vm.selectFork(forkId);

    // Setup signer wallet
    // NOTE: This is the address that will be used to sign transactions
    //       A signature is required to deploy Holographable contracts via the HolographFactory
    alice = vm.addr(1);

    vm.prank(HOLOGRAPH_TREASURY_ADDRESS);

    dummyPriceOracle = DummyDropsPriceOracle(Constants.getDummyDropsPriceOracle());

    // NOTE: This needs to be uncommented to inject the DropsPriceOracleProxy contract into the VM if it isn't done by the deploy script
    //       At the moment we have hardhat configured to deploy and inject the code approrpriately to match the hardcoded address in the HolographDropERC721V2 contract
    // We deploy DropsPriceOracleProxy at specific address
    // vm.etch(address(Constants.getDropsPriceOracleProxy()), address(new DropsPriceOracleProxy()).code);
    // We set storage slot to point to actual drop implementation
    // vm.store(
    //   address(Constants.getDropsPriceOracleProxy()),
    //   bytes32(uint256(keccak256("eip1967.Holograph.dropsPriceOracle")) - 1),
    //   bytes32(abi.encode(Constants.getDummyDropsPriceOracle()))
    // );
  }

  function test_DeployHolographCustomERC721() public {
    // Setup sale config for edition
    SalesConfiguration memory saleConfig = SalesConfiguration({
      publicSaleStart: 0, // starts now
      publicSaleEnd: type(uint64).max, // never ends
      presaleStart: 0, // never starts
      presaleEnd: 0, // never ends
      publicSalePrice: usd100,
      maxSalePurchasePerAddress: 0, // no limit
      presaleMerkleRoot: bytes32(0) // no presale
    });

    // Create initializer
    CustomERC721Initializer memory initializer = CustomERC721Initializer({
      initialOwner: payable(DEFAULT_OWNER_ADDRESS),
      fundsRecipient: payable(DEFAULT_FUNDS_RECIPIENT_ADDRESS),
      contractURI: "https://example.com",
      editionSize: 100,
      royaltyBPS: 1000,
      salesConfiguration: saleConfig
    });

    // Get deployment config, hash it, and then sign it
    DeploymentConfig memory config = getDeploymentConfig(
      "Testing Init", // contractName
      "BOO", // contractSymbol
      1000, // contractBps
      type(uint256).max, // eventConfig
      false, // skipInit
      initializer
    );
    bytes32 hash = keccak256(
      abi.encodePacked(
        config.contractType,
        config.chainType,
        config.salt,
        keccak256(config.byteCode),
        keccak256(config.initCode),
        alice
      )
    );

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);
    Verification memory signature = Verification(r, s, v);
    address signer = ecrecover(hash, v, r, s);
    require(signer == alice, "Invalid signature");

    HolographFactory factory = HolographFactory(payable(Constants.getHolographFactoryProxy()));

    // Deploy the drop / edition
    vm.recordLogs();
    factory.deployHolographableContract(config, signature, alice); // Pass the payload hash, with the signature, and signer's address
    Vm.Log[] memory entries = vm.getRecordedLogs();
    address newDropAddress = address(uint160(uint256(entries[2].topics[1])));

    // Connect the drop implementation to the drop proxy address
    customErc721 = CustomERC721(payable(newDropAddress));

    // assertEq(customErc721.version(), 1);
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

  // TEST HELPERS
  function getDeploymentConfig(
    string memory contractName,
    string memory contractSymbol,
    uint16 contractBps,
    uint256 eventConfig,
    bool skipInit,
    CustomERC721Initializer memory initializer
  ) public returns (DeploymentConfig memory) {
    bytes memory bytecode = abi.encodePacked(vm.getCode("CustomERC721Proxy.sol:CustomERC721Proxy"));
    bytes memory initCode = abi.encode(
      bytes32(0x0000000000000000000000000000000000000000437573746F6D455243373231), // Source contract type CustomERC721
      address(Constants.getHolographRegistryProxy()), // address of registry (to get source contract address from)
      abi.encode(initializer) // actual init code for source contract (CustomERC721)
    );

    return
      DeploymentConfig({
        contractType: Utils.stringToBytes32("HolographERC721"), // HolographERC721
        chainType: 1338, // holograph.getChainId(),
        salt: 0x0000000000000000000000000000000000000000000000000000000000000001, // random salt from user
        byteCode: bytecode, // custom contract bytecode
        initCode: abi.encode(contractName, contractSymbol, contractBps, eventConfig, skipInit, initCode) // init code is used to initialize the HolographERC721 enforcer
      });
  }
}
