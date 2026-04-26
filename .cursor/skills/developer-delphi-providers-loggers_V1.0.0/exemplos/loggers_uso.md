---
description: "Exemplos de uso do módulo Loggers — destinos, níveis, multi-destino"
alwaysApply: false
---

# Exemplos — developer-delphi-providers-loggers

> Requer `{$DEFINE USE_LOGGERS}` em `ORM.Defines.inc`.

## 1. Logger básico para arquivo (TextFile)

```pascal
uses Loggers.Interfaces, Loggers;

var
  LLog: ILogger;
begin
  LLog := TLoggerFactory.New
    .Destination(ldTextFile)
    .FilePath('Data/app.log')
    .MinLevel(llInfo);

  LLog.Info('Aplicação iniciada');
  LLog.Warn('Pool quase esgotado');
  LLog.Error('Falha ao carregar config');
end;
```

## 2. Multi-destino (arquivo + Database)

```pascal
var
  LLoggers: ILoggers;
begin
  LLoggers := TLoggerFactory.NewMultiple
    .Add(
      TLoggerFactory.New
        .Destination(ldTextFile)
        .FilePath('Data/app.log')
        .MinLevel(llInfo)
    )
    .Add(
      TLoggerFactory.New
        .Destination(ldDatabase)
        .Connection(LConn)
        .MinLevel(llWarn)   // apenas WARN+ no banco
    );

  LLoggers.Info('Evento normal — só vai para arquivo');
  LLoggers.Error('Erro — vai para arquivo E banco');
end;
```

## 3. Nível mínimo — filtrar DEBUG em produção

```pascal
var
  LLog: ILogger;
begin
  {$IFDEF DEBUG}
  LLog := TLoggerFactory.New.Destination(ldTextFile).MinLevel(llDebug);
  {$ELSE}
  LLog := TLoggerFactory.New.Destination(ldTextFile).MinLevel(llWarn);
  {$ENDIF}

  LLog.Debug('Variável X = 42');   // só em DEBUG
  LLog.Warn('Memória acima de 80%'); // sempre
end;
```

## 4. Structured logging (campos adicionais)

```pascal
var
  LLog: ILogger;
begin
  LLog := TLoggerFactory.New
    .Destination(ldJSON)
    .FilePath('Data/events.json')
    .MinLevel(llInfo);

  LLog
    .Field('user_id', 42)
    .Field('action', 'login')
    .Field('ip', '192.168.1.100')
    .Info('Usuário autenticado');
end;
```

## 5. Alerta por email (FATAL)

```pascal
var
  LLog: ILogger;
begin
  LLog := TLoggerFactory.New
    .Destination(ldEmail)
    .SmtpHost('smtp.empresa.com')
    .SmtpPort(587)
    .From('sistema@empresa.com')
    .To('admin@empresa.com')
    .MinLevel(llFatal);

  LLog.Fatal('Banco de dados inacessível — serviço parado');
end;
```

## Referência canônica

- `src/Main/Loggers.Interfaces.pas`
- `src/Main/Loggers.pas`
- `src/Modulos/Loggers/`
