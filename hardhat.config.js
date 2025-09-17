require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/eb3c018d46cf41798b2aa8c77dd77019",
      accounts: ["2c66d171d4efb1336386deb36ecdb5ef73a1ac4a51ff969d28b49c5e534686e8"]
    }
  },
  etherscan: {
    apiKey: "AQYBYX82RCTZ9NI5C196TMTFUZBFC5M7VN"
  },
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2
  }
};
