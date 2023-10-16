// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './RequestDataStorageLib.sol';
import './TokenTransferLib.sol';
import '../../node_modules/@openzeppelin/contracts/utils/math/Math.sol';


library CoreFunctionsLib {

  //Constants for storage access
  bytes32 private  constant tip = 0x9c35b68a5d39a44a5834c87c06e0905b483f5921b1cdeb093ce2cca2a2349a4c;
  bytes32 private  constant difficulty = 0xb12aff7664b16cb99339be399b863feecd64d14817be7e1f042f97e3f358e64e;
  bytes32 private  constant birth = 0x0f3fe971129295ad98fb77108128ec4c94083ec495d6ae9d7f14797c097eba91;
  bytes32 private  constant requestQPosition = 0x1e344bd070f05f1c5b3f0b1266f4f20d837a0a8190a3a2da8b0375eac2ba86ea;
  bytes32 private  constant requestCount = 0x05de9147d05477c0a5dc675aeea733157f5092f82add148cf39d579cafe3dc98;
  bytes32 private  constant currentRequestId = 0x7584d7d8701714da9c117f5bf30af73b0b88aca5338a84a21eb28de2fe0d93b8;
  bytes32 private  constant lastCheckpoint = 0xde51f251916b3aa9a2c8ba3c001731c4a7abf4ab61324f8fa182ed1b3aca750e;
  bytes32 private  constant expiryThreshold = 0xf3b61ed74195ed072c4bce5b03aa99fc9ea41769bc3c650e65bb794e49281734;
  bytes32 private  constant totalSupply = 0x7c80aa9fdbfaf9615e4afc7f5f722e265daca5ccc655360fa5ccacf9c267936d;
  bytes32 private  constant reward = 0x594d34f771ec633c2f562d96c03f9299763555317b87ad49b1aa8c08079dde0e;
  bytes32 private  constant requestsInQ = 0x9d35db82da5d0cf70eb254e4850bba2332d9a0dd52374be5ffb3866e6f97269b;

  //Events
  event NewBlock(uint256 id, uint256 prediction, uint256 nonce);
  event ReceivedRequest(uint256 id, string dataCID, uint256 tip);


  function newBlock(RequestDataStorageLib.RequestStorageStruct storage self, uint256 _id, uint256 _nonce) internal returns(bool){
//    self.uintStorage[totalSupply] = 6000 * 10**18;
//    self.uintStorage[reward] = 50 * 10 ** 18;

    RequestDataStorageLib.Request storage request = self.requestIdToRequest[_id];

    //Simple difficulty adjustment.
    if(block.timestamp - self.uintStorage[lastCheckpoint] < 15 seconds) {
      self.uintStorage[difficulty]++;
    } else {
      self.uintStorage[difficulty] = Math.max(1, self.uintStorage[difficulty] - 1);
    }

    uint256 prediction = 0;
    uint256 cmax = 0;
    for(uint256 i = 0; i < 2; i++) {
      uint256 count = 0;
      for(uint256 j = 0; j < 2; j++) {
        if(request.finalPredictions[i] == request.finalPredictions[j])
          count++;
      }
      if(count > cmax){
        cmax = count;
        prediction = request.finalPredictions[i];
      }
    }

    //Call the user contract
    (bool result, ) = request.caller.call(abi.encodeWithSignature("requestCallback(uint256,uint256)", _id, prediction));
    require(result, "Low level call failed!");

    //Pay reward to generate new supply
    for(uint i = 0; i < 2; i++) {
      TokenTransferLib.transferFromTest(self, address(this), request.miners[i], request.uintStorage[tip] / 5 + self.uintStorage[reward]);
    }
    self.uintStorage[totalSupply] += 250 * 10 ** 18;

    //update variables
    request.isComputed = false;
    delete self.requestIdToRequest[_id];

    self.uintStorage[requestsInQ]--;

    if(self.uintStorage[requestsInQ] != 0) {
      self.uintStorage[lastCheckpoint] = block.timestamp;
      self.currentReqAddress = keccak256(abi.encodePacked(self.currentReqAddress, _nonce, blockhash(block.number - 1)));
      self.uintStorage[currentRequestId] = _getTopId(self);
    } else {
      self.uintStorage[currentRequestId] = 0;
    }

    emit NewBlock(_id, prediction, _nonce);

    return true;
  }
  function _getTopId(RequestDataStorageLib.RequestStorageStruct storage self) internal returns(uint256 topId) {
    uint256 maxPri = 0;
    uint256 maxIndex = 0; //Records current max priority
    for(uint i = 0; i < self.requestQ.length; i++) {
      if((self.requestIdToRequest[self.requestQ[i]].uintStorage[tip] + (block.timestamp - self.requestIdToRequest[self.requestQ[i]].uintStorage[birth])) > maxPri && self.requestIdToRequest[self.requestQ[i]].isComputed){
        maxPri = self.requestIdToRequest[self.requestQ[i]].uintStorage[tip];
        maxIndex = i;
      }
    }
    topId = self.requestQ[maxIndex];
    self.requestIdToRequest[topId].uintStorage[requestQPosition] = maxIndex;
  }

  function requestPrediction(RequestDataStorageLib.RequestStorageStruct storage self, string memory _dataCID, uint256 _tip) internal returns(uint256){
    self.uintStorage[difficulty] = 500;
    uint256 id = self.uintStorage[requestCount]++;

    RequestDataStorageLib.Request storage newRequest = self.requestIdToRequest[id];

    newRequest.dataCID = _dataCID;
    newRequest.caller = msg.sender;
    newRequest.requestId = id;
    newRequest.uintStorage[birth] = block.timestamp;
    newRequest.uintStorage[tip] = _tip;
    newRequest.uintStorage[requestQPosition] = self.requestQ.length;
    newRequest.isComputed = true;

    if(self.uintStorage[requestsInQ] == 0) {
      self.uintStorage[lastCheckpoint] = block.timestamp;
      self.uintStorage[currentRequestId] = id;
      self.currentReqAddress = keccak256(abi.encodePacked(self.currentReqAddress, newRequest.caller, blockhash(block.number - 1)));
    }

    bool isInserted = false;
    for(uint i = 0; i < self.requestQ.length; i++) {
      if(!self.requestIdToRequest[self.requestQ[i]].isComputed){
        delete self.requestQ[i];
        self.requestQ[i] = id;
        isInserted = true;
        break;
      }
    }
    if(!isInserted)
      self.requestQ.push(id);

    self.uintStorage[requestsInQ]++;

    if(_tip != 0)
      TokenTransferLib.transferFromTest(self, msg.sender, address(this), _tip); //Change to transferFrom for build.

    emit ReceivedRequest(id, _dataCID, _tip);
    return id;
  }

  function submitMiningSolution(RequestDataStorageLib.RequestStorageStruct storage self,
    uint256 _id,
    uint256 _prediction,
    uint256 _nonce) internal{
    RequestDataStorageLib.Request storage request = self.requestIdToRequest[_id];

    require(!request.minersSubmitted[msg.sender], "Already submitted the value for the request.");

    _verifyNonce(self, _nonce);

    request.finalPredictions[request.predictionsReceivedCount] = _prediction;
    request.minersSubmitted[msg.sender] = true;
    request.miners[request.predictionsReceivedCount] = msg.sender;
    request.predictionsReceivedCount++;

    if(request.predictionsReceivedCount == 2) {
      newBlock(self, _id, _nonce);
    }
  }

  function _verifyNonce(RequestDataStorageLib.RequestStorageStruct storage self, uint256 _nonce) internal view {
    uint256 targetHashValue = uint256(self.currentReqAddress) / self.uintStorage[difficulty];
    uint256 receivedUnderTargetHash = uint256(keccak256((abi.encodePacked(self.currentReqAddress, msg.sender, _nonce))));
    require(targetHashValue > receivedUnderTargetHash, "Invalid nonce for the current challenge.");
  }

}
