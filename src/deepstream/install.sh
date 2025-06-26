#!/usr/bin/env bash

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"deepstream\" feature" >&2
        exit 1
    fi
}

check_option "$DSVERSION" "dsVersion"
check_option "$PLATFORM" "platform"
check_option "$CUDAVERSION" "cudaVersion"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

TARGET="deepstream_sdk_v${DSVERSION}.0_${PLATFORM}.tbz2"
URL="https://api.ngc.nvidia.com/v2/resources/org/nvidia/deepstream/${DSVERSION}/files?redirect=true&path=${TARGET}"

apt update -yq
apt install -yq \
    curl \
    libssl3 \
    libssl-dev \
    libgles2-mesa-dev \
    libjansson-dev \
    libyaml-cpp-dev \
    libjsoncpp-dev \
    protobuf-compiler \
    gcc \
    make \
    git \
    python3 \
    librabbitmq-dev \
    libhiredis-dev \
    libavahi-compat-libdnssd1

curl -L "$URL" -o "$TARGET"
tar -xvf $TARGET -C /

export CFLAGS+="-O0 -ggdb3"
export CXXFLAGS+="$CFLAGS"
export CUDA_VER="$CUDAVERSION"

function build_current_dir() {
    for makefile in `find . -name "Makefile"`; do
        cd `dirname $makefile`
        make
        make install || true # some folders arent for install
        cd -
    done
}

cd /opt/nvidia/deepstream/deepstream/sources/gst-plugins
build_current_dir

cd /opt/nvidia/deepstream/deepstream/sources/libs
build_current_dir

cd /opt/nvidia/deepstream/deepstream/sources/apps
build_current_dir

cd /opt/nvidia/deepstream/deepstream/
./install.sh
