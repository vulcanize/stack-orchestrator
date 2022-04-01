#!/bin/bash
# This script will run everthing for you. Sit back and enjoy they show.

set -e
showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./wrapper.sh -e <compiler-env> -d <database-image-source> -v <keep-or-remove-volume> -u <remote-username> -n <remote-host> -p <path-to-related-repositories-map>
Spin up Foundry with Geth and a database.

-h,         Display help

-e,         Should we compile geth on your "local" machine or in "docker" or on a "remote" machine or "skip" compiling. Recommended to use "docker" for releases

-d,         Should we build a "local" ipdl-eth-db image or use the "remote" one. Use "local" if you have made change to the DB.

-v,         Should we "remove" the volume when bringind the image down or "keep" it?

-u,         What username should we use for the remote build?

-n,         What is the hostname for the remote build?

-p,          Path to related-directory-mapping.sh file.

EOF
exit 1
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

e="local"
d="docker"
v="keep"
u="abdul"
n="alabaster.lan.vdb.to"
p="../../../related-directory-mapping.sh"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
while getopts ":e:d:v:u:n:p:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            [ "$e" = "local" -o "$e" = "docker" -o "$e" = "skip" -o "$e" = "remote" ] ||showHelp
            ;;
        d)
            d=${OPTARG}
            [ "$d" = "local-db" -o "$d" = "remote" -o "$d" = "local-db-prom" -o "$d" = "lighthouse" ] || showHelp
            ;;
        v)
            v=${OPTARG}
            [ "$v" = "keep" -o "$v" = "remove" ] || showHelp
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

# Local Build or Docker Build

echo -e "${GREEN} STARTING PARAMS${NC}"
echo -e "${GREEN} e=${e} ${NC}"
echo -e "${GREEN} d=${d} ${NC}"
echo -e "${GREEN} v=${v} ${NC}"
echo -e "${GREEN} u=${u} ${NC}"
echo -e "${GREEN} n=${n} ${NC}"
echo -e "${GREEN} p=${p} ${NC}"

if [ "$e" != "skip" ]; then
    ./compile-geth.sh -e $e -n $n -u $u -p $p
fi

echo -e "${GREEN} Sourcing: $p ${nc}"
source $p

if [[ "$v" = "keep" ]] ; then
    trap "cd ../docker/; docker-compose down --remove-orphans; cd ../" SIGINT SIGTERM
fi

if [[ "$v" = "remove" ]] ; then
    trap "cd ../docker/; docker-compose down -v --remove-orphans; cd ../" SIGINT SIGTERM
fi

# Consider just having one docker compose command and having users specify the dockerfile they want to use.
if [[ "$d" = "local-db" ]] ; then
    echo -e "${GREEN}Building DB image using Local ipld-eth-db repository!${NC}"
    docker-compose --env-file "$p" -f ../docker/docker-compose-local-db.yml up --build
fi

if [[ "$d" = "local-db-prom" ]] ; then
    echo -e "${GREEN}Building DB image using Local ipld-eth-db repository and prometheus!${NC}"
    docker-compose --env-file "$p" -f ../docker/docker-compose-local-db-prometheus.yml up --build
fi

if [[ "$d" = "remote" ]] ; then
    echo -e "${GREEN}Using a remote image for the DB!${NC}"
    docker-compose -f ../docker/docker-compose.yml up --build
fi

if [[ "$d" = "lighthouse" ]] ; then
    echo -e "${GREEN}Using a remote image for the DB and building Lighthouse!${NC}"
    docker-compose -f ../docker/docker-compose-lighthouse.yml up --build
fi