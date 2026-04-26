---
name: developer-delphi-rest-dataware-orchestrator
description: Ponto de entrada para a família developer-delphi-rest-dataware-*. Classifica demandas de REST DataWare (RDW) e delega para expert (arquitetura/APIs), roteiro (exemplos práticos) ou estrutura (localização de arquivos). Triggers: REST DataWare, RDW, TRESTDWClientSQL, TRESTDWPoolerDB, MassiveCache, uRESTDW.inc, REST server Delphi.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-rest-dataware-orchestrator

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Ponto de entrada para a família `developer-delphi-rest-dataware-*`. Classifica a demanda e delega para a skill correta. Não contém lógica de implementação.

## When to use

- Qualquer menção a **REST DataWare**, **RDW**, **REST-DataWare**
- Componentes: `TRESTDWClientSQL`, `TRESTDWTable`, `TRESTDWPoolerDB`, `TRESTDWMassiveCache`, `TRESTDWIdBase`, `TRESTDWJSONValue`
- Configuração ou dúvidas sobre `uRESTDW.inc` e diretivas de compilação
- Criar servidor REST com Delphi ou Lazarus/FPC
- Autenticação JWT, Bearer, AccessTag, OAuth2 no contexto RDW
- Selecionar driver de banco (FireDAC, Zeos, UniDAC, SQLdb, etc.)

## When NOT to use

- ProvidersORM genérico → `project-master-orchestrator`
- Delphi/FPC sem contexto RDW → `developer-delphi-master-orchestrator`
- Active Directory / LDAP → `developer-delphi-active-directory-orchestrator`

## Skills coordenadas

| Skill | Responsabilidade |
| --- | --- |
| `developer-delphi-rest-dataware-expert` | Arquitetura (5 camadas), APIs, componentes, exceções, diretivas, ADRs |
| `developer-delphi-rest-dataware-roteiro` | Exemplos Pascal: server, client, auth, MassiveCache, drivers |
| `developer-delphi-rest-dataware-estrutura` | Localização de arquivos, mapa de pastas, ordem de compilação |

## Matriz de decisão

| Cenário | Skill |
| --- | --- |
| "Como funciona o REST DataWare? Qual a arquitetura?" | `expert` |
| "Quais componentes existem? Como funciona MassiveCache?" | `expert` |
| "Como configurar o servidor REST com Indy?" | `roteiro` (roteiro_server) |
| "Como fazer consulta com TRESTDWClientSQL?" | `roteiro` (roteiro_client) |
| "Como autenticar com JWT?" | `roteiro` (roteiro_auth) |
| "Onde fica o arquivo uRESTDW.inc?" | `estrutura` |
| "Como selecionar o driver FireDAC vs. Zeos?" | `roteiro` (roteiro_drivers) |
| "Qual a ordem de compilação dos pacotes?" | `estrutura` |

## Sequência canônica

```
developer-delphi-rest-dataware-expert
    ↓
developer-delphi-rest-dataware-estrutura
    ↓
developer-delphi-rest-dataware-roteiro
```

## Visão geral da arquitetura (5 camadas)

```
┌─────────────────────────────────────────────────────┐
│  TRANSPORT          Indy · ICS · FpHttp · LAMW      │
│  (HTTP/HTTPS)       HttpDef (interno)               │
├─────────────────────────────────────────────────────┤
│  CORE + BASIC       ClientSQL · Table · StoredProc  │
│                     PoolerDB · JSONValue · Params   │
├─────────────────────────────────────────────────────┤
│  DATABASE           TRESTDWDriverBase + 9 drivers   │
│  DRIVERS            FireDAC · Zeos · UniDAC · ...   │
├─────────────────────────────────────────────────────┤
│  UTILS / SECURITY   TCripto (AES-256) · JWT · OAuth │
│                     MassiveCache · ShellTools       │
├─────────────────────────────────────────────────────┤
│  PLUGINS            Wizards · Packages extras       │
└─────────────────────────────────────────────────────┘
```

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criação — orchestrator da família developer-delphi-rest-dataware-*.