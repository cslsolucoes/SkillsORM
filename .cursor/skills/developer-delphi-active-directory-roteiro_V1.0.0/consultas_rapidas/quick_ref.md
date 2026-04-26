---
description: "Referência rápida — roteiros de uso do ActiveDirectoryORM"
alwaysApply: false
---

# Quick Reference — developer-delphi-active-directory-roteiro

| Operação | Método | Arquivo |
| --- | --- | --- |
| Config mínima fluente | `TActiveDirectory.New.Host(...).BaseDN(...).GetConfig` | roteiro_config |
| SSL/LDAPS | `.UseSSL(True)` → porta 636 automático | roteiro_config |
| Múltiplas OUs | `.AddSearchOU('OU=Users,...').AddSearchOU(...)` | roteiro_config |
| Config de TStringList | `.SetConfig(TStringList)` formato `Host=srv` | roteiro_config |
| TestConnection | `svc.Connect` + `svc.TestConnection` | roteiro_auth |
| Auth por SAM/UPN | `svc.Authenticate('joao', 'senha')` | roteiro_auth |
| Auth por DN | `svc.AuthenticateUser('CN=joao,...', 'senha')` | roteiro_auth |
| Busca com filtro | `svc.SearchObjects('(cn=joao)', Attrs)` | roteiro_queries |
| Listar grupos | `svc.ListGroups(OUs)` | roteiro_queries |
| Membros do grupo | `svc.GetGroupMembers('CN=GrupoTI,...')` | roteiro_queries |
| Modificar atributo | `svc.SetAttributeValue(DN, 'mail', 'novo@')` | roteiro_write |
| Adicionar membro | `svc.AddMemberToGroup(GroupDN, MemberDN)` | roteiro_write |
| Alterar senha | `svc.ChangePassword(DN, old, new)` + UseSSL obrigatório | roteiro_write |

→ [roteiro_config.md](../exemplos/roteiro_config.md) · [roteiro_auth.md](../exemplos/roteiro_auth.md) · [roteiro_queries.md](../exemplos/roteiro_queries.md) · [roteiro_write.md](../exemplos/roteiro_write.md)
