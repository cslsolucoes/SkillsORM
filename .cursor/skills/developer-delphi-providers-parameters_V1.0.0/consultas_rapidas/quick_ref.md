---
description: "Referência rápida — módulo Parameters"
alwaysApply: false
---

# Quick Reference — developer-delphi-providers-parameters

| Fonte | Método | Arquivo de config padrão |
|-------|--------|--------------------------|
| INI | `TParameters.New.FromIniFile('Data/config.ini')` | `Data/config.ini` |
| INI (padrão) | `TParameters.New.FromConfig` | `Data/config.ini` |
| JSON (string) | `TParameters.New.FromJSON(AJsonStr)` | — |
| JSON (objeto) | `TParameters.New.FromJSONObject(AObj)` | — |
| Database | `TParameters.New.FromDatabase(LConn)` | tabela de config no banco |

## Ativação

```pascal
// ORM.Defines.inc
{$DEFINE USE_PARAMENTERS}   // atenção: typo histórico com E extra
```

## Units para consumo externo

```pascal
uses Parameters.Interfaces, Parameters;
```

## Integração com Connection

```pascal
LConn := TConnection.New.FromParameters(TParameters.New.FromConfig).Connect;
```

→ Exemplos completos: [exemplos/parametros_uso.md](../exemplos/parametros_uso.md)
