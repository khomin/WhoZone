cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(${PROJECT} LANGUAGES CXX)

add_library(${PROJECT} SHARED
    ./jni_bridge.cpp
    ./detector.cpp
    ./detector.h
#    ./frame_source.cpp
#    ./frame_source.h
    ./detection_work_item.h
    ./safe_queue.h
    ./protobuf/generated/app.pb.cc
    ./protobuf/generated/app.pb.h
)
set(OPENCV_LIB_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/sdk/native/libs/${CMAKE_ANDROID_ARCH_ABI})
#set(OPENCV_HEADER_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/sdk/native/jni/include)
set(OPENCV_HEADER_DIR /Users/panic/Documents/PROJECTS/WhoZone/.lib_pack/android/opencv/sdk/native/jni/include)
#/Users/panic/Documents/PROJECTS/WhoZone/.lib_pack/android/opencv/sdk/native/staticlibs/arm64-v8a

message("BTEST_OPENCV_LIB_DIR: ${OPENCV_LIB_DIR}")

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../cpp/
    ${OPENCV_HEADER_DIR}
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/include/
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/arm64-v8a/include/
)

file(GLOB LIBRARIES
#    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/*.a
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/*.a
)

#/Users/panic/Documents/PROJECTS/WhoZone/.lib_pack/android/opencv/sdk/native/libs/arm64-v8a/libopencv_dnn.so

set(LIBRARIES ${LIBRARIES}
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
    ${LIBRARIES}
)