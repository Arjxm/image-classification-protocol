// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import '../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol';
import '../libraries/RequestDataStorageLib.sol';
import '../libraries/GetRequestDataLib.sol';
import '../libraries/TokenTransferLib.sol';
import '../libraries/CoreFunctionsLib.sol';

abstract contract GetRequestData {
    using SafeMath for uint256;
    using GetRequestDataLib for RequestDataStorageLib.RequestStorageStruct;
    using RequestDataStorageLib for RequestDataStorageLib.RequestStorageStruct;
    using TokenTransferLib for RequestDataStorageLib.RequestStorageStruct;
    using CoreFunctionsLib for RequestDataStorageLib.RequestStorageStruct;

    RequestDataStorageLib.RequestStorageStruct data;

    function getAddressStorage(bytes32 _data) external view returns(address) {
        return data.getAddressStorage(_data);
    }


    function getUintStorage(bytes32 _data) external view returns(uint256) {
        return data.getUintStorage(_data);
    }


    function getCurrentVariables() external view returns(bytes32, uint256, uint256, string memory) {
        return data.getCurrentVariables();
    }

    function canGetVariables() external view returns(bool) {
        return data.canGetVariables();
    }

    // ERC20 utility token helpers

    function balanceOf(address _owner) external view returns(uint256) {
        return data.balanceOf(_owner);
    }

    function allowance(address _owner, address _spender) external view returns(uint256) {
        return data.allowance(_owner, _spender);
    }

    function totalSupply() external view returns(uint256) {
        return data.totalSupply();
    }
}
