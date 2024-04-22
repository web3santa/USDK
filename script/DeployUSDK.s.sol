// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {USDK} from "../src/USDK.sol";
import {USDKEngine} from "../src/USDKEngine.sol";
import {USDTMock} from "../src/USDTMock.sol";

contract DeployUSDK is Script {
    function run() external {
        deployGod();
    }

    function deployGod() public returns (address, address, address) {
        vm.startBroadcast();
        USDK usdk = new USDK();
        USDTMock usdt = new USDTMock();
        USDKEngine engine = new USDKEngine(usdk, address(usdt));

        usdk.transferOwnership(address(engine));
        vm.stopBroadcast();
        return (address(usdk), address(usdt), address(engine));
    }
}
