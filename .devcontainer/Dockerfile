# syntax=docker/dockerfile:1
FROM python:3.12.2 AS build_env


# install python dev libraries
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-pip \
    python3-venv


ENV POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_NO_INTERACTION=1 

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# add poetry to path
ENV PATH="$POETRY_HOME/bin:$PATH"
