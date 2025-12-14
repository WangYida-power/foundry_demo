// SPDX-License-Identifier: MIT

// pragma solidity 0.8.7;
// pragma solidity ^0.8.7;
pragma solidity >=0.8.7 <0.9.0;

contract SimpleStorageDemo {
    // boolean uint无符号整数 只能是正数 int正数or负数 address bytes
    bool hasFavoriteNumber = true;
    uint256 a = 123;
    uint8 b = 1;
    string test = "Five";
    int256 ia = -5;
    address myAddress = 0xcf36Acfed9D31238e65091Dd768BC79Ee9Ddb1D4;
    bytes32 bbb = "cat";
    uint256 public favoriteNumber;//默认赋值为0 加上public相当于一个view的getter方法
    //public private external internal
    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
        retrieve();
    }

    function retrieve() public view returns (uint256){
        return favoriteNumber;
    }
    //view意味着只会读取合约的状态 pure不允许读取区块链数据 在这两个函数中不可修改任何状态 调取view pure不需要支付gas
//0xd9145CCE52D386f254917e481eB44e9943F39138

    People public person = People({favoriteNumber: 2, name: "wangyd"});
    People[] public people;
    uint256[] public favoriteNumberList;

    struct People {
        uint256 favoriteNumber;
        string name;
    }

}
