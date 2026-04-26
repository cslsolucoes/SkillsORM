---
name: parameters-absorption-finalize
description: Plano enxuto para finalizar a absorção do módulo Parameters ao ProvidersORM (Master). Fecha gaps cosméticos e residuais identificados na auditoria de 23/04/2026.
scope: Headers de 9 units + limpeza Views/backup + comentários nas Views
version: 1.0
date: 2026-04-23
---

## Estado atual da absorção

Auditoria executada em 23/04/2026. Todas as unidades funcionais do upstream `ParametersORM` já estão absorvidas no ProvidersORM (Master). Apenas gaps cosméticos/residuais restam.

### Absorção funcional — COMPLETA

| Upstream | Destino no Master | Estado |
|---|---|---|
| `Parameters.Consts` | `Commons/Commons.Parameters.Consts` | OK |
| `Parameters.Types` | `Commons/Commons.Parameters.Types` | OK |
| `Parameters.Exceptions` | `Modulos/Exceptions/Exceptions.Parameters` | OK |
| `Parameters.Attributes.*` (5 units) | `Attributers/Attributers.Parameters.*` + `Commons.Parameters.*` + `Exceptions.Parameters` | OK |
| `Parameters.IOUtils` (IfThen) | `Commons/Commons.StrUtils` (12 ocorrências) | OK |
| `Parameters.IOUtils` (TFile/TPath) | `Commons/Commons.IOUtils` | OK |
| `Parameters.Messages` | `Commons/Commons.Messages` (com aliases `ParametersMessage`/`OnParametersMessage`) | OK |
| `Parameters.Version` | `Commons/Commons.Version` | OK |
| `Parameters.FPC.inc` | `Commons/Commons.FPC.inc` | OK (bump FPC 3.2 → 3.3.1) |
| `Parameters.Interfaces` | `Main/Parameters.Interfaces` | OK |
| `Parameters.pas` | `Main/Parameters` | OK |
| `Parameters.Database.*` | `Modulos/Parameters/Database/*` | OK |
| `Parameters.Inifiles` | `Modulos/Parameters/IniFiles` | OK |
| `Parameters.JsonObject` | `Modulos/Parameters/JsonObject` | OK |
| `Parameters.DynamicLibrary` | Rejeitado — infra em `Commons.Consts` + `Commons.Types` + `Providers.Connection` | OK (decisão) |
| Registro no `.dpr` / `.lpr` | 17 units Parameters referenciadas corretamente | OK |

---

## Gaps identificados

### G1 — Header `Project: ParamentersORM` em 9 units (regra Master violada)

Master rule: todo arquivo deve declarar `Project: ProvidersORM` no cabeçalho.

Lista completa:

1. `src/Main/Parameters.pas`
2. `src/Main/Parameters.Interfaces.pas`
3. `src/Modulos/Parameters/Database/Parameters.Database.pas`
4. `src/Modulos/Parameters/Database/Parameters.Database.IniFile.pas`
5. `src/Modulos/Parameters/Database/Parameters.Database.JSonObject.pas`
6. `src/Modulos/Parameters/IniFiles/Parameters.Inifiles.pas`
7. `src/Modulos/Parameters/JsonObject/Parameters.JsonObject.pas`
8. `src/Attributers/Attributers.Parameters.pas`
9. `src/Attributers/Attributers.Parameters.Interfaces.pas`

### G2 — Residual em `src/Views/backup/`

- `src/Views/backup/ufrmParametersAttributers.pas`
- `src/Views/backup/ufrmParametersAttributers.lfm`

Cópia antiga pré-reorganização. O form ativo vive em `src/Views/ufrmParametersAttributers.*` e já está operacional.

### G3 — Comentários em Views referenciam namespace antigo

Documentação inline desatualizada em:

- `src/Views/ufrmParameters.pas` (linhas 1995, 2913, 3295) — cita `Parameters.Consts` (era o nome antigo de `Commons.Parameters.Consts`)
- `src/Views/ufrmConnectionTeste.pas:105`
- `src/Views/ufrmPoolConnectionsTeste.pas:151`

Apenas comentários — sem impacto funcional.

---

## Plano de ação

### Ação 1 — Normalizar header `Project:` nas 9 units

Para cada um dos 9 arquivos em G1:

- `Project: ParamentersORM` → `Project: ProvidersORM`
- `ProjectVersion: 1.0.X` → ler de `ORM.Version.inc` (equivalente ao valor atual, ex. `2.0.0`)
- Adicionar entrada Changelog:
  - `- X.Y.Z (2026-04-23): Header normalizado ao Master ProvidersORM (sync v1.0).`
- Bump `FileVersion` +0.0.1 em cada

### Ação 2 — Remover residual em Views/backup

- Deletar `src/Views/backup/ufrmParametersAttributers.pas`
- Deletar `src/Views/backup/ufrmParametersAttributers.lfm`
- Verificar se `src/Views/backup/` fica vazia → remover a pasta

### Ação 3 — Atualizar comentários em Views

Em cada um dos 3 arquivos de G3, substituir `Parameters.Consts` → `Commons.Parameters.Consts` nos comentários. Nenhuma mudança funcional.

### Ação 4 — Validar

- Compilar `dcc32`/`dcc64` + `fpc32`/`fpc64` (pré-requisito: corrigir mismatch `dataset-serialize` → `horse-dataset-serialize` no `dcc32.cfg`/`dcc64.cfg` linha 57 — ambiente, fora do escopo desta sync mas bloqueia a validação aqui também)
- Runtime smoke: `ufrmParameters`, `ufrmParametersAttributers`, `ufrmEcossistemaTeste`

---

## Arquivos tocados (resumo)

| Arquivo | Ação |
|---|---|
| `src/Main/Parameters.pas` | Header (Ação 1) |
| `src/Main/Parameters.Interfaces.pas` | Header (Ação 1) |
| `src/Modulos/Parameters/Database/Parameters.Database.pas` | Header (Ação 1) |
| `src/Modulos/Parameters/Database/Parameters.Database.IniFile.pas` | Header (Ação 1) |
| `src/Modulos/Parameters/Database/Parameters.Database.JSonObject.pas` | Header (Ação 1) |
| `src/Modulos/Parameters/IniFiles/Parameters.Inifiles.pas` | Header (Ação 1) |
| `src/Modulos/Parameters/JsonObject/Parameters.JsonObject.pas` | Header (Ação 1) |
| `src/Attributers/Attributers.Parameters.pas` | Header (Ação 1) |
| `src/Attributers/Attributers.Parameters.Interfaces.pas` | Header (Ação 1) |
| `src/Views/backup/ufrmParametersAttributers.pas` | Delete (Ação 2) |
| `src/Views/backup/ufrmParametersAttributers.lfm` | Delete (Ação 2) |
| `src/Views/ufrmParameters.pas` | Comentários (Ação 3) |
| `src/Views/ufrmConnectionTeste.pas` | Comentário (Ação 3) |
| `src/Views/ufrmPoolConnectionsTeste.pas` | Comentário (Ação 3) |
