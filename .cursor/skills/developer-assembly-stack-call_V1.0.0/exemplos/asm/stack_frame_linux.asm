; stack_frame_linux.asm
; Prologue canônico Linux x64: PUSH RBP / MOV RBP,RSP / SUB RSP,N
; Demonstra stack frame completo com variáveis locais e chamada aninhada
; Compilar: nasm -f elf64 stack_frame_linux.asm -o stack_frame_linux.o
; Linkar:   ld stack_frame_linux.o -o stack_frame_linux

bits 64

section .data
    msg     db 'resultado: ', 0
    newline db 0x0A

section .bss
    buf     resb 32

section .text
    global _start

; ===========================================================================
; Função: soma_simples(a, b) → a + b
; Stack frame com variáveis locais
; Convenção Linux x64: RDI=a, RSI=b
; ===========================================================================
soma_simples:
    ; --- PROLOGUE ---
    push    rbp                 ; salva frame pointer anterior [RSP-8]
    mov     rbp, rsp            ; RBP = novo frame pointer
    sub     rsp, 16             ; reserva 16 bytes para variáveis locais
    ; Stack atual (crescendo para baixo):
    ;   [RBP+16] — 2° arg via stack se houver
    ;   [RBP+8]  — return address (CALL empilhou)
    ;   [RBP+0]  — saved RBP ← RBP aponta aqui
    ;   [RBP-8]  — variável local 1 (local_a)
    ;   [RBP-16] — variável local 2 (local_b)

    ; Salvar parâmetros em variáveis locais (exemplo)
    mov     [rbp-8],  rdi       ; local_a = a
    mov     [rbp-16], rsi       ; local_b = b

    ; Computar resultado
    mov     rax, [rbp-8]        ; RAX = a
    add     rax, [rbp-16]       ; RAX = a + b

    ; --- EPILOGUE ---
    mov     rsp, rbp            ; restaura stack pointer
    pop     rbp                 ; restaura frame pointer
    ret

; ===========================================================================
; Função: calcula(n) — usa variáveis locais e faz chamada aninhada
; Demonstra frame aninhado: chama soma_simples internamente
; ===========================================================================
calcula:
    ; --- PROLOGUE ---
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32             ; 32 bytes locais (alinhado a 16: 8 + 24 = 32)
    push    rbx                 ; salvar RBX (callee-saved) — desalinha RSP
    push    r12                 ; salvar R12 — realinha RSP (2 push = 16 bytes)

    ; Após 2 pushes adicionais: RSP está alinhado a 16 novamente
    ; (RBP era múltiplo de 16 após MOV RBP,RSP; sub rsp,32 mantém alinhamento;
    ;  2 push de 8 bytes cada = 16 bytes → ainda alinhado)

    ; Parâmetros: RDI = n
    mov     rbx, rdi            ; RBX = n (preservar para uso posterior)
    mov     r12, 0              ; R12 = acumulador = 0

    ; Loop: soma de 1 a n chamando soma_simples
    mov     r8, 1               ; i = 1
.loop:
    cmp     r8, rbx             ; i > n?
    jg      .fim_loop

    ; Chamar soma_simples(acumulador, i)
    mov     rdi, r12            ; arg1 = acumulador
    mov     rsi, r8             ; arg2 = i
    call    soma_simples        ; RAX = acumulador + i
    mov     r12, rax            ; acumulador = resultado

    inc     r8
    jmp     .loop

.fim_loop:
    mov     rax, r12            ; retorno = acumulador

    ; --- EPILOGUE ---
    pop     r12                 ; restaurar na ordem inversa
    pop     rbx
    mov     rsp, rbp
    pop     rbp
    ret

; ===========================================================================
; Função: frame_sem_vars(a, b) — função sem variáveis locais
; Pode omitir SUB RSP,N se não precisar de locals
; ===========================================================================
frame_sem_vars:
    push    rbp
    mov     rbp, rsp
    ; Sem SUB RSP — sem variáveis locais

    ; RDI = a, RSI = b
    mov     rax, rdi
    sub     rax, rsi            ; RAX = a - b

    pop     rbp
    ret

; ===========================================================================
; Função leaf: sem frame (sem CALL interna)
; Função folha: não chama outras funções → pode omitir prologue
; ===========================================================================
incrementar:
    ; RDI = x (input), sem frame necessário
    lea     rax, [rdi + 1]      ; RAX = x + 1
    ret                         ; sem prologue/epilogue

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    ; soma_simples(7, 3) = 10
    mov     rdi, 7
    mov     rsi, 3
    call    soma_simples
    ; RAX = 10

    ; calcula(10) = 1+2+3+...+10 = 55
    mov     rdi, 10
    call    calcula
    ; RAX = 55

    ; frame_sem_vars(100, 42) = 58
    mov     rdi, 100
    mov     rsi, 42
    call    frame_sem_vars
    ; RAX = 58

    ; incrementar(99) = 100
    mov     rdi, 99
    call    incrementar
    ; RAX = 100

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
