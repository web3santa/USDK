// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTMock is ERC20 {
    constructor() ERC20("USDT", "USDT") {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
