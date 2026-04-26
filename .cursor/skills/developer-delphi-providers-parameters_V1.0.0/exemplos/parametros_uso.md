---
description: "Exemplos de uso do módulo Parameters — INI, JSON, fallback cascade"
alwaysApply: false
---

# Exemplos — developer-delphi-providers-parameters

> Requer `{$DEFINE USE_PARAMENTERS}` em `ORM.Defines.inc`.

## 1. Carregar de INI (path explícito)

```pascal
uses Parameters.Interfaces, Parameters;

var
  LParams: IParameters;
begin
  LParams := TParameters.New.FromIniFile('Data/config.ini');
  // Acessar valor
  Writeln(LParams.GetValue('Database', 'Host'));
end;
```

## 2. Carregar de INI (path padrão — Data/config.ini)

```pascal
var
  LParams: IParameters;
begin
  LParams := TParameters.New.FromConfig;
end;
```

## 3. Carregar de JSON (string)

```pascal
const
  CJSON = '{"Database":{"Host":"localhost","Port":"5432","Name":"mydb"}}';
var
  LParams: IParameters;
begin
  LParams := TParameters.New.FromJSON(CJSON);
end;
```

## 4. Carregar de Database

```pascal
var
  LParams: IParameters;
begin
  // LConn já conectado
  LParams := TParameters.New.FromDatabase(LConn);
end;
```

## 5. Fallback cascade (Database > JSON > INI)

```pascal
var
  LParams: IParameters;
begin
  LParams := TParameters.New;
  try
    LParams.FromDatabase(LConn);
  except
    try
      LParams.FromJSON(LJsonString);
    except
      LParams.FromIniFile('Data/config.ini');
    end;
  end;
  // LParams agora tem valores de qualquer fonte que funcionou
end;
```

## 6. Integrar com IConnection

```pascal
uses Parameters.Interfaces, Parameters,
     Providers.Connection.Interfaces, Providers.Connection;

var
  LConn: IConnection;
begin
  LConn := TConnection.New
    .FromParameters(TParameters.New.FromConfig)
    .Connect;
  try
    // usar LConn
  finally
    LConn.Disconnect;
  end;
end;
```

## Referência canônica

- `src/Main/Parameters.Interfaces.pas`
- `src/Main/Parameters.pas`
- `src/Modulos/Parameters/`
