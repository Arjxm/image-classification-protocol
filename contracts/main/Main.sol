// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Main {

  address owner;
  address implAddress;

  mapping(uint256 => bool) pendingRequests;
  mapping(uint256 => uint256) responses;

  uint256 latestResponseId;

  bytes32 private passCode;

  event NewRequest(string dataCID, uint256 tip, uint256 requestId);
  event ReceivedPrediction(uint256 requestId, uint256 prediction);
  event EthMLContractChanged(address newAddress);

  constructor(address _implAddress)  {
    owner = msg.sender;
    implAddress = _implAddress;
  }

  //Create passWord for user 
  function convertToBytes32(string memory input) private pure returns (bytes32) {
        bytes32 result = keccak256(abi.encodePacked(input));
        return result;
    }
  /**
  * @notice Change to internal
  * @dev sends prediction request to proxy.
  */
  function requestPrediction(string calldata _dataCID, uint256 _tip) external {

    //Create passCode 
    passCode = convertToBytes32(_dataCID);

    address _impl = implAddress;
    bytes memory _calldata = abi.encodeWithSignature('requestPrediction(string,uint256)', _dataCID, _tip);
    uint256 _id;

    assembly {
      let ptr := mload(0x40)
      let result := call(gas(), _impl, 0, add(_calldata, 32), mload(_calldata), 0, 0)
      returndatacopy(ptr, 0, returndatasize())
      _id := mload(ptr)
    }

    pendingRequests[_id] = true;
    emit NewRequest( _dataCID, _tip, _id);
  }

  //submit sol
  function requestCallback(uint256 _id, uint256 _prediction) external isValidCall(_id){
    latestResponseId = _id;
    delete pendingRequests[_id];
    responses[_id] = _prediction;

    emit ReceivedPrediction(_id, _prediction);
  }


  function getLatestResponse(bytes32 _passCode) external view returns(uint256) {
    require(_passCode == passCode, "No auth");
    return responses[latestResponseId];
  }

  modifier isValidCall(uint256 _id) {
    require(pendingRequests[_id], "Invalid request id!");
    require(msg.sender == implAddress, "Not authorized!");
    _;
  }
}
