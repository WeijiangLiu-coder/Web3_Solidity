const {ethers,upgrades} = require("hardhat")
const path = require("path");
const fs = require("fs"); // 如果你用到了fs，也需要确保导入

module.exports = async function ({getNamedAccounts, deployments}) {
    const {save} = deployments
    const {deployer} = await getNamedAccounts()
    console.log("部署者地址", deployer);
    
    //读取.cache/proxyNftAuction.json文件
    const storePath = path.resolve(__dirname, "./.cache/proxyNftAuction.json")
    const storeData = fs.readFileSync(storePath, "utf-8")
    const {address,implAddress,abi} = JSON.parse(storeData)
    const NftAuction = await ethers.getContractFactory("NftAuction")

    //升级版的合约
    const NftAuctionV2 = await ethers.getContractFactory("NftAuctionV2")

    //升级合约
    const nftAuctionProxyV2 = await upgrades.upgradeProxy(address, NftAuctionV2)
    await nftAuctionProxyV2.waitForDeployment()
    const proxyAddressV2 = nftAuctionProxyV2.getAddress()

    await save("NftAuctionV2", {
        abi: abi,
        address: proxyAddressV2,
    })
}
module.exports.tags = ["upgradeNftAuction"]