#!/usr/bin/env bash

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z $var ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gstreamer\" feature" >&2
        exit 1
    fi
}

function boolean_to_feature() {
    result=$1

    if [ -z $result || ! $result ]; then
        echo "disabled"
    else
        echo "enabled"
    fi
}

check_option $GSTVERSION "gstVersion"
check_option $BUILDTYPE "buildType"
check_option $TESTS "tests"
check_option $DOCS "docs"
check_option $EXAMPLES "examples"
check_option $GPL "gpl"
check_option $INTROSPECTION "introspection"

apt update
DEBIAN_FRONTEND=noninteractive \
apt install --yes \
  git \
  build-essential \
  ninja-build \
  bison \
  flex \
  pkg-config \
  libunwind-dev \
  libdw-dev \
  libpython3-dev \
  bash-completion \
  python3-gi \
  gobject-introspection \
  libgirepository1.0-dev

mkdir -p /usr/local/src
cd /usr/local/src

GST_REPO_URL="https://gitlab.com/gstreamer/gstreamer.git"
git clone $GST_REPO_URL \
  --depth 1 --single-branch --branch \
  $GSTVERSION

cd gstreamer
meson setup builddir \
  --buildtype $BUILDTYPE \
  -Dnls=disabled \
  -Dexamples=`boolean_to_feature $EXAMPLES` \
  -Dtests=`boolean_to_feature $TESTS` \
  -Dgpl=`boolean_to_feature $GPL` \
  -Ddoc=`boolean_to_feature $DOCS` \
  -Dintrospection=`boolean_to_feature $INTROSPECTION` \
  -Dgstreamer:libunwind=enabled \
  -Dgstreamer:libdw=enabled \
  -Dgstreamer:bash-completion=enabled \
  $EXTRAARGS

meson compile -C builddir
meson install -C builddir

# Can't use containerEnv here because we are dynamically probing the architecture
GST_PROFILE=/etc/profile.d/gstreamer_runtime_paths.sh
MACH=`uname -m`
cat << EOF > $GST_PROFILE
export LD_LIBRARY_PATH=/usr/local/lib/${MACH}-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
EOF

# Only append introspection path if it was enabled
$INTROSPECTION && cat << EOF >> $GST_PROFILE
export GI_TYPELIB_PATH=/usr/local/lib/${MACH}-linux-gnu/girepository-1.0${GI_TYPELIB_PATH:+$GI_TYPELIB_PATH}
EOF

chmod 644 $GST_PROFILE
