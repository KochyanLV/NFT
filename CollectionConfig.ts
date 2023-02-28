import CollectionConfigInterface from '../lib/CollectionConfigInterface';
import * as Networks from '../lib/Networks';
import * as Marketplaces from '../lib/Marketplaces';
import whitelistAddresses from './whitelist.json';

const CollectionConfig: CollectionConfigInterface = {
  testnet: Networks.ethereumTestnet,
  mainnet: Networks.ethereumMainnet,
  // The contract name can be updated using the following command:
  // yarn rename-contract NEW_CONTRACT_NAME
  // Please DO NOT change it manually!
  contractName: 'Pandapoldem',
  tokenName: 'PandaPolis Sep22',
  tokenSymbol: 'PPD',
  hiddenMetadataUri: 'ipfs://QmPtCadHGR1NiuqiGCC5CoVLVNJQfNpjoM4Q6t4JkBcbVE/hidden.json',
  maxSupply: 5000,
  whitelistSale: {
    price: 0.02,
    maxMintAmountPerTx: 5,
  },
  preSale: {
    price: 0.02,
    maxMintAmountPerTx: 2,
  },
  publicSale: {
    price: 0.02,
    maxMintAmountPerTx: 5,
  },
  contractAddress: "0x0C25f15F9198EeEB19EDDA531d4910a8Cc709be2",
  marketplaceIdentifier: 'my-nft-token',
  marketplaceConfig: Marketplaces.openSea,
  whitelistAddresses,
};

export default CollectionConfig;
