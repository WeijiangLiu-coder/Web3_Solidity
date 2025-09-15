// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import  "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NftAuction is Initializable {

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
        require(_duration >= 1, "duration must be greater than 60s");
        require(_startPrice > 0, "startPrice must be greater than 0");

        //将 NFT 从卖家转移到本合约进行托管
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

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
        require(auction.seller != address(0), "Auction does not exist");
        //检查拍卖是否结束
        require(!auction.ended && block.timestamp < auction.startTime + auction.duration, "Auction has ended");
        //检查出价是否大于最高出价也要大于起拍价
        require(msg.value > auction.highestBid && msg.value > auction.startPrice, "Bid must be higher than the current highest bid");
        //退还之前的最高出价
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    //结束拍卖
    function endAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        //判断当前拍卖是否结束
        require(block.timestamp >= auction.startTime + auction.duration, "Auction has not ended yet");
        require(!auction.ended, "Auction has already ended");
        auction.ended = true;
        if (auction.highestBidder != address(0)) {
            //将NFT转移到最高出价者
            IERC721(auction.nftContract).transferFrom(address(this), auction.highestBidder, auction.tokenId);
            //将拍卖的收益发送给卖家
            payable(auction.seller).transfer(auction.highestBid);
        }
    }
}