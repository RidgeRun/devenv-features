#!/usr/bin/env bash

set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gstd\" feature" >&2
        exit 1
    fi
}

check_option "$VERSION" "version"
check_option "$BUILDTYPE" "buildType"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt update -yq
DEBIAN_FRONTEND=noninteractive \
apt install -yq \
  git \
  build-essential \
  pkg-config \
  libxml2-dev \
  libjson-glib-dev \
  libdaemon-dev \
  libjansson-dev \
  libedit-dev \
  libsoup-3.0-dev

mkdir -p /usr/src
cd /usr/src

GSTD_REPO_URL="https://github.com/RidgeRun/gstd-1.x.git"
git clone "$GSTD_REPO_URL" \
  --depth 1 --single-branch --branch \
  "$VERSION"

cd gstd-1.x
meson setup builddir \
  --prefix=/usr \
  --buildtype="$BUILDTYPE" \
  -Denable-tests=disabled \
  -Denable-examples=disabled \
  -Denable-gtk-doc=false \
  -Denable-systemd=disabled \
  -Denable-initd=disabled \
  -Denable-python=disabled \
  $EXTRAARGS

meson compile -C builddir
meson install -C builddir
