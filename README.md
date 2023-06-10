# DEPRECATION NOTICE
This repo has been superseded by https://github.com/cerc-io/stack-orchestrator

# Contents
- [Overview](#overview)
- [Building The Stack](#building-the-stack)
  - [Quick Start](#quick-start)
  - [Components](#components)
    - [Local Versus Latest](#local-versus-latest)
    - [`config.sh`](#-configsh-)
    - [`helper-scripts/wrapper.sh`](#-helper-scripts-wrappersh-)
    - [Utilizing Multiple `docker-compose-*` Files Together](#utilizing-multiple--docker-compose----files-together)
  - [Utilizing CI/CD](#utilizing-ci-cd)
    - [Case Study: `ipld-eth-beacon-indexer`.](#case-study---ipld-eth-beacon-indexer-)
- [Additional Notes](#additional-notes)
  - [Geth Specific](#geth-specific)
  - [Monitoring Specific](#monitoring-specific)
- [Known Issues](#known-issues)
  - [SELinux Issues With Filepath](#selinux-issues-with-filepath)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

# Overview

This repository serves many functions, but the primary function is to test various applications within the stack. [Foundry](https://book.getfoundry.sh/) is utilized primarily for testing `geth` within a test net.

The current applications that we can build using `stack-orchestrator` are:

- `lighthouse`.
- `vulcanize/go-ethereum`.
- `ipld-eth-db`.
- `prometheus`.
- `grafana`.
- `ipld-eth-beacon-indexer`.
- `ipld-eth-server`.

# Building The Stack

This section will highlight how users can build the stack.

## Quick Start

If you want to quickly get all the applications mentioned above cloned and running. Use the following guide.

1.  Clone the stack-orchestrator repository.

    ```bash
    # It is recommended that you utilize the directory below.
    mkdir -p ~/vulcanize
    cd ~/vulcanize
    git clone git@github.com:vulcanize/stack-orchestrator.git

    ```

2.  Create a `config.sh` file.

    ```bash
    cd stack-orchestrator/helper-scripts
    ./create-config.sh
    ## Optional flags
    # ./create-config.sh -b ~/GitHub/cerc -p ../local-config.sh

    ```

3.  Run the setup script.

    ```bash
    ./setup-repositories.sh
    ## Optional Flags
    # ./setup-repositories.sh -c ../config.sh -p ssh
    # ./setup-repositories.sh -c ../local-config.sh -p ssh
    # ./setup-repositories.sh -c ../config.sh -p https

    ```

4.  Optional - If you did not initially use `~/vulcanize`, move the `stack-orchestrator` directory to `~/vulcanize`.

5.  Optional - If you already have the repositories that the `setup-repositories.sh` script clones for you, you can create a `local-config.sh` file.

    ```bash
    # Example command
    ./create-config.sh -b ~/GitHub/cerc -p ../local-config.sh

    # Update all the file as you wish you reflect the location of each repository.
    vim local-config.sh


    ```

6.  Checkout certain repositories to their desired branches:
    At a minimum perform the following (the branches below might be outdated, if you suspect they are, reach out to a core developer).

```bash
source config.sh
cd $vulcanize_test_contract ; git checkout sharding ; cd -
cd $vulcanize_eth_statediff_fill_service ; git checkout sharding; cd -
cd $vulcanize_go_ethereum ; git checkout v1.10.19-statediff-v4 ; cd -
```

If you plan on doing local development, figure out a combination that works for you!

7.  Build the entire stack. The `wrapper.sh` script does all the heavy lifting. You can specify various flags and configurations to it (its helpful to run the script with the `-h` flag to see your options). Ultimately, you can string together various docker-compose files and spin up all the applications at once, or you can use certain shortcuts to build the entire stack.

    - For building part of the stack.

      ```bash
      ./wrapper.sh -e docker \
        -d ../docker/latest/docker-compose-db-sharding.yml \
        -d ../docker/local/docker-compose-ipld-eth-server.yml \
        -d ../docker/latest/docker-compose-lighthouse.yml \
        -d ../docker/local/docker-compose-ipld-eth-beacon-indexer.yml \
        -d ../docker/local/docker-compose-go-ethereum.yml \
        -v remove \
        -p ../config.sh

      ```

      Remove lines for the parts of the stack you don’t want to build.

    - For building full stack with specified DB version (v3 or v4)

      ```bash
      ./wrapper.sh -f true \
        -s v4 \
        -l latest \
        -p ../config.sh
      ```

    - For building stack with auto mining of blocks
      ```bash
      ./wrapper.sh -f true \
        -m true \
        -s v4 \
        -l latest \
        -p ../config.sh
      ```

8.  When you want to clean up your local environment, hit `ctrl + c`. The bash script will remove all containers and any volumes created (if you specify `v remove`).

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

The docker-compose files found in `docker/local` and `docker/latest` are meant to be stand-alone files. You can pass in as many files as you want to the `wrapper.sh` script. A few notes on this:

- This lets you build as many services as you want and mix and match `local` and `latest` services.
- Be careful that you don’t spin up the `local` and `latest` service at the same time.
  - For example, if you attempt to build pass `docker/local/docker-compose-db.yml` and `docker/latest/docker-compose-db.yml` at the same time you will run into an error. They both try to expose the same ports and share the same service name.

## Utilizing CI/CD

If you want to utilize `stack-orchestrator` within your CI/CD, you will do it as follows:

1.  Create a `Dockerfile` within your repository. This Dockerfile should start you application.
2.  Create a `docker-compose` file for `local` and `latest` within the `docker/` directory in `stack-orchestrator`.
3.  Create a Github Action that is triggered by `pull_request` and `workflow_dispatch`.
    1.  You must merge this file into `master/main` before being able to use it. `workflow_dispatch` will not work unless it is in `master/main` first. This is a design fault.
4.  When referencing the stack-orchestrator repository, use a commit hash instead of using a branch name.

### Case Study: `ipld-eth-beacon-indexer`.

I followed this process for `ipld-eth-beacon-indexer`. Here are a few key files.

1.  [`vulcanize/ipld-eth-beacon-indexer:Dockerfile`](https://github.com/vulcanize/ipld-eth-beacon-indexer/blob/main/Dockerfile) - Compiles and starts the application
2.  [`vulcanize/stack-orchestrator:docker/local/docker-compose-ipld-eth-beacon-indexer.yml`](https://github.com/vulcanize/stack-orchestrator/blob/main/docker/local/docker-compose-ipld-eth-beacon-indexer.yml) - A `docker-compose` file to start the container.
3.  [`vulcanize/ipld-eth-beacon-indexer:.github/workflows/on-pr.yml`](https://github.com/vulcanize/ipld-eth-beacon-indexer/blob/main/.github/workflows/on-pr.yml) - Automatically triggered on `pull_request`. If users ever need to reference a specific branch for `ipld-eth-db` or `stack-orchestrator`, they can easily do so in the `env` variable.
    1.  You can also easily run this GHA manually and provide input parameters.

# Additional Notes

Here are a few notes to keep in mind. I **highly recommend** reading every bullet for all first-time users.

## Geth Specific

- If you want to build `geth` remotely, talk to Shane to create a user on `alabaster` (or any other server you want).
  - I prefer to build remotely because the builds are performed on a Linux machine. When I try to build locally, I get portability issues.
- The command to [deploy](https://onbjerg.github.io/foundry-book/forge/deploying.html) the smart contract is: `forge create --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url http://127.0.0.1:8545 --constructor-args 1 --password $(cat ${ETHDIR}/config/password) --legacy /root/stateful/src/Stateful.sol:Stateful`
- The command to create a [transaction](https://onbjerg.github.io/foundry-book/reference/cast.html) (which will create a new block) is: `cast send --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url http://127.0.0.1:8545 --password $(cat $(cat ~/transaction_info/ETHDIR)) --legacy $(cat ~/transaction_info/STATEFUL_TEST_DEPLOYED_ADDRESS) "inc()"`
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

# Known Issues

## SELinux Issues With Filepath

Users might notice issues when attempting to build `ipld-eth-server`. If you are unable to build the application due to file permissions, it can be related to absolute path v relative path. Users might need to update local configurations, or update SELinux with the following command:

```
sudo su -c "setenforce 0"
```

## GETH Issues With M1 Macs

Users might notice issues when attempting to build `go-ethereum` on M1 Macs. If this happens, you will either need to manually install `geth` in your `helper-scripts` directory OR run `./wrapper.sh` using the `-e remote` flag to build the stack on a remote server:

### Manually Installing GETH

```
cd helper-scripts
wget https://github.com/vulcanize/go-ethereum/releases/download/v1.10.19-statediff-4.0.3-alpha/geth-linux-amd64
```

Then rename it using:

```
mv geth-linux-amd64.1 geth-linux-amd64
```

### Building the Stack on a Remote Server

```
./wrapper.sh \
  -e remote \
  -u <USERNAME> \
  -n <HOSTNAME> \
  -d "../docker/latest/docker-compose-db-sharding.yml" \
  -d "../docker/local/docker-compose-go-ethereum.yml" \
  -d "../docker/local/docker-compose-contract.yml" \
  -v remove \
  -p ../config.sh
```
