---
name: developer-delphi-active-directory-orchestrator
description: Ponto de entrada para as skills de integração LDAP/Active Directory em Delphi. Use quando o usuário mencionar Active Directory, LDAP, TActiveDirectory, IActiveDirectoryService, autenticação de usuário no AD, USE_LDAP, Synapse, ldapsend. Coordena as 3 skills da família developer-delphi-active-directory-*.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-active-directory-orchestrator

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Ponto de entrada para qualquer consulta sobre o módulo ActiveDirectoryORM — integração LDAP/Active Directory para apps Delphi consumidores. Esta skill não executa diretamente — seleciona a skill especialista correta da família `developer-delphi-active-directory-*`.

## When to use

- "Active Directory", "LDAP", "ldapsend", "ldapsend.pas"
- "autenticar usuário no AD", "authentication via AD"
- "TActiveDirectory", "IActiveDirectoryConnection", "IActiveDirectoryService"
- "TActiveDirectoryHelper", "TLDAPConfig", "EADException"
- "USE_LDAP", "LDAPS", "SSL porta 636"
- "buscar usuário no AD", "grupos do AD", "modificar atributos LDAP"
- "Synapse LDAP", "OpenSSL LDAPS"

## When NOT to use

- Documentação técnica ou geração de docs → `documentation-master-orchestrator`
- Convenções ProvidersORM (conexão SQL, ORM, pool) → `project-master-orchestrator`
- Delphi genérico (linguagem, RTL, patterns) → `developer-delphi-master-orchestrator`
- Módulo REST-DataWare → `developer-delphi-rest-dataware-orchestrator`

## Skills coordenadas (3)

| Skill | Responsabilidade | Quando invocar |
| --- | --- | --- |
| `developer-delphi-active-directory-expert` | Arquitetura, interfaces, exceções, constantes, helpers, ADRs | Antes de implementar qualquer código de integração AD |
| `developer-delphi-active-directory-roteiro` | Roteiros práticos: config, auth, queries, write operations | Ao implementar um fluxo específico de uso do AD |
| `developer-delphi-active-directory-estrutura` | Mapa de arquivos, camadas, localização de units | Ao precisar saber onde fica cada unit ou camada |

## Matriz de decisão

| Cenário | Skill |
| --- | --- |
| Qual interface usar para configurar conexão LDAP? | `developer-delphi-active-directory-expert` |
| Como autenticar usuário via sAMAccountName? | `developer-delphi-active-directory-roteiro` |
| Onde fica TActiveDirectoryHelper no repositório? | `developer-delphi-active-directory-estrutura` |
| Quais exceções EAD* podem ser lançadas? | `developer-delphi-active-directory-expert` |
| Como modificar atributos de um objeto AD? | `developer-delphi-active-directory-roteiro` |
| Qual diretiva ativa TActiveDirectoryService? | `developer-delphi-active-directory-expert` |

## Sequência canônica para novo código AD

```
1. developer-delphi-active-directory-expert    ← interfaces, exceções, padrões
2. developer-delphi-active-directory-estrutura ← onde criar os arquivos
3. developer-delphi-active-directory-roteiro   ← exemplos de implementação
```

## Anti-padrões

| Anti-padrão | Como corrigir |
| --- | --- |
| Usar port 389/636 hardcoded | Usar constantes LDAP_PORT_DEFAULT / LDAPS_PORT_DEFAULT |
| Acessar units internas de Commons em Views | Acessar apenas via IActiveDirectoryConnection/IActiveDirectoryService |
| ChangePassword sem UseSSL=True | Consultar RN-AD-02 antes de implementar |

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — orchestrator da família developer-delphi-active-directory-* (3 skills).