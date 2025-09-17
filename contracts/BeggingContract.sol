// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract BeggingContract {
    //捐赠记录
    mapping (address donorAddress => uint256 amountBegged) public begRecord;
    //合约拥有者
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    //捐赠排行榜
    address[3] public topAddressDonations; 
    uint256[3] public topAmountDonations;
    
    constructor() {
        owner = msg.sender;
        topAddressDonations = [address(0), address(0), address(0)];
        topAmountDonations = [0, 0, 0];
    }
    event Donation(address indexed donor, uint256 amount);
    //捐赠
    function donate() public payable {
        require(msg.value > 0, "You must send some ETH");
        begRecord[msg.sender] += msg.value;
        _updateTopDonations(msg.sender, msg.value);
        emit Donation(msg.sender, msg.value);
    }
    //更新捐赠排行榜-展示前三，可优化
    function _updateTopDonations(address donor, uint256 amount) internal {
        if(amount > topAmountDonations[0]) {
            topAddressDonations[2] = topAddressDonations[1];
            topAmountDonations[2] = topAmountDonations[1];
            topAddressDonations[1] = topAddressDonations[0];
            topAmountDonations[1] = topAmountDonations[0];
            topAmountDonations[0] = amount;
            topAddressDonations[0] = donor;
        }else if(amount > topAmountDonations[1]) {
            topAddressDonations[2] = topAddressDonations[1];
            topAmountDonations[2] = topAmountDonations[1];
            topAmountDonations[1] = amount;
            topAddressDonations[1] = donor;
        } else if(amount > topAmountDonations[2]) {
            topAddressDonations[2] = donor;
            topAmountDonations[2] = amount;
        }
    }
    //提取资金
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // 向拥有者转账合约余额
        payable(owner).transfer(balance);

    }

    //查询记录
    function getDonation(address donor) public view returns (uint256) {
        require(donor != address(0), "Invalid donor address");
        return begRecord[donor];
    }

    //捐赠排行榜
    function getTopDonors() public view returns (address[3] memory topDonors, uint256[3] memory topAmounts) {
        return(topAddressDonations, topAmountDonations);
    }
}