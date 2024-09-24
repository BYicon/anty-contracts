// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./utils/Utils.sol";

// 0000000000000000000000000000000000000000000000000001c6bf52634000

contract MirrorCoinMarket {
    
    using Utils for bytes;

    IERC20 public erc20; 
    IERC721 public erc721; 

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    event Listed(address seller, uint256 tokenId, uint256 price); // 上架

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
        uint price = data.toUint256(0);
        require(price > 0, "price is zero");
        Listings[tokenId] = Listing(tokenId, from, price, true);
        return MAGIC_ON_ERC721_RECEIVED;
    }
}
