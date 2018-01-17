pragma solidity ^0.4.18;

import "./KomodoToken.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "oraclize/usingOraclize.sol";
import "./strings.sol";


contract KomodoGateway is usingOraclize {
    using SafeMath for *;
    using strings for *;

    event CreatePot(uint _id);
    event JoinPot(uint indexed _potId, uint _amount, address _address);
    event FinalizePot(uint _id, uint _amount, uint _numParticipants);
    event TokenAddressChanged(address _old, address _new);
    event IssueRefund(address _user, uint _amount);
    event PotError(address _winner, uint _amount);
    event PotWinner(address _addr, uint _stake);
    event CallbackFired(uint _result);
    event InitSettle(uint _amount);
    event SentMoney(uint _amount);

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
    address private _oraclizeAddress;
    uint private currentPot;
    uint256 private _minBetSize;
    uint256 private _weiPerEth = 1000000000000000000;

    function KomodoGateway() public {
        // Result of running eth-bridge (necessary for test-net to be able to use
        // oraclize for offchain requests!)
        _oraclizeAddress = 0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475;
        OAR = OraclizeAddrResolverI(_oraclizeAddress);
        _god = msg.sender;
        _minBetSize = 500000000000000000; // 0.1 eth
        currentPot = 1;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        _pot();
    }

    modifier hasGodAccess() {
        require(msg.sender == _god);
        _;
    }

    modifier edible (uint _amount) {
        if (_amount > _minBetSize) {
            _;
        }
    }

    modifier isOraclize() {
        if (msg.sender == _oraclizeAddress) {
            _;
        }
    }

    function joinPot () public payable edible(msg.value) {
        JoinPot(currentPot, msg.value, msg.sender);

        Pot p = _pots[currentPot];

        if (p._stakes[msg.sender] == 0) {
            p._participants[p._numParticipants++] = msg.sender;
        }

        p._stakes[msg.sender] += msg.value;
        p._amount += msg.value;

        if (p._amount > 5000000000000000000) {
            _initSettle(p._amount);
        }
    }

    function fetchCurrentPotId () public view returns (uint) {
        return currentPot;
    }

    function fetchCurrentPotAmount () public view returns (uint) {
        return _pots[currentPot]._amount;
    }

    function setTokenAddress (address _t) public hasGodAccess {
        TokenAddressChanged(_tokenAddress, _t);
        _tokenAddress = _t;
    }

    function __callback(bytes32 _queryId, string _result, bytes _proof) public {
        var _parsedResponse = stringToUint(_result);
        _finalizeSettle(_parsedResponse);
    }

    function _initSettle(uint _potAmount) private {
        InitSettle(_potAmount);
        var _query = "random number between 0 and ".toSlice().concat(uintToString(_potAmount).toSlice());
        oraclize_query("WolframAlpha", _query);
    }

    function stringToUint(string s) private constant returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (b[i] >= 48 && b[i] <= 57) {
                result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        return result; // this was missing
    }

    function uintToString(uint v) private returns (string) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);  // memory isn't implicitly convertible to storage
        return str; // this was missing
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
        CallbackFired(_rand);
        Pot p = _pots[currentPot];
        uint cursor = 0;
        for (uint i = 0; i < p._numParticipants; i++) {
            if (_rand <= cursor + p._stakes[p._participants[i]]) {
                PotWinner(p._participants[i], p._stakes[p._participants[i]]);
                if (p._participants[i].send(p._amount)) {
                    SentMoney(p._amount);
                    currentPot++;
                    _pot();
                } else {
                    PotError(p._participants[i], p._amount);
                }
                return;
            }
            cursor += p._stakes[p._participants[i]];
        }
    }

}
