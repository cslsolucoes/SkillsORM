; registradores_subdivisoes.asm
; Demonstra as subdivisões de RAX: RAX/EAX/AX/AL/AH
; e o comportamento crítico de zero-extension ao escrever em 32-bit
; Compilar: nasm -f elf64 registradores_subdivisoes.asm -o registradores_subdivisoes.o

bits 64

section .data
    ; Labels para seções de output (demonstrativo)
    sep     db '---', 0x0A

section .bss
    out_rax resq 1      ; salvar RAX para inspeção
    out_rax2 resq 1

section .text
    global _start

_start:

    ; =========================================================================
    ; DEMONSTRAÇÃO 1: Zero-extension ao escrever em EAX (32-bit)
    ; REGRA: Escrever em registrador 32-bit ZERA automaticamente os 32 bits
    ;        superiores do registrador de 64 bits correspondente.
    ; =========================================================================

    mov     rax, 0xCAFEBABEDEADBEEF   ; Setup: RAX = valor completo de 64-bit
    mov     [rel out_rax], rax         ; salvar

    ; Escrever em EAX → os 32 bits superiores de RAX ficam ZERO
    mov     eax, 0x12345678
    ; Resultado: RAX = 0x0000000012345678  (bits [63:32] zerados automaticamente)
    mov     [rel out_rax2], rax

    ; =========================================================================
    ; DEMONSTRAÇÃO 2: Escrever em AX (16-bit) — NÃO zera bits superiores
    ; =========================================================================

    mov     rax, 0xFFFFFFFFFFFFFFFF    ; todos os bits em 1
    mov     ax, 0x1234
    ; Resultado: RAX = 0xFFFFFFFFFFFF1234  (apenas [15:0] alterados)

    ; =========================================================================
    ; DEMONSTRAÇÃO 3: Escrever em AL (8-bit baixo) — NÃO zera bits superiores
    ; =========================================================================

    mov     rax, 0xFFFFFFFFFFFFFFFF
    mov     al, 0x42
    ; Resultado: RAX = 0xFFFFFFFFFFFFFF42  (apenas [7:0] alterados)

    ; =========================================================================
    ; DEMONSTRAÇÃO 4: Escrever em AH (bits [15:8]) — NÃO zera bits superiores
    ; =========================================================================

    mov     rax, 0xFFFFFFFFFFFFFFFF
    mov     ah, 0x00
    ; Resultado: RAX = 0xFFFFFFFFFFFF00FF  (apenas [15:8] alterados)

    ; =========================================================================
    ; DEMONSTRAÇÃO 5: MOVZX — zero-extension explícita
    ; =========================================================================

    mov     al, 0xFF                   ; AL = 255 (unsigned) / -1 (signed)
    movzx   ebx, al                   ; EBX = 0x000000FF = 255 (zero-extended)
    ; RBX = 0x00000000000000FF (também zero-extende por ser escrita em EBX)

    movzx   ecx, ax                   ; ECX = zero-extend AX para 32-bit

    ; =========================================================================
    ; DEMONSTRAÇÃO 6: MOVSX — sign-extension
    ; =========================================================================

    mov     al, 0xFF                   ; AL = -1 (signed)
    movsx   ebx, al                   ; EBX = 0xFFFFFFFF = -1 (sign-extended)
    ; RBX = 0xFFFFFFFFFFFFFFFF = -1 (64-bit, por zero-extension de EBX não se aplica aqui)
    ; Nota: MOVSX para 32-bit destino NÃO zera automaticamente os 32 bits superiores do 64-bit
    ;       Isso é uma exceção ao comportamento padrão!

    movsx   rbx, al                   ; RBX = sign-extend AL para 64-bit (correto)
    ; RBX = 0xFFFFFFFFFFFFFFFF

    mov     al, 0x7F                   ; AL = +127
    movsx   rbx, al                   ; RBX = 0x000000000000007F = +127

    ; =========================================================================
    ; DEMONSTRAÇÃO 7: Os mesmos padrões em outros registradores
    ; =========================================================================

    ; RBX / EBX / BX / BL / BH
    mov     rbx, 0xFFFFFFFFFFFFFFFF
    mov     ebx, 1                    ; RBX = 0x0000000000000001 (zero-extend)

    ; RCX / ECX / CX / CL / CH
    mov     rcx, 0xFFFFFFFFFFFFFFFF
    mov     ecx, 1000                 ; RCX = 0x00000000000003E8

    ; RDX / EDX / DX / DL / DH
    mov     rdx, 0xFFFFFFFFFFFFFFFF
    mov     dx,  0x1234               ; RDX = 0xFFFFFFFFFFFF1234 (NÃO zero-extend)
    mov     edx, 0x1234               ; RDX = 0x0000000000001234 (zero-extend)

    ; R8 - R15: mesmas regras (R8D, R8W, R8B)
    mov     r8,  0xFFFFFFFFFFFFFFFF
    mov     r8d, 42                   ; R8 = 0x000000000000002A (zero-extend)
    mov     r8w, 0x1234               ; R8 = 0x000000000000002A ... wait
    ; Correto: após mov r8d,42 → R8=42; depois mov r8w,0x1234 → R8W=0x1234, bits superiores inalterados
    ; R8 = 0x0000000000001234

    ; =========================================================================
    ; Encerrar
    ; =========================================================================
    mov     rax, 60
    xor     rdi, rdi
    syscall
