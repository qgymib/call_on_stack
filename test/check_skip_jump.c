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

typedef struct test_ctx
{
    jmp_buf buf;
    int     val;
}test_ctx_t;

static size_t stack_size = 10240;
static void* buffer1 = NULL;
static void* buffer2 = NULL;

static void _callback_2(void* arg)
{
    test_ctx_t* ctx = arg;

    ctx->val += 2;
    call_on_stack__asm_longjmp(ctx->buf, 1);
}

static void _callback_1(void* arg)
{
    test_ctx_t* ctx = arg;

    ctx->val += 1;
    call_on_stack(buffer2, stack_size, _callback_2, arg);
}

int main(int argc, char* argv[])
{
    (void)argc; (void)argv;

    buffer1 = malloc(stack_size);
    buffer2 = malloc(stack_size);

    test_ctx_t ctx;
    ctx.val = 0;
    if (call_on_stack__asm_setjmp(ctx.buf) != 0)
    {
        goto fin;
    }

    call_on_stack(buffer1, stack_size, _callback_1, &ctx);

    abort();    /* should not reach here */

fin:
    free(buffer1); buffer1 = NULL;
    free(buffer2); buffer2 = NULL;
    return 0;
}

