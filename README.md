# Mezzanote Sale[![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/threesigmaxyz/mezzanote-sale/actions
[gha-badge]: https://github.com/threesigmaxyz/mezzanote-sale/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

This repository contains the source code, test suit and deployment scripts for the Defimons starter monsters contract.

# Getting Started
## Requirements
In order to run the tests and deployment scripts you must install the following:

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - A distributed version control system
- [Foundry](https://book.getfoundry.sh/getting-started/installation) - A toolkit for Ethereum application development.

Additionaly, you should have [make](https://man7.org/linux/man-pages/man1/make.1.html) installed.

## Installation
```sh
git clone https://github.com/threesigmaxyz/mezzanote-sale
cd mezzanote-sale
make all
```

## Testing
To run all tests execute the following commad:
```
make test
```
Alternatively, you can run specific tests as detailed in this [guide](https://book.getfoundry.sh/forge/tests).

# Deployment

On deployment, make sure that the variables in the deployment script `DeploymentScript.s.sol` are set accordingly.

The deployment script performs the following actions:

- Deploys the `DefimonsStarterMonsters.sol` contract;
- Verifies the contracts source on [Etherscan](https://etherscan.io);

## Setup
Prior to deployment you must configure the following variables in the `.env` file:

- `PRIVATE_KEY`: The private key for the deployer wallet.

## Local Deployment
By default, Foundry ships with a local Ethereum node [Anvil](https://github.com/foundry-rs/foundry/tree/master/anvil) (akin to Ganache and Hardhat Network). This allows us to quickly deploy to our local network for testing.

To start a local blockchain, with a determined private key, run:
```
make anvil
```

Afterwards, you can deploy to it via:
```
make deploy-anvil
```

## Remote Deployment
In order to deploy contracts to a remote chain you must configure the corresponding RPC endpoint as an environment variable. Additionaly, to verify the contracts another variable must be set with a block explorer API key. The following table details which variables to configure depending on the target network:

| Network ID | RPC Variable | API Variable |
| --- | --- | --- |
| arbitrum | `RPC_URL_ARBITRUM` | `ARBISCAN_KEY` |
| avalanche | `RPC_URL_AVALANCHE` | `SNOWTRACE_KEY` |
| goerli | `RPC_URL_GOERLI` | `ETHERSCAN_KEY` |
| mainnet | `RPC_URL_MAINNET` | `ETHERSCAN_KEY` |
| optimism | `RPC_URL_OPTIMISM` | `OPTIMISM_ETHERSCAN_KEY` |
| polygon | `RPC_URL_POLYGON` | `POLYGONSCAN_KEY` |

Note that a fresh `ETHERSCAN_KEY` can take a few minutes to activate, you can query any [endpoint](https://api-goerli.etherscan.io/api?module=block&action=getblockreward&blockno=2165403&apikey=ETHERSCAN_API_KEY) to check its status.
Additionaly, if you need testnet ETH for the deployment you can request it from the following [faucet](https://faucet.paradigm.xyz/).

To execute the deployment run:
```
make deploy-network network=<TARGET_NETWORK>
```

Where `TARGET_NETWORK` should be replaced with the corresponding network ID. For a mainnet deployment run:

```
make deploy-network network=mainnet
```

Forge is going to run our script and broadcast the transactions for us. This can take a little while, since Forge will also wait for the transaction receipts.

# About Us
[Three Sigma](https://threesigma.xyz/) is a venture builder firm focused on blockchain engineering, research, and investment. Our mission is to advance the adoption of blockchain technology and contribute towards the healthy development of the Web3 space.

If you are interested in joining our team, please contact us [here](mailto:info@threesigma.xyz).

---

<p align="center">
  <img src="https://threesigma.xyz/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fthree-sigma-labs-research-capital-white.0f8e8f50.png&w=2048&q=75" width="75%" />
</p>