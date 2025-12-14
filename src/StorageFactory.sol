// SPDX-License-Identifier: MIT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract StorageFactory {
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }

    function sfStore(uint256 _simpleStoreIndex, uint256 _simpleStoreNumber) public {
        //合约交互需要
        // Address
        // ABI - Application Binary Interface
        // SimpleStorage simpleStorage = SimpleStorage(simpleStorageArray[_simpleStoreIndex]);//如果是address[]需要这样创建
        // SimpleStorage simpleStorage = simpleStorageArray[_simpleStoreIndex];
        simpleStorageArray[_simpleStoreIndex].store(_simpleStoreNumber);
    }

    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256){
        // SimpleStorage simpleStorage = simpleStorageArray[_simpleStorageIndex];
        // return simpleStorage.retrieve();
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }

}