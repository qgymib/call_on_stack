cmake_minimum_required(VERSION 3.2)
project(call_on_stack C)

add_library(${PROJECT_NAME}
    src/call_on_stack.c)

if (CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
    enable_language(ASM)
    set_property(SOURCE src/call_on_stack-clang-gcc.s
        APPEND PROPERTY COMPILE_OPTIONS "-x" "assembler-with-cpp")
    target_sources(${PROJECT_NAME} PRIVATE src/call_on_stack-clang-gcc.s)
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Werror)
elseif (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    enable_language(ASM_MASM)
    if (CMAKE_SIZEOF_VOID_P EQUAL 4)
        target_sources(${PROJECT_NAME} PRIVATE src/call_on_stack-msvc-i386.asm)
        set_property(SOURCE src/call_on_stack-msvc-i386.asm
            APPEND PROPERTY COMPILE_OPTIONS "/safeseh")
    else ()
        target_sources(${PROJECT_NAME} PRIVATE src/call_on_stack-msvc-x86_64.asm)
    endif ()
    set_property(SOURCE src/call_on_stack.c
        APPEND PROPERTY COMPILE_OPTIONS "/W4" "/WX")
endif ()

target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src)

# build test
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    include(CTest)
endif()
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME AND BUILD_TESTING)
    add_subdirectory(test)
endif()
