import { ethers } from 'ethers';
import { hexlify, zeroPad } from '@ethersproject/bytes';
import { toUtf8Bytes } from '@ethersproject/strings';

type Hex = `0x${string}`;

/**
 * Encrypts or decrypts the given URL using the provided key (Replicate the behavior of DelayedReveal.sol::encryptDecrypt function)
 * @param url The URL to encrypt or decrypt
 * @param hexKey The key to use for encryption or decryption
 * @returns The encrypted or decrypted URL
 */
export function encryptDecrypt(url: string, hexKey: string): string {
  const encoder = new TextEncoder();
  const data = encoder.encode(url);
  const key = ethers.utils.arrayify(hexKey);

  const length = data.length;
  const result = new Uint8Array(length);

  for (let i = 0; i < length; i += 32) {
    const segmentLength = Math.min(32, length - i);
    const indexBytes = ethers.utils.zeroPad(ethers.utils.arrayify(i), 32); // Padding the index to 32 bytes
    const keySegment = ethers.utils.concat([key, indexBytes]); // Concatenating key and padded index

    const hash = ethers.utils.arrayify(ethers.utils.keccak256(keySegment));

    for (let j = 0; j < segmentLength; j++) {
      result[i + j] = data[i + j] ^ hash[j % 32];
    }
  }

  return ethers.utils.hexlify(result);
}

export function flattenObject(obj: Record<string, any>): any[] {
  return Object.values(obj).map((value: any) => {
    if (typeof value === 'object') {
      if (Array.isArray(value)) {
        value.map((item) => flattenObject(item));
      }
      return flattenObject(value); // Recursively flatten nested objects
    }
    return value;
  });
}

export function parseBytes(str: string, size = 32) {
  return hexlify(zeroPad(toUtf8Bytes(str), size));
}

export function generateRandomSalt() {
  return '0x' + Date.now().toString(16).padStart(64, '0');
}

export function destructSignature(signedMessage: Hex) {
  return {
    r: ('0x' + signedMessage.substring(2, 66)) as Hex,
    s: ('0x' + signedMessage.substring(66, 130)) as Hex,
    v: ('0x' + signedMessage.substring(130, 132)) as Hex,
  };
}
