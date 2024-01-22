#!/usr/bin/env bash

# forward errors
set -e

SCRIPT_PATH=$(dirname -- "$( readlink -f -- "$0"; )";)
source $SCRIPT_PATH/vars.sh



function install_python {

    if [[ -d $PYTHON_HOME ]]; then 
        echo "cleaning previous python installation"
        rm -rf $PYTHON_HOME
    fi


    mkdir $PYTHON_HOME
    echo "downloading python source code..."
    python_zip_file="$PYTHON_HOME/python.tar.gz"
    wget -O $python_zip_file https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz > /dev/null

    echo "decompressing python source code"
    tar -xzf $python_zip_file -C $PYTHON_HOME
    rm -f $python_zip_file

    cd $PYTHON_HOME/Python-$PYTHON_VERSION
    echo "building python"
    ./configure --prefix $PYTHON_HOME > /dev/null
    make -j$(getconf _NPROCESSORS_ONLN) > /dev/null
    make install > /dev/null
    cd ../..

    echo -n $PYTHON_VERSION > $PYTHON_VERSION_PATH
}

function install_poetry {

    if [[ -d $POETRY_HOME ]]; then
        echo "cleaning previous poetry installation"
        rm -rf $POETRY_HOME
    fi

    curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME POETRY_VERSION=$POETRY_VERSION python3 - > /dev/null
    $POETRY_BIN env use $PYTHON
    echo -n $POETRY_VERSION > $POETRY_VERSION_PATH
}

# checar se o python3 instalado tem versão igual ou maior que a necessária
# - se sim, usar o python local
# - se não, instalar um python localmente
PYTHON="python3"
if ! $SCRIPT_PATH/scripts/version_gte.py $($SCRIPT_PATH/scripts/get_python_version.py) $PYTHON_VERSION; then


    PYTHON=$PYTHON_BIN

    if ! [[ -d $PYTHON_HOME ]]; then
        echo "system python3 obsolete or inadequate, using local python"
        echo "local python not found, installing..."
        install_python;
    fi

    # checar se a versão do python instalada localmente é menor que a necessária
    # - se sim, atualizar o python instalado localmente
    if ! $SCRIPT_PATH/scripts/version_gte.py $PYTHON_VERSION $(cat $PYTHON_VERSION_PATH); then
        echo "obsolete or inadequate local python version, reinstalling..."
        install_python;
    fi
fi

# checar se o poetry já está instalado
# - se não, instalar
if ! [[ -d $POETRY_HOME ]]; then
    echo -n "local poetry not found, installing poetry..."
    install_poetry
fi

# checar se a versão do poetry instalado é menor que a da variável
# - se sim, reinstalar o poetry
if ! $SCRIPT_PATH/scripts/version_gte.py $POETRY_VERSION $(cat $POETRY_VERSION_PATH); then
    echo "obsolete or inadequate local poetry version, reinstalling..."
    install_poetry
fi

$POETRY_BIN run python3 $SCRIPT_PATH/cpm $@