// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract DeploySimpleBank is Script {
    function run() external returns (SimpleBank) {
        vm.startBroadcast(); // 开始广播交易
        SimpleBank bank = new SimpleBank(); // 部署合约
        vm.stopBroadcast(); // 停止广播
        return bank;
    }
}
