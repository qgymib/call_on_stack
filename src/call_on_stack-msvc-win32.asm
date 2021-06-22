.model flat
.code
_call_on_stack__asm   PROC
    push    ebp
    mov     ebp,    esp
    sub     esp,    8h
    ; backup callee saved registers
    push    esi
    push    edi
    ; backup stack
    mov     esi,    esp
    mov     edi,    ebp
    ; get func and arg
    mov     eax,    DWORD PTR 12[ebp]
    mov     ecx,    DWORD PTR 16[ebp]
    ; switch stack
    mov     esp,    DWORD PTR 8[ebp]
    mov     ebp,    esp
    ; func(arg)
    push    ecx
    call    eax
    ; restore stack
    mov     esp,    esi
    mov     ebp,    edi
    ; restore callee saved registers
    pop     edi
    pop     esi
    ; leave
    add     esp,    8h
    pop     ebp
    ret
_call_on_stack__asm   ENDP

END
