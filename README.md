# 🐶 WhoZone
![Build Status](https://img.shields.io/github/actions/workflow/status/khomin/WhoZone/android.yml)
![License](https://img.shields.io/github/license/khomin/WhoZone)

This app is currently under active development.

It serves as a personal playground for exploring high-performance mobile architecture and integrating advanced ML models.

Dection events are sent from cpp via protobuf -> FFI -> dart

Boxes are drawn in flutter using normalized coordinates, the goal is 60 FPS

### Previews
![1](/resources/demo.gif)

# How to start
```bash
# clone
git clone https://github.com/khomin/WhoZone.git --recurse-submodule

# build protobuf
./scripts/build_protobuf.sh android

# build opencv
./scripts/build_opencv.sh android

# next we need to generate yolo11n.onnx
cd ./resources/ultralytics
python3 -m venv yolo_env
source ./yolo_env/bin/activate
pip install --upgrade pip
pip install ultralytics
yolo export model=yolo11n.pt format=onnx imgsz=320 opset=17

# copy yolo11n.pt file to assets
cp yolo11n.pt ./android/app/src/main/assets

# now run flutter or launch it from vs code
flutter run --debug
```

### How to generate protobuf files
```bash
dart pub global activate protoc_plugin
./scripts/gen_proto.sh
```

## 📋 Prerequisites
Macos or Linux, Android studio with NDK