#!/usr/bin/env bash

set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gst-perf\" feature" >&2
        exit 1
    fi
}

check_option "$VERSION" "version"
check_option "$BUILDTYPE" "buildType"

function build_type_to_cflags() {
    case "$1" in
        plain)
            echo ""
            ;;
        debug)
            echo "-O0 -ggdb3"
            ;;
        debugoptimized)
            echo "-O2 -ggdb3"
            ;;
        release)
            echo "-O2"
            ;;
        minsize)
            echo "-Os"
            ;;
        *)
            echo "Unsupported buildType: $1" >&2
            exit 1
            ;;
    esac
}

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apt update -yq
DEBIAN_FRONTEND=noninteractive \
apt install -yq \
  git \
  autoconf \
  automake \
  libtool \
  build-essential \
  pkg-config

mkdir -p /usr/src
cd /usr/src

GST_PERF_REPO_URL="https://github.com/RidgeRun/gst-perf.git"
git clone "$GST_PERF_REPO_URL" \
  --depth 1 --single-branch --branch \
  "$VERSION"

cd gst-perf
./autogen.sh

BUILD_FLAGS="$(build_type_to_cflags "$BUILDTYPE")"
if [ -n "$BUILD_FLAGS" ]; then
    export CFLAGS="$BUILD_FLAGS"
    export CXXFLAGS="$BUILD_FLAGS"
else
    unset CFLAGS
    unset CXXFLAGS
fi

./configure \
  --prefix=/usr \
  --libdir="/usr/lib/$(gcc -dumpmachine)/" \
  $CONFIGUREARGS

make
make install
