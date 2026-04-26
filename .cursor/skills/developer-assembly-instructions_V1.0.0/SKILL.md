---
name: developer-assembly-instructions
description: Referência do conjunto de instruções x86/x64 — utilizável com assembler Delphi, NASM, GAS e similares.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-assembly-instructions_V1.0.0

**Versão:** 1.0.0
**Data:** 2026-04-11
**Locale:** pt-BR
**Categoria:** developer · delphi · assembly

## Propósito

Referência do conjunto de instruções x86/x64 para uso com o built-in assembler Delphi e NASM.
Cobre transferência de dados, aritmética inteira, lógica e deslocamentos, comparação/saltos,
operações de string com prefixo REP, instruções especiais e diferenças de sintaxe entre o
assembler Delphi e NASM.

---

## Transferência de dados

### MOV e variantes

```nasm
; MOV — move dado entre registrador/memória/imediato
mov eax, 42          ; EAX = 42 (imediato)
mov eax, ebx         ; EAX = EBX (registrador)
mov eax, [ptr]       ; EAX = mem[ptr] (carga de memória)
mov [ptr], eax       ; mem[ptr] = EAX (armazenamento)
mov eax, [ebx+4]     ; EAX = mem[EBX+4] (endereçamento baseado)
mov eax, [ebx+ecx*4] ; EAX = mem[EBX + ECX*4] (indexado com escala)
```

```nasm
; MOVZX — move com zero-extension (sem sinal)
movzx eax, byte [ptr]    ; EAX = byte lido, zero-extended para 32-bit
movzx eax, word [ptr]    ; EAX = word lido, zero-extended para 32-bit
movzx rax, byte [ptr]    ; RAX = byte lido, zero-extended para 64-bit

; MOVSX — move com sign-extension (com sinal)
movsx eax, byte [ptr]    ; EAX = byte lido, sign-extended
movsx rax, dword [ptr]   ; RAX = dword lido, sign-extended (= MOVSXD)
```

```nasm
; XCHG — troca valores
xchg eax, ebx        ; swap(EAX, EBX) — atomico com prefixo LOCK implícito em memória
xchg [var], eax      ; swap(mem[var], EAX) — sempre atômico
```

```nasm
; LEA — Load Effective Address: calcula endereço SEM acessar memória
lea eax, [ebx+ecx*4+8]   ; EAX = EBX + ECX*4 + 8 (usa ULA, não memória!)
lea rax, [rip+offset]     ; RIP-relative: endereço relativo ao PC (x64)

; LEA como calculadora (truque comum):
lea eax, [eax+eax*2]     ; EAX = EAX * 3 (sem MUL!)
lea eax, [eax*4]         ; EAX = EAX * 4
```

---

## Aritméticas inteiras

### ADD, SUB, ADC, SBB

```nasm
add eax, ebx         ; EAX = EAX + EBX  (afeta CF, ZF, SF, OF)
add eax, 100         ; EAX = EAX + 100
add [var], eax       ; mem[var] = mem[var] + EAX
sub eax, ebx         ; EAX = EAX - EBX
sub eax, 1           ; EAX = EAX - 1

; ADC/SBB: add/sub com carry (para aritmética de precisão múltipla)
adc eax, ebx         ; EAX = EAX + EBX + CF
sbb eax, ebx         ; EAX = EAX - EBX - CF
```

### INC, DEC, NEG

```nasm
inc eax              ; EAX++ — NÃO afeta CF!
dec ecx              ; ECX-- — NÃO afeta CF!
neg eax              ; EAX = -EAX (complemento de dois)
```

### MUL, IMUL (multiplicação)

```nasm
; MUL — unsigned: resultado em EDX:EAX (32) ou RDX:RAX (64)
mul ebx              ; EDX:EAX = EAX * EBX (sem sinal)
mul dword [ptr]      ; EDX:EAX = EAX * mem (sem sinal)

; IMUL — signed: formas de 1, 2 e 3 operandos
imul ebx             ; EDX:EAX = EAX * EBX (com sinal, forma 1 op)
imul eax, ebx        ; EAX = EAX * EBX (com sinal, truncado — forma 2 ops)
imul eax, ebx, 10    ; EAX = EBX * 10 (com sinal — forma 3 ops)
imul rax, rcx        ; RAX = RAX * RCX (64-bit signed)
```

### DIV, IDIV (divisão)

```nasm
; DIV — unsigned: dividendo em EDX:EAX, divisor é operando
; Resultado: quociente em EAX, resto em EDX
xor edx, edx         ; limpar EDX antes de divisão 32-bit!
div ebx              ; EAX = EDX:EAX / EBX; EDX = resto
div dword [ptr]

; IDIV — signed: dividendo em EDX:EAX (sinal-extended)
cdq                  ; sign-extend EAX -> EDX:EAX (obrigatório antes de IDIV!)
idiv ebx             ; EAX = EDX:EAX / EBX; EDX = resto

; ATENÇÃO: divisão por zero gera INT 0 (#DE exception)
```

