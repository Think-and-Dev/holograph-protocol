// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import {CustomERC721} from "src/token/CustomERC721.sol";

contract CustomERC721Handler is CustomERC721 {
    function getNextTokenIdToLazyMint() external view returns (uint256) {
        return nextTokenIdToLazyMint;
    }

    function getBaseUri(uint256 tokenId) external view returns (string memory) {
        return _getBaseURI(tokenId);
    }
}
