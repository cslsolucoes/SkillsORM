# ProvidersORM — Forms de teste `ufrm*Teste`

<!-- FileVersion: 1.0.0 · Data: 17/04/2026 -->

Padrão de forms de teste (VCL/FMX/LCL) para validar módulos do framework ProvidersORM. Aplica-se a qualquer projeto que inclua os testes de aceitação do ORM.

## Convenção

- Prefixo `ufrm` + Módulo + sufixo `Teste`.
- Localização canónica: `<ORM_ROOT>/Views/` (conforme `.cursor/config.json._frameworks.providersORM.installPath`).
- Cada form cobre um módulo ORM; não deve chamar lógica de negócio do projeto consumidor.

## Lista canónica

| Form | Módulo testado | Cobertura |
|---|---|---|
| `ufrmConnectionTeste` | Connections | `IConnection.Connect/Disconnect`, FromConfig, multi-engine switch, eventos |
| `ufrmPoolConnectionsTeste` | PoolConnections | `IPoolConnections.GetFromPool/ReturnToPool`, eventos before/after, expiração |
| `ufrmDatabaseTeste` | Database | DDL (`GetSQLCreateTable`), DML (`ExecuteInsert`/Update/Delete), QueryBuilder |
| `ufrmDatabaseAttributersTeste` | Database (Attributes mode) | AttributeMapper, AttributeParser, EntityManager, IdentityMap, UnitOfWork |
| `ufrmExceptionsTeste` | Exceptions | Disparo das 7 categorias de `E{ORM}Exception`, integração com Exception DB |
| `ufrmParameters` | Parameters | Carregamento INI/JSON/Database, cascade fallback, `USE_PARAMENTERS` |
| `ufrmLoggers` | Loggers | 10 destinos (DB/CSV/TextFile/XML/JSON/HTTP/Email/WebSocket/EventLog/Custom), níveis |

## Critério de aceitação

Antes de release do ORM, os 7 forms devem compilar + rodar em:

- Windows 32-bit + 64-bit (Delphi/VCL + FMX).
- Linux 64-bit (FPC/Lazarus + LCL).

## Relação com agents

- `developer-delphi-agent-views-expert` documenta o conteúdo detalhado de cada form.
- `developer-delphi-agent-views-orchestrator` coordena a suite de testes visuais.

## Changelog

- 1.0.0 (17/04/2026): criação — extraído de `developer-delphi-agent-views-expert` / `views-orchestrator` na Onda 4.
