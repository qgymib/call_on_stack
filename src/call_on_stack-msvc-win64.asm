_TEXT SEGMENT

call_on_stack__asm   PROC FRAME
    .endprolog
    ; https://docs.microsoft.com/en-us/cpp/build/x64-calling-convention
    mov     r12,    rcx                 ; save jmp_buf
    mov     r13,    rdx                 ; save longjmp() function pointer
    mov     rsp,    rcx                 ; set stack pointer
    ; Accroding to https://docs.microsoft.com/en-us/cpp/build/stack-usage#stack-allocation,
    ; there is a `register parameter stack area` at the bottom of stack frame.
    ; To simulate it, we leave 40 bytes empty space on this stack.
    sub     rsp,    48
    mov     rcx,    r9
    call    r8                          ; func(arg)
    mov     rcx,    r12                 ; build argument:jmp_buf
    mov     rdx,    1                   ; build argument:1
    call    r13                         ; longjmp(jmp_buf, 1)
call_on_stack__asm   ENDP

; The default Windows implementation of longjmp enable SEH, which is
; incompatible with manual switch stack.
;
; However, we can force longjmp to use common implementation to disable SEH
; feature:
;
; On w64, setjmp(jmp_buf) is implemented as setjmp(jmp_buf, size_t) which need
; a second parameter. If this parameter is 0, longjmp does no stack unwinding,
; that is what we need.
;
; But there is no way to do this in pure C, beacuse Microsoft writes setjmp()
; with two parameters but only gives a signature which has one argument.
;
; To make this work, we need a wrap function, set second parameter (AKA. rdx)
; to 0 and jump to native setjmp.
;
; Checkout https://blog.lazym.io/2020/09/21/Unicorn-Devblog-setjmp-longjmp-on-Windows/
; for details.
EXTERN _setjmp : proc
call_on_stack__asm_setjmp   PROC
    xor     rdx,    rdx
    jmp     _setjmp
call_on_stack__asm_setjmp   ENDP

_TEXT ENDS
END
