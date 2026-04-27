cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(${PROJECT} LANGUAGES CXX)

add_executable(${PROJECT}
    ./main.cpp
    ./detector.cpp
    ./detector.h
    ./frame_source.cpp
    ./frame_source.h
    ./detection_work_item.h
    ./safe_queue.h
    ./protobuf/generated/app.pb.cc
    ./protobuf/generated/app.pb.h
)

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../cpp/
    /Users/panic/Documents/PROJECTS/WhoZone/.lib_pack/android/opencv/arm64-v8a/sdk/native/jni/include
    #${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/include/opencv4
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/include/
)

file(GLOB LIBRARIES
    /Users/panic/Documents/PROJECTS/WhoZone/.lib_pack/android/opencv/arm64-v8a/sdk/native/staticlibs/arm64-v8a/*.so
#    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/opencv/lib/*.so
    ${CMAKE_SOURCE_DIR}/../.lib_pack/android/protobuf/${CMAKE_ANDROID_ARCH_ABI}/lib/libprotobuf.a
)

target_link_libraries(${PROJECT} PUBLIC
    ${LIBRARIES}
)