---
name: governance-master-orchestrator
description: Ponto de entrada para todos os workflows de governança de processo — SDLC, specs, artefatos, políticas, release management, equipe e resposta a incidentes. Coordena as 20 skills da família governance-*.
model: sonnet
thinking: minimal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Master Orchestrator

## Responsabilidade única

Ponto de entrada único para qualquer tarefa de governança de processo de desenvolvimento: gerenciar o ciclo de vida SDLC, redigir e revisar specs técnicas, inventariar artefatos, aplicar políticas constitucionais, gerenciar releases, responder a incidentes e estruturar a equipe. Esta skill não executa diretamente — seleciona a skill especialista correta da família `governance-*` e define a sequência de execução.

## When to use

- "compliance", "SDLC", "governança", "processo", "spec", "PRD", "onboarding", "equipe", "release management", "incidente", "auditoria", "change request", "política", "rastreabilidade", "traceability", "RACI"
- Antes de iniciar qualquer alteração que afete API pública ou contratos entre módulos
- Ao preparar documentação de requisitos ou specs técnicas
- Ao gerenciar incorporação de novos membros à equipe

## When NOT to use

- Para documentação técnica canónica → `documentation-master-orchestrator`
- Para versionamento SemVer e breaking changes → `version-master-orchestrator`
- Para QA, bugs e code review → `quality-master-orchestrator`
- Para implementação técnica → `developer-delphi-master-orchestrator` ou `developer-vuejs-agent-orchestrator`

## Skills coordenadas (20) — 5 sub-domínios

### ARTIFACTS (3 skills)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `governance-artifact-inventory` | Inventariar todos os artefatos do projeto | Ao fazer auditoria de escopo ou kickoff |
| `governance-artifact-dependency-map` | Mapear dependências entre artefatos e módulos | Antes de refactors ou reorganizações |
| `governance-artifact-traceability` | Rastrear req → código → documentação | Em auditorias ou revisões de compliance |

### SPECS (5 skills)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `governance-spec-prd-generator` | Gerar PRD (Product Requirements Document) | Ao iniciar nova feature ou produto |
| `governance-spec-technical-writer` | Redigir spec técnica detalhada | Após PRD aprovado, antes de implementação |
| `governance-spec-reviewer` | Revisar spec por completude e consistência | Antes de começar desenvolvimento |
| `governance-spec-validator` | Validar spec vs código implementado | Ao fechar feature ou sprint |
| `governance-spec-evolution` | Gerenciar evoluções e versões da spec | Ao alterar requisitos em andamento |

### POLICIES (5 skills)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `governance-constitution-policies` | Políticas constitucionais do projeto | Referência normativa para qualquer decisão |
| `governance-refactoring-compatibility-policy` | Política de compatibilidade em refactors | Antes de qualquer refactor que afete API pública |
| `governance-pack-versioning-policy` | Política SemVer do pack de skills/agents | Ao versionar o pack `.cursor/` |
| `governance-pack-checklist-validation` | Validar integridade do pack | Antes de sync entre projetos |
| `governance-pack-sync` | Sincronizar pack `.cursor/` entre projetos | Ao propagar mudanças para outros repos |

### RELEASE / SDLC (4 skills)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `governance-sdlc-lifecycle` | Ciclo de vida SDLC completo | Como referência normativa de processo |
| `governance-release-management` | Gerenciar releases (planejamento, gate, deploy) | Ao planejar ou executar um release |
| `governance-change-request` | Processo formal de change request | Ao propor mudança em produção ou API |
| `governance-incident-response` | Resposta estruturada a incidentes | Ao tratar incidente em produção |

### TEAM (3 skills)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `governance-team-onboarding` | Onboarding de novos membros | Ao integrar alguém à equipe |
| `governance-team-raci-matrix` | Definir e manter matriz RACI | Ao estruturar responsabilidades da equipe |
| `governance-team-ai-human-workflow` | Workflow de colaboração IA + humano | Ao definir como IA e humanos trabalham juntos |

