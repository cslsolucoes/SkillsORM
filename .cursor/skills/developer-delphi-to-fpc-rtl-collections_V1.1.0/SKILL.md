---
name: developer-delphi-to-fpc-rtl-collections
description: Coleções genéricas RTL Delphi — TList<T>, TDictionary<K,V>, TObjectList<T>, comparadores e padrões LINQ-like.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-rtl-collections_V1.1.0

## Propósito

Dominar as coleções genéricas do RTL Delphi: `TList<T>`, `TDictionary<K,V>`, `TObjectList<T>`, `TQueue<T>`, `TStack<T>`, `TSortedList`, comparadores customizados e padrões LINQ-like.

## Quando usar esta skill

- Listas ordenáveis com elementos de tipo específico (TList<T>)
- Mapas chave-valor com lookup O(1) (TDictionary)
- Listas com gerência automática de lifetime dos objetos (TObjectList)
- Filas FIFO e pilhas LIFO (TQueue, TStack)
- Listas sempre ordenadas com busca binária (TSortedList)
- Transformações pipeline sobre coleções (LINQ-style)

## Conteúdo

### exemplos/

| Arquivo | Tema |
|---------|------|
| `tlist_generica.pas` | TList<T>: Add, Remove, Find, Sort, ForEach, comparer |
| `tdictionary.pas` | TDictionary<K,V>: Add, TryGetValue, iteração, grupos |
| `tobjectlist.pas` | TObjectList<T>: OwnsObjects, auto-destroy, herança |
| `tqueue_tstack.pas` | TQueue<T> FIFO e TStack<T> LIFO com exemplos práticos |
| `tsortedlist.pas` | TSortedList + TComparer customizado + busca binária |
| `linq_style.pas` | LINQ-like: Where, Select, GroupBy, OrderBy com anonymous methods |

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `collections_comparativo.md` | TList vs TObjectList vs TDictionary vs TQueue — quando usar |
| `comparer_custom.md` | TComparer<T>.Construct; IComparer<T>; Sort/BinarySearch |
| `collections_thread_safe.md` | TThreadList<T>; TMonitor; padrões de locking |

### templates/

| Arquivo | Uso |
|---------|-----|
| `TEMPLATE_repository_list.pas` | Repositório em memória com TDictionary (CRUD + query) |
| `TEMPLATE_cache_lru.pas` | Cache LRU com TDictionary + lista de acesso |

## Fontes

- `Doc-Delphi/delphi12-libraries_chm_decompiled/` — System.Generics.Collections
- `Doc-Delphi/delphi13-libraries_chm_decompiled/` — RTL Delphi 13

## Changelog

- V1.1.0 (2026-04-11): Criação inicial com 6 exemplos, 3 consultas_rapidas, 2 templates
