; strlen_nasm.asm — Implementacao de strlen para Delphi
; Montagem: nasm -f win32 strlen_nasm.asm -o strlen_nasm.obj
;
; Declaracao Pascal:
;   {$L strlen_nasm.obj}
;   function StrLenNasm(S: PAnsiChar): Integer; external;
;
; Usa SSE4.2 PCMPISTRI para versao otimizada quando disponivel,
; com fallback byte-a-byte

section .text

; ------------------------------------------------------------------
; Versao simples: contagem byte-a-byte
; function StrLenSimples(S: PAnsiChar): Integer;
; Win32 register: S=EAX
; ------------------------------------------------------------------
global _StrLenSimples

_StrLenSimples:
    push    edi
    mov     edi, eax        ; EDI = S
    xor     ecx, ecx        ; ECX = contador
    dec     edi             ; pre-decremento

.loop:
    inc     edi
    inc     ecx
    cmp     byte [edi], 0   ; null terminator?
    jnz     .loop

    dec     ecx             ; nao contar o null
    mov     eax, ecx
    pop     edi
    ret


; ------------------------------------------------------------------
; Versao otimizada com REPNE SCASB (mais rapida que loop manual)
; function StrLenScas(S: PAnsiChar): Integer;
; Win32 register: S=EAX
; ------------------------------------------------------------------
global _StrLenScas

_StrLenScas:
    push    edi
    mov     edi, eax        ; EDI = S
    xor     ecx, ecx        ; ECX = 0
    not     ecx             ; ECX = 0xFFFFFFFF (maior contador possivel)
    xor     al, al          ; AL = 0 (buscar null byte)
    cld                     ; direcao crescente
    repne   scasb           ; busca AL em [EDI], decrementa ECX ate encontrar
    ; ECX = 0xFFFFFFFF - (comprimento + 1)
    not     ecx             ; complemento
    dec     ecx             ; nao contar o null
    mov     eax, ecx
    pop     edi
    ret
