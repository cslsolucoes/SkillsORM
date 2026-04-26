; avx2_soma_8floats.asm — Soma de arrays de float usando AVX2
; 8 floats por iteracao (YMM = 256-bit = 8 x Single)
; Montagem Win32: nasm -f win32 avx2_soma_8floats.asm -o avx2_soma_8floats.obj
;
; REQUISITO: CPU com suporte AVX2 (Intel Haswell 2013+ / AMD Ryzen 2017+)
; Verificar com CPUID antes de usar!

section .text

; ------------------------------------------------------------------
; procedure SomaDoisArraysAVX(Dest, Src1, Src2: PSingle; Count: Integer);
; Dest[i] = Src1[i] + Src2[i] para i = 0..Count-1
; Stdcall: todos params na pilha (para simplificar o exemplo)
; ------------------------------------------------------------------
global _SomaDoisArraysAVX

_SomaDoisArraysAVX:
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ebx

    mov     edi, [ebp+8]        ; EDI = Dest
    mov     esi, [ebp+12]       ; ESI = Src1
    mov     ebx, [ebp+16]       ; EBX = Src2
    mov     ecx, [ebp+20]       ; ECX = Count

    ; Processar 8 floats por vez com AVX (YMM, 256-bit):
    mov     eax, ecx
    shr     eax, 3              ; EAX = Count / 8
    and     ecx, 7              ; ECX = Count mod 8

    test    eax, eax
    jz      .residuo_4

.loop_avx:
    VMOVUPS YMM0, [ESI]         ; carregar 8 floats de Src1 (nao-alinhado)
    VMOVUPS YMM1, [EBX]         ; carregar 8 floats de Src2
    VADDPS  YMM0, YMM0, YMM1   ; YMM0 = YMM0 + YMM1 (3 operandos, nao-destrutivo)
    VMOVUPS [EDI], YMM0         ; gravar 8 floats em Dest
    add     esi, 32             ; Src1 += 8 * 4 bytes
    add     ebx, 32
    add     edi, 32
    dec     eax
    jnz     .loop_avx

    VZEROUPPER                  ; OBRIGATORIO: limpar bits altos YMM antes de SSE/FPU

.residuo_4:
    ; Tentar processar 4 floats com SSE:
    cmp     ecx, 4
    jl      .residuo_1
    MOVUPS  XMM0, [ESI]
    MOVUPS  XMM1, [EBX]
    ADDPS   XMM0, XMM1
    MOVUPS  [EDI], XMM0
    add     esi, 16
    add     ebx, 16
    add     edi, 16
    sub     ecx, 4

.residuo_1:
    ; Processar floats restantes (0-3) escalarmente:
    test    ecx, ecx
    jz      .fim
.loop_escalar:
    fld     dword [esi]
    fadd    dword [ebx]
    fstp    dword [edi]
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
    ret     16                  ; stdcall: limpar 4 params (Dest, Src1, Src2, Count)
