import path from 'path';
import { parse } from 'csv-parse';
import { ethers, Contract, Signer } from 'ethers';
import { Environment } from '@holographxyz/environment';
import { hexlify, zeroPad } from '@ethersproject/bytes';
import { JsonRpcProvider, Log } from '@ethersproject/providers';
import { appendFileSync, createReadStream, existsSync, unlinkSync } from 'fs';
import { TransactionReceipt, TransactionResponse } from '@ethersproject/abstract-provider';

import { DeploymentConfigSettings, Hex } from './types';

export const writeCSVFile = (filePath: string, data: string, breakLine = true) => {
  try {
    appendFileSync(`${filePath}`, breakLine ? data + '\n' : data);
  } catch (err) {
    console.error(err);
  }
};

export const deleteCSVFile = (filePath: string) => {
  try {
    const path = `${filePath}`;
    if (existsSync(path)) {
      unlinkSync(path);
    }
  } catch (err) {
    console.error(err);
  }
};

export async function readCsvFile(filePath: string): Promise<string[][]> {
  const records: any[] = [];
  const extension = path.extname(filePath);

  if (extension !== '.csv') {
    throw new Error('The file is not a CSV file.');
  }

  return new Promise((resolve) => {
    createReadStream(`${filePath}`)
      .pipe(parse({ delimiter: ',' }))
      .on('data', (data: any) => {
        records.push(data);
      })
      .on('end', () => {
        resolve(records);
      });
  });
}

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

export function parseBytes(str: string, size = 32): Hex {
  return hexlify(zeroPad(ethers.utils.toUtf8Bytes(str), size)) as Hex;
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

export function getHolographAddress(environment: Environment) {
  const HOLOGRAPH_ADDRESSES: { [key in Environment]: string } = {
    [Environment.localhost]: '0x17253175f447ca4B560a87a3F39591DFC7A021e3'.toLowerCase(),
    [Environment.experimental]: '0x199728d88a68856868f50FC259F01Bb4D2672Da9'.toLowerCase(),
    [Environment.develop]: '0x11bc5912f9ed5E16820f018692f8E7FDA91a8529'.toLowerCase(),
    [Environment.testnet]: '0x1Ed99DFE7462763eaF6925271D7Cb2232a61854C'.toLowerCase(),
    [Environment.mainnet]: '0x1Ed99DFE7462763eaF6925271D7Cb2232a61854C'.toLowerCase(),
  };

  return HOLOGRAPH_ADDRESSES[environment];
}

export async function getFactoryAddress(provider: JsonRpcProvider, environment: Environment): Promise<Hex> {
  const getFactoryABI = ['function getFactory() view returns (address factory)'];
  const holograph = new Contract(getHolographAddress(environment), getFactoryABI, provider);
  try {
    const factoryProxyAddress: string = await holograph.getFactory();
    return factoryProxyAddress.toLowerCase() as Hex;
  } catch (error) {
    throw new Error(`Failed to get HolographFactory address.`, { cause: error });
  }
}

export async function getRegistryAddress(provider: JsonRpcProvider, environment: Environment): Promise<Hex> {
  const getRegistryABI = ['function getRegistry() view returns (address registry)'];
  const holograph = new Contract(getHolographAddress(environment), getRegistryABI, provider);
  try {
    const registryProxyAddress: string = await holograph.getRegistry();
    return registryProxyAddress.toLowerCase() as Hex;
  } catch (error) {
    throw new Error(`Failed to get HolographRegistry address.`, { cause: error });
  }
}

export async function deployHolographableContract(
  deployer: Signer,
  factoryProxyAddress: Hex,
  fullDeploymentConfig: DeploymentConfigSettings
): Promise<Hex> {
  const holographFactoryABI = [
    'function deployHolographableContract(tuple(bytes32 contractType, uint32 chainType, bytes32 salt, bytes byteCode, bytes initCode) config, tuple(bytes32 r, bytes32 s,uint8 v) signature,address signer) public',
  ];
  const contract = new Contract(factoryProxyAddress, holographFactoryABI, deployer);

  console.log('Calling deployHolographableContract...');

  let tx: TransactionResponse;
  try {
    tx = await contract.deployHolographableContract(
      fullDeploymentConfig.config,
      fullDeploymentConfig.signature,
      fullDeploymentConfig.signer
    );
  } catch (error) {
    throw new Error(`Failed to deploy the contract.`, { cause: error });
  }

  console.log('Transaction:', tx.hash);
  const receipt: TransactionReceipt = await tx.wait();

  if (receipt?.status === 1) {
    console.log('The transaction was executed successfully! Getting the contract address from logs... ');

    const bridgeableContractDeployedTopic = '0xa802207d4c618b40db3b25b7b90e6f483e16b2c1f8d3610b15b345a718c6b41b';
    const bridgeableContractDeployedLog: Log | undefined = receipt.logs.find(
      (log: Log) => log.topics[0] === bridgeableContractDeployedTopic
    );

    if (bridgeableContractDeployedLog) {
      const deploymentAddress = bridgeableContractDeployedLog.topics[1];
      return ethers.utils.getAddress(`0x${deploymentAddress.slice(26)}`).toLowerCase() as Hex;
    } else {
      throw new Error('Failed to extract transfer event from transaction receipt.');
    }
  } else {
    throw new Error('Failed to confirm the transaction.');
  }
}
