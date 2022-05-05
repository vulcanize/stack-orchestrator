#!/bin/bash

## This script will create a config file for you.
usage() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF
Usage: ./create-config -b <base-path>
This script will create a config file for you and put it in the root directory based on the base path you provide it.

-h, -help,          Display help

-b,                 The base directory for the config file. Recommended that you use ~/vulcanize

-p,                 Path to the configuration file that specifies to location of the output directories. It is recommended to use ../config.sh

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

b=~/vulcanize
p=../config.sh
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
while getopts ":b:p:" o; do
    case "${o}" in
        b)
            b=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

cp sample-config.sh ${p}
vulcanize_repo_base_dir=$b

eval "echo \"$(cat sample-config.sh)\" > ${p}"