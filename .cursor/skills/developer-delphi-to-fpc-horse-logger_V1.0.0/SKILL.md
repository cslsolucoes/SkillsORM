---
name: developer-delphi-to-fpc-horse-logger
description: Infraestrutura de logging por providers para Horse. Cobre THorseLoggerManager (RegisterProvider, HorseCallback), contrato de provider, variáveis de formato (${time}, ${request_clientip}, ${response_status}, ${response_time}, etc.) e padrão de múltiplos providers simultâneos. Fonte: app/package/docs/pacotes/horse-logger.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-logger_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Infraestrutura de logging plugável para Horse: define o contrato de provider e a gestão de providers de output. Providers concretos em skills separadas.

## When to use

- Configurar infraestrutura de log no pipeline Horse
- Registar um ou mais providers de output
- Entender as variáveis de formato disponíveis
- Criar provider custom de log

## When NOT to use

- Log em console → `developer-delphi-to-fpc-horse-logger-console`
- Log em ficheiro → `developer-delphi-to-fpc-horse-logger-logfile`
- Log de exceções → `developer-delphi-to-fpc-horse-exception-logger`

## Documento canônico

`app/package/docs/pacotes/horse-logger.md`

---

## THorseLoggerManager — gestão de providers

| Método | Descrição |
| --- | --- |
| `RegisterProvider(provider)` | Adiciona provider de output |
| `HorseCallback` | Middleware Horse (entry point) |

---

## Variáveis de formato

| Variável | Conteúdo |
| --- | --- |
| `${time}` | Data/hora do pedido |
| `${request_clientip}` | IP do cliente |
| `${request_method}` | GET, POST… |
| `${request_path_info}` | /api/users |
| `${request_version}` | HTTP/1.1 |
| `${request_id}` | ID de correlação (se disponível) |
| `${response_status}` | 200, 404, 500… |
| `${response_time}` | Tempo de resposta em ms |
| `${response_content_length}` | Bytes enviados |

---

## Exemplos

### Provider único (console)

```delphi
uses Horse, Horse.Logger, Horse.Logger.Provider.Console;

begin
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New()
  );
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Listen(9000);
end.
```

### Múltiplos providers (console + ficheiro)

```delphi
uses
  Horse, Horse.Logger,
  Horse.Logger.Provider.Console,
  Horse.Logger.Provider.LogFile;

begin
  // Provider 1: consola (desenvolvimento)
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New()
  );
  // Provider 2: ficheiro (produção)
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderLogFile.New(
      THorseLoggerLogFileConfig.New
        .SetLogDir(ExtractFilePath(ParamStr(0)) + 'logs')
    )
  );

  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Listen(9000);
end.
```

### Formato nginx-like

```delphi
const LOG_FORMAT =
  '${request_clientip} - [${time}] "${request_method} ${request_path_info} ' +
  '${request_version}" ${response_status} ${response_content_length}';

THorseLoggerManager.RegisterProvider(
  THorseLoggerProviderLogFile.New(
    THorseLoggerLogFileConfig.New.SetLogFormat(LOG_FORMAT)
  )
);
```

---

## Ordem no pipeline

Logger deve ser registado após os outros middlewares (ultimo a executar):

```delphi
THorse
  .Use(Compression())
  .Use(CORS)
  .Use(Jhonson)
  .Use(HandleException)
  .Use(THorseExceptionLogger.New())
  .Use(THorseLoggerManager.HorseCallback); // por último
```

---

## Arquitectura de providers

```
THorse request
    ↓
THorseLoggerManager.HorseCallback (middleware)
    ↓
Formata linha de log com variáveis ${...}
    ↓
Distribui para TODOS os RegisterProvider registados
    ↓
Provider Console → stdout
Provider LogFile → disco
Provider Custom → destino próprio
```

---

## Notas GestorERP

- Providers activos: console (dev), logfile (staging/prod)
- Formato padrão adoptado: `'${request_clientip} [${time}] ${request_method} ${request_path_info} ${response_status} ${response_time}ms'`
- `units` a usar: `Horse.Logger`, `Horse.Logger.Manager`, `Horse.Logger.Provider.Contract`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill infraestrutura de logging.
