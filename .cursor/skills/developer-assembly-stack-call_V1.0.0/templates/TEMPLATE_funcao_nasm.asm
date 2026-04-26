; TEMPLATE_funcao_nasm.asm
; Função NASM com prologue/epilogue para Linux x64 e Windows x64
;
; INSTRUÇÕES DE USO:
;   1. Copiar e renomear para o arquivo desejado
;   2. Ajustar a convenção de chamada (Linux vs Windows) nos comentários
;   3. Implementar a lógica entre "=== IMPLEMENTAÇÃO ===" e "=== FIM ==="
;   4. Ajustar os callee-saved necessários (PUSH/POP)
;
; COMPILAÇÃO:
;   Linux x64:   nasm -f elf64 nome.asm -o nome.o
;   Windows x64: nasm -f win64 nome.asm -o nome.obj
;
; USO COM DELPHI:
;   1. Compilar o .asm com nasm -f win64
;   2. Linkar com {$L nome.obj} no arquivo .pas
;   3. Declarar: function MinhaFuncao(A, B: Int64): Int64; cdecl; external;

bits 64

section .data
    ; Dados locais se necessário
    ; msg db 'debug', 0x0A

section .bss
    ; Variáveis não inicializadas se necessário

section .text
    global MinhaFuncao    ; exportar para uso externo

; ===========================================================================
; Função: MinhaFuncao(A, B) → Int64
;
; Linux x64:   RDI=A, RSI=B, retorno RAX
; Windows x64: RCX=A, RDX=B, retorno RAX (shadow space obrigatório)
; ===========================================================================
MinhaFuncao:
    ; =========================================================================
    ; PROLOGUE
    ; =========================================================================
    push    rbp
    mov     rbp, rsp

    ; [Windows x64] Alocar shadow space (32 bytes) para subcalls:
    sub     rsp, 32         ; shadow space (Windows) / local space (Linux)

    ; [Opcional] Salvar registradores callee-saved que serão usados:
    push    rbx             ; callee-saved (ambas as ABIs)
    push    r12             ; callee-saved (ambas as ABIs)
    ; Nota: 2 push adicionais = 16 bytes → RSP mantém alinhamento ✓

    ; =========================================================================
    ; SETUP DE PARÂMETROS
    ; Adapte para a plataforma alvo:
    ; =========================================================================

    ; [Linux x64]:
    ; mov     rax, rdi      ; A = 1° arg
    ; mov     rbx, rsi      ; B = 2° arg

    ; [Windows x64]:
    mov     rax, rcx        ; A = 1° arg (RCX)
    mov     rbx, rdx        ; B = 2° arg (RDX)

    ; =========================================================================
    ; === IMPLEMENTAÇÃO ===
    ; Substituir esta seção pela lógica desejada:
    ; =========================================================================

    ; Exemplo: RAX = A + B
    add     rax, rbx        ; RAX = A + B

    ; Exemplo: RAX = A * B
    ; imul    rax, rbx      ; RAX = A * B (truncado para 64-bit)

    ; Exemplo: loop sobre array (RSI=array, RCX=count)
    ; .loop:
    ;     test  rcx, rcx
    ;     jz    .fim
    ;     add   rax, [rsi]
    ;     add   rsi, 8
    ;     dec   rcx
    ;     jmp   .loop
    ; .fim:

    ; =========================================================================
    ; === FIM DA IMPLEMENTAÇÃO ===
    ; Resultado em RAX
    ; =========================================================================

    ; =========================================================================
    ; EPILOGUE
    ; =========================================================================
    ; Restaurar callee-saved na ordem INVERSA:
    pop     r12
    pop     rbx

    ; Liberar shadow space / locais:
    add     rsp, 32

    ; Restaurar frame pointer:
    pop     rbp

    ; Retornar (resultado em RAX):
    ret

; ===========================================================================
; Uso com Delphi (arquivo .pas que usa este .obj):
;
; unit MinhaUnit;
; interface
;
; function MinhaFuncao(A, B: Int64): Int64; cdecl; external;
; {$L MeuArquivo.obj}
;
; implementation
; end.
; ===========================================================================
