; memcopy_nasm.asm — Copia de memoria otimizada para Delphi
; Montagem: nasm -f win32 memcopy_nasm.asm -o memcopy_nasm.obj
;
; Declaracao Pascal:
;   {$L memcopy_nasm.obj}
;   procedure MemCopyNasm(Dest, Src: Pointer; Count: NativeUInt); external;
;   function SomaArrayNasm(P: PInteger; N: Integer): Integer; external;

section .text

; ------------------------------------------------------------------
; procedure MemCopyNasm(Dest, Src: Pointer; Count: NativeUInt);
; Win32 register: Dest=EAX, Src=EDX, Count=ECX
; Usa REP MOVSD para copias de dwords (4 bytes por vez)
; ------------------------------------------------------------------
global _MemCopyNasm

_MemCopyNasm:
    push    esi
    push    edi

    mov     edi, eax        ; EDI = Dest
    mov     esi, edx        ; ESI = Src
    ; Count (ECX) ja esta em ECX

    ; Copiar blocos de 4 bytes (DWORD):
    mov     edx, ecx
    shr     ecx, 2          ; ECX = Count / 4 (numero de dwords)
    and     edx, 3          ; EDX = Count mod 4 (bytes restantes)

    test    ecx, ecx
    jz      .bytes_restantes
    rep     movsd           ; copiar dwords (4 bytes por iteracao)

.bytes_restantes:
    mov     ecx, edx        ; ECX = bytes restantes (0-3)
    rep     movsb           ; copiar bytes restantes

    pop     edi
    pop     esi
    ret


; ------------------------------------------------------------------
; function SomaArrayNasm(P: PInteger; N: Integer): Integer;
; Soma N inteiros no array apontado por P
; Win32 register: P=EAX, N=EDX
; ------------------------------------------------------------------
global _SomaArrayNasm

_SomaArrayNasm:
    push    esi
    push    ebx

    mov     esi, eax        ; ESI = P
    mov     ecx, edx        ; ECX = N
    xor     ebx, ebx        ; EBX = soma = 0

    test    ecx, ecx
    jz      .fim

.loop:
    add     ebx, [esi]      ; soma elemento atual
    add     esi, 4          ; proxima posicao (Integer = 4 bytes)
    dec     ecx
    jnz     .loop

.fim:
    mov     eax, ebx        ; retorno em EAX

    pop     ebx
    pop     esi
    ret
