# Foundry README

# Overview

This document will go through the steps needed to test using Foundry. Currently, we use Foundry in the following capacity.

1. Create a private network with our internal version of Geth.
2. Deploy a smart contract to the private network.
3. Test the smart contract on the private network.
4. Create a transaction on the private network.

# Steps

The steps to create a new project are as follows.

## 1. Creating New Project

1. `cd foundry/projects`.
2. Create a directory that captures your project: `mkdir local-private-network; cd local-private-network`.
3. Create a [new foundry project](https://onbjerg.github.io/foundry-book/forge/creating-a-new-project.html): `forge init stateful`.
4. Follow the foundry [documentation](https://onbjerg.github.io/foundry-book/forge/tests.html) for writing smart contract tests.

## 2. Deployments

You can choose to have custom deployments for your workflow. However, it is recommended to utilize Docker.

# Existing Projects

Below, you can find existing projects and their descriptions.

## `local-private-network`

The purpose of this project is as follows:

1. Compile the geth from the local source.
2. Build a docker container with `ipld-eth-db` and another container for the `local-private-network`.
3. Run the compiled version of geth.
4. Deploy a smart contract to the private blockchain.
5. Trigger a transaction on the newly deployed smart contract.

## Using This Project

If you want to test your local geth code, do the following:

1. cd `projects/local-private-network`.
2. `./wrapper.sh` - This script will do all the heavy lifting for you. Run the flag with -h to see all the options it provides.
3. Keep an eye out for the outputs from the docker container.
4. Enter the docker container and do as you please.

### Custom Docker Compose

You will also notice that there are multiple docker compose files.

1. `docker-compose.yml` - This pulls a published container.
2. `docker-compose-local-db.yml` - This will build the database image from the local repository, allowing you to test any changes.

```
docker-compose -f docker-compose-local-db.yml up --build --abort-on-container-exit
```

### Key Notes:

- The command to [deploy](https://onbjerg.github.io/foundry-book/forge/deploying.html) the smart contract is: `forge create --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url http://127.0.0.1:8545 --constructor-args 1 --password $(cat ${ETHDIR}/config/password) --legacy /root/stateful/src/Stateful.sol:Stateful`
- The command to create a [transaction](https://onbjerg.github.io/foundry-book/reference/cast.html) (which will create a new block) is: `cast send --keystore $(cat ~/transaction_info/CURRENT_ETH_KEYSTORE_FILE) --rpc-url http://127.0.0.1:8545 --password $(cat $(cat ~/transaction_info/ETHDIR)) --legacy $(cat ~/transaction_info/STATEFUL_TEST_DEPLOYED_ADDRESS) "inc()"`
- To manually send a transaction (which will trigger the mining of a new block), simply run the following script: `~/transaction_info/NEW_TRANSACTION`.
  - This script is only populated after the `start-private-network.sh` script has completed successfully.
- The `Dockerfile` compiles `cast` and `forge`.
- The `foundry/projects/local-private-network/deploy-local-network.sh` file does most heavy lifting. It spins up geth and triggers various events.
- The `foundry/projects/local-private-network/start-private-network.sh` file triggers `deploy-local-network.sh`. This file runs all the tests.
- The `geth` node will stay running even after the tests are terminated.
- If you are building the database locally and make change to the schema, you will have to remove the volume: `docker-compose down -v local-private-network_vdb_db_eth_server`.
- If you wish to use a local `genesis.json` file, do not add the `alloc` or `extra_data` block. The start up script will do it for you.
