; programa_com_bug.asm — Exemplo com bug proposital para pratica de debug
; O bug e um off-by-one em um loop de soma de array
;
; TAREFA DE DEBUG:
;   1. Montar e linkar
;   2. Chamar de Delphi com array de 5 elementos {1,2,3,4,5}
;   3. O resultado correto seria 15 (1+2+3+4+5)
;   4. Encontrar o bug usando CPU View ou x64dbg
;
; SPOILER (nao ler antes de depurar):
;   A linha "dec ecx" esta no lugar errado — o loop processa Count-1 elementos

section .text

; function SomaComBug(P: PInteger; Count: Integer): Integer;
; Win32 register: P=EAX, Count=EDX
global _SomaComBug

_SomaComBug:
    push    esi
    push    ebx

    mov     esi, eax        ; ESI = P (ponteiro para array)
    mov     ecx, edx        ; ECX = Count
    xor     ebx, ebx        ; EBX = soma = 0

    ; BUG: DEC ECX deveria vir APOS o loop body, nao antes!
    dec     ecx             ; ← BUG AQUI: pula o ultimo elemento!

.loop:
    test    ecx, ecx
    jz      .fim
    add     ebx, [esi]      ; soma elemento atual
    add     esi, 4
    dec     ecx
    jmp     .loop

.fim:
    mov     eax, ebx        ; retorno em EAX

    pop     ebx
    pop     esi
    ret

; ------------------------------------------------------------------
; Versao CORRIGIDA (sem bug)
; ------------------------------------------------------------------
global _SomaSemBug

_SomaSemBug:
    push    esi
    push    ebx

    mov     esi, eax        ; ESI = P
    mov     ecx, edx        ; ECX = Count
    xor     ebx, ebx        ; soma = 0

    test    ecx, ecx
    jz      .fim_correto

.loop_correto:
    add     ebx, [esi]      ; CORRETO: soma primeiro, depois decrementa
    add     esi, 4
    dec     ecx
    jnz     .loop_correto   ; continua enquanto ECX > 0

.fim_correto:
    mov     eax, ebx

    pop     ebx
    pop     esi
    ret
