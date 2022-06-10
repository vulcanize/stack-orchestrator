#!/bin/bash
# This "script" is simply a configuration file that will be loaded by other files.
# It allows users to specify where related directories are instead of having to hardcode them.

vulcanize_ops=${vulcanize_repo_base_dir}/ops
vulcanize_stack_orchestrator=${vulcanize_repo_base_dir}/stack-orchestrator
vulcanize_ipld_eth_db=${vulcanize_repo_base_dir}/ipld-eth-db
vulcanize_ipld_eth_beacon_indexer=${vulcanize_repo_base_dir}/ipld-eth-beacon-indexer
vulcanize_go_ethereum=${vulcanize_repo_base_dir}/go-ethereum
vulcanize_ipld_eth_server=${vulcanize_repo_base_dir}/ipld-eth-server
vulcanize_ipld_eth_beacon_db=${vulcanize_repo_base_dir}/ipld-eth-beacon-db
vulcanize_eth_statediff_fill_service=${vulcanize_repo_base_dir}/eth-statediff-fill-service
vulcanize_test_contract=${vulcanize_repo_base_dir}/ipld-eth-db-validator/test/contract

# USE SINGLE QUOTES ONLY!!!!!!
extra_args='--metrics --metrics.expensive --metrics.addr 0.0.0.0 --metrics.port 6060'
db_write=true
eth_forward_eth_calls=false
eth_proxy_on_error=false
eth_http_path=''

watched_address_gap_filler_enabled=false
watched_address_gap_filler_interval=5

eth_beacon_capture_mode=boot
# provide only the file name under the ipld-eth-beacon-indexer/ repo.
eth_beacon_config_file=${vulcanize_repo_base_dir}/ipld-eth-beacon-indexer/config/cicd/boot.ipld-eth-beacon-config.json

