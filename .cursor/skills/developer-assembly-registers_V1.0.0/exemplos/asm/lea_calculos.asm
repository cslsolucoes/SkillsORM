; lea_calculos.asm
; Demonstra LEA como calculadora: multiplicação por constantes pequenas
; sem usar MUL — mais rápido e sem afetar flags nem RDX
; Compilar: nasm -f elf64 lea_calculos.asm -o lea_calculos.o

bits 64

section .bss
    resultado resq 16   ; 16 qwords para resultados

section .text
    global _start

_start:

    ; =========================================================================
    ; LEA como calculadora de multiplicação por constantes
    ; LEA dst, [base + idx*scale + disp]
    ; Vantagem: não afeta flags, não toca RDX, usa latência de 1 ciclo (AGU)
    ; =========================================================================

    ; --- Multiplicar por 2 ---
    mov     rax, 10
    lea     rbx, [rax*2]        ; RBX = 10 * 2 = 20

    ; --- Multiplicar por 3 ---
    mov     rax, 7
    lea     rbx, [rax + rax*2]  ; RBX = RAX + RAX*2 = RAX*3 = 21

    ; --- Multiplicar por 4 ---
    mov     rax, 5
    lea     rbx, [rax*4]        ; RBX = 5 * 4 = 20

    ; --- Multiplicar por 5 ---
    mov     rax, 6
    lea     rbx, [rax + rax*4]  ; RBX = RAX + RAX*4 = RAX*5 = 30

    ; --- Multiplicar por 8 ---
    mov     rax, 3
    lea     rbx, [rax*8]        ; RBX = 3 * 8 = 24

    ; --- Multiplicar por 9 ---
    mov     rax, 4
    lea     rbx, [rax + rax*8]  ; RBX = RAX + RAX*8 = RAX*9 = 36

    ; --- Multiplicar por 10 (= 2 * 5) ---
    mov     rax, 7
    lea     rbx, [rax + rax*4]  ; RBX = 7 * 5 = 35
    lea     rbx, [rbx + rbx]    ; RBX = 35 * 2 = 70  (= 7 * 10)

    ; --- Multiplicar por 6 ---
    mov     rax, 8
    lea     rbx, [rax + rax*2]  ; RBX = 8 * 3 = 24
    lea     rbx, [rbx + rbx]    ; RBX = 24 * 2 = 48  (= 8 * 6)

    ; --- Multiplicar por 7 ---
    mov     rax, 5
    lea     rbx, [rax*8]        ; RBX = 5 * 8 = 40
    sub     rbx, rax            ; RBX = 40 - 5 = 35  (= 5 * 7)
    ; Alternativo: lea rbx, [rax + rax*2] → *3; lea rbx,[rbx+rbx*2] → *9... não é 7 direto
    ; A forma sub é mais limpa para *7

    ; =========================================================================
    ; LEA para cálculo de endereços de array (uso primário)
    ; =========================================================================

    ; Simular: ptr = &array[i] onde array é de Int32 (4 bytes cada)
    ; Fórmula: endereço = base + i * 4
    lea     rsi, [rel resultado]  ; RSI = base do array
    mov     rcx, 3                ; índice i = 3
    lea     rdi, [rsi + rcx*8]    ; RDI = &resultado[3] (cada elemento = 8 bytes = qword)
    mov     qword [rdi], 99       ; resultado[3] = 99

    ; =========================================================================
    ; LEA para cálculo com offset (acesso a campos de struct)
    ; Simular: ptr_to_field = &obj.campo onde campo está a +24 bytes do início
    ; =========================================================================

    ; Supondo RAX = endereço de objeto
    ; Campo 'valor' está no offset 24 do objeto:
    ; lea  rbx, [rax + 24]   → RBX = endereço de obj.valor

    ; =========================================================================
    ; Comparação: LEA vs MUL para multiplicação por constante
    ; =========================================================================
    ; LEA (para constantes pequenas — até ~12):
    ;   - 1-2 ciclos de latência
    ;   - não afeta flags
    ;   - não usa RDX
    ;
    ; IMUL (para constantes maiores):
    ;   mov ecx, 13
    ;   imul eax, ecx       ; 3 ciclos, mas qualquer constante
    ;   imul eax, eax, 100  ; forma com imediato — qualquer constante, conveniente

    mov     rax, 7
    imul    rax, rax, 100   ; RAX = 700 (forma de 3 operandos — não afeta RDX)

    ; =========================================================================
    ; Encerrar
    ; =========================================================================
    mov     rax, 60
    xor     rdi, rdi
    syscall
