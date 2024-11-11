// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRecharge.sol";
import "./interfaces/INFTMIR.sol";

contract Recharge is IRecharge, Ownable {
    mapping(address => mapping(uint => uint)) public totalRecharge;

    address public nfToken;
    constructor(address _owner, address _nfToken)
        Ownable(_owner)
    {
        nfToken = _nfToken;
    }

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getTotalRecharge(address user, uint userid) external view returns (uint256) {
        return totalRecharge[user][userid];
    }

    function recharge(uint amount, uint userid) external lock {
        require(amount > 0, "Amount must be greater than 0");
        totalRecharge[msg.sender][userid] += amount;
        INFTMIR(nfToken).safeMint(msg.sender);
        emit Recharge(msg.sender, userid, amount);
    }

    function withdraw(address to, uint amount) external onlyOwner{
        emit Withdraw(to, amount);
    }

}
