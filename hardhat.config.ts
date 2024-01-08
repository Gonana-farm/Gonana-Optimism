import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@eth-optimism/plugins/hardhat-ovm";

const INFURA_API_KEY = "99ce4c3038e14823b3f9ec5d2694fcea"; // Replace with your Infura API key
const PRIVATE_KEY = "983d2adc31773b8152a0b78121baa750231204f5d0182c502efee3b76d841817"; // Replace with your private key

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19", // Change to your Solidity version
  },
  networks: {
    optimismKovan: {
      url: "https://kovan.optimism.io", // Optimism Kovan (Sepolia) testnet RPC URL
      // ovm: true, // Enable OVM (Optimistic Virtual Machine)
      accounts: [PRIVATE_KEY], // Array of private keys to use
    },
    optimismSepolia: {
      url: `https://optimism-sepolia.infura.io/v3/${INFURA_API_KEY}`,
    }
  },
  paths: {
    artifacts: "./artifacts",
  },
};

export default config;
