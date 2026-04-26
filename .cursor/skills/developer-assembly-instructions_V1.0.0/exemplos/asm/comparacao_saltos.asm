; comparacao_saltos.asm
; Demonstra CMP, TEST e todos os saltos condicionais Jcc
; Compilar: nasm -f elf64 comparacao_saltos.asm -o comparacao_saltos.o

bits 64

section .bss
    res_max  resq 1

section .text
    global _start

; ===========================================================================
; Função: max(A, B) — retorna o maior de dois inteiros com sinal
; Entrada: RDI=A, RSI=B (convenção Linux x64)
; Saída:   RAX = max(A, B)
; ===========================================================================
max_signed:
    cmp     rdi, rsi
    jge     .a_maior      ; A >= B (com sinal)? Salta
    mov     rax, rsi      ; RAX = B (B > A)
    ret
.a_maior:
    mov     rax, rdi      ; RAX = A (A >= B)
    ret

; ===========================================================================
; Função: demonstração de todos os Jcc
; ===========================================================================
demo_jcc:
    push    rbp
    mov     rbp, rsp

    ; --- JE / JZ (igual / zero) ---
    mov     eax, 5
    cmp     eax, 5        ; ZF = 1 (iguais)
    je      .igual        ; salta se ZF=1
    jmp     .skip_igual
.igual:
    nop                   ; aqui se eax == 5
.skip_igual:

    ; --- JNE / JNZ (diferente / não zero) ---
    mov     eax, 5
    cmp     eax, 10       ; ZF = 0 (diferentes)
    jne     .diferente    ; salta se ZF=0
    jmp     .skip_dif
.diferente:
    nop
.skip_dif:

    ; --- JG / JNLE (maior — SIGNED) ---
    mov     eax, 10
    cmp     eax, 5        ; 10 > 5 (signed)
    jg      .maior_s
    jmp     .skip_maior_s
.maior_s:
    nop
.skip_maior_s:

    ; --- JL / JNGE (menor — SIGNED) ---
    mov     eax, -5
    cmp     eax, 0        ; -5 < 0 (signed)
    jl      .menor_s
    jmp     .skip_menor_s
.menor_s:
    nop
.skip_menor_s:

    ; --- JGE / JNL (maior ou igual — SIGNED) ---
    mov     eax, 5
    cmp     eax, 5        ; 5 >= 5
    jge     .maiorig_s
    jmp     .skip_maiorig_s
.maiorig_s:
    nop
.skip_maiorig_s:

    ; --- JLE / JNG (menor ou igual — SIGNED) ---
    mov     eax, -1
    cmp     eax, 5        ; -1 <= 5 (signed)
    jle     .menorig_s
    jmp     .skip_menorig_s
.menorig_s:
    nop
.skip_menorig_s:

    ; --- JA / JNBE (acima — UNSIGNED) ---
    mov     eax, 200
    cmp     eax, 100      ; 200 > 100 (unsigned)
    ja      .acima
    jmp     .skip_acima
.acima:
    nop
.skip_acima:

    ; --- JB / JNAE / JC (abaixo — UNSIGNED / carry) ---
    mov     eax, 10
    cmp     eax, 200      ; 10 < 200 (unsigned)
    jb      .abaixo
    jmp     .skip_abaixo
.abaixo:
    nop
.skip_abaixo:

    ; --- JS / JNS (sinal / sem sinal no resultado) ---
    mov     eax, -1
    test    eax, eax      ; SF = 1 (número negativo)
    js      .negativo
    jmp     .skip_neg
.negativo:
    nop
.skip_neg:

    ; --- JO / JNO (overflow de signed) ---
    mov     eax, 0x7FFFFFFF   ; INT_MAX (32-bit)
    add     eax, 1             ; overflow! EAX = 0x80000000 = INT_MIN
    jo      .houve_overflow    ; OF = 1
    jmp     .skip_ov
.houve_overflow:
    nop
.skip_ov:

    ; --- JP / JNP (paridade) ---
    mov     al, 0x81          ; 0b10000001 — dois bits 1 → paridade EVEN
    test    al, al
    jp      .paridade_par     ; PF = 1 se byte baixo tem nº PAR de 1s
    jmp     .skip_pp
.paridade_par:
    nop
.skip_pp:

    pop     rbp
    ret

; ===========================================================================
; Padrão: loop com contador usando CMP + JNZ (mais explícito que LOOP)
; ===========================================================================
demo_loop:
    mov     rcx, 10         ; contador
    xor     rax, rax        ; acumulador = 0

.loop:
    add     rax, rcx        ; rax += rcx
    dec     rcx             ; rcx-- (não afeta CF)
    jnz     .loop           ; continua se rcx != 0

    ; RAX = 10 + 9 + 8 + ... + 1 = 55
    ret

; ===========================================================================
; JMP indireto via tabela (jump table / switch)
; ===========================================================================
demo_jump_table:
    ; Simula um switch de 0 a 3
    ; Entrada: RDI = case index (0-3)
    mov     rdi, 2          ; teste com case 2
    cmp     rdi, 3
    ja      .default_case   ; fora do range → default

    lea     rax, [rel .jump_table]
    mov     rax, [rax + rdi*8]  ; carrega endereço do case
    jmp     rax

.jump_table:
    dq .case0
    dq .case1
    dq .case2
    dq .case3

.case0: nop; jmp .fim_switch
.case1: nop; jmp .fim_switch
.case2: nop; jmp .fim_switch
.case3: nop; jmp .fim_switch
.default_case: nop
.fim_switch:
    ret

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    ; max(7, 3)
    mov     rdi, 7
    mov     rsi, 3
    call    max_signed
    mov     [rel res_max], rax   ; res_max = 7

    ; max(-5, -10) — com sinal
    mov     rdi, -5
    mov     rsi, -10
    call    max_signed
    ; RAX = -5

    call    demo_jcc
    call    demo_loop
    call    demo_jump_table

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
