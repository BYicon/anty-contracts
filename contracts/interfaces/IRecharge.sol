// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRecharge {
    event Recharge(address indexed user, uint indexed userid, uint amount);
    event Withdraw(address indexed user, uint amount);

    function nfToken() external view returns (address);

    function getTotalRecharge(
        address user,
        uint userid
    ) external view returns (uint256);

    function recharge(uint amount, uint userid) external;

    function withdraw(address to, uint amount) external;

}

