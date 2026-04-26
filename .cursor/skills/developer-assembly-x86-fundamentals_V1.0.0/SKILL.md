---
name: developer-assembly-x86-fundamentals
description: Fundamentos x86/x64 — modos de endereçamento, segmentos, modo real vs protegido. Independente de assembler.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-assembly-x86-fundamentals_V1.0.0

**Versão:** 1.0.0
**Data:** 2026-04-11
**Locale:** pt-BR
**Categoria:** developer · delphi · assembly

## Propósito

Referência completa de fundamentos da arquitetura x86/x64 para uso com o built-in assembler
do Delphi (blocos `asm..end`) e com NASM (arquivos `.asm` externos). Cobre modos de operação
da CPU, modelo de memória, tamanhos de operandos, notação Intel vs AT&T, ABI x64 Windows e
as instruções especiais RDTSC e CPUID.

---

## Conteúdo técnico

### Modos de operação x86

| Modo | Bits | Proteção | Uso típico |
|------|------|----------|------------|
| Real Mode | 16 | Nenhuma | DOS, BIOS, bootloaders |
| Protected Mode | 32 | Segmentação + paginação | Windows 32-bit, dcc32 |
| Long Mode (IA-32e) | 64 | Paginação (4-level) | Windows 64-bit, dcc64 |
| SMM | 16/32 | Modo de gerenciamento | Firmware (invisível ao OS) |

**Relevância para Delphi:**
- `dcc32` gera código para Protected Mode (32-bit flat)
- `dcc64` gera código para Long Mode (64-bit)
- Blocos `asm..end` herdam o modo do compilador usado

---

### Modelo de memória — Flat Memory Model

No Windows (32 e 64-bit) o modelo é **flat**: todos os segmentos (código, dados, stack) mapeiam
o mesmo espaço de endereçamento linear. Segmentação é virtualmente desativada (base = 0, limite = 4 GB
em 32-bit ou 2^48 em 64-bit).

```
Espaço de endereçamento (32-bit flat):
┌─────────────────────┐ 0xFFFFFFFF
│   Kernel space      │
├─────────────────────┤ 0x80000000 (aprox)
│                     │
│   User space        │
│                     │
│  ┌───────────────┐  │
│  │  Stack (↓)    │  │ ESP/RSP decresce ao empilhar
│  ├───────────────┤  │
│  │  Heap         │  │
│  ├───────────────┤  │
│  │  .bss         │  │ dados não inicializados
│  ├───────────────┤  │
│  │  .data        │  │ dados inicializados
│  ├───────────────┤  │
│  │  .text / .code│  │ código executável
│  └───────────────┘  │
└─────────────────────┘ 0x00000000
```

**Segmentos principais:**
- `.text` / `CODE` — instruções executáveis (read-only em produção)
- `.data` / `DATA` — variáveis globais e constantes inicializadas
- `.bss` — variáveis globais não inicializadas (zeradas pelo OS)
- `stack` — chamadas de função, variáveis locais, parâmetros

---

### Tamanhos de operandos

| Nome | Bits | Bytes | Tipo Pascal equivalente |
|------|------|-------|------------------------|
| byte | 8 | 1 | Byte, ShortInt, Char |
| word | 16 | 2 | Word, SmallInt, WideChar |
| dword | 32 | 4 | DWord, Integer, LongWord |
| qword | 64 | 8 | Int64, UInt64, NativeInt (64-bit) |
| oword | 128 | 16 | XMM registers |
| yword | 256 | 32 | YMM registers (AVX) |
| zword | 512 | 64 | ZMM registers (AVX-512) |

**Sufixos NASM para tamanho de operando de memória:**
```nasm
mov byte  [var], 42    ; escreve 1 byte
mov word  [var], 42    ; escreve 2 bytes
mov dword [var], 42    ; escreve 4 bytes
mov qword [var], 42    ; escreve 8 bytes
```

---

### Notação Intel vs AT&T

O built-in assembler Delphi usa **notação Intel**. NASM também usa Intel por padrão.

