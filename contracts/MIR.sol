// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MIR is ERC20, Ownable {
    uint8 private constant _decimals = 6;

    uint256 private rewardMir = 10 * 10 ** _decimals;

    mapping(address => uint32) public lastDailyCheck;

    event DailyCheck(address indexed user, uint256 indexed amount);

    constructor(
        uint256 initialSupply
    ) ERC20("MirrorToken", "MIR") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }

    function dailyCheck() external {
        require(msg.sender.code.length == 0, "Only user address");
        require(
            lastDailyCheck[msg.sender] == 0 ||
                block.timestamp - lastDailyCheck[msg.sender] >= 1 days,
            "Daily Check Error"
        );
        _mint(msg.sender, rewardMir);
        lastDailyCheck[msg.sender] = uint32(block.timestamp);
        emit DailyCheck(msg.sender, rewardMir);
    }

    function setRewardRate(uint256 _newRewardMir) external onlyOwner {
        rewardMir = _newRewardMir;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
}
