#!/bin/bash

# This script will help new developers clone all the repositories locally.
# Make sure the config.sh file is up to date and accurate.
# This is needed because docker-compose cannot handle chained variables: ${A}/something-else
# Instead it needs to be this/something-else

usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./setup-repository -c <path-to-config> -p <network-protocol>
Setup repositories that can be built using the stack-orchestrator repository.

-h, -help,          Display help

-c,                 Path to the configuration file that specifies to location of the output directories. It is recommended to use ../config.sh

-p,                 The network protocol to use, https or ssh.

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

c=../config.sh
p=https
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
while getopts ":c:b:p:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
            [[ -f "$c" ]] || usage
            ;;
        p)
            p=${OPTARG}
            [ "$p" = "ssh" -o "$p" = "https" ] || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

echo -e "${GREEN} Config file being used = ${c}${NC}"
echo -e "${GREEN} Network protocol being used = ${p}${NC}"

source ${c}

mkdir -p $vulcanize_repo_base_dir

if [[ "$p" == "https" ]] ; then
    prefix="https://github.com/"
elif [[ "$p" == "ssh" ]] ; then
    prefix="git@github.com:"
fi

git clone ${prefix}vulcanize/ops.git $vulcanize_ops
git clone ${prefix}vulcanize/ipld-eth-db.git $vulcanize_ipld_eth_db
git clone ${prefix}vulcanize/go-ethereum.git $vulcanize_go_ethereum
git clone ${prefix}vulcanize/ipld-eth-server.git $vulcanize_ipld_eth_server
git clone ${prefix}vulcanize/eth-statediff-fill-service.git $vulcanize_eth_statediff_fill_service
git clone ${prefix}vulcanize/ipld-eth-db-validator.git ${vulcanize_repo_base_dir}/ipld-eth-db-validator

# Statediff fill
# Validator


# Might fail if you don't have access to the repository.
git clone ${prefix}vulcanize/ipld-eth-beacon-indexer.git $vulcanize_ipld_eth_beacon_indexer
if [ $? -ne 0 ]; then
    echo -e "${RED} You don't have access to vulcanize/ipld-eth-beacon-indexer.git${NC}"
fi

# Might fail if you don't have access to the repository.
git clone ${prefix}vulcanize/ipld-eth-beacon-db.git $vulcanize_ipld_eth_beacon_db
if [ $? -ne 0 ]; then
    echo -e "${RED} You don't have access to vulcanize/ipld-eth-beacon-db.git${NC}"
fi

if [[ ! -d $vulcanize_stack_orchestrator ]] ; then
    echo -e "${RED} We highly recommend moving this repository to: $vulcanize_stack_orchestrator${NC}"
fi
