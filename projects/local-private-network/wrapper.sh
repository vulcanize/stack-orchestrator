#!/bin/bash
# This script will run everthing for you. Sit back and enjoy they show.

set -e
showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./wrapper.sh -e <compiler-env> -d <database-image-source>
Spin up Foundry with Geth and a database.

-h,         Display help

-e,         Should we compile geth on your "local" machine or in "docker" or on a "remote" machine or "skip" compiling. Recommended to use "docker" for releases

-d,         Should we build a "local" ipdl-eth-db image or use the "remote" one. Use "local" if you have made change to the DB.

-v,         Should we "remove" the volume when bringind the image down or "keep" it?

EOF
exit 1
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

e="local"
d="docker"
v="keep"
while getopts ":e:d:v:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            [ "$e" = "local" -o "$e" = "docker" -o "$e" = "skip" -o "$e" = "remote" ] || showHelp
            ;;
        d)
            d=${OPTARG}
            [ "$d" = "local" -o "$d" = "remote" ] || showHelp
            ;;
        v)
            v=${OPTARG}
            [ "$v" = "keep" -o "$v" = "remove" ] || showHelp
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
# Local Build or Docker Build

echo -e "${GREEN} STARTING PARAMS${NC}"
echo -e "${GREEN} e=${e} ${NC}"
echo -e "${GREEN} d=${d} ${NC}"
echo -e "${GREEN} v=${v} ${NC}"

if [ "$e" != "skip" ]; then
    ./compile-geth.sh -e $e
fi

if [[ "$v" = "keep" ]] ; then
    trap "docker-compose down" SIGINT SIGTERM
fi

if [[ "$v" = "remove" ]] ; then
    trap "docker-compose down -v" SIGINT SIGTERM
fi

if [[ "$d" = "local" ]] ; then
    echo -e "${GREEN}Building DB image using Local ipld-eth-db repository!${NC}"
    docker-compose -f docker-compose-local-db.yml up --build
fi

if [[ "$d" = "remote" ]] ; then
    echo -e "${GREEN}Using a remote image for the DB!${NC}"
    docker-compose up --build --abort-on-container-exit
fi
