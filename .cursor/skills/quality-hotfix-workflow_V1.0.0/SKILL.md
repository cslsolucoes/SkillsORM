---
name: quality-hotfix-workflow
description: Guia o fluxo completo de hotfix em produção — desde a criação do branch de correção emergencial até o merge em main e release patch, com gates de qualidade mínimos para velocidade segura.
model: sonnet
thinking: extended
category: quality
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Orquestrar o ciclo de vida de um hotfix emergencial (branch isolado → fix mínimo → teste rápido → merge → patch release) — não executar a correção técnica (delegue ao agente da área).

## When to use

- Bug S1/S2 em produção que exige correção imediata fora do ciclo normal de release.
- Regressão crítica introduzida por release recente.
- Vulnerabilidade de segurança com exploração ativa.

## When NOT to use

- Para bugs S3/S4 → incluir no próximo sprint via `quality-bug-triage`.
- Para planejamento de releases normais → use `governance-release-management`.
- Para rastrear bugs sem urgência → use `quality-tech-debt-tracker`.

## Inputs obrigatórios

1. Ticket de bug S1/S2 validado por `quality-bug-triage`.
2. Versão de produção afetada.
3. Aprovação explícita do responsável para iniciar hotfix.

## Dependências (skills prévias)

- `quality-bug-triage` — ticket estruturado com severidade confirmada.
- `governance-release-management` — para emitir o patch release após o fix.
- `version-semver-product` — para incrementar a versão PATCH.

## Workflow executável

1. **Criar branch hotfix** a partir da tag de produção: `hotfix/vX.Y.Z-<descricao>`.
2. **Isolar o fix mínimo** — apenas o necessário para corrigir; sem refatoração, sem features.
3. **Testes de regressão rápidos** — mínimo: teste do caminho afetado + smoke tests.
4. **Code review** — mínimo 1 aprovação obrigatória antes do merge.
5. **Merge em main E em develop** (evitar regressão futura).
6. **Emitir patch release** com `version-semver-product` (bump PATCH).
7. **Documentar** no changelog e notificar stakeholders.
8. **Post-mortem breve** — causa raiz, tempo de detecção, tempo de resolução.

## Outputs obrigatórios

- Branch `hotfix/` criado a partir de tag de produção.
- Fix commitado com referência ao ticket.
- Tag de patch release (vX.Y.Z+1).
- Entrada no changelog com data e referência ao ticket.
- Post-mortem de 1 parágrafo.

## Checklist de validação

- [ ] Branch criado a partir da tag correta de produção (não de develop).
- [ ] Fix mínimo — sem código extra não relacionado.
- [ ] Smoke tests passam.
- [ ] Code review completo (mínimo 1 aprovação).
- [ ] Merge em main E em develop.
- [ ] Patch release taggeado e publicado.
- [ ] Changelog atualizado.
- [ ] Stakeholders notificados.

## Anti-padrões

- Fazer hotfix direto em main sem branch — sem rastreabilidade.
- Incluir features ou refatoração no hotfix — aumenta risco.
- Merge apenas em main sem atualizar develop — regride futura release.
- Pular code review por "urgência" — a maioria dos incidentes graves tem essa origem.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Fix introduz nova regressão | Alto | Smoke tests obrigatórios antes de merge |
| Develop diverge de main | Médio | Merge em develop obrigatório no mesmo workflow |
| Branch criado errado | Alto | Criar sempre a partir de tag de produção, não de develop |

## Métricas de sucesso

- Tempo de detecção → deploy: < 2 horas para S1.
- Zero regressões introduzidas pelo hotfix.
- Post-mortem registrado em 100% dos hotfixes S1.

## Responsável principal

`dev-agent-orchestrator` — coordena o agente técnico da área para executar o fix e `governance-release-management` para emitir o patch.

## Referências

- `quality-bug-triage_V1.0.0/SKILL.md`
- `quality-regression-guard_V1.0.0/SKILL.md`
- `governance-release-management_V1.0.0/SKILL.md`
- `version-semver-product_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.
