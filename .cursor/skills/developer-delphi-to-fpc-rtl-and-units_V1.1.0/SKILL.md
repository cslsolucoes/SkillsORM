---
name: developer-delphi-to-fpc-rtl-and-units
description: Orquestradora da Família D — RTL e I/O Delphi. Cobre coleções genéricas, streams/IO e strings.
model: sonnet
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-rtl-and-units_V1.1.0

## Propósito

Orquestradora da Família D — RTL e I/O. Provê contexto integrado das três micro-skills que cobrem as bibliotecas de runtime mais usadas no Delphi: coleções genéricas, streams/IO e strings.

## Quando usar esta skill

Use esta skill para orientar **qual micro-skill da Família D invocar** conforme o tipo de problema. Use as micro-skills diretamente para detalhes de implementação.

## Mapa da Família D

| Skill | Responsabilidade | Acionar quando… |
|-------|-----------------|-----------------|
| `developer-delphi-to-fpc-rtl-collections_V1.1.0` | TList\<T\>, TDictionary\<K,V\>, TObjectList, TQueue, TStack, TSortedList, TComparer, LINQ-style | Precisar de coleção em memória, lookup por chave, fila/pilha, ordenação |
| `developer-delphi-to-fpc-rtl-streams-io_V1.1.0` | TStream, TFileStream, TMemoryStream, TStreamReader/Writer, TBinaryWriter/Reader, IOUtils | Leitura/escrita de arquivo, serialização binária, manipulação de paths |
| `developer-delphi-to-fpc-rtl-strings_V1.1.0` | TStringHelper, TStringBuilder, Format, TRegEx, encoding, conversões | Manipulação de texto, validação/extração com regex, formatação de saída |

## Combinações comuns

| Tarefa | Skills envolvidas |
|--------|------------------|
| Ler CSV e carregar em dicionário | streams-io → collections |
| Formatar relatório e salvar em arquivo | strings → streams-io |
| Parsear log e agrupar erros por tipo | strings (regex) → collections (groupby) |
| Cache em memória com lookup por string | collections (TDictionary) + strings (hash) |
| Serializar lista de registros em arquivo binário | collections + streams-io (binary_io) |
| Ler arquivo e extrair campos com regex | streams-io + strings |

## Conteúdo

### consultas_rapidas/

| Arquivo | Tema |
|---------|------|
| `mapa_skills_rtl.md` | Quando usar cada skill RTL — árvore de decisão |
| `units_principais.md` | Tabela unit → responsabilidade (SysUtils, Classes, IOUtils, etc.) |

## Skills relacionadas (outras famílias)

| Skill | Relação |
|-------|---------|
| `developer-delphi-to-fpc-language-types_V1.1.0` | Família B — tipos base usados pelas coleções |
| `developer-delphi-to-fpc-language-generics_V1.1.0` | Família B — generics que fundamentam TList\<T\> etc. |
| `developer-delphi-to-fpc-threading-basics_V1.1.0` | Família E — sincronização de coleções em threads |
| `developer-delphi-to-fpc-patterns-creational_V1.1.0` | Família C — padrões que usam coleções (ObjectPool, Registry) |

## Changelog

- V1.1.0 (2026-04-11): Criação como orquestradora Família D com 2 consultas_rapidas
