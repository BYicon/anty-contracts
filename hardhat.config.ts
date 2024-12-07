import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "./tasks";
import * as envEnc from "@chainlink/env-enc";
envEnc.config();

console.log(process.env.SEPOLIA_RPC_URL);

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const PRIVATE_KEY_MAIN = process.env.PRIVATE_KEY_MAIN as string;
const PRIVATE_KEY = process.env.PRIVATE_KEY as string;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY as string;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY, PRIVATE_KEY_MAIN],
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  },
  namedAccounts: {
    owner369: {
      default: 0
    },
    maine27ee: {
      default: 1
    },
  },
};

export default config;
