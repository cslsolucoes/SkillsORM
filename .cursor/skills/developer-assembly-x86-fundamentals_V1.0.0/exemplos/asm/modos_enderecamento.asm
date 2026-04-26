; modos_enderecamento.asm
; Demonstra todos os modos de endereçamento x86-64:
;   imediato, direto (absoluto), indireto, baseado, indexado, com escala
; Compilar: nasm -f elf64 modos_enderecamento.asm -o modos_enderecamento.o

bits 64

section .data
    array   dd 10, 20, 30, 40, 50  ; array de 5 dwords
    variavel dd 0xDEAD             ; variável de 4 bytes
    ptr64    dq 0                  ; ponteiro de 8 bytes

section .bss
    resultado resd 1

section .text
    global _start

_start:

    ; -----------------------------------------------------------------------
    ; MODO 1: Imediato (Immediate)
    ; O valor está codificado na própria instrução
    ; -----------------------------------------------------------------------
    mov     rax, 42             ; RAX = 42 (literal na instrução)
    mov     ecx, 0xFF00         ; ECX = 65280
    mov     rdx, 0x0102030405060708  ; RAX = literal 8 bytes

    ; -----------------------------------------------------------------------
    ; MODO 2: Registrador (Register)
    ; Operando é um registrador — mais rápido, sem acesso à memória
    ; -----------------------------------------------------------------------
    mov     rax, rbx            ; RAX = RBX
    mov     ecx, edx            ; ECX = EDX
    xchg    rax, rcx            ; swap(RAX, RCX)

    ; -----------------------------------------------------------------------
    ; MODO 3: Direto / Absoluto (Direct)
    ; Endereço da variável está na instrução
    ; Usando endereçamento RIP-relativo no x64 (recomendado)
    ; -----------------------------------------------------------------------
    mov     eax, [rel variavel]     ; EAX = mem[endereço_de_variavel]
    mov     [rel variavel], eax     ; mem[endereço_de_variavel] = EAX

    ; -----------------------------------------------------------------------
    ; MODO 4: Indireto via Registrador (Register Indirect)
    ; O registrador contém o ENDEREÇO a acessar
    ; -----------------------------------------------------------------------
    lea     rbx, [rel array]        ; RBX = endereço de array (não lê memória!)
    mov     eax, [rbx]              ; EAX = mem[RBX] = array[0] = 10

    ; -----------------------------------------------------------------------
    ; MODO 5: Baseado com Deslocamento (Base + Displacement)
    ; registrador_base + constante → endereço final
    ; -----------------------------------------------------------------------
    lea     rbx, [rel array]
    mov     eax, [rbx + 0]          ; array[0] = 10 (dword = 4 bytes cada)
    mov     eax, [rbx + 4]          ; array[1] = 20
    mov     eax, [rbx + 8]          ; array[2] = 30
    mov     eax, [rbx + 12]         ; array[3] = 40
    mov     eax, [rbx + 16]         ; array[4] = 50

    ; -----------------------------------------------------------------------
    ; MODO 6: Indexado com Escala (Base + Index * Scale + Displacement)
    ; Forma geral: [base + índice * escala + deslocamento]
    ; escala válida: 1, 2, 4, 8
    ; -----------------------------------------------------------------------
    lea     rbx, [rel array]
    xor     rcx, rcx                ; RCX = 0 (índice)

    mov     eax, [rbx + rcx*4]      ; array[0]: RBX + 0*4 = 10
    inc     rcx
    mov     eax, [rbx + rcx*4]      ; array[1]: RBX + 1*4 = 20
    inc     rcx
    mov     eax, [rbx + rcx*4]      ; array[2]: RBX + 2*4 = 30

    ; Com deslocamento adicional:
    mov     eax, [rbx + rcx*4 + 4]  ; array[3]: RBX + 2*4 + 4 = 40

    ; -----------------------------------------------------------------------
    ; MODO 7: RIP-relative (x64 específico — para code/data position-independent)
    ; -----------------------------------------------------------------------
    ; [rel label] → endereço = RIP_da_próxima_instrução + offset_para_label
    ; Útil para PIC (Position Independent Code) e bibliotecas compartilhadas
    lea     rax, [rel array]         ; RAX = endereço de array (relativo ao RIP)
    mov     eax, [rel variavel]      ; lê variavel usando RIP-relative

    ; -----------------------------------------------------------------------
    ; Encerrar
    ; -----------------------------------------------------------------------
    mov     rax, 60
    xor     rdi, rdi
    syscall
