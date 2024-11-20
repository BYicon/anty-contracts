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

    uint16 public nftTokenId;
    IERC20 public usdt;
    uint256 constant mintPrice = 10 * 10 ** 18;
    mapping(address => bool) public blacklist;
    mapping(uint => uint) public totalRechargeOfUserid;
    mapping(address => uint) public totalRechargeOfAddress;
    mapping(address => uint) public availableForMint;
    mapping(address => uint256[]) public waitingForRedeem;

    modifier onlyNotBlacklist() {
        require(!blacklist[msg.sender], "invalid user");
        _;
    }

    constructor(
        address usdtAddress
    ) ERC721("NFTMIR", "NFTMIR") Ownable(msg.sender) {
        usdt = IERC20(usdtAddress);
    }

    // getNFT URI
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    // set NFT URI
    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        _setTokenURI(tokenId, uri);
    }

    // recharge
    function recharge(uint userid, uint amount) external onlyNotBlacklist {
        require(amount > 0 && usdt.balanceOf(msg.sender) >= amount, "invalid amount");
        // record total recharge amount of userid
        totalRechargeOfUserid[userid] += amount;
        // record total recharge amount of current address
        totalRechargeOfAddress[msg.sender] += amount;
        // record available for mint
        availableForMint[msg.sender] += amount;
        // transfer USDT from user to owner
        usdt.transferFrom(msg.sender, address(this), amount);
        // calculate mintable NFTs count
        uint256 mintableNFTsCount = availableForMint[msg.sender] / mintPrice;
        // mint NFT and record waiting for redeem
        uint[] memory mintableTokenIds = new uint[](mintableNFTsCount);
        if (mintableNFTsCount > 0) {
            uint16 currentTokenId = nftTokenId;
            for (uint256 i = 0; i < mintableNFTsCount; i++) {
                currentTokenId++;
                waitingForRedeem[msg.sender].push(currentTokenId); // record waiting for redeem
                mintableTokenIds[i] = currentTokenId;
            }
            nftTokenId = currentTokenId;
            // update available for mint
            availableForMint[msg.sender] %= mintPrice;
        }
        emit Recharge(userid, msg.sender, amount, mintableTokenIds);
    }

    // get user waiting for redeem
    function getWaitingForRedeem(address user) public view returns (uint[] memory) {
        return waitingForRedeem[user];
    }

    // user redeem
    function redeem(uint tokenId, string memory uri) external onlyNotBlacklist {
        // remove from waiting for redeem
        uint[] storage waitingForRedeemArray = waitingForRedeem[msg.sender];
        if(waitingForRedeemArray.length > 0) {
            for (uint256 i = 0; i < waitingForRedeemArray.length; i++) {
                if (waitingForRedeemArray[i] == tokenId) {
                    waitingForRedeemArray[i] = waitingForRedeemArray[waitingForRedeemArray.length - 1];
                    waitingForRedeemArray.pop();
                    _safeMint(msg.sender, tokenId);
                    _setTokenURI(tokenId, uri);
                    emit Redeem(tokenId, waitingForRedeemArray);
                    break;
                }
            }
        } else {
            revert("invalid tokenId");
        }
    }

    // Withdraw To Owner,TODO: after add staking reward (warn reentrancy)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
        emit Withdraw(address(this).balance);
    }

    // set blacklist
    function setBlacklist(address user, bool isBlacklist) external onlyOwner {
        if(user == owner()) revert("owner can't be blacklisted");
        blacklist[user] = isBlacklist;
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
