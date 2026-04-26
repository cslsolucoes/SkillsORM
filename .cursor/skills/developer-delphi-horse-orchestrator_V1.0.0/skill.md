---
name: developer-delphi-horse-orchestrator
description: Orquestrador da família Horse para Delphi/FPC. Ponto de entrada único para Horse (servidor HTTP), middlewares (CORS, JWT, log, compressão, ETag, paginação, octet-stream, basic-auth, exception handling, ClientIP), segurança JWT/JOSE/Swagger, cliente HTTP RESTRequest4Delphi e serialização JSON↔DataSet. Classifica e roteia para a skill especializada correcta.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-horse-orchestrator

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Ponto de entrada único para o ecossistema **Horse** (servidor HTTP Express-like para Delphi/Lazarus FPC) e todos os pacotes complementares. Analisa o contexto e roteia para a skill especializada adequada — não resolve problemas directamente.

## Triggers (palavras-chave que activam este orquestrador)

`Horse`, `THorse`, `THorseRequest`, `THorseResponse`, `THorseCallback`,
`HorseJWT`, `THorseJWTConfig`, `HorseCORS`, `HorseCORSConfig`,
`Compression()`, `TCompressionType`,
`HandleException`, `EHorseException`,
`HorseBasicAuthentication`, `THorseBasicAuthenticationConfig`,
`Paginate`, `gpoDoNotIncludeSummary`, `X-Paginate`,
`OctetStream`, `TFileReturn`,
`eTag`, `If-None-Match`, `ETag`,
`THorseExceptionLogger`,
`THorseLoggerManager`, `HorseCallback`, `RegisterProvider`,
`THorseLoggerProviderConsole`, `THorseLoggerConsoleConfig`,
`THorseLoggerProviderLogFile`, `THorseLoggerLogFileConfig`,
`ClientIP`, `CF-Connecting-IP`, `X-Forwarded-For`, `X-Real-IP`,
`TJWT`, `TJOSE`, `TJWTClaims`, `TJOSEConsumerBuilder`,
`HorseSwagger`, `Swagger.Info`, `Swagger.Path`,
`TRequest`, `IRequest`, `IResponse`, `RESTRequest4Delphi`,
`TCSVAdapterRESTRequest4D`, `TDataSetSerializeAdapter`,
`ToJSONArray`, `ToJSONObject`, `LoadFromJSON`, `TDataSetSerializeConfig`,
`REST API Delphi`, `servidor HTTP Delphi`, `middleware Horse`,
`delphi-jose-jwt`, `gbSwagger`, `DataSet.Serialize`

---

## Matriz de roteamento

