---
name: developer-delphi-to-fpc-patterns-creational
description: Padrões de criação em Delphi — Factory Method, Abstract Factory, Builder fluente, Singleton, Prototype, Object Pool.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-patterns-creational_V1.1.0

## Propósito

Dominar padrões de criação em Delphi: Factory Method, Abstract Factory, Builder fluente, Singleton thread-safe, Prototype e Object Pool. Cada padrão com implementação canônica via interface + factory function (`New`).

## Quando usar esta skill

- Isolar criação de objetos do código cliente (Factory)
- Construir objetos complexos passo a passo (Builder)
- Garantir instância única thread-safe (Singleton)
- Reutilizar objetos caros de criar (Object Pool)
- Clonar objetos preservando estado (Prototype)

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `factory_method.pas` | TAnimalFactory.New — factory com registro dinâmico |
| `abstract_factory.pas` | IDBFactory: NewConnection + NewQuery por engine |
| `builder_pattern.pas` | TQueryBuilder fluente com method chaining completo |
| `singleton.pas` | TSingleton<T> thread-safe com Double-Checked Locking |
| `prototype.pas` | Clone via interface + cópia profunda |
| `object_pool.pas` | Pool de objetos reutilizáveis com Acquire/Release |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `factory_vs_new.md` | Quando usar factory vs constructor direto |
| `singleton_riscos.md` | Thread safety, lifetime, testability issues |
| `builder_fluente.md` | Regras do fluent API: Self return, terminador, validação |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_factory_interface.pas` | Factory com interface + registro dinâmico de tipos |
| `TEMPLATE_builder_fluente.pas` | Builder fluente completo com validação e build |
| `TEMPLATE_singleton_safe.pas` | Singleton thread-safe Double-Checked Locking |

## Fontes

- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Design Patterns
- GoF — Design Patterns (Gamma et al.)
