#!/usr/bin/env bash

set -euo pipefail

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gst-rr-browser-sink\" build script" >&2
        exit 1
    fi
}

repo_url=__DEFAULT_REPO_URL__
version=__DEFAULT_VERSION__
build_type=__DEFAULT_BUILD_TYPE__
extra_args=__DEFAULT_EXTRA_ARGS__

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo-url)
            repo_url="$2"
            shift 2
            ;;
        --version)
            version="$2"
            shift 2
            ;;
        --build-type)
            build_type="$2"
            shift 2
            ;;
        --extra-args)
            extra_args="$2"
            shift 2
            ;;
        --help)
            cat <<USAGE
Usage: build-gst-rr-browser-sink [--repo-url URL] [--version REF] [--build-type TYPE] [--extra-args ARGS]
USAGE
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

check_option "$repo_url" "repoUrl"
check_option "$version" "version"
check_option "$build_type" "buildType"

workdir="$(mktemp -d /tmp/gst-rr-browser-sink.XXXXXX)"
trap 'rm -rf "$workdir"' EXIT

git clone "$repo_url" \
    --depth 1 --single-branch --branch \
    "$version" "$workdir/src"

cd "$workdir/src"
meson setup builddir \
    --prefix=/usr \
    --buildtype="$build_type" \
    $extra_args

meson compile -C builddir
sudo meson install -C builddir
