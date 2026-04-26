---
name: developer-delphi-assembly-expressions
description: Expressões assembly Delphi em tempo de compilacao — OFFSET, TYPE, SIZE, VMTOFFSET, DMTINDEX, PTR, LEA com enderecamento indexado, otimizacoes com LEA (multiplicacao sem MUL), macros NASM (%macro, %rep) e operadores aritmeticos em expressões asm.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-expressions

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill cobre as **expressoes calculadas em tempo de compilacao** disponíveis no assembler Delphi — OFFSET (endereco de simbolo), TYPE (tamanho de tipo), SIZE (tamanho total de variavel), VMTOFFSET (offset de metodo virtual na VMT) e DMTINDEX (indice na DMT para metodos dynamic). Tambem cobre endereçamento indexado (`LEA rax, [rbx + rcx*4 + 8]`), otimizacoes com LEA para multiplicacao sem MUL e, para NASM externo, macros com `%macro` e `%rep`. NAO cobre modificadores PTR/OFFSET de acesso (ver `developer-delphi-assembly-inline`) nem instrucoes SIMD.

## When to use

- Calcular offsets de campos de struct/record em tempo de compilacao.
- Chamar metodo virtual diretamente pelo offset VMT sem overhead de lookup.
- Usar LEA para multiplicacoes rapidas por 2, 3, 4, 5, 8, 9 sem MUL.
- Determinar tamanho de tipos e arrays em expressoes asm.
- Escrever macros NASM reutilizaveis (%macro, %rep).

## When NOT to use

- Modificadores de tamanho de acesso (BYTE PTR, DWORD PTR) ’ `developer-delphi-assembly-inline`.
- Instrucoes SIMD ’ `developer-delphi-assembly-simd-avx`.
- Convencoes de chamada ’ `developer-delphi-assembly-calling-conventions`.

## Expressoes Delphi calculadas em tempo de compilacao

### OFFSET — endereco de variavel global:
```pascal
var GVar: Integer;
asm
  MOV EAX, OFFSET GVar    // EAX = endereco estatico de GVar
  LEA EAX, GVar           // alternativa equivalente
end;
```

### TYPE — tamanho em bytes de um tipo:
```pascal
asm
  MOV EAX, TYPE Integer     // EAX = 4
  MOV EAX, TYPE Double      // EAX = 8
  MOV EAX, TYPE Char        // EAX = 2 (WideChar no Delphi moderno)
  MOV EAX, TYPE TMyRecord   // EAX = SizeOf(TMyRecord)
end;
```

### SIZE — tamanho total de uma variavel (array incluso):
```pascal
var Arr: array[0..9] of Integer;  // 10 elementos = 40 bytes
asm
  MOV EAX, SIZE Arr   // EAX = 40 (tamanho TOTAL = 10 * 4)
  MOV EAX, TYPE Arr   // EAX = 4  (tamanho de 1 ELEMENTO)
end;
```

### VMTOFFSET — offset de metodo virtual na VMT:
```pascal
// Chamar metodo virtual sem overhead de dispatch por nome
// Util em hot paths onde o tipo concreto e sempre o mesmo
asm
  MOV EAX, [EBX]        // EBX = objeto; [EBX] = ponteiro para VMT
  CALL DWORD PTR [EAX + VMTOFFSET TMinhaClasse.MeuMetodo]
end;
```

### DMTINDEX — indice para metodo `dynamic`:
```pascal
// Metodos `dynamic` usam DMT separada da VMT (indices negativos)
asm
  MOV EAX, DMTINDEX TMinhaClasse.MeuMetodoDynamic
  // Valor negativo — para dispatch via System.@DynamicDispatch
end;
```

## Enderecamento indexado e LEA

### Formas de LEA:
```nasm
LEA RAX, [RBX + RCX*4 + 8]     ; RAX = RBX + RCX*4 + 8
LEA RAX, [RBX + RCX*8]          ; RAX = RBX + RCX*8
LEA RAX, [RBX + displacement]   ; RAX = RBX + constante
```

