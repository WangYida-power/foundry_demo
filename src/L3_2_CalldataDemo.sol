// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//1. 基本概念
//1.1 什么是 calldata？
//2. 技术细节
//2.1 存储位置对比
//2.2 Gas 成本分析
//3. 使用场景
//3.1 外部函数参数（推荐）
//3.2 复杂数据结构
//3.3 编码/解码数据
//4. 限制和约束
//4.1 不可修改性
//4.2 类型限制
//4.3 内部函数调用限制
//5. 高级用法
//5.1 内联汇编操作
//5.2 动态参数解析
//5.3 节省 Gas 的模式
//6. 安全注意事项
//6.1 输入验证
//6.2 防止 DoS 攻击
//7. 最佳实践总结
//7.1 何时使用 calldata
//7.2 性能优化模式
//8. 真实案例
//8.1 Uniswap V2 示例
//8.2 ERC-721 批量转账
//9. 调试和测试
//9.1 查看 calldata
//9.2 Gas 测试

//特性	    calldata	memory	    storage
//位置	    交易数据	    运行时内存	合约存储
//成本	    最低	        中等	        最高
//可修改性	只读	        可读可写	    可读可写
//持久性	    临时	        临时	        永久
//作用域	    函数调用期间	函数执行期间	合约生命周期

//不可修改性 类型限制 内部函数调用限制
// ✅ 允许的类型：
// - 基本类型（uint, address, bool 等）
// - 固定大小数组
// - 动态数组
// - 结构体
// - bytes（动态）
// - string



contract L3_2_CalldataDemo {
    constructor(){

    }
}

contract CalldataDemo {
    //1. 基本概念
    //1.1 什么是 calldata？
    // calldata 是 EVM 中的一个特殊只读数据区域
    // 函数参数可以声明为 calldata 类型
    function processData(uint256[] calldata input) external pure returns (uint256) {
        // input 存储在 calldata 中，不可修改
        // 只能读取，不能写入
        return input.length;
    }

    // 对比：memory 参数
    function processMemory(uint256[] memory input) public pure returns (uint256) {
        // memory 数据可以修改
        input[0] = 100;
        // ✅ 允许
        return input.length;
    }
}

//2. 技术细节
//2.1 存储位置对比
//特性	    calldata	memory	    storage
//位置	    交易数据	    运行时内存	合约存储
//成本	    最低	        中等	        最高
//可修改性	只读	        可读可写	    可读可写
//持久性	    临时	        临时	        永久
//作用域	    函数调用期间	函数执行期间	合约生命周期

//2.2 Gas 成本分析
contract GasComparison {
    uint256[] public storageArray = [1, 2, 3, 4, 5];

    // ✅ calldata: 最省 gas（直接读取交易数据）
    function sumCalldata(uint256[] calldata data) external pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < data.length; i++) {
            total += data[i];
            // 直接读取 calldata
        }
        return total;
    }

    // ❌ memory: 需要复制数据，消耗更多 gas
    function sumMemory(uint256[] memory data) public pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < data.length; i++) {
            total += data[i];
            // 读取 memory（已经复制过）
        }
        return total;
    }

    // 🔴 storage: 最耗 gas
    function sumStorage() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < storageArray.length; i++) {
            total += storageArray[i];
            // 每次读取都访问 storage
        }
        return total;
    }
}

//3. 使用场景
//3.1 外部函数参数（推荐）
contract ExternalFunctions {
    // ✅ 最佳实践：external 函数使用 calldata
    function processBatch(
        address[] calldata users,
        uint256[] calldata amounts,
        bytes32[] calldata signatures
    ) external {
        require(users.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < users.length; i++) {
            _processSingle(users[i], amounts[i], signatures[i]);
        }
    }

    function _processSingle(
        address user,
        uint256 amount,
        bytes32 signature
    ) internal {
        // 内部处理
    }
}

//3.2 复杂数据结构
contract ComplexData {
    struct Order {
        address maker;
        address taker;
        uint256 price;
        uint256 amount;
        bytes32 orderHash;
    }

    // ✅ 传递结构体数组（节省 gas）
    function batchExecute(Order[] calldata orders) external {
        for (uint256 i = 0; i < orders.length; i++) {
            _executeOrder(orders[i]);
        }
    }

    // ✅ 使用嵌套数组
    function processMatrix(uint256[][] calldata matrix) external pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < matrix.length; i++) {
            for (uint256 j = 0; j < matrix[i].length; j++) {
                total += matrix[i][j];
            }
        }
        return total;
    }
}
//3.3 编码/解码数据
contract EncodingExample {
    // ✅ 接收原始调用数据
    function decodeCalldata(bytes calldata data) external pure returns (
        address,
        uint256,
        string memory
    ) {
        // 手动解码 calldata
        (address addr, uint256 amount, string memory name) =
        abi.decode(data[4 :], (address, uint256, string));

        return (addr, amount, name);
    }

    // ✅ 函数选择器 + 参数
    function withSelector(bytes4 selector, bytes calldata params) external {
        require(selector == this.doSomething.selector, "Invalid selector");

        // 解码参数
        (uint256 a, uint256 b) = abi.decode(params, (uint256, uint256));

        doSomething(a, b);
    }

    function doSomething(uint256 a, uint256 b) public {
        // ...
    }
}
//4. 限制和约束
//4.1 不可修改性
contract ImmutableCalldata {
    // ❌ 不能修改 calldata
    function modifyCalldata(uint256[] calldata data) external pure {
        // data[0] = 1; // 编译错误：Calldata arrays are read-only

        // ✅ 解决方案：复制到 memory
        uint256[] memory copy = new uint256[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            copy[i] = data[i];
        }
        copy[0] = 1;
        // 可以修改 memory 副本
    }
}

