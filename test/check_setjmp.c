#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include <setjmp.h>
#include "call_on_stack.h"

#if defined(_WIN64)

/**
 * @warning This test is not supported on WIN64.
 * 
 * WIN64 longjmp() will do stack unwinding, and there is no standard way to
 * disable it. So this test will always fail on WIN64.
 */
int main(int argc, char* argv[])
{
    (void)argc; (void)argv;
    return 0;
}

#else

static void* buffer = NULL;

static void _callback(void* arg)
{
    longjmp(arg, 1);
}

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;

    /* use valgrind to detect memory error */
    const size_t buffer_size = 24 * 1024;
    buffer = malloc(buffer_size);

    jmp_buf buf;
    if (setjmp(buf) != 0)
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

#endif
