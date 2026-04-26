---
name: developer-delphi-assembly-functions
description: Funcoes e procedures puramente assembly em Delphi — keyword `assembler`, pseudo-ops x64 (.PARAMS, .PUSHNV, .SAVENV, .NOFRAME), linkagem de .obj NASM, exportacao de simbolos e retorno de tipos Delphi.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-functions_V1.0.0

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill documenta funcoes e procedures que sao INTEIRAMENTE escritas em assembly no Delphi — usando a keyword `assembler` (sem `begin/end` Pascal) ou linkando arquivos `.obj` gerados por NASM externo. Cobre pseudo-ops x64 do compilador Delphi (`.PARAMS`, `.PUSHNV`, `.SAVENV`, `.NOFRAME`), como exportar simbolos para uso em Delphi e como passar/retornar os principais tipos Delphi. NAO cobre blocos `asm..end` dentro de funcoes Pascal — esses pertencem a `developer-delphi-assembly-inline`.

## When to use

- Implementar funcoes criticas de performance inteiramente em assembly.
- Linkar bibliotecas `.obj` NASM ao projeto Delphi.
- Criar wrappers Delphi para funcoes assembly de terceiros.
- Exportar funcoes assembly via DLL com ABI definida.
- Usar pseudo-ops x64 para gerar prologo/epilogo correto automaticamente.

## When NOT to use

- Bloco asm dentro de funcao Pascal existente ’ `developer-delphi-assembly-inline`.
- Otimizacoes SIMD/AVX ’ ver tambem `developer-delphi-assembly-simd-avx`.
- Convencoes de chamada e registradores ’ `developer-delphi-assembly-calling-conventions`.

## Declaracao de funcao assembly pura

```pascal
// Sem begin/end Pascal — apenas asm..end
function SomarPuro(A, B: Integer): Integer; assembler;
asm
  // Win32: A=EAX, B=EDX; retorno=EAX
  ADD EAX, EDX
end;

// COM prologo/epilogo completo (Win64 com pseudo-ops):
function Calcular(A, B: Integer): Integer; assembler;
asm
  .PARAMS 2        // habilita frame + shadow space 32B no Win64
  .PUSHNV R12      // salva R12 automaticamente no prologo
  // A=ECX (Win64), B=EDX
  LEA EAX, [ECX + EDX]
  // R12 restaurado automaticamente no epilogo
end;
```

## Pseudo-ops x64 do Delphi

| Pseudo-op          | Funcao                                                           |
| ------------------ | ---------------------------------------------------------------- |
| `.PARAMS N`        | Declara N parametros — habilita frame de pilha + shadow space 32B |
| `.PUSHNV reg`      | PUSH registrador int. non-volatile + restaura automaticamente    |
| `.SAVENV XMMreg`   | Salva registrador XMM non-volatile na area home                  |
| `.NOFRAME`         | Sem prologo/epilogo (funcao leaf que nao chama outras funcoes)   |

## Quando usar .NOFRAME

- Funcao nao chama outras funcoes (leaf function).
- Nao usa variaveis locais.
- Nao precisa salvar registradores non-volatile.
- Maxima performance — sem overhead de PUSH EBP / MOV EBP,ESP.

```pascal
function AbsoluteNoFrame(N: Integer): Integer; assembler; nostackframe;
asm
  // Win32: N=EAX
  TEST EAX, EAX
  JNS  @fim
  NEG  EAX
@fim:
end;
```

## Linkagem de arquivos .obj NASM

```pascal
// Passo 1: montar com NASM
// nasm -f win32 minha_rotina.asm -o minha_rotina.obj

// Passo 2: declarar em Pascal e linkar
{$L minha_rotina.obj}   // incluir o .obj no projeto

// Passo 3: declarar a funcao externa
function SomarNasm(A, B: Integer): Integer; external;
// (sem 'external DLLName' = linkagem estatica do .obj)
```

## Exportar funcao assembly para DLL

```nasm
; NASM: minha_dll.asm
; Exportar para uso em Delphi
section .text
global _MinhaFuncao@8    ; stdcall decorated name

_MinhaFuncao@8:
    ; implementacao
    RET 8
```

```pascal
// Declaracao no Delphi consumidor:
function MinhaFuncao(A, B: Integer): Integer; stdcall; external 'minha_dll.dll';
```

## Retorno de valores

| Tipo          | Win32 (dcc32)      | Win64 (dcc64)      |
| ------------- | ------------------ | ------------------ |
| Integer/Bool  | EAX                | EAX (parte de RAX) |
| Int64         | EDX:EAX            | RAX                |
| Pointer/PChar | EAX                | RAX                |
| Single        | ST(0) [x87]        | XMM0 (baixo 32-bit)|
| Double        | ST(0) [x87]        | XMM0 (64-bit)      |
| Record <=8B   | EDX:EAX            | RAX                |
| Record >8B    | Ponteiro oculto    | Ponteiro oculto    |

## Inputs

- Assinatura da funcao Pascal (nome, parametros, retorno).
- Plataforma (Win32/Win64).
- Fonte da implementacao (inline Delphi ou arquivo .obj externo).

## Workflow executavel

1. Determinar se funcao sera inline Delphi (`assembler`) ou .obj externo (NASM).
2. Mapear todos os parametros para registradores conforme ABI.
3. Implementar com pseudo-ops corretos (.PARAMS, .PUSHNV etc.) para x64.
4. Declarar `{$L arquivo.obj}` e `external` se .obj externo.
5. Testar em Win32 E Win64 (compilar com dcc32 e dcc64).
6. Verificar stack balance e registradores preservados via CPU View.

## Anti-padroes

| Anti-padrao                              | Por que e errado                                   | Como corrigir                                 |
| ---------------------------------------- | -------------------------------------------------- | --------------------------------------------- |
| Usar .NOFRAME e chamar outra funcao      | RSP pode nao estar alinhado, sem shadow space      | Usar .PARAMS para funcoes que fazem CALL       |
| Omitir .PARAMS em funcao nao-leaf x64   | Violacao de ABI — crash na funcao chamada          | Adicionar .PARAMS N                            |
| Retornar Double em EAX em Win64         | Win64 usa XMM0 para float, nao EAX                | MOVSD XMM0 com o valor antes de RET           |
| Nao usar {$L} para .obj NASM            | Linker nao encontra o simbolo — erro E1026         | Adicionar {$L nome.obj} antes da declaracao   |

## Dependencias (skills previas)

| Skill                                           | Quando usar antes                                    |
| ----------------------------------------------- | ---------------------------------------------------- |
| `developer-delphi-assembly-calling-conventions` | Para regras de registradores e convencoes            |

## Referencias

- Consulta rapida: `consultas_rapidas/pseudo_ops_completo.md`
- Consulta rapida: `consultas_rapidas/declaracao_assembler.md`
- Exemplos NASM: `exemplos/asm/strlen_nasm.asm`, `funcao_retorna_int.asm`
- Exemplos Pascal: `exemplos/pas/func_pura_32.pas`, `func_pura_64.pas`
- Templates: `templates/TEMPLATE_func_assembler.pas`, `TEMPLATE_func_x64.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — keyword assembler, pseudo-ops x64, linkagem .obj NASM, retorno de tipos e anti-padroes.
