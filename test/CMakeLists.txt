cmake_minimum_required(VERSION 3.2)
project(call_in_stack_test)

get_target_property(TEST_PROJECT_INCLUDES call_on_stack INCLUDE_DIRECTORIES)

function(CUSTOM_ADD_TEST name)
	add_executable(${name} ${name}.c)
	target_link_libraries(${name} PRIVATE call_on_stack)
	if (CMAKE_C_COMPILER_ID STREQUAL "MSVC")
		target_compile_options(${name} PRIVATE /W4 /WX)
	else ()
		target_compile_options(${name} PRIVATE -Wall -Wextra -Werror)
	endif ()
	target_include_directories(${name}
		PRIVATE
			${TEST_PROJECT_INCLUDES}
			${CMAKE_CURRENT_SOURCE_DIR})
	add_test(${name} ${name})
endfunction()

CUSTOM_ADD_TEST(check_address)
CUSTOM_ADD_TEST(check_setjmp)
