#!/bin/bash
if ! [ -x "$(command -v gp)" ]; then
    docker compose up "$@"
else
    URL_PATTERN=$(gp url 5555 | sed 's@5555@%s@') docker compose up "$@"
fi
