# Prologo e Epilogo em Funcoes Assembly — Consulta Rapida

## O que sao prologo e epilogo

**Prologo:** codigo gerado no inicio da funcao para criar o stack frame.
**Epilogo:** codigo gerado ao final para desfazer o frame e retornar.

## Prologo/Epilogo Win32 classico

```asm
; PROLOGO:
PUSH EBP          ; salvar frame pointer antigo
MOV  EBP, ESP     ; EBP = frame pointer atual
SUB  ESP, N       ; reservar N bytes para variaveis locais
PUSH EBX          ; salvar registradores non-volatile usados
PUSH ESI
PUSH EDI

; ... corpo da funcao ...

; EPILOGO:
POP  EDI          ; restaurar (ordem inversa)
POP  ESI
POP  EBX
MOV  ESP, EBP     ; restaurar ESP (libera variaveis locais)
POP  EBP          ; restaurar frame pointer antigo
RET N             ; stdcall: limpa N bytes; cdecl: RET simples
```

## Prologo/Epilogo Win64 (gerado pelo Delphi com .PARAMS)

```asm
; PROLOGO (gerado por .PARAMS 2):
PUSH RBP
MOV  RBP, RSP
SUB  RSP, 32      ; shadow space = 32 bytes minimo
; Se .PUSHNV R12: PUSH R12
; Se .SAVENV XMM6: MOVAPS [RSP+offset], XMM6

; ... corpo ...

; EPILOGO:
; Se .SAVENV XMM6: MOVAPS XMM6, [RSP+offset]
; Se .PUSHNV R12: POP R12
MOV  RSP, RBP
POP  RBP
RET
```

## Delphi automatiza prologo/epilogo

No Delphi com funcao `assembler`, o compilador gera o prologo/epilogo
baseado nos pseudo-ops usados:

| Pseudo-ops usados          | Prologo gerado                                    |
| -------------------------- | ------------------------------------------------- |
| Nenhum (leaf)              | Minimo ou nenhum (depende da funcao)              |
| `.PARAMS N`                | PUSH RBP, MOV RBP RSP, SUB RSP 32                |
| `.PARAMS` + `.PUSHNV R12`  | + PUSH R12 no inicio, POP R12 no fim              |
| `.PARAMS` + `.SAVENV XMM6` | + MOVAPS no inicio e fim para XMM6                |
| `nostackframe`             | SEM prologo e SEM epilogo                         |

## Quando o programador deve escrever o prologo manualmente?

**No bloco asm inline (nao-assembler):**
O Delphi NAO gera prologo automaticamente dentro de `begin..asm..end`.
Se voce mudar ESP ou EBP dentro de um bloco asm inline, deve
restaurar manualmente.

```pascal
function ManualFrame(A, B: Integer): Integer;
asm
  // Em bloco inline: se precisar frame manual:
  PUSH EBP
  MOV  EBP, ESP
  // ... usa [EBP+...] se necessario ...
  POP  EBP
  // Nao usar RET aqui — Delphi gera o RET do begin..end
end;
```
