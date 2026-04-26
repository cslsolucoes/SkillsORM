# `.cursor/agents/` — agentes Cursor (dev + doc)

**Manifesto de área:** [**agents-pack-manifest_V1.7.1.md**](agents-pack-manifest_V1.7.1.md)

## CEO e orquestradores

| Ficheiro | Papel |
|----------|--------|
| [developer-agent-orchestrator_V2.3.0.md](developer-agent-orchestrator_V2.3.0.md) | CEO técnico — delegação dev |
| [developer-delphi-agent-orchestrator_V1.3.0.md](developer-delphi-agent-orchestrator_V1.3.0.md) | Sub-orquestrador Delphi/FPC |
| [developer-vuejs-agent-orchestrator_V1.2.0.md](developer-vuejs-agent-orchestrator_V1.2.0.md) | Sub-orquestrador VueJS/NodeJS |
| [documentation-agent-orchestrator_V1.4.0.md](documentation-agent-orchestrator_V1.4.0.md) | Orquestração documental `Documentation/`, `Analise/`, `doc-agent-class-*` |
| [governance-agent-orchestrator_V1.0.0.md](governance-agent-orchestrator_V1.0.0.md) | Governança / SDLC — specs, PRD, compliance, equipe, release management |
| [quality-agent-orchestrator_V1.0.0.md](quality-agent-orchestrator_V1.0.0.md) | QA — bugs, hotfix, code review, tech debt, testes de processo |
| [version-agent-orchestrator_V1.0.0.md](version-agent-orchestrator_V1.0.0.md) | Versionamento — semver, breaking change, deprecação, notas de release |

## Especialistas doc-agent-*

| Ficheiro | Domínio |
|----------|---------|
| [documentation-agent-migration_V1.2.0.md](documentation-agent-migration_V1.2.0.md) | Migração para `Documentation/` |
| [documentation-agent-migration-conflict-resolution_V1.2.0.md](documentation-agent-migration-conflict-resolution_V1.2.0.md) | Colisão de destino / `_CONFLITO` |
| [documentation-agent-superseded-definition_V1.2.0.md](documentation-agent-superseded-definition_V1.2.0.md) | Superseded vs conflito |
| [documentation-agent-roadmap_V1.2.0.md](documentation-agent-roadmap_V1.2.0.md) | Roadmap a partir da árvore |
| [documentation-agent-review_V1.2.0.md](documentation-agent-review_V1.2.0.md) | Revisão de consistência |
| [documentation-agent-architecture_V1.2.0.md](documentation-agent-architecture_V1.2.0.md) | `Documentation/Arquitetura/`; quality model via `documentation-overview-architecture` |
| [documentation-agent-rules_V1.4.0.md](documentation-agent-rules_V1.4.0.md) | Regras de negócio documentadas |
| [documentation-agent-cursor-rules-integration_V1.2.0.md](documentation-agent-cursor-rules-integration_V1.2.0.md) | Precedência rules vs docs vs skills |

## Especialistas doc-agent-class-* (análise por tipo — skill documentation-class-analysis-generator)

| Ficheiro | Escopo |
|----------|--------|
| [documentation-agent-class-scanner_V1.2.0.md](documentation-agent-class-scanner_V1.2.0.md) | Inventário de tipos no código-fonte |
| [documentation-agent-class-writer_V1.2.0.md](documentation-agent-class-writer_V1.2.0.md) | Preenchimento das 7 secções em `{ClassName}.md` |
| [documentation-agent-class-indexer_V1.2.0.md](documentation-agent-class-indexer_V1.2.0.md) | `README.md` + `FLOWCHART.md` na raiz da análise |

## Especialistas dev-agent-* (Delphi / ORM)

| Ficheiro | Escopo |
|----------|--------|
| [developer-delphi-agent-modules-orchestrator_V1.3.0.md](developer-delphi-agent-modules-orchestrator_V1.3.0.md) | `src/Modulos/` (visão geral) |
| [developer-delphi-agent-orm-architect_V1.3.0.md](developer-delphi-agent-orm-architect_V1.3.0.md) | ORM / documentation-project-expert |
| [developer-delphi-agent-connections-expert_V1.3.0.md](developer-delphi-agent-connections-expert_V1.3.0.md) | Connections |
| [developer-delphi-agent-database-expert_V1.3.0.md](developer-delphi-agent-database-expert_V1.3.0.md) | Database |
| [developer-delphi-agent-exceptions-expert_V1.3.0.md](developer-delphi-agent-exceptions-expert_V1.3.0.md) | Exceptions |
| [developer-delphi-agent-loggers-expert_V1.3.0.md](developer-delphi-agent-loggers-expert_V1.3.0.md) | Loggers |
| [developer-delphi-agent-parameters-expert_V1.3.0.md](developer-delphi-agent-parameters-expert_V1.3.0.md) | Parameters |
| [developer-delphi-agent-poolconnections-expert_V1.3.0.md](developer-delphi-agent-poolconnections-expert_V1.3.0.md) | PoolConnections |
| [developer-delphi-agent-views-orchestrator_V1.3.0.md](developer-delphi-agent-views-orchestrator_V1.3.0.md) | Frontend / Views |
| [developer-delphi-agent-views-expert_V1.3.0.md](developer-delphi-agent-views-expert_V1.3.0.md) | Views (detalhe) |

## Especialistas dev-agent-* (Vue / web)

| Ficheiro | Escopo |
|----------|--------|
| [developer-vuejs-agent-core-expert_V1.2.0.md](developer-vuejs-agent-core-expert_V1.2.0.md) | Vue 3 / SFC / core |
| [developer-vuejs-agent-routing-state-expert_V1.2.0.md](developer-vuejs-agent-routing-state-expert_V1.2.0.md) | Router / Pinia |
| [developer-web-agent-runtime-build-expert_V1.2.0.md](developer-web-agent-runtime-build-expert_V1.2.0.md) | Node / Vite / npm |
| [developer-web-agent-quality-expert_V1.2.0.md](developer-web-agent-quality-expert_V1.2.0.md) | Qualidade / a11y / segurança |

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.2.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.2.0 (11/04/2026): Adicionados 3 novos orquestradores (`governance-agent-orchestrator_V1.0.0`, `quality-agent-orchestrator_V1.0.0`, `version-agent-orchestrator_V1.0.0`); CEO atualizado → V2.2.0; manifesto → V1.4.0.
- 1.1.0 (11/04/2026): Auditoria — todas as versões sincronizadas com filesystem; manifesto → V1.3.0; doc-agents → V1.1.0; dev-agent ORM/Delphi → V1.2.0; dev-agent Vue/web → V1.1.0; orchestrators → V2.1.0 / V1.1.0 / V1.2.0.
- 1.0.4 (01/04/2026): **`documentation-agent-orchestrator_V1.1.3.md`**; manifesto **`agents-pack-manifest_V1.0.7.md`**.
- 1.0.3 (01/04/2026): Renomeação **doc-agent-class-*** (`*_V1.0.1.md`); manifesto **`agents-pack-manifest_V1.0.6.md`**.
- 1.0.2 (01/04/2026): Secção **doc-class-*** e manifesto `agents-pack-manifest_V1.0.5.md`.
- 1.0.1 (30/03/2026): Ficheiro renomeado de `README_V1.0.md` para `README.md`; agentes com SemVer no sufixo; manifesto `agents-pack-manifest_V1.0.4.md`.
- 1.0.0 (30/03/2026): Indice da area criado; manifesto `agents-pack-manifest_V1.0.3.md`.
