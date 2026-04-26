---
name: governance-spec-evolution
description: Gerencia a evolução controlada de especificações existentes (PRD, TSD, SPEC), garantindo rastreabilidade de mudanças, análise de impacto, compatibilidade e decisão formal (backward compat / deprecated / breaking change).
model: sonnet
thinking: extended
category: governance-spec
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Gerenciar a evolução de especificações já publicadas de forma rastreável e com análise de impacto explícita — não criar especificações novas (use `governance-spec-prd-generator` ou `governance-spec-technical-writer`).

## When to use

- Quando uma especificação aprovada precisa ser alterada, ampliada ou corrigida.
- Quando requisitos mudam após a spec estar em implementação.
- Quando há conflito entre spec e implementação real e é necessário decidir qual vence.
- Quando a spec precisa ser deprecada ou substituída.

## When NOT to use

- Para criar especificações do zero → use `governance-spec-prd-generator` ou `governance-spec-technical-writer`.
- Para revisar qualidade de uma spec → use `governance-spec-reviewer`.
- Para validar conformidade → use `governance-spec-validator`.
- Para renomear código → use `governance-refactoring-compatibility-policy`.

## Inputs obrigatórios

1. Spec atual (PRD/TSD/SPEC) com versão identificada.
2. Descrição da mudança desejada.
3. Contexto de impacto: módulos, APIs, consumers afetados.

## Dependências (skills prévias)

- `governance-spec-reviewer` — verificar estado atual antes de evoluir.
- `governance-refactoring-compatibility-policy` — se a evolução da spec implica renomear código.
- `governance-sdlc-lifecycle` — fase SDLC em que a spec se encontra.

## Workflow executável

1. **Identificar versão atual** da spec e changelog existente.
2. **Classificar a mudança:**
   - Tipo A — additive (nova seção, novo campo opcional) → MINOR bump, backward compat.
   - Tipo B — breaking (campo obrigatório alterado, contrato modificado) → MAJOR bump, deprecação agendada.
   - Tipo C — correção (typo, ambiguidade, erro factual) → PATCH bump.
3. **Análise de impacto:** listar todos os artefatos que referenciam a spec (código, testes, docs, agentes).
4. **Documentar decisão formal** (A/B/C) com justificativa.
5. **Atualizar a spec:** incrementar versão, adicionar entrada no changelog, marcar seções alteradas.
6. **Notificar consumers** — se tipo B, adicionar seção `## Breaking Changes` com migration guide.
7. **Validar** com `governance-spec-validator`.

## Outputs obrigatórios

- Spec atualizada com nova versão SemVer.
- Changelog entry descrevendo a mudança e o tipo (A/B/C).
- Lista de artefatos impactados.
- Migration guide (apenas tipo B).

## Checklist de validação

- [ ] Versão SemVer corretamente incrementada (MAJOR/MINOR/PATCH conforme tipo).
- [ ] Changelog entry presente com data e tipo de mudança.
- [ ] Todos os consumers identificados e notificados.
- [ ] Migration guide presente se tipo B.
- [ ] Spec validada com `governance-spec-validator` após edição.
- [ ] Referências cruzadas internas consistentes.

## Anti-padrões

- Editar spec sem incrementar versão — perda de rastreabilidade.
- Fazer breaking changes sem migration guide.
- Evoluir spec em implementação sem comunicar os consumers.
- Usar PATCH para mudanças que alteram contrato.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Breaking change silencioso | Alto | Sempre classificar explicitamente; obrigar migration guide |
| Spec desalinhada com código | Médio | `governance-spec-validator` após cada evolução |
| Consumers não notificados | Alto | Checklist de artefatos impactados obrigatório |

## Métricas de sucesso

- Zero breaking changes sem migration guide.
- Changelog presente em 100% das versões publicadas.
- Consumers notificados antes da merge da spec evoluída.

## Responsável principal

`doc-agent-orchestrator` — coordena com `doc-agent-review` para validação de qualidade.

## Referências

- `governance-spec-reviewer_V1.0.0/SKILL.md`
- `governance-spec-validator_V1.0.0/SKILL.md`
- `governance-refactoring-compatibility-policy_V1.0.0/SKILL.md`
- `governance-sdlc-lifecycle_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.
