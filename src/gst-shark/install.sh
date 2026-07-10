#!/usr/bin/env bash

set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gst-shark\" feature" >&2
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
  libgraphviz-dev

mkdir -p /usr/src
cd /usr/src

GST_SHARK_REPO_URL="https://github.com/RidgeRun/gst-shark.git"
git clone "$GST_SHARK_REPO_URL" \
  --depth 1 --single-branch --branch \
  "$VERSION"

cd gst-shark
meson setup builddir \
  --prefix=/usr \
  --buildtype="$BUILDTYPE" \
  $EXTRAARGS

meson compile -C builddir
meson install -C builddir
