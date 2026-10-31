## WhoZone

This app serves as a playground for exploring YOLO11 models with practical application<br>
<img src="resources/screenshot.jpg" width="200" />
<img src="resources/diagram.png"/>

## Features
* **Real-Time Object Detection**: YOLO11 inference on [ncnn](https://github.com/Tencent/ncnn), running on the big CPU cores.
* **Native Surface Integration**: Utilizes `AImageReader` via JNI to achieve zero-copy frame ingestion.
* **Object Tracking**: Implements **Kalman filtering** to maintain bounding box consistency and smooth motion across camera frames.
* **Event Bus**: bidirectional communication between the native C++ engine and Flutter UI, serialized via **Protocol Buffers** and FFI.
* **UI**: Adaptive bounding box.

## How to start
```bash
git clone https://github.com/khomin/WhoZone.git --recurse-submodule

./scripts/build_protobuf.sh android

./scripts/build_opencv.sh android

./scripts/build_ncnn.sh

flutter run --debug
```

## In case you want a model from scratch
```bash
cd ./resources
python3 -m venv yolo_env
source ./yolo_env/bin/activate
pip install --upgrade pip
pip install ultralytics
yolo export model=yolo11n.pt format=onnx imgsz=320 opset=17
cd ..
./scripts/convert_model.sh
```

## How to generate protobuf files
```bash
./scripts/gen_proto.sh
```

## How to update DI
```bash
dart run build_runner build
```

<a href="https://play.google.com/store/apps/details?id=com.who.zone">
  <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60">
</a>

## 📋 Prerequisites
Macos or Linux, Android studio with NDK