//4.2 类型限制
contract TypeRestrictions {
    // ✅ 允许的类型：
    // - 基本类型（uint, address, bool 等）
    // - 固定大小数组
    // - 动态数组
    // - 结构体
    // - bytes（动态）
    // - string

    // ✅ 各种类型示例
    function allTypes(
        uint256 num,
        address addr,
        bool flag,
        uint256[3] calldata fixedArray,
        uint256[] calldata dynamicArray,
        bytes calldata data,
        string calldata text
    ) external pure {
        // 都可以使用 calldata
    }
}

//4.3内部函数调用限制
contract InternalCalls {
    // ❌ 不能直接传递 calldata 给 internal 函数
    function externalFunction(uint256[] calldata data) external {
        // _internalFunction(data); // 编译错误
        // calldata 只能用于 external 函数参数

        // ✅ 解决方案：转换为 memory
        uint256[] memory memoryData = data;
        _internalFunction(memoryData);
    }

    function _internalFunction(uint256[] memory data) internal {
        // 处理 memory 数据
    }
}

//5. 高级用法
//5.1 内联汇编操作
contract AssemblyCalldata {
    // 直接读取 calldata 大小和内容
    function getCalldataInfo() external pure returns (uint256 size, bytes4 selector) {
        assembly {
        // calldatasize() 返回 calldata 的总字节数
            size := calldatasize()

        // calldataload(offset) 从 calldata 加载32字节
        // 前4字节是函数选择器
            selector := calldataload(0)

        // 注意：calldataload 总是读取32字节，可能需要移位
        }
    }

    // 手动解码参数
    function decodeWithAssembly() external pure returns (address, uint256) {
        address addr;
        uint256 amount;

        assembly {
        // 跳过函数选择器（4字节）
        // 参数1: address（从第4字节开始，32字节对齐）
            addr := calldataload(4)

        // 参数2: uint256（从第36字节开始）
            amount := calldataload(36)

        // 清理 address（只取后20字节）
            addr := and(addr, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        }

        return (addr, amount);
    }
}

//5.2 动态参数解析
contract DynamicParams {
    // 处理可变参数
    function dynamicCall(bytes calldata encodedData) external pure returns (uint256[] memory) {
        // 解码为数组
        uint256[] memory numbers = abi.decode(encodedData, (uint256[]));

        // 处理数组
        uint256[] memory results = new uint256[](numbers.length);
        for (uint256 i = 0; i < numbers.length; i++) {
            results[i] = numbers[i] * 2;
        }

        return results;
    }

    // 使用多重编码
    function multiEncode(
        bytes calldata data1,
        bytes calldata data2
    ) external pure returns (bytes memory) {
        // 将多个 calldata 合并编码
        return abi.encode(data1, data2);
    }
}


//5.3 节省 Gas 的模式
contract GasOptimization {
    // ✅ 模式1：批量处理使用 calldata
    function batchTransfer(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length == amounts.length, "Mismatch");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(recipients[i], amounts[i]);
        }
    }

    // ✅ 模式2：延迟加载（按需读取）
    function processSelectively(
        uint256[] calldata data,
        uint256[] calldata indices
    ) external pure returns (uint256) {
        uint256 sum = 0;

        // 只读取需要的元素
        for (uint256 i = 0; i < indices.length; i++) {
            uint256 index = indices[i];
            require(index < data.length, "Index out of bounds");
            sum += data[index];
            // 直接从 calldata 读取特定位置
        }

        return sum;
    }

    // ✅ 模式3：使用 bytes 而不是多个参数
    function packedParams(bytes calldata packedData) external pure returns (
        address,
        uint256,
        uint256
    ) {
        // 解码打包的数据
        (address user, uint256 amount, uint256 deadline) =
        abi.decode(packedData, (address, uint256, uint256));

        return (user, amount, deadline);
    }

    function _transfer(address to, uint256 amount) internal {
        // 转账逻辑
    }
}


//6.安全注意事项
//6.1输入验证
contract InputValidation {
// ✅ 必须验证 calldata 参数
    function safeProcess(uint256[] calldata data) external pure returns (uint256) {
        // 1. 检查长度
        require(data.length > 0, "Empty array");
        require(data.length <= 100, "Array too large");

        // 2. 检查每个元素
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            // 防止溢出（Solidity 0.8+ 自动检查，但显式检查更好）
            require(data[i] <= type(uint256).max - sum, "Overflow risk");
            sum += data[i];
        }

        return sum;
    }

