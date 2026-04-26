; TEMPLATE_loop_nasm.asm
; Template: loop com RCX como contador — esqueleto NASM para x64
;
; INSTRUÇÕES DE USO:
;   1. Copiar e renomear
;   2. Substituir a operação no loop pela lógica desejada
;   3. Ajustar o setup de RSI/RDI conforme o array a processar
;   4. Compilar: nasm -f elf64 nome.asm -o nome.o (Linux)
;               nasm -f win64 nome.asm -o nome.obj (Windows)

bits 64

section .data
    ; Dados de entrada
    array_in    dq 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
    array_len   equ ($ - array_in) / 8     ; número de qwords

section .bss
    array_out   resq 10     ; array de saída
    resultado   resq 1      ; resultado acumulado

section .text
    global _start

; ===========================================================================
; Função genérica: processa array_in → array_out
; Operação: out[i] = in[i] * 2 (exemplo — substituir pela sua lógica)
;
; Linux x64 convenção: RDI=dst, RSI=src, RDX=count
; Windows x64 convenção: RCX=dst, RDX=src, R8=count
; ===========================================================================
processar_array:
    ; Prologue
    push    rbp
    mov     rbp, rsp
    push    rbx             ; callee-saved

    ; Setup (ajustar para convenção da plataforma alvo):
    ; [Linux]
    mov     rax, rdx        ; RAX = count
    ; RSI = src, RDI = dst (já configurados pelo chamador)

    ; [Windows: descomentar estas linhas]
    ; mov rdi, rcx          ; RDI = dst (Windows: RCX)
    ; mov rsi, rdx          ; RSI = src (Windows: RDX)
    ; mov rax, r8           ; RAX = count (Windows: R8)

    ; Verificar count > 0
    test    rax, rax
    jle     .fim_proc

    ; Inicializar contador de loop
    mov     rcx, rax        ; RCX = count (contador)

.loop:
    ; === OPERAÇÃO SOBRE CADA ELEMENTO ===
    ; Substituir esta seção pela lógica desejada:
    mov     rax, [rsi]      ; RAX = *src (elemento atual)
    shl     rax, 1          ; RAX = elemento * 2 (EXEMPLO)
    mov     [rdi], rax      ; *dst = resultado
    ; === FIM DA OPERAÇÃO ===

    add     rsi, 8          ; src++ (qword = 8 bytes)
    add     rdi, 8          ; dst++
    dec     rcx             ; contador--
    jnz     .loop           ; continua se rcx != 0

.fim_proc:
    pop     rbx
    pop     rbp
    ret

; ===========================================================================
; Variante: loop com CMP + JL (índice explícito — mais legível)
; ===========================================================================
processar_array_indexed:
    push    rbp
    mov     rbp, rsp
    push    rbx

    ; Entrada: RSI = array_in, RDI = array_out, RDX = count
    mov     rbx, rdx        ; RBX = count (callee-saved)
    xor     rcx, rcx        ; RCX = índice = 0

.loop_idx:
    cmp     rcx, rbx        ; idx >= count?
    jge     .fim_idx

    ; === OPERAÇÃO COM ÍNDICE ===
    mov     rax, [rsi + rcx*8]    ; RAX = array_in[idx]
    ; ... operação ...
    add     rax, 1                 ; EXEMPLO: incrementar
    mov     [rdi + rcx*8], rax    ; array_out[idx] = resultado

    inc     rcx
    jmp     .loop_idx

.fim_idx:
    pop     rbx
    pop     rbp
    ret

; ===========================================================================
; Variante: loop com REP para operações de cópia/fill (mais eficiente)
; ===========================================================================
copiar_array:
    ; RSI = src, RDI = dst, RCX = count (em qwords)
    cld
    rep     movsq           ; copia RCX qwords RSI → RDI
    ret

; ===========================================================================
; Ponto de entrada — testa as funções
; ===========================================================================
_start:
    ; Testar processar_array:
    lea     rsi, [rel array_in]
    lea     rdi, [rel array_out]
    mov     rdx, array_len
    call    processar_array

    ; Testar com índice:
    lea     rsi, [rel array_in]
    lea     rdi, [rel array_out]
    mov     rdx, array_len
    call    processar_array_indexed

    ; Copiar array_in para array_out:
    lea     rsi, [rel array_in]
    lea     rdi, [rel array_out]
    mov     rcx, array_len
    call    copiar_array

    ; Encerrar
    mov     rax, 60
    xor     rdi, rdi
    syscall
