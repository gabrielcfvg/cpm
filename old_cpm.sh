#!/usr/bin/env bash

# setup errors
set -eu

# imports
SCRIPT_HOME=$(dirname -- "$( readlink -f -- "$0"; )";)
source $SCRIPT_HOME/vars.sh



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

    # TODO:
    # para previnir que warnings de compilação sejam mostrados na tela,
    # enviar o stderr dos comandos de compilação para um arquivo, caso
    # o comando seja bem sucedido, deletar o arquivo, caso ocorra um erro,
    # avisar sobre o erro e apontar o arquivo onde os logs de erro estão
    ./configure --enable-shared --prefix $PYTHON_HOME > /dev/null
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
    $POETRY_BIN env use $PYTHON_BIN
    $POETRY_BIN install
    echo -n $POETRY_VERSION > $POETRY_VERSION_PATH
}

# checar se o python3 instalado tem versão igual ou maior que a necessária
# - se sim, usar o python local
# - se não, instalar um python localmente
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


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PYTHON_HOME/lib

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

# TODO:
#
# lembrar:
#   -- usar '--noconfirm' para buildar     
#   -- após o build, gerar um arquivo contendo a versão do cpm
#       -- para gerar o arquivo, entrar no diretório do example_project e rodar o comando de versão
#       -- ex: cd example_project
#              ../dist/cpm/cpm --version | tr -d '\n' > ../dist/cpm/.cpm_version
#              cd -
#
# melhorias:
#   -- criar abstração para executar um comando, enviar o stdout e o stderr para um arquivo
#       -- caso o comando seja executado com sucesso, deletar arquivo
#       -- caso o comando falhe, mostar na tela que falhou e apontar o caminho do arquivo contento os logs
#
#
#
# FLUXO DO PROGRAMA:
#
# OBS: caso seja necessário buildar o cpm, avisar ao usuário para executar
#      manualmente o script de build. caso a variavel CPM_AUTO_BUILD esteja
#      setada, buildar automáticamente
#
# ao executar o cpm.sh, verificar se o dist/cpm existe
# -- se não, é necessário buildar o cpm
# -- se sim, prossiga
#
# comparar a versão do cpm atual com a versão especificada na variável CPM_VERSION
# -- se for menor, é necessário rebuildar o cpm
# -- se for maior, então significa que esqueceram de atualizar a variável no script vars.sh
# -- se for igual, prossiga
# 
# invocar o cpm repassando os argumentos