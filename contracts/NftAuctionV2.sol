// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NftAuctionV2 is Initializable {

    struct Auction {
        //卖家
        address seller;
        //拍卖持续时间
        uint256 duration;
        uint256 startPrice;
        //开始时间
        uint256 startTime;

        //是否结束
        bool ended;
        //最高出价者
        address highestBidder;
        //最高价格
        uint256 highestBid;

        //NFT的合约地址
        address nftContract;
        //NFT的ID
        uint256 tokenId;
    }
    //状态变量
    mapping(uint256 => Auction) public auctions;
    //下一个拍卖ID
    uint256 public nextAuctionId;
    
    //管理员的ID
    address public admin;
    function initialize() public initializer {
        admin = msg.sender;
    }

    //创建拍卖
    function createAuction(uint256 _duration, uint256 _startPrice, address _nftContract, uint256 _tokenId) public {
        //只有管理员才能创建拍卖
        require(msg.sender == admin,"Only admin can create auctions");
        //检查参数
        require(_duration > 1000*60, "duration must be greater than 60s");
        require(_startPrice > 0, "startPrice must be greater than 0");

        auctions[nextAuctionId++] = Auction({
            seller: msg.sender,
            duration: _duration,
            startPrice: _startPrice,
            ended: false,
            highestBidder: address(0),
            highestBid: 0,
            startTime: block.timestamp,
            nftContract: _nftContract,
            tokenId: _tokenId
        });

    }
    //买家参与买单
    function placeBid(uint256 _auctionId) external payable {
        Auction storage auction = auctions[_auctionId];
        //检查拍卖是否存在
        require(auctions[nextAuctionId].seller != address(0), "Auction does not exist");
        //检查拍卖是否结束
        require(!auctions[nextAuctionId].ended && block.timestamp < auctions[nextAuctionId].startTime + auctions[nextAuctionId].duration, "Auction has ended");
        //检查出价是否大于最高出价也要大于起拍价
        require(msg.value > auctions[nextAuctionId].highestBid && msg.value > auctions[nextAuctionId].startPrice, "Bid must be higher than the current highest bid");
        //退还之前的最高出价
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    function TestHello() public pure returns (string memory) {
        //测试函数
        return "Hello, World!";
    }
}