---

## Lógicas e deslocamentos

### AND, OR, XOR, NOT

```nasm
and eax, ebx         ; EAX = EAX AND EBX  (CF=OF=0, ZF/SF baseados no resultado)
and eax, 0xFF        ; mascara: mantém apenas byte baixo
or  eax, ebx         ; EAX = EAX OR EBX
or  eax, 0x01        ; seta bit 0
xor eax, ebx         ; EAX = EAX XOR EBX
xor eax, eax         ; EAX = 0 (padrão idiomático — menor que MOV EAX,0!)
not eax              ; EAX = NOT EAX (complemento de bits — NÃO afeta flags!)
```

### Deslocamentos: SHL, SHR, SAR, ROL, ROR

```nasm
; SHL/SAL — shift left (multiplica por potência de 2)
shl eax, 1           ; EAX = EAX * 2 (CF = bit deslocado para fora)
shl eax, 3           ; EAX = EAX * 8
shl eax, cl          ; EAX <<= CL (contador variável DEVE ser em CL)

; SHR — shift right lógico (sem sinal: preenche com 0)
shr eax, 1           ; EAX = EAX / 2 (sem sinal)
shr eax, cl

; SAR — shift right aritmético (com sinal: preserva bit de sinal)
sar eax, 1           ; EAX = EAX / 2 (com sinal, arredonda para -inf)
sar eax, cl

; ROL/ROR — rotações (o bit que sai pela esquerda entra pela direita e vice-versa)
rol eax, 1           ; rotação left 1 bit
ror eax, 1           ; rotação right 1 bit
rol eax, cl

; RCL/RCR — rotação através do CF
rcl eax, 1           ; rotate left through carry
rcr eax, 1           ; rotate right through carry
```

---

## Comparação e saltos

### CMP, TEST

```nasm
; CMP: subtração virtual (NÃO salva resultado, apenas afeta flags)
cmp eax, ebx         ; flags de (EAX - EBX)
cmp eax, 0           ; EAX == 0 ?
cmp dword [ptr], 100 ; mem[ptr] == 100 ?

; TEST: AND virtual (NÃO salva resultado, apenas afeta flags)
test eax, eax        ; EAX == 0 ? (mais rápido que CMP EAX, 0)
test eax, 0x01       ; bit 0 de EAX está setado?
test al, 0b00001111  ; bits 0-3 de AL estão todos zerados?
```

### Tabela completa de saltos condicionais (Jcc)

| Instrução | Sinônimo | Condição | Flags |
|-----------|----------|----------|-------|
| JE | JZ | Igual / Zero | ZF=1 |
| JNE | JNZ | Não igual / Não zero | ZF=0 |
| JG | JNLE | Maior (signed) | ZF=0 AND SF=OF |
| JGE | JNL | Maior ou igual (signed) | SF=OF |
| JL | JNGE | Menor (signed) | SF≠OF |
| JLE | JNG | Menor ou igual (signed) | ZF=1 OR SF≠OF |
| JA | JNBE | Acima (unsigned) | CF=0 AND ZF=0 |
| JAE | JNB, JNC | Acima ou igual (unsigned) | CF=0 |
| JB | JNAE, JC | Abaixo (unsigned) | CF=1 |
| JBE | JNA | Abaixo ou igual (unsigned) | CF=1 OR ZF=1 |
| JS | — | Sinal negativo | SF=1 |
| JNS | — | Sinal positivo | SF=0 |
| JO | — | Overflow | OF=1 |
| JNO | — | Sem overflow | OF=0 |
| JP | JPE | Paridade par | PF=1 |
| JNP | JPO | Paridade ímpar | PF=0 |

```nasm
; Padrão típico: CMP + Jcc
cmp eax, 10
jge .maior_igual    ; salta se EAX >= 10 (signed)
; código para EAX < 10
jmp .fim
.maior_igual:
; código para EAX >= 10
.fim:

; JMP incondicional
jmp label           ; salto relativo curto/longo
jmp eax             ; salto indireto (jump table)
jmp [eax]           ; salto indireto via memória
```

---

## Operações de string

