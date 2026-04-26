; registradores_gp.asm
; Demonstra MOV em todos os tamanhos de RAX: RAX/EAX/AX/AL/AH
; e o comportamento de zero-extension ao escrever em registradores 32-bit
; Compilar: nasm -f elf64 registradores_gp.asm -o registradores_gp.o

bits 64

section .data
    valor64  dq 0xCAFEBABEDEADBEEF  ; qword para carregar
    valor32  dd 0xDEADBEEF           ; dword para carregar
    valor16  dw 0xABCD               ; word para carregar
    valor8   db 0x42                 ; byte para carregar

section .bss
    resultado resq 1                  ; 8 bytes para salvar resultado

section .text
    global _start

_start:

    ; -----------------------------------------------------------------------
    ; PARTE 1: Carregamento em diferentes tamanhos de RAX
    ; -----------------------------------------------------------------------

    ; Carregar qword completo (64 bits)
    mov     rax, [rel valor64]      ; RAX = 0xCAFEBABEDEADBEEF
    ; RAX: [63:32]=0xCAFEBABE  [31:16]=0xDEAD  [15:8]=0xBE  [7:0]=0xEF

    ; Carregar dword — ZERA automaticamente bits [63:32] de RAX!
    mov     rax, 0xFFFFFFFFFFFFFFFF ; setup: RAX todo 0xFF
    mov     eax, [rel valor32]      ; EAX = 0xDEADBEEF → RAX = 0x00000000DEADBEEF
    ; Os 32 bits superiores foram zerados automaticamente!

    ; Carregar word — NÃO zera os bits superiores
    mov     rax, 0xFFFFFFFFFFFFFFFF ; setup
    mov     ax,  [rel valor16]      ; AX = 0xABCD → RAX = 0xFFFFFFFFFFFFABCD
    ; Apenas os 16 bits inferiores foram alterados

    ; Carregar byte baixo (AL) — NÃO zera os bits superiores
    mov     rax, 0xFFFFFFFFFFFFFFFF ; setup
    mov     al,  [rel valor8]       ; AL = 0x42 → RAX = 0xFFFFFFFFFFFFFF42

    ; Carregar byte alto (AH) — apenas bits [15:8]
    mov     rax, 0xFFFFFFFFFFFFFFFF ; setup
    mov     ah,  0x00               ; AH = 0x00 → RAX = 0xFFFFFFFFFFFF00FF
    ; bits [15:8] = 0x00, demais inalterados

    ; -----------------------------------------------------------------------
    ; PARTE 2: Mesma demonstração com outros registradores
    ; -----------------------------------------------------------------------

    ; RBX / EBX / BX / BL / BH
    mov     rbx, 0xFFFFFFFFFFFFFFFF
    mov     ebx, 0x12345678         ; RBX = 0x0000000012345678 (zero-extend)
    mov     bx,  0xABCD             ; RBX = 0x000000001234ABCD
    mov     bl,  0x00               ; RBX = 0x000000001234AB00
    mov     bh,  0xFF               ; RBX = 0x000000001234FF00

    ; RCX / ECX / CX / CL / CH
    mov     rcx, 0xFFFFFFFFFFFFFFFF
    mov     ecx, 0xAABBCCDD         ; RCX = 0x00000000AABBCCDD

    ; RDX / EDX / DX / DL / DH
    mov     rdx, 0
    mov     edx, 1000               ; EDX = 1000, RDX = 1000 (zero-extend)

    ; -----------------------------------------------------------------------
    ; PARTE 3: Movimentação MOVZX e MOVSX
    ; -----------------------------------------------------------------------

    ; MOVZX: move com zero-extension (sem sinal)
    mov     al, 0xFF                ; AL = 255 (como unsigned)
    movzx   eax, al                 ; EAX = 255 (0x000000FF) — zero-extended
    movzx   rax, al                 ; RAX = 255 (0x00000000000000FF)

    ; MOVSX: move com sign-extension (com sinal)
    mov     al, 0xFF                ; AL = -1 (como signed, complemento de 2)
    movsx   eax, al                 ; EAX = -1 (0xFFFFFFFF) — sign-extended
    movsx   rax, al                 ; RAX = -1 (0xFFFFFFFFFFFFFFFF)

    mov     al, 0x7F                ; AL = +127 (positivo)
    movsx   eax, al                 ; EAX = +127 (0x0000007F) — sinal 0, zero-fill

    ; -----------------------------------------------------------------------
    ; Encerrar
    ; -----------------------------------------------------------------------
    xor     eax, eax                ; RAX = 0
    mov     rax, 60                 ; sys_exit
    xor     rdi, rdi
    syscall
