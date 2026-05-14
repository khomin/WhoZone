cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(CMAKE_CXX_STANDARD 20)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(${PROJECT} LANGUAGES CXX C)

# find flutter sdk location
if(NOT DEFINED FLUTTER_SDK_PATH)
    if(IS_DIRECTORY "$ENV{FLUTTER_ROOT}")
        set(FLUTTER_SDK_PATH "$ENV{FLUTTER_ROOT}")
    else()
        # Fallback to your PATH search, but use CMake's find_program
        find_program(DART_EXE dart)
        if(DART_EXE)
            get_filename_component(FLUTTER_BIN_DIR "${DART_EXE}" DIRECTORY)
            set(FLUTTER_SDK_PATH "${FLUTTER_BIN_DIR}")
        endif()
    endif()
    message(STATUS "FLUTTER_SDK_PATH is ${FLUTTER_SDK_PATH}")
endif()

set(DART_API_DL_C "${FLUTTER_SDK_PATH}/bin/cache/dart-sdk/include/dart_api_dl.c")
set(DART_INCLUDE_DIR "${FLUTTER_SDK_PATH}/bin/cache/dart-sdk/include")
if(NOT EXISTS "${DART_API_DL_C}")
    message(STATUS "Dart API source: Flutter SDK (${DART_API_DL_C})")
endif()

set(OPENCV_LIB_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/${CMAKE_ANDROID_ARCH_ABI}/sdk/native/libs/${CMAKE_ANDROID_ARCH_ABI})
set(OPENCV_HEADER_DIR ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/${CMAKE_ANDROID_ARCH_ABI}/sdk/native/jni/include)

add_subdirectory(submodule/libyuv)

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

add_library(${PROJECT} SHARED
    ${DART_API_DL_C}
    ./log.h
    ./jni_bridge.cpp
    ./api_lib.cpp
    ./api_lib.h
    ./dart_lib.cpp
    ./dart_lib.h
    ./detector.cpp
    ./detector.h
    ./detection_item.h
    ./safe_queue.h
    ./protobuf/generated/app.pb.cc
    ./protobuf/generated/app.pb.h
)

target_include_directories(${PROJECT} PUBLIC
    .
    ${DART_INCLUDE_DIR}
    ${OPENCV_HEADER_DIR}
    ${CMAKE_SOURCE_DIR}/../cpp/
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/include/
    ./protobuf/generated
    ./submodule/libyuv/include
    ./submodule/thread-pool/include
)

target_link_libraries(${PROJECT} PUBLIC
    -Wl,--start-group
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libprotobuf.a
    ${PROTO_ABSL_LIBS}
    -Wl,--end-group
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