### Multiplicacao sem MUL usando LEA:
```nasm
; Multiplicar por 3:
LEA EAX, [EAX + EAX*2]    ; EAX = EAX + EAX*2 = 3*EAX

; Multiplicar por 5:
LEA EAX, [EAX + EAX*4]    ; EAX = EAX + EAX*4 = 5*EAX

; Multiplicar por 9:
LEA EAX, [EAX + EAX*8]    ; EAX = EAX + EAX*8 = 9*EAX

; Multiplicar por 12 (nao direto — dois LEA):
LEA EAX, [EAX + EAX*2]    ; EAX = 3*EAX
SHL EAX, 2                 ; EAX = 4 * 3*EAX = 12*EAX
```

## Operadores em expressoes asm Delphi

| Operador  | Tipo       | Exemplo                              |
| --------- | ---------- | ------------------------------------ |
| `+`, `-`  | Aritmetica | `MOV EAX, OFFSET X + 4`             |
| `*`       | Aritmetica | `MOV EAX, TYPE Integer * 4`         |
| `SHR`, `SHL` | Deslocamento | `MOV ECX, SIZE Arr SHR 2`       |
| `AND`, `OR`, `XOR`, `NOT` | Logica | `MOV EAX, EAX AND $FF` |
| `MOD`     | Modulo     | `MOV EAX, 13 MOD 4`                 |

## Macros NASM (%macro, %rep)

```nasm
; Macro simples: PUSH + MOV multiplos registradores
%macro SAVE_REGS 0
    push    rbx
    push    rsi
    push    rdi
%endmacro

%macro RESTORE_REGS 0
    pop     rdi
    pop     rsi
    pop     rbx
%endmacro

; Macro com parametros:
%macro LOOPN 2              ; %1=contador, %2=label
    mov     ecx, %1
%%loop:
    ; corpo do loop aqui
    dec     ecx
    jnz     %%loop
%endmacro

; %rep — repetir bloco N vezes (loop no tempo de montagem):
%rep 4
    nop
%endrep
```

## Inputs

- Tipo ou variavel cujo tamanho/endereco se quer calcular.
- Classe com metodo virtual para VMTOFFSET.
- Expressao de multiplicacao para otimizar com LEA.

## Workflow executavel

1. Identificar a expressao necessaria (OFFSET/TYPE/SIZE/VMTOFFSET).
2. Verificar se e variavel global (OFFSET) ou local (nome direto).
3. Para VMT: garantir que o metodo e `virtual` (nao `dynamic`).
4. Para LEA: verificar se o multiplicador permite combinacao direta.
5. Compilar e verificar no CPU View que o valor calculado esta correto.

## Anti-padroes

| Anti-padrao                      | Por que e errado                                      | Como corrigir                              |
| -------------------------------- | ----------------------------------------------------- | ------------------------------------------ |
| `OFFSET` em variavel local       | OFFSET funciona apenas em globais                     | Usar nome diretamente (Delphi resolve)     |
| `VMTOFFSET` em metodo `dynamic`  | Metodos dynamic usam DMT, nao VMT — indice errado     | Usar `DMTINDEX` para metodos dynamic       |
| LEA para multiplicar por valor nao-suportado | Scale so aceita 1, 2, 4, 8                | Combinar dois LEA ou usar IMUL             |
| `SIZE` confundido com `TYPE`     | SIZE = total array; TYPE = tamanho 1 elemento         | Verificar qual dimensao e necessaria       |

## Referencias

- Consulta rapida: `consultas_rapidas/expressoes_asm.md`
- Consulta rapida: `consultas_rapidas/vmtoffset_como_funciona.md`
- Exemplos: `exemplos/pas/offset_global.pas`, `vmtoffset_virtual.pas`
- Templates: `templates/TEMPLATE_acesso_campo.pas`, `TEMPLATE_chamada_virtual.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — OFFSET/TYPE/SIZE/VMTOFFSET/DMTINDEX, LEA indexado, otimizacoes LEA, macros NASM e anti-padroes.
