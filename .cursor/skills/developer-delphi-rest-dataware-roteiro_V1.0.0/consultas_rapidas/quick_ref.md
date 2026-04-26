---
description: "Referência rápida — roteiros de uso do REST DataWare"
alwaysApply: false
---

# Quick Reference — developer-delphi-rest-dataware-roteiro

| Operação | Componente/Método | Arquivo |
| --- | --- | --- |
| Iniciar servidor (Indy) | `TRESTDWIdBase.Active := True` | roteiro_server |
| Configurar pool de conexões | `TRESTDWPoolerDB` + `DataBase` + `UserName` | roteiro_server |
| SSL no servidor | `TRESTDWIdBase.SSLIOHandler + CertFile` | roteiro_server |
| Consulta SQL | `TRESTDWClientSQL.SQL + Params + Open` | roteiro_client |
| CRUD via tabela | `TRESTDWTable.Insert/Edit/Post/Delete` | roteiro_client |
| ApplyUpdates cliente | `TRESTDWClientSQL.ApplyUpdates` | roteiro_client |
| Obter JWT | Endpoint `/newtoken` + `Authorization: Bearer` | roteiro_auth |
| Renovar JWT | Endpoint `/renewtoken` | roteiro_auth |
| Auth Basic | `AuthorizationMode := amBasic` | roteiro_auth |
| Batch INSERT/UPDATE | `TRESTDWMassiveCache.ApplyUpdates` | roteiro_massive |
| Trocar driver | Diretiva em `uRESTDW.inc` | roteiro_drivers |
| FireDAC + PostgreSQL | `{$DEFINE RESTDWFIREDAC}` | roteiro_drivers |
| Zeos (FPC) | `{$DEFINE RESTDWZEOS}` | roteiro_drivers |

→ [roteiro_server.md](../exemplos/roteiro_server.md) · [roteiro_client.md](../exemplos/roteiro_client.md) · [roteiro_auth.md](../exemplos/roteiro_auth.md) · [roteiro_massive.md](../exemplos/roteiro_massive.md) · [roteiro_drivers.md](../exemplos/roteiro_drivers.md)
