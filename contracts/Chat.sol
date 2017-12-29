pragma solidity ^0.4.7;

contract Chat {
  event UserRegistered (address _addr, uint id);
  struct Message {
    uint timestamp;
    string message;
  }

  struct Conversation {
    bool _initialized;
    uint num_messages;
    mapping (uint => Message) messages;
  }

  mapping (address => mapping (address => Conversation)) conversations;
  mapping (uint => address) users;
  uint num_users;

  function register () payable public returns (bool success) {
    users[num_users++] = msg.sender;
    UserRegistered(msg.sender, num_users);
    return true;
  }

  function isRegistered (address _isRegistered) public constant returns (bool registered) {
    for (uint i = 0 ; i < num_users; i++) {
      if (users[i] == _isRegistered) {
        return true;
      }
    }
    return false;
  }

  function Chat() public {
    num_users = 0;
  }

  function message(address _to, string message) public {
    require(isRegistered(msg.sender));
    require(isRegistered(_to));
    require(msg.sender != _to);

    address _from = msg.sender;

    if (conversations[_to][msg.sender]._initialized) {
      _from = _to;
      _to = msg.sender;
    }

    Conversation c;

    // If conversation is not yet initialized
    if (!c._initialized) {
      c._initialized = true;
      c.num_messages = 0;
    } else {
      c = conversations[_from][_to];
    }

    uint n = c.num_messages;
    Message m;
    m.timestamp = now;
    m.message = message;

    c.messages[n] = m;
    c.num_messages++;

    conversations[_from][_to] = c;
  }

  function getMessage(address _with, uint messageNumber) public constant returns (string message, uint timestamp) {
    address _from = msg.sender;

    if (conversations[_with][msg.sender]._initialized) {
      _from = _with;
      _with = msg.sender;
    }

    message = conversations[_from][_with].messages[messageNumber].message;
    timestamp = conversations[_from][_with].messages[messageNumber].timestamp;
    return (message, timestamp);
  }

  function getLatest (address _with) public constant returns (string message, uint timestamp) {
    address _from = msg.sender;

    if (conversations[_with][msg.sender]._initialized) {
      _from = _with;
      _with = msg.sender;
    }
    uint n = conversations[_from][_with].num_messages - 1;
    message = conversations[_from][_with].messages[n].message;
    timestamp = conversations[_from][_with].messages[n].timestamp;
    return (message, timestamp);
  }
}
