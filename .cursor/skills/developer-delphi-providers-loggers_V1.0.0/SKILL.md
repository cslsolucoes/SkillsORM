---
name: developer-delphi-providers-loggers
description: Use when the user asks about the Loggers module — multi-destination logging (Database, CSV, TextFile, XML, JSON, HTTP, Email, WebSocket, Windows EventLog, Custom); ILogger/ILoggers/TLoggerFactory API; log levels (DEBUG/INFO/WARN/ERROR/FATAL); USE_LOGGERS directive. Path: src/Modulos/Loggers/ + src/Main/Loggers.Interfaces.pas + src/Main/Loggers.pas.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-providers-loggers
## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill documenta o módulo **Loggers** do Providers ORM v2 — sistema de logging multi-destino com níveis configuráveis. Define a interface pública `ILogger`/`ILoggers`/`TLoggerFactory`, os 10 destinos disponíveis, os níveis de log e as regras de ativação via `USE_LOGGERS`.

## When to use

- Ao implementar logging em qualquer módulo do projeto.
- Ao configurar destinos (Database, CSV, TextFile, XML, JSON, HTTP, Email, WebSocket, EventLog, Custom).
- Ao definir nível mínimo de log (DEBUG, INFO, WARN, ERROR, FATAL).
- Ao ativar `USE_LOGGERS` em `ORM.Defines.inc`.

## When NOT to use

- Para carregamento de configuração (INI/JSON) → usar `developer-delphi-providers-parameters`.
- Para exceções centralizadas → usar `documentation-project-expert` / seção Exceptions.
- Para diretivas `{$IFDEF}` → usar `developer-delphi-programming-conditional-defines`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Ao ativar `USE_LOGGERS` em `ORM.Defines.inc` |
| `documentation-project-expert` | Ao integrar Loggers com Connection ou Database |

---

## Ativação

Em `ORM.Defines.inc`:

```pascal
{$DEFINE USE_LOGGERS}
```

Quando ativo, o DPR inclui as units de `src/Modulos/Loggers/` e as facades em `src/Main/`.

---

## Interface pública

**Units para consumidores externos:**

- `src/Main/Loggers.Interfaces.pas` — `ILogger`, `ILoggers`, `ILoggerDatabase`
- `src/Main/Loggers.pas` — `TLoggerFactory` (factory)

**Units internas** (uso apenas dentro do projeto):

- `src/Modulos/Loggers/` — implementações por destino

---

## Níveis de log

| Nível | Valor numérico | Quando usar |
|-------|---------------|-------------|
| `DEBUG` | 0 | Diagnóstico detalhado de desenvolvimento |
| `INFO` | 1 | Eventos normais do sistema |
| `WARN` | 2 | Situações inesperadas mas não críticas |
| `ERROR` | 3 | Erros recuperáveis |
| `FATAL` | 4 | Erros irrecuperáveis; sistema não pode continuar |

Configurar nível mínimo via `.MinLevel(llWarn)` — apenas logs ≥ nível mínimo são processados.

---

## 10 destinos disponíveis

| Destino | Quando usar |
|---------|-------------|
| **Database** | Auditoria persistente; histórico consultável via SQL |
| **CSV** | Análise em planilhas; baixo overhead |
| **TextFile** | Log simples em arquivo `.log`; debug rápido |
| **XML** | Integração com ferramentas XML/XSLT |
| **JSON** | APIs e sistemas modernos; fácil parse |
| **HTTP/HTTPS** | Envio para servidores centralizados REST |
| **Email** | Alertas críticos (FATAL/ERROR); notificação por e-mail |
| **WebSocket** | Monitoramento em tempo real; dashboards |
| **Windows EventLog** | Integração com infraestrutura Windows; monitoramento centralizado |
| **Custom** | Destino personalizado via implementação de `ILogger` |

---

## Métodos principais

| Método | Descrição |
|--------|-----------|
| `TLoggerFactory.New` | Cria instância de logger |
| `.Destination(ldDatabase)` | Define destino (enum `TLoggerDestination`) |
| `.MinLevel(llWarn)` | Define nível mínimo |
| `.Connection(LConn)` | Fornece conexão para destinos Database/HTTP |
| `.Log(llInfo, 'mensagem')` | Registra uma entrada |
| `.Debug('msg')` | Atalho para nível DEBUG |
| `.Info('msg')` | Atalho para nível INFO |
| `.Warn('msg')` | Atalho para nível WARN |
| `.Error('msg')` | Atalho para nível ERROR |
| `.Fatal('msg')` | Atalho para nível FATAL |

---

## Estrutura de pastas

```
src/
  Main/
    Loggers.Interfaces.pas      ← API pública (ILogger, ILoggers, ILoggerDatabase)
    Loggers.pas                 ← Factory (TLoggerFactory.New)
  Modulos/
    Loggers/
      Loggers.Database.pas      ← Destino Database
      Loggers.CSV.pas           ← Destino CSV
      Loggers.TextFile.pas      ← Destino TextFile
      Loggers.XML.pas           ← Destino XML
      Loggers.Json.pas          ← Destino JSON
      Loggers.HTTP.pas          ← Destino HTTP/HTTPS
      Loggers.Email.pas         ← Destino Email
      Loggers.WebSocket.pas     ← Destino WebSocket
      Loggers.EventLog.pas      ← Destino Windows EventLog
      Loggers.Consts.pas
      Loggers.Types.pas
      Loggers.Exceptions.pas
```

---

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Usar `USE_LOGGERS` sem definir no `.inc` | Compilação condicional falha | Ativar em `ORM.Defines.inc` e verificar DPR |
| Criar logger novo a cada chamada | Overhead; perde configuração | Reutilizar instância `ILogger` por módulo/serviço |
| Chamar units de `src/Modulos/Loggers/` de código externo | Viola encapsulamento | Usar apenas `Loggers.Interfaces` + `Loggers` |
| Log de dados sensíveis (senhas, tokens) em TextFile/HTTP | Risco de segurança | Mascarar ou excluir campos sensíveis antes de logar |

---

## Métricas de sucesso

- Logs gravados no destino correto sem overhead perceptível para o módulo produtor.
- Nível mínimo configurado — sem DEBUG em produção.
- Zero referências diretas a units internas de `src/Modulos/Loggers/` por código externo.

---

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor | `developer-delphi-agent-loggers-expert` |
| Revisor | `documentation-project-expert` |

---

## Changelog (este arquivo)

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-loggers_V*` para `developer-delphi-providers-loggers_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.0.0 (11/04/2026): Criação — skill do módulo Loggers (10 destinos, 5 níveis, ILogger, TLoggerFactory, ativação USE_LOGGERS, tabela de decisão por destino).