## Sequências canônicas

```
NOVA FEATURE (do zero):
  governance-spec-prd-generator → governance-spec-technical-writer →
  governance-spec-reviewer → (implementação) → governance-spec-validator

RELEASE COMPLETO:
  governance-release-management → governance-change-request → governance-sdlc-lifecycle

MUDANÇA EM PRODUÇÃO:
  governance-change-request → governance-release-management → (deploy) → governance-incident-response (se necessário)

ONBOARDING:
  governance-team-onboarding → governance-team-raci-matrix → governance-team-ai-human-workflow

AUDITORIA DO PACK:
  governance-pack-checklist-validation → governance-pack-versioning-policy → governance-pack-sync
```

## Matriz de decisão

| Cenário | Skill |
|---------|-------|
| Preciso escrever os requisitos de uma nova feature | `governance-spec-prd-generator` |
| Tenho o PRD, preciso da spec técnica detalhada | `governance-spec-technical-writer` |
| A spec está pronta, alguém precisa revisar | `governance-spec-reviewer` |
| Feature entregue, verificar se bate com a spec | `governance-spec-validator` |
| Os requisitos mudaram durante o desenvolvimento | `governance-spec-evolution` |
| Quero saber quais artefatos o projeto tem | `governance-artifact-inventory` |
| Preciso entender dependências antes de refatorar | `governance-artifact-dependency-map` |
| Auditoria: req → código → doc | `governance-artifact-traceability` |
| Qual é a política oficial para X neste projeto? | `governance-constitution-policies` |
| Quero renomear uma interface pública — é seguro? | `governance-refactoring-compatibility-policy` |
| Como versionar minha mudança no pack `.cursor/`? | `governance-pack-versioning-policy` |
| Validar se o pack está íntegro antes de sync | `governance-pack-checklist-validation` |
| Propagar pack para outro projeto | `governance-pack-sync` |
| Qual o processo de release formal? | `governance-sdlc-lifecycle` + `governance-release-management` |
| Preciso abrir um change request formal | `governance-change-request` |
| Incidente em produção — processo estruturado | `governance-incident-response` |
| Novo membro entrando na equipe | `governance-team-onboarding` |
| Quem é responsável por quê neste projeto? | `governance-team-raci-matrix` |
| Como estruturar o trabalho com IA neste projeto? | `governance-team-ai-human-workflow` |

## Outputs esperados

| Skill | Output canônico |
|-------|----------------|
| `governance-artifact-dependency-map` | `TEMPLATE_dependency_map.md` |
| `governance-change-request` | `TEMPLATE_change_request.md` |
| `governance-incident-response` | `TEMPLATE_incident_report.md` |
| `governance-release-management` | `TEMPLATE_release_checklist.md` |
| `governance-team-raci-matrix` | `TEMPLATE_raci_matrix.md` |
| `governance-spec-prd-generator` | `TEMPLATE_spec_prd.md` |

Templates em `.cursor/skills/governance-master-orchestrator_V1.0.0/templates/`.

## Anti-padrões

| Anti-padrão | Como corrigir |
|-------------|---------------|
| Renomear API pública sem `governance-refactoring-compatibility-policy` | Executar a política antes — ela força a análise de impacto |
| Fazer deploy sem change request em produção | `governance-change-request` é gate obrigatório para mudanças em produção |
| Iniciar feature sem spec aprovada | `governance-spec-prd-generator` + `governance-spec-reviewer` antes do primeiro commit |
| Sincronizar pack sem validar integridade | `governance-pack-checklist-validation` antes de `governance-pack-sync` |
| Responder a incidente sem runbook | `governance-incident-response` antes de agir — garante comunicação e rastreabilidade |

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (11/04/2026): Criação — skill orquestradora da família `governance-*` (20 skills, 5 sub-domínios).
- 1.1.0 (24/04/2026): Rename E5a — `governance-master-orchestrator` -> `governance-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).