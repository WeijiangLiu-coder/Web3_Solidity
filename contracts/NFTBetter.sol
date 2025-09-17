// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTBetter is ERC721, ERC721URIStorage, Ownable {
    //这是 Solidity 的 using for 语法，为 Counters.Counter 类型的变量 “绑定”Counters 库的所有方法。
    //原本需要写 Counters.increment(_tokenIds)，绑定后可直接写 _tokenIds.increment()，代码更简洁
    uint256 private _tokenIdCounter;

    //调用ERC721构造函数，传入NFT名称和代号
    constructor() ERC721("RokerKing", "AB") Ownable(msg.sender) {}

    function mintNFT(address recipient, string memory tokenUrl) public onlyOwner returns (uint256) {
        _tokenIdCounter++;
        //获取当前tokenId
        uint256 newTokenId = _tokenIdCounter;
        //ERC721合约的内部函数，用于将新铸造的NFT分配给指定的接收者
        _mint(recipient, newTokenId);
        //ERC721URIStorage合约的内部函数，用于设置NFT的元数据URI
        _setTokenURI(newTokenId, tokenUrl);
        return newTokenId;
    }
    //允许外部合约或用户查询当前合约是否实现了某个特定接口
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage)  returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    //ERC721URIStorage合约的内部函数，用于获取指定NFT的元数据URI
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId); 
    }
}