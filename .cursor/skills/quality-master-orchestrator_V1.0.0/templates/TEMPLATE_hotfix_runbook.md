# TEMPLATE — Hotfix Runbook

**Skill:** `quality-hotfix-workflow_V1.0.0`
**Incidente:** {INC-YYYY-NNN}
**Data de início:** {YYYY-MM-DD HH:MM}
**Responsável (IC):** {nome}
**Comunicação:** {canal Slack / e-mail / etc.}

---

## 1. Contexto do Incidente

| Campo | Valor |
|-------|-------|
| **Ambiente** | {produção / staging} |
| **Versão afetada** | {vX.Y.Z} |
| **Severidade** | {CRÍTICO / ALTO} |
| **Usuários impactados** | {estimativa} |
| **Bug de referência** | {BUG-YYYY-NNN} |
| **Descrição** | {uma linha do problema} |

---

## 2. Diagnóstico

**Sintoma observado:**

> {O que está quebrando — erro, comportamento, dados afetados}

**Causa raiz identificada:**

> {Preencher após análise — antes de prosseguir para a correção}

**Arquivos / módulos afetados:**

- `{caminho/arquivo}` — {motivo}

---

## 3. Estratégia de Correção

**Opção escolhida:**

- [ ] Hotfix direto em produção (branch `hotfix/INC-NNN`)
- [ ] Rollback para versão anterior ({vX.Y.(Z-1)})
- [ ] Feature flag desativada (sem deploy)

**Justificativa:** {motivo da escolha}

---

## 4. Plano de Execução

| # | Passo | Responsável | ETA | Status |
|---|-------|-------------|-----|--------|
| 1 | Criar branch `hotfix/INC-NNN` de `main` | {nome} | {HH:MM} | |
| 2 | Aplicar fix mínimo ({descrever}) | {nome} | {HH:MM} | |
| 3 | Testes de smoke na branch | {nome} | {HH:MM} | |
| 4 | Code review urgente (1 aprovador) | {nome} | {HH:MM} | |
| 5 | Merge em `main` + tag `vX.Y.(Z+1)` | {nome} | {HH:MM} | |
| 6 | Deploy em produção | {nome} | {HH:MM} | |
| 7 | Validação pós-deploy | {nome} | {HH:MM} | |
| 8 | Comunicação de resolução | {nome} | {HH:MM} | |
| 9 | Cherry-pick para branch de desenvolvimento | {nome} | {HH:MM} | |

---

## 5. Validação Pós-Deploy

- [ ] Sintoma original não reproduzível
- [ ] Logs sem novos erros relacionados
- [ ] Métricas normalizadas (taxa de erro, latência)
- [ ] Usuários confirmaram normalização (se aplicável)

**Validado às:** {YYYY-MM-DD HH:MM} por {nome}

---

## 6. Plano de Rollback

Se o hotfix agravar o problema:

1. {Passo de rollback 1 — ex.: reverter deploy para vX.Y.Z}
2. {Passo de rollback 2}
3. Notificar equipe e stakeholders

**Decisor de rollback:** {nome} · **Critério:** {condição que dispara rollback}

---

## 7. Post-mortem

| Campo | Valor |
|-------|-------|
| **Data do post-mortem** | {YYYY-MM-DD} |
| **Causa raiz final** | {descrever} |
| **Duração do incidente** | {HH:MM} |
| **Ações preventivas** | {lista de melhorias para evitar recorrência} |
| **Tasks criadas** | {links para issues de follow-up} |

---

**FileVersion:** 1.0.0 · **Skill:** `quality-hotfix-workflow_V1.0.0`
