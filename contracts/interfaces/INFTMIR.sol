// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTMIR {
    event Recharge(uint indexed userid,address indexed user, uint indexed amount, uint[] mintableTokenIds);
    event Withdraw(uint indexed amount);

    // 获取用户充值总额
    function getTotalRecharge(address user,uint userid) external view returns (uint256);
    // 用户充值 
    function recharge(uint userid, string memory uri, uint amount) external;
    // 铸造NFT
    function safeMint(address to, string memory uri) external;
    // 提现
    function withdraw() external;
}
