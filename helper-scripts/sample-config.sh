#!/bin/bash
# This "script" is simply a configuration file that will be loaded by other files.
# It allows users to specify where related directories are instead of having to hardcode them.

vulcanize_ops=${vulcanize_repo_base_dir}/ops
vulcanize_stack_orchestrator=${vulcanize_repo_base_dir}/stack-orchestrator
vulcanize_ipld_eth_db=${vulcanize_repo_base_dir}/ipld-eth-db
vulcanize_ipld_ethcl_indexer=${vulcanize_repo_base_dir}/ipld-ethcl-indexer
vulcanize_go_ethereum=${vulcanize_repo_base_dir}/go-ethereum
vulcanize_ipld_eth_server=${vulcanize_repo_base_dir}/ipld-eth-server

# USE SINGLE QUOTES ONLY!!!!!!
extra_args='--metrics --metrics.expensive --metrics.addr 0.0.0.0 --metrics.port 6060'
db_write=true
eth_forward_eth_calls=false
eth_proxy_on_error=false
eth_http_path=''
watched_addres_gap_filler_enabled=false
watched_addres_gap_filler_interval=5