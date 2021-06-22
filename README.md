# call_on_stack

![CMake](https://github.com/qgymib/call_on_stack/actions/workflows/cmake.yml/badge.svg)
![CodeQL](https://github.com/qgymib/call_on_stack/actions/workflows/codeql-analysis.yml/badge.svg)

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



## Limit

You cannot use `setjmp()`/`longjmp()` in the callback, because `setjmp()` and `longjmp()` may check caller's stack for security purpose.

On windows, the default implementation of `longjmp()` enable `SEH`, which is incompatible with user provided stack. Checkout [this post](https://blog.lazym.io/2020/09/21/Unicorn-Devblog-setjmp-longjmp-on-Windows/) for details.

On linux, the glibc version of `longjmp()` check for environment that `setjmp()` provided, that means in most case it is fine to call `longjmp()` in callback. But if you chain-call `call_on_stack()` and try to jump to the first custom stack, you will get your program crashed.

The solution is to implementation your own `setjmp()` and `longjmp()`, which only backup and restore callee-saved registers.

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
