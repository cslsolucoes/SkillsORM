; sse_soma_floats.asm — Soma de arrays de float usando SSE2
; 4 floats por iteracao (XMM = 128-bit = 4 x Single)
; Montagem Win32: nasm -f win32 sse_soma_floats.asm -o sse_soma_floats.obj
;
; Declaracao Pascal:
;   {$L sse_soma_floats.obj}
;   procedure SomaArraySSE(Dest, A, B: PSingle; Count: Integer); external;

section .data
align 16
constZero: dd 0.0, 0.0, 0.0, 0.0   ; 4 zeros para padding

section .text

; ------------------------------------------------------------------
; procedure SomaArraySSE(Dest, A, B: PSingle; Count: Integer);
; Dest[i] = A[i] + B[i] para i = 0..Count-1
; Win32 register: Dest=EAX, A=EDX, Count=ECX
; NOTA: B seria quarto parametro (na pilha em register)
;
; Versao simplificada com 3 params (B = A + offset para demonstracao):
; function SomaMesmoArray(Dest, Src: PSingle; Count: Integer): void;
; Dest=EAX, Src=EDX, Count=ECX
; ------------------------------------------------------------------
global _SomaDoisArraysSSE

_SomaDoisArraysSSE:
    ; Entrada: EAX=Dest, EDX=Src1, [ESP+4]=Src2, [ESP+8]=Count
    ; (stdcall para demonstrar parametros na pilha)
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi

    mov     edi, eax            ; EDI = Dest
    mov     esi, edx            ; ESI = Src1
    mov     edx, [ebp+8]        ; EDX = Src2
    mov     ecx, [ebp+12]       ; ECX = Count

    ; Processar 4 floats por vez com SSE:
    mov     eax, ecx
    shr     eax, 2              ; EAX = Count / 4
    and     ecx, 3              ; ECX = Count mod 4 (residuo)

    test    eax, eax
    jz      .residuo

.loop_sse:
    MOVUPS XMM0, [ESI]          ; carregar 4 floats de Src1
    MOVUPS XMM1, [EDX]          ; carregar 4 floats de Src2
    ADDPS  XMM0, XMM1           ; XMM0 = Src1[0..3] + Src2[0..3]
    MOVUPS [EDI], XMM0          ; gravar 4 floats em Dest
    add     esi, 16             ; Src1 += 4 * 4 bytes
    add     edx, 16             ; Src2 += 4 * 4 bytes
    add     edi, 16             ; Dest += 4 * 4 bytes
    dec     eax
    jnz     .loop_sse

.residuo:
    ; Processar floats restantes (0, 1, 2, ou 3)
    test    ecx, ecx
    jz      .fim
.loop_escalar:
    fld     dword [esi]         ; ST(0) = *Src1
    fadd    dword [edx]         ; ST(0) += *Src2
    fstp    dword [edi]         ; *Dest = ST(0)
    add     esi, 4
    add     edx, 4
    add     edi, 4
    dec     ecx
    jnz     .loop_escalar

.fim:
    pop     edi
    pop     esi
    pop     ebp
    ret     8                   ; stdcall: limpar 2 params da pilha
