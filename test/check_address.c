#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include "call_on_stack.h"

static void _callback(void* arg)
{
    void** addr = (void**)arg;

    int var;
    *addr = &var;
}

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;

    /* use valgrind to detect memory error */
    const size_t buffer_size = 1024;
    char* buffer = malloc(buffer_size);

    /* get variable address in stack */
    void* addr = NULL;
    call_on_stack(buffer, buffer_size, _callback, &addr);

    /* if success, the variable address must in between buffer */
    assert((uintptr_t)addr > (uintptr_t)buffer);
    assert((uintptr_t)addr < (uintptr_t)buffer + buffer_size);

    free(buffer);
    return 0;
}
