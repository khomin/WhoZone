cmake_minimum_required(VERSION 3.5)

set(PROJECT WhoZone)
set(BUILD_CONFIG_CXX_TESTS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(${PROJECT} LANGUAGES CXX)

add_executable(${PROJECT}
    ../main.cpp
    ../detector.cpp
    ../detector.h
    ../frame_source.cpp
    ../frame_source.h
    ../detection_work_item.h
    ../safe_queue.h
    ./protobuf/generated/app.pb.cc
    ./protobuf/generated/app.pb.h

)

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/../cpp/
    ${CMAKE_SOURCE_DIR}/../.lib_pack/opencv/include/opencv4
)

file(GLOB OPENCV_LIBRARIES
    ${CMAKE_SOURCE_DIR}/../.lib_pack/opencv/lib/*.so
)

file(GLOB GRPC_AND_DEPS_LIBRARIES
    ${CMAKE_SOURCE_DIR}/../.lib_pack/opencv/lib/*.dylib
)


target_link_libraries(${PROJECT} PUBLIC
    ${OPENCV_LIBRARIES}
    ${GRPC_AND_DEPS_LIBRARIES}
)