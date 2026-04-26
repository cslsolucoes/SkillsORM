# ProvidersORM — Estrutura interna canónica de módulos

<!-- FileVersion: 1.0.0 · Data: 17/04/2026 -->

Estrutura canónica de cada módulo do framework ProvidersORM. Aplica-se a qualquer projeto que consuma o ORM.

## Árvore do ORM

```
{ORM_ROOT}/                            (default: E:/CSL/ProvidersORM)
├── src/
│   ├── Main/                          ← APIs públicas (única fachada de consumo)
│   │   ├── Providers.Connection.pas
│   │   ├── Providers.Connection.Interfaces.pas
│   │   ├── Providers.PoolConnections.pas
│   │   ├── Providers.PoolConnections.Interfaces.pas
│   │   ├── Providers.Database.pas
│   │   ├── Providers.Database.Interfaces.pas
│   │   ├── Providers.Exceptions.pas
│   │   ├── Providers.Exceptions.Interfaces.pas
│   │   ├── Providers.Parameters.pas
│   │   ├── Providers.Parameters.Interfaces.pas
│   │   ├── Providers.Loggers.pas
│   │   └── Providers.Loggers.Interfaces.pas
│   ├── Commons/                       ← Tipos, constantes, excepções (fonte única)
│   │   ├── Providers.Commons.Types.pas
│   │   ├── Providers.Commons.Consts.pas
│   │   ├── Providers.Commons.Exceptions.pas
│   │   └── Providers.Commons.Utils.pas
│   ├── Modulos/
│   │   ├── Connections/               ← implementação do módulo Connections
│   │   │   ├── Providers.Connection.Engine.FireDAC.pas
│   │   │   ├── Providers.Connection.Engine.UniDAC.pas
│   │   │   ├── Providers.Connection.Engine.Zeos.pas
│   │   │   └── Providers.Connection.Engine.SQLdb.pas
│   │   ├── PoolConnections/
│   │   ├── Database/                  ← TTable, TTables, QueryBuilder, EntityManager
│   │   ├── Exceptions/
│   │   ├── Parameters/
│   │   └── Loggers/
│   └── Attributers/                   ← atributos RTTI (USE_ATTRIBUTES)
├── Views/                             ← forms de teste ufrm*Teste
├── Analise/                           ← documentação de análise por classe
├── Exemplos/                          ← casos de uso
└── Data/                              ← exception.db, config.ini, seeds
```

## Regras de encapsulamento

1. **`src/Main/`** é a **única fachada pública** — consumidores externos (aplicações que usam o ORM) só fazem `uses` de `Providers.<Module>` ou `Providers.<Module>.Interfaces`.
2. **`src/Modulos/*`** é **interno** ao ORM — nunca referenciado directamente por consumidores.
3. **`src/Commons/`** é **fonte única** de tipos, constantes e excepções — módulos consomem Commons, nunca duplicam definições.
4. **`src/Attributers/`** só é activo quando `USE_ATTRIBUTES` está definido (via `ORM.Defines.inc`).

## Path resolution

O path concreto do ORM deste clone é lido de:

1. `.workspace/context.json._frameworks_overrides.providersORM.installPath` (override local, se existir).
2. `.cursor/config.json._frameworks.providersORM.installPath` (default canónico, `E:/CSL/ProvidersORM`).

## Relação com agents

Os 11 agents `developer-delphi-agent-*` referenciam esta estrutura:

| Agent | Módulo em `src/Modulos/` |
|---|---|
| `-orm-architect` | hierarquia completa (Connections → Database → …) |
| `-connections-expert` | `Connections/` + `src/Main/Providers.Connection.pas` |
| `-poolconnections-expert` | `PoolConnections/` + `src/Main/Providers.PoolConnections.pas` |
| `-database-expert` | `Database/` + `src/Main/Providers.Database.pas` |
| `-exceptions-expert` | `Exceptions/` + `src/Commons/Providers.Commons.Exceptions.pas` + `Data/exception.db` |
| `-parameters-expert` | `Parameters/` + `src/Main/Providers.Parameters.pas` (requer `USE_PARAMENTERS`) |
| `-loggers-expert` | `Loggers/` + `src/Main/Providers.Loggers.pas` (requer `USE_LOGGERS`) |
| `-views-expert` | `Views/` (7 forms `ufrm*Teste`) |

## Changelog

- 1.0.0 (17/04/2026): criação — extraído dos 11 agents `developer-delphi-agent-*` na Onda 4.
