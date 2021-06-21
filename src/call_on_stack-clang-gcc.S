
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

.global call_on_stack__asm_setjmp
.type call_on_stack__asm_setjmp,@function
call_on_stack__asm_setjmp:
    mov     4(%esp),    %eax
    mov     %ebx,       (%eax)
    mov     %esi,       4(%eax)
    mov     %edi,       8(%eax)
    mov     %ebp,       12(%eax)
    lea     4(%esp),    %ecx
    mov     %ecx,       16(%eax)
    mov     (%esp),     %ecx
    mov     %ecx,       20(%eax)
    xor     %eax,       %eax
    ret

.global call_on_stack__asm_longjmp
.type call_on_stack__asm_longjmp,@function
call_on_stack__asm_longjmp:
    mov     4(%esp),    %edx
    mov     8(%esp),    %eax
    cmp     $1,         %eax
    adc     $0,         %al
    mov     (%edx),     %ebx
    mov     4(%edx),    %esi
    mov     8(%edx),    %edi
    mov     12(%edx),   %ebp
    mov     16(%edx),   %esp
    jmp     *20(%edx)

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

.global call_on_stack__asm_setjmp
.type call_on_stack__asm_setjmp,@function
call_on_stack__asm_setjmp:
    mov     %rbx,       (%rdi)         /* rdi is jmp_buf, move registers onto it */
    mov     %rbp,       8(%rdi)
    mov     %r12,       16(%rdi)
    mov     %r13,       24(%rdi)
    mov     %r14,       32(%rdi)
    mov     %r15,       40(%rdi)
    lea     8(%rsp),    %rdx        /* this is our rsp WITHOUT current ret addr */
    mov     %rdx,       48(%rdi)
    mov     (%rsp),     %rdx         /* save return addr ptr for new rip */
    mov     %rdx,       56(%rdi)
    xor     %eax,       %eax           /* always return 0 */
    ret

.global call_on_stack__asm_longjmp
.type call_on_stack__asm_longjmp,@function
call_on_stack__asm_longjmp:
    xor     %eax,       %eax
    cmp     $1,         %esi             /* CF = val ? 0 : 1 */
    adc     %esi,       %eax           /* eax = val + !val */
    mov     (%rdi),     %rbx         /* rdi is the jmp_buf, restore regs from it */
    mov     8(%rdi),    %rbp
    mov     16(%rdi),   %r12
    mov     24(%rdi),   %r13
    mov     32(%rdi),   %r14
    mov     40(%rdi),   %r15
    mov     48(%rdi),   %rsp
    jmp     *56(%rdi)           /* goto saved address without altering rsp */

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
#   error   "unsupport platform"
#endif
