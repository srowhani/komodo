pragma solidity ^0.4.18;
//name this contract whatever you'd like
import "./StandardToken.sol";
contract KomodoToken is StandardToken {
  event Refund(address _addr);

  function () public {
        Refund(msg.sender);
        revert();
  }

  string public name;
  uint8 public decimals;
  string public symbol;
  string public version = '1.0';

  function KomodoToken() public {
    balances[msg.sender] = 10000;
    totalSupply = 10000;
    name = "Komodo";
    decimals = 0;
    symbol = "KMD";
  }

  /* Approves and then calls the receiving contract */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    if (!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)){
      revert();
    }
    return true;
  }
}
