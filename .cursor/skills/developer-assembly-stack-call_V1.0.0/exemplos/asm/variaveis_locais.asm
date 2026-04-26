; variaveis_locais.asm
; Acesso a variáveis locais via [RBP-8], [RBP-16]; alinhamento 16-byte
; Compilar: nasm -f elf64 variaveis_locais.asm -o variaveis_locais.o

bits 64

section .bss
    resultado resq 4

section .text
    global _start

; ===========================================================================
; Demonstra: layout de variáveis locais no stack frame
; ===========================================================================
demo_vars_locais:
    ; --- PROLOGUE ---
    push    rbp
    mov     rbp, rsp

    ; Reservar espaço para variáveis locais:
    ; Variáveis:
    ;   local_a: qword @ [rbp-8]
    ;   local_b: qword @ [rbp-16]
    ;   local_c: dword @ [rbp-20]  (mas alinhado a 4)
    ;   local_d: byte  @ [rbp-21]  (alinhado a 1)
    ; Total: 21 bytes → arredonda para múltiplo de 16 = 32 bytes
    sub     rsp, 32             ; reserva 32 bytes (16-byte aligned)

    ; Stack layout:
    ;   [rbp+8]  = return address
    ;   [rbp+0]  = saved rbp
    ;   [rbp-8]  = local_a (qword)
    ;   [rbp-16] = local_b (qword)
    ;   [rbp-20] = local_c (dword)
    ;   [rbp-21] = local_d (byte)
    ;   [rbp-32] = padding para alinhamento

    ; --- INICIALIZAR VARIÁVEIS LOCAIS ---
    mov     qword [rbp-8],  1000      ; local_a = 1000
    mov     qword [rbp-16], 2000      ; local_b = 2000
    mov     dword [rbp-20], 300       ; local_c = 300
    mov     byte  [rbp-21], 42        ; local_d = 42

    ; --- OPERAÇÕES COM VARIÁVEIS LOCAIS ---
    mov     rax, [rbp-8]        ; RAX = local_a
    add     rax, [rbp-16]       ; RAX = local_a + local_b = 3000
    mov     [rel resultado], rax

    ; Acessar dword local
    movzx   rbx, dword [rbp-20] ; RBX = local_c (zero-extended)
    add     rax, rbx             ; RAX += 300

    ; Acessar byte local
    movzx   rcx, byte [rbp-21]  ; RCX = local_d
    add     rax, rcx             ; RAX += 42

    ; RAX = 1000 + 2000 + 300 + 42 = 3342

    ; --- EPILOGUE ---
    mov     rsp, rbp
    pop     rbp
    ret

; ===========================================================================
; Demonstra: variáveis locais com registo de múltiplos tamanhos
; ===========================================================================
demo_arrays_locais:
    push    rbp
    mov     rbp, rsp

    ; Array local: 4 qwords = 32 bytes
    ; arr[0] @ [rbp-8], arr[1] @ [rbp-16], arr[2] @ [rbp-24], arr[3] @ [rbp-32]
    sub     rsp, 32             ; 4 qwords

    ; Inicializar array local via índice
    mov     qword [rbp-8],  10
    mov     qword [rbp-16], 20
    mov     qword [rbp-24], 30
    mov     qword [rbp-32], 40

    ; Somar todos os elementos
    xor     rax, rax
    add     rax, [rbp-8]
    add     rax, [rbp-16]
    add     rax, [rbp-24]
    add     rax, [rbp-32]
    ; RAX = 100

    ; Acesso via registrador como base para "índice":
    lea     rdx, [rbp-8]        ; RDX = &arr[0] (endereço do primeiro elemento)
    mov     rcx, 2              ; índice = 2
    mov     rbx, [rdx + rcx*8 - 8*2]  ; arr[0] (calculado: rdx = arr[0], rcx*8 offset)
    ; Nota: para arr[i] onde arr @ [rbp-8]: endereço = rbp-8 - i*8
    ; Mais simples: calcular endereço base explicitamente

    mov     rsp, rbp
    pop     rbp
    ret

; ===========================================================================
; Demonstra: alinhamento explícito do stack
; ===========================================================================
demo_alinhamento:
    push    rbp
    mov     rbp, rsp

    ; Garantir RSP alinhado a 16 antes de qualquer CALL:
    ; RSP após PUSH RBP = 16n - 8 - 8 = 16n - 16 = múltiplo de 16 ✓
    ; Após sub rsp, 32 → ainda múltiplo de 16 ✓

    sub     rsp, 32             ; shadow space + locais

    ; Se precisar de N bytes de locais:
    ; N arredondado = ((N + 15) / 16) * 16
    ; Exemplo: N=20 → ((20+15)/16)*16 = (35/16)*16 = 2*16 = 32

    ; Se adicionamos PUSH extras (callee-saved):
    ; Cada PUSH desloca RSP por 8 bytes
    ; Para manter alinhamento: número de PUSH adicionais DEVE ser PAR
    ; (ou fazer um sub rsp, 8 extra se for ímpar)

    push    rbx                 ; 1° push extra → RSP desalinhado
    push    r12                 ; 2° push extra → RSP realinhado ✓

    ; ... implementação ...

    pop     r12
    pop     rbx
    add     rsp, 32
    pop     rbp
    ret

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    call    demo_vars_locais
    call    demo_arrays_locais
    call    demo_alinhamento

    mov     rax, 60
    xor     rdi, rdi
    syscall
