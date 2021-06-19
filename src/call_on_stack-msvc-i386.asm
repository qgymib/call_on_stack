.model flat
.code
_call_on_stack__asm   PROC
    push    ebp
    mov     ebp,    esp
    mov     esi,    DWORD PTR 8[ebp]      ; save jmpbuf
    mov     edi,    DWORD PTR 12[ebp]     ; save longjmp() function pointer
    mov     eax,    DWORD PTR 20[ebp]     ; get user function
    mov     ecx,    DWORD PTR 24[ebp]     ; get user argument
    mov     esp,    DWORD PTR 16[ebp]     ; set stack pointer
    push    ecx
    call    eax
    add     esp,    4h
    push    1
    push    esi
    call    edi
_call_on_stack__asm   ENDP

END
