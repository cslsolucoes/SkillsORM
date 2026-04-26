# Pseudo-ops do Built-in Assembler Delphi 64-bit

## Visão geral

As pseudo-ops são diretivas especiais do built-in assembler Delphi 64-bit que:
1. Geram o código de prologue/epilogue correto
2. Incluem **unwind information** (tabela `.pdata`) necessária para SEH/exceções
3. Permitem que o debugger e o runtime percorram frames corretamente

**Sem unwind info:** exceções não podem fazer unwind através do frame → crash ou comportamento indefinido.

## .PARAMS N

Declara que a função tem N parâmetros passados por registrador.
Gera shadow space de 32 bytes no prologue (obrigatório no Windows x64).

```pascal
function MinhaFuncao(A, B, C: Int64): Int64;
asm
  .PARAMS 3       // 3 parâmetros: RCX=A, RDX=B, R8=C
  // shadow space de 32 bytes alocado automaticamente
  MOV RAX, RCX
  ADD RAX, RDX
  ADD RAX, R8
end;
```

**Quando omitir `.PARAMS`:** funções leaf (`.NOFRAME`) sem chamadas internas.
**Não omitir em outros casos:** sem shadow space, CALLs internas terão comportamento indefinido.

## .PUSHNV Reg

Salva registrador não-volátil (callee-saved) e gera unwind information.
Equivale a `PUSH Reg` mas com rastreamento para SEH.

```pascal
function UsaMultiploRegistradores(N: Int64): Int64;
asm
  .PARAMS 1       // shadow space
  .PUSHNV RBX     // PUSH RBX + unwind info
  .PUSHNV RSI     // PUSH RSI + unwind info
  .PUSHNV RDI     // PUSH RDI + unwind info
  // Agora pode usar RBX, RSI, RDI livremente

  MOV RBX, RCX   // RBX = N
  XOR RSI, RSI   // RSI = acumulador
  MOV RDI, 1     // RDI = i

@loop:
  CMP RDI, RBX
  JG  @fim
  ADD RSI, RDI
  INC RDI
  JMP @loop

@fim:
  MOV RAX, RSI

  // Epilogue automático: POP RDI, POP RSI, POP RBX, ADD RSP,32, RET
end;
```

**Registradores válidos para .PUSHNV:** RBX, RSI, RDI, RBP, R12, R13, R14, R15

## .SAVENV XMMn

Salva registrador XMM não-volátil na stack + gera unwind information.
Necessário antes de usar XMM4-XMM15 (callee-saved em Windows x64).

```pascal
function ProcessarSSE(Ptr: Pointer; N: Integer): Double;
asm
  .PARAMS 2
  .PUSHNV RBX
  .SAVENV XMM6    // salva XMM6 + unwind info (necessário se XMM4-XMM15 usados)
  .SAVENV XMM7

  // XMM6 e XMM7 agora podem ser usados livremente
  XORPD XMM6, XMM6     ; acumulador = 0.0
  // ...

  MOVAPD XMM0, XMM6    ; retorno em XMM0
  // Epilogue automático: restaura XMM7, XMM6, RBX
end;
```

## .NOFRAME

Indica função leaf sem prologue/epilogue. A função NÃO pode:
- Chamar outras funções (sem shadow space)
- Usar stack para variáveis locais
- Ser interrompida por exceções que fazem unwind

```pascal
function IncrementarLeaf(X: Integer): Integer;
asm
  .NOFRAME        // sem PUSH RBP / MOV RBP,RSP / SUB RSP,...
  // RCX = X (Windows x64)
  MOV EAX, ECX
  INC EAX
  // RET gerado automaticamente
end;
```

## Tabela de uso

| Situação | Pseudo-ops necessárias |
|----------|----------------------|
| Função simples com 1-4 params, sem locals | `.PARAMS N` |
| Função que usa RBX, RSI, RDI | `.PARAMS N` + `.PUSHNV RBX` etc. |
| Função que usa XMM4-XMM15 | `.PARAMS N` + `.SAVENV XMM4` etc. |
| Função leaf (não chama ninguém) | `.NOFRAME` |
| Função sem params, sem locals, leaf | `.NOFRAME` |

## Equivalência manual (para comparação didática)

```pascal
// Com .PUSHNV (correto para produção):
function F1: Int64;
asm
  .PARAMS 0
  .PUSHNV RBX
  mov rbx, 42
  mov rax, rbx
end;

// Equivalente manual (sem unwind info — não usar com exceções!):
function F2: Int64;
asm
  sub rsp, 32     // shadow space manual
  push rbx        // salvar RBX (sem unwind info)
  mov  rbx, 42
  mov  rax, rbx
  pop  rbx        // restaurar
  add  rsp, 32
end;
```