| Característica | Intel (Delphi/NASM) | AT&T (GCC/GAS) |
|----------------|---------------------|----------------|
| Ordem operandos | `INST dst, src` | `INST src, dst` |
| Registradores | sem prefixo: `EAX` | com `%`: `%eax` |
| Imediatos | sem prefixo: `42` | com `$`: `$42` |
| Tamanho | por operando: `dword` | por sufixo: `movl` |
| Memória | `[EBP-4]` | `-4(%ebp)` |

```nasm
; Intel (Delphi / NASM)
mov eax, [ebp-4]     ; EAX = conteúdo de [EBP-4]
add eax, 1

; AT&T (GCC inline asm)
movl -4(%ebp), %eax  ; %eax = conteúdo de -4(%ebp)
addl $1, %eax
```

---

### Blocos asm..end no Delphi

#### Regras fundamentais

```pascal
procedure ExemploBlocoAsm;
var
  X: Integer;
begin
  X := 10;
  asm
    // Dentro do bloco:
    // - Sintaxe Intel (mesma do MASM/NASM)
    // - Acesso a variáveis locais pelo nome
    // - Acesso a campos via Self (em métodos)
    MOV EAX, X      // lê variável local X em 32-bit
    ADD EAX, 5
    MOV X, EAX      // escreve de volta
  end;
  // X agora vale 15
end;
```

#### Restrições importantes

1. **Preservação obrigatória (Win32):** EBX, ESI, EDI, EBP, ESP — salvar antes de usar, restaurar antes de sair.
2. **Preservação obrigatória (Win64):** RBX, RSI, RDI, RBP, R12-R15, XMM4-XMM15.
3. **RET** não deve ser emitido manualmente — o Delphi gera o epilogue correto.
4. **Variáveis locais** são acessadas pelo nome diretamente; o compilador resolve o offset.
5. **Parâmetros** de funções `register` chegam em EAX, EDX, ECX (32-bit).
6. Em **64-bit**, o built-in assembler suporta `RAX`, `RCX`, `RDX`, `R8`-`R15`, `XMM*`.
7. Não misturar **FPU** com **SSE** sem `EMMS` / `FNINIT` adequado.

#### Variáveis locais em asm..end

```pascal
procedure DemoVariaveisLocais;
var
  A, B, Resultado: Integer;
begin
  A := 7;
  B := 3;
  asm
    MOV EAX, A      // EAX = 7
    MOV ECX, B      // ECX = 3
    IMUL ECX        // EDX:EAX = EAX * ECX = 21
    MOV Resultado, EAX
  end;
  WriteLn(Resultado); // 21
end;
```

---

### Diretivas NASM principais

```nasm
; --- Diretivas de modo ---
bits 16          ; gera código 16-bit (Real Mode)
bits 32          ; gera código 32-bit (Protected Mode)
bits 64          ; gera código 64-bit (Long Mode)

; --- Seções ---
section .text    ; código
section .data    ; dados inicializados
section .bss     ; dados não inicializados

; --- Visibilidade ---
global _start    ; exportar símbolo para o linker
global MyFunc    ; exportar função para uso externo
extern printf    ; importar símbolo externo

; --- Reserva de espaço (.bss) ---
buffer  resb 256   ; reservar 256 bytes
wbuffer resw 128   ; reservar 128 words (256 bytes)
dbuffer resd  64   ; reservar 64 dwords (256 bytes)
qbuffer resq  32   ; reservar 32 qwords (256 bytes)

; --- Dados inicializados (.data) ---
msg     db 'Ola', 0    ; string terminada em null
count   dd 0           ; dword inicializado com 0
pi      dq 3.14159     ; qword float

; --- Constantes ---
%define BUFFER_SIZE 4096
%define MAX_ITER    100
```

---

### ABI x64 Windows — Pontos críticos

