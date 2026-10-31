#!/bin/bash
set -x
set -e

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH/../

dart pub global activate protoc_plugin

export PATH=$PATH:.lib_pack/apple/protobuf/macos_universal/bin/

mkdir -p ./lib/core/native-api/protobuf/
mkdir -p ./cpp/protobuf/generated
protoc  -I=./protobuf --cpp_out=./cpp/protobuf/generated --dart_out=./lib/core/native-api/protobuf  ./protobuf/app.proto