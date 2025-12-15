// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract L4_TransferDemo {
    constructor(){

    }

    //一、事件（Events）基础概念
    //1.什么是事件
    // 事件定义
//    event Transfer(address indexed from, address indexed to, uint256 value);

    // 事件触发
//    emit Transfer(msg.sender, recipient, amount);

    //2. 事件的特点
    //不可变：一旦发出，无法修改或删除
    //链外可读：可通过 RPC 节点查询
    //链内不可读：合约内无法读取已发出的事件
    //低成本存储：相比 storage 便宜很多
    //永久存储：随区块永久记录

    //二、事件声明语法
    //1. 基本声明

    // 常规事件
    event LogData(string message, uint256 timestamp);

    // 带 indexed 参数的事件（最多3个）
    event Transfer(
    address indexed from, // 可索引，用于快速过滤
    address indexed to, // 可索引
    uint256 value           // 非索引，存储在日志数据中
    );

    // 匿名事件（不记录事件签名）
    event AnonymousEvent(address indexed user) anonymous;

    //2. 参数类型限制
    // 允许的类型
    event ValidEvent(
        address indexed addr,      // ✅ 允许
        uint256 indexed id,        // ✅ 允许
        bytes32 indexed data,      // ✅ 允许
        string message,           // ✅ 允许（但不能 indexed）
        bytes data,               // ✅ 允许（但不能 indexed）
        uint[] array              // ✅ 允许（但不能 indexed）
    );

    // 错误示例
    event InvalidEvent(
        mapping(address => uint) map  // ❌ 不允许
    );
}

//三、emit 使用详解
//1. 基本用法
contract EventEmitter {
    // 定义事件
    event ValueChanged(address indexed changer, uint oldValue, uint newValue);
    event UserRegistered(address indexed user, uint256 userId, string username);

    uint public value;
    uint256 public userCount;

    function setValue(uint newValue) public {
        uint oldValue = value;
        value = newValue;

        // 触发事件
        emit ValueChanged(msg.sender, oldValue, newValue);
    }

    function registerUser(string memory username) public {
        userCount++;

        // 触发带多个参数的事件
        emit UserRegistered(msg.sender, userCount, username);

        // 可以多次触发不同事件
        emit ValueChanged(msg.sender, 0, 1);
    }
}

//2. Gas 成本分析
contract GasCostExample {
    event CheapEvent(address indexed addr);  // 375 gas（主题） + 数据
    event ExpensiveEvent(string longMessage); // 数据部分按字节计费

    function testGas() public {
        // 基础成本
        emit CheapEvent(msg.sender);  // ~375 gas（主题） + 8 gas/非零字节

        // 字符串成本较高
        emit ExpensiveEvent("This is a long message that will cost more gas");
        // 成本 = 日志成本 + (字符串长度 * 8 gas)
    }
}

//四、索引参数（indexed）详解
//1. indexed 的作用
contract IndexedExample {
    // indexed 参数会进入 topics 数组
    event IndexedLog(
        address indexed addr1,    // topics[1]
        address indexed addr2,    // topics[2]（如果有）
        uint256 indexed id,       // topics[3]（如果有）
        string data               // 在 data 字段中
    );

    function logData() public {
        // 发出事件
        emit IndexedLog(
            msg.sender,
            address(this),
            123,
            "Additional data"
        );
    }
}

//2. Topics 结构
//日志条目包含：
//- topics[0]: 事件签名哈希（keccak256("EventName(type1,type2,...")）
//- topics[1]: 第一个 indexed 参数
//- topics[2]: 第二个 indexed 参数
//- topics[3]: 第三个 indexed 参数
//- data: 所有非 indexed 参数的 ABI 编码

//3. 过滤查询示例
// Web3.js 中通过 indexed 参数过滤
//const events = await contract.getPastEvents('Transfer', {
//    filter: {
//        from: '0x123...',      // 过滤 indexed 参数
//        to: '0x456...'         // 过滤 indexed 参数
//    },
//    fromBlock: 0,
//    toBlock: 'latest'
//});
//
// 非 indexed 参数无法直接过滤

//五、高级事件用法
//1. 继承中的事件
// 基合约定义事件
contract Base {
    event BaseEvent(address indexed user);

    function triggerBase() internal {
        emit BaseEvent(msg.sender);
    }
}

