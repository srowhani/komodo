pragma solidity 0.4.18;

import "./KomodoToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract KomodoGateway is usingOraclize {
    event CreatePot(uint _id);
    event JoinPot(uint indexed _potId, uint _potSize, address _address, uint stakeSize);
    event FinalizePot(uint _id, uint _amount, uint _numParticipants);
    event TokenAddressChanged(address _old, address _new);
    event IssueRefund(address _user, uint _amount);
    event PotError(uint indexed _potId, uint indexed _queryId);

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

    mapping (uint => Pot) private _pots;

    address private _god;
    address private _tokenAddress;
    uint private currentPot;
    uint256 private _minBetSize;

    function KomodoGateway(address _randomContract) public {
        _god = msg.sender;
        random = _randomContract
        _minBetSize = 10; // 0.1 eth
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
        // log all join interactions, allow client to parse available transaction blocks
        // for room metrics
        Pot p = _pots[currentPot];

        if (p._stakes[msg.sender] == 0) {
            p._numParticipants += 1;
        }

        p._stakes[msg.sender] = msg.value;
        p._amount += msg.value;
        JoinPot(currentPot, p._amount, msg.sender, msg.value);
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

        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            PotError(currentPot, _queryId);
        } else {
            uint maxRange = 2 ** (8 * _pots[currentPot]._amount);
            uint _rand = uint(keccak256(_result)) % maxRange;
            _finalize_settle(_rand);
        }


    }

    function _pot() private {
        Pot memory p;
        p._id = currentPot;
        p._numParticipants = 0;
        p._amount = 0;
        _pots[currentPot] = p;
        CreatePot(currentPot);
    }

    function _initSettle() private {
        Pot p = _pots[currentPot]

        uint _potSize = p._amount;
        uint _delay = 0;
        uint _callbackGas = 200000;

        oraclize_newRandomDSQuery(_delay, _potSize, _callbackGas);
    }

    function _finalizeSettle (uint _rand) private {
        Pot p = _pots[currentPot];
        uint cursor = 0;
        for (uint i = 0; i < p._numParticipants; i++) {
            if (_rand <= cursor + p._stakes[p._addr[i]]) {
              // Winner is p._addr[i]
            }
            cursor += p._stakes[p._addr[i]];
        }
    }

}
