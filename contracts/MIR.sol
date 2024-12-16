// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MIR is ERC20, Ownable, ERC20Permit {
    uint8 private constant _decimals = 6;
    uint256 private constant claimableAmount = 100 * 10 ** _decimals;
    mapping(address => bool) public claims;

    constructor(
        uint256 initialSupply
    ) ERC20("MirrorToken", "MIR") Ownable(msg.sender) ERC20Permit("MirrorToken") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    function registerClaim() external {
        require(claims[msg.sender] == false, "Already claimed");
        claims[msg.sender] = true;
        _mint(msg.sender, claimableAmount);
    }


    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
}
