// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {USDK} from "./USDK.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract USDKEngine is ReentrancyGuard, Pausable, Ownable {
    error USDKEngine__MintValueNeedtoMoreThanZero();
    error USDKEngine__ValueNeedToHaveMoreThenZero();
    error USDKEngine__BorrowValueLimitation();
    error USDKEngine__HealthFactorFailed();

    USDK private usdk;
    IERC20 private usdb;
    uint256 private STAKING_REWARDS_PERCENTAGE = 1;
    address[] private users;
    uint256 private healthFactor;

    mapping(address => uint256) stakingAmount;
    mapping(address => uint256) stakingBlock;

    constructor(USDK _usdk, IERC20 _usd) Ownable(msg.sender) {
        usdk = _usdk;
        usdb = _usd;
    }

    function staking(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();
        usdk.transferFrom(msg.sender, address(this), amount);
        stakingAmount[msg.sender] += amount;
        stakingBlock[msg.sender] = block.timestamp;
        users.push(msg.sender);
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

    function resetsRewards() public onlyOwner nonReentrant {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[0];
            stakingBlock[user] = block.timestamp;
        }
    }

    function mint(uint256 amount) public payable nonReentrant {
        if (amount < 0) revert USDKEngine__MintValueNeedtoMoreThanZero();
        usdb.transferFrom(msg.sender, address(this), amount);
        usdk.mint(msg.sender, amount);
    }

    function burn(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();
        usdk.burn(amount);
        usdb.transferFrom(address(this), msg.sender, amount);
    }

    // TODO
    // change transfer(DefiContract, amount);
    function depositUSDKAndBorrowUSD(uint256 amount) public nonReentrant {
        if (amount < 0) revert USDKEngine__ValueNeedToHaveMoreThenZero();
        if (amount < (stakingAmount[msg.sender] * 100) / 90) revert USDKEngine__BorrowValueLimitation();
        (bool successTransferFrom) = usdk.transferFrom(msg.sender, address(this), amount);
        require(successTransferFrom, "failed to transferFrom");
        (bool successTransfer) = usdb.transfer(msg.sender, amount);
        require(successTransfer, "failed to transferFrom");
    }

    function Liquidation() public nonReentrant {
        if (healthFactor > 100) revert USDKEngine__HealthFactorFailed();
    }
}