// 子合约继承并使用事件
contract Derived is Base {
    event DerivedEvent(uint256 value);

    function doSomething() public {
        emit BaseEvent(msg.sender);      // ✅ 可以触发父合约事件
        emit DerivedEvent(100);          // ✅ 触发自己的事件
        triggerBase();                   // ✅ 通过内部函数触发
    }
}

//2. 接口中的事件
// 接口定义事件
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address to, uint256 amount) external returns (bool);
}

// 实现合约触发事件
contract MyToken is IERC20 {
    mapping(address => uint256) private _balances;

    function transfer(address to, uint256 amount) external returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        // 触发接口中定义的事件
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

//3. 匿名事件
contract AnonymousEventExample {
    // 匿名事件，不记录事件签名哈希
    event AnonymousTransfer(
        address indexed from,
        address indexed to,
        uint256 value
    ) anonymous;

    function transfer(address to, uint256 amount) public {
        // 匿名事件 topics[0] 不包含事件签名
        emit AnonymousTransfer(msg.sender, to, amount);
    }
}

//六、事件在 DApp 中的应用
//1. 前端监听事件
//javascript
//// 使用 ethers.js 监听事件
//const contract = new ethers.Contract(address, abi, provider);
//
//// 方式1：实时监听
//contract.on("Transfer", (from, to, value, event) => {
//console.log(`${from} 转账给 ${to}: ${value.toString()}`);
//
//// 获取完整事件数据
//console.log("Block:", event.blockNumber);
//console.log("Transaction:", event.transactionHash);
//console.log("Log index:", event.logIndex);
//});
//
//// 方式2：查询历史事件
//const filter = contract.filters.Transfer(null, userAddress); // 过滤接收方
//const events = await contract.queryFilter(filter, fromBlock, toBlock);
//
//// 方式3：监听特定地址的转账
//const transferFilter = contract.filters.Transfer(userAddress);
//contract.on(transferFilter, (from, to, value) => {
//console.log(`用户 ${userAddress} 参与的转账`);
//});


//2. 后端事件处理
//// Node.js 后端处理事件
//const Web3 = require('web3');
//const web3 = new Web3(process.env.INFURA_URL);
//
//// 创建合约实例
//const contract = new web3.eth.Contract(abi, contractAddress);
//
//// 订阅事件
//const subscription = contract.events.Transfer({
//    fromBlock: 'latest'
//})
//.on('data', (event) => {
//    console.log('新事件:', event);
//
//    // 解析 indexed 参数
//    const from = web3.utils.toChecksumAddress(event.returnValues.from);
//    const to = web3.utils.toChecksumAddress(event.returnValues.to);
//    const value = event.returnValues.value;
//
//    // 保存到数据库
//    saveToDatabase({
//        txHash: event.transactionHash,
//        blockNumber: event.blockNumber,
//        from: from,
//        to: to,
//        value: value
//    });
//})
//.on('error', (error) => {
//    console.error('事件监听错误:', error);
//});

//七、Gas 优化技巧
//1. 减少事件数据大小
contract GasOptimizedEvents {
    // ❌ 不好：字符串成本高
    event InefficientEvent(string description, uint256 value);

    // ✅ 好：使用 bytes32 或枚举
    event EfficientEvent(bytes32 indexed eventType, uint256 value);

    // 使用枚举转换为 bytes32
    bytes32 constant TRANSFER = keccak256("TRANSFER");
    bytes32 constant APPROVAL = keccak256("APPROVAL");

    function triggerEfficient() public {
        // 使用预定义的 bytes32
        emit EfficientEvent(TRANSFER, 100);
    }
}

//2. 批量事件触发
contract BatchEvents {
    event BatchTransfer(
        address[] indexed from,
        address[] indexed to,
        uint256[] values
    );

    // ❌ 错误：数组不能 indexed
    // 正确做法：只记录摘要信息

    event TransferBatch(
        bytes32 indexed batchId,
        uint256 totalAmount,
        uint256 count
    );

    function batchTransfer(
        address[] memory recipients,
        uint256[] memory amounts
    ) public {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            // 执行转账...
            total += amounts[i];
        }

        // 只触发一个汇总事件
        emit TransferBatch(keccak256(abi.encode(block.timestamp)), total, recipients.length);
    }
}