| Cenário / Pedido | Skill destino |
| --- | --- |
| Configurar servidor Horse, rotas GET/POST/PUT/DELETE, request/response, grupos | `developer-delphi-to-fpc-horse-core_V1.0.0` |
| Tratar exceções HTTP, `EHorseException`, callback de intercepção | `developer-delphi-to-fpc-horse-handle-exception_V1.0.0` |
| Autenticação HTTP Basic (`Authorization: Basic …`) | `developer-delphi-to-fpc-horse-basic-auth_V1.0.0` |
| Compressão GZIP/DEFLATE de respostas (`Accept-Encoding`) | `developer-delphi-to-fpc-horse-compression_V1.0.0` |
| CORS, preflight OPTIONS, origens permitidas, credenciais | `developer-delphi-to-fpc-horse-cors_V1.0.0` |
| Cache HTTP, ETag, `If-None-Match`, 304 Not Modified | `developer-delphi-to-fpc-horse-etag_V1.0.0` |
| Log de excepções em disco (ficheiro), auditoria de erros | `developer-delphi-to-fpc-horse-exception-logger_V1.0.0` |
| Autenticação JWT Bearer em rotas Horse, validar token, claims no request | `developer-delphi-to-fpc-horse-jwt_V1.0.0` |
| Infraestrutura de log — `THorseLoggerManager`, registar providers, formato | `developer-delphi-to-fpc-horse-logger_V1.0.0` |
| Provider de log para console/stdout (desenvolvimento) | `developer-delphi-to-fpc-horse-logger-console_V1.0.0` |
| Provider de log para ficheiro com rotação diária (produção) | `developer-delphi-to-fpc-horse-logger-logfile_V1.0.0` |
| Download/upload de ficheiros binários, `TStream`, `TFileReturn` | `developer-delphi-to-fpc-horse-octet-stream_V1.0.0` |
| Paginar listas JSON, `X-Paginate`, `limit`/`page`, summary wrapper | `developer-delphi-to-fpc-horse-paginate_V1.0.0` |
| Extrair IP real do cliente (proxy, Cloudflare, Nginx) | `developer-delphi-to-fpc-horse-clientip_V1.0.0` |
| JWT/JOSE base — gerar token, validar, `TJWT`, `TJOSE`, `TJWTClaims`; Swagger OpenAPI | `developer-delphi-to-fpc-horse-security_V1.0.0` |
| Consumir REST APIs externas, `TRequest`, HTTP client fluente, adapters CSV/DataSet | `developer-delphi-to-fpc-http-client-rest_V1.0.0` |
| Serializar DataSet↔JSON, `ToJSONArray`, `LoadFromJSON`, master-detail | `developer-delphi-to-fpc-dataset-serialize_V1.0.0` |

---

## Diagrama de decisão

```
Pedido relacionado com Horse / REST API Delphi?
│
├─► Servidor / rotas / request-response?
│   └─► horse-core
│
├─► Middleware de segurança?
│   ├─► JWT Bearer (validar token em rotas) → horse-jwt
│   ├─► Basic Auth (user:pass base64) → horse-basic-auth
│   ├─► CORS (origens, preflight) → horse-cors
│   └─► Gerar/assinar token JOSE, Swagger docs → horse-security
│
├─► Middleware de logging?
│   ├─► Infraestrutura de log (THorseLoggerManager) → horse-logger
│   ├─► Provider console (desenvolvimento) → horse-logger-console
│   ├─► Provider ficheiro (produção) → horse-logger-logfile
│   └─► Log de excepções em disco → horse-exception-logger
│
├─► Middleware de resposta/optimização?
│   ├─► Compressão GZIP/DEFLATE → horse-compression
│   ├─► ETag / cache 304 → horse-etag
│   ├─► Paginação JSON → horse-paginate
│   └─► Download/upload binário → horse-octet-stream
│
├─► Tratamento de erros HTTP (EHorseException) → horse-handle-exception
│
├─► Extrair IP real do cliente → horse-clientip
│
├─► Consumir APIs REST externas (HTTP client) → horse-client
│
└─► Serializar DataSet↔JSON → horse-serialization
```

---

## Ordem recomendada de middleware

```delphi
THorse
  .Use(Compression)            // 1. Compressão (primeiro — antes de qualquer conteúdo)
  .Use(HorseCORS)              // 2. CORS (antes de auth)
  .Use(Jhonson)                // 3. JSON body parser
  .Use(HandleException)        // 4. Excepções HTTP
  .Use(THorseExceptionLogger.New) // 5. Log de excepções
  .Use(HorseJWT(Secret))       // 6. Autenticação JWT
  .Use(THorseLoggerManager.HorseCallback) // 7. Access log (último middleware)
  .Use(eTag);                  // 8. ETag (depois do corpo estar definido)
```

---

## Notas GestorERP

- Infraestrutura externa (synapse, TProcess) tratada em sessão separada
- Verificar compatibilidade Delphi + FPC em todos os middlewares antes de adoptar
- Para ambientes com proxy/Cloudflare: combinar `horse-cors` + `horse-clientip` + `horse-jwt`
- JWT: `horse-jwt` (middleware de validação) usa `horse-security` (TJOSE, geração de token)

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — orquestrador da família Horse.
