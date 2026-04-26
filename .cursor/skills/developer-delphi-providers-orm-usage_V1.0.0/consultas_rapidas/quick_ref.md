---
description: "Referência rápida — modos de operação do Providers ORM"
alwaysApply: false
---

# Quick Reference — developer-delphi-providers-orm-usage

| Modo | Quando usar | Arquivo canônico |
|------|-------------|-----------------|
| **Slim — Connection + Tables** | DDL/DML sem RTTI; cenário simples ou multi-engine; compatível Delphi + FPC | `src/Modulos/Connections/`, `src/Modulos/Database/` |
| **Attributes — EntityManager** | Persistência com mapeamento declarativo `[Table]`/`[Field]`; requer `USE_ATTRIBUTES` + `USE_ENTITY_MANAGER` | `src/Attributers/`, `src/Modulos/Database/EntityManager.pas` |
| **QueryBuilder** | SELECT fluente sem escrever SQL manualmente; funciona com ou sem Attributes | `src/Modulos/Database/QueryBuilder.pas` |
| **Pool** | Múltiplas conexões concorrentes; requer `USE_POOLCONNECTIONS` | `src/Modulos/PoolConnections/` |

## Operações Slim — visão 1-linha

| Operação | Chamada |
|----------|---------|
| Conectar | `LConn := TConnection.New.Host('h').Port(5432).Database('db').Connect` |
| Desconectar | `LConn.Disconnect` |
| Carregar tabelas | `LTables := TTables.New.LoadFromConnection(LConn)` |
| Gerar INSERT | `LTable.GenerateInsertSQL` |
| Executar comando | `LConn.ExecuteCommand(SQL)` |
| Executar query | `LDS := LConn.ExecuteQuery(SQL)` |
| Scalar | `LVal := LConn.ExecuteScalar(SQL)` |
| Transação | `LConn.BeginTransaction` / `LConn.Commit` / `LConn.Rollback` |

→ Exemplos Attributes: [exemplos/roteiro_attributes.md](../exemplos/roteiro_attributes.md) (modo Slim foi descontinuado)
