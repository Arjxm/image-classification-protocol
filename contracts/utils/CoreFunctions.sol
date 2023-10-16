// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import '../libraries/RequestDataStorageLib.sol';
import '../libraries/TokenTransferLib.sol';
import '../libraries/CoreFunctionsLib.sol';

contract CoreFunctions {

    using CoreFunctionsLib for RequestDataStorageLib.RequestStorageStruct;
    using TokenTransferLib for RequestDataStorageLib.RequestStorageStruct;

    RequestDataStorageLib.RequestStorageStruct data;

    function requestPrediction(string calldata _dataCID,uint256 _tip) external returns(uint256){
        return data.requestPrediction(_dataCID, _tip);
    }


    function submitMiningSolution(uint256 _id, uint256 _prediction, uint256 _nonce) external {
        data.submitMiningSolution(_id, _prediction, _nonce);
    }


    /* Utility token functions */
    function name() external pure returns(string memory) {
        return "Arshu Token";
    }

    function symbol() external pure returns(string memory) {
        return "ARS";
    }

    function decimals() external pure returns(uint256) {
        return 18;
    }


    function transferTest(address _to, uint256 _value) external returns(bool) {
        return data.transferTest(_to, _value);
    }


    function transferFromTest(address _from, address _to, uint256 _value) external returns(bool) {
        return data.transferFromTest(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) external returns(bool) {
        return data.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns(bool) {
        return data.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) external returns(bool){
        return data.approve(_spender, _value);
    }
}
