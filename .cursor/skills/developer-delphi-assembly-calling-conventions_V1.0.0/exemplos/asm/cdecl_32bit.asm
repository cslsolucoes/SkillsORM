; cdecl_32bit.asm — Exemplo de funcao cdecl para Win32
; Montagem: nasm -f win32 cdecl_32bit.asm -o cdecl_32bit.obj
;
; Declaracao Pascal:
;   function SomarCdecl(A, B: Integer): Integer; cdecl; external;
;   {$L cdecl_32bit.obj}
;
; DIFERENCA cdecl vs stdcall:
;   - cdecl: o CALLER (codigo Pascal) limpa a pilha apos o CALL
;   - stdcall: o CALLEE (esta funcao asm) limpa com RET N
;
; O compilador Delphi gera automaticamente o ADD ESP,N no caller
; quando a funcao e declarada com `cdecl`.

section .text

global _SomarCdecl          ; cdecl: sem decoracao @N no nome
                             ; (diferente de stdcall que usa _Nome@8)

; ------------------------------------------------------------------
; function SomarCdecl(A, B: Integer): Integer; cdecl;
;
; Stack frame:
;   [EBP+8]  = A
;   [EBP+12] = B
; Retorno: EAX
; Caller limpa pilha (nao usa RET N)
; ------------------------------------------------------------------
_SomarCdecl:
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp+8]    ; A
    add     eax, [ebp+12]   ; A + B

    pop     ebp
    ret                     ; cdecl: RET simples (sem N!)
                            ; caller faz: ADD ESP, 8

; ------------------------------------------------------------------
; Funcao variadic cdecl — exemplo: soma N inteiros
; function SomaVariadic(Count: Integer; ...): Integer; cdecl;
;
; Stack antes de CALL:
;   [EBP+8]  = Count
;   [EBP+12] = primeiro argumento variadic
;   [EBP+16] = segundo argumento variadic ... etc.
; ------------------------------------------------------------------
global _SomaVariadic

_SomaVariadic:
    push    ebp
    mov     ebp, esp
    push    esi
    push    ebx

    mov     ecx, [ebp+8]    ; Count = numero de valores
    lea     esi, [ebp+12]   ; ESI aponta para primeiro arg variadic
    xor     eax, eax        ; acumulador = 0

.loop:
    test    ecx, ecx
    jz      .fim
    add     eax, [esi]      ; acumula
    add     esi, 4          ; proxima posicao na pilha
    dec     ecx
    jmp     .loop

.fim:
    pop     ebx
    pop     esi
    pop     ebp
    ret                     ; caller limpa todos os args
