#!/usr/bin/env bash

apt update
DEBIAN_FRONTEND=noninteractive \
apt install --yes \
  pipx

if [ ! -d "$MESONPATH" ]; then
    echo "The path \"$MESONPATH\" is not a valid directory" >&2
    exit 1
fi

if [ -z "$MESONVERSION" ]; then
    PKG="meson"
else
    PKG="meson==$MESONVERSION"
fi

PIPX_BIN_DIR=$MESONPATH \
pipx install $PKG
