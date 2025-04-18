# BuyEarth Deployment

## 部署合约

```bash
buyearth on  master [✘!+?] via 🅒 base took 41.7s 
➜ forge script BuyEarthScript --rpc-url $MONAD_RPC_URL  --broadcast -vvvvv          
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] BuyEarthScript::setUp()
    └─ ← [Stop]

  [428362] BuyEarthScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [383740] → new BuyEarth@0x00189Cae228389b61f68B4e3520393941dAAD6e1
    │   └─ ← [Return] 1806 bytes of code
    ├─ [0] console::log("BuyEarth deployed to:", BuyEarth: [0x00189Cae228389b61f68B4e3520393941dAAD6e1]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  BuyEarth deployed to: 0x00189Cae228389b61f68B4e3520393941dAAD6e1

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [383740] → new BuyEarth@0x00189Cae228389b61f68B4e3520393941dAAD6e1
    └─ ← [Return] 1806 bytes of code


==========================

Chain 10143

Estimated gas price: 100.000000001 gwei

Estimated total gas used for script: 605982

Estimated amount required: 0.060598200000605982 ETH

==========================

##### monad-testnet
✅  [Success] Hash: 0x20539872430564608a34726305a6d2e3616f330b2142a4165fc0911d3c08def9
Contract Address: 0x00189Cae228389b61f68B4e3520393941dAAD6e1
Block: 12326687
Paid: 0.030299100000605982 ETH (605982 gas * 50.000000001 gwei)

✅ Sequence #1 on monad-testnet | Total Paid: 0.030299100000605982 ETH (605982 gas * avg 50.000000001 gwei)
                                                                                                               

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /Users/qiaopengjun/Code/monad/buyearth/broadcast/Counter.s.sol/10143/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/monad/buyearth/cache/Counter.s.sol/10143/run-latest.json



buyearth on  master [✘!+?] via 🅒 base took 9.0s 
➜ forge clean && forge build                                               
[⠊] Compiling...
[⠰] Compiling 23 files with Solc 0.8.28
[⠑] Solc 0.8.28 finished in 4.45s
Compiler run successful!

buyearth on  master [✘!+?] via 🅒 base took 5.1s 
➜ forge script BuyEarthScript --rpc-url $MONAD_RPC_URL  --broadcast -vvvvv 
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] BuyEarthScript::setUp()
    └─ ← [Stop]

  [552447] BuyEarthScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [507659] → new BuyEarth@0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D
    │   └─ ← [Return] 2425 bytes of code
    ├─ [0] console::log("BuyEarth deployed to:", BuyEarth: [0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  BuyEarth deployed to: 0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [507659] → new BuyEarth@0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D
    └─ ← [Return] 2425 bytes of code


==========================

Chain 10143

Estimated gas price: 100.000000001 gwei

Estimated total gas used for script: 779785

Estimated amount required: 0.077978500000779785 ETH

==========================

##### monad-testnet
✅  [Success] Hash: 0xea135b6f31118e73319e4fc1122ab080975b23c5f42d370e6b422cba0f809271
Contract Address: 0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D
Block: 12417895
Paid: 0.038989250000779785 ETH (779785 gas * 50.000000001 gwei)

✅ Sequence #1 on monad-testnet | Total Paid: 0.038989250000779785 ETH (779785 gas * avg 50.000000001 gwei)
                                                                                                               

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /Users/qiaopengjun/Code/monad/buyearth/broadcast/BuyEarth.s.sol/10143/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/monad/buyearth/cache/BuyEarth.s.sol/10143/run-latest.json

```

## 验证合约

```bash
buyearth on  master [✘!+?] via 🅒 base 
➜ forge verify-contract \
  --rpc-url https://testnet-rpc.monad.xyz \
  --verifier sourcify \
  --verifier-url 'https://sourcify-api-monad.blockvision.org' \
  0x00189Cae228389b61f68B4e3520393941dAAD6e1 \
  src/BuyEarth.sol:BuyEarth
Start verifying contract `0x00189Cae228389b61f68B4e3520393941dAAD6e1` deployed on monad-testnet
Attempting to verify on Sourcify. Pass the --etherscan-api-key <API_KEY> to verify on Etherscan, or use the --verifier flag to verify on another provider.

Submitting verification for [BuyEarth] "0x00189Cae228389b61f68B4e3520393941dAAD6e1".
Contract successfully verified

buyearth on  master [✘!+?] via 🅒 base took 10.0s 
➜ forge verify-contract \
  --rpc-url https://testnet-rpc.monad.xyz \
  --verifier sourcify \
  --verifier-url 'https://sourcify-api-monad.blockvision.org' \
  0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D \
  src/BuyEarth.sol:BuyEarth
Start verifying contract `0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D` deployed on monad-testnet
Attempting to verify on Sourcify. Pass the --etherscan-api-key <API_KEY> to verify on Etherscan, or use the --verifier flag to verify on another provider.

Submitting verification for [BuyEarth] "0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D".
Contract successfully verified

```

## 参考

- <https://testnet.monadexplorer.com/address/0x00189Cae228389b61f68B4e3520393941dAAD6e1>
- <https://testnet.monadexplorer.com/address/0x00189Cae228389b61f68B4e3520393941dAAD6e1?tab=Contract>
- <https://testnet.monadexplorer.com/verify-contract?address=0x00189Cae228389b61f68B4e3520393941dAAD6e1>
- <https://docs.monad.xyz/guides/verify-smart-contract/foundry>

- <https://testnet.monadexplorer.com/address/0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D>
- <https://testnet.monadexplorer.com/address/0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D?tab=Contract>
