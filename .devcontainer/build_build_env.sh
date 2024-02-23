#!/usr/bin/env bash

# forward errors
set -e

# get script directory
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)

# check if docker is available
if ! command -v docker &> /dev/null; then
    echo "Could not find docker. Please install docker and try again."
    exit 1
fi

# build the build_env image
docker build -t cpm_build_env -f $SCRIPT_HOME/Dockerfile .
