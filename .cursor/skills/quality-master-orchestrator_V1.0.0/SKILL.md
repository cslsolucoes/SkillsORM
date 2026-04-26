---
name: quality-master-orchestrator
description: Ponto de entrada para todos os workflows de qualidade de processo — estratégia de testes, aceite, regressão, code review, bugs, hotfix, refactoring seguro e tech debt. Coordena as 8 skills da família quality-*.
model: sonnet
thinking: minimal
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Quality Master Orchestrator

## Responsabilidade única

Ponto de entrada único para qualquer tarefa de qualidade de processo de desenvolvimento: definir estratégia de testes, validar critérios de aceite, proteger contra regressões, executar code review estruturado, triar e priorizar bugs, executar hotfixes de produção com segurança, refatorar sem quebrar funcionalidade e rastrear tech debt. Esta skill não executa diretamente — seleciona a skill especialista correta da família `quality-*`.

**Distinção importante:** `quality-*` trata de **processos de QA** (como testar, como revisar). Skills de linguagem (`developer-delphi-testing-*`) tratam de **implementação técnica de testes** (DUnitX, Vitest).

## When to use

- "testar", "qualidade", "QA", "bug", "hotfix", "code review", "refatorar com segurança", "tech debt", "regressão", "aceite", "critério de aceite"
- Antes de qualquer merge para proteger contra regressões
- Ao classificar e priorizar bugs em produção
- Ao definir estratégia de testes para uma nova feature

## When NOT to use

- Para implementação técnica de testes em Delphi/FPC → `developer-delphi-testing-dunitx`
- Para implementação técnica de testes web → `developer-web-testing-debugging`
- Para versionamento ou release → `version-master-orchestrator`
- Para SDLC formal e release management → `governance-master-orchestrator`

## Skills coordenadas (8)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `quality-test-strategy` | Definir estratégia de testes para o projeto/feature | Antes de iniciar implementação de nova feature |
| `quality-acceptance-testing` | Definir e validar critérios de aceite | Antes de marcar feature como concluída |
| `quality-regression-guard` | Garantir que mudanças não quebram funcionalidade existente | Antes de merge / após refactor |
| `quality-code-review-checklist` | Estruturar code review em PRs com checklist padronizado | Durante revisão de PRs |
| `quality-bug-triage` | Classificar, priorizar e atribuir bugs | Ao receber um bug report |
| `quality-hotfix-workflow` | Executar hotfix em produção com segurança e rastreabilidade | Ao tratar incidente de produção |
| `quality-refactoring-safe` | Refatorar código preservando comportamento e sem regressões | Antes de qualquer refactor significativo |
| `quality-tech-debt-tracker` | Catalogar, priorizar e planejar redução de tech debt | Ao identificar débito técnico acumulado |

## Famílias de uso

```
PRÉ-RELEASE:
  quality-test-strategy → quality-acceptance-testing → quality-regression-guard

REVISÃO DE CÓDIGO:
  quality-code-review-checklist

INCIDENTES EM PRODUÇÃO:
  quality-bug-triage → quality-hotfix-workflow

EVOLUÇÃO DO CÓDIGO:
  quality-refactoring-safe → quality-tech-debt-tracker
```

## Matriz de decisão

| Cenário | Skill |
|---------|-------|
| Nova feature — como devo testá-la? | `quality-test-strategy` |
| Feature pronta — está completa conforme spec? | `quality-acceptance-testing` |
| Refactor — posso quebrar algo existente? | `quality-regression-guard` |
| PR aberto para revisão | `quality-code-review-checklist` |
| Bug reportado em produção | `quality-bug-triage` |
| Bug crítico em produção agora | `quality-hotfix-workflow` |
| Preciso refatorar X sem quebrar Y | `quality-refactoring-safe` |
| Código legado se acumulando, preciso priorizar | `quality-tech-debt-tracker` |

## Outputs esperados

| Skill | Output canônico |
|-------|----------------|
| `quality-code-review-checklist` | `TEMPLATE_code_review_checklist.md` |
| `quality-test-strategy` | `TEMPLATE_test_strategy_matrix.md` |
| `quality-acceptance-testing` | `TEMPLATE_acceptance_test_case.md` |
| `quality-bug-triage` | `TEMPLATE_bug_report.md` |
| `quality-hotfix-workflow` | `TEMPLATE_hotfix_runbook.md` |

Templates em `.cursor/skills/quality-master-orchestrator_V1.0.0/templates/`.

## Anti-padrões

| Anti-padrão | Como corrigir |
|-------------|---------------|
| Usar `quality-*` para escrever código de teste | Usar skills `developer-delphi-testing-*` ou `developer-web-testing-*` |
| Fazer merge sem passar por `quality-regression-guard` | Incorporar regressão check no processo de PR |
| Triar bug como hotfix sem classificar primeiro | Sempre `quality-bug-triage` antes de `quality-hotfix-workflow` |
| Refatorar sem documentar intenção e escopo | `quality-refactoring-safe` exige escopo definido antes de iniciar |

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (11/04/2026): Criação — skill orquestradora da família `quality-*` (8 skills).
- 1.1.0 (24/04/2026): Rename E5a — `quality-master-orchestrator` -> `quality-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).