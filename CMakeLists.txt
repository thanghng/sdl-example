cmake_minimum_required(VERSION 3.15)
project(SDL2Example)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/modules/")

find_package(SDL2 REQUIRED)
include_directories(SDL2Example ${SDL2_INCLUDE_DIR})

add_executable(SDL2Example main.cpp)

if(MINGW)
    target_link_libraries(SDL2Example SDL2::Main ${MINGW32_LIBRARY})
else()
    target_link_libraries(SDL2Example SDL2::Main)
endif()
