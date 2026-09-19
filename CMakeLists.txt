cmake_minimum_required(VERSION 3.15)
project(ChickenInvaders VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
list(FILTER SOURCES EXCLUDE REGEX "_test_")
list(FILTER SOURCES EXCLUDE REGEX "CMakeCXXCompilerId")

include_directories("${CMAKE_CURRENT_SOURCE_DIR}")

find_package(PkgConfig REQUIRED)
pkg_check_modules(SDL2 REQUIRED sdl2)
pkg_check_modules(SDL2_MIXER REQUIRED SDL2_mixer)
include_directories(${SDL2_INCLUDE_DIRS} ${SDL2_MIXER_INCLUDE_DIRS})

find_package(Boost 1.70 REQUIRED COMPONENTS chrono thread)
include_directories(${Boost_INCLUDE_DIRS})

find_library(TINYXML_LIB tinyxml REQUIRED)
find_package(OpenAL REQUIRED)
find_library(SNDFILE_LIB sndfile REQUIRED)

add_executable(ChickenInvaders ${SOURCES})

target_link_libraries(ChickenInvaders
    ${SDL2_LIBRARIES}
    ${SDL2_MIXER_LIBRARIES}
    Boost::chrono
    Boost::thread
    
    ${TINYXML_LIB}
    ${OPENAL_LIBRARY}
    ${SNDFILE_LIB}
)

target_compile_definitions(ChickenInvaders PRIVATE
    USE_BOOST_CHRONO
    BOOST_SP_DISABLE_THREADS
    TIXML_USE_STL
    CPP11
)

target_compile_options(ChickenInvaders PRIVATE -Wall -Wextra -O3)
