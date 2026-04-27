#!/bin/bash
set -e

PROJECT_DIR=$PWD
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$PROJECT_DIR/.lib_pack/apple/protobuf/swift-protobuf"
SOURCE_DIR="$SCRIPT_DIR/.swift-protobuf"

echo "SCRIPT_DIR=$SCRIPT_DIR"
echo "INSTALL_DIR=$INSTALL_DIR"

mkdir -p "${INSTALL_DIR}"

echo "Cloning swift-protobuf..."
git clone https://github.com/apple/swift-protobuf.git "$SOURCE_DIR"

cd "$SOURCE_DIR"
echo "Checking out version 1.20.0..."
git checkout tags/1.20.0

# 3. Build it
echo "Building (this may take a minute)..."
swift build -c release

cp .build/release/protoc-gen-swift $INSTALL_DIR
cp .build/release/protoc-gen-swift-tool $INSTALL_DIR

rm -rf $SOURCE_DIR