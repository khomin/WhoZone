#!/bin/bash
SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH/../

dart pub global activate protoc_plugin

mkdir -p ./lib/native-api/protobuf/
mkdir -p ./cpp/protobuf/generated
set -x
set -e
.lib_pack/macos/protobuf/protoc  -I=./protobuf --cpp_out=./cpp/protobuf/generated --dart_out=./lib/native-api/protobuf  ./protobuf/app.proto