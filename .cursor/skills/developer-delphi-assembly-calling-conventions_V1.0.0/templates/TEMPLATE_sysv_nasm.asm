; TEMPLATE_sysv_nasm.asm — System V AMD64 ABI (Linux/macOS x64)
; NOTA: Delphi nao suporta Linux/macOS nativamente em x64 via ASM inline.
; Este template e para NASM externo linkado via FPC em Linux.
;
; System V AMD64 ABI (Linux/macOS):
;   Parametros inteiros: RDI, RSI, RDX, RCX, R8, R9
;   Parametros float:    XMM0-XMM7
;   Retorno inteiro:     RAX
;   Retorno float:       XMM0
;   Callee-saved:        RBX, RBP, R12-R15
;   Caller-saved:        RAX, RCX, RDX, RSI, RDI, R8-R11, XMM0-XMM7
;   Stack alignment:     16 bytes no ponto do CALL
;   Red zone:            128 bytes abaixo de RSP (funcoes leaf podem usar)
;
; Diferenca principal vs. Windows x64:
;   Win64:   RCX, RDX, R8, R9 + shadow space 32B
;   SysV:    RDI, RSI, RDX, RCX, R8, R9 + sem shadow space + red zone

section .text

; ------------------------------------------------------------------
; long long SomarSysV(long long A, long long B);
; FPC: function SomarSysV(A, B: Int64): Int64; cdecl; external;
;
; A = RDI, B = RSI
; Retorno = RAX
; ------------------------------------------------------------------
global SomarSysV

SomarSysV:
    mov     rax, rdi        ; RAX = A
    add     rax, rsi        ; RAX = A + B
    ret


; ------------------------------------------------------------------
; void CopiarMemoriaSysV(void* dest, const void* src, size_t n);
; dest = RDI, src = RSI, n = RDX
; ------------------------------------------------------------------
global CopiarMemoriaSysV

CopiarMemoriaSysV:
    ; Salvar callee-saved se necessario
    ; (RDI, RSI, RDX sao todos caller-saved — podemos usar livremente)
    mov     rcx, rdx        ; RCX = contador de bytes
    test    rcx, rcx
    jz      .fim

    ; Copiar usando rep movsb (simplificado — use MOVDQU para performance)
    cld                     ; direcao crescente
    rep movsb               ; RDI = dest, RSI = src, RCX = count

.fim:
    ret
