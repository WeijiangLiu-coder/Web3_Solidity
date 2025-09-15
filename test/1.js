const {ethers,deployments} = require("hardhat")
const { expect } = require("chai");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Test Auction",async function() {
    it("Should be ok",async function() {
        await main()
    });
})

async function main() {
    await deployments.fixture(["deployNFTAuction"])
    const nftAuctionProxy = await deployments.get("NftAuctionProxy")

    const [singer,buyer] = await ethers.getSigners()

    //部署ERC721合约
    const TestERC721 = await ethers.getContractFactory("TestERC721")
    const testERC721 = await TestERC721.deploy()
    await testERC721.waitForDeployment()
    const testERC721Address = await testERC721.getAddress()
    console.log("testERC721Address:",testERC721Address)
    
    //mint 10个Nft
    for(let i=1;i<=10;i++){
        await testERC721.mint(singer.address,i)
    }
    const tokenId = 1
    //调用createAuction 方法创建拍卖
    console.log("Debug ->: nftAuctionProxy.address",nftAuctionProxy.address)
    const nftAuction = await ethers.getContractAt(
        "NftAuction",
        nftAuctionProxy.address)
    //给代理合约授权
    await testERC721.connect(singer).setApprovalForAll(await nftAuction.getAddress(), true)
    console.log("Debug ->: testERC721")
    await nftAuction.createAuction(
        60,
        ethers.parseEther("0.01"),
        testERC721Address,
        tokenId,
    )
    const auction = await nftAuction.auctions(0)
    console.log("createAuction success ->")

    //购买者
    // 买家无需授权，授权由 NFT 拥有者(singer)授予给拍卖合约

    await nftAuction.connect(buyer).placeBid(0,{value: ethers.parseEther("0.02")})
    //结束拍卖
    await time.increase(61)

    await nftAuction.connect(singer).endAuction(0)
    //验证结果
    const auctionResult = await nftAuction.auctions(0)
    console.log("endAuction success ->",)
    console.log("endAuction success before->", auctionResult.highestBidder,buyer.address)
    expect(auctionResult.highestBidder).to.equal(buyer.address)
    expect(auctionResult.highestBid).to.equal(ethers.parseEther("0.02"))

    console.log("owner ->",await testERC721.ownerOf(tokenId))
    //验证购买者是否获得NFT
    const owner = await testERC721.ownerOf(tokenId)
    expect(owner).to.equal(buyer.address)
    console.log("buy success ->",owner)
}