// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '../../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol';
import './RequestDataStorageLib.sol';


library TokenTransferLib {

  using SafeMath for uint256;

  //ERC20 based Events
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);


  function transferTest(RequestDataStorageLib.RequestStorageStruct storage self, address _to, uint256 _value) internal returns(bool){
    _transfer(self, msg.sender, _to, _value);
    return true;
  }

  function transferFromTest(RequestDataStorageLib.RequestStorageStruct storage self, address _from,address _to, uint256 _value) internal returns(bool){
    _transfer(self, _from, _to, _value);
    return true;
  }

  function transfer(RequestDataStorageLib.RequestStorageStruct storage self, address _to, uint256 _value) internal returns(bool){
    _transfer(self, msg.sender, _to, _value);
    return true;
  }

  function transferFrom(RequestDataStorageLib.RequestStorageStruct storage self, address _from, address _to, uint256 _value)
    internal returns(bool) {
      require(self.allowances[_from][msg.sender] >= _value, "not allowed to transfer the specified amount");
      self.allowances[_from][msg.sender] -= _value;
      _transfer(self, _from, _to, _value);
      return true;
  }

  function _transfer(RequestDataStorageLib.RequestStorageStruct storage self, address _from, address _to, uint256 _value)
    internal {
      require(_value >= 0, "Transferring a non positive amount");
      require(balanceOf(self, _from) >= _value, "Insufficient transfer balance");
      self.balances[_from] -= _value;
      self.balances[_to] += _value;
      emit Transfer(_from, _to, _value);
  }

  function approve(RequestDataStorageLib.RequestStorageStruct storage self, address _spender, uint256 _value) internal returns(bool) {
    self.allowances[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function balanceOf(RequestDataStorageLib.RequestStorageStruct storage self, address _owner) internal view returns(uint256){
    return self.balances[_owner];
  }

  function allowance(RequestDataStorageLib.RequestStorageStruct storage self, address _owner, address _spender)
    internal view returns(uint256){
    return self.allowances[_owner][_spender];
  }
}
