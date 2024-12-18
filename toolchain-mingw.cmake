set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64) # Or i686 for 32-bit

set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc) # Or i686-w64-mingw32-gcc
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++) # Or i686-w64-mingw32-g++

set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32) # Or /usr/i686-w64-mingw32

# cross-compile windows binary on other platforms
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dll")
