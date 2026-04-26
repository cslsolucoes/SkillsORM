---
name: developer-delphi-to-fpc-horse-logger-logfile
description: Provider de log em ficheiro para horse-logger. Cobre THorseLoggerProviderLogFile (New, New(config)) e THorseLoggerLogFileConfig (SetDir, SetLogName, SetLogFormat, GetDir, GetLogName). Para produção com rotação diária. Fonte: app/package/docs/pacotes/horse-logger-provider-logfile.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-logger-logfile_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Provider de logging em ficheiro para o horse-logger. Persiste logs de acesso em disco — adequado para produção e staging.

## When to use

- Persistir logs de acesso em disco (produção/staging)
- Configurar pasta, nome e formato dos ficheiros de log
- Rotação diária automática de logs

## When NOT to use

- Desenvolvimento (usar console) → `developer-delphi-to-fpc-horse-logger-console`
- Infraestrutura de logging → `developer-delphi-to-fpc-horse-logger`

## Documento canônico

`app/package/docs/pacotes/horse-logger-provider-logfile.md`

---

## THorseLoggerLogFileConfig — configuração

| Método | Descrição |
| --- | --- |
| `New` | Cria instância |
| `SetLogFormat(format)` | Formato da linha de log |
| `SetDir(dir)` | Pasta de destino |
| `SetLogName(name)` | Nome base do ficheiro |
| `GetLogFormat(out fmt)` | Lê formato |
| `GetDir(out dir)` | Lê pasta |
| `GetLogName(out name)` | Lê nome |

## THorseLoggerProviderLogFile — provider

| Método | Descrição |
| --- | --- |
| `New` | Provider com defaults |
| `New(config)` | Provider com configuração |

---

## Exemplos

### Configuração padrão

```delphi
uses Horse, Horse.Logger, Horse.Logger.Provider.LogFile;

begin
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New());
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);
  THorse.Listen(9000);
end;
```

### Caminho e formato customizados

```delphi
uses Horse, Horse.Logger, Horse.Logger.Provider.LogFile, System.SysUtils;

begin
  THorseLoggerManager.RegisterProvider(
    THorseLoggerProviderLogFile.New(
      THorseLoggerLogFileConfig.New
        .SetDir(ExtractFilePath(ParamStr(0)) + 'logs')
        .SetLogFormat('${request_clientip} [${time}] ${request_method} ${request_path_info} ${response_status}')
    )
  );
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Listen(9000);
end;
```

### Configuração completa

```delphi
THorseLoggerManager.RegisterProvider(
  THorseLoggerProviderLogFile.New(
    THorseLoggerLogFileConfig.New
      .SetDir('C:\logs\api')
      .SetLogName('gestorerp')  // ficheiro: gestorerp_YYYY-MM-DD.log
      .SetLogFormat(
        '${request_clientip} [${time}] ${request_method} ' +
        '${request_path_info} ${response_status} ${response_time}ms'
      )
  )
);
```

### Lazarus / FPC

```delphi
{$MODE DELPHI}{$H+}
uses Horse, Horse.Logger, Horse.Logger.Provider.LogFile, SysUtils;

begin
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New());
  THorse.Use(THorseLoggerManager.HorseCallback);
  THorse.Get('/ping', GetPing);
  THorse.Listen(9000);
end.
```

### SetLogName — convenção de nome de ficheiro

```delphi
THorseLoggerLogFileConfig.New
  .SetLogName('access')
// Cria: access_2026-04-12.log (rotação diária automática)
```

---

## Dependências

- `horse-logger` (base obrigatória)
- `horse-utils-clientip` (para `${request_clientip}`)

---

## Notas GestorERP

- Pasta de logs: `.\logs\` relativa ao executável (configurar caminho absoluto em produção)
- Rotação diária gerida automaticamente pelo pacote
- Manter pelo menos 30 dias de logs para auditoria
- `units`: `Horse.Logger`, `Horse.Logger.Provider.LogFile`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill logger provider logfile.
