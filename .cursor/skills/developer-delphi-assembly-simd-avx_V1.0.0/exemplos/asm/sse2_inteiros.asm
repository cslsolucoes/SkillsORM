; sse2_inteiros.asm — Operacoes com inteiros usando SSE2
; PADDQ, PSUBQ, PCMPEQD, PMULLD (SSE4.1)
; Montagem: nasm -f win32 sse2_inteiros.asm -o sse2_inteiros.obj

section .text

; ------------------------------------------------------------------
; procedure SomaDoisArraysInt32(Dest, A, B: PInteger; Count: Integer);
; Soma dois arrays de Integer com PADDD (SSE2, 4 int32 por iteracao)
; Stdcall
; ------------------------------------------------------------------
global _SomaDoisArraysInt32

_SomaDoisArraysInt32:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ebx

    mov     edi, [ebp+8]        ; Dest
    mov     esi, [ebp+12]       ; A
    mov     ebx, [ebp+16]       ; B
    mov     ecx, [ebp+20]       ; Count

    mov     eax, ecx
    shr     eax, 2              ; blocos de 4 int32
    and     ecx, 3

    test    eax, eax
    jz      .residuo

.loop_sse2:
    MOVDQU  XMM0, [ESI]         ; 4 x Int32 de A (nao-alinhado)
    MOVDQU  XMM1, [EBX]         ; 4 x Int32 de B
    PADDD   XMM0, XMM1          ; XMM0[0..3] += XMM1[0..3] (Int32 add)
    MOVDQU  [EDI], XMM0
    add     esi, 16
    add     ebx, 16
    add     edi, 16
    dec     eax
    jnz     .loop_sse2

.residuo:
    test    ecx, ecx
    jz      .fim
.loop_escalar:
    mov     eax, [esi]
    add     eax, [ebx]
    mov     [edi], eax
    add     esi, 4
    add     ebx, 4
    add     edi, 4
    dec     ecx
    jnz     .loop_escalar

.fim:
    pop     ebx
    pop     edi
    pop     esi
    pop     ebp
    ret     16


; ------------------------------------------------------------------
; procedure SomaDoisArraysInt64(Dest, A, B: PInt64; Count: Integer);
; Soma arrays de Int64 com PADDQ (2 int64 por iteracao)
; ------------------------------------------------------------------
global _SomaDoisArraysInt64

_SomaDoisArraysInt64:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ebx

    mov     edi, [ebp+8]
    mov     esi, [ebp+12]
    mov     ebx, [ebp+16]
    mov     ecx, [ebp+20]

    mov     eax, ecx
    shr     eax, 1              ; blocos de 2 int64
    and     ecx, 1

    test    eax, eax
    jz      .residuo64

.loop_paddq:
    MOVDQU  XMM0, [ESI]         ; 2 x Int64 de A
    MOVDQU  XMM1, [EBX]         ; 2 x Int64 de B
    PADDQ   XMM0, XMM1          ; XMM0 += XMM1 (PADDQ = soma 64-bit!)
    MOVDQU  [EDI], XMM0
    add     esi, 16
    add     ebx, 16
    add     edi, 16
    dec     eax
    jnz     .loop_paddq

.residuo64:
    test    ecx, ecx
    jz      .fim64
    ; processar Int64 escalar
    mov     eax, [esi]          ; low 32 bits de A
    mov     edx, [esi+4]        ; high 32 bits de A
    add     eax, [ebx]          ; + low de B
    adc     edx, [ebx+4]        ; + high de B (com carry)
    mov     [edi], eax
    mov     [edi+4], edx

.fim64:
    pop     ebx
    pop     edi
    pop     esi
    pop     ebp
    ret     16
