; conditional_ops.asm
; Demonstra SETcc e CMOVcc — operações condicionais sem branch
; Técnica "branch-free": evita mispredictions em loops de alta performance
; Compilar: nasm -f elf64 conditional_ops.asm -o conditional_ops.o

bits 64

section .bss
    resultado resq 1

section .text
    global _start

; ===========================================================================
; SETcc — seta byte de destino para 0 ou 1 baseado em flags
; Equivale a: dst = (condição) ? 1 : 0
; ===========================================================================
demo_setcc:
    ; SETE/SETZ: seta se igual (ZF=1)
    mov     eax, 5
    cmp     eax, 5          ; ZF = 1 (iguais)
    sete    bl              ; BL = 1 (porque ZF=1)

    cmp     eax, 10         ; ZF = 0 (diferentes)
    sete    bl              ; BL = 0 (porque ZF=0)
    movzx   ebx, bl         ; zero-extend para uso como Integer

    ; SETG/SETA: seta se maior (signed/unsigned)
    mov     eax, 10
    cmp     eax, 5
    setg    bl              ; BL = 1 (10 > 5, signed)

    ; SETL: seta se menor (signed)
    mov     eax, -5
    cmp     eax, 0
    setl    bl              ; BL = 1 (-5 < 0)

    ; SETNZ: seta se não zero (útil para bool)
    mov     eax, 42
    test    eax, eax
    setnz   bl              ; BL = 1 (EAX != 0)

    ; SETS: seta se negativo (SF=1)
    mov     eax, -1
    test    eax, eax
    sets    bl              ; BL = 1 (SF=1)

    ret

; ===========================================================================
; CMOVcc — move condicional (sem branch!)
; Equivale a: if (condição) dst = src
; NOTA: CMOVcc lê o src SEMPRE — não há curto-circuito de memória
; ===========================================================================
demo_cmovcc:
    ; max(a, b) sem branch usando CMOVL
    mov     rdi, 7          ; a = 7
    mov     rsi, 3          ; b = 3

    mov     rax, rdi        ; rax = a (candidato inicial)
    cmp     rdi, rsi
    cmovl   rax, rsi        ; se a < b (signed), rax = b
    ; RAX = 7 (max)

    ; min(a, b):
    mov     rax, rdi        ; rax = a
    cmp     rdi, rsi
    cmovg   rax, rsi        ; se a > b, rax = b
    ; RAX = 3 (min)

    ; Clamp: limitar valor ao intervalo [lo, hi]
    ; valor = max(lo, min(hi, x))
    mov     r8,  5          ; x = 5
    mov     r9,  1          ; lo = 1
    mov     r10, 10         ; hi = 10

    mov     rax, r8         ; rax = x
    cmp     rax, r9
    cmovl   rax, r9         ; se x < lo, rax = lo
    cmp     rax, r10
    cmovg   rax, r10        ; se x > hi, rax = hi
    ; RAX = clamp(5, 1, 10) = 5

    ; Teste com valor fora do range:
    mov     r8, 15          ; x = 15 (> hi=10)
    mov     rax, r8
    cmp     rax, r9
    cmovl   rax, r9
    cmp     rax, r10
    cmovg   rax, r10
    ; RAX = 10 (clamped)

    ret

; ===========================================================================
; Exemplo performance-critical: valor absoluto sem branch
; ===========================================================================
; abs(x) sem branch:
;   mask = x >> 63  (SAR propaga o bit de sinal: -1 ou 0)
;   return (x XOR mask) - mask
abs_no_branch:
    ; Entrada: RDI = x (signed)
    ; Saída:   RAX = abs(x)
    mov     rax, rdi
    mov     rdx, rdi
    sar     rdx, 63         ; RDX = 0 se x >= 0, 0xFFFFFFFFFFFFFFFF se x < 0
    xor     rax, rdx        ; complementa bits se negativo
    sub     rax, rdx        ; adiciona 1 se negativo (equivalente ao NOT + 1)
    ret

; ===========================================================================
; Exemplo: contagem de valores positivos sem branch (SETcc + ADD)
; ===========================================================================
contar_positivos:
    ; Entrada: RSI = ponteiro para array de int64, RDX = count
    ; Saída:   RAX = número de elementos positivos
    xor     rax, rax        ; contador = 0
    xor     rcx, rcx        ; índice = 0

.loop:
    cmp     rcx, rdx
    jge     .fim
    mov     r8, [rsi + rcx*8]
    test    r8, r8
    setg    r9b             ; R9B = 1 se r8 > 0
    movzx   r9d, r9b
    add     rax, r9         ; contador += (r8 > 0 ? 1 : 0)
    inc     rcx
    jmp     .loop
.fim:
    ret

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    call    demo_setcc
    call    demo_cmovcc

    ; Teste abs_no_branch
    mov     rdi, -42
    call    abs_no_branch   ; RAX = 42

    mov     rdi, 42
    call    abs_no_branch   ; RAX = 42

    mov     rdi, 0
    call    abs_no_branch   ; RAX = 0

    mov     rax, 60
    xor     rdi, rdi
    syscall
