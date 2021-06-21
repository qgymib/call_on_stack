#include <assert.h>
#include <setjmp.h>
#include <stdint.h>
#include "call_on_stack.h"

#define ALIGN_SIZE(size, align) \
    (((uintptr_t)(size) + ((uintptr_t)(align) - 1)) & ~((uintptr_t)(align) - 1))

#define STACK_ALIGN_SIZE (sizeof(void*) * 2)

#define JMP_POINT(stack, size)  \
    ((void*)((char*)ALIGN_SIZE((char*)stack + size - sizeof(jmp_buf), STACK_ALIGN_SIZE) - STACK_ALIGN_SIZE))

/**
 * setjmp() and longjmp() may check caller's stack for security purpose.
 *
 * For example, on new version of glibc, longjmp() check jump destination to
 * see whether it is a valid thread stack. If check fails, crash can be triggered,
 * and you can see something like `longjmp causes uninitialized stack frame` in
 * backtrace.
 *
 * In most case it is ok, but it do cause problem if user chain switch stack,
 * beacuse the first call is always valid as it on thread stack, but the second
 * call is on user provide stack, which cannot bypass stack check in longjmp().
 *
 * To avoid that, we may need private implementation of setjmp() and longjmp().
 */
#if defined(_WIN64)
    int call_on_stack__asm_setjmp(jmp_buf env);
#   define call_on_stack__asm_longjmp  longjmp
#elif defined(_WIN32)
#   define call_on_stack__asm_setjmp   setjmp
#   define call_on_stack__asm_longjmp  longjmp
#elif defined(__i386__) || defined(__x86_64__)
    int call_on_stack__asm_setjmp(jmp_buf);
    void call_on_stack__asm_longjmp(jmp_buf, int);
#else
#   define call_on_stack__asm_setjmp   _setjmp
#   define call_on_stack__asm_longjmp  _longjmp
#endif

/**
 * @brief Call `func(arg)` in stack and jump back to `orig`
 * @param[in] orig      Jumpback address
 * @param[in] longjmp   Jumpback function
 * @param[in] baseaddr  Stack base addr
 * @param[in] func      User defined function
 * @param[in] arg       User defined argument
 */
void call_on_stack__asm(jmp_buf orig, void (*longjmp)(jmp_buf, int),
    void (*func)(void* arg), void* arg);

void call_on_stack(void* stack, size_t size, void (*func)(void* arg), void* arg)
{
    /* Save registers */
    if (call_on_stack__asm_setjmp(JMP_POINT(stack, size)) != 0)
    {
        return;
    }

    /* Switch stack and call function */
    call_on_stack__asm(JMP_POINT(stack, size), call_on_stack__asm_longjmp, func, arg);
}
