---
name: developer-assembly-stack-call
description: Stack e convenções de chamada x86/x64 — prologue, epilogue, register vs stack calling conventions, Windows x64 ABI, System V AMD64.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-assembly-stack-call_V1.0.0

**Versão:** 1.0.0
**Data:** 2026-04-11
**Locale:** pt-BR
**Categoria:** developer · delphi · assembly

## Propósito

Referência completa de stack frames, mecanismo CALL/RET, shadow space Windows x64, passagem de
parâmetros e pseudo-ops do built-in assembler Delphi (.PARAMS, .PUSHNV, .SAVENV, .NOFRAME).
Inclui exemplos de funções assembly chamadas do Delphi com 2 parâmetros.

---

## PUSH e POP — Operações de stack

```nasm
; PUSH: RSP -= tamanho; mem[RSP] = valor
push rax             ; RSP -= 8; [RSP] = RAX
push rbx
push 42              ; valor imediato (sign-extended para 64-bit)
push qword [var]     ; empilha valor de memória

; POP: valor = mem[RSP]; RSP += tamanho
pop rax              ; RAX = [RSP]; RSP += 8
pop rbx

; ATENÇÃO: PUSH/POP sempre em pares! RSP deve ser restaurado.
```

---

## Mecanismo CALL e RET

### O que CALL faz

```
CALL label:
  1. RSP -= 8                    (reserva espaço)
  2. [RSP] = RIP_próxima_instrução  (salva return address)
  3. RIP = endereço_de_label     (salta para a função)
```

### O que RET faz

```
RET:
  1. RIP = [RSP]   (lê return address)
  2. RSP += 8      (remove return address da stack)
  3. continua em RIP

RET N (com valor):
  1. RIP = [RSP]
  2. RSP += 8 + N  (remove return address + N bytes de parâmetros)
  Usado quando a FUNÇÃO (callee) limpa a stack (stdcall no Win32)
```

```nasm
; Visão da stack durante a execução de uma função:
;
; Antes do CALL (caller):
;   [RSP]    = espaço para shadow space / args
;
; Imediatamente após CALL (dentro da função):
;   [RSP]    = return address   ← RSP aqui = RSP_caller - 8
;   [RSP+8]  = shadow[0]  (home de RCX)
;   [RSP+16] = shadow[1]  (home de RDX)
;   [RSP+24] = shadow[2]  (home de R8)
;   [RSP+32] = shadow[3]  (home de R9)
;   [RSP+40] = 5° parâmetro (se houver)
```

---

## Stack Frame — Prologue e Epilogue

### Padrão 32-bit (Win32)

```nasm
; Prologue padrão 32-bit:
push ebp             ; salva frame pointer anterior
mov  ebp, esp        ; novo frame pointer = stack pointer atual
sub  esp, N          ; reserva N bytes para variáveis locais

; Acesso a parâmetros (acima de EBP):
;   [EBP+8]  = 1° parâmetro (em stdcall/pascal)
;   [EBP+12] = 2° parâmetro
; Acesso a variáveis locais (abaixo de EBP):
;   [EBP-4]  = 1ª variável local
;   [EBP-8]  = 2ª variável local

; Epilogue padrão 32-bit:
mov  esp, ebp        ; restaura stack pointer
pop  ebp             ; restaura frame pointer
ret                  ; (ou RET N se função limpa stack)
```

### Padrão 64-bit (Win64)

```nasm
; Prologue padrão 64-bit:
push rbp             ; salva RBP (callee-saved)
mov  rbp, rsp        ; frame pointer
sub  rsp, N          ; N deve manter RSP alinhado a 16-bytes!
; (N = múltiplo de 16, ou 8+múltiplo de 16 se número ímpar de push)

; Parâmetros chegam via registradores (Windows x64):
;   RCX = 1° param (ou Self)
;   RDX = 2° param
;   R8  = 3° param
;   R9  = 4° param
;   [RBP+16+0]  = 5° param (primeiros 32 bytes = shadow space)
;   [RBP+48]    = 5° param de fato (acima do shadow space)

; Variáveis locais (abaixo de RBP):
;   [RBP-8]  = 1ª local
;   [RBP-16] = 2ª local

; Epilogue padrão 64-bit:
mov  rsp, rbp        ; restaura RSP
pop  rbp             ; restaura RBP
ret
```

