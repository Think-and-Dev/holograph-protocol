// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

library CustomERC721Helper {
  
  function encryptDecrypt(bytes memory data, bytes calldata key) public pure returns (bytes memory result) {
    // Store data length on stack for later use
    uint256 length = data.length;

    // solhint-disable-next-line no-inline-assembly
    assembly {
      // Set result to free memory pointer
      result := mload(0x40)
      // Increase free memory pointer by lenght + 32
      mstore(0x40, add(add(result, length), 32))
      // Set result length
      mstore(result, length)
    }

    // Iterate over the data stepping by 32 bytes
    for (uint256 i = 0; i < length; i += 32) {
      // Generate hash of the key and offset
      bytes32 hash = keccak256(abi.encodePacked(key, i));

      bytes32 chunk;
      // solhint-disable-next-line no-inline-assembly
      assembly {
        // Read 32-bytes data chunk
        chunk := mload(add(data, add(i, 32)))
      }
      // XOR the chunk with hash
      chunk ^= hash;
      // solhint-disable-next-line no-inline-assembly
      assembly {
        // Write 32-byte encrypted chunk
        mstore(add(result, add(i, 32)), chunk)
      }
    }
  }

}
