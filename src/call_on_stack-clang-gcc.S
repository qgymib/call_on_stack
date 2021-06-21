
#if defined(__i386__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    mov     4(%esp),    %esi        /* save jmpbuf */
    mov     8(%esp),    %edi        /* save longjmp() function pointer */
    mov     12(%esp),   %eax        /* get user function */
    mov     16(%esp),   %ecx        /* get user argument */
    mov     %esi,       %esp        /* set stack pointer */
    sub     $4,         %esp
    push    %ecx                    /* build argument:arg */
    call    *%eax                   /* func(arg) */
    add     $4,         %esp
    push    $1                      /* build argument:1 */
    push    %esi                    /* build argument:jmp_buf */
    call    *%edi

#elif defined(__x86_64__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    mov     %rdi,       %r12        /* save jmp_buf */
    mov     %rsi,       %r13        /* save longjmp() function pointer */
    mov     %rdi,       %rsp        /* set stack pointer */
    sub     $8,         %rsp
    mov     %rcx,       %rdi        /* build argument:arg */
    call    *%rdx                   /* func(arg) */
    mov     %r12,       %rdi        /* build argument:jmp_buf */
    mov     $1,         %rsi        /* build argument:1 */
    call    *%r13                   /* longjmp(jmp_buf, 1) */

#elif defined(__arm__)

.syntax unified
.global call_on_stack__asm
.type call_on_stack__asm,%function
call_on_stack__asm:
    mov     r4,         r0          /* save jmp_buf */
    mov     r5,         r1          /* save longjmp() function pointer */
    mov     sp,         r0          /* set stack pointer */
    sub     sp,         sp, #4
    mov     r0,         r3          /* build argument: arg */
    blx     r2                      /* func(arg) */
    mov     r0,         r4          /* build argument: jmp_buf */
    mov     r1,         #1          /* build argument: 1 */
    bx      r5

#elif defined(__aarch64__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    mov     x19,        x0          /* save jmpbuf */
    mov     x20,        x1          /* save longjmp() function pointer */
    mov     sp,         x0          /* set stack pointer */
    sub     sp,         sp, #8
    mov     x0,         x3          /* build argument: arg */
    blr     x2                      /* func(arg) */
    mov     x0,         x19         /* build argument: jmpbuf */
    mov     x1,         1           /* build argument:  1 */
    br      x20                     /* longjmp(jmpbuf, 1) */

#else
#   error	"unsupport platform"
#endif