```nasm
; MOVSB/MOVSW/MOVSD/MOVSQ — copia DS:[RSI] → ES:[RDI], incrementa/decrementa RSI e RDI
movsb               ; copia 1 byte
movsw               ; copia 2 bytes (word)
movsd               ; copia 4 bytes (dword)
movsq               ; copia 8 bytes (qword) — x64

; CMPSB/CMPSW/CMPSD — compara DS:[RSI] com ES:[RDI]
cmpsb               ; compara 1 byte, afeta flags

; SCASB/SCASW/SCASD — busca AL/AX/EAX em ES:[RDI]
scasb               ; compara AL com byte em [RDI]

; LODSB/LODSW/LODSD/LODSQ — carrega DS:[RSI] em AL/AX/EAX/RAX
lodsb               ; AL = byte em [RSI]; incrementa RSI

; STOSB/STOSW/STOSD/STOSQ — armazena AL/AX/EAX/RAX em ES:[RDI]
stosb               ; byte [RDI] = AL; incrementa RDI
stosd               ; dword [RDI] = EAX; incrementa RDI por 4

; Prefixos REP:
; REP   — repete RCX vezes (para MOVS, STOS, LODS)
; REPE/REPZ  — repete enquanto ZF=1 (para CMPS, SCAS)
; REPNE/REPNZ — repete enquanto ZF=0 (para CMPS, SCAS)

; Direção: DF=0 (CLD) → incremento, DF=1 (STD) → decremento
cld                 ; direction flag = 0 (incrementar — padrão)
std                 ; direction flag = 1 (decrementar)

; Exemplo: copiar 100 bytes de src para dst
lea rsi, [src]
lea rdi, [dst]
mov rcx, 100
cld
rep movsb           ; copia 100 bytes RSI→RDI

; Exemplo: buscar null byte (strlen)
lea rdi, [string]
xor al, al          ; AL = 0
mov rcx, -1         ; RCX = contador máximo
cld
repne scasb         ; busca até AL == byte em [RDI]
not rcx             ; RCX = comprimento + 1
dec rcx             ; RCX = comprimento
```

---

## Instruções especiais

```nasm
; NOP — No Operation (1 byte, usado para alinhamento ou patch)
nop
nop dword [rax+0]   ; NOP multi-byte (alinhamento de código)

; HLT — Halt (para execução até próxima interrupção — apenas ring 0)
hlt

; INT 3 — Breakpoint de software (debug trap)
int3                ; gera exceção #BP — o debugger captura
; int 3 (com espaço) gera opcode 0xCD 0x03 (2 bytes)
; int3 (sem espaço) gera opcode 0xCC (1 byte — preferido para breakpoints)

; PAUSE — hint para loops de spin-wait (economiza energia no HT)
pause               ; equivalente a REP NOP (0xF3 0x90)

; CPUID — consulta features (destrói EAX,EBX,ECX,EDX)
mov eax, 0          ; função 0: vendor string
cpuid               ; EBX:EDX:ECX = "GenuineIntel" ou "AuthenticAMD"
```

---

## Diferenças de sintaxe — Delphi built-in assembler

| Situação | NASM | Delphi asm..end |
|----------|------|-----------------|
| Tamanho de operando de memória | `mov dword [var], 0` | `mov dword ptr [var], 0` |
| Rótulo local | `.label:` | `@label:` |
| Referência a variável Pascal | — | `MOV EAX, MinhaVar` |
| Endereço de variável | `lea rax, [var]` | `LEA EAX, MinhaVar` |
| Chamada a função Pascal | `call _ProcName` | `CALL PascalProc` (direto) |
| Comentários | `;` | `//` ou `{ }` |

```pascal
// Exemplo: diferenças de rótulos no Delphi asm
procedure ExemploRotulos(N: Integer);
asm
  MOV ECX, N
  TEST ECX, ECX
  JZ @zero          // rótulo local com @
@loop:
  DEC ECX
  JNZ @loop
@zero:
  // fim
end;
```

---

## Estrutura de arquivos

```
developer-assembly-instructions_V1.0.0/
├── SKILL.md
├── exemplos/
│   ├── asm/
│   │   ├── aritmetica.asm
│   │   ├── bitwise_shifts.asm
│   │   ├── comparacao_saltos.asm
│   │   ├── string_operations.asm
│   │   ├── loop_patterns.asm
│   │   └── conditional_ops.asm
│   └── pas/
│       ├── aritmetica_delphi.pas
│       ├── bitwise_flags.pas
│       ├── string_move.pas
│       ├── condicional_cmov.pas
│       ├── loop_counter.pas
│       └── prefixo_lock.pas
├── consultas_rapidas/
│   ├── instrucoes_referencia.md
│   ├── jcc_tabela.md
│   ├── string_ops.md
│   └── instrucoes_delphi_diffs.md
└── templates/
    ├── TEMPLATE_loop_array.pas
    ├── TEMPLATE_atomic_inc.pas
    ├── TEMPLATE_memset_asm.pas
    └── TEMPLATE_loop_nasm.asm
```

## Skills relacionadas

- `developer-assembly-x86-fundamentals_V1.0.0` — arquitetura base
- `developer-assembly-registers_V1.0.0` — registradores e flags
- `developer-assembly-stack-call_V1.0.0` — stack frame e convenções de chamada
