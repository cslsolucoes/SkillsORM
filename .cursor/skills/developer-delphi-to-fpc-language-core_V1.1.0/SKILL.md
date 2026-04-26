---
name: developer-delphi-to-fpc-language-core
description: "Orquestradora Família B — Linguagem Object Pascal: direciona para a micro-skill correta (types, oop, generics, rtti, advanced). Inclui fundamentos Pascal, estrutura de units e mapa de skills."
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-core_V1.1.0

## Versão interna

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Atualização** | 2026-04-11 |

## Responsabilidade

Orquestradora da **Família B — Linguagem Core**. Mapeia requisitos de linguagem para a micro-skill correta e fornece referências rápidas de fundamentos Pascal (sintaxe, unidades, estrutura).

**NÃO** substitui as micro-skills — delega para elas.

## Mapa das micro-skills (Família B)

| Skill | Responsabilidade | Usar quando |
|-------|-----------------|-------------|
| [`developer-delphi-to-fpc-language-types_V1.1.0`](../developer-delphi-to-fpc-language-types_V1.1.0/SKILL.md) | Tipos primitivos, strings, arrays, records, enums, pointers | Declarar tipos de dados, DTOs, flags |
| [`developer-delphi-to-fpc-language-oop_V1.1.0`](../developer-delphi-to-fpc-language-oop_V1.1.0/SKILL.md) | Classes, interfaces, herança, polimorfismo, helpers, operators | Modelar entidades, padrões OOP, ciclo de vida |
| [`developer-delphi-to-fpc-language-generics_V1.1.0`](../developer-delphi-to-fpc-language-generics_V1.1.0/SKILL.md) | TList<T>, TDictionary<K,V>, constraints, patterns genéricos | Coleções type-safe, repository, factory genérica |
| [`developer-delphi-to-fpc-language-rtti_V1.1.0`](../developer-delphi-to-fpc-language-rtti_V1.1.0/SKILL.md) | TRttiContext, attributes, reflection, auto-binding, DI | Mappers, serialização, validação declarativa |
| [`developer-delphi-to-fpc-language-advanced_V1.1.0`](../developer-delphi-to-fpc-language-advanced_V1.1.0/SKILL.md) | Anonymous methods, closures, TProc/TFunc, inline, operators | Callbacks, pipelines funcionais, guard clauses |

## When to use (esta skill)

- Dúvida sobre **qual micro-skill de linguagem** usar
- Precisar de referência rápida de **fundamentos Pascal** (sintaxe, units)
- Checar **compatibilidade Delphi × FPC**

## When NOT to use

| Necessidade | Skill correta |
|-------------|---------------|
| Build/deploy | `developer-delphi-to-fpc-build` |
| RTL/units/System.* | `developer-delphi-to-fpc-rtl-and-units` |
| Diretivas de engine | `developer-delphi-programming-conditional-defines` |
| Exceptions/diagnóstico | `developer-delphi-to-fpc-error-handling-and-diagnostics` |
| Arquitetura macro | `developer-delphi-to-fpc-architecture-and-design` |

## Checklist cross-compiler (Delphi + FPC)

- [ ] Sem inline variables (`var x := 1`) em código compartilhado — FPC não suporta
- [ ] String tipada explicitamente ou com `{$H+}` + `{$mode delphi}` no FPC
- [ ] Attributes com guard `{$IFDEF}` para FPC < 3.3
- [ ] Generics testados nos quatro targets: dcc32, dcc64, fpc32, fpc64
- [ ] Nomenclatura: `I*` interfaces, `T*` classes/records, `E*` exceptions, `F*` fields, `A*` params

## Changelog

- 1.1.0 (2026-04-11): Promovida a orquestradora V1.1.0 da Família B. Adicionado mapa completo das 5 micro-skills; consultas_rapidas de fundamentos Pascal, estrutura de units e mapa de skills.
- 1.0.0 (2026-04-09): Versão inicial — cross-compiler language rules; migrada de `developer-delphi-language-core`.
