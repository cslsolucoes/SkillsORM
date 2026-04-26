---
name: developer-delphi-providers-parameters
description: Use when the user asks about the Parameters module — loading config from INI, JSON, or Database; IParameters/TParameters API; FromIniFile, FromJSON, FromDatabase; USE_PARAMENTERS directive; fallback cascade pattern. Path: src/Modulos/Parameters/ + src/Main/Parameters.Interfaces.pas + src/Main/Parameters.pas.
model: haiku
thinking: extended
category: developer-delphi
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# developer-delphi-providers-parameters
## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill documenta o módulo **Parameters** do Providers ORM v2 — carregamento de configuração a partir de três fontes (INI, JSON, Database) com suporte a fallback cascade. Define a interface pública `IParameters`/`TParameters`, os métodos disponíveis e as regras de ativação via `USE_PARAMENTERS`.

## When to use

- Ao implementar carregamento de configuração via INI, JSON ou banco de dados.
- Ao usar `FromConfig`, `FromIniFile`, `FromJSON`, `FromJSONObject`, `FromDatabase`.
- Ao configurar `IConnection.FromParameters` (parâmetros de conexão vindos do módulo).
- Ao ativar `USE_PARAMENTERS` em `ORM.Defines.inc`.

## When NOT to use

- Para configurar a conexão manualmente (Host, Port, etc.) → usar `documentation-project-expert` / seção Connection.
- Para logging → usar `developer-delphi-providers-loggers`.
- Para diretivas `{$IFDEF}` → usar `developer-delphi-programming-conditional-defines`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `developer-delphi-programming-conditional-defines` | Ao ativar `USE_PARAMENTERS` em `ORM.Defines.inc` |
| `documentation-project-expert` | Ao integrar Parameters com Connection ou Database |

---

## Ativação

Em `ORM.Defines.inc`:

```pascal
{$DEFINE USE_PARAMENTERS}
```

> **Nota:** O nome da diretiva tem typo histórico (`PARAMENTERS`, não `PARAMETERS`) — manter exatamente assim.

Quando ativo, o DPR inclui as units de `src/Modulos/Parameters/` e as facades em `src/Main/`.

---

## Interface pública

**Units para consumidores externos:**

- `src/Main/Parameters.Interfaces.pas` — `IParameters`, `IParametersDatabase`
- `src/Main/Parameters.pas` — `TParameters` (factory)

**Units internas** (uso apenas dentro do projeto):

- `src/Modulos/Parameters/` — implementações por fonte (IniFile, JSON, Database)

---

## Métodos principais

| Método | Fonte | Descrição |
|--------|-------|-----------|
| `FromIniFile(APath)` | INI | Carrega `config.ini` (padrão: `Data/config.ini`) |
| `FromJSON(AJson)` | JSON (string) | Carrega de string JSON |
| `FromJSONObject(AObj)` | JSON (objeto) | Carrega de `TJSONObject` já parseado |
| `FromConfig` | INI padrão | Usa path padrão `Data/config.ini` |
| `FromDatabase(AConn)` | Database | Lê parâmetros da tabela de config no banco |

Todos retornam `IParameters` para encadeamento (Fluent API).

---

## Padrão de fallback cascade

```pascal
// Prioridade: Database > JSON > INI > padrão
LParams := TParameters.New;
try
  // Tenta Database primeiro
  LParams.FromDatabase(LConn);
except
  try
    // Fallback para JSON
    LParams.FromJSON(LJsonString);
  except
    // Último recurso: INI
    LParams.FromIniFile('Data/config.ini');
  end;
end;
```

---

## Integração com IConnection

```pascal
// USE_PARAMENTERS + USE_* engine ativos
LConn := TConnection.New
  .FromParameters(TParameters.New.FromConfig)
  .Connect;
```

---

## Quando NÃO usar Parameters para conexão

Preferir `IConnection.FromConfig` diretamente quando a configuração é simples e não há necessidade de fallback ou carregamento de múltiplas fontes.

```pascal
// Simples: sem Parameters
LConn := TConnection.New
  .Host('localhost').Port(5432).Database('db')
  .Connect;
```

---

## Estrutura de pastas

```
src/
  Main/
    Parameters.Interfaces.pas   ← API pública (IParameters, IParametersDatabase)
    Parameters.pas              ← Factory (TParameters.New)
  Modulos/
    Parameters/
      Parameters.IniFiles.pas   ← Implementação INI
      Parameters.JsonObject.pas ← Implementação JSON
      Parameters.Database.pas   ← Implementação Database
      Parameters.Consts.pas
      Parameters.Types.pas
      Parameters.Exceptions.pas
```

---

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Usar `USE_PARAMENTERS` sem definir no `.inc` | Compilação condicional falha | Ativar em `ORM.Defines.inc` e verificar DPR |
| Duplicar constantes de path fora de Commons | Redundância | Usar `Commons.Consts.DEFAULT_DATABASE_PATH` |
| Chamar units de `src/Modulos/Parameters/` de código externo | Viola encapsulamento | Usar apenas `Parameters.Interfaces` + `Parameters` |

---

## Métricas de sucesso

- Configuração carregada de INI/JSON/Database sem duplicar lógica de parse.
- `IConnection.FromParameters` funciona com qualquer fonte ativa.
- Zero referências diretas a units internas de `src/Modulos/Parameters/` por código externo.

---

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor | `developer-delphi-agent-parameters-expert` |
| Revisor | `documentation-project-expert` |

---

## Changelog (este arquivo)

- 1.0.0 (17/04/2026): Onda 3 do refactor — skill renomeada de `project-parameters_V*` para `developer-delphi-providers-parameters_V1.0.0`. Conteúdo generificado (remoção de referências literais a 'Projeto v2.0 deste clone', paths absolutos, MXX concreto). Versão anterior arquivada em `.cursor/Backup/renamed-skills-20260417/skills/`.

- 1.0.0 (11/04/2026): Criação — skill do módulo Parameters (INI, JSON, Database; IParameters; fallback cascade; ativação USE_PARAMENTERS).