// ✅ 验证 bytes 数据
    function validateSignature(
        bytes32 hash,
        bytes calldata signature,
        address expectedSigner
    ) external pure returns (bool) {
        // 检查签名长度
        require(signature.length == 65, "Invalid signature length");

        // 拆分签名
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
        // 前32字节：r
            r := calldataload(signature.offset)
        // 接下来32字节：s
            s := calldataload(add(signature.offset, 32))
        // 最后1字节：v
            v := byte(0, calldataload(add(signature.offset, 64)))
        }

        // 验证签名
        address signer = ecrecover(hash, v, r, s);
        return signer == expectedSigner;
    }
}

//6.2防止DOS攻击
contract AntiDOS {
// ✅ 限制 calldata 大小
    function processData(bytes calldata data) external pure returns (bytes32) {
        // 防止超大 calldata 消耗过多 gas
        require(data.length <= 1024 * 10, "Data too large");
        // 10KB 限制

        // 计算哈希
        return keccak256(data);
    }

// ✅ 使用分页处理大量数据
    function processLargeData(
        bytes calldata data,
        uint256 offset,
        uint256 limit
    ) external pure returns (bytes32[] memory) {
        require(offset < data.length, "Offset out of bounds");

        // 计算实际处理长度
        uint256 end = offset + limit;
        if (end > data.length) {
            end = data.length;
        }

        // 分段处理
        uint256 resultCount = (end - offset + 31) / 32;
        // 每32字节一个哈希
        bytes32[] memory results = new bytes32[](resultCount);

        for (uint256 i = 0; i < resultCount; i++) {
            uint256 start = offset + i * 32;
            uint256 chunkSize = 32;
            if (start + chunkSize > end) {
                chunkSize = end - start;
            }

            // 处理数据块
            results[i] = keccak256(data[start : start + chunkSize]);
        }

        return results;
    }
}

//7.最佳实践总结
//7.1何时使用
contract WhenToUseCalldata {
    // ✅ 使用场景：

    // 1. 外部函数的数组/结构体参数
    function externalArray(uint256[] calldata arr) external {
        // 最佳实践
    }

    // 2. 不需要修改的参数
    function readOnlyParams(
        address user,
        uint256 amount,
        bytes calldata data
    ) external view {
        // 如果不需要修改数据
    }

    // 3. Gas 优化是关键时
    function gasCriticalOperation(
        bytes32[] calldata proofs,
        bytes calldata signature
    ) external {
        // 需要最小化 gas 消耗
    }

    // ❌ 避免的场景：

    // 1. 需要修改参数时
    function needsModification(uint256[] memory arr) public {
        arr[0] = 1; // 需要 memory
    }

    // 2. 内部函数调用时
    function internalCall(uint256[] memory arr) internal {
        // 内部函数通常用 memory
    }
}

//7.2性能优化模式
contract OptimizationPatterns {
    // 模式1：延迟解码
    function delayedDecoding(bytes calldata encoded) external {
        // 只在需要时解码
        (uint256 a, uint256 b) = abi.decode(encoded, (uint256, uint256));
        // 使用 a, b
    }

    // 模式2：选择性读取
    function selectiveRead(
        uint256[] calldata data,
        uint256 index
    ) external pure returns (uint256) {
        // 只读取需要的元素
        require(index < data.length, "Out of bounds");
        return data[index];
    }

    // 模式3：使用固定大小数组
    function fixedSizeArray(uint256[10] calldata data) external pure returns (uint256) {
        // 固定大小数组更高效
        uint256 sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += data[i];
        }
        return sum;
    }
}

//8.真实案例
//8.1Uniswap V2 示例
// 类似 Uniswap 的路由合约
contract SwapRouter {
    // ✅ 使用 calldata 传递路径（节省大量 gas）
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,  // 交易路径
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        // 验证路径
        require(path.length >= 2, "Invalid path");

        // 处理交易
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {
            // 执行兑换
            // ...
        }
    }
}
//8.2ERC-721 批量转账
contract NFTBatchTransfer {
    // ✅ 批量操作使用 calldata
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds,  // 多个 tokenId
        bytes calldata data
    ) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _safeTransfer(from, to, tokenIds[i], data);
        }
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        // 转账逻辑
    }
}

//9.调试和测试
//9.1查看calldata
contract DebugCalldata {
    event CalldataInfo(bytes data, uint256 size, bytes4 selector);

    function debug() external {
        // 获取当前调用的 calldata
        bytes memory data = msg.data;
        uint256 size = data.length;
        bytes4 selector = bytes4(data);

        emit CalldataInfo(data, size, selector);
    }

    // 测试函数
    function testFunction(uint256 a, address b) external {
        // 调用 debug() 查看 calldata
    }
}

//9.2gas测试
contract GasTest {
    function testCalldataGas(uint256[] calldata data) external pure returns (uint256) {
        uint256 gasStart = gasleft();

        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }

        uint256 gasUsed = gasStart - gasleft();
        return gasUsed;
    }

    function testMemoryGas(uint256[] memory data) public pure returns (uint256) {
        uint256 gasStart = gasleft();

        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }

        uint256 gasUsed = gasStart - gasleft();
        return gasUsed;
    }
}
