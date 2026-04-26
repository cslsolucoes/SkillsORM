---
name: governance-team-raci-matrix
description: Matriz RACI humano + IA por tipo de tarefa do Providers.2.1.0 — define quem é Responsável, Aprovador, Consultado e Informado para cada tipo de atividade, distinguindo explicitamente o papel humano do papel do agent IA.
model: haiku
thinking: minimal
category: governance-people
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance People — Team RACI Matrix

## Responsabilidade única

Manter e gerar a matriz RACI que define, para cada tipo de tarefa do Providers.2.1.0 (nova feature,
bugfix, refatoração, release, documentação, mudança de API), quem é Responsável, Aprovador,
Consultado e Informado — com distinção explícita entre papel humano e papel do agent IA. Esta skill
**não** cobre o fluxo detalhado de decisão IA vs. humano (→ `governance-team-ai-human-workflow`)
nem o processo completo de onboarding (→ `governance-team-onboarding`).

## When to use

- Ao fazer onboarding de novo desenvolvedor no projeto.
- Ao revisar processo de decisão e fluxo de aprovação.
- Ao definir ou atualizar responsabilidades para novo tipo de tarefa.
- Ao auditar se as responsabilidades estão sendo seguidas na prática.

## When NOT to use

- Para onboarding técnico completo → usar `governance-team-onboarding`.
- Para definir política de autonomia do agent → usar `governance-team-ai-human-workflow`.
- Para processo de gestão de mudança → usar `governance-change-request`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Tipos de tarefa do projeto | Lista | Categorias de atividade a serem mapeadas na RACI |
| Papéis humanos | Lista | Ex.: Tech Lead, Dev, QA, Product Owner |
| Agents IA disponíveis | Lista | Ex.: dev-agent-orchestrator, agentes especializados |

## Dependências (skills prévias)

Nenhuma dependência obrigatória.

## Workflow executável

1. **Listar tipos de tarefa** — identificar todas as categorias de atividade recorrente no
   Providers.2.1.0:
   - Nova feature (módulo novo)
   - Bugfix (correção de defeito)
   - Refatoração (melhoria interna sem mudança de comportamento)
   - Release (publicação de versão)
   - Documentação (criação/atualização de docs)
   - Mudança de API pública (breaking ou não-breaking)
   - Mudança de SPEC (atualização de especificação técnica)
   - Revisão de code review
   - Onboarding de membro

2. **Preencher RACI por tarefa** — para cada tipo de tarefa, atribuir exatamente um R
   (Responsável), um ou mais A (Aprovador), zero ou mais C (Consultado) e zero ou mais I
   (Informado). Distinguir explicitamente:
   - Papéis humanos: Tech Lead, Dev, QA, Product Owner
   - Papéis IA: dev-agent-orchestrator, skills especializadas
   - Regra: aprovação (A) é sempre papel humano para tarefas de alto impacto

3. **Validar com stakeholders** — apresentar a matriz para revisão; verificar que não há tarefa
   sem R definido; verificar que não há múltiplos R na mesma tarefa; confirmar que aprovadores
   humanos estão disponíveis para as tarefas que exigem.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Matriz RACI | `Documentation/RACI.md` | Tabela Markdown |

### Estrutura obrigatória da matriz RACI

```markdown
# Matriz RACI — Providers.2.1.0

**Legenda:** R = Responsável · A = Aprovador · C = Consultado · I = Informado
**[H]** = Papel humano · **[IA]** = Agent IA

| Tipo de Tarefa | Tech Lead [H] | Dev [H] | QA [H] | Product Owner [H] | dev-agent-orchestrator [IA] |
|----------------|--------------|---------|--------|-------------------|----------------------------|
| Nova feature   | A            | R       | C      | A                 | C                           |
| Bugfix         | I            | R       | A      | I                 | C                           |
| Refatoração    | A            | R       | C      | I                 | C                           |
| Release        | A            | C       | R      | A                 | I                           |
| Documentação   | I            | R       | I      | I                 | R (geração)                 |
| Mudança de API | A            | R       | C      | A                 | C                           |
```

## Checklist de validação

- [ ] Todos os tipos de tarefa recorrentes listados
- [ ] Todo tipo de tarefa com exatamente um R definido
- [ ] Papéis humanos e IA distinguidos explicitamente
- [ ] Aprovação (A) atribuída a papel humano para tarefas de alto impacto
- [ ] Nenhum conflito de múltiplos R na mesma tarefa
- [ ] Matriz validada com Tech Lead
- [ ] `Documentation/RACI.md` criado/atualizado

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| RACI sem distinção humano/IA | Responsabilidades ambíguas; agent pode agir além do autorizado | Adicionar coluna/indicador [H]/[IA] para cada papel |
| Múltiplos R por tarefa | Responsabilidade difusa; ninguém realmente responsável | Reduzir a exatamente um R por tarefa |
| RACI desatualizado após mudança de processo | Documentação não reflete realidade; confusão na equipe | Revisar RACI a cada mudança significativa de processo |
| IA como Aprovador em tarefas de alto impacto | Decisões críticas tomadas sem supervisão humana | Aprovação é sempre papel humano para impacto alto |
| RACI sem validação com stakeholders | Matrix teórica que não será seguida na prática | Executar passo 3 antes de publicar |

## Avaliação de risco

- **Parar e confirmar quando:** alguma tarefa ficar sem R definido — não publicar RACI incompleto.
- **Risco baixo:** nova categoria de tarefa adicionada sem afetar categorias existentes.
- **Risco médio:** redistribuição de responsabilidades existentes — comunicar a todos os afetados.

## Métricas de sucesso

- Toda tarefa com exatamente um R definido.
- Agentes IA e humanos distinguidos em 100% das linhas da RACI.
- Aprovação humana (A) presente para todas as tarefas de alto impacto.
- RACI revisado ao menos a cada release major.

## Responsável principal

| Papel | Quem |
|-------|------|
| Executor e gerador | Agent (com supervisão) |
| Proprietário e aprovador | Humano (Tech Lead) |

## Referências

- Política de autonomia: `governance-team-ai-human-workflow_V1.0.0`
- Onboarding completo: `governance-team-onboarding_V1.0.0`
- Pasta de saída: `Documentation/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.
