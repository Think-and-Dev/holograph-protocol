import yargs from 'yargs/yargs';
import { hideBin } from 'yargs/helpers';
import { parse } from 'csv-parse';
import * as z from 'zod';
import { Contract, ethers } from 'ethers';
import { appendFileSync, createReadStream, existsSync, unlinkSync } from 'fs';
import path from 'path';
import { ZodError } from 'zod';
import { destructSignature, encryptDecrypt, flattenObject, generateRandomSalt, parseBytes } from './utils';
import { LedgerSigner } from '@anders-t/ethers-ledger';
import { getEnvironment } from '@holographxyz/environment';
import { TransactionReceipt, TransactionResponse } from '@ethersproject/abstract-provider';
import { getNetworkByChainId } from '@holographxyz/networks';
import { customErc721Bytecode } from './custom-erc721-bytecode';

require('dotenv').config();

/**
 * TODO:
 *  - Validate URI for arweave
 *  - validate ENVs
 */

/**
 * This script will be used to set create the NFT ranges, encrypt the URI, and finally decrypt later.
 * Usage: `npx ts-node scripts/encrypt-batch-ranges.ts`
 */

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

export const REVEAL_MAP_CSV_HEADER =
  'BatchId,Name,Range,PlaceholderURI Path,PlaceholderURI CID,RevealURI Path,RevealURI CID,Key,EncryptedURI,Should Decrypt';

const FileColumnsSchema = z.object({
  ['BatchId']: z.number(),
  ['Name']: z.string().trim(),
  ['Range']: z.number(),
  ['PlaceholderURI Path']: z.string().trim(),
  ['RevealURI Path']: z.string().trim(),
  ['Key']: z.string().trim(),
  ['ProvenanceHash']: z.string().trim().optional(),
  ['EncryptedURI']: z.string().trim().optional(),
  ['Should Decrypt']: z.boolean(),
});

type FileColumnsType = z.infer<typeof FileColumnsSchema>;

function validateHeader(headerKeys: string[]): void {
  const expectedKeys = Object.keys(FileColumnsSchema.shape);

  for (let i = 0; i < headerKeys.length; i++) {
    if (headerKeys[i].trim() !== expectedKeys[i]) {
      throw new Error(
        `Header column name mismatch at column ${i + 1}. Expected: ${expectedKeys[i]}, Found: ${headerKeys[i]}`
      );
    }
  }
}

