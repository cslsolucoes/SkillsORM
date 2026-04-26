---
name: governance-spec-reviewer
description: Auditor independente da SPEC — identifica gaps técnicos (segurança, edge cases de banco, comportamento sob carga, rollback) e conduz entrevista de negócio para resolver ambiguidades antes do início da implementação.
model: opus
thinking: extended
category: governance-spec
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Spec — Reviewer

## Responsabilidade única

Atuar como auditor independente que lê a SPEC gerada por `governance-spec-technical-writer` e faz
as perguntas que ninguém fez durante a especificação: gaps de segurança, edge cases de banco de
dados, comportamento sob carga, estratégias de rollback, ambiguidades de nomenclatura e conflitos
com outros módulos. Esta skill **não cria** a SPEC (responsabilidade do technical-writer) nem
valida implementação já feita (responsabilidade do validator).

## When to use

- Após `governance-spec-technical-writer` gerar a SPEC e antes de iniciar qualquer sprint.
- Quando a SPEC for atualizada por `governance-spec-evolution` e exigir nova auditoria.
- Antes de qualquer merge de branch de feature para main/master.

## When NOT to use

- Para criar a SPEC do zero → usar `governance-spec-technical-writer`.
- Para validar implementação já entregue → usar `governance-spec-validator`.
- Para registrar mudanças em SPEC aprovada → usar `governance-spec-evolution`.
- Para gerar o PRD → usar `governance-spec-prd-generator`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| SPEC gerada | Arquivo JSON ou Markdown | `Documentation/SPEC/<nome-feature>.SPEC.json` ou `.SPEC.md` |
| PRD de origem | Arquivo Markdown | `Documentation/PRD/<nome-feature>.PRD.md` (para cruzamento) |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-spec-technical-writer` | SPEC estruturada é o input principal desta skill |

## Workflow executável

1. **Ler a SPEC e o PRD** — carregar ambos os documentos; verificar se a SPEC referencia
   corretamente o PRD de origem; identificar discrepâncias óbvias entre o que o PRD define
   e o que a SPEC especifica tecnicamente.

2. **Mapear gaps técnicos** — percorrer cada feature/step da SPEC e questionar:
   - Segurança: quem pode executar esta ação? Existe validação de entrada? Como lidar com
     tentativas de acesso indevido?
   - Banco de dados: qual é o comportamento em caso de deadlock, timeout ou constraint violation?
     A migration é reversível?
   - Carga: qual é o volume esperado? A implementação especificada escala para esse volume?
   - Rollback: se o step falhar no meio, qual é o estado do sistema? Existe estratégia de
     compensação ou idempotência?

3. **Formular perguntas de negócio** — para cada gap identificado, formular uma pergunta fechada
   ou de múltipla escolha (evitar perguntas abertas que gerem ambiguidade na resposta); agrupar
   por criticidade: crítico (bloqueia implementação), importante (deve ser resolvido antes do
   merge), informativo (pode ser documentado como decisão pendente).

4. **Registrar respostas** — conduzir entrevista com o stakeholder/Tech Lead; registrar cada
   resposta junto à pergunta; nunca deixar gap crítico sem resposta antes de aprovar a SPEC.

5. **Atualizar a SPEC** — incorporar as respostas como refinamentos nos campos correspondentes;
   adicionar edge_cases descobertos durante a revisão; emitir relatório de revisão com status
   (aprovada / aprovada com ressalvas / reprovada — requer nova iteração).

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Relatório de revisão | `Documentation/SPEC/<nome-feature>.REVIEW.md` | Markdown |
| SPEC atualizada | `Documentation/SPEC/<nome-feature>.SPEC.json` | JSON (in-place) |

### Estrutura obrigatória do relatório de revisão

```markdown
# Review — <Nome da Feature>

**Data da revisão:** <data>
**Revisor:** <nome ou papel>
**Status:** Aprovada | Aprovada com ressalvas | Reprovada

## Gaps identificados

### Críticos (bloqueiam implementação)
| ID | Gap | Pergunta | Resposta | Ação tomada na SPEC |
|----|-----|----------|----------|---------------------|
| G1 | ... | ...      | ...      | ...                 |

### Importantes (resolver antes do merge)
| ID | Gap | Pergunta | Resposta | Ação tomada na SPEC |
|----|-----|----------|----------|---------------------|

### Informativos (decisão pendente documentada)
| ID | Gap | Pergunta | Resposta | Ação tomada na SPEC |
|----|-----|----------|----------|---------------------|

## Edge cases adicionados
- <edge case descoberto durante revisão>

## Decisão final
<justificativa da decisão: aprovada / ressalvas / reprovada>
```

## Checklist de validação

- [ ] Todos os campos de segurança (`auth`) verificados
- [ ] Todos os campos de banco de dados (`database`) verificados com estratégia de rollback
- [ ] Comportamento sob carga avaliado para features de alto volume
- [ ] Zero gaps críticos sem resposta
- [ ] Edge cases descobertos adicionados à SPEC
- [ ] Relatório de revisão gerado em `Documentation/SPEC/<nome-feature>.REVIEW.md`
- [ ] SPEC atualizada in-place com as respostas incorporadas
- [ ] Status de revisão declarado explicitamente (aprovada / ressalvas / reprovada)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Aprovar SPEC sem questionar campos `auth` e `database` | São os campos de maior risco de regresão em produção | Sempre auditar esses campos, mesmo que pareçam simples |
| Perguntar sobre o que já está documentado no PRD ou na SPEC | Desperdiça tempo e desacredita o processo de revisão | Ler os documentos completamente antes de formular perguntas |
| Não registrar respostas na SPEC | Perde rastreabilidade das decisões de design | Incorporar cada resposta como refinamento no campo correspondente |
| Aprovar com gaps críticos abertos | Transfere risco para a implementação sem solução | Bloquear aprovação até todos os gaps críticos estarem resolvidos |
| Revisar só os campos preenchidos | Campos `null` podem indicar lacunas legítimas | Questionar explicitamente os campos `null` — podem ser omissões ou decisões válidas |

## Avaliação de risco

- **Parar e confirmar quando:** o status de revisão for "Reprovada" — não iniciar nenhum sprint
  antes de uma nova iteração com `governance-spec-technical-writer`.
- **Risco baixo:** gaps informativos — podem ser documentados como decisões pendentes e resolvidos
  durante o sprint.
- **Risco médio:** gaps importantes em `api_endpoint` ou `frontend` — resolver antes do merge,
  mas não necessariamente antes de iniciar o sprint.
- **Risco alto:** gaps críticos em `auth`, `database` ou `rollback` — bloqueiam o início da
  implementação; nunca aprovar com esses gaps abertos.

## Métricas de sucesso

- Zero gaps críticos na SPEC aprovada.
- Todas as perguntas formuladas durante a revisão respondidas e registradas.
- SPEC aprovada antes do início do primeiro sprint de implementação.
- Relatório de revisão acessível para rastreabilidade futura.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão humana | Revisor técnico humano (obrigatório para gaps críticos) |

## Referências

- Skill anterior na cadeia: `governance-spec-technical-writer_V1.0.0`
- Próxima skill na cadeia: `governance-spec-validator_V1.0.0` (após implementação)
- Atualização de SPEC aprovada: `governance-spec-evolution_V1.0.0`
- Pasta de saída canônica: `Documentation/SPEC/`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance-spec no plano de migração V2.6.
