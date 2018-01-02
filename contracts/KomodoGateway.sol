pragma solidity ^0.4.18;

import "./KomodoToken.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract KomodoGateway {
  using SafeMath for *;

  event CreatePot(uint _id);
  event JoinPot(uint _potId, address _address, uint stakeSize);
  event FinalizePot(uint _id, uint _amount, uint _numParticipants);
  event TokenAddressChanged(address _old, address _new);
  event IssueRefund(address _user, uint _amount);

  enum PotState {
    OPEN,
    CLOSED,
    PAUSED
  }

  struct Pot {
    uint _id;
    uint _numParticipants;
    uint _amount;
    mapping (address => uint) _stakes;
  }

  mapping (uint => Pot) _pots;

  address _god;
  address _tokenAddress;
  uint currentPot;
  float _minBetSize;

  function KomodoGateway() public {
    _god = msg.sender;
    _minBetSize = 0.05;
    _pot();
  }

  modifier hasGodAccess {
    require(msg.sender == _god);
    _;
  }

  modifier edible (uint _amount) {
    if (_amount > _minBetSize) {
      _;
    }
  }

  function joinPot (uint amount) public payable edible(msg.value) {
    // log all join interactions, allow client to parse available transaction blocks
    // for room metrics
    JoinPot(currentPot, msg.sender, msg.value);
    Pot p = _pots[currentPot];

    if (p._stakes[msg.sender] == 0) {
      p._numParticipants += 1;
    }

    p._stakes[msg.sender] = msg.value;
    p._amount = add(p._amount, msg.value);
  }

  function fetchCurrentPotId () public view returns (uint) {
    return currentPot;
  }

  function setTokenAddress (address _t) public hasGodAccess {
    TokenAddressChanged(_tokenAddress, _t);
    _tokenAddress = _t;
  }

  function _pot() private {
    Pot memory p;
    p._id = currentPot;
    p._numParticipants = 0;
    p._amount = 0;
    _pots[currentPot++] = p;
  }
}
