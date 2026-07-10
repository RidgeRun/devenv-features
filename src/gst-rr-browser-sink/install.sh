#!/usr/bin/env bash

set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gst-rr-browser-sink\" feature" >&2
        exit 1
    fi
}

check_option "$VERSION" "version"
check_option "$REPOURL" "repoUrl"
check_option "$BUILDTYPE" "buildType"

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/build-gst-rr-browser-sink.sh"
TARGET_SCRIPT="/usr/local/bin/build-gst-rr-browser-sink"

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
  libsoup-3.0-dev \
  libnice-dev \
  libssl-dev

DEFAULT_REPO_URL=$(printf '%q' "$REPOURL")
DEFAULT_VERSION=$(printf '%q' "$VERSION")
DEFAULT_BUILD_TYPE=$(printf '%q' "$BUILDTYPE")
DEFAULT_EXTRA_ARGS=$(printf '%q' "${EXTRAARGS:-}")

escape_sed_replacement() {
    printf '%s' "$1" | sed 's/[\\&|]/\\&/g'
}

tmp_script="$(mktemp /tmp/build-gst-rr-browser-sink.XXXXXX)"
trap 'rm -f "$tmp_script"' EXIT

sed \
    -e "s|__DEFAULT_REPO_URL__|$(escape_sed_replacement "$DEFAULT_REPO_URL")|g" \
    -e "s|__DEFAULT_VERSION__|$(escape_sed_replacement "$DEFAULT_VERSION")|g" \
    -e "s|__DEFAULT_BUILD_TYPE__|$(escape_sed_replacement "$DEFAULT_BUILD_TYPE")|g" \
    -e "s|__DEFAULT_EXTRA_ARGS__|$(escape_sed_replacement "$DEFAULT_EXTRA_ARGS")|g" \
    "$SOURCE_SCRIPT" >"$tmp_script"

install -m 0755 "$tmp_script" "$TARGET_SCRIPT"
