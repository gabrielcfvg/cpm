#!/usr/bin/env bash

# setup errors
set -eu

# imports
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)
source $SCRIPT_HOME/vars.sh



# call setup_env.sh to ensure that all dependencies are meet
$SCRIPT_HOME/setup_env.sh > /dev/null

# check if the current build is already the lastest version
if [[ -f $CPM_BIN ]]; then

    if ! [[ -f $CPM_VERSION_PATH ]]; then
        echo "the build directory seems to be corrupted, you can try removing the $PYINSTALLER_HOME directory or running a full clean"
        exit 1
    fi

    if $version_gte $( cat $CPM_VERSION_PATH ) $CPM_VERSION; then

        if $version_lt $CPM_VERSION $( cat $CPM_VERSION_PATH ); then
            echo "the version of the cpm build is higher than the script version. this can only be caused by forgetting to update the script version"
            exit 1
        fi

        echo "the most recent version of CPM is already built"
        exit 0
    fi
fi


# create the build folder if needed
if ! [[ -d $PYINSTALLER_HOME ]]; then
    mkdir $PYINSTALLER_HOME
fi



cd $PYINSTALLER_HOME
$POETRY_BIN run pyinstaller -n cpm -y --workpath $PYINSTALLER_WORKPATH --distpath $PYINSTALLER_DIST $SCRIPT_HOME/cpm/__main__.py
cd $SCRIPT_HOME/example_project
$CPM_BIN --version | tr -d '\n' > $CPM_VERSION_PATH
cd $SCRIPT_HOME