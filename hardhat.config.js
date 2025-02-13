require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-waffle");
// require("@nomiclabs/hardhat-ethers");
//require('@chainlink/hardhat-chainlink');

require("dotenv").config();

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.6",
      },
    ],
  },
  networks: {
    sepolia: {
      url: process.env.INFURA_SEPOLIA_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    tabi: {
      url: "https://rpc.testnetv2.tabichain.com",
      accounts: [process.env.PRIVATE_KEY],
    },
    hardhat: {
      chainId: 1337,
      blockGasLimit: 30000000,
      gas: 12000000, 
    },
  },
};