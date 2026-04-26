; funcao_retorna_int.asm — Funcoes NASM retornando Integer para Delphi
; Montagem Win32: nasm -f win32 funcao_retorna_int.asm -o funcao_retorna_int.obj
; Montagem Win64: nasm -f win64 funcao_retorna_int.asm -o funcao_retorna_int.obj
;
; Declaracoes Pascal correspondentes (arquivo .pas):
;   {$L funcao_retorna_int.obj}
;   function SomaNasm(A, B: Integer): Integer; external;
;   function MaximoNasm(A, B: Integer): Integer; external;
;   function FatorialNasm(N: Integer): Integer; external;

%ifdef WIN32

section .text

; ------------------------------------------------------------------
; function SomaNasm(A, B: Integer): Integer;
; register convention: A=EAX, B=EDX, retorno=EAX
; ------------------------------------------------------------------
global _SomaNasm        ; prefixo _ para cdecl/registro Win32

_SomaNasm:
    add     eax, edx
    ret


; ------------------------------------------------------------------
; function MaximoNasm(A, B: Integer): Integer;
; ------------------------------------------------------------------
global _MaximoNasm

_MaximoNasm:
    cmp     eax, edx
    jge     .retorna_a
    mov     eax, edx
.retorna_a:
    ret


; ------------------------------------------------------------------
; function FatorialNasm(N: Integer): Integer;
; N=EAX, retorno=EAX
; Implementacao iterativa (sem recursao — evita stack overhead)
; ------------------------------------------------------------------
global _FatorialNasm

_FatorialNasm:
    push    ebx
    mov     ecx, eax        ; ECX = N
    mov     eax, 1          ; EAX = resultado = 1
    cmp     ecx, 0
    jle     .fim

.loop:
    imul    eax, ecx        ; resultado *= ECX
    dec     ecx
    jnz     .loop

.fim:
    pop     ebx
    ret

%endif  ; WIN32


%ifdef WIN64

section .text

; ------------------------------------------------------------------
; function SomaNasm(A, B: Integer): Integer;
; Win64: A=ECX, B=EDX, retorno=EAX
; ------------------------------------------------------------------
global SomaNasm         ; Win64: sem prefixo _

SomaNasm:
    mov     eax, ecx
    add     eax, edx
    ret


global MaximoNasm

MaximoNasm:
    mov     eax, ecx
    cmp     eax, edx
    jge     .retorna_a
    mov     eax, edx
.retorna_a:
    ret


global FatorialNasm

FatorialNasm:
    ; ECX = N
    mov     eax, 1
    cmp     ecx, 0
    jle     .fim
.loop:
    imul    eax, ecx
    dec     ecx
    jnz     .loop
.fim:
    ret

%endif  ; WIN64
