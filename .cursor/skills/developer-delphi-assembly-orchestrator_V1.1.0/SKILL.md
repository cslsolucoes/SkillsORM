---
name: developer-delphi-assembly-orchestrator
description: Orquestradora da Familia Assembly Delphi (J1-J10) — mapa de 10 micro-skills, quando usar asm inline vs. externo, checklist de seguranca, fluxo de aprendizado e criterios para justificar uso de assembly.
model: sonnet
thinking: extended
category: developer-delphi-assembly
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-assembly-orchestrator

## Versao interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.1.0 |

## Responsabilidade unica

Esta skill e o ponto de entrada da Familia Assembly Delphi. Ela mapeia as 10 micro-skills da familia, orienta sobre quando usar assembly (vs. Pascal puro ou intrinsics), apresenta o checklist de seguranca antes de introduzir asm em producao e define a trilha de aprendizado recomendada. NAO implementa codigo — delega as skills especializadas.

## When to use

- Primeira vez usando assembly em um projeto Delphi — ler este mapa antes de qualquer outra skill.
- Decidir qual micro-skill chamar para a tarefa especifica.
- Avaliar se assembly e justificado para um problema de performance.
- Revisar codigo asm existente quanto a seguranca e corretude.

## When NOT to use

- Qualquer tarefa tecnica especifica (convencoes, inline, SIMD etc.) ’ usar a skill especializada diretamente.
- Debugging Pascal geral ’ `developer-delphi-debugging-techniques`.

## Mapa das 10 micro-skills da Familia Assembly Delphi

| # | Skill                                             | Responsabilidade                                   |
| - | ------------------------------------------------- | -------------------------------------------------- |
| J1| `developer-delphi-assembly-calling-conventions`   | Convencoes de chamada: register, stdcall, cdecl, Win64 ABI |
| J2| `developer-delphi-assembly-inline`         | Blocos `asm..end` dentro de funcoes Pascal         |
| J3| `developer-delphi-assembly-functions`      | Funcoes puras `assembler`, pseudo-ops x64, .obj NASM |
| J4| `developer-delphi-assembly-simd-avx`              | SSE/AVX2/AVX-512, XMM/YMM/ZMM, masking            |
| J5| `developer-delphi-assembly-expressions`           | OFFSET, TYPE, SIZE, VMTOFFSET, DMTINDEX, LEA       |
| J6| `developer-delphi-assembly-debugging`             | CPU View, INT 3, RDTSC, x64dbg, erros frequentes  |
| *(futuro)* | x86-fundamentals                         | Arquitetura x86/x64: registradores, flags, pilha  |
| *(futuro)* | assembly-registers                        | Uso detalhado de registradores Delphi             |
| *(futuro)* | assembly-instructions                     | Conjunto de instrucoes x86/x64 por categoria      |
| *(futuro)* | assembly-stack-call                       | Pilha, frames, CALL/RET, shadow space             |

## Trilha de aprendizado recomendada

```
FUNDAMENTOS (aprender primeiro):
  1. calling-conventions (J1) → base para tudo
  2. delphi-inline (J2)       → primeiro contato com asm no Delphi

INTERMEDIARIO:
  3. delphi-functions (J3)    → funcoes puras, pseudo-ops x64
  4. expressions (J5)         → OFFSET, VMTOFFSET, LEA
  5. debugging (J6)           → ferramentas de debug

AVANCADO:
  6. simd-avx (J4)            → SSE/AVX — performance critica
```

## Quando usar asm inline vs. funcao assembly externa

| Criterio                             | Asm Inline (asm..end)     | Funcao Externa (assembler / .obj) |
| ------------------------------------ | ------------------------- | ---------------------------------- |
| Tamanho do bloco asm                 | Pequeno (< 20 instrucoes) | Qualquer tamanho                   |
| Reutilizacao entre modulos           | Nao (apenas na unit)      | Sim (via .obj ou DLL)              |
| Acesso a variaveis Pascal locais     | Sim (Delphi resolve)      | Via parametros apenas              |
| Pseudo-ops x64 (`.PARAMS`, etc.)     | Limitado                  | Completo                           |
| Testabilidade isolada                | Dificil                   | Facil (funcao individual)          |
| Portabilidade para outro compilador  | Media                     | Alta (NASM independente)           |

**Regra geral:** Para blocos curtos de otimizacao dentro de funcoes existentes ’ `asm..end`. Para algoritmos SIMD/criticos completos ’ funcao `assembler` ou .obj NASM.

## Checklist de seguranca — quando asm vale o risco

Antes de introduzir assembly em codigo de producao, validar cada item:

- [ ] Profiling comprova bottleneck: Pascal puro nao e suficiente (benchmark com RDTSC)
- [ ] Restricoes de plataforma documentadas: Win32/Win64 apenas (nao iOS/Android)
- [ ] CPUID verificado para instrucoes SSE/AVX: nao assume suporte
- [ ] Registradores non-volatile preservados: EBX/ESI/EDI (Win32), R12-R15/XMM6-15 (Win64)
- [ ] Stack balanceado: ESP/RSP igual antes e depois (testado via CPU View)
- [ ] Testes de regressao cobrindo todos os paths da rotina asm
- [ ] Compilacao verificada em dcc32 E dcc64 (sem warnings asm)
- [ ] Labels com `@` para evitar conflito com identificadores Pascal
- [ ] INT 3 e codigo de debug protegidos com `{$IFDEF DEBUG}`
- [ ] Revisao por segundo desenvolvedor (codigo asm e dificil de revisar)
- [ ] Documentacao inline explicando invariantes, convencao usada e registradores modificados
- [ ] VZEROUPPER chamado apos qualquer instrucao AVX (antes de SSE/FPU)
- [ ] MOVUPS (nao MOVAPS) para dados sem garantia de alinhamento

