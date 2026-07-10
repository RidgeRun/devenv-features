#!/usr/bin/env bash

set -euo pipefail

install -d -m 0755 \
  /var/run/devenv \
  /var/run/devenv/config \
  /var/run/devenv/cache

install -m 0755 ./devenv-post-create.sh /usr/local/bin/devenv-post-create
