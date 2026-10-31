#!/bin/bash
set -e

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z $PROJECT_DIR ]; then
    PROJECT_DIR=$PWD
fi
VERSION="20261020"
ARCHIVE="ncnn-$VERSION-android-shared"
INSTALL_DIR="$PROJECT_DIR/.lib_pack/android/ncnn"
TEMP_DIR=$(mktemp -d)

curl -fL -o "$TEMP_DIR/ncnn.zip" "https://github.com/Tencent/ncnn/releases/download/$VERSION/$ARCHIVE.zip"
unzip -q "$TEMP_DIR/ncnn.zip" -d "$TEMP_DIR"

for ARCH in arm64-v8a x86_64; do
    mkdir -p "$INSTALL_DIR/$ARCH"
    rm -rf "$INSTALL_DIR/$ARCH/include" "$INSTALL_DIR/$ARCH/lib"
    cp -R "$TEMP_DIR/$ARCHIVE/$ARCH/include" "$TEMP_DIR/$ARCHIVE/$ARCH/lib" "$INSTALL_DIR/$ARCH/"
done
rm -rf "$TEMP_DIR"

echo "------------------"
echo "COMPLETED"
echo "------------------"
