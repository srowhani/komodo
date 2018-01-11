pragma solidity 0.4.18;

import "./KomodoToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "oraclize/usingOraclize.sol";


contract KomodoGateway is usingOraclize {
    using SafeMath for *;

    event CreatePot(uint _id);
    event JoinPot(uint indexed _potId, uint _amount, address _address);
    event FinalizePot(uint _id, uint _amount, uint _numParticipants);
    event TokenAddressChanged(address _old, address _new);
    event IssueRefund(address _user, uint _amount);
    event PotError(bytes32 _queryId, bytes _proof);
    event PotWinner(address _addr, uint _stake);

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
        mapping (uint => address) _participants;
    }

    mapping (uint => Pot) private _pots;

    address private _god;
    address private _tokenAddress;
    uint private currentPot;
    uint256 private _minBetSize;

    function KomodoGateway() public {
        _god = msg.sender;
        _minBetSize = 10; // 0.1 eth
        currentPot = 1;
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

    function joinPot () public payable {
        JoinPot(currentPot, msg.value, msg.sender);

        Pot p = _pots[currentPot];

        if (p._stakes[msg.sender] == 0) {
            p._participants[p._numParticipants++] = msg.sender;
        }

        p._stakes[msg.sender] = msg.value;
        p._amount += msg.value;
    }

    function fetchCurrentPotId () public view returns (uint) {
        return currentPot;
    }

    function setTokenAddress (address _t) public hasGodAccess {
        TokenAddressChanged(_tokenAddress, _t);
        _tokenAddress = _t;
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) {
        if (msg.sender != oraclize_cbAddress())
            revert();

        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) == 0) {
            uint maxRange = 2 ** (8 * _pots[currentPot]._amount);
            uint _rand = uint(keccak256(_result)) % maxRange;
            _finalizeSettle(_rand);
        } else {
            PotError(_queryId, _proof);
        }
    }

    function _initSettle() public {
        Pot p = _pots[currentPot];

        uint _potSize = p._amount;
        uint _delay = 0;
        uint _callbackGas = 120000;

        oraclize_newRandomDSQuery(_delay, _potSize, _callbackGas);
    }

    function _pot() private {
        Pot memory p;
        p._id = currentPot;
        p._numParticipants = 0;
        p._amount = 0;
        _pots[currentPot] = p;
        CreatePot(currentPot);
    }

    function _finalizeSettle (uint _rand) private {
        Pot p = _pots[currentPot];
        uint cursor = 0;
        for (uint i = 0; i < p._numParticipants; i++) {
            if (_rand <= cursor + p._stakes[p._participants[i]]) {
                PotWinner(p._participants[i], p._stakes[p._participants[i]]);
            }
            cursor += p._stakes[p._participants[i]];
        }
    }

}
