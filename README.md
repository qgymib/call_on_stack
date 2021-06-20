# call_on_stack

Call a function on an independent stack.

## How to use

It only has one interface:

```
/**
 * @brief Call function in stack
 * @param[in] stack Stack address
 * @param[in] size  Stack size
 * @param[in] func  The function to be called
 * @param[in] arg   User defined argument pass to `func`
 */
void call_on_stack(void* stack, size_t size, void (*func)(void* arg), void* arg);
```

Check out this example:

```
#include "call_on_stack.h"
static char buffer[24 * 1024];
void* p = malloc(1);
call_on_stack(buffer, sizeof(buffer), free, p);
```

This code malloc a block of memory in one stack, and free it in another stack.

## Support architecture

Currently support following architectures:

|         | clang | gcc  | msvc |
| ------- | ----- | ---- | ---- |
| i386    | YES   | YES  | YES  |
| x86_64  | YES   | YES  | YES  |
| armv7   | YES   | YES  |      |
| aarch64 | YES   | YES  |      |


## How it works

The details are highly architecture related, but generally need three stages:
1. Backup callee-saved registers (including SP)
2. Set SP to the address of the stack, build argument and call your function
3. Restore registers
