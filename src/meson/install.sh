#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt update -yq
DEBIAN_FRONTEND=noninteractive \
    apt install -yq \
    python3 \
    python3-pip


if [ -z "$MESONVERSION" ]; then
    PKG="meson"
else
    PKG="meson==$MESONVERSION"
fi

pip install $PKG
