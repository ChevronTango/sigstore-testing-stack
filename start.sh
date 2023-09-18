#!/bin/bash
URL_PATTERN=$(gp url 5555 | sed 's@5555@%s@') docker compose up