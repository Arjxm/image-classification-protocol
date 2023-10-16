// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library RequestDataStorageLib{

  struct Error {
    uint256 errorType; //0: Invalid datapoint, 1: invalid request hash (No such dataset/model)
    bool hasError;
  }

  struct Request {
    string dataCID;

    address caller;

    uint256 requestId;
    uint256 predictionsReceivedCount;
    uint256[2] finalPredictions;

    address[2] miners;

    bool isComputed;

    mapping(address => bool) minersSubmitted;
    mapping(bytes32 => uint256) uintStorage;
  }

  struct RequestStorageStruct{
    mapping(bytes32 => uint) uintStorage;
    mapping(bytes32 => address) addressStorage;

    bytes32 currentReqAddress;

    uint256[] requestQ;

    mapping(uint256 => Request) requestIdToRequest;
    //Token Vars
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
  }

  function updateRequest(RequestStorageStruct storage self, address _newRequest) internal {
    require(msg.sender == self.addressStorage[keccak256('owner')], "Not authorised.");
    self.addressStorage[keccak256('ReqAddress')] = _newRequest;
  }

  function updateOwner(RequestStorageStruct storage self, address _newOwner) internal {
    require(msg.sender == self.addressStorage[keccak256('owner')], "Not authorised.");
    self.addressStorage[keccak256('owner')] = _newOwner;
  }
}
