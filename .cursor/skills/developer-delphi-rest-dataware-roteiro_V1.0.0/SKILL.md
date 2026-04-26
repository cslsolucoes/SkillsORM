---
name: developer-delphi-rest-dataware-roteiro
description: Roteiros práticos de uso do framework REST DataWare (RDW) V2.1 — configurar servidor REST (Indy/SSL/pooling), consultas com TRESTDWClientSQL/TRESTDWTable, autenticação JWT/Basic/OAuth2, operações em lote com MassiveCache, seleção e configuração de drivers de banco. Exemplos Pascal completos por operação.
model: haiku
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-rest-dataware-roteiro

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Roteiros práticos de uso do framework REST DataWare V2.1 com exemplos Pascal completos por operação. Não cobre arquitetura ou estrutura de arquivos — ver `developer-delphi-rest-dataware-expert` e `developer-delphi-rest-dataware-estrutura`.

## When to use

- Configurar servidor REST com Indy, SSL e pooling
- Implementar cliente REST com TRESTDWClientSQL ou TRESTDWTable
- Autenticar usuários com JWT, Basic Auth, AccessTag ou OAuth2
- Enviar operações em lote com TRESTDWMassiveCache
- Selecionar e configurar driver de banco (FireDAC, Zeos, SQLdb, etc.)

## When NOT to use

- Arquitetura e APIs → `developer-delphi-rest-dataware-expert`
- Localizar arquivos → `developer-delphi-rest-dataware-estrutura`

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `developer-delphi-rest-dataware-expert` | Para conhecer componentes e exceções antes de codificar |

## Documentos canônicos

| Documento | Conteúdo |
| --- | --- |
| `app/modules/REST-DataWare/Documentation/Arquitetura/Arquitetura_RESTDataWare_V2.1.md` | Visão geral das 5 camadas |
| `app/modules/REST-DataWare/Documentation/Analise/Basic/RESTDWClientSQL.md` | API TRESTDWClientSQL |
| `app/modules/REST-DataWare/Documentation/Analise/Basic/RESTDWPoolerDB.md` | API TRESTDWPoolerDB |
| `app/modules/REST-DataWare/Documentation/Analise/Basic/RESTDWMassiveCache.md` | MassiveCache API |
| `app/modules/REST-DataWare/Documentation/Analise/Mechanics/RESTDWAuthenticators.md` | Autenticação JWT/OAuth2 |
| `app/modules/REST-DataWare/Documentation/Analise/Database_Drivers/RESTDWDriverBase.md` | Abstração de driver |
| `app/modules/REST-DataWare/Documentation/Regras de Negocio/` | 25 RNs nos módulos M00–M04 |

## Roteiros disponíveis

| Roteiro | Arquivo | Operações cobertas |
| --- | --- | --- |
| Servidor | `exemplos/roteiro_server.md` | TRESTDWIdBase, porta, SSL, pooling (TRESTDWPoolerDB), eventos, rotas |
| Cliente | `exemplos/roteiro_client.md` | TRESTDWClientSQL (SQL/Params/Open), TRESTDWTable (CRUD), ApplyUpdates |
| Autenticação | `exemplos/roteiro_auth.md` | JWT (NewToken/Bearer/RenewToken), Basic, AccessTag, OAuth2 4 passos |
| MassiveCache | `exemplos/roteiro_massive.md` | Acumular INSERT/UPDATE/DELETE, enviar batch, TMassiveBuffer |
| Drivers | `exemplos/roteiro_drivers.md` | Selecionar driver, configurar FireDAC/Zeos/SQLdb, diretivas uRESTDW.inc |

## Referência rápida — operações

| Operação | Componente | Roteiro |
| --- | --- | --- |
| Iniciar servidor REST | `TRESTDWIdBase` + `TRESTDWPoolerDB` | roteiro_server |
| Consulta SQL | `TRESTDWClientSQL.SQL + Open` | roteiro_client |
| Consulta de tabela | `TRESTDWTable.TableName + Open` | roteiro_client |
| Autenticar com JWT | Endpoint `/newtoken` + `Authorization: Bearer` | roteiro_auth |
| Batch DML | `TRESTDWMassiveCache.ApplyUpdates` | roteiro_massive |
| Selecionar driver | Diretiva em `uRESTDW.inc` | roteiro_drivers |

## Anti-padrões

| Anti-padrão | Como corrigir |
| --- | --- |
| Loop de ApplyUpdates linha a linha | Usar TRESTDWMassiveCache para batch único |
| Referenciar TRESTDWIdBase no código de negócio | Isolar criação de servidor no setup; abstrair interface |
| Hardcodar driver no código de negócio | Usar diretivas em uRESTDW.inc; código usa TRESTDWDrvQuery |
| HTTP sem SSL em produção | Configurar certificado + HTTPS antes de deploy |

---

## Changelog (este arquivo)

- 1.0.0 (11/04/2026): Criação — skill roteiro da família developer-delphi-rest-dataware-*.
