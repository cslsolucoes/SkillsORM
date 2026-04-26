---
name: loggers-absorption-finalize
description: Plano enxuto para finalizar a absorção do módulo Loggers ao ProvidersORM (Master). Fecha gaps cosméticos e residuais identificados na auditoria de 23/04/2026.
scope: Headers de 60 units Loggers* + limpeza __history/ + arquivo .~1~ residual
version: 1.0
date: 2026-04-23
---

## Estado atual da absorção

Auditoria executada em 23/04/2026 contra o upstream `E:/CSL/LoggersORM` (frozen em 11/02/2026). Todas as unidades funcionais do upstream já estão absorvidas no ProvidersORM (Master). Apenas gaps cosméticos/residuais restam. Não há wave de atualizações upstream recente (diferente do Parameters).

### Absorção funcional — COMPLETA

| Upstream | Destino no Master | Estado |
|---|---|---|
| `src/Loggers.pas` | `Main/Loggers.pas` (3037 L; +36 L customização ecossistema) | OK |
| `src/Loggers.Interfaces.pas` | `Main/Loggers.Interfaces.pas` | OK |
| `src/Commons/Loggers.Consts` | `Commons/Commons.Loggers.Consts` | OK |
| `src/Commons/Loggers.Types` | `Commons/Commons.Loggers.Types` (+ `Commons.Loggers.SQL.*`) | OK |
| `src/Commons/Loggers.Exceptions` | `Modulos/Exceptions/Exceptions.Loggers` | OK |
| `src/Attributes/Loggers.Attributes.*` (5 units) | `Attributers/Attributers.Loggers.*` (2 units) + `Commons.Loggers.*` + `Exceptions.Loggers` | OK |
| `src/Modules/CSV/*` (5) | `Modulos/Loggers/CSV/*` (5) | OK |
| `src/Modules/Databases/Loggers.Database.*` (4 units: Consts+Exceptions+Interfaces+pas) | `Modulos/Loggers/Databases/*` (2 units; Consts→`Commons.Loggers.Consts`, Exceptions→`Exceptions.Loggers`) | OK |
| `src/Modules/Emails/*` (+Engines) | `Modulos/Loggers/Emails/*` + `Engines/Email.*` (renome: `Emails.Engines.*` → `Engines.Email.*`) | OK |
| `src/Modules/EventLogs/*` (5) | `Modulos/Loggers/EventLogs/*` (5) | OK |
| `src/Modules/Events/*` (5) | `Modulos/Loggers/Events/*` (5) | OK |
| `src/Modules/Https/*` (+Engines) | `Modulos/Loggers/Https/*` + `Engines/HTTP.*` (renome) | OK |
| `src/Modules/JsonObject/*` (5 + 2 json.*) | `Modulos/Loggers/JsonObject/*` (5 + 2 json.*) | OK |
| `src/Modules/TextFiles/*` (2) | `Modulos/Loggers/TextFiles/*` (2) | OK |
| `src/Modules/WebSocket/*` (6) | `Modulos/Loggers/WebSocket/*` (5) + `Engines/WebSocket.Indy` (renome) | OK |
| `src/Modules/XML/*` (5) | `Modulos/Loggers/XML/*` (5) | OK |
| `src/Paramenters/Loggers.Paramenters.*` (5 stubs vazios de 7 L) | **Rejeitado** — nunca implementado upstream; integração Loggers↔Parameters já provida pelo ecossistema `SetLogger`/`SetExceptions` | OK (decisão) |
| Registro no `.dpr` / `.lpr` | Units Loggers referenciadas corretamente (Main, Attributers, Exceptions, Modulos/Loggers/*) | OK |

---

## Gaps identificados

### G1 — `Project: LoggersORM` ou `Project: LoggersCSL` em 60 units (regra Master violada)

Master rule: `Project: ProvidersORM`, `ProjectVersion` de `ORM.Version.inc` (2.1.6), `Date: 23/04/2026`.

Distribuição (60 arquivos):

- `src/Main/`: 2 (`Loggers.pas`, `Loggers.Interfaces.pas`)
- `src/Attributers/`: 2 (`Attributers.Loggers.*`)
- `src/Modulos/Loggers/CSV/`: 5
- `src/Modulos/Loggers/Databases/`: 2
- `src/Modulos/Loggers/Emails/`: 5
- `src/Modulos/Loggers/Engines/`: 9 (`Email.Factory/Indy/Interfaces/Synapse` + `HTTP.Factory/Indy/Interfaces/Synapse` + `WebSocket.Indy`)
- `src/Modulos/Loggers/EventLogs/`: 5
- `src/Modulos/Loggers/Events/`: 5
- `src/Modulos/Loggers/Https/`: 5
- `src/Modulos/Loggers/JsonObject/`: 7 (Loggers.JsonObject.* 5 + Loggers.json.* 2)
- `src/Modulos/Loggers/TextFiles/`: 2
- `src/Modulos/Loggers/WebSocket/`: 5 (+ 1 residual em `__history/`)
- `src/Modulos/Loggers/XML/`: 5

### G2 — Residuais IDE em `src/Modulos/Loggers/WebSocket/__history/`

- `Loggers.WebSocket.Consts.pas.~1~` (backup automático do Delphi IDE)
- Pasta `__history/` deve ser removida após deletar o arquivo

### G3 — Comentários nas Views

**Nenhum** — grep em `src/Views` não encontrou referências a namespaces antigos (`Loggers.Consts`, `Loggers.Types`, `Loggers.Exceptions`, `Loggers.Attributes.*`, `Loggers.Paramenters`). Mais limpo que o Parameters.

---

## Plano de ação

### Ação 1 — Normalizar header `Project:` nas 60 units

Para cada unit com `Project: LoggersORM` ou `Project: LoggersCSL`:

- `Project: LoggersORM` (ou `LoggersCSL`) → `Project: ProvidersORM`
- `ProjectVersion: 1.0.X` → `ProjectVersion: 2.1.6`
- `Date:` → `23/04/2026`
- Bump `FileVersion` +0.0.1
- Adicionar entrada Changelog:
  - `- X.Y.Z (23/04/2026): Header normalizado ao Master ProvidersORM (absorção Loggers — finalize v1.0).`

### Ação 2 — Remover residuais IDE

- Deletar `src/Modulos/Loggers/WebSocket/__history/Loggers.WebSocket.Consts.pas.~1~`
- Remover pasta `src/Modulos/Loggers/WebSocket/__history/` (após esvaziar)
- Grep preventivo por outros `__history/` em `src/Modulos/Loggers` (vazio hoje mas manter no checklist)

### Ação 3 — Validar

- Compilar `dcc32`/`dcc64` + `fpc32`/`fpc64` (pré-requisito: corrigir mismatch `dcc32.cfg`/`dcc64.cfg` linha 57 `dataset-serialize` → `horse-dataset-serialize` — ambiente, mesmo blocker do Parameters)
- Runtime smoke: `ufrmEcossistemaTeste` (usa `SetLogger`/`SetExceptions`)

---

## Arquivos tocados (resumo)

| Pasta | Qtd | Ação |
|---|---|---|
| `src/Main/` | 2 | Header (Ação 1) |
| `src/Attributers/` | 2 | Header (Ação 1) |
| `src/Modulos/Loggers/CSV/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/Databases/` | 2 | Header (Ação 1) |
| `src/Modulos/Loggers/Emails/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/Engines/` | 9 | Header (Ação 1) |
| `src/Modulos/Loggers/EventLogs/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/Events/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/Https/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/JsonObject/` | 7 | Header (Ação 1) |
| `src/Modulos/Loggers/TextFiles/` | 2 | Header (Ação 1) |
| `src/Modulos/Loggers/WebSocket/` | 5 | Header (Ação 1) |
| `src/Modulos/Loggers/WebSocket/__history/` | 1 + pasta | Delete (Ação 2) |
| `src/Modulos/Loggers/XML/` | 5 | Header (Ação 1) |
| **Total** | **60 headers + 1 delete + 1 pasta** | — |
