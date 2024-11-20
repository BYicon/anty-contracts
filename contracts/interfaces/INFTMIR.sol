// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTMIR {
    event Recharge(uint indexed userid,address indexed user, uint indexed amount, uint[] mintableTokenIds);
    event Withdraw(uint indexed amount);
    event Redeem(uint indexed userid, uint[] tokenIds);
    // 用户充值 
    function recharge(uint userid, uint amount) external;
    // 提现
    function withdraw() external;

    // 获取用户等待赎回的NFT
    function getWaitingForRedeem(address user) external view returns (uint[] memory);

    // 用户赎回
    function redeem(uint tokenId, string memory uri) external;
}
