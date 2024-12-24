// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SignatureDrop is Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    using SafeERC20 for IERC20;

    address public immutable token;
    address public signer;
    mapping(uint256 => bool) public usedNonces;

    event Claimed(address to, uint256 amount, uint256 nonce);

    error NonceUsed();
    error Expired();
    error InvalidSignature();

    constructor(address token_, address signer_) Ownable(msg.sender) {
        token = token_;
        signer = signer_;
    }

    function updateSigner(address signer_) external onlyOwner {
        signer = signer_;
    }

    function claimRestTokens(address to) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
    }

    function claim(
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 expireAt,
        bytes memory signature
    ) external {
        if (usedNonces[nonce]) revert NonceUsed();
        if (expireAt < block.timestamp) revert Expired();

        if (!verifySignature(to, amount, nonce, expireAt, signature))
            revert InvalidSignature();

        usedNonces[nonce] = true;
        IERC20(token).safeTransfer(to, amount);

        emit Claimed(to, amount, nonce);
    }

    function verifySignature(
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 expireAt,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHash(to, amount, nonce, expireAt);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        address recovered = ethSignedMessageHash.recover(signature);
        return recovered == signer;
    }

    function getMessageHash(
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 expireAt
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, amount, nonce, expireAt));
    }

    function getEthSignedMessageHash(
        bytes32 messageHash
    ) public pure returns (bytes32) {
        return messageHash.toEthSignedMessageHash();
    }
}
