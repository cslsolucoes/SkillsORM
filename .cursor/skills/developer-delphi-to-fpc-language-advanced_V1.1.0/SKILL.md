---
name: developer-delphi-to-fpc-language-advanced
description: Recursos avançados da linguagem Delphi — closures, operator overloading, inline functions, anonymous methods.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-advanced_V1.1.0

## Propósito

Dominar recursos avançados da linguagem Delphi: anonymous methods (closures), TProc/TFunc como tipos de primeira classe, captura de variáveis, operator overloading em records/classes, funções inline e padrões de exit/guard clause.

## Quando usar esta skill

- Passar comportamento como parâmetro (callbacks, handlers, predicados)
- Capturar variáveis locais em closures
- Sobrecarregar operadores em records e classes
- Otimizar funções pequenas com `inline`
- Usar exit antecipado com valor para guard clauses

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `anon_methods.pas` | `procedure of object` vs anonymous method: captura, ciclo de vida |
| `closures.pas` | Closure sobre variável local; contador, memoização |
| `proc_references.pas` | TProc<T>, TFunc<T,R>; passagem como parâmetro; multicast |
| `operator_overloading.pas` | Implicit, Explicit, +, -, *, =, <> em classes |
| `record_operators.pas` | Add, Subtract, Equal, Implicit, Explicit em records |
| `exit_params.pas` | Exit(value), guard clauses, early return patterns |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `anon_vs_proc_of_object.md` | Diferença: closure de variáveis vs ponteiro de método |
| `operator_tabela.md` | Todos os operadores overloadáveis com semântica |
| `inline_regras.md` | Quando inline é expandido; limitações do compilador |
| `exit_patterns.md` | Exit(Result), guard clauses, early return |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_pipeline.pas` | Pipeline funcional com TFunc<T,T> chainable |
| `TEMPLATE_event_handler.pas` | Event handler com TProc<T> e multicast |
| `TEMPLATE_builder_anon.pas` | Builder configurável com anonymous methods |

## Fontes

- `Doc-Delphi/delphi12-topics_chm_decompiled/` — "Anonymous Methods", "Inline"
- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Advanced Language
