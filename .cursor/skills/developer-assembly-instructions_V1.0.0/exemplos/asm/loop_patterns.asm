; loop_patterns.asm
; Demonstra padrões de loop: LOOP, LOOPE, LOOPNE vs CMP+Jcc
; Compilar: nasm -f elf64 loop_patterns.asm -o loop_patterns.o

bits 64

section .data
    array   dq 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    arr_len equ ($ - array) / 8       ; 10 elementos

section .bss
    soma    resq 1

section .text
    global _start

; ===========================================================================
; Padrão 1: Instrução LOOP (ECX/RCX como contador)
; LOOP label ≡ DEC RCX; JNZ label
; NOTA: LOOP não afeta flags! LOOP é mais lento que DEC+JNZ em CPUs modernas.
; ===========================================================================
demo_loop_instruction:
    mov     rcx, 10         ; contador = 10
    xor     rax, rax        ; acumulador = 0
.loop1:
    add     rax, rcx        ; acumula: 10, 9, 8, ..., 1
    loop    .loop1          ; RCX--; se RCX != 0, volta para .loop1
    ; RAX = 55 (soma de 1 a 10)
    mov     [rel soma], rax
    ret

; ===========================================================================
; Padrão 2: LOOPE (Loop while Equal) / LOOPZ
; LOOPE: DEC RCX; JNZ AND ZF=1 → continua enquanto RCX != 0 E ZF=1
; Útil para busca com verificação de condição em cada iteração
; ===========================================================================
demo_loope:
    ; Busca primeira posição onde array[i] > 5
    lea     rsi, [rel array]
    mov     rcx, arr_len

.loope_loop:
    mov     rax, [rsi]
    cmp     rax, 5          ; compara elemento com 5
    rsi_inc:
    add     rsi, 8          ; avança ponteiro (modifica flags? NÃO — ADD afeta flags)
    ; CUIDADO: LOOPE testa ZF do CMP acima, mas ADD acima pode sobrescrever ZF!
    ; Por isso LOOPE é raramente usado — preferir CMP + Jcc explícito
    loope   .loope_loop
    ; Quando para: RCX=0 (fim) OU ZF=0 (elemento > 5 encontrado)
    ret

; ===========================================================================
; Padrão 3: CMP + Jcc (recomendado — mais explícito e mais rápido)
; ===========================================================================
demo_cmp_jcc:
    ; Soma de array de qwords
    lea     rsi, [rel array]
    mov     rcx, arr_len
    xor     rax, rax        ; acumulador = 0

.cmp_loop:
    test    rcx, rcx        ; RCX == 0?
    jz      .cmp_fim        ; sim → termina
    add     rax, [rsi]      ; acumulador += array[i]
    add     rsi, 8          ; ponteiro += sizeof(qword)
    dec     rcx             ; contador--
    jmp     .cmp_loop       ; volta (poderia usar JNZ acima do dec)

.cmp_fim:
    ret                     ; RAX = 55

; ===========================================================================
; Padrão 4: Loop com índice (mais idiomático para arrays)
; ===========================================================================
demo_loop_indexed:
    lea     rsi, [rel array]
    xor     rcx, rcx        ; índice i = 0
    xor     rax, rax        ; acumulador

.idx_loop:
    cmp     rcx, arr_len    ; i >= arr_len?
    jge     .idx_fim
    add     rax, [rsi + rcx*8]  ; acumulador += array[i]
    inc     rcx
    jmp     .idx_loop

.idx_fim:
    ret                     ; RAX = 55

; ===========================================================================
; Padrão 5: Loop com ponteiro (mais eficiente — sem multiplicação por escala)
; ===========================================================================
demo_loop_pointer:
    lea     rsi, [rel array]
    lea     rdi, [rel array + arr_len*8]  ; ptr end = one past last element
    xor     rax, rax

.ptr_loop:
    cmp     rsi, rdi        ; chegou no fim?
    jge     .ptr_fim
    add     rax, [rsi]      ; acumulador += *ptr
    add     rsi, 8          ; ptr++
    jmp     .ptr_loop

.ptr_fim:
    ret                     ; RAX = 55

; ===========================================================================
; Padrão 6: Loop com REP (mais eficiente para cópias/preenchimentos)
; ===========================================================================
; Ver string_operations.asm para exemplos de REP MOVS*/STOS*/CMPS*/SCAS*

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    call    demo_loop_instruction
    call    demo_cmp_jcc
    call    demo_loop_indexed
    call    demo_loop_pointer

    mov     rax, 60
    xor     rdi, rdi
    syscall