---

## Shadow Space (Windows x64) — Regra crítica

O chamador **DEVE** alocar 32 bytes (4 × 8) de shadow space antes de qualquer CALL no
Windows x64 ABI. Isso é obrigatório mesmo quando a função chamada não tem parâmetros.

```
Stack layout antes de CALL (Windows x64):
                        ← RSP deve ser 16-byte aligned AQUI
┌─────────────────────┐
│ [RSP+32] home R9    │  ← shadow para 4° param
│ [RSP+24] home R8    │  ← shadow para 3° param
│ [RSP+16] home RDX   │  ← shadow para 2° param
│ [RSP+8]  home RCX   │  ← shadow para 1° param
│ [RSP+0]  ← RSP      │  ← CALL escreve return address aqui
└─────────────────────┘
```

```nasm
; Exemplo NASM — chamada Windows x64 com shadow space:
sub  rsp, 32         ; aloca shadow space (RSP já estava alinhado antes)
mov  rcx, arg1       ; 1° parâmetro
mov  rdx, arg2       ; 2° parâmetro
call MinhaFuncao
add  rsp, 32         ; libera shadow space
```

---

## Passagem de parâmetros — Windows x64

### Regras

1. **Inteiros/ponteiros:** RCX, RDX, R8, R9 (em ordem)
2. **Floats:** XMM0, XMM1, XMM2, XMM3 (em ordem, nos mesmos slots)
3. **Se misto (int e float):** cada slot é OU registrador int OU XMM — não ambos
4. **5° parâmetro em diante:** stack, acima do shadow space (`[RSP+40]` antes do CALL)
5. **Structs grandes (> 8 bytes):** passados por ponteiro em RCX (e o "Self" de método passa a ser RDX)

```nasm
; Chamada de f(int a, double b, int c, double d, int e):
;   RCX = a (int)
;   XMM1 = b (double — slot 2 é XMM1, NÃO XMM0, porque RCX ocupou slot 1)
;   R8  = c (int)
;   XMM3 = d (double — slot 4 é XMM3)
;   [RSP+40] = e (5° param na stack, acima dos 32 bytes de shadow)
```

---

## Alinhamento da stack — Regra dos 16 bytes

```
Antes de CALL: RSP deve estar alinhado a 16 bytes.
Após CALL push do return address: RSP = 16n - 8.
Após PUSH RBP no prologue: RSP = 16n - 16 = múltiplo de 16.

Portanto: após PUSH RBP + MOV RBP,RSP, RSP já está alinhado.
SUB RSP, N deve usar N = múltiplo de 16.
```

```nasm
; Checagem mental de alinhamento:
push rbp             ; RSP -= 8  →  16n - 8 - 8 = 16n - 16  ✓ alinhado
mov  rbp, rsp
push r12             ; RSP -= 8  →  desalinhado!
push r13             ; RSP -= 8  →  realinhado
sub  rsp, 32         ; RSP -= 32 → ainda alinhado (32 é múltiplo de 16)
```

---

## Pseudo-ops do built-in assembler Delphi (64-bit)

O built-in assembler Delphi 64-bit suporta diretivas especiais que geram prologue/epilogue
automático com unwind information para exceções Windows:

```pascal
// .PARAMS N — declara N parâmetros (gera shadow space automaticamente)
// .PUSHNV reg — push de registrador não-volátil (gera unwind info)
// .SAVENV reg — salva XMM não-volátil (gera unwind info)
// .NOFRAME — indica função leaf sem frame (sem prologue/epilogue)

function FuncaoComParams(A, B: Int64): Int64;
asm
  .PARAMS 2           // 2 parâmetros: compilador gera shadow space
  // RCX = A, RDX = B
  MOV RAX, RCX
  ADD RAX, RDX
end;

function FuncaoComRegistradoresSalvos: Integer;
asm
  .PUSHNV RBX        // PUSH RBX + gera unwind info
  .PUSHNV R12        // PUSH R12 + gera unwind info
  // ... usa RBX e R12 livremente ...
  MOV EAX, 42
  // epilogue automático: POP R12, POP RBX, RET
end;

function FuncaoLeaf(X: Integer): Integer;
asm
  .NOFRAME           // sem prologue/epilogue — função leaf simples
  // RCX = X (Windows x64)
  MOV EAX, ECX
  INC EAX
end;
```

