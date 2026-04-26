---
description: "Referência rápida — módulo Loggers"
alwaysApply: false
---

# Quick Reference — developer-delphi-providers-loggers

## Ativação

```pascal
// ORM.Defines.inc
{$DEFINE USE_LOGGERS}
```

## Níveis (ordem crescente de severidade)

| Nível | Constante | Quando usar |
|-------|-----------|-------------|
| DEBUG | `llDebug` | Diagnóstico de desenvolvimento |
| INFO | `llInfo` | Eventos normais |
| WARN | `llWarn` | Situações inesperadas |
| ERROR | `llError` | Erros recuperáveis |
| FATAL | `llFatal` | Erros irrecuperáveis |

## 10 destinos — tabela de decisão

| Destino | Enum | Melhor para |
|---------|------|-------------|
| Database | `ldDatabase` | Auditoria; histórico consultável |
| CSV | `ldCSV` | Análise em planilhas |
| TextFile | `ldTextFile` | Debug rápido; arquivo `.log` |
| XML | `ldXML` | Integração XSLT/ferramentas XML |
| JSON | `ldJSON` | APIs; sistemas modernos |
| HTTP/HTTPS | `ldHTTP` | Agregadores centralizados REST |
| Email | `ldEmail` | Alertas FATAL/ERROR |
| WebSocket | `ldWebSocket` | Monitoramento em tempo real |
| Windows EventLog | `ldEventLog` | Infra Windows; log centralizado |
| Custom | `ldCustom` | Destino personalizado |

## Uso básico

```pascal
uses Loggers.Interfaces, Loggers;

var LLog: ILogger;
begin
  LLog := TLoggerFactory.New
    .Destination(ldTextFile)
    .MinLevel(llInfo);
  LLog.Info('Aplicação iniciada');
  LLog.Error('Falha ao conectar');
end;
```

→ Exemplos completos: [exemplos/loggers_uso.md](../exemplos/loggers_uso.md)
