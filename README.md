# 🐶 WhoZone

# to yolo11n.onnx
- cd ./resources/ultralytics
- python3 -m venv yolo_env
- source ./yolo_env/bin/activate
- pip install --upgrade pip
- pip install ultralytics
- yolo export model=yolo11n.pt format=onnx imgsz=320 dynamic=False opset=12
copy the file to assets
- cp /android/app/src/main/assets

#### To generate protobuf files
- dart pub global activate protoc_plugin
- ./scripts/gen_proto.sh

## 📋 Prerequisites
...

### Android

You need to build opencv manually using cmake or build_opencv.sh.

    # go to where opencv
    cd ~/Documents/PROJECTS/opencv
    # create build dir & go
    mkdir build_opencv
    cd build_opencv

    ./scripts/build_opencv.sh # adjust path to this project

    # for linux
    export NDK=~/Android/Sdk/ndk/26.1.10909125/ # YOUR SDK VERSION
    # for macos
    export NDK=~/Android/Sdk/ndk/26.1.10909125/  # YOUR SDK VERSION
    
    # toolchain
    # for linux
    export CMAKE_SYSROOT=${NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/
    # for macos
    export CMAKE_SYSROOT=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/
    #
    export TOOLCHAIN=${NDK}/build/cmake/android.toolchain.cmake
    export INSTALL_PATH_PREFIX=~/Documents/PROJECTS/dog-detector/lib_pack/opencv  # YOUR DIRECTORY
    # build
    chmod +x ./scripts/build_opencv.sh
    ./scripts/build_opencv.sh

so it will look like: 

    ./lib_pack/opencv/x86_64/..
    ./lib_pack/opencv/arm64/..
    ./lib_pack/opencv/x86/..

The library is loaded in App.kt:

    companion object {
        private const val TAG = "App"
        init {
            try {
                System.loadLibrary("opencv_cpp")
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            }
        }
    }