#!/bin/bash
set -e

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./wrapper.sh -e <compiler-env>
Spin up Foundry with Geth and a database.

-h,         Display help

-e,         Should we compile on your "local" machine or in "docker" or on a "remote" server

-v,         Should we "remove" the volume when bringind the image down or "keep" it?

-u,         What username should we use for the remote build?

-p,          Path to config.sh file.

EOF
exit 1
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

u="abdul"
n="alabaster.lan.vdb.to"
p="../../config.sh"
while getopts ":e:u:n:p:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            [ "$e" = "local" -o "$e" = "docker" -o "$e" = "remote" ] || showHelp
            ;;
        u)
            u=${OPTARG}
            ;;
        n)
            n=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            [[ -f "$p" ]] || showHelp
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

echo -e "${GREEN}Building geth!${NC}"
echo -e "${GREEN}e=${e}${NC}"
echo -e "${GREEN}n=${n}${NC}"
echo -e "${GREEN}u=${u}${NC}"
echo -e "${GREEN}p=${p}${NC}"
echo -e "${GREEN}Start path: ${start_path} ${NC}"

source $p
echo -e "${GREEN}Build Path: ${vulcanize_go_ethereum}"
cd ${vulcanize_go_ethereum}

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
fi

cd $start_path
echo -e "${GREEN}geth build complete!${NC}"
