cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# add_definitions(-DPROTOBUF_NO_THREADLOCAL=1)

project(${PROJECT} LANGUAGES CXX)

add_library(${PROJECT} SHARED
    ./jni_bridge.cpp
    ./detector.cpp
    ./detector.h
    ./detection_item.h
    ./safe_queue.h
    ./protobuf/generated/app.pb.cc
    ./protobuf/generated/app.pb.h
)
set(OPENCV_LIB_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/${CMAKE_ANDROID_ARCH_ABI}/sdk/native/libs/${CMAKE_ANDROID_ARCH_ABI})
set(OPENCV_HEADER_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/${CMAKE_ANDROID_ARCH_ABI}/sdk/native/jni/include)

add_subdirectory(submodule/libyuv)

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../cpp/
    ${OPENCV_HEADER_DIR}
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/include/
    ./submodule/libyuv/include
#    ./submodule/thread-pool/include
)

file(GLOB PROTO_ABSL_LIBS
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libabsl_*.a
)

set(OPENCV_LIBS
    ${OPENCV_LIB_DIR}/libopencv_calib3d.so
    ${OPENCV_LIB_DIR}/libopencv_core.so
    ${OPENCV_LIB_DIR}/libopencv_dnn.so
    ${OPENCV_LIB_DIR}/libopencv_features2d.so
    ${OPENCV_LIB_DIR}/libopencv_flann.so
    ${OPENCV_LIB_DIR}/libopencv_gapi.so
    ${OPENCV_LIB_DIR}/libopencv_highgui.so
    ${OPENCV_LIB_DIR}/libopencv_imgcodecs.so
    ${OPENCV_LIB_DIR}/libopencv_imgproc.so
    ${OPENCV_LIB_DIR}/libopencv_ml.so
    ${OPENCV_LIB_DIR}/libopencv_objdetect.so
    ${OPENCV_LIB_DIR}/libopencv_photo.so
    ${OPENCV_LIB_DIR}/libopencv_stitching.so
    ${OPENCV_LIB_DIR}/libopencv_video.so
    ${OPENCV_LIB_DIR}/libopencv_videoio.so
)

target_link_libraries(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libprotobuf.a
    ${PROTO_ABSL_LIBS}
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libutf8_validity.a
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libutf8_range.a
    ${OPENCV_LIBS}
    mediandk
    jnigraphics
    nativewindow
    android
    yuv
    z
    log
)