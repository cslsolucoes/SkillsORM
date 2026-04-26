---
name: developer-assembly-registers
description: GPRs, segmento, flags, SSE/AVX em x86/x64. Aplicável a Delphi assembler, NASM, GAS.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-assembly-registers_V1.0.0

**Versão:** 1.0.0
**Data:** 2026-04-11
**Locale:** pt-BR
**Categoria:** developer · delphi · assembly

## Propósito

Referência completa dos registradores x86/x86-64: subdivisões de tamanho, registradores de
segmento, RFLAGS bit a bit, RIP, registradores SIMD (XMM/YMM/ZMM) e convenções de preservação
(caller-saved vs callee-saved) para Windows x64 ABI. Inclui exemplos concretos de uso no
built-in assembler Delphi.

---

## Registradores de propósito geral x86-64

### Tabela completa de subdivisões

| 64-bit | 32-bit | 16-bit | 8-bit alto | 8-bit baixo | Uso convencional |
|--------|--------|--------|------------|-------------|------------------|
| RAX | EAX | AX | AH | AL | Acumulador, retorno de função |
| RBX | EBX | BX | BH | BL | Base, callee-saved |
| RCX | ECX | CX | CH | CL | Contador, 1° param (x64) |
| RDX | EDX | DX | DH | DL | Dados, 2° param (x64) |
| RSI | ESI | SI | — | SIL | Source index, 6° param (Linux) |
| RDI | EDI | DI | — | DIL | Dest index, 7° param (Linux) |
| RSP | ESP | SP | — | SPL | Stack pointer (NÃO modificar!) |
| RBP | EBP | BP | — | BPL | Base pointer (frame), callee-saved |
| R8 | R8D | R8W | — | R8B | 3° param Windows x64 |
| R9 | R9D | R9W | — | R9B | 4° param Windows x64 |
| R10 | R10D | R10W | — | R10B | Caller-saved, uso geral |
| R11 | R11D | R11W | — | R11B | Caller-saved, uso geral |
| R12 | R12D | R12W | — | R12B | Callee-saved |
| R13 | R13D | R13W | — | R13B | Callee-saved |
| R14 | R14D | R14W | — | R14B | Callee-saved |
| R15 | R15D | R15W | — | R15B | Callee-saved |

**REGRA CRÍTICA — Zero-extension em 64-bit:**
Escrever em um registrador de 32 bits (ex: `EAX`) **zera automaticamente** os 32 bits
superiores do registrador de 64 bits (`RAX`). Operações de 8 e 16 bits NÃO fazem isso.

```nasm
; Exemplo de zero-extension automático
mov rax, 0xFFFFFFFFFFFFFFFF   ; RAX = 0xFFFFFFFFFFFFFFFF
mov eax, 1                    ; RAX = 0x0000000000000001 (zeros superiores!)
mov ax,  1                    ; RAX = 0xFFFFFFFF00000001 (NÃO zera os 48 bits superiores)
mov al,  1                    ; RAX = 0xFFFFFFFFFFFF0001 (NÃO zera os 56 bits superiores)
```

---

### Layout interno de RAX (exemplo aplicável a todos)

```
RAX (64 bits):
┌────────────────────────────────────────────────────────────────┐
│ 63                              32 31              16 15  8 7  0│
│                EAX                      AX           AH   AL   │
└────────────────────────────────────────────────────────────────┘
```

---

## Registradores de segmento

| Registrador | Nome | Uso no Windows flat model |
|-------------|------|--------------------------|
| CS | Code Segment | Aponta para segmento de código (gerenciado pelo OS) |
| DS | Data Segment | Dados (base 0 em flat model) |
| ES | Extra Segment | Usado em string ops (MOVS, STOS) |
| FS | FS Segment | **TEB** (Thread Environment Block) em Windows user-mode |
| GS | GS Segment | **TEB** em Windows x64 / PCB em kernel mode |
| SS | Stack Segment | Stack (base 0 em flat model) |

**Nota:** No Windows `FS:[0]` (32-bit) e `GS:[0x30]` (64-bit) apontam para o TEB. Útil para
exceções estruturadas (SEH) e TLS.

---

## RFLAGS — Registrador de flags

### Mapa de bits principais

| Bit | Sigla | Nome | Quando é setado (1) |
|-----|-------|------|---------------------|
| 0 | CF | Carry Flag | Resultado gerou carry/borrow; overflow sem sinal |
| 2 | PF | Parity Flag | Byte baixo do resultado tem número PAR de bits 1 |
| 4 | AF | Auxiliary Carry | Carry do bit 3 para o bit 4 (aritmética BCD) |
| 6 | ZF | Zero Flag | Resultado é **zero** |
| 7 | SF | Sign Flag | Resultado é **negativo** (bit mais alto = 1) |
| 8 | TF | Trap Flag | Single-step mode (debug) |
| 9 | IF | Interrupt Enable | Interrupções habilitadas |
| 10 | DF | Direction Flag | String ops decrementam (STD/CLD) |
| 11 | OF | Overflow Flag | Overflow em operação **com sinal** |

### Como instruções afetam as flags

| Instrução | CF | ZF | SF | OF | Observação |
|-----------|----|----|----|----|------------|
| ADD/SUB | sim | sim | sim | sim | Todas as aritméticas |
| MUL | sim | — | — | sim | CF=OF=0 se parte alta é zero |
| IMUL | sim | — | — | sim | CF=OF=0 se não houve overflow |
| CMP | sim | sim | sim | sim | Subtração sem salvar resultado |
| TEST | 0 | sim | sim | 0 | AND sem salvar resultado |
| INC/DEC | — | sim | sim | sim | CF **não** é afetado! |
| AND/OR/XOR | 0 | sim | sim | 0 | Lógicas zeram CF e OF |
| SHL/SHR | sim | sim | sim | sim | CF = último bit deslocado |

