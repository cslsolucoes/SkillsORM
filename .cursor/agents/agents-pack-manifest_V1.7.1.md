# Versão interna — `.cursor/agents/`

**FolderVersion:** 1.7.1 · **Data:** 24/04/2026
**Política:** [../VERSION.md](../VERSION.md)

Área de agentes com convenção `{domínio}-agent-{papel}_V{SemVer}.md` (migração V2 completa). Todos os 34 agentes têm `model:` declarado (opus/sonnet/haiku).

**Total V1.7.1: 34 agents.** Sem alterações de contagem vs V1.7.0.

## Onda E5a — cross-refs atualizadas — 24/04/2026

Sem alterações estruturais nos agents. Atualizadas 6 cross-refs (paths e labels) em `governance-agent-orchestrator_V1.0.0.md`, `quality-agent-orchestrator_V1.0.0.md` e `version-agent-orchestrator_V1.0.0.md` para refletir o rename de 7 skills master-orchestrators (`*-orchestrator` → `*-master-orchestrator`) executado em `.cursor/skills/` (ver `skills-pack-manifest_V1.19.0.md`).

## Onda 4 do refactor — 17/04/2026

### 11 agents generificados (zero renames)

Os 11 agents `developer-delphi-agent-*` foram generificados para tratar o framework **ProvidersORM** como reusável por qualquer projeto adoptante, removendo referências literais a "Projeto v2.0":

1. `developer-delphi-agent-orchestrator` — já genérico (sem alterações).
2. `developer-delphi-agent-modules-orchestrator_V1.3.0` → bump conteúdo 1.3.1.
3. `developer-delphi-agent-orm-architect_V1.3.0` → bump conteúdo 1.3.1.
4. `developer-delphi-agent-connections-expert_V1.3.0` → bump conteúdo 1.3.1.
5. `developer-delphi-agent-database-expert_V1.3.0` → bump conteúdo 1.3.1.
6. `developer-delphi-agent-exceptions-expert_V1.3.0` → bump conteúdo 1.3.1.
7. `developer-delphi-agent-loggers-expert_V1.3.0` → bump conteúdo 1.3.1.
8. `developer-delphi-agent-parameters-expert_V1.3.0` → bump conteúdo 1.3.1.
9. `developer-delphi-agent-poolconnections-expert_V1.3.0` → bump conteúdo 1.3.1.
10. `developer-delphi-agent-views-expert_V1.3.0` → bump conteúdo 1.3.1.
11. `developer-delphi-agent-views-orchestrator_V1.3.0` → bump conteúdo 1.3.1.

### Substituições aplicadas

- `"Projeto v2.0 deste clone"` → `"framework ProvidersORM"`
- `"Projeto v2.0"` → `"framework ProvidersORM"`
- `"do Projeto"` → `"do framework ProvidersORM"`
- `"deste clone"` → removido
- `"modo Slim"` → `"modo Attributes (Slim foi descontinuado)"`
- `"Mode: Slim only"` → `"Mode: Attributes (Slim was removed)"`

### Exemplos concretos migrados para Templates

3 ficheiros novos em `.cursor/Templates/providers-orm-examples/`:

- `README.md` — índice.
- `exception-codes.md` — tabela canónica de códigos 40001–40019 de `EConnectionException` e hierarquia `E{ORM}Exception`.
- `test-forms.md` — 7 forms `ufrm*Teste` canónicos (Connection, PoolConnections, Database, DatabaseAttributers, Exceptions, Parameters, Loggers).
- `module-structure.md` — árvore `src/Main/` / `src/Commons/` / `src/Modulos/*` do ORM.

## Changelog (este arquivo)

- 1.7.0 (17/04/2026): **FolderVersion** 1.7.0 (Onda 4 do refactor) — 10 dos 11 agents `developer-delphi-agent-*` actualizados com generificação de "Projeto v2.0" → "framework ProvidersORM" (zero renames); nota sobre descontinuação do modo Slim; exemplos concretos (códigos 40001–40019, lista `ufrm*Teste`, árvore `src/`) extraídos para `.cursor/Templates/providers-orm-examples/`. 1 agent já era genérico (orchestrator).
- 1.6.0 (15/04/2026): **FolderVersion** 1.6.0 — 34 agentes total; skills OOP adicionadas aos 3 orquestradores.
- (histórico preservado — ver versões anteriores arquivadas).
