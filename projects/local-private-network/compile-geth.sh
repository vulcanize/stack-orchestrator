#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

start_path=$(pwd)
cd ../../../../
echo -e "${GREEN}Building geth!${NC}"
echo -e "${GREEN}e=${e}${NC}"
echo -e "${GREEN}n=${n}${NC}"
echo -e "${GREEN}u=${u}${NC}"
echo -e "${GREEN}Start path: ${start_path} ${NC}"

if [[ "$e" = "local" ]] ; then
    echo -e "${GREEN}Building geth locally!${NC}"
    echo -e "${RED}LOCAL BUILD MIGHT NOT WORK!!${NC}"
    make geth
    chmod +x build/bin/geth
    mv build/bin/geth ${start_path}/geth-linux-amd64
fi

if [[ "$e" = "docker" ]] ; then
    echo -e "${GREEN}Building geth using docker!${NC}"
    docker build -t vulcanize/go-ethereum -f Dockerfile .
    docker run --rm --entrypoint cat vulcanize/go-ethereum /usr/local/bin/geth > ./geth-linux-amd64
    chmod +x ./geth-linux-amd64
    mv ./geth-linux-amd64 ${start_path}/geth-linux-amd64
fi

if [[ "$e" == "remote" ]]; then
    echo -e "${GREEN}Building geth remotely on $n ${NC}"
    [ -e ${start_path}/geth-linux-amd64 ] && \
        rm ${start_path}/geth-linux-amd64
    rsync -uavz ./ ${u}@${n}:/home/${u}/go-ethereum-cerc
    ssh ${u}@${n} "cd /home/${u}/go-ethereum-cerc/ ; make geth ; chmod +x build/bin/geth"
    scp ${u}@${n}:/home/${u}/go-ethereum-cerc/build/bin/geth ${start_path}/geth-linux-amd64

echo -e "${GREEN}geth build complete!${NC}"
cd $start_path
mv ../../../../geth-linux-amd64 .
