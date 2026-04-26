---
name: developer-delphi-to-fpc-language-generics
description: Generics em Delphi — classes/métodos genéricos, constraints, TList/TDictionary, Nullable<T>, Result<T,E>.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-language-generics_V1.1.0

## Propósito

Dominar generics em Delphi: declaração de classes e métodos genéricos, constraints, collections genéricas da RTL (TList, TDictionary, TQueue, TStack) e padrões avançados como Nullable<T>, Result<T,E> e Repository<T>.

## Quando usar esta skill

- Criar classes/métodos reutilizáveis sem duplicação por tipo
- Usar TList<T>, TDictionary<K,V>, TQueue<T>, TStack<T>
- Aplicar constraints (class, record, constructor, interface)
- Implementar padrões como Repository, Factory, Nullable, Result

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `generics_basicos.pas` | Declaração TMyClass<T>, instanciação, type params |
| `constraints.pas` | class, record, constructor, interface, base class |
| `generic_methods.pas` | Métodos genéricos: procedure Foo<T>(const V: T) |
| `generic_collections.pas` | TList<T>, TDictionary<K,V>, TQueue<T>, TStack<T> |
| `generic_factory.pas` | Factory genérica: TFactory<T: class, constructor> |
| `generic_repository.pas` | Repository pattern genérico com IRepository<T, TId> |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `constraints_tabela.md` | Todos os constraints com semântica e exemplos |
| `generics_vs_vartype.md` | Quando usar generics vs Variant vs TObject vs Any |
| `common_patterns.md` | Nullable<T>, Optional<T>, Result<T,E>, Lazy<T> |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_generic_list.pas` | Lista genérica com Add/Remove/Find/ForEach/Sort |
| `TEMPLATE_generic_result.pas` | Result<T,E> para error handling funcional |
| `TEMPLATE_nullable.pas` | Nullable<T> record com HasValue/Value/OrElse |

## Fontes

- `Doc-Delphi/delphi12-topics_chm_decompiled/` — "Generics"
- `Doc-Delphi/delphi12-system_chm_decompiled/` — System.Generics.Collections
- `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Generics
