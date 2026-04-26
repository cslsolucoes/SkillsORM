; windows_x64_shadow.asm — Windows x64 ABI com shadow space
; Montagem: nasm -f win64 windows_x64_shadow.asm -o windows_x64_shadow.obj
;
; Declaracao Pascal (Win64):
;   function SomarX64(A, B: Integer): Integer; external;
;   {$L windows_x64_shadow.obj}
;
; WINDOWS X64 ABI:
;   - Parametros inteiros: RCX, RDX, R8, R9 (5o+ na pilha)
;   - Parametros float:    XMM0, XMM1, XMM2, XMM3
;   - Retorno inteiro:     RAX
;   - Retorno float:       XMM0
;   - CALLER deve reservar 32 bytes de shadow space antes de CALL
;   - RSP deve estar alinhado em 16 bytes no momento do CALL
;   - Non-volatile: RBX, RBP, RDI, RSI, R12-R15, XMM4-XMM15

section .text

; ------------------------------------------------------------------
; function SomarX64(A, B: Integer): Integer;
; A = ECX (baixo 32 bits de RCX)
; B = EDX (baixo 32 bits de RDX)
; Retorno: EAX (baixo 32 bits de RAX)
; Funcao leaf simples: nao precisa de frame completo
; ------------------------------------------------------------------
global SomarX64

SomarX64:
    ; Nao modifica registradores non-volatile — nao precisa salvar
    mov     eax, ecx        ; EAX = A
    add     eax, edx        ; EAX = A + B
    ret                     ; retorno em EAX (parte de RAX)


; ------------------------------------------------------------------
; function ChamarCallback(Fn: Pointer; A, B: Int64): Int64;
;
; Demonstra shadow space obrigatorio ao chamar outra funcao
; A = RCX = ponteiro para funcao
; B = RDX = primeiro arg Int64 para o callback
; C = R8  = segundo arg Int64 para o callback
; ------------------------------------------------------------------
global ChamarCallback

ChamarCallback:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32 + 8     ; 32 shadow space + 8 para alinhamento 16 bytes
                            ; (CALL empilhou 8 bytes de endereco retorno)
                            ; total SUB = 40 => RSP alinhado em 16

    mov     r10, rcx        ; salvar ponteiro da funcao (RCX sera sobrescrito)
    ; Preparar args para o callback (Windows x64 ABI):
    mov     rcx, rdx        ; primeiro arg = B (era RDX)
    mov     rdx, r8         ; segundo arg = C (era R8)
    ; Shadow space ja alocado no RSP
    call    r10             ; chamar funcao cujo ponteiro estava em RCX original

    ; resultado ja em RAX

    mov     rsp, rbp
    pop     rbp
    ret


; ------------------------------------------------------------------
; Funcao com registradores non-volatile — usa R12 e R13
; function ContarLoop(Inicio, Fim: Int64): Int64;
; ------------------------------------------------------------------
global ContarLoop

ContarLoop:
    push    rbp
    mov     rbp, rsp
    push    r12             ; salvar r12 (non-volatile!)
    push    r13             ; salvar r13 (non-volatile!)
    sub     rsp, 8          ; alinhamento (2 pushes = 16, mais 8 do CALL = 24; sub 8 = 32 total, alinhado)

    mov     r12, rcx        ; r12 = Inicio
    mov     r13, rdx        ; r13 = Fim
    xor     rax, rax        ; contador = 0

.loop:
    cmp     r12, r13
    jge     .fim
    inc     rax
    inc     r12
    jmp     .loop

.fim:
    add     rsp, 8
    pop     r13
    pop     r12
    pop     rbp
    ret
