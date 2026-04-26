# Template V2.0 — AGENT.md

> Use este template ao criar ou migrar agents para o padrão V2.
> Caminho do agent: `.cursor/agents/<nome-agent>_V{MAJOR.MINOR.PATCH}.md`
> Seções marcadas com `← NOVO` não existem no template V1 e devem ser adicionadas.
> Remova este bloco de instruções ao criar o agent real.

---

```yaml
---
name: <grupo>-agent-<papel>
description: <uma linha: responsabilidade principal deste agent>
model: <opus|sonnet|haiku>
---
```

**Padrão de nome:** `{grupo}-agent-{papel}_V{MAJOR.MINOR.PATCH}.md`
- `{grupo}`: `doc` (documental) | `dev` (implementação)
- `{papel}`: `orchestrator` | `<domínio>-expert` | `<especialidade>`

---

# <Nome Legível do Agent>

## Categoria  ← NOVO

`<categoria>` — breve descrição do domínio de atuação deste agent.

## Responsabilidade única  ← NOVO

> Um parágrafo (3-5 frases). Descrever **qual problema** este agent coordena e por que
> ele existe separado dos demais. Não repetir o campo `description` do frontmatter.

## When to use

- Situação 1 que dispara este agent
- Situação 2 ...

## When NOT to use

- Situação A → usar `<outro-agent>` em vez deste
- Situação B → delegar diretamente a skill `<nome-skill>` sem passar por este agent

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| `<campo>` | `<tipo>` | Descrição e restrições |

## Dependências (agents/skills)

| Dependência | Tipo | Quando necessário |
|-------------|------|-------------------|
| `<agent/skill>` | agent / skill | Pré-condição ou colaboração |

## Skills que este agent opera  ← NOVO

| Skill | Quando invoca |
|-------|---------------|
| `<nome-skill>` | Condição ou fase em que esta skill é chamada |
| `<nome-skill>` | ... |

## Fluxo de decisão  ← NOVO

| Tipo de decisão | Quem decide |
|----------------|-------------|
| **Automático** (executa sem confirmação) | Descrição das ações autônomas |
| **Confirmação humana** (pausa e aguarda) | Situações que exigem aprovação |
| **Humano** (fora do escopo do agent) | O que o agent NÃO decide |

## Workflow

1. Passo 1 — ação ativa (verbo no imperativo)
2. Passo 2 — ...
3. Passo 3 — ...

## Outputs

| Output | Localização | Descrição |
|--------|-------------|-----------|
| `<artefato>` | `<path>` | O que este agent entrega |

## Limites de atuação  ← NOVO

Este agent **NÃO** deve:
- Tomar decisão X sem aprovação humana
- Modificar Y fora do escopo Z
- Escalar para agent W sem confirmação

## Anti-padrões  ← NOVO

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Erro comum 1 que este agent comete | Consequência | Correção |
| Erro comum 2 | Consequência | Correção |

## Métricas de sucesso  ← NOVO

- Indicador 1: como saber que o agent executou corretamente
- Indicador 2: sinal de que o resultado está completo

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 2.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 2.0.0 (DD/MM/AAAA): Migração V2 — adicionadas seções Categoria, Responsabilidade única,
  Skills que opera, Fluxo de decisão, Limites de atuação, Anti-padrões, Métricas de sucesso.
- X.Y.Z (DD/MM/AAAA): entrada anterior (preservar histórico).

---

<!-- INSTRUÇÕES DE USO DESTE TEMPLATE (remover ao criar agent real)

BUMP DE VERSÃO:
  Migração (nova seção = retrocompatível) → bump MINOR (ex.: 1.1.4 → 1.2.0)
  Agent novo                              → iniciar em 1.0.0
  Correção de bug em seção existente      → bump PATCH

CHECKLIST DE VALIDAÇÃO APÓS MIGRAÇÃO:
  [ ] Tabela "Skills que este agent opera" presente e completa
  [ ] "Limites de atuação" com pelo menos 2 restrições explícitas
  [ ] "Fluxo de decisão" com as 3 categorias (Automático / Confirmação / Humano)
  [ ] Pasta renomeada para nova versão (_V2.0.0 ou maior)
  [ ] Entrada de changelog adicionada

-->
