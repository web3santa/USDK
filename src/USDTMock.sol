// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTMock is ERC20 {
    uint256 public usdtPerEth = 1000;

    constructor() ERC20("USDT", "USDT") {}

    function mint() public payable {
        uint256 mintAmount = msg.value * usdtPerEth;
        _mint(msg.sender, mintAmount);
    }
}
