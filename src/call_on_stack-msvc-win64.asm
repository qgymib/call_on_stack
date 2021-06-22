_TEXT SEGMENT

call_on_stack__asm   PROC
    ; https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention
    ; https://docs.microsoft.com/en-us/cpp/build/stack-usage
    ; enter
    mov QWORD PTR [rsp+24], r8
    mov QWORD PTR [rsp+16], rdx
    mov QWORD PTR [rsp+8],  rcx
    ; backup callee saved registers
    push    rsi
    push    rdi
    ; backup stack
    mov     rsi,    rsp
    mov     rdi,    rbp
    ; switch stack
    mov     rsp,    rcx
    mov     rbp,    rsp
    ; Accroding to https://docs.microsoft.com/en-us/cpp/build/stack-usage#stack-allocation,
    ; there is a `register parameter stack area` at the bottom of stack frame.
    ; To simulate it, we leave 40 bytes empty space on this stack.
    sub     rsp,    40
    mov     rcx,    r8
    call    rdx
    add     rsp,    40
    ; restore stack
    mov     rsp,    rsi
    mov     rbp,    rdi
    ; restore callee saved registers
    pop rdi
    pop rsi
    ; leave
    ret
call_on_stack__asm   ENDP

_TEXT ENDS
END
