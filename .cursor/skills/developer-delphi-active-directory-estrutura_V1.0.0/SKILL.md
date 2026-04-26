---
name: developer-delphi-active-directory-estrutura
description: Mapa de arquivos e camadas do módulo ActiveDirectoryORM — onde ficam IActiveDirectoryConnection, TActiveDirectoryService, TLDAPConfig, TActiveDirectoryHelper, exceções EAD*, views de teste, DLLs OpenSSL e localização canônica de produção em backend-delphi.
model: haiku
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

> **Path resolution:** o path real de `{ACTIVE_DIRECTORY_ORM_ROOT}` é lido de `.cursor/config.json._frameworks.activeDirectoryORM.installPath` (default `E:/CSL/ActiveDirectoryORM`). Override local opcional em `.workspace/context.json._frameworks_overrides.activeDirectoryORM`.

# developer-delphi-active-directory-estrutura

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Mapa de arquivos e camadas do módulo ActiveDirectoryORM. Responde onde fica cada unit, o que cada pasta contém e qual é a localização canônica de produção. Não cobre APIs, exemplos de código ou convenções arquiteturais — ver `developer-delphi-active-directory-expert`.

## When to use

- Precisar saber em qual arquivo/pasta fica `IActiveDirectoryConnection`, `TLDAPConfig`, etc.
- Verificar se um arquivo deve ser criado em `Core/`, `Commons/` ou `Views/`
- Identificar onde estão as DLLs de dependência (OpenSSL)
- Confirmar o path de produção canônico em `backend-delphi`

## When NOT to use

- APIs e interfaces → `developer-delphi-active-directory-expert`
- Exemplos de código → `developer-delphi-active-directory-roteiro`

## Mapa de pastas

```
{ACTIVE_DIRECTORY_ORM_ROOT}/         ← Sandbox de referência
├── ActiveDirectoryORM.dpr              ← Projeto Delphi
├── ActiveDirectoryORM.dproj
├── ORM.Defines.inc                     ← Diretivas (USE_LDAP)
├── CLAUDE.md
├── CHANGELOG.md
├── README.md
├── src/
│   ├── ActiveDirectory.Service.pas     ← TActiveDirectoryService (USE_LDAP obrigatório)
│   ├── Core/
│   │   ├── ActiveDirectory.Main.Interfaces.pas  ← IActiveDirectoryConnection
│   │   └── ActiveDirectory.Main.pas             ← TActiveDirectoryConnection, TActiveDirectory
│   ├── Commons/
│   │   ├── ActiveDirectory.Types.pas       ← TLDAPConfig record, TLDAPEntry
│   │   ├── ActiveDirectory.Consts.pas      ← constantes: portas, objectClass, atributos, ERR_LDAP_BASE
│   │   ├── ActiveDirectory.Exceptions.pas  ← hierarquia EAD* (40000-40006)
│   │   ├── ActiveDirectory.Helpers.pas     ← TActiveDirectoryHelper
│   │   └── ActiveDirectory.Attributers.pas ← atributos LDAP adicionais
│   └── Views/
│       ├── ufrmActiveDirectoryTeste.pas    ← Form de teste (sempre disponível)
│       ├── ufrmActiveDirectoryTeste.dfm
│       ├── ufrmLDAP_Teste.pas              ← Form de teste LDAP (USE_LDAP only)
│       └── ufrmLDAP_Teste.dfm
├── Exemplo/                             ← Projeto standalone referência (Synapse direto)
│   └── src/                             ← Equivalência mapeada em Documentation/Mapeamento/
├── dlls/
│   ├── libeay32.dll                    ← OpenSSL — obrigatório para LDAPS (UseSSL=True)
│   └── ssleay32.dll                    ← OpenSSL — obrigatório para LDAPS (UseSSL=True)
└── Documentation/                       ← Docs canônicos do módulo
    ├── Fundamentos/                     ← API, exemplos, commons
    ├── Arquitetura/                     ← ADRs e diagrama de camadas
    ├── Estrutura/                       ← Mapa de repositório
    └── Regras de Negocio/               ← RN-AD-01, RN-AD-02, RN-AD-03
```

## Tabela camada → path

| Camada | Path relativo | Conteúdo |
| --- | --- | --- |
| Factory | `src/Main/ActiveDirectory.Main.pas` | `TActiveDirectory.New` |
| Interface fluent | `src/Main/ActiveDirectory.Main.Interfaces.pas` | `IActiveDirectoryConnection` |
| Implementação builder | `src/Main/ActiveDirectory.Main.pas` | `TActiveDirectoryConnection` |
| Serviço LDAP | `src/ActiveDirectory.Service.pas` | `TActiveDirectoryService` (USE_LDAP) |
| Tipos/Record | `src/Commons/ActiveDirectory.Types.pas` | `TLDAPConfig`, `TLDAPEntry` |
| Constantes | `src/Commons/ActiveDirectory.Consts.pas` | Portas, objectClass, atributos, ERR_LDAP_BASE |
| Exceções | `src/Commons/ActiveDirectory.Exceptions.pas` | Hierarquia EAD* |
| Helpers | `src/Commons/ActiveDirectory.Helpers.pas` | `TActiveDirectoryHelper` |
| Views de teste | `src/Views/` | `ufrmActiveDirectoryTeste`, `ufrmLDAP_Teste` |
| DLLs externas | `dlls/` | libeay32.dll, ssleay32.dll (LDAPS) |

## Localização canônica de produção

O módulo `{ACTIVE_DIRECTORY_ORM_ROOT}/` é um **sandbox de referência**. O código de produção está em:

```
{BACKEND_ROOT}/src/Infrastructure/Integrations/ActiveDirectory/
└── Infrastructure.Integrations.ActiveDirectory.ServiceLDAP.pas
```

Ao implementar ou ajustar integração AD no app consumidor, editar o arquivo de produção, não o sandbox.

## Convenções de nomenclatura

| Tipo | Prefixo | Exemplos |
| --- | --- | --- |
| Interfaces | `I*` | `IActiveDirectoryConnection` |
| Classes | `T*` | `TActiveDirectory`, `TActiveDirectoryService` |
| Exceções | `EAD*` | `EADException`, `EADValidationException` |
| Views (forms) | `ufrm*` | `ufrmActiveDirectoryTeste` |
| Documentação | `{Tipo}_{Projeto}_V{X.Y}.md` | `Arquitetura_ActiveDirectoryORM_V1.0.md` |

## Anti-padrões

| Anti-padrão | Como corrigir |
| --- | --- |
| Editar código em `{ACTIVE_DIRECTORY_ORM_ROOT}/` para produção | Editar `{BACKEND_ROOT}/src/Infrastructure/Integrations/ActiveDirectory/` |
| Referenciar DLLs OpenSSL por path absoluto | Colocar `libeay32.dll`/`ssleay32.dll` no mesmo diretório do executável ou no PATH |
| Lógica de negócio em `src/Views/` | Views são apenas para teste; lógica pertence a Service ou Core |

---

## Changelog (este arquivo)

- 1.0.1 (17/04/2026): Onda 5 do refactor — paths hardcoded substituidos por placeholders `{ACTIVE_DIRECTORY_ORM_ROOT}` / `{REST_DATAWARE_ROOT}` resolvidos via `.cursor/config.json._frameworks`.

- 1.0.0 (12/04/2026): Criação — skill estrutura da família developer-delphi-active-directory-*.
