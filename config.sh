#!/bin/bash
# This "script" is simply a configuration file that will be loaded by other files.
# It allows users to specify where related directories are instead of having to hardcode them.

vulcanize_ops=/Users/abdulrabbani/GitHub/cerc/ops
vulcanize_foundry_test=/Users/abdulrabbani/GitHub/cerc/foundry-test
vulcanize_ipld_eth_db=/Users/abdulrabbani/GitHub/cerc/ipld-eth-db
vulcanize_ipld_ethcl_indexer=/Users/abdulrabbani/GitHub/cerc/ipld-ethcl-indexer/
vulcanize_go_ethereum=/Users/abdulrabbani/GitHub/cerc/forks/go-ethereum-cerc/

extra_args="--metrics --metrics.expensive --metrics.addr 0.0.0.0 --metrics.port 6060"
eth_forward_eth_calls=false
eth_proxy_on_error=false
eth_http_path=""