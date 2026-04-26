; TEMPLATE_nasm_basico.asm
; Esqueleto NASM completo: .data + .bss + .text + _start
; Suporte a Linux x64 e Windows x64 via ifdefs de comentário
;
; INSTRUÇÕES DE USO:
;   1. Copiar e renomear para o arquivo desejado
;   2. Descomentar a plataforma alvo (Linux ou Windows)
;   3. Adicionar dados em .data e .bss conforme necessário
;   4. Implementar a lógica em .text
;
; COMPILAÇÃO Linux x64:
;   nasm -f elf64 nome.asm -o nome.o
;   ld nome.o -o nome
;
; COMPILAÇÃO Windows x64:
;   nasm -f win64 nome.asm -o nome.obj
;   link nome.obj /subsystem:console /entry:_start kernel32.lib
;   (ou usar MinGW/MSVC linker)

; ===========================================================================
; Configuração de bits
; ===========================================================================
bits 64

; ===========================================================================
; Seção de dados inicializados
; ===========================================================================
section .data

    ; --- Strings ---
    msg_hello   db 'Ola, NASM!', 0x0A   ; mensagem com newline
    msg_len     equ $ - msg_hello         ; comprimento calculado

    msg_erro    db 'Erro!', 0x0A
    msg_erro_len equ $ - msg_erro

    ; --- Inteiros ---
    contador    dq 0                      ; qword inicializado com 0
    maximo      dd 1000                   ; dword = 1000

    ; --- Float ---
    ; pi_f32      dd 3.14159              ; float single
    ; pi_f64      dq 3.14159265358979    ; float double

; ===========================================================================
; Seção de dados não inicializados (reservados, zerados pelo OS)
; ===========================================================================
section .bss

    ; --- Buffers ---
    buffer      resb 4096   ; 4096 bytes
    resultado   resq 1      ; 1 qword (8 bytes)
    temp        resd 4      ; 4 dwords = 16 bytes

; ===========================================================================
; Seção de código
; ===========================================================================
section .text

    ; Símbolos globais exportados
    global _start

    ; Símbolos externos (descomente conforme necessário)
    ; extern printf
    ; extern malloc
    ; extern free

; ---------------------------------------------------------------------------
; Sub-rotina de exemplo: soma dois inteiros
; Entrada: RCX = A, RDX = B (Windows x64) / RDI = A, RSI = B (Linux)
; Saída:   RAX = A + B
; ---------------------------------------------------------------------------
; [LINUX]
;SomaLinux:
;    mov     rax, rdi        ; RAX = A
;    add     rax, rsi        ; RAX = A + B
;    ret

; [WINDOWS]
;SomaWindows:
;    mov     rax, rcx        ; RAX = A
;    add     rax, rdx        ; RAX = A + B
;    ret

; ---------------------------------------------------------------------------
; Ponto de entrada principal
; ---------------------------------------------------------------------------
_start:

    ; === PROLOGUE (se necessário) ===
    ; Para _start simples sem frame:
    ; push    rbp
    ; mov     rbp, rsp
    ; sub     rsp, 32         ; shadow space (Windows) ou espaço local (Linux)

    ; === CORPO DO PROGRAMA ===

    ; -- [LINUX] Imprimir mensagem via syscall write --
    mov     rax, 1              ; sys_write
    mov     rdi, 1              ; stdout
    lea     rsi, [rel msg_hello]
    mov     rdx, msg_len
    syscall

    ; -- [WINDOWS] Imprimir via WriteConsole (requer kernel32.lib) --
    ; (implementação omitida — preferir libc para simplicidade)

    ; === EPILOGUE + EXIT ===

    ; [LINUX] sys_exit(0)
    mov     rax, 60             ; sys_exit
    xor     rdi, rdi            ; exit code = 0
    syscall

    ; [WINDOWS] ExitProcess(0)
    ; sub     rsp, 32           ; shadow space para ExitProcess
    ; xor     ecx, ecx          ; exit code = 0
    ; call    ExitProcess
