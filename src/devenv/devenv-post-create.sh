#!/usr/bin/env bash

set -euo pipefail

link_path() {
  local destination="$1"
  local source="$2"

  mkdir -p "$(dirname "$destination")"
  rm -rf "$destination"
  ln -s "$source" "$destination"
}

link_path "$HOME/.config" /var/run/devenv/config
link_path "$HOME/.gitconfig" /var/run/devenv/gitconfig
link_path "$HOME/.cache" /var/run/devenv/cache
link_path "$HOME/.ssh/known_hosts" /var/run/devenv/known_hosts
link_path "$HOME/.Xauthority" /var/run/devenv/.Xauthority

if [ -e /var/run/devenv/ssh-auth.sock ]; then
  sudo chmod o=rw /var/run/devenv/ssh-auth.sock
fi
