// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTMIR {
    event Recharge(uint indexed userid,address indexed user, uint indexed amount, uint[] mintableTokenIds);
    event Withdraw(uint indexed amount);
    // 用户充值 
    function recharge(uint userid, uint amount) external;
    // 提现
    function withdraw() external;
}
