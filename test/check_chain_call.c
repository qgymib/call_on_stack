#include <assert.h>
#include <stdlib.h>
#include <stdint.h>
#include <setjmp.h>
#include "call_on_stack.h"

static size_t stack_size = 10240;
static void* buffer1 = NULL;
static void* buffer2 = NULL;

typedef struct check_chain_pos
{
    void* pos1;
    void* pos2;
}check_chain_pos_t;

static void _callback_2(void* arg)
{
    check_chain_pos_t* pos = arg;
    int var;
    pos->pos2 = &var;
}

static void _callback_1(void* arg)
{
    check_chain_pos_t* pos = arg;
    int var;

    pos->pos1 = &var;
    call_on_stack(buffer2, stack_size, _callback_2, arg);
}

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;

    
    buffer1 = malloc(stack_size);
    buffer2 = malloc(stack_size);

    check_chain_pos_t pos = { NULL, NULL };
    call_on_stack(buffer1, stack_size, _callback_1, &pos);

    assert(pos.pos1 > buffer1 && pos.pos1 < buffer1 + stack_size);
    assert(pos.pos2 > buffer2 && pos.pos2 < buffer2 + stack_size);

    free(buffer1); buffer1 = NULL;
    free(buffer2); buffer2 = NULL;
    return 0;
}
