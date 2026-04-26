---
name: developer-delphi-assembly-calling-conventions
description: Convenções de chamada em Assembly para Delphi — register, stdcall, cdecl, safecall, pascal, winapi e Windows x64 ABI. Tabelas de registradores caller/callee-saved, passagem de parametros e retorno de valores.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-calling-conventions

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |

## Responsabilidade unica

Esta skill documenta e exemplifica as convencoes de chamada (calling conventions) usadas em Delphi/Free Pascal para codigo assembly: como parametros sao passados (registradores vs. pilha), quem limpa a pilha (callee vs. caller), quais registradores devem ser preservados, e como o Windows x64 ABI difere do modelo Win32 classico. Ela NAO cobre instrucoes SIMD — essas pertencem a `developer-delphi-assembly-simd-avx`.

## When to use

- Escrever ou integrar rotinas assembly externas chamadas de Pascal.
- Depurar corrupcao de pilha ou registradores em codigo misto Pascal+ASM.
- Exportar funcoes assembly via DLL com ABI correta.
- Entender por que uma funcao assembly falha somente em Win64.
- Chamar funcoes variadic (printf-style) de dentro do asm.

## When NOT to use

- Instrucoes SIMD/SSE/AVX ’ `developer-delphi-assembly-simd-avx`.
- Blocos `asm..end` dentro de funcoes Pascal ’ `developer-delphi-assembly-inline`.
- Funcoes puras assembly (keyword `assembler`) ’ `developer-delphi-assembly-functions`.
- Expressoes em tempo de compilacao (OFFSET, VMTOFFSET) ’ `developer-delphi-assembly-expressions`.

## Inputs

- Assinatura da funcao Pascal (parametros e tipo de retorno).
- Plataforma alvo: Win32 (dcc32) ou Win64 (dcc64).
- Convencao escolhida: register / stdcall / cdecl / safecall.

## Tabela comparativa de convencoes

| Convencao  | Passagem de args              | Quem limpa pilha | Retorno       | Uso principal          |
| ---------- | ----------------------------- | ---------------- | ------------- | ---------------------- |
| `register` | EAX, EDX, ECX (3 primeiros)   | callee           | EAX / ST(0)  | Padrao Delphi Win32    |
| `stdcall`  | Pilha direita-esq             | callee (RET N)   | EAX           | WinAPI Win32           |
| `cdecl`    | Pilha direita-esq             | caller           | EAX           | DLLs C/C++             |
| `safecall` | Idem stdcall                  | callee           | HResult       | COM/automation         |
| `pascal`   | Pilha esquerda-direita        | callee           | EAX           | Legado (Delphi 1-3)    |
| `winapi`   | stdcall no Win, cdecl no POSIX| conforme OS      | —             | Portabilidade          |
| Win64 ABI  | RCX, RDX, R8, R9 + shadow 32B | caller           | RAX / XMM0   | dcc64 / x64            |

## Registradores preservados obrigatorios

### Win32 — callee DEVE preservar:
- `EBX`, `EBP`, `ESI`, `EDI`, `ESP`
- Nunca modificar sem salvar/restaurar via PUSH/POP ou equivalente

### Win64 — callee DEVE preservar (non-volatile):
- `RBX`, `RBP`, `RDI`, `RSI`, `R12`, `R13`, `R14`, `R15`, `RSP`
- `XMM4` a `XMM15` (128-bit inteiros)
- Volatile (caller-saved, pode destruir): `RAX`, `RCX`, `RDX`, `R8`, `R9`, `R10`, `R11`, `XMM0`—`XMM3`

## Windows x64 ABI — detalhe

```
Parametros inteiros/ponteiros: RCX, RDX, R8, R9  (5o em diante: pilha)
Parametros float/double:       XMM0, XMM1, XMM2, XMM3
Shadow space:                  32 bytes reservados pelo CALLER antes da chamada
                               (mesmo que a funcao nao use — obrigatorio!)
Retorno inteiro:               RAX
Retorno float:                 XMM0
Stack alignment:               RSP deve estar alinhado em 16 bytes no CALL
```

## Convencao `register` Delphi Win32 — metodo de objeto

Quando a funcao e um metodo (procedure/function de classe):
- `Self` ’ `EAX`
- 1o parametro ’ `EDX`
- 2o parametro ’ `ECX`
- 3o em diante ’ pilha (direita para esquerda)

## Workflow executavel

1. Identificar plataforma (Win32 vs. Win64) e convencao necessaria.
2. Mapear parametros para registradores ou posicoes de pilha.
3. Identificar quais registradores serao modificados e PUSH/POP os non-volatile.
4. Implementar logica.
5. Restaurar registradores salvos.
6. Retornar valor no registrador correto (EAX/RAX/XMM0).
7. Usar RET N (stdcall) ou RET simples (cdecl) conforme convencao.

## Dependencias (skills previas)

| Skill                                            | Quando usar antes                                   |
| ------------------------------------------------ | --------------------------------------------------- |
| `developer-delphi-assembly-inline`        | Para blocos asm dentro de funcoes Pascal            |
| `developer-delphi-assembly-functions`     | Para funcoes `assembler;` puras                     |

## Anti-padroes

| Anti-padrao                              | Por que e errado                                      | Como corrigir                                      |
| ---------------------------------------- | ----------------------------------------------------- | -------------------------------------------------- |
| Nao salvar EBX/ESI/EDI em Win32          | Corrompe estado do caller — bugs silenciosos          | PUSH antes de usar; POP antes de RET               |
| Ignorar shadow space em Win64            | Funcoes chamadas podem corromper a pilha              | SUB RSP, 32 antes de CALL; ADD RSP, 32 apos        |
| Usar convencao errada em DLL export      | Crash ou dados incorretos no caller C/C++             | Verificar convencao esperada pelo consumer         |
| Retornar float em EAX em Win64           | Win64 ABI retorna float em XMM0, nao em EAX          | Usar MOVSS/MOVSD XMM0 para retorno float           |
| Misturar cdecl caller-cleanup e stdcall  | Stack imbalance — crash imprevisivel                  | Verificar cada declaracao `external` vs. real ABI  |

## Metricas de sucesso

- Funcao assembly compilada e executada sem AV (Access Violation).
- Pilha balanceada: RSP/ESP igual antes e depois da chamada.
- Registradores non-volatile preservados — verificavel via CPU View.
- Testes de integracao passam em dcc32 e dcc64.

## Referencias

- Consulta rapida: `consultas_rapidas/convencoes_comparativo.md`
- Consulta rapida: `consultas_rapidas/callee_saved_tabela.md`
- Exemplos ASM: `exemplos/asm/stdcall_32bit.asm`, `windows_x64_shadow.asm`
- Exemplos Pascal: `exemplos/pas/conv_register.pas`, `x64_shadow_space.pas`
- Templates: `templates/TEMPLATE_conv_register.pas`, `TEMPLATE_conv_stdcall.pas`
- Skill orquestradora: `developer-delphi-assembly-orchestrator_V1.1.0`

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criacao inicial — tabela de convencoes, registradores preservados Win32/Win64, Windows x64 ABI, exemplos e anti-padroes.
