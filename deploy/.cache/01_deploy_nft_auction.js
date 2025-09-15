const {deployments,upgrades, ethers} = require("hardhat")
const fs = require("fs")
const path = require("path");


module.exports = async ({ getNamedAccounts, deployments }) => {
    const { save } = deployments;
    const { deployer } = await getNamedAccounts();
    console.log("部署者地址",deployer);
    const NftAuction = await ethers.getContractFactory("NftAuction")
  
    //通过代理部署合约
    const nftAuctionProxy = await upgrades.deployProxy(NftAuction,[],{
        initializer: "initialize",
    })
    await nftAuctionProxy.waitForDeployment()
    
    const nftAuctionAddress = await nftAuctionProxy.getAddress()
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(nftAuctionAddress)
    console.log("代理合约地址", nftAuctionAddress)
    console.log("代理合约实现地址", implementationAddress)

    const storePath = path.join(__dirname, "./.cache/proxyNftAuction.json")
    fs.writeFileSync(
        storePath,
        JSON.stringify({ 
            address: nftAuctionAddress,
            implementation: implementationAddress,
            abi: NftAuction.interface.format("json")
        }))
    
    await save("NftAuctionProxy", {
        abi: NftAuction.interface.format("json"),
        address: nftAuctionAddress,
    })
//   await deploy("MyContract", {
//     from: deployer,
//     args: ["Hello"],
//     log: true,
//   });
};
// add tags and dependencies
module.exports.tags = ["deployNFTAuction"];