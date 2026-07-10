#!/usr/bin/env bash

set -euo pipefail

install -d -m 0755 \
  /var/run/devenv \
  /var/run/devenv/config \
  /var/run/devenv/cache

install -m 0755 ./devenv-post-create.sh /usr/local/bin/devenv-post-create

printf 'export DISPLAY=%q\n' "$DISPLAY" > /etc/profile.d/devenv-x11.sh
chmod 0644 /etc/profile.d/devenv-x11.sh
