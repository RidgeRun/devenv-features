#!/usr/bin/env bash

#set -e

function check_option() {
    var="$1"
    opt_name="$2"

    if [ -z "$var" ]; then
        echo "Please pass the \"${opt_name}\" option to the \"gstreamer\" feature" >&2
        exit 1
    fi
}

check_option "$CUDAVERSION" "cudaVersion"
check_option "$ARCHITECTURE" "architecture"
check_option "$UBUNTUVERSION" "ubuntuVersion"

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

ubuntu_version_flat="${UBUNTUVERSION/./}"
cuda_version_dash="${CUDAVERSION/./-}"

URL=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${ubuntu_version_flat}/${ARCHITECTURE}/cuda-keyring_1.1-1_all.deb

export DEBIAN_FRONTEND=noninteractive
apt -yq update
apt install -yq wget ca-certificates

cd /tmp/
wget $URL
dpkg -i cuda-keyring_1.1-1_all.deb
apt -yq update

cuda_pkg="cuda-libraries-${cuda_version_dash}"
nvtx_pkg="cuda-nvtx-${cuda_version_dash}"
toolkit_pkg="cuda-toolkit-${cuda_version_dash}"
if ! apt-cache show "$cuda_pkg"; then
    echo $cuda_pkg
    echo "The requested version of CUDA is not available: CUDA $CUDAVERSION"
    exit 1
fi

echo "Installing CUDA libraries..."
apt-get install -yq "$cuda_pkg"
apt-get update -yq --fix-missing

# auto find recent cudnn version
major_cuda_version=$(echo "${CUDAVERSION}" | cut -d '.' -f 1)
if [ "$CUDNNVERSION" = "automatic" ]; then
    if [[ "$CUDAVERSION" < "12.3" ]]; then
        CUDNNVERSION=$(apt-cache policy libcudnn8 | grep "$CUDAVERSION" | grep -Eo '^[^-1+]*' | sort -V | tail -n1 | xargs)
    else
        CUDNNVERSION=$(apt-cache policy libcudnn9-cuda-$major_cuda_version | grep "Candidate" | awk '{print $2}' | grep -Eo '^[^-+]*')
    fi
fi
major_cudnn_version=$(echo "${CUDNNVERSION}" | cut -d '.' -f 1)

if [ "$INSTALLCUDNN" = "true" ]; then
    # Ensure that the requested version of cuDNN is available AND compatible
    #if major cudnn version is 9, then we need to install libcudnn9-cuda-<major_cuda_version>_<CUDNN_VERSION>-1 package
    #else we need to install libcudnn8_<CUDNN_VERSION>-1+cuda<CUDA_VERSION>" package
    if [[ $major_cudnn_version -ge "9" ]]
    then
        cudnn_pkg_version="libcudnn9-cuda-${major_cuda_version}=${CUDNNVERSION}-1"
    else
        cudnn_pkg_version="libcudnn8=${CUDNN_VERSION}-1+cuda${CUDAVERSION}"
    fi

    if ! apt-cache show "$cudnn_pkg_version"; then
        echo "The requested version of cuDNN is not available: cuDNN $CUDNNVERSION for CUDA $CUDAVERSION"
        exit 1
    fi

    echo "Installing cuDNN libraries..."
    apt-get install -yq "$cudnn_pkg_version"
fi

if [ "$INSTALLCUDNNDEV" = "true" ]; then
    # Ensure that the requested version of cuDNN development package is available AND compatible
    #if major cudnn version is 9, then we need to install libcudnn9-dev-cuda-<major_cuda_version>_<CUDNN_VERSION>-1 package
    #else we need to install libcudnn8-dev_<CUDNN_VERSION>-1+cuda<CUDA_VERSION>" package
    if [[ $major_cudnn_version -ge "9" ]]
    then
        cudnn_dev_pkg_version="libcudnn9-dev-cuda-${major_cuda_version}=${CUDNNVERSION}-1"
    else
        cudnn_dev_pkg_version="libcudnn8-dev=${CUDNNVERSION}-1+cuda${CUDAVERSION}"
    fi
    if ! apt-cache show "$cudnn_dev_pkg_version"; then
        echo "The requested version of cuDNN development package is not available: cuDNN $CUDNNVERSION for CUDA $CUDAVERSION"
        exit 1
    fi

    echo "Installing cuDNN dev libraries..."
    apt-get install -yq "$cudnn_dev_pkg_version"
fi

if [ "$INSTALLNVTX" = "true" ]; then
    echo "Installing NVTX..."
    apt-get install -yq "$nvtx_pkg"
fi

if [ "$INSTALLTOOLKIT" = "true" ]; then
    echo "Installing CUDA Toolkit..."
    apt-get install -yq "$toolkit_pkg"
fi

cat << EOF > /etc/profile.d/cuda_runtime_paths.sh
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
EOF

echo "Installed!"
