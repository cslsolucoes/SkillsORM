# Anatomia do Stack Frame — 64-bit (Win64 / Long Mode)

## Diagrama do frame (Windows x64 ABI)

```
Endereço maior
┌────────────────────────────────────────┐
│  ... params 5+ na stack               │ [RBP+48+], [RBP+56]...
├────────────────────────────────────────┤
│  Shadow space R9  (home 4° param)     │ [RBP+40]
│  Shadow space R8  (home 3° param)     │ [RBP+32]
│  Shadow space RDX (home 2° param)     │ [RBP+24]
│  Shadow space RCX (home 1° param)     │ [RBP+16]
├────────────────────────────────────────┤
│  Return Address (CALL empilhou 8 b.)  │ [RBP+8]
├────────────────────────────────────────┤ ← RBP aponta aqui
│  Saved RBP (PUSH RBP)                 │ [RBP+0]
├────────────────────────────────────────┤
│  Variável local 1 (qword)             │ [RBP-8]
│  Variável local 2 (qword)             │ [RBP-16]
│  Variável local N                     │ [RBP-N*8]
├────────────────────────────────────────┤
│  Callee-saved registradores           │ .PUSHNV ou PUSH manual
│  (RBX, RSI, RDI, R12-R15, XMM4-15)   │
├────────────────────────────────────────┤ ← RSP (alinhado a 16)
│  Shadow space 32 bytes p/ chamadas    │ [RSP+0..RSP+24]
└────────────────────────────────────────┘
Endereço menor (stack cresce para baixo)
```

## Prologue padrão Win64

```nasm
push    rbp             ; save frame pointer (RSP -= 8)
mov     rbp, rsp        ; RBP = frame pointer atual

; Opcional: salvar registradores callee-saved
push    rbx             ; (-8 → RSP desalinha)
push    rsi             ; (-8 → RSP realinha)
; NOTA: par de PUSH mantém alinhamento; ímpar de PUSH exige padding

; Reservar espaço: locals + shadow space para subcalls
sub     rsp, 32+N       ; 32 = shadow space mínimo; N = locais
; RSP deve ser múltiplo de 16 aqui!
```

## Regras de alinhamento (crítico!)

```
RSP deve ser 16-byte aligned NO MOMENTO do CALL.
O CALL empilha 8 bytes (return addr), então DENTRO da função RSP é 16n-8.
PUSH RBP: RSP = 16n-16 → múltiplo de 16 ✓

Se número ÍMPAR de PUSH adicionais: RSP desalinha → add sub rsp, 8 para corrigir.
Se número PAR de PUSH adicionais: RSP permanece alinhado.

Checar: total de PUSH + SUB RSP deve ser múltiplo de 16.
```

## Shadow space — regras

1. O chamador DEVE alocar 32 bytes antes de qualquer CALL.
2. Os 32 bytes ficam ACIMA do return address (entre o RSP do chamador e o return addr).
3. A função chamada PODE, mas não é obrigada a, usar esses 32 bytes.
4. Debuggers e ferramentas esperam esses 32 bytes → necessário para unwind correto.

## Epilogue padrão Win64

```nasm
; Liberar locais e shadow space:
add     rsp, 32+N

; Restaurar callee-saved (ordem inversa):
pop     rsi
pop     rbx

; Restaurar frame pointer:
mov     rsp, rbp    ; equivalente a: add rsp, N (se não usou locais)
pop     rbp

ret
```

## Pseudo-ops Delphi 64-bit — mapeamento

| Pseudo-op | Equivalente gerado | Inclui unwind info? |
|-----------|-------------------|---------------------|
| `.PARAMS N` | Shadow space + ajuste | Sim |
| `.PUSHNV Reg` | `PUSH Reg` | Sim |
| `.SAVENV XMMn` | Save XMM na stack | Sim |
| `.NOFRAME` | Sem prologue/epilogue | — (função leaf) |

## Layout de parâmetros (chamador deve preparar antes do CALL)

```
Sub RSP adequado antes de chamar:

Caso: f(a, b, c, d, e)
  mov rcx, a              ; 1° param
  mov rdx, b              ; 2° param
  mov r8,  c              ; 3° param
  mov r9,  d              ; 4° param
  mov qword [rsp+32], e   ; 5° param (acima do shadow space de 32 bytes)
  call f
```