//3. 合理使用 indexed
contract OptimizedIndexing {
    // 优化原则：
    // 1. 经常需要过滤的参数设为 indexed
    // 2. 不需要过滤的大数据不要设为 indexed
    // 3. 最多3个 indexed 参数

    // ✅ 好的设计
    event UserAction(
        address indexed user,        // 经常按用户过滤
        bytes32 indexed actionType,  // 经常按动作类型过滤
        uint256 timestamp,          // 时间戳通常不需要过滤
        bytes data                  // 大数据不索引
    );
}

//八、事件与错误处理
//1. 事件不影响交易状态
contract EventErrorHandling {
    event LogAttempt(address user, uint256 amount);
    event LogSuccess(address user, uint256 amount);

    function safeTransfer(uint256 amount) public {
        // 即使后续失败，事件也会被记录
        emit LogAttempt(msg.sender, amount);

        require(amount > 0, "Amount must be positive");

        // 如果这里失败，LogAttempt 仍然会被记录
        // 但 LogSuccess 不会
        emit LogSuccess(msg.sender, amount);
    }
}

//2. 在 try-catch 中使用事件
//显示
//// 假设存在以下接口（代码中未显式定义）
//interface IOtherContract {
//    function someFunction(bytes memory data) external;
//}
//接口定义隐式 IOtherContract(otherContract).someFunction(data)
contract TryCatchEvents {
    event ExternalCallSuccess(address contractAddr, bytes data);
    event ExternalCallFailure(address contractAddr, string reason);

    function callExternal(address otherContract, bytes memory data) public {
        try IOtherContract(otherContract).someFunction(data) {
            emit ExternalCallSuccess(otherContract, data);
        } catch Error(string memory reason) {
            //由 require()、revert("message") 或 throw 产生的字符串错误
            emit ExternalCallFailure(otherContract, reason);
        } catch (bytes memory lowLevelData) {
            //捕获的错误类型：所有其他类型的错误，包括：
            //断言失败：assert() 失败
            //除零错误：除法或取模运算中除数为零
            //数组越界：访问数组时索引超出范围
            //类型转换错误：类型转换失败
            //未实现的函数：调用不存在的函数
            //Gas 不足：执行过程中 gas 耗尽
            //其他未预料错误
            emit ExternalCallFailure(otherContract, "Low-level error");
        }
    }
}

//九、事件与升级合约
//1. 可升级合约中的事件
// 逻辑合约
contract LogicV1 {
    // 事件定义在逻辑合约中
    event ValueUpdated(uint256 newValue);

    uint256 public value;

    function updateValue(uint256 newValue) public {
        value = newValue;
        emit ValueUpdated(newValue);
    }
}

// 代理合约（使用透明代理模式）
//todo
contract Proxy {
    address public implementation;

    fallback() external payable {
        address impl = implementation;
        assembly {
        // 转发所有调用
        // 事件会以代理合约地址发出
        }
    }
}

//2. 事件版本控制
contract VersionedEvents {
    // V1 事件
    event TransferV1(address indexed from, address indexed to, uint256 value);

    // V2 事件（添加新字段）
    event TransferV2(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes32 indexed txRef
    );

    // 向后兼容
    function transfer(address to, uint256 amount) public {
        // 触发两个版本的事件
        emit TransferV1(msg.sender, to, amount);
        emit TransferV2(msg.sender, to, amount, keccak256(abi.encode(block.timestamp)));
    }
}

//十、实战示例：ERC20 转账事件
contract MyERC20 {
    // ERC20 标准事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转账函数
    function transfer(address to, uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        // 触发转账事件
        emit Transfer(msg.sender, to, amount);

        return true;
    }

    // 批量转账（节省 gas）
    function batchTransfer(
        address[] memory recipients,
        uint256[] memory amounts
    ) public returns (bool) {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        uint256 total = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            total += amounts[i];
        }

        require(_balances[msg.sender] >= total, "Insufficient balance");

        _balances[msg.sender] -= total;

        for (uint256 i = 0; i < recipients.length; i++) {
            _balances[recipients[i]] += amounts[i];

            // 为每笔转账单独触发事件
            emit Transfer(msg.sender, recipients[i], amounts[i]);
        }

        return true;
    }
}

//总结要点
//事件是链上数据的廉价存储方式
//indexed 参数用于高效过滤（最多3个）
//事件一旦发出无法撤销或修改
//合理设计事件结构可以节省大量 gas
//前端通过事件监听实现实时更新
//事件是合约与外部世界通信的主要方式
//事件是以太坊智能合约的重要组成部分，正确使用事件可以大大提升 DApp 的用户体验和开发效率。