---
name: governance-spec-validator
description: Valida a implementação real contra a SPEC aprovada — gera relatório de conformidade com percentual de features implementadas, acceptance_criteria atendidos vs pendentes, e edge_cases cobertos.
model: sonnet
thinking: normal
category: governance-spec
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Spec — Validator

## Responsabilidade única

Comparar o que foi efetivamente implementado com o que a SPEC especificou — produzindo um relatório
de conformidade com percentual numérico de features implementadas, critérios de aceite atendidos
vs pendentes, e edge_cases cobertos. Esta skill **não revisa** a SPEC (responsabilidade do reviewer)
nem atualiza a SPEC com novas mudanças (responsabilidade do evolution).

## When to use

- Ao final de cada sprint, antes de marcar features como concluídas.
- Antes de qualquer merge para a branch main/master.
- Quando houver dúvida sobre se uma feature foi completamente implementada conforme especificado.
- Como gate formal de qualidade antes de release.

## When NOT to use

- Para revisar a SPEC antes da implementação → usar `governance-spec-reviewer`.
- Para criar a SPEC → usar `governance-spec-technical-writer`.
- Para registrar mudanças na SPEC → usar `governance-spec-evolution`.
- Para gerar o PRD → usar `governance-spec-prd-generator`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| SPEC aprovada | Arquivo JSON | `Documentation/SPEC/<nome-feature>.SPEC.json` (revisada e aprovada) |
| Código implementado | Acesso ao repositório | Arquivos fonte relevantes para as features validadas |
| Relatório de revisão | Arquivo Markdown | `Documentation/SPEC/<nome-feature>.REVIEW.md` (para cruzar edge_cases) |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-spec-technical-writer` | SPEC estruturada é o baseline de comparação |
| `governance-spec-reviewer` | SPEC deve estar aprovada (sem gaps críticos) antes da validação |

## Workflow executável

1. **Ler a SPEC aprovada** — carregar `Documentation/SPEC/<nome-feature>.SPEC.json`; verificar
   que possui relatório de revisão aprovado; listar todos os `acceptance_criteria` e `edge_cases`
   para uso como checklist de validação.

2. **Comparar com a implementação** — para cada feature/step da SPEC, localizar a implementação
   correspondente no código; verificar se o comportamento declarado no `acceptance_criteria` é
   observável no código ou em testes; verificar se os `edge_cases` identificados possuem tratamento
   explícito (guard clause, teste, log ou documentação de decisão).

3. **Marcar conformidade** — para cada item, registrar: CONFORME (implementado e verificado),
   PARCIAL (implementado mas sem evidência completa), PENDENTE (não implementado) ou N/A (não
   aplicável a este sprint); nunca marcar como CONFORME sem evidência concreta.

4. **Gerar relatório de conformidade** — calcular percentuais por categoria (features totais,
   acceptance_criteria, edge_cases); listar todos os itens PENDENTE e PARCIAL com ação corretiva
   sugerida; emitir recomendação: APROVADO PARA MERGE / APROVADO COM RESSALVAS / BLOQUEADO.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Relatório de conformidade | `Documentation/SPEC/<nome-feature>.VALIDATION.md` | Markdown com % |

### Estrutura obrigatória do relatório de conformidade

```markdown
# Validation Report — <Nome da Feature>

**Data:** <data>
**Sprint validado:** <sprint>
**SPEC de referência:** `Documentation/SPEC/<nome-feature>.SPEC.json`

## Resumo de conformidade

| Categoria | Total | Conforme | Parcial | Pendente | % Conformidade |
|-----------|-------|----------|---------|----------|----------------|
| Features  | N     | N        | N       | N        | XX%            |
| Acceptance criteria | N | N  | N       | N        | XX%            |
| Edge cases | N    | N        | N       | N        | XX%            |

**Conformidade geral: XX%**

## Detalhamento por feature

### F1 — <Nome>
| Item | Status | Evidência | Ação corretiva |
|------|--------|-----------|----------------|
| AC: dado X, quando Y, então Z | CONFORME | `arquivo.pas` linha 42 | - |
| Edge case: <caso> | PENDENTE | — | Implementar guard clause em <método> |

## Recomendação final

**APROVADO PARA MERGE** | **APROVADO COM RESSALVAS** | **BLOQUEADO**

<Justificativa>
```

## Checklist de validação

- [ ] Todos os `acceptance_criteria` da SPEC verificados (status definido para cada um)
- [ ] Todos os `edge_cases` da SPEC verificados (status definido para cada um)
- [ ] Nenhum item marcado como CONFORME sem evidência (arquivo + linha ou teste)
- [ ] Percentuais calculados corretamente para as 3 categorias
- [ ] Recomendação final declarada explicitamente
- [ ] Relatório salvo em `Documentation/SPEC/<nome-feature>.VALIDATION.md`

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Validar sem acesso ao código-fonte | Torna a validação hipotética, sem evidência real | Garantir acesso ao repositório antes de iniciar |
| Marcar como CONFORME sem evidência (arquivo/linha/teste) | Frauda o relatório de conformidade | Sempre registrar a evidência concreta no campo correspondente |
| Ignorar `edge_cases` na validação | Edge cases não tratados viram bugs em produção | Verificar explicitamente cada edge case listado na SPEC |
| Aprovar com PENDENTE em acceptance_criteria críticos | Feature entregue incompleta entra em produção | Bloquear merge; registrar como ação corretiva com prazo |
| Usar percentual como único critério de aprovação | 80% pode incluir gaps críticos de segurança | Analisar qualitativamente os itens PENDENTE antes de recomendar |

## Avaliação de risco

- **Parar e confirmar quando:** acceptance_criteria relacionados a `auth` ou `database` estiverem
  PENDENTE — bloquear merge independentemente do percentual geral.
- **Risco baixo:** itens PARCIAL em features de baixo impacto — aprovação com ressalvas.
- **Risco médio:** percentual geral abaixo de 80% — exigir plano de correção antes do merge.
- **Risco alto:** qualquer PENDENTE em campo `auth` ou edge case de segurança — BLOQUEADO.

## Métricas de sucesso

- Relatório com percentual numérico gerado para as 3 categorias (features, acceptance_criteria,
  edge_cases).
- Todos os acceptance_criteria verificados (nenhum omitido).
- Recomendação final declarada com justificativa.
- Zero itens marcados como CONFORME sem evidência registrada.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão humana | Tech Lead (obrigatório para BLOQUEADO ou gaps em `auth`/`database`) |

## Referências

- Skill anterior na cadeia: `governance-spec-reviewer_V1.0.0` (SPEC deve estar aprovada)
- Skill para registrar divergências encontradas: `governance-spec-evolution_V1.0.0`
- Pasta de saída canônica: `Documentation/SPEC/`
- Política SDLC: `.cursor/skills/governance-sdlc-lifecycle_V1.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance-spec no plano de migração V2.6.
