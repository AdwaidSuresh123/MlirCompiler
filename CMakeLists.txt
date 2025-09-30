cmake_minimum_required(VERSION 3.20)
project(mlir-compiler LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ standard to conform to")
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find MLIR (this will also find LLVM)
find_package(MLIR REQUIRED CONFIG)

message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

# Add MLIR and LLVM CMake modules
list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

include(TableGen)
include(AddLLVM)
include(AddMLIR)
include(HandleLLVMOptions)

# Include directories
include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})
include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_BINARY_DIR}/include)

# Link directories (helps with lib resolution)
link_directories(${LLVM_BUILD_LIBRARY_DIR})

# Add definitions
add_definitions(${LLVM_DEFINITIONS})

# Build subdirectories
add_subdirectory(include)
add_subdirectory(lib)
add_subdirectory(tools)
