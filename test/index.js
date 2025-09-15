const { ethers } = require('hardhat')

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