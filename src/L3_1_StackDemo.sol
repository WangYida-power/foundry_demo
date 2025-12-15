// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract L3_1_StackDemo {
    constructor(){

    }
//    大小固定：最多 1024 个元素（每个 256 位/32 字节）
//    LIFO（后进先出）：只能从顶部添加/移除元素
//    操作有限：只能访问顶部 16 个元素（0-15 深度）

    // EVM 栈是执行环境中的临时存储区域
    // 用于存储局部变量、函数参数和中间计算结果

    // ✅ 是否避免深度递归？
    // ✅ 函数参数是否过多？（建议 ≤ 16）
    // ✅ 局部变量是否过多？
    // ✅ 复杂表达式是否拆分？
    // ✅ 是否使用内存存储大数据？
    // ✅ 是否限制循环次数？
    // ✅ 内联汇编是否小心管理栈？
    // ✅ 是否启用编译器优化？

    function example() public pure {
        uint256 a = 1;    // 压入栈
        uint256 b = 2;    // 压入栈
        uint256 c = a + b; // a和b出栈，结果c压入栈
    }

    // ✅ 安全：使用迭代替代递归
    function sum(uint256 n) public pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 1; i <= n; i++) {
            total += i; // 栈使用稳定
        }
        return total;
    }

    // ✅ 更好：分步计算
    function goodExpression(
        uint256 a, uint256 b, uint256 c, uint256 d,
        uint256 e, uint256 f, uint256 g, uint256 h
    ) public pure returns (uint256) {
        uint256 temp1 = a + b;
        uint256 temp2 = temp1 * c;
        uint256 temp3 = temp2 / d;
        uint256 temp4 = temp3 + e;
        uint256 temp5 = temp4 - f;
        uint256 temp6 = temp5 * g;
        uint256 result = temp6 / h;
        return result; // 栈使用更少
    }

    // ✅ 使用结构体或数组减少栈占用
    function betterApproach() public pure {
        uint256[100] memory values; // 使用内存数组
        for (uint256 i = 0; i < values.length; i++) {
            values[i] = i;
        }
    }

    // ❌ -begin
    // ... 一直嵌套
    // ❌ 如果嵌套超过调用深度限制会失败
    // 每个调用消耗栈空间保存返回地址和上下文
    function level1() public {
        level2();
    }

    function level2() internal {
        level3();
    }

    function level3() internal {
        level4();
    }

    function level4() internal {
        level5();
    }
    // ❌ -end

    // 良好的设计模式
    // 1. 限制函数参数数量
    function processBatch(
        uint256[] memory ids,  // 使用数组而不是多个参数
        uint256[] memory values
    ) public {
        require(ids.length == values.length, "Length mismatch");
        require(ids.length <= 100, "Batch too large"); // 限制大小

        for (uint256 i = 0; i < ids.length; i++) {
            // 处理每个项目
        }
    }

    // 2. 使用内存存储中间结果
    function complexCalculation(uint256[] memory inputs) public pure returns (uint256) {
        uint256 length = inputs.length;
        uint256[] memory intermediates = new uint256[](length);

        // 第一步计算
        for (uint256 i = 0; i < length; i++) {
            intermediates[i] = inputs[i] * 2; // 存入内存，不占用栈
        }

        // 第二步计算
        uint256 total = 0;
        for (uint256 i = 0; i < length; i++) {
            total += intermediates[i];
        }

        return total;
    }

    // 3. 分阶段处理
    struct ProcessingState {
        uint256 stage;
        uint256[] results;
    }

    function processInStages(uint256[] memory data) public returns (uint256[] memory) {
        ProcessingState memory state;
        state.results = new uint256[](data.length);

        // 阶段1
        for (uint256 i = 0; i < data.length; i++) {
            state.results[i] = stage1(data[i]);
        }

        // 阶段2
        for (uint256 i = 0; i < data.length; i++) {
            state.results[i] = stage2(state.results[i]);
        }

        return state.results;
    }

    // 安全实践
    mapping(address => uint256) private balances;

    // 使用检查-效果-交互模式
    function safeWithdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        // 1. 检查
        require(address(this).balance >= amount, "Insufficient contract balance");

        // 2. 效果（先更新状态）
        balances[msg.sender] = 0;

        // 3. 交互（最后调用外部）
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // ✅ 防止重入
        // ✅ 栈使用可控
    }

    // 添加调用深度保护
    function protectedCall(address target, bytes memory data) internal {
        // 确保有足够的栈空间
        uint256 gasLeft = gasleft();
        require(gasLeft > 100000, "Insufficient gas for safe execution");

        // 限制调用深度
        // 可以通过外部方式检查调用深度
        (bool success, bytes memory result) = target.call(data);
        require(success, "Call failed");
    }
}
