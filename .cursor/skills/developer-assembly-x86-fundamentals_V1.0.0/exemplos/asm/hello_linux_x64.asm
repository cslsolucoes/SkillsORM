; hello_linux_x64.asm
; Hello World Linux 64-bit usando syscall write e exit
; Compilar: nasm -f elf64 hello_linux_x64.asm -o hello_linux_x64.o
; Linkar:   ld hello_linux_x64.o -o hello_linux_x64
; Executar: ./hello_linux_x64

bits 64

section .data
    msg     db 'Hello, Assembly x64!', 0x0A  ; mensagem + newline
    msg_len equ $ - msg                       ; comprimento calculado pelo NASM

section .bss
    ; Nenhuma variável não inicializada neste exemplo

section .text
    global _start

_start:
    ; --- syscall: write(fd=1, buf=msg, count=msg_len) ---
    ; Número da syscall: RAX = 1 (sys_write no Linux x64)
    ; Argumentos:
    ;   RDI = file descriptor (1 = stdout)
    ;   RSI = ponteiro para o buffer
    ;   RDX = número de bytes a escrever
    mov     rax, 1          ; sys_write
    mov     rdi, 1          ; stdout
    lea     rsi, [rel msg]  ; endereço RIP-relativo da mensagem
    mov     rdx, msg_len    ; comprimento da mensagem
    syscall                 ; chama o kernel

    ; --- syscall: exit(status=0) ---
    ; Número da syscall: RAX = 60 (sys_exit no Linux x64)
    ; Argumento:
    ;   RDI = código de saída
    mov     rax, 60         ; sys_exit
    xor     rdi, rdi        ; exit code = 0
    syscall
