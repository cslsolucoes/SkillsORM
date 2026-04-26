; bitwise_shifts.asm
; Demonstra instruções lógicas e de deslocamento:
; AND, OR, XOR, NOT, SHL, SHR, SAR, ROL, ROR, RCL, RCR
; Compilar: nasm -f elf64 bitwise_shifts.asm -o bitwise_shifts.o

bits 64

section .data
    val     dq 0xF0F0F0F0DEADBEEF

section .bss
    resultado resq 8

section .text
    global _start

_start:

    ; =========================================================================
    ; AND — E lógico (bit a bit)
    ; CF=0, OF=0, ZF/SF/PF baseados no resultado
    ; =========================================================================
    mov     rax, 0xFF00FF00FF00FF00
    mov     rbx, 0x0F0F0F0F0F0F0F0F
    and     rax, rbx        ; RAX = 0x0F000F000F000F00

    ; Usos comuns de AND:
    ; Mascarar bits (manter apenas bits específicos):
    mov     eax, 0xABCDEF12
    and     eax, 0xFF        ; EAX = 0x12 (mantém apenas byte baixo)
    and     eax, 0xF0        ; EAX = 0x10 (mantém nibble alto do byte baixo)

    ; Alinhar endereço para baixo (ex: alinhar a 16 bytes):
    mov     rax, 0x12345678
    and     rax, -16         ; -16 em complemento de dois = 0xFFFFFFFFFFFFFFF0
    ; RAX = 0x12345670 (16-byte aligned para baixo)

    ; Verificar se bit está setado:
    mov     eax, 0x42        ; 0b01000010
    test    eax, (1 shl 6)   ; bit 6 está setado? (TEST = AND sem salvar resultado)
    ; ZF=0 → bit 6 está setado

    ; =========================================================================
    ; OR — OU lógico (bit a bit)
    ; =========================================================================
    mov     eax, 0x0F0F0F0F
    or      eax, 0xF0F0F0F0  ; EAX = 0xFFFFFFFF

    ; Setar bits específicos:
    mov     eax, 0x40        ; 0b01000000
    or      eax, (1 shl 0)   ; seta bit 0 → EAX = 0x41 (0b01000001)
    or      eax, (1 shl 7)   ; seta bit 7 → EAX = 0xC1 (0b11000001)

    ; =========================================================================
    ; XOR — OU exclusivo (bit a bit)
    ; CF=0, OF=0, ZF/SF/PF baseados no resultado
    ; =========================================================================
    ; Zerar registrador (idioma padrão — menor e mais rápido que MOV EAX,0):
    xor     eax, eax         ; EAX = 0, RAX = 0 (zero-extension)
    xor     rax, rax         ; RAX = 0

    ; Toggle de bits:
    mov     eax, 0xFF
    xor     eax, (1 shl 3)   ; inverte bit 3 → EAX = 0xF7
    xor     eax, (1 shl 3)   ; inverte novamente → EAX = 0xFF

    ; Trocar valores sem variável temporária (cuidado: lento em hardware moderno):
    mov     eax, 0xAABBCCDD
    mov     ebx, 0x11223344
    xor     eax, ebx         ; EAX = EAX XOR EBX
    xor     ebx, eax         ; EBX = EBX XOR EAX = original EAX
    xor     eax, ebx         ; EAX = EAX XOR EBX = original EBX
    ; Resultado: EAX e EBX trocados (use XCHG na prática)

    ; =========================================================================
    ; NOT — complemento de bits (NÃO afeta flags!)
    ; =========================================================================
    mov     eax, 0xFF00FF00
    not     eax              ; EAX = 0x00FF00FF

    ; Limpar bit específico usando NOT + AND:
    mov     eax, 0xFF
    and     eax, not (1 shl 3)   ; limpa bit 3: EAX = 0xF7
    ; equivalente a: and eax, 0xF7

    ; =========================================================================
    ; SHL / SAL — shift left (= multiplicação por 2^n)
    ; O bit deslocado para fora entra em CF
    ; =========================================================================
    mov     eax, 1
    shl     eax, 1           ; EAX = 2   (= 1 << 1)
    shl     eax, 3           ; EAX = 16  (= 2 << 3)

    ; Contador variável DEVE estar em CL:
    mov     eax, 1
    mov     cl, 4
    shl     eax, cl          ; EAX = 16 (= 1 << 4)

    ; =========================================================================
    ; SHR — shift right lógico (sem sinal, preenche com 0)
    ; =========================================================================
    mov     eax, 0xFF
    shr     eax, 4           ; EAX = 0x0F (= 255 >> 4, preenche com 0)

    ; =========================================================================
    ; SAR — shift right aritmético (com sinal, preserva bit de sinal)
    ; =========================================================================
    mov     eax, -16         ; 0xFFFFFFF0
    sar     eax, 2           ; EAX = -4 (0xFFFFFFFC, bit de sinal copiado)

    mov     eax, 16
    sar     eax, 2           ; EAX = 4 (positivo, sem diferença)

    ; =========================================================================
    ; ROL / ROR — rotação (o bit que sai por um lado entra pelo outro)
    ; =========================================================================
    mov     eax, 0x80000001  ; bit 31 e bit 0 setados
    rol     eax, 1           ; EAX = 0x00000003 (bit 31 → CF → bit 0)
    ror     eax, 1           ; EAX = 0x80000001 (desfaz)

    ; =========================================================================
    ; RCL / RCR — rotação através do CF
    ; =========================================================================
    ; RCL: [CF] ← bit_alto → restante → [CF]
    stc                      ; CF = 1
    mov     eax, 0x80000000  ; bit 31 setado
    rcl     eax, 1           ; bit 31 → CF; CF (=1) → bit 0; EAX = 0x00000001, CF=1

    clc                      ; CF = 0
    mov     eax, 0x00000001  ; bit 0 setado
    rcr     eax, 1           ; bit 0 → CF; CF (=0) → bit 31; EAX = 0x00000000, CF=1

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
