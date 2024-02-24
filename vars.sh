#!/usr/bin/env bash

# setup errors
set -eu


# setting the path variables
SCRIPT_HOME="$(dirname -- "$( readlink -f -- "$0"; )";)"

# dependencies versions
POETRY_VERSION="1.7.1"
PYTHON_VERSION="3.12.1"
PYTHON_REDUCED_VERSION=$(echo "$PYTHON_VERSION" | cut -d'.' -f1,2)
PYTHON_NAMES=("python3" "python$PYTHON_REDUCED_VERSION")

# build paths
PYINSTALLER_HOME="$SCRIPT_HOME/build" # prevents the root folder from getting too dirty
PYINSTALLER_WORKPATH="cache" # two consecutive build folders are confusing
PYINSTALLER_DIST="dist"
CPM_HOME="$PYINSTALLER_HOME/$PYINSTALLER_DIST/cpm"
CPM_BIN="$CPM_HOME/cpm"
CPM_VERSION="0.1.12"
CPM_VERSION_PATH="$CPM_HOME/.cpm_path"


# scripts
function assert_file_existence { if ! [[ -f $1 ]]; then echo "$1 not found" >&2; exit 1; fi }
get_python_version="$SCRIPT_HOME/scripts/get_python_version.py"; assert_file_existence $get_python_version
version_gte="$SCRIPT_HOME/scripts/version_gte.py"; assert_file_existence $version_gte
version_lt="$SCRIPT_HOME/scripts/version_lt.py"; assert_file_existence $version_lt
