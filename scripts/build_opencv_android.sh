#!/bin/bash
set -e

PROJECT_DIR=$PWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$PROJECT_DIR/.lib_pack/android/opencv"
SOURCE_DIR="$SCRIPT_DIR/.opencv"
CHECKOUT_TAG="4.10.0"

if [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
else
    export ANDROID_HOME="$HOME/Android/Sdk"
    export JAVA_HOME="$HOME/android-studio/jbr"
fi

export NDK=$(ls -d $ANDROID_HOME/ndk/* 2>/dev/null | sort -V | tail -n 1)
export CMAKE_SYSROOT=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/
export TOOLCHAIN=${NDK}/build/cmake/android.toolchain.cmake

echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "INSTALL_DIR=$INSTALL_DIR"

mkdir -p "${INSTALL_DIR}"

if [ -z "$NDK" ]
then
    echo "NDK not defined"
    exit 0
fi

if [ -z "$CMAKE_SYSROOT" ]
then
    echo "CMAKE_SYSROOT not defined"
    exit 0
fi

if [ -z "$TOOLCHAIN" ]
then
    echo "TOOLCHAIN not defined"
    exit 0
fi

echo "------------------"
echo "USING-NDK: ${NDK}"
echo "USING-CMAKE_SYSROOT: ${CMAKE_SYSROOT}"
echo "USING-TOOLCHAIN: ${TOOLCHAIN}"
echo "------------------"

if [ ! -d "$SOURCE_DIR/.git" ]; then
    echo "Cloning opencv..."
    git clone https://github.com/opencv/opencv.git "$SOURCE_DIR"
else
    echo "OpenCV source already exists in $SOURCE_DIR. Skipping clone."
fi

cd "$SOURCE_DIR"
echo "Checking out version $CHECKOUT_TAG..."
git checkout tags/$CHECKOUT_TAG

# 3. Build it
echo "Building (this may take a minute)..."

if [ ! -d "build" ]; then
    mkdir build
fi

cd build

# aarch64
if [ ! -d "aarch64" ]; then
    mkdir aarch64
fi
cd ./aarch64
cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
-DBUILD_SAMPLES=OFF \
-DCMAKE_BUILD_TYPE=Release \
-Dprotobuf_BUILD_TESTS=OFF \
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
-DANDROID_ABI=arm64-v8a \
-DANDROID_NDK=${NDK} \
-DANDROID_PLATFORM=android-26 \
-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a  \
-DCMAKE_ANDROID_NDK=${NDK} \
-DBUILD_opencv_java=OFF \
-DBUILD_ANDROID_PROJECTS=OFF \
-DBUILD_ANDROID_EXAMPLES=OFF \
-DCMAKE_CXX_FLAGS="-llog"
make -j32
cmake --install . --prefix ${INSTALL_DIR}/arm64-v8a
cd ../

# # x86_64
# mkdir x86_64
# cd ./x86_64
# cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
# -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
# -DBUILD_SAMPLES=OFF \
# -Dprotobuf_BUILD_TESTS=OFF \
# -DCMAKE_BUILD_TYPE=Release \
# -DCMAKE_SYSTEM_NAME=Android \
# -DCMAKE_SYSTEM_PROCESSOR=x86_64 \
# -DANDROID_ABI=x86_64 \
# -DANDROID_NDK=${NDK} \
# -DANDROID_PLATFORM=android-26 \
# -DCMAKE_ANDROID_ARCH_ABI=x86_64  \
# -DCMAKE_ANDROID_NDK=${NDK} \
# -DCMAKE_CXX_FLAGS="-llog"
# make -j32
# cmake --install . --prefix ${INSTALL_DIR}/x86_64

# x86
# mkdir x86
# cd ./x86
# cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
# -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
# -DBUILD_SAMPLES=OFF \
# -Dprotobuf_BUILD_TESTS=OFF \
# -DCMAKE_SYSTEM_NAME=Android \
# -DCMAKE_BUILD_TYPE=Release \
# -DCMAKE_SYSTEM_PROCESSOR=x86 \
# -DANDROID_ABI=x86 \
# -DANDROID_NDK=${NDK} \
# -DANDROID_PLATFORM=android-26 \
# -DCMAKE_CXX_FLAGS="-llog" \
# -Dprotobuf_BUILD_TESTS=OFF
# make -j32
# cmake --install . --prefix ${INSTALL_DIR}/x86
# cd ../

# rm -rf $SOURCE_DIR

echo "------------------"
echo "COMPLETED"
echo "------------------"