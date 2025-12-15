// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleBank {
    // 映射：将地址映射到余额，相当于一个键值对数据库
    mapping(address => uint256) private _balances;

    // 事件：存款和取款时触发，用于前端或后端监听
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    // 存款函数： payable 关键字表示此函数可以接收ETH
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        _balances[msg.sender] += msg.value; // msg.sender 是调用者的地址
        emit Deposited(msg.sender, msg.value); // 触发事件
    }

    // 取款函数
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        // 重要：在更新状态之前先转账，遵循“检查-生效-交互”模式防重入攻击
        _balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawn(msg.sender, amount);
    }

    // 查询余额函数，view 表示此函数只读取状态，不消耗Gas
    function getBalance() public view returns (uint256) {
        return _balances[msg.sender];
    }

    // 查询合约总存款，方便测试
    function getTotalBankBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
