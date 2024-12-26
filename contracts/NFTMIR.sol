// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/INFTMIR.sol";

uint8 constant MIR_DECIMALS = 6;

contract NFTMIR is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    INFTMIR
{
    uint16 public nftTokenId;
    IERC20 public mir;
    uint256 constant mintPrice = 10 * 10 ** MIR_DECIMALS;
    mapping(address => bool) public blacklist;
    mapping(uint => uint) public totalRechargeOfUserid;
    mapping(address => uint) public totalRechargeOfAddress;
    mapping(address => uint) public availableForMint;
    mapping(address => uint256[]) public waitingForRedeem;

    modifier onlyNotBlacklist() {
        require(!blacklist[msg.sender], "invalid user");
        _;
    }

    struct TokenInfo {
        uint256 tokenID;
        string tokenURI;
    }

    constructor(
        address mirAddress
    ) ERC721("NFTMIR", "NFTMIR") Ownable(msg.sender) {
        mir = IERC20(mirAddress);
    }

    // getNFT URI
    function tokenURI(
        uint256 _tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(_tokenId);
    }

    // set NFT URI
    function setTokenURI(uint256 _tokenId, string memory _uri) public onlyOwner {
        _setTokenURI(_tokenId, _uri);
    }

    // recharge
    function recharge(uint _userid, uint _amount) external onlyNotBlacklist {
        require(
            _amount > 0 && mir.balanceOf(msg.sender) >= _amount,
            "invalid amount"
        );
        // record total recharge amount of userid
        totalRechargeOfUserid[_userid] += _amount;
        // record total recharge amount of current address
        totalRechargeOfAddress[msg.sender] += _amount;
        // record available for mint
        availableForMint[msg.sender] += _amount;
        // transfer MIR from user to owner
        mir.transferFrom(msg.sender, address(this), _amount);
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
        emit Recharge(_userid, msg.sender, _amount, mintableTokenIds);
    }

    // get user waiting for redeem
    function getWaitingForRedeem(
        address _user
    ) public view returns (uint[] memory) {
        return waitingForRedeem[_user];
    }

    function _findWaitingForRedeemIndex(
        address _user,
        uint _tokenId
    ) private view returns (int) {
        uint[] storage waitingForRedeemArray = waitingForRedeem[_user];
        for (uint256 i = 0; i < waitingForRedeemArray.length; i++) {
            if (waitingForRedeemArray[i] == _tokenId) {
                return int(i);
            }
        }
        return -1;
    }

    // user redeem
    function redeem(uint _tokenId, string memory _uri) external onlyNotBlacklist {
        // remove from waiting for redeem
        uint[] storage waitingForRedeemArray = waitingForRedeem[msg.sender];
        if (waitingForRedeemArray.length > 0) {
            int index = _findWaitingForRedeemIndex(msg.sender, _tokenId);
            if (index > -1) {
                waitingForRedeemArray[uint(index)] = waitingForRedeemArray[
                    waitingForRedeemArray.length - 1
                ];
                waitingForRedeemArray.pop();
                _safeMint(msg.sender, _tokenId);
                _setTokenURI(_tokenId, _uri);
                emit Redeem(_tokenId, waitingForRedeemArray);
            } else {
                revert("invalid tokenId");
            }
        } else {
            revert("no waiting for redeem");
        }
    }

    function getNFTsByUser(
        address _owner
    ) external view returns (TokenInfo[] memory) {
        uint256 balance = balanceOf(_owner);
        TokenInfo[] memory nfts = new TokenInfo[](balance);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(_owner, i);
            nfts[i] = TokenInfo({
                tokenID: tokenId,
                tokenURI: tokenURI(tokenId)
            });
        }
        return nfts;
    }

    // Withdraw To Owner,TODO: after add staking reward (warn reentrancy)
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
        emit Withdraw(address(this).balance);
    }

    // set blacklist
    function setBlacklist(address _user, bool _isBlacklist) external onlyOwner {
        if (_user == owner()) revert("owner can't be blacklisted");
        blacklist[_user] = _isBlacklist;
    }

    // test: set ERC20
    function setERC20(address _erc20) external onlyOwner {
        mir = IERC20(_erc20);
    }

    // block timestamp
    function blockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    // update NFT
    function _update(
        address _to,
        uint256 _tokenId,
        address _auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(_to, _tokenId, _auth);
    }

    // increase balance
    function _increaseBalance(
        address _account,
        uint128 _value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(_account, _value);
    }

    // support interface
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
