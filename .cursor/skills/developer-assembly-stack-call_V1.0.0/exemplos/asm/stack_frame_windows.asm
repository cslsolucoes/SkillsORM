; stack_frame_windows.asm
; Prologue Windows x64 com shadow space de 32 bytes obrigatório
; Compilar (win64): nasm -f win64 stack_frame_windows.asm -o stack_frame_windows.obj
; Linkar: link stack_frame_windows.obj /subsystem:console /entry:_start kernel32.lib

bits 64

section .data
    ; Dados simples
    val1    dq 42
    val2    dq 58

section .bss
    resultado resq 1

section .text
    global _start

; ===========================================================================
; Convenção Windows x64 — regras de shadow space:
;
; Antes de CALL, o chamador deve alocar 32 bytes de shadow space.
; Stack layout no momento do CALL (RSP = 16n):
;
;   RSP+32 = home R9 (4° arg)
;   RSP+24 = home R8 (3° arg)
;   RSP+16 = home RDX (2° arg)
;   RSP+8  = home RCX (1° arg)
;   RSP+0  = ← CALL escreve return address aqui
;
; Dentro da função, após PUSH RBP:
;   [RBP+16] = home de RCX (shadow do 1° arg)
;   [RBP+24] = home de RDX (shadow do 2° arg)
;   [RBP+32] = home de R8
;   [RBP+40] = home de R9
;   [RBP+48] = 5° argumento (se houver)
; ===========================================================================

; ===========================================================================
; Função: soma(a, b) → a + b
; RCX = a, RDX = b
; Retorno: RAX
; ===========================================================================
soma:
    ; Prologue Windows x64
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; shadow space para chamadas aninhadas

    ; Parâmetros chegam em RCX e RDX
    mov     rax, rcx            ; RAX = a
    add     rax, rdx            ; RAX = a + b

    ; Epilogue
    add     rsp, 32
    pop     rbp
    ret

; ===========================================================================
; Função: processa(a, b, c, d) → a + b + c + d
; RCX=a, RDX=b, R8=c, R9=d
; Demonstra acesso a todos os 4 parâmetros de registrador
; ===========================================================================
processa_4params:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Opcional: salvar parâmetros no shadow space (para debug ou se precisar de RCX etc)
    mov     [rbp+16], rcx       ; shadow de RCX (home)
    mov     [rbp+24], rdx       ; shadow de RDX
    mov     [rbp+32], r8        ; shadow de R8
    mov     [rbp+40], r9        ; shadow de R9

    ; Computar soma
    mov     rax, rcx            ; RAX = a
    add     rax, rdx            ; RAX += b
    add     rax, r8             ; RAX += c
    add     rax, r9             ; RAX += d

    add     rsp, 32
    pop     rbp
    ret

; ===========================================================================
; Função: com_5_params(a, b, c, d, e) — 5° param na stack
; RCX=a, RDX=b, R8=c, R9=d
; e = [RBP+48] (após prologue)
; Nota: antes do CALL, chamador pushou e em [RSP+32]
; ===========================================================================
com_5_params:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; 4 primeiros via registradores
    mov     rax, rcx            ; a
    add     rax, rdx            ; + b
    add     rax, r8             ; + c
    add     rax, r9             ; + d

    ; 5° parâmetro: [RBP+48]
    ; Layout após prologue:
    ;   [RBP+0]  = saved RBP
    ;   [RBP+8]  = return address
    ;   [RBP+16] = shadow RCX
    ;   [RBP+24] = shadow RDX
    ;   [RBP+32] = shadow R8
    ;   [RBP+40] = shadow R9
    ;   [RBP+48] = 5° argumento ← passado antes do CALL
    add     rax, [rbp+48]       ; + e

    add     rsp, 32
    pop     rbp
    ret

; ===========================================================================
; Função: usa registradores callee-saved
; ===========================================================================
usa_callee_saved:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; Salvar registradores não-voláteis que vamos usar
    push    rbx
    push    rsi
    push    rdi
    push    r12
    ; 4 push extras = 32 bytes; RSP estava alinhado após sub rsp,32;
    ; 4 push de 8 = 32 bytes → RSP ainda alinhado? verificar:
    ; sub rsp,32 → alinhado; 4 push → -32 → ainda alinhado a 16? 32%16=0 ✓

    ; Usar os registradores preservados livremente
    mov     rbx, rcx            ; rbx = 1° arg
    mov     rsi, rdx            ; rsi = 2° arg
    xor     rdi, rdi
    xor     r12, r12

    mov     rax, rbx
    add     rax, rsi

    ; Restaurar na ordem inversa
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx

    add     rsp, 32
    pop     rbp
    ret

; ===========================================================================
; Ponto de entrada: demonstra chamadas com shadow space
; ===========================================================================
_start:
    ; Alocar shadow space antes de CALL
    sub     rsp, 32             ; shadow space para _start chamar funções

    ; Chamar soma(42, 58)
    mov     rcx, 42             ; 1° arg
    mov     rdx, 58             ; 2° arg
    call    soma                ; RAX = 100
    mov     [rel resultado], rax

    ; Chamar processa_4params(1, 2, 3, 4)
    mov     rcx, 1
    mov     rdx, 2
    mov     r8,  3
    mov     r9,  4
    call    processa_4params    ; RAX = 10

    ; Chamar com_5_params(1, 2, 3, 4, 5)
    ; 5° argumento: precisa ser empilhado ANTES do shadow space
    ; Layout no RSP no momento do CALL:
    ;   [RSP+0]  = CALL escreve return addr
    ;   [RSP+8]  = shadow RCX
    ;   [RSP+16] = shadow RDX
    ;   [RSP+24] = shadow R8
    ;   [RSP+32] = shadow R9
    ;   [RSP+40] = 5° argumento (e)
    ; Portanto: push e ANTES de ajustar shadow:
    sub     rsp, 8              ; alinhar (RSP já tinha 32 bytes de shadow, agora mais 8)
    mov     qword [rsp+32], 5  ; 5° argumento na posição correta
    mov     rcx, 1
    mov     rdx, 2
    mov     r8,  3
    mov     r9,  4
    call    com_5_params        ; RAX = 15
    add     rsp, 8              ; desfaz o alinhamento extra

    add     rsp, 32             ; limpa shadow space de _start

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
