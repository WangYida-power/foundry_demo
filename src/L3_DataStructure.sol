// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// stack memory storage calldata code logs

// 变量的数据位置必须是 storage memory calldata
// calldata 函数调用栈，标志着函数参数没有使用指针引用，不能进行赋值修改等操作
// calldata memory意味着变量暂时存在，calldata不能被修改，memory可以被修改
// storage存储变量甚至存在于正在执行的函数之外

// stack栈
//用于存储函数内部的局部值类型变量（如uint、bool等）。
//栈是临时的，函数执行结束后，栈中的数据会被清除。
//栈的大小有限（在EVM中为1024个元素），因此不适合存储大量数据或复杂结构。

//memory内存
//用于存储临时数据，如函数参数、局部变量（特别是引用类型，如数组、结构体）在函数执行期间存在。
//内存是线性的，按字节寻址，读写速度较快，但会在函数调用结束时被清除。
//当你在函数内部声明一个数组或结构体，并且不希望它持久化存储时，可以使用memory。

// storage存储
//用于永久存储数据，是合约状态变量存储的地方。
//存储是键值对存储，键和值都是32字节。
//对存储的读写操作开销较大，因此应谨慎使用。
//存储在storage中的数据会持久化，直到被修改或合约被销毁。

// calldata调用数据
//一个只读区域，用于存储函数调用的参数。
//对于外部函数的参数，如果它们是数组或结构体等引用类型，可以指定为calldata。
//使用calldata可以避免复制数据，节省gas，因为数据直接从调用中读取，不拷贝到内存。

//code（代码）：
//这里指的是合约的代码，是只读的，存储合约的字节码。
//通常不直接用于变量存储，但可以通过内联汇编访问。

//logs（日志）：
//用于存储事件（events）发出的数据。
//日志数据存储在区块链上，但智能合约无法直接访问，只能通过事件日志的外部证明来获取。
//日志是一种相对便宜的存储方式，适合记录合约的状态变化

//对比表格
//存储位置	持久性	读写成本	    可变性	使用场景
//stack	    临时	    最低	        读写	    函数局部值类型变量
//memory	临时	    低	        读写	    函数内部引用类型临时变量
//storage	永久	    最高	        读写	    合约状态变量
//calldata	临时	    最低	        只读  	函数参数（外部函数）
//code	    永久	    低（只读）	只读	    常量、immutable变量、合约字节码
//logs	    永久	    中等（写入）	只写	    事件、历史记录

//Gas 成本对比
//从高到低：storage 写入 > storage 读取 > memory 写入 > memory 读取 > stack > calldata
contract L3_DataStructure {
    // 状态变量存储在storage中
    uint256 public storedData;
    uint256[] public arr;

    // 事件将数据存储在logs中
    event DataStored(uint256 data);

    // 函数参数可以指定为calldata（外部函数）
    function setData(uint256 _data) external {
        // 局部变量data存储在栈上
        uint256 data = _data;

        // 修改状态变量，存储在storage中
        storedData = data;

        // 触发事件，数据存储在logs中
        emit DataStored(data);
    }

    // 使用memory和calldata的示例
    function processArray(uint256[] calldata input) external pure returns (uint256[] memory) {
        // 限制输入数组的大小，防止gas消耗过多
        require(input.length <= 100, "Input array too large");

        // 将calldata数组复制到memory中，以便修改（calldata是只读的）
        uint256[] memory localArray = input;

        // 修改memory中的数组
        localArray[0] = 1;

        // 返回memory数组
        return localArray;
    }

    // 使用storage的示例
    function getArray() external view returns (uint256[] memory) {
        // 返回storage数组的memory副本（因为返回类型是memory）
        return arr;
    }

    // 使用storage指针
    function updateArray() external {
        // storage指针指向状态变量arr
        uint256[] storage arrRef = arr;
        arrRef.push(10);
    }

}