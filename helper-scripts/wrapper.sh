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

-d,         Should be the path(s) to the docker compose file you want to use. You can string together multiple docker
            compose files. Just make sure the services do not have conflicts!

-v,         Should we "remove" the volume when bringing the image down or "keep" it?

-u,         What username should we use for the remote build?

-n,         What is the hostname for the remote build?

-f          Should we build the full stack? "true" or "false"

-l          If we are building the full stack, should we build using local repositories, or use latest images wherever possible? "local" or "latest".

-s          If we are building the full stack, specify the DB version youd like: "v3" or "v4".

-m          Should mining of blocks be done in intervals? "true" or "false"

-p,         Path to config.sh file.

EOF
exit 1
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

e="docker"
v="keep"
u="abdul"
n="alabaster.vdb.to"
p="../config.sh"
f="false"
l="remote"
s="v3"
m="false"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
while getopts ":e:d:v:u:n:p:f:l:s:m:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
            [ "$e" = "local" -o "$e" = "docker" -o "$e" = "skip" -o "$e" = "remote" ] ||showHelp
            ;;
        d)  composeFiles+=($OPTARG)
            [[ -f "$OPTARG" ]] || showHelp
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
        f)
            f=${OPTARG}
            [ "$f" = "true" -o "$f" = "false" ] || showHelp
            ;;
        s)
            s=${OPTARG}
            [ "$s" = "v3" -o "$s" = "v4" ] || showHelp
            ;;
        l)
            l=${OPTARG}
            [ "$l" = "local" -o "$l" = "latest" ] || showHelp
            ;;
        m)
            m=${OPTARG}
            [ "$m" = "true" -o "$m" = "false" ] || showHelp
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
echo -e "${GREEN} composeFiles=${composeFiles[@]} ${NC}"
echo -e "${GREEN} v=${v} ${NC}"
echo -e "${GREEN} u=${u} ${NC}"
echo -e "${GREEN} n=${n} ${NC}"
echo -e "${GREEN} p=${p} ${NC}"
echo -e "${GREEN} p=${p} ${NC}"

if [ "$f" == "true" ]; then
    latestPath="../docker/latest"
    localPath="../docker/local"
    if [ "$l" == "local" ]; then
        composeFiles=("${latestPath}/docker-compose-lighthouse.yml"
                      "${localPath}/docker-compose-ipld-eth-beacon-db.yml"
                      "${localPath}/docker-compose-ipld-eth-beacon-indexer.yml"
                      "${localPath}/docker-compose-ipld-eth-server.yml"
                      "${localPath}/docker-compose-eth-statediff-fill-service.yml"
                      "${localPath}/docker-compose-go-ethereum.yml"
                      "${localPath}/docker-compose-contract.yml"
                     )
    elif [ "$l" == "latest" ]; then
        composeFiles=("${latestPath}/docker-compose-lighthouse.yml"
                      "${latestPath}/docker-compose-ipld-eth-beacon-db.yml"
                      "${latestPath}/docker-compose-ipld-eth-beacon-indexer.yml"
                      "${latestPath}/docker-compose-ipld-eth-server.yml"
                      "${localPath}/docker-compose-eth-statediff-fill-service.yml"
                      "${localPath}/docker-compose-go-ethereum.yml"
                      "${localPath}/docker-compose-contract.yml"
                      )
    fi

    if [ "$s" == "v3" ] && [ "$l" == "latest" ]; then
    composeFiles+=("${latestPath}/docker-compose-db.yml")

    elif [ "$s" == "v3" ] && [ "$l" == "local" ]; then
    composeFiles+=("${localPath}/docker-compose-db.yml")

    elif [ "$s" == "v4" ] && [ "$l" == "latest" ]; then
    composeFiles+=("${latestPath}/docker-compose-db-sharding.yml")

    elif [ "$s" == "v4" ] && [ "$l" == "local" ]; then
    composeFiles+=("${localPath}/docker-compose-db-sharding.yml")

    fi
fi


if [ "$e" != "skip" ]; then
    ./compile-geth.sh -e $e -n $n -u $u -p $p
fi

echo -e "${GREEN} Sourcing: $p ${nc}"
source $p

if [ "$m" == "true" ]; then
    export genesis_file_path='start-up-files/go-ethereum/genesis-automine.json'
fi

fileArgs=()
for files in "${composeFiles[@]}"; do fileArgs+=(-f "$files"); done

echo -e "${GREEN} fileArgs: ${fileArgs[@]} ${nc}"


if [[ "$v" = "keep" ]] ; then
    trap 'cd ../docker/; docker-compose --env-file $p ${fileArgs[@]} down --remove-orphans; cd ../' SIGINT SIGTERM
fi

if [[ "$v" = "remove" ]] ; then
    trap 'cd ../docker/; docker-compose --env-file $p ${fileArgs[@]} down -v --remove-orphans; cd ../' SIGINT SIGTERM
fi

echo -e "${GREEN}Building DB image using ${d}${NC}"
echo -e "${GREEN}docker-compose --env-file $p ${fileArgs[@]} up --build${NC}"
docker-compose --env-file "$p" ${fileArgs[@]} up --build
