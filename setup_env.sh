#!/usr/bin/env bash


# if DRY_RUN is not defined, set it to zero
# this needs to happen before 'set', since it is an external variable

if ! [[ -v DRY_RUN ]]; then
    DRY_RUN=0
else
    DRY_RUN=$DRY_RUN
fi

# setup errors
set -eu

# imports
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)
source $SCRIPT_HOME/vars.sh



function install_poetry {

    if [[ $DRY_RUN -eq 1 ]]; then
        echo "internal error: $FUNCNAME should not be called in DRY_RUN mode" >&2
        exit 0
    fi

    if [[ -d $POETRY_HOME ]]; then
        echo "cleaning previous poetry installation" >&2
        rm -rf $POETRY_HOME
    fi

    curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME POETRY_VERSION=$POETRY_VERSION $PYTHON_BIN - > /dev/null
    $POETRY_BIN -C $SCRIPT_HOME config virtualenvs.in-project true
    $POETRY_BIN -C $SCRIPT_HOME env use $PYTHON_BIN
    $POETRY_BIN -C $SCRIPT_HOME install
    echo -n $POETRY_VERSION > $POETRY_VERSION_PATH
}

# unused, for now.....
#
# function read_answer {
# 
#     read -p "$1 ($2, $3): " answer
# 
#     if [[ "$answer" == "$2" ]]; then
#         return 1
#     elif [[ "$answer" == "$3" ]]; then
#         return 2
#     else
#         echo "invalid answer, retry"
#         return $(read_answer "$1" "$2" "$3")
#     fi
# }



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
    exit 1
fi



# checar se o poetry já está instalado
# - se não, instalar
if ! [[ -d $POETRY_HOME ]]; then

    echo "local poetry not found, installing poetry..." >&2

    if ! [[ $DRY_RUN -eq 1 ]]; then
        install_poetry
    fi
fi

# checar se a versão do poetry instalado é menor que a da variável
# - se sim, reinstalar o poetry
if ! $SCRIPT_HOME/scripts/version_gte.py $POETRY_VERSION $(cat $POETRY_VERSION_PATH); then
    
    echo "obsolete or inadequate local poetry version, reinstalling..." >&2
    
    if ! [[ $DRY_RUN -eq 1 ]]; then
        install_poetry
    fi
fi

echo "poetry local installation is done"
