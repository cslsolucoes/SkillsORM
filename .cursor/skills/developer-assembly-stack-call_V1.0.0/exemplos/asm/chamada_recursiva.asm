; chamada_recursiva.asm
; Fatorial recursivo para demonstrar frames aninhados
; Cada chamada cria um novo frame; o debugger mostra a pilha de frames
; Compilar: nasm -f elf64 chamada_recursiva.asm -o chamada_recursiva.o

bits 64

section .bss
    resultado resq 1

section .text
    global _start

; ===========================================================================
; Fatorial recursivo: fatorial(n) = n * fatorial(n-1)
; Base: fatorial(0) = 1, fatorial(1) = 1
;
; Convenção Linux x64: RDI = n, retorno em RAX
;
; Stack de chamadas para fatorial(4):
;   fatorial(4):  [RBP] = saved_rbp_3, n=4
;     fatorial(3):  [RBP] = saved_rbp_2, n=3
;       fatorial(2):  [RBP] = saved_rbp_1, n=2
;         fatorial(1):  [RBP] = saved_rbp_0, n=1 → retorna 1
;       retorna 2*1 = 2
;     retorna 3*2 = 6
;   retorna 4*6 = 24
; ===========================================================================
fatorial:
    ; --- PROLOGUE ---
    push    rbp
    mov     rbp, rsp
    sub     rsp, 16             ; espaço para variável local (n salvo)
    push    rbx                 ; callee-saved — usado para guardar n
    ; Total pushes: push rbp (8) + sub 16 + push rbx (8) = 32 bytes
    ; RSP alinhado? Antes do CALL: RSP era múltiplo de 16
    ; Após CALL: RSP = 16n-8 (return addr empilhado)
    ; push rbp: RSP = 16n-16 = múltiplo de 16
    ; sub 16:   RSP = 16n-32 = múltiplo de 16
    ; push rbx: RSP = 16n-40 = não múltiplo de 16!
    ; Adicionar 1 push extra ou ajuste para alinhar:
    push    r12                 ; 2° push extra → RSP = 16n-48 = múltiplo de 16 ✓

    ; --- CASO BASE ---
    mov     rbx, rdi            ; RBX = n (preservar)
    cmp     rbx, 1
    jle     .base_case          ; n <= 1: retorna 1

    ; --- CASO RECURSIVO ---
    ; Chamar fatorial(n-1)
    lea     rdi, [rbx-1]        ; RDI = n-1
    call    fatorial            ; RAX = fatorial(n-1)

    ; Multiplicar n * fatorial(n-1)
    imul    rax, rbx            ; RAX = n * fatorial(n-1)
    jmp     .fim

.base_case:
    mov     rax, 1              ; fatorial(0) = fatorial(1) = 1

.fim:
    ; --- EPILOGUE ---
    pop     r12
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret

; ===========================================================================
; Fibonacci recursivo: fib(n) = fib(n-1) + fib(n-2)
; (exponencialmente lento — apenas para demonstrar múltiplos calls)
; ===========================================================================
fibonacci:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    ; 2 pushes adicionais = 16 bytes → RSP alinhado ✓

    mov     rbx, rdi            ; RBX = n

    cmp     rbx, 1
    jle     .fib_base           ; n <= 1: retorna n

    ; fib(n-1)
    lea     rdi, [rbx-1]
    call    fibonacci
    mov     r12, rax            ; R12 = fib(n-1)

    ; fib(n-2)
    lea     rdi, [rbx-2]
    call    fibonacci
    ; RAX = fib(n-2)

    add     rax, r12            ; RAX = fib(n-1) + fib(n-2)
    jmp     .fib_fim

.fib_base:
    mov     rax, rbx            ; retorna n (fib(0)=0, fib(1)=1)

.fib_fim:
    pop     r12
    pop     rbx
    pop     rbp
    ret

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    ; Testar fatorial
    mov     rdi, 10
    call    fatorial
    mov     [rel resultado], rax    ; resultado = 10! = 3628800

    ; Testar fibonacci (pequeno N)
    mov     rdi, 10
    call    fibonacci               ; fib(10) = 55

    mov     rax, 60
    xor     rdi, rdi
    syscall
