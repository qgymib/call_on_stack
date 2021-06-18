#include <assert.h>
#include <setjmp.h>
#include <stdint.h>
#include "call_on_stack.h"

#define ALIGN_SIZE(size, align)	\
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
void call_on_stack_asm(jmp_buf orig, void (*longjmp)(jmp_buf, int),
    void* baseaddr, void (*func)(void* arg), void* arg);

void call_on_stack(void* stack, size_t size, void (*func)(void* arg), void* arg)
{
    assert(size > STACK_ALIGN_SIZE * 2);

    /* Save registers */
    jmp_buf buf;
    if (setjmp(buf) != 0)
    {
        return;
    }

    /**
     * Calculate stack base address
     * The stack address must align to ensure meet PCS requirements
     */
    void* base_addr = (char*)stack + size;
    void* align_addr = (void*)ALIGN_SIZE(base_addr, STACK_ALIGN_SIZE);
    if (base_addr != align_addr)
    {
        base_addr = align_addr - STACK_ALIGN_SIZE;
    }

    /* Switch stack and call function */
    call_on_stack_asm(buf, longjmp, base_addr, func, arg);
}
