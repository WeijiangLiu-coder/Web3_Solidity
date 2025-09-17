// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTPicture {

    string public name;
    string public symbol;
    address public owner;

    // 1. tokenId => 所有者地址 (核心映射：记录每个NFT的归属)
    mapping(uint256 tokenId => address ownerAddress) private _owners;

    // 2. 所有者地址 => NFT数量 (快速查询某个地址拥有多少NFT)
    mapping (address ownerAddress => uint256 numOfNFTs) private _balances;
    // 3. tokenId => 被授权地址 (单个NFT的授权：允许某个地址操作该NFT)
    mapping(uint256 => address) private _tokenApprovals;
    // 4. tokenId => 元数据链接（新增：存储每个NFT的元数据URL）
    mapping(uint256 => string) private _tokenURIs;

    //事件必须添加否者钱包无法监听NFT铸造/转移
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    modifier addressMustBeValid(address addr) {
        require(addr != address(0), "ERC721: invalid address");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "ERC721: caller is not owner");
        _;
    }

    // 1. 查询地址拥有的NFT数量
    function balanceOf(address addr) public view returns (uint256) {
        require(addr != address(0), "ERC721: balance query for the zero address");
        return _balances[addr];
    }
    // 2. 查询某个NFT的拥有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address ownerAddress = _owners[tokenId];
        require(ownerAddress != address(0), "ERC721: owner query for nonexistent token");
        return ownerAddress;
    }
    //3. 转账NFT：从from地址转移到to地址
    function transfer(address from, address to, uint256 tokenId) public addressMustBeValid(from) addressMustBeValid(to) {
        //检查当前NFT是否存在
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        //验证当前NFT的拥有者是否是from
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        //有权限才能操作NFT
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _balances[to] += 1;
        _balances[from] -= 1;
        _owners[tokenId] = to;
        //删除原本的授权信息
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId);
    }

    //4. 铸造NFT
    // owner可以把铸造的NFT的拥有者设置为其他人
    function mintNFT(address to, uint256 tokenId,string memory uri) public onlyOwner() addressMustBeValid(to) {
        require(!_exists(tokenId), "ERC721: token already minted");
        _tokenURIs[tokenId] = uri;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    // 5. 授权to地址操作某个NFT
    function approve(address to, uint256 tokenId) public addressMustBeValid(to) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        require(ownerOf(tokenId) == msg.sender, "ERC721: approve caller is not owner");
        // TODO: 保存授权信息
           _tokenApprovals[tokenId] = to;
    }
    // 6. 查询某个NFT的授权地址
     function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    // 核心：返回NFT的元数据链接（钱包/平台会调用这个函数获取图片）
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        
        string memory url = _tokenURIs[tokenId];

        // 如果设置了单个tokenURI，优先使用；否则用基础链接+tokenId
        if (bytes(url).length > 0) {
            return url;
        } else {
            return "";
        }
    }

    // 检查NFT是否存在（是否被铸造过）
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // 校验调用者是否有权操作NFT（核心权限逻辑）
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address ownerAddr = ownerOf(tokenId);
        // 3种合法场景：1.调用者是所有者 2.调用者是单个授权地址 
        return (
            spender == ownerAddr ||
            getApproved(tokenId) == spender
        );
    }
}