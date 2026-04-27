#!/bin/bash
set -e

PROJECT_DIR=$PWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$PROJECT_DIR/.lib_pack/apple/protobuf"
SOURCE_DIR="$SCRIPT_DIR/.protobuf_macos"
CHECKOUT_BRANCH_TAG="v4.30.0"

echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "INSTALL_DIR=$INSTALL_DIR"

if [ ! -d "$SOURCE_DIR/.git" ]; then
    echo "Cloning protobuf..."
    git clone https://github.com/protocolbuffers/protobuf.git --recurse-submodule "$SOURCE_DIR"
else
    echo "Protobuf source already exists in $SOURCE_DIR. Skipping clone."
fi

cd "$SOURCE_DIR"
echo "Checking out version $CHECKOUT_BRANCH_TAG..."
git checkout tags/$CHECKOUT_BRANCH_TAG

git submodule update --init --recursive

# 3. Build it
echo "Building (this may take a minute)..."

if [ ! -d ".build" ]; then
    mkdir .build
fi

cd .build

# macos
if [ ! -d "macos_universal" ]; then
    mkdir macos_universal
fi
cd ./macos_universal
cmake ../../ \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make -j32
cmake --install . --prefix ${INSTALL_DIR}/macos_universal
cd ../

# rm -rf $SOURCE_DIR

echo "------------------"
echo "COMPLETED"
echo "------------------"