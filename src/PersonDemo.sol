// SPDX-License-Identifier: MIT
//MIT限制最小
pragma solidity >=0.8.7 <0.9.0;

//变量的数据位置必须是 storage memory calldata
//EVM can access and store information in six places:
// stack memory storage calldata code logs
// calldata 函数调用栈，标志着函数参数没有使用指针引用，不能进行赋值修改等操作
//calldata memory意味着变量暂时存在，calldata不能被修改，memory可以被修改
//storage存储变量甚至存在于正在执行的函数之外
contract PersonDemo {
    uint256 public favoriteNumber;
    // People public person = People({number: 2, name: "wangyd"});
    People[] public people; //自动分配为一个存储变量
    uint256[] public favoriteNumberList;

    mapping(string => uint256) public nameToFavoriteNumber;

    struct People {
        uint256 number;
        string name;
    }

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
        retrieve();
    }

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }

    //数组、结构、映射在Solidity被认为是特殊的类型，Solidity可以自动知道uint256位置
    //String是一个bytes数组，所以需要加memory
    function addPerson(string memory _name, uint256 _number) public {
        People memory newPerson = People({number: _number, name: _name});
        // People memory newPerson = People({_number, _name});
        people.push(newPerson);
        // people.push(People(_number, _name));
        nameToFavoriteNumber[_name] = _number;
    }
}
