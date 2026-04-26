---
description: "Referência rápida — estrutura de arquivos ActiveDirectoryORM"
alwaysApply: false
---

# Quick Reference — developer-delphi-active-directory-estrutura

| Camada | Path relativo | O que contém |
| --- | --- | --- |
| Factory | `src/Main/ActiveDirectory.Main.pas` | `TActiveDirectory.New` |
| Interface fluent | `src/Main/ActiveDirectory.Main.Interfaces.pas` | `IActiveDirectoryConnection` |
| Serviço LDAP | `src/ActiveDirectory.Service.pas` | `TActiveDirectoryService` (USE_LDAP) |
| Tipos/Record | `src/Commons/ActiveDirectory.Types.pas` | `TLDAPConfig`, `TLDAPEntry` |
| Constantes | `src/Commons/ActiveDirectory.Consts.pas` | Portas, objectClass, ERR_LDAP_BASE |
| Exceções | `src/Commons/ActiveDirectory.Exceptions.pas` | Hierarquia EAD* (40001-40006) |
| Helpers | `src/Commons/ActiveDirectory.Helpers.pas` | `TActiveDirectoryHelper` |
| Views de teste | `src/Views/` | `ufrmActiveDirectoryTeste`, `ufrmLDAP_Teste` |
| OpenSSL (LDAPS) | `dlls/` | `libeay32.dll`, `ssleay32.dll` |
| Documentação | `Documentation/` | Fundamentos, Arquitetura, RNs |

**Produção canônica:**
`app/backend-delphi/src/Infrastructure/Integrations/ActiveDirectory/Infrastructure.Integrations.ActiveDirectory.ServiceLDAP.pas`

**Sandbox:** `app/modules/ActiveDirectoryORM/` — apenas referência
