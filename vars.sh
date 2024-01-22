#!/usr/bin/env bash

POETRY_HOME="$(dirname -- "$( readlink -f -- "$0"; )";)/poetry"
POETRY_BIN="${POETRY_HOME}/bin/poetry"
POETRY_VERSION="1.7.1"
POETRY_VERSION_PATH="${POETRY_HOME}/.poetry_version"

PYTHON_HOME="$(dirname -- "$( readlink -f -- "$0"; )";)/python"
PYTHON_BIN="${PYTHON_HOME}/bin/python3"
PYTHON_VERSION="3.12.1"
PYTHON_VERSION_PATH="${PYTHON_HOME}/.python_version"