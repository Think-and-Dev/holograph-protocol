# Holograph Bridge
The first draft of the Holograph Bridge smart contracts.
```
  ,,,,,,,,,,,
 [ HOLOGRAPH ]
  '''''''''''
  _____________________________________________________________
 |                                                             |
 |                            / ^ \                            |
 |                            ~~*~~            .               |
 |                         [ '<>:<>' ]         |=>             |
 |               __           _/"\_           _|               |
 |             .:[]:.          """          .:[]:.             |
 |           .'  []  '.        \_/        .'  []  '.           |
 |         .'|   []   |'.               .'|   []   |'.         |
 |       .'  |   []   |  '.           .'  |   []   |  '.       |
 |     .'|   |   []   |   |'.       .'|   |   []   |   |'.     |
 |   .'  |   |   []   |   |  '.   .'  |   |   []   |   |  '.   |
 |.:'|   |   |   []   |   |   |':'|   |   |   []   |   |   |':.|
 |___|___|___|___[]___|___|___|___|___|___|___[]___|___|___|___|
 |XxXxXxXxXxXxXxX[]XxXxXxXxXxXxXxXxXxXxXxXxXxX[]XxXxXxXxXxXxXxX|
 |^^^^^^^^^^^^^^^[]^^^^^^^^^^^^^^^^^^^^^^^^^^^[]^^^^^^^^^^^^^^^|
 |               []                           []               |
 |               []                           []               |
 |    ,          []     ,        ,'      *    []               |
 |~~~~~^~~~~~~~~/##\~~~^~~~~~~~~^^~~~~~~~~^~~/##\~~~~~~~^~~~~~~|
 |_____________________________________________________________|

             - one bridge, infinite possibilities -
```

If you're using a node version manager `nvm install` or make sure to use `v16.6.1`.

Install all the dev packages `npm install`.

Copy over shared env configs and mnemonic `cp sample.env .env && cp sample.mnemonic .mnemonic`.

Make missing data dir `mkdir data`, where all contract addresses are stored for reference and re-use.

In a separate terminal run ganache by `npm run-script ganache`, to run two separate instances of ganache, run `npm run-script ganache-x2`, to run the second instance only, `npm run-script ganache2`.

Build the latest version of the project with `npm run-script build-compile`.

End to end testing can be done with `sh _deploy.sh`.

The deployment script will accomplish the following: deploy the entire protocol on both chains, create the same collection on each chain, set `.env $NETWORK` chain as original chain, mint sample NFTs on origin chain, and on foreign chain, test basic info validation, and simple functionality like `transferFrom`.

Once the deployment has been done, multi-chain transfers can be tested with `sh _bridge.sh`. This script tests `bridgeOut` and `bridgeIn` requests between `NETWORK` and `NETWORK2`.
