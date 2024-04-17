// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

uint256 constant MINT_PRICE = 0.1 ether;
uint256 constant MAX_SUPPLY = 4_000_000;
uint256 constant MAX_PURCHASE_PER_ADDRESS = 20;
uint256 constant PUBLIC_SALE_START = 5 days;
uint256 constant PUBLIC_SALE_END = 10 days;
uint256 constant PRESALE_START = 1 days;
uint256 constant PRESALE_END = 5 days - 1;
bytes32 constant PRESALE_MERKLE_ROOT = keccak256("random-merkle-root");
string constant BASE_URI = "https://url.com/uri/";
string constant PLACEHOLDER_URI = "https://url.com/not-revealed/";
bytes constant ENCRYPT_DECRYPT_KEY = abi.encode("random-encrypt-decrypt-key");
