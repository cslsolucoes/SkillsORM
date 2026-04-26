---
name: developer-delphi-to-fpc-horse-exception-logger
description: Middleware de log de exceções para Horse. Cobre THorseExceptionLogger.New (formato padrão e com format/dir), variáveis de formato (${time}, ${request_clientip}, ${exception}, ${response_status}, etc.) e ordem no pipeline. Fonte: app/package/docs/pacotes/horse-exception-logger.md.
model: sonnet
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-to-fpc-horse-exception-logger_V1.0.0

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Middleware que regista exceções do pipeline Horse em ficheiro/console com formato de linha configurável — focado em auditoria, não em log de acesso normal.

## When to use

- Registar exceções em disco para auditoria de segurança
- Rastrear erros HTTP (status, método, path, mensagem de exceção)
- Complementar `handle-exception` com persistência de erros

## When NOT to use

- Log de acesso normal (requests/responses) → `developer-delphi-to-fpc-horse-logger`
- Intercepção de erros HTTP → `developer-delphi-to-fpc-horse-handle-exception`

## Documento canônico

`app/package/docs/pacotes/horse-exception-logger.md`

---

## THorseExceptionLogger — factory de middleware

| Método | Descrição |
| --- | --- |
| `THorseExceptionLogger.New` | Formato padrão |
| `THorseExceptionLogger.New(format, dir)` | Formato e pasta de log customizados |

---

## Variáveis de formato

| Variável | Conteúdo |
| --- | --- |
| `${time}` | Data/hora da exceção |
| `${request_clientip}` | IP do cliente |
| `${request_method}` | Verbo HTTP (GET, POST…) |
| `${request_path_info}` | Path da rota |
| `${request_version}` | Versão HTTP |
| `${response_status}` | Código HTTP da resposta |
| `${exception}` | Mensagem da exceção |

**Formato padrão:** `${request_clientip} [${time}] ${request_method} ${request_path_info} ${request_version} ${response_status} ${exception}`

---

## Ordem no pipeline

```delphi
THorse
  .Use(Jhonson)                        // 1.º
  .Use(HandleException)                // 2.º — formata erros HTTP
  .Use(THorseExceptionLogger.New())    // 3.º — regista exceção (após handle)
  .Use(THorseLoggerManager.HorseCallback); // 4.º — log de acesso
```

---

## Exemplos

### Mínimo

```delphi
uses Horse, Horse.Exception.Logger;

begin
  THorse.Use(THorseExceptionLogger.New());

  THorse.Get('/raise',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      raise Exception.Create('Exception test');
    end);

  THorse.Listen(9000);
end.
```

### Com formato e pasta customizados

```delphi
THorse.Use(
  THorseExceptionLogger.New(
    '${time} - ${request_method} ${request_path_info} ${exception}',
    ExtractFilePath(ParamStr(0)) + 'logs'
  )
);
```

### Formato para auditoria de segurança

```delphi
THorse.Use(
  THorseExceptionLogger.New(
    '${time} | ${request_clientip} | ${request_method} ${request_path_info} | ${response_status} | ${exception}',
    'C:\logs\api\exceptions'
  )
);
```

### Stack completo com todos os loggers

```delphi
uses
  Horse, Horse.Jhonson, Horse.HandleException,
  Horse.Exception.Logger, Horse.Logger, Horse.Logger.Provider.LogFile;

begin
  THorse
    .Use(Jhonson)
    .Use(HandleException)
    .Use(THorseExceptionLogger.New())
    .Use(THorseLoggerManager.HorseCallback);

  THorse.Listen(9000);
end.
```

---

## Notas GestorERP

- Registar **DEPOIS** de `HandleException` e **ANTES** do logger de acesso
- `boss.json` do pacote tem `name: horse-logger` (cópia upstream) — identificador Boss correcto: `arvanus/horse-exception-logger`
- `unit` a usar: `Horse.Exception.Logger`

---

## Changelog (este arquivo)

- 1.0.0 (12/04/2026): Criação — skill middleware exception-logger.
