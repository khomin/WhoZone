cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(${PROJECT} LANGUAGES CXX)

add_library(${PROJECT}
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
set(OPENCV_LIB_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/sdk/native/staticlibs/${CMAKE_ANDROID_ARCH_ABI})
set(OPENCV_HEADER_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/sdk/native/jni/include)

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../cpp/
    ${OPENCV_HEADER_DIR}
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/include/
)


file(GLOB LIBRARIES
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/*.a
    ${OPENCV_LIB_DIR}/libopencv_dnn.a
    ${OPENCV_LIB_DIR}/libopencv_objdetect.a
    ${OPENCV_LIB_DIR}/libopencv_imgproc.a
    ${OPENCV_LIB_DIR}/libopencv_core.a
    ${OPENCV_LIB_DIR}/libtegra_hal.a
    ${OPENCV_LIB_DIR}/libippicv.a
    ${OPENCV_LIB_DIR}/libopencv_video.a
)

target_link_libraries(${PROJECT} PUBLIC
    ${LIBRARIES}
)