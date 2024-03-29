#!/usr/bin/env bash

# forward errors
set -eu

# get script directory
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)

# TODO: option to force the use of build container
# use local environment if it attends the requirements
if $SCRIPT_HOME/setup_env.sh; then
    echo "Looks like your environment have all the requirements, using local environment..."
    $SCRIPT_HOME/build.sh
    exit 0
fi

# check if docker is available
if ! command -v docker &> /dev/null; then
    echo "Could not find docker. Please install docker and try again."
    exit 1
fi

# build the build_env image
$SCRIPT_HOME/.devcontainer/build_build_env.sh

# use the build_env image to build the cpm
docker run --rm -v $SCRIPT_HOME:/cpm -w /cpm cpm_build_env /cpm/build.sh
