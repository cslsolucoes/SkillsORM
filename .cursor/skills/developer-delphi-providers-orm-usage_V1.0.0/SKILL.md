---
name: developer-delphi-providers-orm-usage
description: Use when the user asks how to use the ProvidersORM framework — Attributes mode (class-to-table mapping, EntityManager, IdentityMap, UnitOfWork, AttributeRegistry). Canonical docs per-project: Documentation/RegrasNegocio/orm-usage.md or `.cursor/rules/local_arquivos_V1.0.mdc` if defined. Nota: o modo Slim foi descontinuado — apenas Attributes mode é suportado.
model: sonnet
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-providers-orm-usage

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill é a referência de uso prático do framework **ProvidersORM** no **modo Attributes** (mapeamento classe ↔ tabela via RTTI + EntityManager). Aplica-se a qualquer projeto que adopte o ProvidersORM. O **modo Slim (Connection.Lite) foi descontinuado** — não é mais suportado.

A skill orienta o desenvolvedor a consultar os documentos canónicos do próprio projeto (tipicamente `Documentation/RegrasNegocio/orm-usage.md` ou equivalente em `.workspace/`) antes de responder sobre units, fluxos ou trechos de código, garantindo que nenhuma API seja inventada.

Não cobre estrutura de pastas, compilação, padrões de nomenclatura ou documentação de produto — essas responsabilidades pertencem a skills dedicadas.

## When to use

- Usuário pergunta **como usar** o ProvidersORM no dia a dia (conexão, queries, transações, tabelas).
- Usuário pergunta sobre **modo Attributes**: mapeamento classe ↔ tabela, `[Table]` / `[Field]` / `[PrimaryKey]`, AttributeMapper, AttributeParser, EntityManager (Save, Find, FindAll, FindWhere, Delete), IdentityMap, UnitOfWork, AttributeRegistry.
- Usuário pede **exemplos de código** para conectar, criar tabela, inserir/atualizar/deletar, ou CRUD com entidades mapeadas.
- Usuário quer escolher quais flags activar (`USE_ATTRIBUTES` + `USE_ENTITY_MANAGER` + `USE_QUERY_BUILDER`).

**Ação obrigatória:** consultar a documentação canónica do projeto (tipicamente `Documentation/RegrasNegocio/orm-usage.md` ou o `.workspace/context.json.orm.useFlags`) antes de responder com units, fluxos ou trechos de código.

## When NOT to use

- Localizar pastas, units ou paths do repositório → usar `documentation-project-structure`.
- Compilação e diretivas `USE_*` → usar `developer-delphi-programming-conditional-defines` + `developer-delphi-build-toolchain`.
- Arquitectura de domínio, padrões `T*` / `I*`, factory e fluent → usar `documentation-project-expert`.
- Geração/atualização de documentação de produto → usar família `documentation-*`.

## Dependências (skills prévias)

| Skill                                                 | Quando executar antes                                     |
| ----------------------------------------------------- | --------------------------------------------------------- |
| `documentation-project-structure`                     | Para confirmar localização de units antes de citar paths  |
| `documentation-project-expert`                        | Para padrões de nomenclatura e interfaces ao implementar  |
| `developer-delphi-programming-conditional-defines`    | Para confirmar flags `USE_*` activas no projeto actual    |

## Modo único — Attributes (RTTI + EntityManager)

Flags mandatórias (activar em `.workspace/context.json.orm.useFlags`):

- `USE_ATTRIBUTES` — liga o subsistema de atributos RTTI do ProvidersORM.
- `USE_ENTITY_MANAGER` — liga o EntityManager, IdentityMap e UnitOfWork.
- `USE_QUERY_BUILDER` — (opcional) liga o IQueryBuilder.
- `USE_POOLCONNECTIONS` — (opcional) liga o pool de conexões.

APIs principais:

- **Mapeamento:** `[Table('nome', 'schema')]`, `[Field('coluna')]`, `[PrimaryKey]`, `[Nullable]`, `[AutoIncrement]`.
- **AttributeMapper:** `IAttributeMapper.MapClass(TClass)` → retorna `ITableDef`.
- **AttributeParser:** `IAttributeParser.ParseObject(TObject)` → retorna `ITableData`.
- **EntityManager:** `IEntityManager.Save(Entity) / Find(id) / FindAll / FindWhere(criteria) / Delete(Entity)`.
- **IdentityMap:** `IIdentityMap` — cache de entidades por chave primária; evita duplicatas na mesma transação.
- **UnitOfWork:** `IUnitOfWork.BeginTransaction / Commit / Rollback / AddDirty / Remove`.
- **AttributeRegistry:** `IAttributeRegistry.Register(TClass)` — registo explícito (alternativa ao descobrimento automático via RTTI).

