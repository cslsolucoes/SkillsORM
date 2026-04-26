; labels_locais.asm — Demonstra labels locais em NASM vs. Delphi built-in assembler
;
; Em NASM: labels locais comecam com ponto (.label)
; Em Delphi built-in assembler: labels locais comecam com @ (@Label)
;
; REGRA DELPHI:
;   Labels sem @ sao globais (podem conflitar com labels Pascal ou outros modulos)
;   Labels com @ sao locais ao bloco asm (correto para uso dentro de funcoes)

section .text

; ------------------------------------------------------------------
; Exemplo: busca linear com labels locais NASM
; function BuscaLinear(P: PInteger; N, Val: Integer): Integer;
; Retorna indice do primeiro Val encontrado, ou -1
; P=EAX, N=EDX, Val=ECX
; ------------------------------------------------------------------
global _BuscaLinear

_BuscaLinear:
    push    esi
    push    ebx

    mov     esi, eax        ; ESI = P (ponteiro)
    mov     ebx, edx        ; EBX = N (contador)
    ; ECX = Val (valor a buscar)
    xor     eax, eax        ; EAX = indice = 0

.loop:
    test    ebx, ebx
    jz      .nao_encontrado
    cmp     [esi], ecx
    je      .encontrado
    add     esi, 4          ; proxima posicao
    inc     eax             ; indice++
    dec     ebx
    jmp     .loop

.encontrado:
    ; EAX ja contem o indice
    pop     ebx
    pop     esi
    ret

.nao_encontrado:
    mov     eax, -1         ; retornar -1
    pop     ebx
    pop     esi
    ret


; ------------------------------------------------------------------
; Equivalente Delphi (comentado para referencia):
;
; function BuscaLinear(P: PInteger; N, Val: Integer): Integer;
; asm
;   PUSH ESI
;   PUSH EBX
;   MOV  ESI, EAX     { P }
;   MOV  EBX, EDX     { N }
;   XOR  EAX, EAX     { indice = 0 }
; @loop:
;   TEST EBX, EBX
;   JZ   @naoEncontrado
;   CMP  [ESI], ECX   { compara com Val }
;   JE   @encontrado
;   ADD  ESI, 4
;   INC  EAX
;   DEC  EBX
;   JMP  @loop
; @encontrado:
;   POP  EBX
;   POP  ESI
;   RET
; @naoEncontrado:
;   MOV  EAX, -1
;   POP  EBX
;   POP  ESI
;   // Fim automatico: RET
; end;
; ------------------------------------------------------------------