---

## RIP — Instruction Pointer

- **RIP** (64-bit) / **EIP** (32-bit): aponta para a **próxima instrução** a executar.
- Não pode ser lido/escrito diretamente com `MOV` em x86 clássico.
- Em x64, pode ser usado como base de endereçamento RIP-relative: `mov rax, [rip+offset]`
- É modificado por: `JMP`, `CALL`, `RET`, `Jcc`, `LOOP`, interrupções.

```nasm
; RIP-relative addressing (x64 NASM)
section .data
  valor dq 42

section .text
  mov rax, [rel valor]   ; lê 'valor' relativo a RIP (PIC-friendly)
```

---

## Registradores SIMD

### XMM (SSE) — 128 bits

- **XMM0-XMM15** (x64) / **XMM0-XMM7** (x86-32)
- Cada XMM = 128 bits = 16 bytes = 4 floats = 2 doubles = 8 words = 4 ints
- Mapeados sobre os 128 bits baixos dos YMM

```nasm
; Operações SSE básicas
movaps xmm0, [array]     ; load 4 floats alinhados (16-byte aligned)
movups xmm1, [ptr]       ; load 4 floats NÃO alinhados
addps  xmm0, xmm1        ; soma 4 floats em paralelo (packed single)
mulpd  xmm0, xmm2        ; multiplica 2 doubles em paralelo (packed double)
```

### YMM (AVX) — 256 bits

- **YMM0-YMM15** — requerem `{$DEFINE CPUAVX}` ou detecção em runtime
- Os 128 bits inferiores de YMM sobrepõem exatamente XMM

```nasm
; Operações AVX básicas (256-bit)
vmovaps ymm0, [array]    ; load 8 floats alinhados
vaddps  ymm0, ymm0, ymm1 ; soma 8 floats em paralelo
```

### ZMM (AVX-512) — 512 bits

- **ZMM0-ZMM31** — requerem suporte AVX-512 (Skylake-X+, Ice Lake+)
- Inclui máscara de predicado k0-k7 para operações seletivas

---

## Convenções de preservação

### Windows x64 ABI

**Caller-saved (voláteis — não preservados entre calls):**
```
RAX, RCX, RDX, R8, R9, R10, R11
XMM0, XMM1, XMM2, XMM3, XMM4, XMM5
```

**Callee-saved (não-voláteis — DEVEM ser preservados):**
```
RBX, RBP, RSI, RDI, R12, R13, R14, R15, RSP
XMM4, XMM5, XMM6, XMM7, XMM8, XMM9, XMM10, XMM11,
XMM12, XMM13, XMM14, XMM15
```

### Delphi 32-bit — Convenção "register"

| Registrador | Papel |
|-------------|-------|
| EAX | Self (métodos) ou 1° parâmetro; retorno de inteiro |
| EDX | 2° parâmetro |
| ECX | 3° parâmetro |
| ST(0) | Retorno de float/extended (FPU) |
| EBX, ESI, EDI, EBP, ESP | Callee-saved — DEVEM ser preservados |

### Delphi 64-bit — Windows x64 ABI

| Registrador | Papel |
|-------------|-------|
| RCX | Self (métodos) ou 1° parâmetro |
| RDX | 2° parâmetro |
| R8 | 3° parâmetro |
| R9 | 4° parâmetro |
| RAX | Retorno de inteiro/ponteiro |
| XMM0 | Retorno de float/double |

---

## Exemplo: função que retorna valor via RAX

```pascal
// Função assembly pura que retorna A + B via RAX
// Compatível com dcc64 (Windows x64)
function SomaDois(A, B: Int64): Int64;
asm
  // RCX = A, RDX = B (Windows x64: 1° e 2° params)
  MOV RAX, RCX   // RAX = A
  ADD RAX, RDX   // RAX = A + B
  // Retorno implícito: o valor em RAX é o resultado
end;
```

```pascal
// Versão 32-bit: A em EAX, B em EDX
function SomaDois32(A, B: Integer): Integer;
asm
  // EAX = A (1° param), EDX = B (2° param)
  ADD EAX, EDX   // EAX = A + B (resultado retornado em EAX)
end;
```

---

## Estrutura de arquivos

```
developer-assembly-registers_V1.0.0/
├── SKILL.md
├── exemplos/
│   ├── asm/
│   │   ├── registradores_subdivisoes.asm
│   │   └── lea_calculos.asm
│   └── pas/
│       ├── parametros_register.pas
│       ├── parametros_x64.pas
│       ├── preservar_obrigatorios.pas
│       └── self_access.pas
├── consultas_rapidas/
│   ├── registradores_completo.md
│   ├── preservacao_regras.md
│   ├── self_e_params.md
│   └── r8_r15_restricoes.md
└── templates/
    ├── TEMPLATE_metodo_asm.pas
    ├── TEMPLATE_func_preserva.pas
    └── TEMPLATE_registradores.asm
```

## Skills relacionadas

- `developer-assembly-x86-fundamentals_V1.0.0` — arquitetura, modos, modelo de memória
- `developer-assembly-instructions_V1.0.0` — conjunto de instruções
- `developer-assembly-stack-call_V1.0.0` — stack frame e convenções de chamada
