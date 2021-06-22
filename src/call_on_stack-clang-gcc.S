
#if defined(__i386__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    /* enter */
    push    %ebp
    mov     %esp,       %ebp
    sub     $8,         %esp
    /* backup callee saved registers */
    push    %esi
    push    %edi
    /* backup esp and ebp */
    mov     %esp,       %esi
    mov     %ebp,       %edi
    /* get func and arg */
    mov     12(%ebp),   %eax
    mov     16(%ebp),   %ecx
    /* switch stack */
    mov     8(%ebp),    %esp
    mov     %esp,       %ebp
    /* func(arg) */
    push    %ecx
    call    *%eax
    /* restore stack */
    mov     %esi,       %esp
    mov     %edi,       %ebp
    /* restore callee save registers */
    pop     %edi
    pop     %esi
    /* leave */
    leave
    ret

#elif defined(__x86_64__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    /* enter */
    push    %rbp
    mov     %rsp,       %rbp
    sub     $32,        %rsp
    mov     %rdi,       -8(%rbp)
    mov     %rsi,       -16(%rbp)
    mov     %rdx,       -24(%rbp)
    /* backup callee saved registers */
    push    %r12
    push    %r13
    /* backup rsp and rbp */
    mov     %rsp,       %r12
    mov     %rbp,       %r13
    /* switch stack */
    mov     %rdi,       %rsp
    mov     %rsp,       %rbp
    /* call func(arg) */
    mov     %rdx,       %rdi
    call    *%rsi
    /* restore stack */
    mov     %r12,       %rsp
    mov     %r13,       %rbp
    /* restore callee saved registers */
    pop     %r13
    pop     %r12
    /* leave */
    leave
    ret

#elif defined(__arm__)

.syntax unified
.global call_on_stack__asm
.type call_on_stack__asm,%function
call_on_stack__asm:
    /* enter */
    push    { r7, lr }
    sub     sp,         sp, #20
    add     r7,         sp, #0
    str     r0,         [r7, #12]
    str     r1,         [r7, #8]
    str     r2,         [r7, #4]
    /* backup callee saved registers */
    str     r4,         [r7, #16]
    /* backup stack */
    mov     r4,         sp
    /* switch stack */
    mov     sp,         r0
    /* func(arg) */
    mov     r0,         r2
    blx     r1
    /* restore stack */
    mov     sp,         r4
    /* restore callee saved registers */
    ldr     r4,         [r7, #16]
    /* leave */
    adds    r7,         r7, #20
    mov     sp,         r7
    pop     { r7, pc }

#elif defined(__aarch64__)

.global call_on_stack__asm
.type call_on_stack__asm,@function
call_on_stack__asm:
    /* etner */
    stp     x29, x30, [sp, -64]!
    mov     x29,        sp
    str     x0,         [sp, 40]
    str     x1,         [sp, 32]
    str     x2,         [sp, 24]
    /* backup calledd saved registers */
    str     x19,        [sp, 48]
    str     x20,        [sp, 56]
    /* backup stack */
    mov     x19,        sp
    mov     x20,        x29
    /* switch stack */
    mov     sp,         x0
    mov     x29,        x0
    /* func(arg) */
    mov     x0,         x2
    blr     x1
    /* restore stack */
    mov     sp,         x19
    mov     x29,        x20
    /* restore callee saved registers */
    ldr     x19,        [sp, 48]
    ldr     x20,        [sp, 56]
    /* leave */
    ldp     x29, x30, [sp], 64
    ret

#else
#   error   "unsupport platform"
#endif
