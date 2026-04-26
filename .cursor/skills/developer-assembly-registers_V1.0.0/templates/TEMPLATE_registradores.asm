; TEMPLATE_registradores.asm
; Demonstração NASM: todos os tamanhos de registradores x86-64
; e padrões de uso correto (zero-extension, sign-extension, preservação)
;
; Compilar (Linux): nasm -f elf64 TEMPLATE_registradores.asm -o TEMPLATE_registradores.o
; Compilar (Win64): nasm -f win64 TEMPLATE_registradores.asm -o TEMPLATE_registradores.obj

bits 64

section .data
    ; Dados de teste
    val_byte   db  0x42
    val_word   dw  0xABCD
    val_dword  dd  0xDEADBEEF
    val_qword  dq  0xCAFEBABEDEADBEEF

section .bss
    ; Resultados
    res_rax resq 1
    res_rbx resq 1
    res_rcx resq 1

section .text
    global _start

; ===========================================================================
; Macro auxiliar para demonstração (não necessária em código real)
; Salva RAX em memória para inspeção
; ===========================================================================
%macro SAVE_RAX 1
    mov     [rel %1], rax
%endmacro

; ===========================================================================
; Função de demonstração: padrões de zero-extension
; ===========================================================================
demo_zero_extension:
    push    rbp
    mov     rbp, rsp
    push    rbx         ; callee-saved

    ; --- EAX zero-extends RAX ---
    mov     rax, 0xFFFFFFFFFFFFFFFF   ; RAX = todo 1s
    mov     eax, 0x12345678           ; RAX = 0x0000000012345678 (zero-extend!)
    SAVE_RAX res_rax

    ; --- AX NÃO zero-extends ---
    mov     rax, 0xFFFFFFFFFFFFFFFF   ; RAX = todo 1s
    mov     ax, 0x1234                ; RAX = 0xFFFFFFFFFFFF1234 (SEM zero-extend)

    ; --- AL NÃO zero-extends ---
    mov     rax, 0xFFFFFFFFFFFFFFFF
    mov     al, 0x42                  ; RAX = 0xFFFFFFFFFFFFFF42

    ; --- MOVZX: zero-extension explícita ---
    mov     al, 0xFF                  ; AL = 255
    movzx   ebx, al                   ; EBX = 255, RBX = 0x00000000000000FF
    movzx   ecx, ax                   ; ECX = zero-extend AX para 32-bit

    ; --- MOVSX: sign-extension ---
    mov     al, 0x80                  ; AL = -128 (signed)
    movsx   ebx, al                   ; EBX = 0xFFFFFF80 = -128 (32-bit)
    movsx   rbx, al                   ; RBX = 0xFFFFFFFFFFFFFF80 = -128 (64-bit)

    mov     al, 0x7F                  ; AL = +127
    movsx   rbx, al                   ; RBX = 0x000000000000007F = +127

    pop     rbx
    pop     rbp
    ret

; ===========================================================================
; Função de demonstração: preservação de registradores (Windows x64 ABI)
; Salva e restaura: RBX, RSI, RDI, RBP (RSP mantido pela stack)
; ===========================================================================
demo_preservacao:
    ; Prologue
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32         ; shadow space (Windows x64 obrigatório)

    ; Salvar registradores callee-saved que vamos usar
    push    rbx
    push    rsi
    push    rdi
    push    r12
    push    r13
    ; Após 5 PUSH: RSP misalignado de 16? Verificar:
    ; rbp = rsp original antes do prologue (estava alinhado)
    ; sub rsp, 32 → ainda alinhado
    ; push rbx → RSP -= 8 → misaligned
    ; push rsi → RSP -= 8 → aligned
    ; push rdi → misaligned
    ; push r12 → aligned
    ; push r13 → misaligned
    ; Adicionar um push extra ou sub rsp, 8 para alinhar:
    sub     rsp, 8          ; alinhar RSP a 16-byte (agora é múltiplo de 16)

    ; Usar os registradores livremente
    mov     rbx, 0xDEADBEEF00000001
    mov     rsi, 0xCAFEBABE00000002
    mov     rdi, 0xABABABAB00000003
    mov     r12, 0x1234567800000004
    mov     r13, 0x8888888800000005

    ; Implementação real vai aqui...

    ; Epilogue: restaurar na ordem INVERSA
    add     rsp, 8          ; desfaz o alinhamento extra
    pop     r13
    pop     r12
    pop     rdi
    pop     rsi
    pop     rbx

    add     rsp, 32         ; libera shadow space
    pop     rbp
    ret

; ===========================================================================
; Ponto de entrada principal
; ===========================================================================
_start:
    ; Chamar demos
    call    demo_zero_extension
    call    demo_preservacao

    ; Inspecionar resultados em [res_rax], [res_rbx], [res_rcx] via debugger

    ; Encerrar
    mov     rax, 60         ; sys_exit (Linux)
    xor     rdi, rdi        ; exit code = 0
    syscall
