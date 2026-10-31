#!/bin/bash
# Converts resources/yolo11n.onnx to the ncnn files the app loads.
set -e

PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null)
TEMP_DIR=$(mktemp -d)
python3 -m venv "$TEMP_DIR/venv"
"$TEMP_DIR/venv/bin/pip" install pnnx

cp "$PROJECT_DIR/resources/yolo11n.onnx" "$TEMP_DIR/"
cd "$TEMP_DIR"
"$TEMP_DIR/venv/bin/pnnx" yolo11n.onnx "inputshape=[1,3,320,320]" fp16=0
cp yolo11n.ncnn.param yolo11n.ncnn.bin "$PROJECT_DIR/android/app/src/main/assets/"
rm -rf "$TEMP_DIR"