## Criterios para justificar uso de assembly

### Justificado:
- Rotina no hot path (medida com profiler) que passa > 10% do tempo total
- Instrucao de CPU sem intrinsic Pascal equivalente (CPUID, RDTSC, POPCNT)
- Vetorizacao SIMD para processamento de arrays grandes (>1000 elementos por chamada)
- Operacoes atomicas de baixissima latencia
- Codigo de startup ou inicializacao de sistema critico

### NAO justificado:
- "Acho que vai ser mais rapido" (sem medida real)
- Codigo que roda raramente (inicializacao, configuracao)
- Logica de negocio que poderia mudar — asm e muito dificil de manter
- Casos onde o compilador ja vetoriza automaticamente ({$O+})

## Inputs

- Descricao do problema de performance ou necessidade de instrucao especifica.
- Plataforma alvo e resultado de profiling.

## Workflow executavel

1. Ler o mapa de skills e identificar qual(is) cobrem o problema.
2. Verificar o checklist de seguranca — todos os itens devem ser satisfeitos.
3. Executar a skill especializada relevante.
4. Compilar em Win32 E Win64 (dcc32 e dcc64).
5. Executar testes de regressao.
6. Medir ciclos antes/depois com RDTSC para confirmar ganho.

## Dependencias (skills previas)

| Skill                                              | Quando usar antes                              |
| -------------------------------------------------- | ---------------------------------------------- |
| `developer-delphi-assembly-calling-conventions`    | Sempre — base para qualquer trabalho asm       |
| `developer-delphi-assembly-debugging`              | Antes de depurar codigo asm existente          |

## Anti-padroes

| Anti-padrao                                  | Por que e errado                                      | Como corrigir                           |
| -------------------------------------------- | ----------------------------------------------------- | --------------------------------------- |
| Pular `calling-conventions` e ir direto a SIMD| Sem entender convencoes, qualquer codigo asm falha   | Estudar J1 antes de J4                  |
| Escrever asm sem benchmark previo            | Otimizacao prematura — gasta tempo sem ganho real     | Medir primeiro, otimizar o que dói      |
| Assembly sem testes de regressao             | Bugs silenciosos em condicoes de borda                | Escrever testes para todos os paths     |
| Misturar `inline` + `asm` na mesma funcao   | Erro E2426 de compilacao                              | Remover `inline;` — incompativel        |
| Codigo asm sem comentario de convencao usada | Impossivel de manter por outra pessoa                 | Documentar: convencao, registradores, retorno |

## Metricas de sucesso

- Rotina asm compila sem warnings em dcc32 E dcc64.
- Stack balanceado verificado via CPU View.
- Benchmark demonstra ganho mensuravel vs. Pascal puro (RDTSC).
- Testes de regressao passam com arrays de Count = 0, 1, 3, 4, 8, 16, 17.
- Todos os items do checklist de seguranca verificados.

## Referencia cruzada: NASM vs Delphi built-in assembler

| Aspecto                  | NASM (Intel syntax)         | Delphi built-in assembler      |
| ------------------------ | --------------------------- | ------------------------------ |
| Labels locais            | `.label` (com ponto)        | `@label` (com arroba)          |
| Comentarios              | `;`                         | `//` e `{ }` (nao `(* *)`)    |
| Masking AVX-512          | `{k1}{z}`                   | `<k1><z>` (angle brackets!)   |
| Convencao registro       | Nao automatica              | Resolvida pelo compilador      |
| Tamanho de tipo          | `DWORD`, `QWORD` literals   | `TYPE`, `SIZE` expressions     |
| Endereco de global       | `[GVar]` ou `GVar`          | `OFFSET GVar` ou nome direto   |
| Pseudo-ops x64           | Nao (manualmente)           | `.PARAMS`, `.PUSHNV`, `.SAVENV`|

## Referencias

- Consulta rapida: `consultas_rapidas/mapa_skills.md`
- Consulta rapida: `consultas_rapidas/quando_usar_asm.md`
- Consulta rapida: `consultas_rapidas/nasm_vs_delphi_asm.md`
- Skill de compilacao: `developer-delphi-build-toolchain` ’ `compile.md`
- Skill de diretivas: `developer-delphi-programming-conditional-defines` ’ `diretivas_compilacao.md`

---

## Changelog (este arquivo)

- 1.1.0 (11/04/2026): Criacao da V1.1.0 — mapa de 10 skills (J1-J6 criadas + J7-J10 futuras), checklist de seguranca expandido, criterios para justificar asm, trilha de aprendizado e tabela NASM vs Delphi.
- 1.0.0: Nao existia — versao anterior era apenas referencia em subplanos.
