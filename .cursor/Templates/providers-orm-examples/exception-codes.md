# ProvidersORM — Exception codes canónicos

<!-- FileVersion: 1.0.0 · Data: 17/04/2026 -->

Tabela de códigos de excepção usados pela hierarquia `E{ORM}Exception` do framework ProvidersORM. Aplica-se a qualquer projeto que consuma o ORM.

## Hierarquia

```
Exception
└── EProvidersException (base)
    ├── EConnectionException       (40001–40019)
    ├── EDatabaseException         (40020–40099)
    ├── EEntityManagerException    (40100–40199)
    ├── EQueryBuilderException     (40200–40299)
    ├── EParametersException       (40300–40399)
    ├── ELoggersException          (40400–40499)
    └── EPoolConnectionsException  (40500–40599)
```

## EConnectionException (40001–40019)

| Código | Constante | Descrição |
|---|---|---|
| 40001 | `EC_INVALID_HOST` | Host vazio ou não resolvido |
| 40002 | `EC_INVALID_PORT` | Porto inválido (fora do range 1–65535) |
| 40003 | `EC_INVALID_DATABASE` | Nome de database vazio |
| 40004 | `EC_INVALID_USER` | User vazio |
| 40005 | `EC_INVALID_PASSWORD` | Password vazia (apenas se engine exige) |
| 40006 | `EC_CONNECTION_FAILED` | Falha ao conectar (TCP/engine) |
| 40007 | `EC_ALREADY_CONNECTED` | Tentativa de conectar com ligação activa |
| 40008 | `EC_NOT_CONNECTED` | Operação em ligação fechada |
| 40009 | `EC_DISCONNECT_FAILED` | Falha ao desligar (transação pendente) |
| 40010 | `EC_QUERY_FAILED` | Erro ao executar query |
| 40011 | `EC_COMMAND_FAILED` | Erro ao executar comando (INSERT/UPDATE/DELETE) |
| 40012 | `EC_TRANSACTION_FAILED` | Erro em begin/commit/rollback |
| 40013 | `EC_ENGINE_NOT_SUPPORTED` | Engine inválido (verificar `USE_*` directives) |
| 40014 | `EC_DATABASE_NOT_SUPPORTED` | Tipo de banco não reconhecido |
| 40015 | `EC_EVENT_HANDLER_ERROR` | Erro dentro de `OnBefore*`/`OnAfter*` |
| 40016 | `EC_FROMCONFIG_FAILED` | Falha em `FromConfig`/`FromIni`/`FromJSON` |
| 40017 | `EC_FROMPARAMETERS_FAILED` | Falha em `FromParameters` (requer `USE_PARAMENTERS`) |
| 40018 | `EC_POOL_UNAVAILABLE` | Pool esgotado ou não inicializado |
| 40019 | `EC_RESERVED` | Reservado para expansão |

## Uso típico

```pascal
try
  LConn.Connect;
except
  on E: EConnectionException do
    if E.Code = EC_CONNECTION_FAILED then
      LogRetry(E.Message)
    else
      raise;
end;
```

## Instalação canónica

- **Path do framework:** `.cursor/config.json._frameworks.providersORM.installPath` (default `E:/CSL/ProvidersORM`).
- **Ficheiro:** `<ORM_ROOT>/src/Commons/Providers.Commons.Exceptions.pas`.

## Changelog

- 1.0.0 (17/04/2026): criação — extraído de `developer-delphi-agent-connections-expert` / `developer-delphi-agent-exceptions-expert` na Onda 4.
