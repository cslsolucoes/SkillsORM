---
description: "Referência rápida — família developer-delphi-active-directory-*"
alwaysApply: false
---

# Quick Reference — developer-delphi-active-directory-orchestrator

| Skill | Quando usar |
| --- | --- |
| `developer-delphi-active-directory-expert` | arquitetura, IActiveDirectoryConnection/Service, exceções EAD*, constantes, TActiveDirectoryHelper, ADRs |
| `developer-delphi-active-directory-roteiro` | exemplos Pascal: config fluente, autenticação, queries, write operations, ChangePassword |
| `developer-delphi-active-directory-estrutura` | onde ficam as units no repo, mapa de camadas, localização canônica de produção |

**Sequência para novo código AD:**
`expert` → `estrutura` → `roteiro`

**Diretiva de ativação:** `{$DEFINE USE_LDAP}` em `ORM.Defines.inc`

**Portas:** LDAP=389 (`LDAP_PORT_DEFAULT`) · LDAPS=636 (`LDAPS_PORT_DEFAULT`)

**Factory:** `TActiveDirectory.New.Host(...).BaseDN(...).GetConfig`
