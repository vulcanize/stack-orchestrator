#!/bin/bash
set -e

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./wrapper.sh -e <compiler-env>
Spin up Foundry with Geth and a database.

-h,         Display help

-e,         Should we compile on your "local" machine or in "docker" or on a "remote" server

EOF
exit 1
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

while getopts ":e:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            [ "$e" = "local" -o "$e" = "docker" -o "$e" = "remote" ] || showHelp
            ;;
        *)
            showHelp
            ;;
    esac
done
shift $((OPTIND-1))

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

start_path=$(pwd)

trap "cd ${start_path}" SIGINT SIGTERM

cd ../../../../
echo -e "${GREEN}Building geth!${NC}"
echo -e "${GREEN}e=${e}${NC}"

if [[ "$e" = "local" ]] ; then
    echo -e "${GREEN}Building geth locally!${NC}"
    echo -e "${RED}LOCAL BUILD MIGHT NOT WORK!!${NC}"
    make geth
    chmod +x build/bin/geth
    mv build/bin/geth related-repositories/foundry-test/projects/local-private-network/geth-linux-amd64
fi

if [[ "$e" = "docker" ]] ; then
    echo -e "${GREEN}Building geth using docker!${NC}"
    docker build -t vulcanize/go-ethereum -f Dockerfile .
    docker run --rm --entrypoint cat vulcanize/go-ethereum /usr/local/bin/geth > ./geth-linux-amd64
    chmod +x ./geth-linux-amd64
    mv ./geth-linux-amd64 related-repositories/foundry-test/projects/local-private-network/geth-linux-amd64
fi

if [[ "$e" == "remote" ]]; then
    echo -e "${GREEN}Building geth remotely on alabaster.lan.vdb.to${NC}"
    rm related-repositories/foundry-test/projects/local-private-network/geth-linux-amd64
    rsync -uavz ./ abdul@alabaster.lan.vdb.to:/home/abdul/go-ethereum-cerc
    ssh abdul@alabaster.lan.vdb.to "cd /home/abdul/go-ethereum-cerc/ ; make geth ; chmod +x build/bin/geth"
    scp abdul@alabaster.lan.vdb.to:/home/abdul/go-ethereum-cerc/build/bin/geth related-repositories/foundry-test/projects/local-private-network/geth-linux-amd64

fi

cd $start_path
echo -e "${GREEN}geth build complete!${NC}"
