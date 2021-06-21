#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include <setjmp.h>
#include "call_on_stack.h"

#if defined(_WIN64)
    int call_on_stack__asm_setjmp(jmp_buf env);
#   define call_on_stack__asm_longjmp  longjmp
#else
#   define call_on_stack__asm_setjmp   setjmp
#   define call_on_stack__asm_longjmp  longjmp
#endif

static void* buffer = NULL;

static void _callback(void* arg)
{
    call_on_stack__asm_longjmp(arg, 1);
}

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;

    /* use valgrind to detect memory error */
    const size_t buffer_size = 24 * 1024;
    buffer = malloc(buffer_size);

    jmp_buf buf;
    if (call_on_stack__asm_setjmp(buf) != 0)
    {
        goto fin;
    }

    call_on_stack(buffer, buffer_size, _callback, buf);

    /* should not reach here */
    abort();

fin:
    free(buffer);
    return 0;
}
