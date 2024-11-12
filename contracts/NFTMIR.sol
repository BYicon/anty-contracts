// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/INFTMIR.sol";

contract NFTMIR is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    INFTMIR
{

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    uint256 private _nextTokenId;
    mapping(address => mapping(uint => uint)) public totalRecharge;

    constructor(
        address initialOwner
    ) ERC721("NFTMIR", "NFTMIR") Ownable(initialOwner) {}

    // 获取NFT URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // 铸造NFT
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // 用户充值
    function recharge(uint userid, string memory uri) external payable lock {
        require(msg.value > 0, "Amount must be greater than 0");
        totalRecharge[msg.sender][userid] += msg.value;
        if (getTotalRecharge(msg.sender, userid) >= 10 ** 15) {
            // 铸造NFT
            uint256 tokenId = _nextTokenId++;
            _safeMint(msg.sender, tokenId);
            _setTokenURI(tokenId, uri);  
        }
        emit Recharge(msg.sender, userid, msg.value);
    }

    // 获取用户充值总额
    function getTotalRecharge(
        address user,
        uint userid
    ) public view returns (uint256) {
        return totalRecharge[user][userid];
    }

    // 提现
    function withdraw(uint amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
        emit Withdraw(amount);
    }

    // 更新NFT
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    // 增加余额
    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    // 支持接口
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
