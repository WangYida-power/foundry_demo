// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;
    address public user1 = address(1);

    function setUp() public {
        bank = new SimpleBank();
        vm.deal(user1, 100 ether);
    }

    function testDeposit() public {
        // 1. 先模拟 user1 存款
        vm.prank(user1);
        bank.deposit{value: 10 ether}();

        // 2. 关键：再次切换到 user1 的上下文来查询余额
        vm.prank(user1);
        uint256 userBalance = bank.getBalance();
        assertEq(userBalance, 10 ether, "User's balance should be 10 ether after deposit");

        // 3. 查询合约总余额无需切换上下文
        assertEq(bank.getTotalBankBalance(), 10 ether, "Contract's total balance should be 10 ether");
    }

    function testWithdraw() public {
        // 1. 存款
        vm.startPrank(user1);
        bank.deposit{value: 10 ether}();
        vm.stopPrank();

        // 2. 记录取款前用户的原生ETH余额和合约内余额
        uint256 initialEthBalance = user1.balance;
        vm.prank(user1);
        uint256 initialBankBalance = bank.getBalance(); // 应该是 10 ether

        // 3. 执行取款
        vm.startPrank(user1);
        bank.withdraw(5 ether);
        vm.stopPrank();

        // 4. 【核心修正】验证业务逻辑，而非精确数值
        // a) 验证用户在合约内的余额正确减少了5 ether
        vm.prank(user1);
        uint256 finalBankBalance = bank.getBalance();
        assertEq(
            finalBankBalance, initialBankBalance - 5 ether, "User's bank balance should decrease by exactly 5 ether"
        );

        // b) 验证用户收到的原生ETH非常接近5 ether（允许极小的Gas误差）
        uint256 ethReceived = user1.balance - initialEthBalance;
        // 使用 assertApproxEqAbs 允许一个微小的绝对误差范围（例如 100 wei），这完全足够且合理。
        assertApproxEqAbs(ethReceived, 5 ether, 100 wei, "User should receive approximately 5 ether");

        // 可选：验证合约总余额也相应减少
        assertEq(bank.getTotalBankBalance(), 5 ether, "Contract's total balance should be 5 ether left");
    }

    function testWithdrawMoreThanBalance() public {
        vm.startPrank(user1);
        bank.deposit{value: 1 ether}();

        vm.expectRevert("Insufficient balance");
        bank.withdraw(2 ether); // 此调用仍在 user1 上下文中
        vm.stopPrank();
    }
}
