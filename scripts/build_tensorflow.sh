#!/bin/bash
set -e

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $PROJECT_DIR ]; then
    PROJECT_DIR=$PWD
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.tensorflow"
TEMP_DIR=".build"

if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
else
    export ANDROID_HOME="$HOME/Android/Sdk"
fi
export NDK=$(ls -d $ANDROID_HOME/ndk/* 2>/dev/null | sort -V | tail -n 1)
export CMAKE_SYSROOT=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/
export TOOLCHAIN=${NDK}/build/cmake/android.toolchain.cmake
if [ -z "$NDK" ]; then
    echo "NDK not defined"
    exit 1
fi
if [ -z "$CMAKE_SYSROOT" ]; then
    echo "CMAKE_SYSROOT not defined"
    exit 1
fi
if [ -z "$TOOLCHAIN" ]; then
    echo "TOOLCHAIN not defined"
    exit 1
fi
echo "USING-NDK: ${NDK}"
echo "USING-CMAKE_SYSROOT: ${CMAKE_SYSROOT}"
echo "USING-TOOLCHAIN: ${TOOLCHAIN}"
echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "PROJECT_DIR=$PROJECT_DIR"

if [ ! -d "$SOURCE_DIR/.git" ]; then
    echo "Cloning protobuf"
    git clone https://github.com/tensorflow/tensorflow.git --depth 1 --recurse-submodule "$SOURCE_DIR"
else
    echo "Source already exists in $SOURCE_DIR. Skipping clone."
fi
cd "$SOURCE_DIR"
mkdir -p $TEMP_DIR
cd $TEMP_DIR

build() {
    # local BUILD_NAME=$1
    # local ARCH=$2
    # local EXTRA_ARGS=$3
    # echo "Building $BUILD_NAME-$ARCH arguments=$EXTRA_ARGS (this may take a minute)..."

    # mkdir -p host_build
    # cmake -S ../tensorflow/lite -B host_build \
    #     -DCMAKE_BUILD_TYPE=Release \
    #     -DTFLITE_ENABLE_GPU=OFF
    # cmake --build host_build --target flatc --config Release

    # HOST_TOOLS_DIR=$(pwd)/host_build

    # INSTALL_DIR="$PROJECT_DIR/.lib_pack/$BUILD_NAME/tensorflow"

    # cmake -S ../tensorflow/lite -B "$BUILD_NAME" \
    #     -DCMAKE_CXX_STANDARD=17 \
    #     -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    #     $EXTRA_ARGS \
    #     -DTFLITE_HOST_TOOLS_DIR=$HOST_TOOLS_DIR
    # cmake --build $BUILD_NAME --config Release
    # cmake --install $BUILD_NAME --config Release --prefix ${INSTALL_DIR}/$ARCH
    local BUILD_NAME=$1
    local ARCH=$2
    local EXTRA_ARGS=$3
    
    # --- 1. BUILD HOST TOOLS (Stage 1) ---
    # We need a dedicated host directory that doesn't get wiped by the Android build
    local HOST_BUILD_DIR="$(pwd)/host_tools"
    echo "Building host tools in $HOST_BUILD_DIR..."
    
    mkdir -p "$HOST_BUILD_DIR"
    # Note: We build flatc here for the machine running the script (Mac/Linux)
    cmake -S ../tensorflow/lite -B "$HOST_BUILD_DIR" \
        -DCMAKE_BUILD_TYPE=Release \
        -DTFLITE_ENABLE_GPU=OFF \
        -DTFLITE_ENABLE_XNNPACK=OFF
    
    cmake --build "$HOST_BUILD_DIR" --target flatc -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)

    # TFLite expects flatc to be in $TFLITE_HOST_TOOLS_DIR/bin
    # If flatc is in the root of the build dir, we'll create a bin folder and symlink it
    mkdir -p "$HOST_BUILD_DIR/bin"
    if [ -f "$HOST_BUILD_DIR/flatbuffers-flatc/bin/flatc" ]; then
        ln -sf "$HOST_BUILD_DIR/flatbuffers-flatc/bin/flatc" "$HOST_BUILD_DIR/bin/flatc"
    elif [ -f "$HOST_BUILD_DIR/flatc" ]; then
        ln -sf "$HOST_BUILD_DIR/flatc" "$HOST_BUILD_DIR/bin/flatc"
    fi

    # --- 2. BUILD ANDROID (Stage 2) ---
    echo "Building $BUILD_NAME-$ARCH..."
    INSTALL_DIR="$PROJECT_DIR/.lib_pack/$BUILD_NAME/tensorflow"
    
    cmake -S ../tensorflow/lite -B "$BUILD_NAME" \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        $EXTRA_ARGS \
        -DTFLITE_HOST_TOOLS_DIR="$HOST_BUILD_DIR" \
        -Dflatbuffers_DIR="$HOST_BUILD_DIR/flatbuffers"
        
    cmake --build "$BUILD_NAME" --config Release -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
    cmake --install "$BUILD_NAME" --config Release --prefix "${INSTALL_DIR}/$ARCH"
}

build "android" "arm64-v8a" "-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN
    -DCMAKE_ANDROID_NDK=${NDK} \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-29   \
    -DTFLITE_ENABLE_GPU=ON"

# cd ../..
# rm -rf $SOURCE_DIR

echo "------------------"
echo "COMPLETED"
echo "------------------"