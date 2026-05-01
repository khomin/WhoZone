#!/bin/bash
set -e

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $PROJECT_DIR ]; then
    PROJECT_DIR=$PWD
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ARG=$1
SOURCE_DIR="$SCRIPT_DIR/.protobuf"
CHECKOUT_TAG="v34.0"
TEMP_DIR=".build-$PLATFORM_ARG"

if [[ ! "$PLATFORM_ARG" =~ ^(macos|android|windows|linux|ios)$ ]]; then
    echo "Usage: $0 {macos|android|windows|linux|ios}"
    exit 1
fi

echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "PROJECT_DIR=$PROJECT_DIR"

if [ ! -d "$SOURCE_DIR/.git" ]; then
    echo "Cloning protobuf... $CHECKOUT_TAG"
    git clone https://github.com/protocolbuffers/protobuf.git --branch $CHECKOUT_TAG --depth 1 --recurse-submodule "$SOURCE_DIR"
else
    echo "Protobuf source already exists in $SOURCE_DIR. Skipping clone."
fi
cd "$SOURCE_DIR"
mkdir -p $TEMP_DIR
cd $TEMP_DIR

build() {
    local BUILD_NAME=$1
    local ARCH=$2
    local EXTRA_ARGS=$3
    echo "Building $BUILD_NAME-$ARCH arguments=$EXTRA_ARGS (this may take a minute)..."
    INSTALL_DIR="$PROJECT_DIR/.lib_pack/$BUILD_NAME/protobuf"
    cmake -S ../ -B "$BUILD_NAME" \
        -Dprotobuf_BUILD_TESTS=OFF \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_MACOSX_BUNDLE=OFF \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        $EXTRA_ARGS
    cmake --build $BUILD_NAME --config Release
    cmake --install $BUILD_NAME --config Release --prefix ${INSTALL_DIR}/$ARCH
}

echo "PLATFORM_ARG=$PLATFORM_ARG"

case $PLATFORM_ARG in
    macos)
        build "apple" "macos_universal" \
            "-G Xcode \
            -DPLATFORM=MAC_UNIVERSAL \
            -DDEPLOYMENT_TARGET=11.0 \
            -Dprotobuf_BUILD_PROTOC_BINARIES=YES \
            -DCMAKE_TOOLCHAIN_FILE=$PROJECT_DIR/cpp/submodule/ios-cmake/ios.toolchain.cmake"
        ;;
    android)
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
        build "android" "arm64-v8a" "-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN
            -DANDROID_ABI=arm64-v8a \
            -DANDROID_PLATFORM=android-29 \
            -DCMAKE_ANDROID_NDK=${NDK} \
            -Dprotobuf_BUILD_PROTOC_BINARIES=NO"
        ;;
    *)
        echo "Usage: $0 {macos|android}"
        exit 1
        ;;
esac

# cd ../..
# rm -rf $SOURCE_DIR

echo "------------------"
echo "COMPLETED"
echo "------------------"