---

## Exemplo completo: função assembly chamada do Delphi com 2 parâmetros

### Win32 — 2 parâmetros via EAX, EDX

```pascal
unit ExemploASM32;

interface

// Multiplica A por B e retorna o resultado (Win32, convenção register)
function Multiplica32(A, B: Integer): Integer;

implementation

function Multiplica32(A, B: Integer): Integer;
// Entrada: EAX = A, EDX = B
// Saída:   EAX = resultado
asm
  IMUL EAX, EDX     // EAX = EAX * EDX (overflow silencioso se > 32-bit)
  // Retorno implícito em EAX
end;

end.
```

### Win64 — 2 parâmetros via RCX, RDX

```pascal
unit ExemploASM64;

interface

// Multiplica A por B e retorna o resultado (Win64, Windows x64 ABI)
function Multiplica64(A, B: Int64): Int64;

implementation

function Multiplica64(A, B: Int64): Int64;
// Entrada: RCX = A, RDX = B
// Saída:   RAX = resultado
asm
  MOV  RAX, RCX     // RAX = A
  IMUL RAX, RDX     // RAX = A * B (com sinal, resultado truncado para 64-bit)
  // Retorno implícito em RAX
end;

end.
```

### NASM — função chamada externamente (Windows x64)

```nasm
; arquivo: soma_externa.asm
; Compilar: nasm -f win64 soma_externa.asm -o soma_externa.obj
; Linkar com o executável Delphi via {$L soma_externa.obj}

bits 64
section .text

; int64 SomaExterna(int64 A, int64 B)
; RCX = A, RDX = B, retorno em RAX
global SomaExterna

SomaExterna:
    ; Prologue mínimo (função simples, sem locals)
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32         ; shadow space (obrigatório!)

    ; Lógica
    mov     rax, rcx        ; RAX = A
    add     rax, rdx        ; RAX = A + B

    ; Epilogue
    add     rsp, 32
    pop     rbp
    ret
```

```pascal
// Uso no Delphi:
unit UsaSomaExterna;

interface

function SomaExterna(A, B: Int64): Int64; cdecl; external;

{$L soma_externa.obj}

implementation

end.
```

---

## Diagnóstico de stack frame no CPU View

Para inspecionar o stack frame no debugger do Delphi (RAD Studio):

1. Abrir **View → Debug Windows → CPU View** (Ctrl+Alt+C)
2. Painel **Registers**: ver ESP/RSP, EBP/RBP em tempo real
3. Painel **Stack**: conteúdo da stack em palavras de 4/8 bytes
4. Colocar breakpoint dentro do bloco `asm`
5. Observar:
   - `[RBP+0]` = RBP salvo do caller
   - `[RBP+8]` = return address
   - `[RBP+16]` = shadow[0] (home RCX)
   - `[RBP-8]`, `[RBP-16]` = variáveis locais

---

## Estrutura de arquivos

```
developer-assembly-stack-call_V1.0.0/
├── SKILL.md
├── exemplos/
│   ├── asm/
│   │   ├── stack_frame_linux.asm
│   │   ├── stack_frame_windows.asm
│   │   ├── chamada_recursiva.asm
│   │   └── variaveis_locais.asm
│   └── pas/
│       ├── frame_32bit.pas
│       ├── frame_64bit.pas
│       ├── noframe_leaf.pas
│       ├── recursiva_asm.pas
│       └── call_pascal_from_asm.pas
├── consultas_rapidas/
│   ├── frame_anatomia_32.md
│   ├── frame_anatomia_64.md
│   ├── call_ret_delphi.md
│   ├── pseudo_ops_x64.md
│   └── call_ret_mecanismo.md
└── templates/
    ├── TEMPLATE_funcao_asm_32.pas
    ├── TEMPLATE_funcao_asm_64.pas
    ├── TEMPLATE_funcao_noframe.pas
    └── TEMPLATE_funcao_nasm.asm
```

## Skills relacionadas

- `developer-assembly-x86-fundamentals_V1.0.0` — arquitetura base
- `developer-assembly-registers_V1.0.0` — registradores e preservação
- `developer-assembly-instructions_V1.0.0` — conjunto de instruções
