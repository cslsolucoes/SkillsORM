; asm_basico.asm — Equivalente NASM das operacoes mais comuns em inline asm Delphi
; Referencia para entender a sintaxe NASM vs. Delphi built-in assembler
;
; DIFERENCAS SINTAXE:
;   NASM:   mov eax, [ebp-4]        ; acesso a variavel local
;   Delphi: MOV EAX, LocalVar       ; Delphi resolve o endereco
;
;   NASM:   jmp .label              ; label local com ponto
;   Delphi: JMP @Label              ; label local com @ (obrigatorio!)
;
;   NASM:   ; comentario            ; apenas ; ou # no NASM
;   Delphi: // comentario           ; // ou { } no built-in assembler

section .text

; ------------------------------------------------------------------
; Equivalente NASM de: function SomarDoisInteiros(A, B: Integer): Integer;
; Convencao register Win32: A=EAX, B=EDX
; ------------------------------------------------------------------
global _SomarDoisInteiros

_SomarDoisInteiros:
    add     eax, edx        ; EAX = A + B
    ret                     ; resultado em EAX


; ------------------------------------------------------------------
; Equivalente NASM de: function Maximo(A, B: Integer): Integer;
; Demonstra labels locais (em NASM: .label, em Delphi: @label)
; ------------------------------------------------------------------
global _Maximo

_Maximo:
    cmp     eax, edx        ; compara A e B
    jge     .retorna_a      ; A >= B ? retornar A (ja em EAX)
    mov     eax, edx        ; EAX = B (B e maior)
.retorna_a:
    ret                     ; resultado em EAX


; ------------------------------------------------------------------
; Equivalente NASM de loop simples:
; function SomaArray(P: PInteger; N: Integer): Integer;
; P=EAX, N=EDX
; ------------------------------------------------------------------
global _SomaArray

_SomaArray:
    push    esi
    push    ebx
    mov     esi, eax        ; ESI = ponteiro P
    mov     ecx, edx        ; ECX = contador N
    xor     ebx, ebx        ; EBX = acumulador (0)
    test    ecx, ecx
    jz      .fim

.loop:
    add     ebx, [esi]      ; acumula elemento
    add     esi, 4          ; proxima posicao (Integer = 4 bytes)
    dec     ecx
    jnz     .loop

.fim:
    mov     eax, ebx        ; resultado em EAX
    pop     ebx
    pop     esi
    ret
