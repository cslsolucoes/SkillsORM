---
name: developer-delphi-to-fpc-horse-logger-console
description: Provider de log em console (stdout) para horse-logger. Cobre THorseLoggerProviderConsole (New, New(config)) e THorseLoggerConsoleConfig (SetLogFormat, GetLogFormat). Para uso em desenvolvimento. Fonte: app/package/docs/pacotes/horse-logger-provider-console.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-logger-console_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Provider de logging em console (stdout) para o horse-logger. Adequado para desenvolvimento.

## When to use

- Visualizar logs de acesso em desenvolvimento
- Debugging de middleware chain no terminal

## When NOT to use

- Produção (stdout polui logs do serviço) → `developer-delphi-to-fpc-horse-logger-logfile`
- Infraestrutura de logging → `developer-delphi-to-fpc-horse-logger`

## Documento canônico

`app/package/docs/pacotes/horse-logger-provider-console.md`

---

## THorseLoggerConsoleConfig — configuração

| Método | Descrição |
| --- | --- |
| `New` | Cria instância |
| `SetLogFormat(format)` | Define formato da linha de log |
| `GetLogFormat(out fmt)` | Lê formato atual |

## THorseLoggerProviderConsole — provider

| Método | Descrição |
| --- | --- |
| `New` | Provider com configuração padrão |
| `New(config)` | Provider com configuração custom |

---

## Exemplos

### Configuração padrão

```delphi
uses Horse, Horse.Logger, Horse.Logger.Provider.Console;

begin
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New()
  );
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);
  THorse.Listen(9000);
end;
```

### Formato personalizado

```delphi
THorseLoggerManager.RegisterProvider(
  THorseLoggerProviderConsole.New(
    THorseLoggerConsoleConfig.New
      .SetLogFormat(
        '${request_clientip} [${time}] ${request_method} ' +
        '${request_path_info} ${response_status}'
      )
  )
);
THorse.Use(THorseLoggerManager.HorseCallback);
THorse.Listen(9000);
```

### Lazarus / FPC

```delphi
{$MODE DELPHI}{$H+}
uses Horse, Horse.Logger, Horse.Logger.Provider.Console, SysUtils;

begin
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderConsole.New(
      THorseLoggerConsoleConfig.New
        .SetLogFormat('${request_clientip} [${time}] ${request_method} ${request_path_info} ${response_status}')
    )
  );
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Get('/ping', GetPing);
  THorse.Listen(9000);
end.
```

### SetLogFormat com variáveis disponíveis

```delphi
THorseLoggerConsoleConfig.New
  .SetLogFormat(
    '${time} ${response_status} ${request_method} ${request_path_info} ' +
    '→ ${response_time}ms'
  )
```

---

## Dependências

- `horse-logger` (base obrigatória)
- `horse-utils-clientip` (para `${request_clientip}`)

---

## Notas GestorERP

- Provider de consola activo apenas em ambiente de desenvolvimento
- Desactivar em produção (não registar o provider console)
- `units`: `Horse.Logger`, `Horse.Logger.Provider.Console`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill logger provider console.
