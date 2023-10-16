// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol';
import './RequestDataStorageLib.sol';


library GetRequestDataLib {
  using SafeMath for uint256;

  function getAddressStorage(RequestDataStorageLib.RequestStorageStruct storage self, bytes32 _data) internal view returns(address){
      return self.addressStorage[_data];
  }

  function getUintStorage(RequestDataStorageLib.RequestStorageStruct storage self, bytes32 _data) internal view returns(uint){
      return self.uintStorage[_data];
  }

  function getCurrentVariables(RequestDataStorageLib.RequestStorageStruct storage self) internal view returns(
    bytes32, uint256, uint256, string memory
  ) {
    return (
      self.currentReqAddress,
      self.uintStorage[keccak256('currentRequestId')],
      self.uintStorage[keccak256('difficulty')],
      self.requestIdToRequest[self.uintStorage[keccak256('currentRequestId')]].dataCID
    );
  }

  function canGetVariables(RequestDataStorageLib.RequestStorageStruct storage self) internal view returns(bool) {
    return self.uintStorage[keccak256('requestsInQ')] != 0;
  }

  function totalSupply(RequestDataStorageLib.RequestStorageStruct storage self) internal view returns(uint256) {
    return self.uintStorage[keccak256('totalSupply')];
  }
}
