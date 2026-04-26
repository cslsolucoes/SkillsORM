; aritmetica.asm
; Demonstra instruções aritméticas: ADD, SUB, INC, DEC, MUL, IMUL, DIV, IDIV, NEG, ADC, SBB
; Compilar: nasm -f elf64 aritmetica.asm -o aritmetica.o

bits 64

section .data
    val_a   dq  100
    val_b   dq   37
    val_c   dd  -7       ; valor negativo para IDIV

section .bss
    res_add  resq 1
    res_sub  resq 1
    res_mul  resq 1
    res_div  resq 1
    res_mod  resq 1

section .text
    global _start

_start:

    ; =========================================================================
    ; ADD — adição
    ; =========================================================================
    mov     rax, [rel val_a]    ; RAX = 100
    mov     rbx, [rel val_b]    ; RBX = 37
    add     rax, rbx            ; RAX = 137
    mov     [rel res_add], rax

    ; ADD com imediato:
    mov     eax, 50
    add     eax, 25             ; EAX = 75

    ; ADD de memória:
    add     qword [rel val_a], 10   ; val_a += 10 (agora 110)

    ; =========================================================================
    ; SUB — subtração
    ; =========================================================================
    mov     rax, 200
    mov     rbx, 75
    sub     rax, rbx            ; RAX = 125
    mov     [rel res_sub], rax

    ; =========================================================================
    ; INC / DEC — não afetam CF!
    ; =========================================================================
    mov     ecx, 10
    inc     ecx                 ; ECX = 11
    dec     ecx                 ; ECX = 10
    dec     ecx                 ; ECX = 9

    ; =========================================================================
    ; NEG — negação (complemento de dois)
    ; =========================================================================
    mov     eax, 42
    neg     eax                 ; EAX = -42
    neg     eax                 ; EAX = 42 (negação dupla restaura)

    ; =========================================================================
    ; ADC — Add with Carry (para aritmética de precisão múltipla)
    ; Exemplo: somar dois inteiros de 128 bits (RDX:RAX + RCX:RBX)
    ; =========================================================================
    ; 128-bit resultado = [RAX low] + [RBX low]
    mov     rax, 0xFFFFFFFFFFFFFFFF  ; low parte do 1° número
    mov     rdx, 0x0000000000000000  ; high parte do 1° número
    mov     rbx, 0x0000000000000001  ; low parte do 2° número
    mov     rcx, 0x0000000000000000  ; high parte do 2° número
    add     rax, rbx                 ; soma low: RAX = 0 (com CF=1)
    adc     rdx, rcx                 ; soma high + CF: RDX = 1
    ; Resultado 128-bit: RDX:RAX = 0x00000000000000010000000000000000

    ; =========================================================================
    ; SBB — Subtract with Borrow
    ; =========================================================================
    mov     rax, 0x0000000000000000   ; low
    mov     rdx, 0x0000000000000001   ; high
    mov     rbx, 0x0000000000000001   ; subtrair low
    xor     rcx, rcx
    sub     rax, rbx                  ; RAX = -1 = 0xFFFFFFFFFFFFFFFF, CF=1
    sbb     rdx, rcx                  ; RDX = 1 - 0 - CF = 0
    ; Resultado: RDX:RAX = 0x0000000000000000:0xFFFFFFFFFFFFFFFF

    ; =========================================================================
    ; MUL — multiplicação sem sinal
    ; Resultado: RDX:RAX = RAX * operando
    ; =========================================================================
    mov     rax, 1000000
    mov     rbx, 1000000
    mul     rbx                       ; RDX:RAX = 1000000 * 1000000 = 10^12
    mov     [rel res_mul], rax        ; salva parte baixa

    ; Verificar se houve overflow (resultado > 64-bit):
    ; Se RDX != 0, houve overflow no multiplicador de 64-bit
    test    rdx, rdx
    jnz     .overflow_mul
    jmp     .sem_overflow_mul
.overflow_mul:
    ; RDX tem parte alta do resultado (normalmente isso seria erro)
.sem_overflow_mul:

    ; =========================================================================
    ; IMUL — multiplicação com sinal
    ; Formas: 1 operando (RDX:RAX), 2 operandos (dst * src), 3 operandos (dst = src * imm)
    ; =========================================================================
    ; Forma 1 operando (equivale ao MUL mas com sinal):
    mov     rax, -7
    mov     rbx, 6
    imul    rbx                       ; RDX:RAX = RAX * RBX = -42

    ; Forma 2 operandos (resultado truncado — mais comum):
    mov     rax, 100
    mov     rbx, -3
    imul    rax, rbx                  ; RAX = 100 * -3 = -300

    ; Forma 3 operandos com imediato:
    imul    rax, rbx, 7               ; RAX = RBX * 7

    ; =========================================================================
    ; DIV — divisão sem sinal
    ; Dividendo: RDX:RAX
    ; Divisor: operando
    ; Resultado: RAX = quociente, RDX = resto
    ; ATENÇÃO: divisão por zero → exceção #DE!
    ; =========================================================================
    xor     rdx, rdx                  ; OBRIGATÓRIO: zerar RDX antes de DIV 64-bit!
    mov     rax, 100
    mov     rbx, 7
    div     rbx                       ; RAX = 100/7 = 14, RDX = 100%7 = 2
    mov     [rel res_div], rax
    mov     [rel res_mod], rdx

    ; =========================================================================
    ; IDIV — divisão com sinal
    ; Dividendo: RDX:RAX (com sinal)
    ; CQO (Convert Quadword to Octword) = sign-extends RAX into RDX:RAX
    ; =========================================================================
    mov     rax, -100
    cqo                               ; sign-extends RAX → RDX:RAX (RDX = 0xFFFFFFFFFFFFFFFF)
    mov     rbx, 7
    idiv    rbx                       ; RAX = -100/7 = -14 (arredonda para zero), RDX = -2

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
