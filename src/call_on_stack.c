#include <assert.h>
#include <setjmp.h>
#include <stdint.h>
#include "call_on_stack.h"

#define ALIGN_SIZE(size, align) \
    (((uintptr_t)(size) + ((uintptr_t)(align) - 1)) & ~((uintptr_t)(align) - 1))

#define STACK_ALIGN_SIZE (sizeof(void*) * 2)

/**
 * @brief Call `func(arg)` in stack and jump back to `orig`
 * @param[in] orig      Jumpback address
 * @param[in] longjmp   Jumpback function
 * @param[in] baseaddr  Stack base addr
 * @param[in] func      User defined function
 * @param[in] arg       User defined argument
 */
void call_on_stack__asm(void* stack, void (*func)(void* arg), void* arg);

void call_on_stack(void* stack, size_t size, void (*func)(void* arg), void* arg)
{
    void* stack_addr = (void*)((uintptr_t)stack + size);
    void* align_addr = (void*)ALIGN_SIZE(stack_addr, STACK_ALIGN_SIZE);
    if (stack_addr != align_addr)
    {
        stack_addr = (void*)((uintptr_t)align_addr - STACK_ALIGN_SIZE);
    }

    /* Switch stack and call function */
    call_on_stack__asm(stack_addr, func, arg);
}
