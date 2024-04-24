// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/* ----------------------------- Init constants ----------------------------- */

uint256 constant DEFAULT_MINT_PRICE = 0.1 ether;
uint256 constant DEFAULT_MAX_PURCHASE_PER_ADDRESS = 20;
uint256 constant DEFAULT_PUBLIC_SALE_START = 5 days;
uint256 constant DEFAULT_PUBLIC_SALE_END = 10 days;
uint256 constant DEFAULT_PRESALE_START = 1 days;
uint256 constant DEFAULT_PRESALE_END = 5 days - 1;
bytes32 constant DEFAULT_PRESALE_MERKLE_ROOT = keccak256("random-merkle-root");

/* ----------------------------- Collection data ---------------------------- */

string constant DEFAULT_BASE_URI = "https://url.com/uri/";
string constant DEFAULT_BASE_URI_2 = "https://url.com/uri2/";
string constant DEFAULT_PLACEHOLDER_URI = "https://url.com/not-revealed/";
string constant DEFAULT_PLACEHOLDER_URI_2 = "https://url.com/not-revealed-2/";
bytes constant DEFAULT_ENCRYPT_DECRYPT_KEY = abi.encode("random-encrypt-decrypt-key");
bytes constant DEFAULT_ENCRYPT_DECRYPT_KEY_2 = abi.encode("random-encrypt-decrypt-key-2");

uint40 constant DEFAULT_START_DATE = 1718822400; // Epoch time for June 3, 2024
uint32 constant DEFAULT_MAX_SUPPLY = 4173120; // Total number of ten-minute intervals until Oct 8, 2103
uint24 constant DEFAULT_MINT_INTERVAL = 10 minutes; // Duration of each interval
