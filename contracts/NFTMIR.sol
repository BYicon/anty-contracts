// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
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

    uint256 public nextTokenId;
    IERC20 public usdt;
    uint256 constant mintPrice = 10 * 10 ** 18;

    mapping(address => mapping(uint => uint)) public totalRecharge;
    mapping(address => mapping(uint => uint)) public availableForMint;

    constructor(
        address initialOwner,
        address usdtAddress
    ) ERC721("NFTMIR", "NFTMIR") Ownable(initialOwner) {
        usdt = IERC20(usdtAddress);
    }

    // getNFT URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // mint NFT
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // recharge
    function recharge(uint userid, string memory uri, uint amount) external {
        require(amount > 0 && usdt.balanceOf(msg.sender) >= amount, "invalid amount");

        // update total recharge amount of user
        totalRecharge[msg.sender][userid] += amount;
        // calculate available for mint
        availableForMint[msg.sender][userid] += amount;

        usdt.transferFrom(msg.sender, address(this), amount);

        // calculate mintable NFTS 
        uint256 mintableNFTs = availableForMint[msg.sender][userid] / mintPrice;

        if (mintableNFTs > 0) {
            for (uint256 i = 0; i < mintableNFTs; i++) {
                uint256 tokenId = nextTokenId++;
                _safeMint(msg.sender, tokenId);
                _setTokenURI(tokenId, uri);
            }
            // update available for mint
            availableForMint[msg.sender][userid] %= mintPrice;
        }

        emit Recharge(msg.sender, userid, amount);
    }

    // Get Total Recharge Amount
    function getTotalRecharge(
        address user,
        uint userid
    ) public view returns (uint256) {
        return totalRecharge[user][userid];
    }

    // Withdraw To Owner,TODO: after add staking reward (warn reentrancy)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
        emit Withdraw(address(this).balance);
    }

    // update NFT
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    // increase balance
    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    // support interface
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
