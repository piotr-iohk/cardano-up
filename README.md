# Cardano Up!

[![Tests](https://github.com/piotr-iohk/cardano-up/actions/workflows/tests.yml/badge.svg)](https://github.com/piotr-iohk/cardano-up/actions/workflows/tests.yml)

## Overview

This Ruby gem provides easy way for:
 - getting `cardano-node`, `cardano-cli`, `cardano-wallet`, `cardano-addresses` and `bech32` tools onto your system (Linux, MacOS or Windows).
 - getting configuration for any Cardano public environment.
 - starting, managing and monitoring cardano-node and cardano-wallet services.

<img src="cardano-up.gif" />

## Installation

    $ gem install cardano-up

## Usage

It only takes single command to start node and wallet on your system. Fancy `mainnet`?

    $ cardano-up mainnet node-wallet up

    Configs: installing configs for mainnet... Ok.
    Binaries: installing latest release binaries... Ok.

    Starting...

    {
      "node": {
        "service": "NODE_mainnet",
        "version": "cardano-node 1.35.3 - linux-x86_64 - ghc-8.10git rev 950c4e222086fed5ca53564e642434ce9307b0b9",
        "log": "/home/piotr/.cardano-up/logs/mainnet/node.log",
        "db_dir": "/home/piotr/.cardano-up/state/mainnet/node-db",
        "socket_path": "/home/piotr/.cardano-up/state/mainnet/node.socket",
        "protocol_magic": 764824073,
        "network": "mainnet",
        "bin": "/home/piotr/.cardano-up/bins/cardano-node",
        "cmd": "/home/piotr/.cardano-up/bins/cardano-node run --config /home/piotr/.cardano-up/configs/mainnet/config.json --topology /home/piotr/.cardano-up/configs/mainnet/topology.json --database-path /home/piotr/.cardano-up/state/mainnet/node-db --socket-path /home/piotr/.cardano-up/state/mainnet/node.socket"
      },
      "wallet": {
        "service": "WALLET_mainnet",
        "version": "v2022-10-06 (git revision: 2130fe0acf19fa218cef8de4ef325ae9078e356e)",
        "log": "/home/piotr/.cardano-up/logs/mainnet/wallet.log",
        "db_dir": "/home/piotr/.cardano-up/state/mainnet/wallet-db",
        "port": 8090,
        "host": "http://localhost:8090/v2",
        "bin": "/home/piotr/.cardano-up/bins/cardano-wallet",
        "cmd": "/home/piotr/.cardano-up/bins/cardano-wallet serve --port 8090 --node-socket /home/piotr/.cardano-up/state/mainnet/node.socket --mainnet --database /home/piotr/.cardano-up/state/mainnet/wallet-db --token-metadata-server https://tokens.cardano.org"
      }
    }

    Congratulations! You've just started cardano-node and cardano-wallet!

That's it! 🎉

Call `$ cardano-up --help` to explore more options.

## Documentation
TODO

## How it works

**Configurations** are downloaded from [Cardano Book](https://book.world.dev.cardano.org/environments.html).

**Binaries** come from [cardano-wallet](https://github.com/input-output-hk/cardano-wallet) which actually provides `cardano-node`, `cardano-cli`, `cardano-wallet`, `cardano-addresses` and `bech32` tools in each of its release bundles. This ensures that all components are compatible and work smoothly together. You can get any public release of the cardano-wallet bundle as well as `master` version and even any of the PRs that are currently being worked on.

**Starting** `cardano-node` and `cardano-wallet`,  cardano-up attempts to launch separate [`screen`](https://www.gnu.org/software/screen/) sessions for wallet and node respectively. If screen is not present on your system you can install it using package manager, e.g.:

MacOS:

    $ brew install screen

Linux:

    $ sudo apt-get install screen

In case of Windows it will attempt to install cardano-node and cardano-wallet as Windows services using [`nssm`](https://nssm.cc/) tool. Nssm can be installed via choco package manager:

    $ choco install nssm

> :warning: nssm requires administrator permissions to register Windows services, therefore you need to start your cmd as an administrator.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
