; string_operations.asm
; Demonstra MOVSB/D/Q, CMPSB, LODSB, STOSB, SCASB com REP/REPZ/REPNZ
; Convenção Linux x64: RDI=dst, RSI=src, RCX=count, AL=valor
; Compilar: nasm -f elf64 string_operations.asm -o string_operations.o

bits 64

section .data
    src_data    db 'Hello, Assembly!', 0   ; 17 bytes (16 + null)
    src_len     equ $ - src_data
    pattern     db 'x', 0

section .bss
    dst_buf     resb 256
    cmp_buf     resb 256

section .text
    global _start

; ===========================================================================
; Função: copia N bytes de RSI para RDI usando REP MOVSB
; Similar a memcpy
; ===========================================================================
my_memcpy:
    ; Entrada: RDI=dst, RSI=src, RDX=count
    push    rcx
    mov     rcx, rdx    ; RCX = count (REP usa RCX como contador)
    cld                 ; DF=0: direção crescente (RSI/RDI incrementam)
    rep     movsb       ; copia RCX bytes: [RSI]→[RDI], RSI++, RDI++, RCX-- até RCX=0
    pop     rcx
    ret

; ===========================================================================
; Função: copia N dwords de RSI para RDI usando REP MOVSD
; Mais eficiente que MOVSB para blocos alinhados de 4 bytes
; ===========================================================================
my_memcpy_dword:
    ; Entrada: RDI=dst, RSI=src, RDX=count (em dwords, não bytes!)
    push    rcx
    mov     rcx, rdx
    cld
    rep     movsd       ; copia RCX dwords; RSI+=4, RDI+=4, RCX-- por iteração
    pop     rcx
    ret

; ===========================================================================
; Função: strlen — conta bytes até null usando REPNE SCASB
; ===========================================================================
my_strlen:
    ; Entrada: RDI = ponteiro para string (null-terminated)
    ; Saída:   RAX = comprimento (sem o null)
    push    rcx
    push    rdi

    xor     al, al          ; AL = 0 (byte a buscar: null)
    mov     rcx, -1         ; RCX = contador máximo (busca até 2^63 bytes)
    cld
    repne   scasb           ; busca: enquanto AL != [RDI], avança RDI e decrementa RCX
    ; Quando para: RDI aponta para DEPOIS do null, RCX = -(comprimento) - 2
    not     rcx             ; RCX = comprimento + 1
    dec     rcx             ; RCX = comprimento

    mov     rax, rcx

    pop     rdi
    pop     rcx
    ret

; ===========================================================================
; Função: memset — preenche N bytes a partir de RDI com valor em AL
; Usando REP STOSB
; ===========================================================================
my_memset:
    ; Entrada: RDI=dst, RSI=valor (byte), RDX=count
    push    rcx
    mov     al,  sil        ; AL = byte de preenchimento (parte baixa de RSI)
    mov     rcx, rdx        ; RCX = count
    cld
    rep     stosb            ; [RDI] = AL; RDI++; RCX-- até RCX=0
    pop     rcx
    ret

; ===========================================================================
; Função: memset com DWORD (4x mais rápido para blocos grandes)
; ===========================================================================
my_memset_dword:
    ; Entrada: RDI=dst, ESI=valor_dword, RDX=count (em dwords)
    push    rcx
    mov     eax, esi        ; EAX = valor a preencher
    mov     rcx, rdx
    cld
    rep     stosd            ; [RDI] = EAX; RDI+=4; RCX--
    pop     rcx
    ret

; ===========================================================================
; Função: memcmp — compara N bytes em RSI com RDI usando REPE CMPSB
; ===========================================================================
my_memcmp:
    ; Entrada: RDI=buf1, RSI=buf2, RDX=count
    ; Saída:   RAX = 0 (iguais), <0 (buf1 < buf2), >0 (buf1 > buf2)
    push    rcx
    mov     rcx, rdx
    cld
    repe    cmpsb           ; compara enquanto bytes iguais e RCX > 0
    ; Quando para: ZF=1 se todos iguais, ZF=0 no primeiro byte diferente
    je      .iguais
    movzx   eax, byte [rdi-1]   ; byte de buf1 (RDI foi incrementado após CMPSB)
    movzx   ecx, byte [rsi-1]   ; byte de buf2
    sub     eax, ecx            ; diferença
    jmp     .fim
.iguais:
    xor     eax, eax            ; RAX = 0
.fim:
    pop     rcx
    ret

; ===========================================================================
; Função: busca byte usando REPNE SCASB
; ===========================================================================
my_memchr:
    ; Entrada: RDI=buffer, AL=byte_buscar, RCX=count
    ; Saída:   RAX = endereço do byte encontrado, ou 0 se não encontrado
    push    rcx
    push    rdi
    cld
    repne   scasb           ; busca AL em [RDI], avança RDI, decrementa RCX
    jne     .nao_encontrado
    lea     rax, [rdi-1]    ; endereço do byte (RDI passou além)
    jmp     .fim_busca
.nao_encontrado:
    xor     eax, eax        ; RAX = 0 (NULL)
.fim_busca:
    pop     rdi
    pop     rcx
    ret

; ===========================================================================
; Função: LODS — carrega sequência da memória para AL/AX/EAX/RAX
; ===========================================================================
demo_lods:
    ; Exemplo: somar todos os bytes de uma string
    lea     rsi, [rel src_data]
    mov     rcx, src_len - 1    ; excluir null terminator
    xor     rax, rax
    xor     rbx, rbx            ; acumulador
    cld
.lods_loop:
    lodsb                       ; AL = [RSI]; RSI++
    movzx   eax, al
    add     rbx, rax
    dec     rcx
    jnz     .lods_loop
    ; RBX = soma dos bytes ASCII de src_data
    ret

; ===========================================================================
; Ponto de entrada
; ===========================================================================
_start:
    ; Copia src_data para dst_buf
    lea     rdi, [rel dst_buf]
    lea     rsi, [rel src_data]
    mov     rdx, src_len
    call    my_memcpy

    ; Calcula comprimento de src_data
    lea     rdi, [rel src_data]
    call    my_strlen
    ; RAX = 16 (sem null)

    ; Preenche os primeiros 32 bytes de cmp_buf com 0xAB
    lea     rdi, [rel cmp_buf]
    mov     esi, 0xABABABAB       ; valor dword
    mov     rdx, 8                ; 8 dwords = 32 bytes
    call    my_memset_dword

    ; Compara dst_buf com src_data
    lea     rdi, [rel dst_buf]
    lea     rsi, [rel src_data]
    mov     rdx, src_len
    call    my_memcmp
    ; RAX = 0 (iguais, pois copiamos)

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
