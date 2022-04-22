- [Overview](#overview)
- [Building The Stack](#building-the-stack)
  - [Components](#components)
    - [Local Versus Latest](#local-versus-latest)
    - [`config.sh`](#-configsh-)
    - [`helper-scripts/wrapper.sh`](#-helper-scripts-wrappersh-)
    - [Utilizing Multiple `docker-compose-*` Files Together](#utilizing-multiple--docker-compose----files-together)
  - [Building Locally](#building-locally)
  - [Utilizing CI/CD](#utilizing-ci-cd)
    - [Case Study: `ipld-ethcl-indexer`.](#case-study---ipld-ethcl-indexer-)
- [Additional Notes](#additional-notes)
  - [Geth Specific](#geth-specific)
  - [Monitoring Specific](#monitoring-specific)
  - [`ipld-eth-server` Specific](#-ipld-eth-server--specific)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# Foundry README

# Overview

This repository serves many functions, but the primary function is to test various applications within the stack. [Foundry](https://book.getfoundry.sh/) is utilized primarily for testing `geth` within a test net.

The current applications that we can build using `foundry-test` are:

- `lighthouse`.
- `vulcanize/go-ethereum`.
- `ipld-eth-db`.
- `prometheus`.
- `grafana`.
- `ipld-ethcl-indexer`.
- `ipld-eth-server` - Needs Debugging.

# Building The Stack

This section will highlight how users can build the stack.

## Components

A few important components for building the stack.

### Local Versus Latest

When building various parts of the stack, two main concepts are `local` and `latest` builds.

1.  `local` - This option will build the specified component from a local repository.
2.  `latest` - This option will utilize the latest remote docker image.

We can only build several applications locally.

### `config.sh`

There is a local configuration file `config.sh`. When the applications are built locally, they find the path to the repository using this file. When working with the application locally, it is recommended to update the values in this file with your local paths.

### `helper-scripts/wrapper.sh`

This script does all the heavy lifting. It will do the following for you:

1.  (Optional) - Build `geth` for you. Either locally, on a remote server, or in a docker container.
2.  Utilize `docker-compose` to start the necessary services.
3.  Stop and remove all containers when you do `ctrl + c`.
    1.  (Optional) - Remove all volumes.

### Utilizing Multiple `docker-compose-*` Files Together

The docker-compose files found in `docker/local` and `docker/latest` are meant to be stand-alone files. You can pass in as many files as you want to the [`wrapper.sh`](http://wrapper.sh) script. A few notes on this:

- This lets you build as many services as you want and mix and match `local` and `latest` services.
- Be careful that you don’t spin up the `local` and `latest` service at the same time.
  - For example, if you attempt to build pass `docker/local/docker-compose-db.yml` and `docker/latest/docker-compose-db.yml` at the same time you will run into an error. They both try to expose the same ports and share the same service name.

## Building Locally

To build the application locally, do the following:

1.  Update the `[config.sh](<http://config.sh>)` file with the correct local paths to the specified repositories.

2.  `cd helper-scripts/`.

3.  Utilize the `./wrapper.sh` to start the application. An example start-up command might look like the following:

    ```bash
    ./wrapper.sh \\
      -e remote \\
      -d ../docker/local/docker-compose-db.yml \\
      -d ../docker/local/docker-compose-go-ethereum.yml \\
      -d ../docker/local/docker-compose-prometheus-grafana.yml \\
      -d ../docker/latest/docker-compose-lighthouse.yml \\
      -u abdul \\
      -n alabaster.vdb.to \\
      -v remove \\
      -p ../config.sh

    ```

4.  When you want to clean up your local environment, hit `ctrl + c`. The bash script will remove all containers and any volumes created (if you specify `-v remove`).

## Utilizing CI/CD

If you want to utilize `foundry-test` within your CI/CD, you will do it as follows:

1.  Create a `Dockerfile` within your repository. This Dockerfile should start you application.
2.  Create a `docker-compose` file for `local` and `latest` within the `docker/` directory in `foundry-test`.
3.  Create a manual Github Action that is triggered by `pull_request` and `workflow_dispatch`.
    1.  You must merge this file into `master/main` before being able to use it. `workflow_dispatch` will not work unless it is in `master/main` first. This is a design fault.

### Case Study: `ipld-ethcl-indexer`.

I followed this process for `ipld-ethcl-indexer`. Here are a few key files.

1.  [`vulcanize/ipld-ethcl-indexer:Dockerfile`](https://github.com/vulcanize/ipld-ethcl-indexer/blob/main/Dockerfile) - Compiles and starts the application
2.  [`vulcanize/foundry-test:docker/local/docker-compose-ipld-ethcl-indexer.yml`](https://github.com/vulcanize/foundry-test/blob/feature/build-stack/docker/local/docker-compose-ipld-ethcl-indexer.yml) - A `docker-compose` file to start the container.
3.  [`vulcanize/ipld-ethcl-indexer:.github/workflows/on-pr-automated.yaml`](https://github.com/vulcanize/ipld-ethcl-indexer/blob/main/.github/workflows/on-pr.yml) - Automatically triggered on `pull_request`. If users ever need to reference a specific branch for `ipld-eth-db` or `foundry-test`, they can easily do so in the `env` variable.
    1.  You can also easily run this GHA manually and provide input parameters.

# Additional Notes

Here are a few notes to keep in mind. I **highly recommend** reading every bullet for all first-time users.

## Geth Specific

- If you want to build `geth` remotely, talk to Shane to create a user on `alabaster` (or any other server you want).
  - I prefer to build remotely because the builds are performed on a Linux machine. When I try to build locally, I get portability issues.
- The command to [deploy](https://onbjerg.github.io/foundry-book/forge/deploying.html) the smart contract is: `forge create --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url <http://127.0.0.1:8545> --constructor-args 1 --password $(cat ${ETHDIR}/config/password) --legacy /root/stateful/src/Stateful.sol:Stateful`
- The command to create a [transaction](https://onbjerg.github.io/foundry-book/reference/cast.html) (which will create a new block) is: `cast send --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url <http://127.0.0.1:8545> --password $(cat $(cat ~/transaction_info/ETHDIR)) --legacy $(cat ~/transaction_info/STATEFUL_TEST_DEPLOYED_ADDRESS) "inc()"`
- To manually send a transaction (which will trigger the mining of a new block), simply run the following script: `~/transaction_info/NEW_TRANSACTION`.
  - This script is only populated after the `start-private-network.sh` script has been completed successfully.
- The `Dockerfile` compiles `cast` and `forge`.
- The `start-up-files/deploy-local-network.sh` file does most heavy lifting for building a private network. It spins up geth and triggers various events.
- The `start-up-files/start-private-network.sh` file triggers `deploy-local-network.sh`. This file runs all the tests.
- The `geth` node will stay running even after the tests are terminated.
- If you wish to use a local `genesis.json` file, do not add the `alloc` or `extra_data` block. The start-up script will do it for you.

## Monitoring Specific

- If you want to utilize Prometheus and Grafana. Do the following:
  - Within your local `vulcanize/ops` repo, update the following file `metrics/etc/prometheus.yml`. Update `[localhost:6060]` —> `go-ethereum:6060`.

## `ipld-eth-server` Specific

- Currently, neither the `local` nor the `latest` docker-compose file is working.
- I am utilizing the following `start-up-files/ipld-eth-server/chain.json`, not the one specified in the `ipld-eth-server` repository. The reason is that the `start-up-files/ipld-eth-server/chain.json` file matches the `start-up-files/go-ethereum/genesis.json`.
