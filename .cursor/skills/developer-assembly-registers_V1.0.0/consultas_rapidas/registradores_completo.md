# Registradores x86 — Tabela completa IA-16 / IA-32 / x86-64

## Registradores de propósito geral

| IA-16 (16-bit) | IA-32 (32-bit) | x86-64 (64-bit) | Extras 64-bit | Papel convencional |
|----------------|----------------|-----------------|---------------|--------------------|
| AX (AH:AL) | EAX | RAX | — | Acumulador, retorno |
| BX (BH:BL) | EBX | RBX | — | Base, callee-saved |
| CX (CH:CL) | ECX | RCX | — | Contador, 1° param x64 |
| DX (DH:DL) | EDX | RDX | — | Dados, 2° param x64 |
| SI | ESI | RSI | SIL | Source index |
| DI | EDI | RDI | DIL | Dest index |
| SP | ESP | RSP | SPL | Stack pointer |
| BP | EBP | RBP | BPL | Base pointer (frame) |
| — | — | R8 | R8D, R8W, R8B | 3° param Windows x64 |
| — | — | R9 | R9D, R9W, R9B | 4° param Windows x64 |
| — | — | R10 | R10D, R10W, R10B | Caller-saved |
| — | — | R11 | R11D, R11W, R11B | Caller-saved |
| — | — | R12 | R12D, R12W, R12B | Callee-saved |
| — | — | R13 | R13D, R13W, R13B | Callee-saved |
| — | — | R14 | R14D, R14W, R14B | Callee-saved |
| — | — | R15 | R15D, R15W, R15B | Callee-saved |

## Registradores especiais

| IA-16 | IA-32 | x86-64 | Descrição |
|-------|-------|--------|-----------|
| IP | EIP | RIP | Instruction Pointer (próxima instrução) |
| FLAGS | EFLAGS | RFLAGS | Flags de status e controle |
| — | — | — | Não acessíveis diretamente com MOV |

## Registradores de segmento

| Reg | Nome | Uso no Windows |
|-----|------|----------------|
| CS | Code Segment | Gerenciado pelo OS |
| DS | Data Segment | Base 0 (flat model) |
| ES | Extra Segment | Usado em MOVS/STOS/CMPS |
| FS | FS Segment | **TEB** em user-mode 32-bit |
| GS | GS Segment | **TEB** em user-mode 64-bit |
| SS | Stack Segment | Base 0 (flat model) |

## Registradores SIMD

| Família | Bits | Quantidade | Disponível em |
|---------|------|-----------|---------------|
| XMM0-XMM7 | 128 | 8 | x86-32 com SSE |
| XMM0-XMM15 | 128 | 16 | x86-64 com SSE |
| YMM0-YMM15 | 256 | 16 | AVX (sobrepõem XMM nos bits baixos) |
| ZMM0-ZMM31 | 512 | 32 | AVX-512 (sobrepõem YMM nos bits baixos) |
| k0-k7 | 64 | 8 | AVX-512 (máscara de predicado) |

## Papel de cada registrador no Delphi

| Contexto | Reg | Papel |
|----------|-----|-------|
| Delphi 32-bit, 1° param | EAX | 1° parâmetro ou Self em métodos |
| Delphi 32-bit, 2° param | EDX | 2° parâmetro |
| Delphi 32-bit, 3° param | ECX | 3° parâmetro |
| Delphi 32-bit, retorno int | EAX | resultado inteiro |
| Delphi 32-bit, retorno float | ST(0) | FPU top-of-stack |
| Delphi 64-bit, Self | RCX | 1° slot (Self em métodos) |
| Delphi 64-bit, 1° param | RCX | ou 2° se Self presente |
| Delphi 64-bit, 2° param | RDX | |
| Delphi 64-bit, 3° param | R8 | |
| Delphi 64-bit, 4° param | R9 | |
| Delphi 64-bit, retorno int | RAX | |
| Delphi 64-bit, retorno float | XMM0 | |
