/*HOLOGRAPH_LICENSE_HEADER*/

/*SOLIDITY_COMPILER_VERSION*/

import "../abstract/ERC721H.sol";

import "../interface/ERC721Holograph.sol";

import "../library/Strings.sol";

/**
 * @title Sample ERC-721 Collection that is bridgeable via Holograph
 * @author CXIP-Labs
 * @notice A smart contract for minting and managing Holograph Bridgeable ERC721 NFTs.
 * @dev The entire logic and functionality of the smart contract is self-contained.
 */
contract SampleERC721 is ERC721H {
  /*
   * @dev Address of initial creator/owner of the collection.
   */
  address private _owner;

  mapping(uint256 => string) private _tokenURIs;

  /*
   * @dev Internal reference used for minting incremental token ids.
   */
  uint224 private _currentTokenId;

  modifier onlyOwner(address msgSender) {
    require(msgSender == _owner, "owner only function");
    _;
  }

  /**
   * @notice Constructor is empty and not utilised.
   * @dev To make exact CREATE2 deployment possible, constructor is left empty. We utilize the "init" function instead.
   */
  constructor() {}

  /**
   * @notice Initializes the collection.
   * @dev Special function to allow a one time initialisation on deployment. Also configures and deploys royalties.
   */
  function init(bytes memory data) external override returns (bytes4) {
    // do your own custom logic here
    address owner = abi.decode(data, (address));
    _owner = owner;
    // run underlying initializer logic
    return _init(data);
  }

  /**
   * @notice Get's the URI of the token.
   * @dev Defaults the the Arweave URI
   * @return string The URI.
   */
  function tokenURI(uint256 _tokenId) external view onlyHolographer returns (string memory) {
    return _tokenURIs[_tokenId];
  }

  /*
   * @dev Sample mint where anyone can mint any token, with a custom URI
   */
  function mint(
    address msgSender,
    address to,
    string calldata URI
  ) external onlyHolographer onlyOwner(msgSender) {
    _currentTokenId++;
    ERC721Holograph(holographer()).sourceMint(to, _currentTokenId);
    uint256 _tokenId = ERC721Holograph(holographer()).sourceGetChainPrepend() + uint256(_currentTokenId);
    _tokenURIs[_tokenId] = URI;
  }

  function test(address msgSender) external view onlyHolographer returns (string memory) {
    return string(abi.encodePacked("it works! ", Strings.toHexString(msgSender)));
  }

  function bridgeIn(
    uint32, /* _chainId*/
    address, /* _from*/
    address, /* _to*/
    uint256 _tokenId,
    bytes calldata _data
  ) external override onlyHolographer returns (bool) {
    string memory URI = abi.decode(_data, (string));
    _tokenURIs[_tokenId] = URI;
    return true;
  }

  function bridgeOut(
    uint32, /* _chainId*/
    address, /* _from*/
    address, /* _to*/
    uint256 _tokenId
  ) external view override onlyHolographer returns (bytes memory _data) {
    _data = abi.encode(_tokenURIs[_tokenId]);
  }

  function afterBurn(
    address, /* _owner*/
    uint256 _tokenId
  ) external override onlyHolographer returns (bool) {
    delete _tokenURIs[_tokenId];
    return true;
  }
}