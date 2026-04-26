---
name: developer-delphi-active-directory-roteiro
description: Roteiros práticos de uso do módulo ActiveDirectoryORM — configuração fluente (LDAP/LDAPS, OUs, JSON/TStringList), autenticação (Authenticate/AuthenticateUser/TestConnection), consultas (SearchObjects, ListGroups, GetGroupMembers), operações de escrita (SetAttributeValue, AddObject, ChangePassword). Exemplos Pascal completos por operação.
model: haiku
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

> **Path resolution:** o path real de `{ACTIVE_DIRECTORY_ORM_ROOT}` é lido de `.cursor/config.json._frameworks.activeDirectoryORM.installPath` (default `E:/CSL/ActiveDirectoryORM`). Override local opcional em `.workspace/context.json._frameworks_overrides.activeDirectoryORM`.

# developer-delphi-active-directory-roteiro

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Roteiros práticos de uso do módulo ActiveDirectoryORM com exemplos Pascal completos por operação. Não cobre arquitetura, interfaces ou estrutura de arquivos — ver `developer-delphi-active-directory-expert` e `developer-delphi-active-directory-estrutura`.

## When to use

- Implementar configuração de conexão LDAP/LDAPS
- Autenticar usuário via Active Directory (por sAMAccountName, UPN, DN)
- Buscar objetos, usuários ou grupos no AD
- Modificar atributos de objetos AD
- Gerenciar membros de grupos
- Alterar senha de usuário via LDAPS

## When NOT to use

- Arquitetura e APIs → `developer-delphi-active-directory-expert`
- Localizar arquivos → `developer-delphi-active-directory-estrutura`

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `developer-delphi-active-directory-expert` | Para conhecer interfaces e exceções antes de codificar |

## Documentos canônicos

| Documento | Conteúdo |
| --- | --- |
| `{ACTIVE_DIRECTORY_ORM_ROOT}/Documentation/Fundamentos/02-Exemplos-Completos.md` | 10 exemplos de configuração completos |
| `{ACTIVE_DIRECTORY_ORM_ROOT}/Documentation/Regras de Negocio/RN-AD-01_Autenticacao_V1.0.md` | Regras de autenticação |
| `{ACTIVE_DIRECTORY_ORM_ROOT}/Documentation/Regras de Negocio/RN-AD-02_OperacoesEscrita_V1.0.md` | Regras de escrita |
| `{ACTIVE_DIRECTORY_ORM_ROOT}/Documentation/Regras de Negocio/RN-AD-03_Configuracao_V1.0.md` | Regras de configuração e validações |

## Roteiros disponíveis

| Roteiro | Arquivo | Operações cobertas |
| --- | --- | --- |
| Configuração | `exemplos/roteiro_config.md` | Fluent mínimo, SSL/LDAPS, múltiplas OUs, TStringList, JSON, reuso de config, constantes |
| Autenticação | `exemplos/roteiro_auth.md` | TestConnection, Authenticate, AuthenticateUser, LastError |
| Consultas | `exemplos/roteiro_queries.md` | SearchObjects, SearchWithCustomFilter, ListGroups, GetGroupMembers, GetObjectAttributes, ListContainerObjects |
| Escrita | `exemplos/roteiro_write.md` | SetAttributeValue, AddAttributeValue, DeleteAttributeValue, SetAttributes, AddObject, DeleteObject, RenameObject, AddMemberToGroup, RemoveMemberFromGroup, ChangePassword |

## Referência rápida — operações

| Operação | Método | Roteiro |
| --- | --- | --- |
| Conexão básica | `TActiveDirectory.New.Host(...).GetConfig` | roteiro_config |
| SSL/LDAPS | `.UseSSL(True)` — ajusta porta automaticamente | roteiro_config |
| Teste de conexão | `IActiveDirectoryService.TestConnection` | roteiro_auth |
| Auth por SAM/UPN | `Authenticate(Username, Password)` | roteiro_auth |
| Auth por DN | `AuthenticateUser(UserDN, Password)` | roteiro_auth |
| Busca com filtro | `SearchObjects(Filter, Attributes)` | roteiro_queries |
| Listar grupos | `ListGroups(SearchOUs)` | roteiro_queries |
| Membros de grupo | `GetGroupMembers(GroupDN)` | roteiro_queries |
| Modificar atributo | `SetAttributeValue(DN, Attr, Value)` | roteiro_write |
| Alterar senha | `ChangePassword(UserDN, Old, New)` — UseSSL obrigatório | roteiro_write |

## Anti-padrões

| Anti-padrão | Como corrigir |
| --- | --- |
| ChangePassword sem UseSSL=True | AD rejeita — usar configuração com UseSSL(True) antes de ChangePassword |
| Ignorar LastError após Authenticate | Sempre verificar LastError quando Authenticate retorna False |
| Criar TStringList para SearchOUs sem liberar | SearchOUs é responsabilidade do caller; usar try/finally para liberar |

---

## Changelog (este arquivo)

- 1.0.1 (17/04/2026): Onda 5 do refactor — paths hardcoded substituidos por placeholders `{ACTIVE_DIRECTORY_ORM_ROOT}` / `{REST_DATAWARE_ROOT}` resolvidos via `.cursor/config.json._frameworks`.

- 1.0.0 (12/04/2026): Criação — skill roteiro da família developer-delphi-active-directory-*.
