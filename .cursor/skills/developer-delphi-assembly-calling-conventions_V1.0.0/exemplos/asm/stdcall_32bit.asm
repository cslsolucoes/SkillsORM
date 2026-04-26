; stdcall_32bit.asm — Exemplo de funcao stdcall para Win32
; Montagem: nasm -f win32 stdcall_32bit.asm -o stdcall_32bit.obj
; Linkagem com dcc32: incluir stdcall_32bit.obj no projeto .dpr
;
; Declaracao Pascal correspondente:
;   function SomarStdcall(A, B: Integer): Integer; stdcall; external;
;   {$L stdcall_32bit.obj}

section .text

global _SomarStdcall@8    ; nome decorado stdcall: _Nome@(bytes_args)
                           ; 8 = 2 * 4 bytes (dois Integer de 32-bit)

; ------------------------------------------------------------------
; function SomarStdcall(A, B: Integer): Integer; stdcall;
;
; Stack frame apos CALL + PUSH EBP:
;   [EBP+8]  = A (primeiro parametro)
;   [EBP+12] = B (segundo parametro)
; Retorno: EAX
; Callee limpa pilha: RET 8
; ------------------------------------------------------------------
_SomarStdcall@8:
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp+8]    ; EAX = A
    add     eax, [ebp+12]   ; EAX = A + B  (resultado em EAX)

    pop     ebp
    ret     8               ; stdcall: callee descarta 2*4=8 bytes da pilha


; ------------------------------------------------------------------
; function MultiplicarStdcall(A, B, C: Integer): Integer; stdcall;
;
; Stack frame:
;   [EBP+8]  = A
;   [EBP+12] = B
;   [EBP+16] = C
; Retorno: EAX = A * B + C
; ------------------------------------------------------------------
global _MultiplicarStdcall@12

_MultiplicarStdcall@12:
    push    ebp
    mov     ebp, esp
    push    ebx             ; EBX e callee-saved em Win32!

    mov     eax, [ebp+8]    ; EAX = A
    imul    eax, [ebp+12]   ; EAX = A * B
    add     eax, [ebp+16]   ; EAX = A*B + C

    pop     ebx
    pop     ebp
    ret     12              ; stdcall: descarta 3*4=12 bytes
