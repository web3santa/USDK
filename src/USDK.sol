// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract USDK is ERC20, Ownable, ERC20Burnable {
    constructor() ERC20("USDK", "USDK") Ownable(msg.sender) {}

    function mint(address minter, uint256 amount) public onlyOwner {
        _mint(minter, amount);
    }
}
