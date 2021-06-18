
#if defined(__i386__)

.global call_on_stack_asm
.type call_on_stack_asm,@function
call_on_stack_asm:
    mov     4(%esp),    %esi        /* save jmpbuf */
    mov     8(%esp),    %edi        /* save longjmp() function pointer */
    mov     16(%esp),   %eax        /* get user function */
    mov     20(%esp),   %ecx        /* get user argument */
    mov     12(%esp),   %esp        /* set stack pointer */
    push    %ecx                    /* build argument:arg */
    call    *%eax                   /* func(arg) */
    add     $4,         %esp
    push    $1                      /* build argument:1 */
    push    %esi                    /* build argument:jmp_buf */
    call    *%esi

#elif defined(__x86_64__)

.global call_on_stack_asm
.type call_on_stack_asm,@function
call_on_stack_asm:
    mov     %rdi,       %r12        /* save jmp_buf */
    mov     %rsi,       %r13        /* save longjmp() function pointer */
    mov     %rdx,       %rsp        /* set stack pointer */
    mov     %r8,        %rdi        /* build argument:arg */
    call    *%rcx                   /* func(arg) */
    mov     %r12,       %rdi        /* build argument:jmp_buf */
    mov     $1,         %rsi        /* build argument:1 */
    call    *%r13                   /* longjmp(jmp_buf, 1) */

#elif defined(__arm__)

.syntax unified
.global call_on_stack_asm
.type call_on_stack_asm,%function
call_on_stack_asm:
    mov     r4,         r0          /* save jmp_buf */
    mov     r5,         r1          /* save longjmp() function pointer */
    ldr     r6,         [sp]        /* save user argument */
    mov     sp,         r2          /* set stack pointer */
    mov     r0,         r6          /* build argument: arg */
    blx     r3                      /* func(arg) */
    mov     r0,         r4          /* build argument: jmp_buf */
    mov     r1,         #1          /* build argument: 1 */
    bx      r5

#elif defined(__aarch64__)

.global call_on_stack_asm
.type call_on_stack_asm,@function
call_on_stack_asm:
    mov     r19,        r0          /* save jmpbuf */
    mov     r20,        r1          /* save longjmp() function pointer */
    mov     sp,         r2          /* set stack pointer */
    mov     r0,         r4          /* build argument: arg */
    blr     r3                      /* func(arg) */
    mov     r0,         r19         /* build argument: jmpbuf */
    mov     r1,         1           /* build argument:  1 */
    br      r20                     /* longjmp(jmpbuf, 1) */

#else
#   error	"unsupport platform"
#endif