```
Chamador deve providenciar antes de CALL:
┌─────────────────────────────────────────┐
│  ... parâmetros 5+ (na stack) ...       │
├─────────────────────────────────────────┤  ← RSP antes do CALL (alinhado a 16)
│  Shadow space: 32 bytes (4 × 8)         │  ← OBRIGATÓRIO mesmo sem parâmetros!
│  [RSP+24] = 4° arg (home R9)           │
│  [RSP+16] = 3° arg (home R8)           │
│  [RSP+8]  = 2° arg (home RDX)          │
│  [RSP+0]  = 1° arg (home RCX)          │
├─────────────────────────────────────────┤  ← RSP após CALL (CALL empilha return addr)
│  Return address (8 bytes)               │
├─────────────────────────────────────────┤
│  Saved RBP (se usado)                   │
├─────────────────────────────────────────┤
│  Variáveis locais + callee-saved regs   │
└─────────────────────────────────────────┘
```

**Regras de alinhamento:**
- RSP deve estar alinhado a **16 bytes** no momento do `CALL`
- O `CALL` empilha 8 bytes (return address) → dentro da função RSP é `16n - 8`
- O prologue típico `PUSH RBP` restaura o alinhamento para múltiplo de 16

**Registradores voláteis (caller-saved) no Windows x64:**
RAX, RCX, RDX, R8, R9, R10, R11, XMM0-XMM5

**Registradores não-voláteis (callee-saved) no Windows x64:**
RBX, RSI, RDI, RBP, RSP, R12, R13, R14, R15, XMM4-XMM15

---

### RDTSC — Leitura do Timestamp Counter

```pascal
// RDTSC: lê o contador de ciclos do processador
// Resultado: parte baixa em EAX, parte alta em EDX
// Útil para benchmarking de código asm
function ReadTSC: Int64;
asm
  // 32-bit: resultado montado pelo Delphi como EDX:EAX = Int64
  RDTSC
  // Em 32-bit o compilador monta EAX (baixo) + EDX (alto) = Int64
  // Em 64-bit: usar RDTSC + SHL RDX,32 + OR RAX,RDX se necessário
end;
```

---

### CPUID — Detecção de features

```pascal
// CPUID com EAX=1: retorna info de família e feature flags
// ECX bit 28 = AVX, EDX bit 25 = SSE, EDX bit 26 = SSE2
procedure GetCPUFeatures(out HasSSE, HasSSE2, HasAVX: Boolean);
var
  FlagsECX, FlagsEDX: Cardinal;
asm
  PUSH EBX           // EBX é callee-saved em 32-bit!
  MOV  EAX, 1
  CPUID
  MOV  FlagsECX, ECX
  MOV  FlagsEDX, EDX
  POP  EBX
end;
  HasSSE  := (FlagsEDX and (1 shl 25)) <> 0;
  HasSSE2 := (FlagsEDX and (1 shl 26)) <> 0;
  HasAVX  := (FlagsECX and (1 shl 28)) <> 0;
end;
```

---

## Estrutura de arquivos

```
developer-assembly-x86-fundamentals_V1.0.0/
├── SKILL.md
├── exemplos/
│   ├── asm/
│   │   ├── hello_linux_x64.asm
│   │   ├── estrutura_basica.asm
│   │   ├── registradores_gp.asm
│   │   └── modos_enderecamento.asm
│   └── pas/
│       ├── cpu_view_demo.pas
│       ├── registradores_basicos.pas
│       ├── rdtsc_benchmark.pas
│       └── cpuid_info.pas
├── consultas_rapidas/
│   ├── registradores_delphi.md
│   ├── eflags_resumo.md
│   ├── modos_cpu.md
│   ├── cpu_view_guia.md
│   └── enderecamento_modos.md
└── templates/
    ├── TEMPLATE_asm_minimo.pas
    ├── TEMPLATE_cpuid_check.pas
    └── TEMPLATE_nasm_basico.asm
```

## Skills relacionadas

- `developer-assembly-registers_V1.0.0` — registradores em profundidade
- `developer-assembly-instructions_V1.0.0` — conjunto de instruções
- `developer-assembly-stack-call_V1.0.0` — stack frame e convenções de chamada
