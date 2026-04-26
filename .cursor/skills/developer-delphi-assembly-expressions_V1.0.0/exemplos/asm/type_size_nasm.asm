; type_size_nasm.asm — Equivalentes NASM de TYPE e SIZE do Delphi
; Em NASM, tamanhos de tipo sao expressos como constantes ($, %sizeof, DWORD etc.)
; O NASM nao tem `TYPE` nem `SIZE` do Delphi — calculamos manualmente

%define SIZEOF_INT32  4
%define SIZEOF_INT64  8
%define SIZEOF_FLOAT  4   ; Single
%define SIZEOF_DOUBLE 8

; Macro para calcular tamanho de struct definida no NASM:
; (Delphi: TYPE TMyRecord = SizeOf(TMyRecord))
struc TMyRecord
    .campo1: resd 1    ; 4 bytes (Integer)
    .campo2: resq 1    ; 8 bytes (Double)
    .campo3: resb 4    ; 4 bytes (array de 4 bytes)
    ; Total: 16 bytes
endstruc
%define SIZEOF_TMYRECORD TMyRecord_size   ; definido automaticamente por struc

; Array global de inteiros:
section .data
    GArray resd 10     ; 10 * 4 = 40 bytes (como array[0..9] of Integer)
    ARRAY_SIZE equ $ - GArray   ; tamanho total em bytes = 40

section .text

; ------------------------------------------------------------------
; Demonstracao: copiar N elementos usando TYPE para calcular offset
; procedure CopiarInteiros(Dest, Src: PInteger; Count: Integer);
; Win32: Dest=EAX, Src=EDX, Count=ECX
; ------------------------------------------------------------------
global _CopiarInteiros

_CopiarInteiros:
    push    esi
    push    edi

    mov     edi, eax    ; EDI = Dest
    mov     esi, edx    ; ESI = Src
    ; ECX = Count

    test    ecx, ecx
    jz      .fim

    ; SIZEOF_INT32 = 4 (size de 1 elemento)
    ; Copiar usando REP MOVSD (move 4 bytes = 1 Integer por vez):
    cld
    rep     movsd       ; copia ECX DWORDs de [ESI] para [EDI]

.fim:
    pop     edi
    pop     esi
    ret


; ------------------------------------------------------------------
; Demonstracao: acessar campo de struct via offset calculado
; Equivale ao Delphi: VMTOFFSET / acesso a campo [EAX].TRecord.Campo
; ------------------------------------------------------------------

; Definicao da struct (replique no Pascal como TRegistro):
; struc TRegistro (definido acima como TMyRecord)
;   .campo1 = offset 0 (Integer, 4 bytes)
;   .campo2 = offset 4 (Double, 8 bytes)
;   .campo3 = offset 12 (array 4 bytes)

global _LerCampo2

_LerCampo2:
    ; EAX = ponteiro para TMyRecord
    ; Ler campo2 (Double, offset 4):
    push    ebp
    mov     ebp, esp
    sub     esp, 8          ; espaco para Double local

    ; Carregar Double de campo2:
    fld     qword [eax + TMyRecord.campo2]  ; ST(0) = registro.campo2
    ; Retorno de Double em ST(0) (Win32)

    mov     esp, ebp
    pop     ebp
    ret