async function readCsvFile(filePath: string): Promise<string[][]> {
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

async function parseRowsContent(lines: string[][]) {
  const data = lines.map((line) => {
    const [batchId, name, range, placeholderUriPath, revealUriPath, key, provenanceHash, encryptedUri, shouldDecrypt] =
      line;
    return {
      ['BatchId']: parseInt(batchId),
      ['Name']: name,
      ['Range']: parseInt(range),
      ['PlaceholderURI Path']: placeholderUriPath,
      ['RevealURI Path']: revealUriPath,
      ['Key']: key,
      ['ProvenanceHash']: provenanceHash,
      ['EncryptedURI']: encryptedUri,
      ['Should Decrypt']: shouldDecrypt.toLowerCase() === 'true',
    };
  });

  const validatedData: FileColumnsType[] = data.map((row, index) => {
    try {
      const parsedRow: FileColumnsType = FileColumnsSchema.parse(row);
      return parsedRow;
    } catch (error) {
      if (error instanceof ZodError) {
        console.error(`Validation error at line ${index}: `, error);
      }
      //throw error;
      throw new Error(`Row ${index + 1} has an error`);
    }
  });

  return validatedData;
}

type Hex = `0x${string}`;

type CustomERC721SalesConfiguration = {
  presaleStart: number;
  presaleEnd: number;
  publicSalePrice: number;
  maxSalePurchasePerAddress: number;
  presaleMerkleRoot: Hex;
};

type LazyMintConfiguration = {
  amount: number; // The amount of tokens to lazy mint (basically the batch size)
  baseURIForTokens: string; // The base URI for the tokens in this batch
  data: Hex; // The data to be used to set the encrypted URI. A bytes containing a sub bytes and a bytes32 => abi.encode(bytes(0x00..0), bytes32(0x00..0));
};

type CustomERC721Initializer = {
  startDate: number;
  initialMaxSupply: number;
  mintInterval: number; // Duration of each interval
  initialOwner: Hex;
  fundsRecipient: Hex;
  contractURI: string;
  salesConfiguration: CustomERC721SalesConfiguration;
  lazyMintsConfigurations: LazyMintConfiguration[];
};

const REGISTRY_ADDRESS = '0xB47C0E0170306583AA979bF30c0407e2bFE234b2';
const HolographFactoryABI = ''; //TODO: get abi

async function main() {
  const args = yargs(hideBin(process.argv))
    .options({
      file: {
        type: 'string',
        description: 'reveal csv file',
        alias: 'file',
      },
    })
    .parseSync();

  const { file } = args as { file: string };

  /// LOAD SENSITIVE INFORMATION SAFELY

  const privateKey = process.env.PRIVATE_KEY as string;
  const providerURL = process.env.CUSTOM_ERC721_PROVIDER_URL as string;
  const salt = process.env.CUSTOM_ERC721_SALT as string; // Salt is used for deterministic address generation
  const provider = new ethers.providers.JsonRpcProvider(providerURL);
  let chainId: number = await provider.getNetwork().then((network: any) => network.chainId);

  let deployer;
  if (process.env.HARDWARE_WALLET_ENABLED === 'true') {
    deployer = new LedgerSigner(provider, "44'/60'/0'/0/0");
  } else {
    deployer = new ethers.Wallet(privateKey, provider);
  }
  const deployerAddress: Hex = (await deployer.getAddress()) as Hex;

  // Get the ENVIRONMENT
  //  const ENVIRONMENT = getEnvironment()

  // Get the ABI
  //  const abis = await getABIs(ENVIRONMENT)
  //  const holograph = new Contract(HOLOGRAPH_ADDRESSES[ENVIRONMENT], abis.HolographABI, provider)
  //  const factoryProxyAddress = (await holograph.getFactory()).toLowerCase()
  const factoryProxyAddress = REGISTRY_ADDRESS; //TODO: change this

  // Set the static values for custom erc721
  const contractName = 'CustomERC721';
  const contractSymbol = 'C721';
  const contractURI = 'https://example.com/metadata.json';
  const contractBps = 0;
  const startDate = 1718822400; // Epoch time for June 3, 2024
  const initialMaxSupply = 4173120; // Total number of ten-minute intervals until Oct 8, 2103
  const mintInterval = 600; // Duration of each interval
  const initialOwner = deployerAddress;
  const fundsRecipient = deployerAddress;
  // set static values for sales config
  const presaleStart = 0; // never starts
  const presaleEnd = 0; // never ends
  const publicSalePrice = 100;
  const maxSalePurchasePerAddress = 0; // no limit
  const presaleMerkleRoot = `0x${'00'.repeat(32)}` as Hex; // no presale

  /// CSV FILE VALIDATION

  const csvData = await readCsvFile(file);

  if (csvData.length === 0) {
    throw new Error(`File is empty!`);
  }
  const [headerKeys, ...lines] = csvData;

  console.log(`Validating header...`);
  validateHeader(headerKeys.filter(Boolean));

  console.log(`Validating rows...`);
  const parsedRows: FileColumnsType[] = await parseRowsContent(lines);

  deleteCSVFile(file);
  writeCSVFile(file, Object.keys(FileColumnsSchema.shape).join(','));

  let lazyMintConfiguration: LazyMintConfiguration[] = [];

  console.log(`Generating provenance hash and encrypting URIs...`);
  for (let parsedRow of parsedRows) {
    if (!parsedRow.EncryptedURI || !parsedRow.ProvenanceHash) {
      parsedRow.ProvenanceHash = ethers.utils.keccak256(
        ethers.utils.solidityPack(['string', 'bytes', 'uint256'], [parsedRow['RevealURI Path'], parsedRow.Key, chainId])
      );
      parsedRow.EncryptedURI = encryptDecrypt(parsedRow['RevealURI Path'], parsedRow.Key);
      const data = Object.values(parsedRow).join(',');
      writeCSVFile(file, data);
    }

    // Encode _data parameter
    const data = ethers.utils.defaultAbiCoder.encode(
      ['bytes', 'bytes32'],
      [ethers.utils.toUtf8Bytes(parsedRow.EncryptedURI), parsedRow.ProvenanceHash]
    ) as `0x${string}`;

    lazyMintConfiguration.push({
      amount: parsedRow.Range,
      baseURIForTokens: parsedRow['PlaceholderURI Path'],
      data,
    });
  }

  console.log(`Starting deploy...`);

  // Deploy the CustomERC721 custom contract source

  const saleConfig: CustomERC721SalesConfiguration = {
    presaleStart,
    presaleEnd,
    publicSalePrice,
    maxSalePurchasePerAddress,
    presaleMerkleRoot,
  };

  const CustomERC721Initializer: CustomERC721Initializer = {
    startDate,
    initialMaxSupply,
    mintInterval,
    initialOwner,
    fundsRecipient,
    contractURI,
    salesConfiguration: saleConfig,
    lazyMintsConfigurations: lazyMintConfiguration,
  };

  const customERC721InitCode = ethers.utils.defaultAbiCoder.encode(
    [
      'tuple(uint40,uint32,uint24,address,address,string,tuple(uint104,uint24,uint64,uint64,bytes32),tuple(uint256,string,bytes)[])',
    ],
    [flattenObject(CustomERC721Initializer)]
  );

  const initCodeEncoded: Hex = ethers.utils.defaultAbiCoder.encode(
    ['bytes32, address, bytes'],
    [parseBytes('CustomERC721'), REGISTRY_ADDRESS, customERC721InitCode]
  );

  const encodedInitParameters = ethers.utils.defaultAbiCoder.encode(
    ['string, string, uint16, uint256, bool, bytes'],
    [
      contractName,
      contractSymbol,
      contractBps,
      BigInt(`0x${'00'.repeat(32)}`), // eventConfig
      false, // skipInit
      initCodeEncoded,
    ]
  );

  const deploymentConfig = {
    contractType: parseBytes('HolographERC721'),
    chainType: getNetworkByChainId(chainId).holographId,
    byteCode: customErc721Bytecode,
    initCode: encodedInitParameters,
    salt: generateRandomSalt(),
  };

  // keccak256(encodePacked())
  const deploymentConfigHash = ethers.utils.solidityKeccak256(
    ['bytes32', 'uint32', 'bytes32', 'bytes32', 'bytes32', 'address'],
    [
      deploymentConfig.contractType,
      deploymentConfig.chainType,
      deploymentConfig.salt,
      ethers.utils.keccak256(deploymentConfig.byteCode),
      ethers.utils.keccak256(deploymentConfig.initCode),
      deployerAddress,
    ]
  );

  const signedMessage = await deployer.signMessage(deploymentConfigHash!);
  const signature = destructSignature(signedMessage);

  const fullDeploymentConfig = {
    config: deploymentConfig,
    signature: {
      r: signature.r,
      s: signature.s,
      v: Number.parseInt(signature.v, 16),
    },
    signer: deployerAddress,
  };

  console.log(`Preparing to deploy CustomERC721 contract...`);

  // Create a contract instance
  const contract = new Contract(factoryProxyAddress, HolographFactoryABI, deployer);

  console.log('Calling deployHolographableContract...');
  try {
    const tx: TransactionResponse = await contract.deployHolographableContract(
      fullDeploymentConfig.config,
      fullDeploymentConfig.signature,
      fullDeploymentConfig.signer
    );
    console.log('Transaction:', tx);
    const receipt: TransactionReceipt = await tx.wait();
    console.log('Transaction receipt:', receipt);

    // if (receipt === null) {
    //   throw new Error('Failed to confirm that the transaction was mined');
    // } else {
    //   const logs: any[] | undefined = decodeBridgeableContractDeployedEvent(receipt, factoryProxyAddress);
    //   if (logs === undefined) {
    //     throw new Error('Failed to extract transfer event from transaction receipt');
    //   } else {
    //     const deploymentAddress = logs[0] as string;
    //     console.log(`Contract has been deployed to address ${deploymentAddress} on ${'targetNetwork'} network`);
    //   }
    // }
  } catch (error) {
    console.error('Error:', error);
  }

  console.log(`Exiting script ✅\n`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
