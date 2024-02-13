require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-gas-reporter");
require("@nomicfoundation/hardhat-chai-matchers");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */

const goerli_rpc = process.env.goerli_rpc_url
const goerli_pk = process.env.goerli_pk
const etherscan_api_key = process.env.etherscan_api_key
const coinmarketcap = process.env.coinmarketcap
const sepolia_rpc = process.env.sepolia_rpc_url
const sepolia_pk = process.env.sepolia_pk

module.exports = {
  solidity : {
    compilers: [
      {version : "0.8.17"},
      {version : "0.8.0"},
    ]
  },
  defaultNetwork: "hardhat",
  
  etherscan : {
    apiKey : {
      blast_sepolia: etherscan_api_key
    },
    customChains: [
      {
        network: "blast_sepolia",
        chainId: 168587773,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
          browserURL: "https://testnet.blastscan.io"
        }
      }
    ]
  },

  networks : {
    goerli: {
      url:  goerli_rpc , 
      accounts: [goerli_pk,],
      chainId: 5,
      blockConfirmations : 6,
      gasPrice: 5000000

    },
    sepolia: {
      url: sepolia_rpc,
      accounts: [sepolia_pk],
      chainId: 11155111,
      blockConfirmations : 6,
      gasPrice: 5000000
    },
    blast_sepolia: {
      url: "https://rpc.ankr.com/blast_testnet_sepolia",
      chainId: 168587773,
      accounts: [sepolia_pk],
      blockConfirmations : 6,
      gasPrice: 5000000
    },
  },
  gasReporter : {
    enabled: true,
    outputFile : "gas_report.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap : coinmarketcap,
  },


  namedAccounts : {
    deployer : {
        default:0
    },
    seller : {
      default : 1
    },
    buyer : {
      default: 2
    }
  }
};