Tipos de banco suportados: `dtPostgreSQL`, `dtMySQL`, `dtSQLServer`, `dtFireBird`, `dtSQLite`, `dtAccess` (conforme engines activas no `.cursor/config.json._frameworks.providersORM` e overrides do `.workspace/context.json`).

## Documentos canónicos por projeto

O desenvolvedor deve consultar no seu próprio projeto:

| Documento típico                                  | Localização recomendada                                    | Conteúdo esperado                                  |
| ------------------------------------------------- | ---------------------------------------------------------- | -------------------------------------------------- |
| Roteiros de uso do ORM                            | `Documentation/RegrasNegocio/orm-usage.md`                 | Passos Attributes (1–8: classe mapeada, AttributeMapper, AttributeParser, EntityManager, FindAll/FindWhere, IdentityMap, UnitOfWork, AttributeRegistry). Units, resumo de tipos de banco. |
| Exemplo de uso e flags activas                    | `.workspace/context.json.orm`                              | `useFlags`, `moduleMap`, paths do ORM no clone.    |

## Regra de uso

1. **Ao responder sobre uso do ORM:** ler a documentação canónica do projeto (ver tabela acima) antes de citar units, fluxos ou trechos de código. Não inventar APIs ou métodos que não constem ali.
2. **Ao alterar** os roteiros (novas seções, novos exemplos, novas APIs): actualizar a documentação do projeto e manter esta skill alinhada à descrição. Se o alteração for genérica (aplicável a qualquer projeto que use ProvidersORM), propagar para esta skill; se for específica do clone, manter só no `Documentation/` local ou em `.workspace/`.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| ----------- | ---------------- | ------------- |
| Inventar métodos/APIs sem consultar os documentos canónicos | Gera código que não existe no ORM; leva o desenvolvedor a erro | Sempre ler a documentação local antes de sugerir qualquer API |
| Tentar usar o modo Slim / Connection.Lite | Feature **descontinuada**; não existe mais no ProvidersORM | Usar exclusivamente o modo Attributes (USE_ATTRIBUTES + USE_ENTITY_MANAGER) |
| Referenciar units internas do ORM (`Modulos/*`) directamente em código consumidor | Viola encapsulamento — essas units são internas do framework | Aceder apenas às interfaces públicas em `src/Main/` do ProvidersORM |
| Activar `USE_ENTITY_MANAGER` sem `USE_ATTRIBUTES` | EntityManager depende do subsistema de atributos RTTI | Activar sempre ambas em conjunto |

## Métricas de sucesso

- Nenhuma API ou método citado que não exista na documentação do ORM ou do projeto.
- Desenvolvedor consegue implementar classe mapeada + primeira operação CRUD (Save/Find) em menos de 30 minutos.
- Code review confirma zero uso do modo Slim (descontinuado) e zero referência a units internas do ORM fora das interfaces públicas.

## Responsável principal

| Papel    | Quem                              |
| -------- | --------------------------------- |
| Executor | Desenvolvedor ORM                 |
| Revisor  | `documentation-project-expert`    |

---

## Changelog (este arquivo)

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `developer-delphi-providers-orm-usage_V1.0.0` para `developer-delphi-providers-orm-usage_V1.0.0`. **Modo Slim / Connection.Lite removido** (descontinuado). Skill passa a documentar exclusivamente o modo Attributes (EntityManager + IdentityMap + UnitOfWork + AttributeRegistry). Documentação canónica passa a ser lida por projeto (`Documentation/RegrasNegocio/orm-usage.md` + `.workspace/context.json`). Versão V1.2.0 arquivada em `.cursor/Backup/renamed-skills-20260417/skills/developer-delphi-providers-orm-usage_V1.0.0/`.
- 1.2.0 (11/04/2026): Criados `consultas_rapidas/quick_ref.md`, `exemplos/roteiro_slim.md`, `exemplos/roteiro_attributes.md`; bump FileVersion 1.1.0 → 1.2.0.
- 1.1.0 (09/04/2026): Migração V2 — `thinking: extended`, `category: project`, Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal adicionados.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
