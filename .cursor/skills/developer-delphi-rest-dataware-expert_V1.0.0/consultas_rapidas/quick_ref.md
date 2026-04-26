---
description: "Referência rápida — arquitetura e APIs do REST DataWare"
alwaysApply: false
---

# Quick Reference — developer-delphi-rest-dataware-expert

## Exceções — hierarquia

| Classe | Quando é lançada |
| --- | --- |
| `eRESTDWException` | Base de todas as exceções RDW |
| `eRESTDWSocketException` | Erro de socket/rede |
| `eRESTDWTimeoutException` | Timeout de conexão ou operação |
| `eRESTDWAuthException` | Falha de autenticação |
| `eRESTDWDriverException` | Erro no driver de banco |
| `eRESTDWQueryException` | Erro de SQL/query |
| `eRESTDWPoolException` | Erro no pool de conexões |
| `eRESTDWSerializationException` | Erro de serialização JSON |
| `eRESTDWConfigException` | Configuração inválida |
| `eRESTDWSecurityException` | Violação de segurança/permissão |

## Transportes × Diretiva

| Transporte | Diretiva |
| --- | --- |
| Indy (padrão) | (nenhuma — padrão) |
| ICS | `{$DEFINE RESTDWINDYICS}` |
| FpHttp | `{$DEFINE RESTDWFPHTTPCLIENT}` |
| LAMW Android | `{$DEFINE RESTDWLAMWHTTPCLIENT}` |

## Drivers × Diretiva

| Driver | Diretiva |
| --- | --- |
| FireDAC | `{$DEFINE RESTDWFIREDAC}` |
| Zeos | `{$DEFINE RESTDWZEOS}` |
| UniDAC | `{$DEFINE RESTDWUNIDAC}` |
| Lazarus SQLdb | `{$DEFINE RESTDWSQLDB}` |
| IBDAC | `{$DEFINE RESTDWIBDAC}` |

## Segurança — modos

| Modo | `AuthorizationMode` |
| --- | --- |
| Basic | `amBasic` |
| AccessTag | `amAccessTag` |
| JWT Bearer | `amJWT` |
| OAuth2 | fluxo 4 passos via TCripto |
