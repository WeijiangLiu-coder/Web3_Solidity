const { ethers,deployments } = require('hardhat')
const { expect } = require('chai')
describe('Starting test', async function () {
  it('Should deploy and call', async function () {
    const Contract = await ethers.getContractFactory('NftAuction')
    const contract = await Contract.deploy()
    await contract.waitForDeployment()

    const resp = await contract.createAuction(
        100*1000,
        ethers.parseEther('0.001'),
        ethers.ZeroAddress,
        1
    )
    const auction0 = await contract.auctions(0)
    console.log(auction0);
    
  })
})

describe('Test upgrade', async function () {
  it('Should deploy and call', async function () {
    //部署业务合约
    await deployments.fixture(['NftAuction'])

    const nftAuctionProxy = await deployments.get('NftAuctionProxy')
    //调用createAuction 函数
    const nftAuction = await ethers.getContractAt('NftAuction', nftAuctionProxy.address)
    const resp = await nftAuction.createAuction(
        100*1000,
        ethers.parseEther('0.001'),
        ethers.ZeroAddress,
        1
    )
    const aunction0 = await nftAuction.auctions(0)
    console.log("创建拍卖成功", aunction0);

    //升级合约
    await deployments.fixture(['upgradeNftAuction'])

    //读取auction0
    const aunctionV20 = await nftAuction.auctions(0)
    expect(aunctionV20.startTime).to.be.equal(aunction0.startTime)
  })
})