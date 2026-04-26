; estrutura_basica.asm
; Esqueleto mínimo NASM: sections + global _start
; Demonstra a estrutura de um arquivo NASM válido sem dependências externas
; Compilar (Linux): nasm -f elf64 estrutura_basica.asm -o estrutura_basica.o
; Compilar (Win64): nasm -f win64 estrutura_basica.asm -o estrutura_basica.obj

bits 64             ; gera código de 64 bits

; ===========================================================================
; Seção de dados inicializados
; ===========================================================================
section .data

    ; Constante de string (terminada em null para compatibilidade com C)
    hello       db 'Assembly', 0

    ; Inteiros de vários tamanhos
    byte_val    db 0xFF              ; 1 byte  (define byte)
    word_val    dw 0xABCD            ; 2 bytes (define word)
    dword_val   dd 0xDEADBEEF        ; 4 bytes (define dword)
    qword_val   dq 0x0102030405060708 ; 8 bytes (define qword)

    ; Float
    float_val   dd 3.14159           ; float IEEE-754 32-bit
    double_val  dq 2.71828182845904  ; double IEEE-754 64-bit

; ===========================================================================
; Seção de dados não inicializados (BSS)
; BSS é zerada automaticamente pelo OS ao carregar o processo
; ===========================================================================
section .bss

    ; Reserva de espaço sem valor inicial
    buffer      resb 256    ; 256 bytes (reserve byte)
    wbuffer     resw  64    ; 64 words = 128 bytes (reserve word)
    dbuffer     resd  32    ; 32 dwords = 128 bytes (reserve dword)
    qbuffer     resq  16    ; 16 qwords = 128 bytes (reserve qword)

; ===========================================================================
; Seção de código executável
; ===========================================================================
section .text

    ; Exportar símbolo _start para o linker
    global _start

    ; Declarar símbolo externo (se fosse usar printf da libc, por exemplo)
    ; extern printf

; ---------------------------------------------------------------------------
; Ponto de entrada do programa
; ---------------------------------------------------------------------------
_start:
    ; Código principal vai aqui

    ; Exemplo de acesso aos dados:
    mov     rax, [qword_val]        ; RAX = 0x0102030405060708
    movzx   rcx, byte [byte_val]    ; RCX = 0xFF (zero-extended)
    movzx   rdx, word [word_val]    ; RDX = 0xABCD (zero-extended)
    mov     esi, dword [dword_val]  ; ESI = 0xDEADBEEF (zero-extends RSI)

    ; Escrever no buffer:
    lea     rdi, [rel buffer]       ; RDI = endereço de buffer
    mov     byte [rdi], 'A'         ; buffer[0] = 'A'
    mov     byte [rdi+1], 'S'       ; buffer[1] = 'S'
    mov     byte [rdi+2], 'M'       ; buffer[2] = 'M'
    mov     byte [rdi+3], 0         ; buffer[3] = null terminator

    ; Encerrar: sys_exit(0)
    mov     rax, 60                 ; sys_exit (Linux)
    xor     rdi, rdi                ; exit code = 0
    syscall
