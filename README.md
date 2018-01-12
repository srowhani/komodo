# Komodo

## Instructions

#### Dependencies
First thing to do is install all the dependencies

```
  npm install
  npm install -g truffle
  npm install -g ethereumjs-testrpc
```

#### Getting Started

```
  npm run testrpc
  npm run bridge
```

Then from the output of `npm run bridge` copy OAR from output to stdout
and copy into constructor into `KomodoGateway`.

```
function KomodoGateway() public {
    // Result of running eth-bridge (necessary for test-net to be able to use
    // oraclize for offchain requests!)
    OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    _god = msg.sender;
    _minBetSize = 500000000000000000; // 0.1 eth
    currentPot = 1;
    _pot();
}
```

By default mnemonic will be the same running `npm run testrpc`, so the 49'th address
used to deploy `oraclize` on testnet will most likely be the same.

Next is compiling, and migrating the contracts

```
npm run compile
npm run migrate
```

After completing migrations, you can launch the dev server


```
npm run start
```

This will open your browser of preference at localhost:8080

The app requires MetaMask for web3 injection.

https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn
