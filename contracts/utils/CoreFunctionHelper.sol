// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./GetRequestData.sol";

contract CoreFunctionHelper is GetRequestData{
    using RequestDataStorageLib for  RequestDataStorageLib.RequestStorageStruct;

    constructor(address _newRequestAddress) {
        data.addressStorage[keccak256('ReqAddress')] = _newRequestAddress;
        data.addressStorage[keccak256('owner')] = msg.sender;
    }

    //Event sharing
    event NewBlock(uint256 id, uint256 prediction, uint256 nonce);
    event ReceivedRequest(uint256 id, string dataCID, uint256 tip);


    function updateRequest(address _newRequest) external {
        data.updateRequest(_newRequest);
    }

    function updateOwner(address _newOwner) external {
        data.updateOwner(_newOwner);
    }

    fallback() external payable {
        address _impl = data.addressStorage[keccak256('ReqAddress')];

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    receive() external payable {}
}
