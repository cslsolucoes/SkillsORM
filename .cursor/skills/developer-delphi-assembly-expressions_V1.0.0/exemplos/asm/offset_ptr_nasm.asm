; offset_ptr_nasm.asm — Expressoes de endereco em NASM
; Demonstra equivalentes NASM das expressoes Delphi OFFSET e PTR
;
; No NASM, enderecos de dados globais sao referenciados diretamente pelo label
; Em Delphi, usa-se OFFSET para variaveis globais

section .data
    GVarA dd 42             ; variavel global (equivale a var GVarA: Integer = 42)
    GVarB dq 1234567890.0   ; Double

    ; Array de 10 inteiros:
    GArray dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

    ; Constante de multiplicacao:
    CMult dd 7

section .text

; ------------------------------------------------------------------
; Demonstracao de acesso a globais por endereco
; function AcessarGlobal: Integer;
; Win32 register: retorno=EAX
; ------------------------------------------------------------------
global _AcessarGlobal

_AcessarGlobal:
    ; Em NASM (flat model Win32):
    ;   MOV EAX, GVarA      = carregar VALOR de GVarA (nao o endereco!)
    ;   MOV EAX, [GVarA]    = idem (colchetes opcionais para dados)
    ;   LEA EAX, [GVarA]    = carregar ENDERECO de GVarA (como OFFSET no Delphi)
    ;   MOV EAX, GVarA      = em NASM, isso tambem carrega o valor (por default)

    ; Carregar valor:
    mov     eax, [GVarA]    ; EAX = GVarA (42)
    ret


; ------------------------------------------------------------------
; Acesso indexado a array: equivale a GArray[Index]
; function ElementoArray(Index: Integer): Integer;
; Win32: Index=EAX
; ------------------------------------------------------------------
global _ElementoArray

_ElementoArray:
    ; EAX = Index
    ; Elemento em GArray[Index] = [GArray + Index*4]
    ; (Integer = 4 bytes)

    lea     ecx, [GArray]           ; ECX = endereco base do array
    mov     eax, [ecx + eax*4]      ; EAX = GArray[Index] (escala 4 = sizeof(Integer))
    ret


; ------------------------------------------------------------------
; Multiplicacao por 7 usando LEA (sem MUL)
; Metodo: N*7 = N*8 - N = (N SHL 3) - N
; Ou: N*7 = N*4 + N*2 + N
; function MultiplicarPor7(N: Integer): Integer;
; Win32: N=EAX
; ------------------------------------------------------------------
global _MultiplicarPor7

_MultiplicarPor7:
    ; Metodo 1: LEA + LEA
    lea     ecx, [eax + eax*2]      ; ECX = N + N*2 = 3*N
    lea     eax, [eax + ecx*2]      ; EAX = N + 3*N*2 = N + 6*N = 7*N
    ret


; ------------------------------------------------------------------
; Multiplicacao por 6, 10, 12, 15 usando combinacoes de LEA/SHL
; ------------------------------------------------------------------
global _MultiplicarPor6

_MultiplicarPor6:
    lea     eax, [eax + eax*2]      ; EAX = 3*N
    lea     eax, [eax + eax]        ; EAX = 2*(3*N) = 6*N
    ; Alternativa: LEA EAX, [EAX*2] + ADD EAX, [EAX*4]
    ret

global _MultiplicarPor10

_MultiplicarPor10:
    lea     eax, [eax + eax*4]      ; EAX = 5*N
    lea     eax, [eax + eax]        ; EAX = 2*(5*N) = 10*N
    ret

global _MultiplicarPor15

_MultiplicarPor15:
    lea     ecx, [eax + eax*4]      ; ECX = 5*N
    lea     eax, [ecx + ecx*2]      ; EAX = 3*(5*N) = 15*N
    ret
