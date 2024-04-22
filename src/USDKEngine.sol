// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {USDK} from "./USDK.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract USDKEngine is ReentrancyGuard, Pausable, Ownable {
    error USDKEngine__MintValueNeedtoMoreThanZero();
    error USDKEngine__ValueNeedToHaveMoreThenZero();

    USDK private usdk;
    uint256 private STAKING_REWARDS_PERCENTAGE = 1;
    address[] private users;

    mapping(address => uint256) stakingAmount;
    mapping(address => uint256) stakingBlock;

    constructor(USDK _usdk) Ownable(msg.sender) {
        usdk = _usdk;
    }

    function staking(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();
        usdk.transferFrom(msg.sender, address(this), amount);
        stakingAmount[msg.sender] += amount;
        stakingBlock[msg.sender] = block.timestamp;
    }

    function unstaking(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();
        usdk.transferFrom(address(this), msg.sender, amount);
        stakingAmount[msg.sender] -= amount;
        stakingBlock[msg.sender] = block.timestamp;
    }

    function checkRewards() public view returns (uint256) {
        uint256 stakingPeriod = block.timestamp - stakingAmount[msg.sender];
        uint256 calcStakingRewards = stakingAmount[msg.sender];

        uint256 totalReward = (calcStakingRewards * stakingPeriod * 100) / STAKING_REWARDS_PERCENTAGE;

        return totalReward;
    }

    function mint() public payable nonReentrant {
        if (msg.value < 0) revert USDKEngine__MintValueNeedtoMoreThanZero();

        uint256 mintAmount = msg.value;
        usdk.mint(msg.sender, mintAmount);
    }

    function burn(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();

        usdk.burn(amount);
    }
}
