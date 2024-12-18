cmake_minimum_required(VERSION 3.22)

message(STATUS "Using CMake ${CMAKE_VERSION}")

# Require out-of-source builds
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)

if (EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in the source directory. Please use a build subdirectory.")
endif()

# Add paths to modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")

# Turn on link time optimization for everything
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)

# Output compile commands to compile_commands.json (for debugging CMake issues)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Build universal lib on macOS
# Note that CMAKE_OSX_ARCHITECTURES must be set before project().
if (APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "")
endif()

# Main project information
project(gdexample LANGUAGES CXX VERSION 0.1.0)

string(TOLOWER "${CMAKE_SYSTEM_NAME}" CMAKE_SYSTEM_NAME_LOWER)
string(CONCAT LIBNAME "${PROJECT_NAME}.${CMAKE_SYSTEM_NAME_LOWER}.template_debug.x86_64")
# Create our library
add_library(${LIBNAME} SHARED)

target_compile_features(${LIBNAME} PRIVATE cxx_std_17)

# LIB_ARCH is the architecture being built. It is set to the build system's architecture.
# For macOS, we build a universal library (both arm64 and x86_64).
set(LIB_ARCH ${CMAKE_SYSTEM_PROCESSOR})
if (APPLE)
    set(LIB_ARCH "universal")
endif()

# LIB_DIR is where the actual library ends up. This is used in both the build directory and the
# install directory and needs to be consistent with the paths in the gdextension file.
#   e.g. linux.release.x86_64 = "lib/Linux-x86_64/libGDExtensionTemplate.so"
set(LIB_DIR "lib/${CMAKE_SYSTEM_NAME}-${LIB_ARCH}")

message(STATUS "Building ${LIBNAME} for ${LIB_ARCH} on ${CMAKE_SYSTEM_NAME}")

# BUILD_OUTPUT_DIR is where we put the resulting library (in the build directory)
set(BUILD_OUTPUT_DIR "${PROJECT_BINARY_DIR}/${LIBNAME}/")

set_target_properties(${LIBNAME}
    PROPERTIES
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN true
        RUNTIME_OUTPUT_DIRECTORY "${BUILD_OUTPUT_DIR}/${LIB_DIR}"
        LIBRARY_OUTPUT_DIRECTORY "${BUILD_OUTPUT_DIR}/${LIB_DIR}"
)

if(NOT DEFINED CMAKE_DEBUG_POSTFIX)
    set_target_properties(${LIBNAME}
        PROPERTIES
            DEBUG_POSTFIX "-d"
    )
endif()

# Copy over additional files from the support_files directory
# add_custom_command(
#     TARGET ${LIBNAME} POST_BUILD
#     COMMAND ${CMAKE_COMMAND} -E copy_directory
#             "${CMAKE_SOURCE_DIR}/support_files"
#             ${BUILD_OUTPUT_DIR}
# )

add_subdirectory(src)

# Install library, extension file, and support files in ${CMAKE_INSTALL_PREFIX}/${LIBNAME}
set(INSTALL_DIR "${CMAKE_BINARY_DIR}/${LIBNAME}/")

message(STATUS "Install directory: ${INSTALL_DIR}")

install(TARGETS ${LIBNAME}
    LIBRARY
        DESTINATION ${INSTALL_DIR}/${LIB_DIR}
    RUNTIME
        DESTINATION ${INSTALL_DIR}/${LIB_DIR}
)

# Copy over support files
# install(DIRECTORY "${CMAKE_SOURCE_DIR}/support_files/"
#     DESTINATION ${INSTALL_DIR}
#     PATTERN ".*" EXCLUDE
# )

# # Warnings
# include(CompilerWarnings)

# # Create and include version info file from git
# include(GitVersionInfo)

# # ccache
# # Turns on ccache if found
# include(ccache)

# # Formatting
# # Adds a custom target to format all the code at once
# include(ClangFormat)

# godot-cpp
# From here: https://github.com/godotengine/godot-cpp
if (NOT EXISTS "${CMAKE_SOURCE_DIR}/godot-cpp/Makefile")
    message(
        FATAL_ERROR
            "[${LIBNAME}] The godot-cpp submodule was not downloaded. Please update submodules: git submodule update --init --recursive."
    )
endif()

set(GODOT_CPP_SYSTEM_HEADERS ON CACHE BOOL "" FORCE)

add_subdirectory(godot-cpp)

set_target_properties(godot-cpp
    PROPERTIES
        CXX_VISIBILITY_PRESET hidden    # visibility needs to be the same as the main library
)

target_link_libraries(${LIBNAME} PRIVATE godot-cpp)
