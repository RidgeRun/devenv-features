#!/usr/bin/env bash

set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gst-interpipe\" feature" >&2
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
  ninja-build \
  pkg-config

mkdir -p /usr/src
cd /usr/src

GST_INTERPIPE_REPO_URL="https://github.com/RidgeRun/gst-interpipe.git"
git clone "$GST_INTERPIPE_REPO_URL" \
  --depth 1 --single-branch --branch \
  "$VERSION"

cd gst-interpipe
meson setup builddir \
  --prefix=/usr \
  --buildtype="$BUILDTYPE" \
  -Dtests=disabled \
  -Denable-gtk-doc=false \
  $EXTRAARGS

meson compile -C builddir
meson install -C builddir
