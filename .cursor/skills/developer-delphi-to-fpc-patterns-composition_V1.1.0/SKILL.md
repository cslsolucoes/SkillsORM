---
name: developer-delphi-to-fpc-patterns-composition
description: Orquestradora da Família C — Design Patterns Delphi. Mapeia as 3 micro-skills de padrões por categoria.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-patterns-composition_V1.1.0

## Propósito

Orquestradora da **Família C — Design Patterns**. Mapeia as 3 micro-skills de padrões e orienta sobre qual categoria usar para cada problema de design em Delphi.

## Quando usar esta skill

Use como ponto de entrada quando souber que precisa de um padrão de design mas não souber em qual categoria cair.

| Pergunta | Família | Skill |
|----------|---------|-------|
| Como criar objetos sem acoplar ao tipo concreto? | Creational | `developer-delphi-to-fpc-patterns-creational_V1.1.0` |
| Como compor objetos para estruturas maiores? | Structural | `developer-delphi-to-fpc-patterns-structural_V1.1.0` |
| Como distribuir responsabilidade entre objetos? | Behavioral | `developer-delphi-to-fpc-patterns-behavioral_V1.1.0` |

## Mapa da Família C

| Skill | Padrões cobertos |
|-------|-----------------|
| `patterns-creational_V1.1.0` | Factory Method, Abstract Factory, Builder fluente, Singleton thread-safe, Prototype, Object Pool |
| `patterns-structural_V1.1.0` | Composite, Decorator, Adapter, Proxy, Facade, Bridge |
| `patterns-behavioral_V1.1.0` | Strategy, Observer, Command+Undo, Chain of Responsibility, Mediator, State, Iterator |

## Conteúdo desta orquestradora

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `mapa_skills_patterns.md` | Quando usar cada skill de patterns |
| `gof_tabela.md` | 23 padrões GoF classificados com contexto Delphi |
| `patterns_delphi.md` | Adaptações específicas do Delphi (interfaces, anonymous methods, generics) |

## Princípios transversais

- **Interfaces `I*`** como contrato — nunca acoplar ao tipo concreto
- **Factory `New`** como único ponto de criação — evitar `T.Create` no código cliente
- **Composição via interface** — preferir delegation a herança profunda
- **Compatibilidade Delphi + FPC** — evitar features exclusivas de um compilador nos exemplos

## Changelog

- V1.1.0 (2026-04-11): Criação inicial como orquestradora da Família C; sem V1.0.0 predecessora
