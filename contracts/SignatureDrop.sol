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
    mapping(address => bool) public claims;

    event Claimed(address to, uint256 amount, uint256 nonce);

    error NonceUsed();
    error Expired();
    error InvalidSignature();
    error AlreadyClaimed();

    constructor(address _token) Ownable(msg.sender) {
        token = _token;
        signer = msg.sender;
    }

    function updateSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function claimRestTokens(address to) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
    }

    function claim(
        address _to,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) external {
        if (claims[msg.sender]) revert AlreadyClaimed();
        if (usedNonces[_nonce]) revert NonceUsed();
        if (_deadline < block.timestamp) revert Expired();
        if (!verifySignature(_to, _amount, _nonce, _deadline, _signature))
            revert InvalidSignature();

        usedNonces[_nonce] = true;
        claims[_to] = true;
        IERC20(token).safeTransfer(_to, _amount);

        emit Claimed(_to, _amount, _nonce);
    }

    function verifySignature(
        address _to,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline,
        bytes memory _signature
    ) public view returns (bool) {
        bytes32 _messageHash = getMessageHash(_to, _amount, _nonce, _deadline);
        bytes32 _ethSignedMessageHash = getEthSignedMessageHash(_messageHash);
        address _recovered = _ethSignedMessageHash.recover(_signature);
        return _recovered == signer;
    }

    function getMessageHash(
        address _to,
        uint256 _amount,
        uint256 _nonce,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _nonce, _deadline));
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return _messageHash.toEthSignedMessageHash();
    }
}
