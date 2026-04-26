# Instruções de String x86 — Referência

## Registradores implícitos

| Instrução | Fonte | Destino | Contador | Valor |
|-----------|-------|---------|----------|-------|
| MOVS | DS:[RSI] | ES:[RDI] | RCX | — |
| CMPS | DS:[RSI] | ES:[RDI] | RCX | — |
| LODS | DS:[RSI] | AL/AX/EAX/RAX | RCX | — |
| STOS | — | ES:[RDI] | RCX | AL/AX/EAX/RAX |
| SCAS | — | ES:[RDI] | RCX | AL/AX/EAX/RAX |

## DF — Direction Flag

| DF | Comportamento | Instrução |
|----|---------------|-----------|
| 0 | RSI e RDI **incrementam** (endereço cresce) | CLD (default) |
| 1 | RSI e RDI **decrementam** (endereço decresce) | STD |

**Regra:** SEMPRE executar `CLD` antes de string operations (DF pode estar 1 em situações excepcionais).

## Variantes por tamanho

| Sufixo | Tamanho | Passo RSI/RDI |
|--------|---------|---------------|
| B | Byte (8-bit) | ±1 |
| W | Word (16-bit) | ±2 |
| D | Dword (32-bit) | ±4 |
| Q | Qword (64-bit) — x64 only | ±8 |

## Prefixos REP

| Prefixo | Condição de parada | Usado com |
|---------|-------------------|-----------|
| REP | RCX = 0 | MOVS, STOS, LODS |
| REPE / REPZ | RCX = 0 OU ZF = 0 | CMPS, SCAS |
| REPNE / REPNZ | RCX = 0 OU ZF = 1 | CMPS, SCAS |

## Tabela de uso idiomático

| Operação | Assembly | Equivalente em C |
|----------|----------|------------------|
| Copiar N bytes | `rep movsb` | `memcpy(dst, src, n)` |
| Copiar N dwords | `rep movsd` | `memcpy(dst, src, n*4)` |
| Preencher N bytes | `rep stosb` | `memset(dst, val, n)` |
| Preencher N dwords | `rep stosd` | `wmemset` |
| Strlen | `repne scasb` + NOT RCX + DEC | `strlen(s)` |
| Strcmp até N | `repe cmpsb` | `strncmp(a,b,n)` |
| Buscar byte | `repne scasb` | `memchr(buf, c, n)` |

## Exemplos rápidos NASM

```nasm
; memcpy(dst, src, n) — copiar N bytes
cld
lea rdi, [dst]
lea rsi, [src]
mov rcx, n
rep movsb

; memset(buf, 0, n) — zerar N bytes
cld
lea rdi, [buf]
xor al, al      ; AL = 0
mov rcx, n
rep stosb

; strlen(s) — comprimento da string null-terminated
cld
lea rdi, [s]
xor al, al      ; AL = 0 (null byte)
mov rcx, -1
repne scasb     ; busca null
not rcx
dec rcx         ; RCX = comprimento

; memchr(buf, c, n) — buscar byte c em buf
cld
lea rdi, [buf]
mov al, c
mov rcx, n
repne scasb     ; para quando [RDI] == AL ou RCX == 0
jne .nao_encontrado
lea rax, [rdi-1]  ; endereço do byte encontrado
```

## Delphi asm..end — cuidados

1. **ES e DS** em 32-bit flat model têm base 0 → `ES:[EDI]` e `DS:[ESI]` acessam memória linear normalmente.
2. Em 64-bit, segment overrides são ignorados (exceto FS/GS).
3. **PUSH ESI / PUSH EDI** antes de usá-los — são callee-saved!
4. Em 64-bit Delphi, usar RSI/RDI/RCX (não ESI/EDI/ECX).
