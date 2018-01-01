pragma solidity ^0.4.18;

import "./KomodoToken.sol";

contract KomodoGateway {
  event CreatePot(uint _id);
  event JoinPot(uint _potId, address _address, uint stakeSize);
  event FinalizePot(uint _id, uint _amount, uint _numParticipants);
  event TokenAddressChanged(address _old, address _new);

  enum PotState {
    OPEN,
    CLOSED,
    PAUSED
  }

  struct Pot {
    uint _id;
    uint _numParticipants;
    uint amount;
    mapping (address => uint) _stakes;
  }

  mapping (uint => Pot) _pots;
  address _god;
  address _tokenAddress;
  uint currentPot;

  function KomodoGateway() public {
    _god = msg.sender;
    _iterPot();
  }

  modifier hasGodAccess {
    require(msg.sender == _god);
    _;
  }

  function fetchCurrentPotId () public view returns (uint) {
    return currentPot;
  }

  function setTokenAddress (address _t) public hasGodAccess {
    TokenAddressChanged(_tokenAddress, _t);
    _tokenAddress = _t;
  }

  function _iterPot() private {
    Pot memory p;
    p._id = currentPot;
    p._numParticipants = 0;
    p.amount = 0;
    _pots[currentPot++] = p;
  }
}
