// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./libraries/Utils.sol";

// 0000000000000000000000000000000000000000000000000001c6bf52634000

contract MirrorCoinMarket {
    
    using Utils for bytes;

    IERC20 public erc20; 
    IERC721 public erc721; 

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    event Listed(address seller, uint256 tokenId, uint256 price);
    event ItemBought(address buyer, address seller, uint256 tokenId, uint256 price);
    event PriceUpdated(address seller, uint256 tokenId, uint256 previousPrice, uint256 price);
    event Delisted(address seller, uint256 tokenId);

    struct Listing {
        uint tokenId;
        address seller;
        uint price;
        bool isListed;
    }
    mapping(uint => Listing) public Listings;

    constructor(address _erc20, address _erc721) {
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        require(msg.sender == address(erc721), "invalid sender");
        require(!Listings[tokenId].isListed, "token is already listed");
        uint price = data.toUint256(0);
        require(price > 0, "price is zero");
        Listings[tokenId] = Listing(tokenId, from, price, true);
        emit Listed(from, tokenId, price);
        return MAGIC_ON_ERC721_RECEIVED;
    }

    // 购买 
    function buy(uint tokenId) external {
        Listing memory listing = Listings[tokenId];
        require(listing.isListed, "not listed");
        address buyer = msg.sender;
        require(erc20.transferFrom(buyer, listing.seller, listing.price), "ERC20 payment failed");
        erc721.safeTransferFrom(address(this), buyer, tokenId);
        delete Listings[tokenId];
        emit ItemBought(buyer, listing.seller, tokenId, listing.price);
    }

    // 更新价格
    function updatePrice(uint256 _tokenId, uint256 _price) external {
        Listing storage listing = Listings[_tokenId];
         address seller = listing.seller;
        require(msg.sender == seller, "not the seller");
        require(Listings[_tokenId].isListed, "not listed");
        Listings[_tokenId].price = _price;
    }

    // 取消上架
    function delist(uint tokenId) external {
        Listing storage listing = Listings[tokenId];
        require(listing.isListed, "not listed");
        address seller = listing.seller;
        require(msg.sender == seller, "not the seller");
        erc721.safeTransferFrom(address(this), seller, tokenId);
        delete Listings[tokenId];
        emit Delisted(seller, tokenId);
    }  
}
