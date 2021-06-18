#ifndef __CALL_ON_STACK_H__
#define __CALL_ON_STACK_H__
#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>

/**
 * @brief Call function in stack
 * @param[in] stack Stack address
 * @param[in] size  Stack size
 * @param[in] func  The function to be called
 * @param[in] arg   User defined argument pass to `func`
 */
void call_on_stack(void* stack, size_t size, void (*func)(void* arg), void* arg);

#ifdef __cplusplus
}
#endif
#endif
