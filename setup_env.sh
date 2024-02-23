#!/usr/bin/env bash

# setup errors
set -eu

# imports
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)
source $SCRIPT_HOME/vars.sh


# ---------------------------------- python ---------------------------------- #

SYS_PYTHON_ERROR=0
SYS_PYTHON_ERROR_MESSAGE=0

for python in "${PYTHON_NAMES[@]}"; do

    echo -n "checking $python...: "

    SYS_PYTHON_ERROR=0
    SYS_PYTHON_ERROR_MESSAGE=0

    # check if python is installed on the system
    if ! command -v $python &> /dev/null;then
        SYS_PYTHON_ERROR=1
        SYS_PYTHON_ERROR_MESSAGE="could not find $python"
    fi

    # check if the version of system python is adequate
    if [[ $SYS_PYTHON_ERROR -eq 0 ]] && (! $version_gte $( $python $SCRIPT_HOME/scripts/get_python_version.py ) $PYTHON_VERSION); then
        SYS_PYTHON_ERROR=1
        SYS_PYTHON_ERROR_MESSAGE="the system's $python version is not adequate, CPM requires python $PYTHON_VERSION"
    fi

    # check if the system's python installation have the shared library that is needed by the pyinstaller
    if [[ $SYS_PYTHON_ERROR -eq 0 ]] && (! ldconfig -p | grep "libpython${PYTHON_REDUCED_VERSION}.so.1.0" &> /dev/null); then
        SYS_PYTHON_ERROR=1
        SYS_PYTHON_ERROR_MESSAGE="the system does not have the libpython${PYTHON_REDUCED_VERSION}.so.1.0 library"
    fi

    if [[ $SYS_PYTHON_ERROR -eq 0 ]]; then
        
        echo "SUCCESS"
        PYTHON_BIN=$python
        break
    else
        echo "FAILED, $SYS_PYTHON_ERROR_MESSAGE"
    fi
done

if ! [[ SYS_PYTHON_ERROR -eq 0 ]]; then
    echo "could not find a compatible python interpreter" >&2
    echo "You can use the build_env and dev_env container images to develop or build CPM." >&2
    exit 1
fi


# ---------------------------------- poetry ---------------------------------- #

# check if poetry is available
if ! command -v poetry &> /dev/null; then
    echo "Poetry is not installed. Please install Poetry." >&2
    echo "You can use the build_env and dev_env container images to develop or build CPM." >&2
    exit 1
fi

# check if poetry version is equal or higher than the required version
INSTALLED_POETRY_VERSION=$(poetry --version | awk '{print $NF}')
if ! [[ "$(printf '%s\n' "$POETRY_VERSION" "$INSTALLED_POETRY_VERSION" | sort -V | head -n1)" == "$POETRY_VERSION" ]]; then
    echo "Poetry version $POETRY_VERSION or higher is required. Please upgrade Poetry." >&2
    echo "You can use the build_env and dev_env container images to develop or build CPM." >&2
    exit 1
fi
