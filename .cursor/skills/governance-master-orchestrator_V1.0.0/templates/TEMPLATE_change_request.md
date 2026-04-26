# TEMPLATE — Change Request

**Skill:** `governance-change-request_V1.0.0`
**CR-ID:** {CR-YYYY-NNN}
**Data:** {YYYY-MM-DD}
**Solicitante:** {nome}
**Aprovador:** {nome}

---

## 1. Identificação

| Campo | Valor |
|-------|-------|
| **Título** | {descrição concisa da mudança} |
| **Tipo** | {funcional / infra / configuração / emergência} |
| **Urgência** | {NORMAL / URGENTE / EMERGÊNCIA} |
| **Ambiente alvo** | {produção / staging / ambos} |
| **Janela de implementação** | {YYYY-MM-DD HH:MM → HH:MM} |

---

## 2. Descrição da Mudança

**O que será alterado:**

> {Descrição técnica precisa — arquivos, configurações, queries, endpoints afetados}

**Motivação:**

> {Por que esta mudança é necessária — issue, requisito, incidente de referência}

---

## 3. Análise de Impacto

| Aspecto | Impacto | Detalhamento |
|---------|---------|--------------|
| Usuários afetados | {nenhum / {N}} | {como} |
| Downtime esperado | {nenhum / {duração}} | {motivo} |
| Sistemas dependentes | {lista ou nenhum} | {como impacta} |
| Dados afetados | {nenhum / descrever} | {volume / tipo} |

**Risco global:** {BAIXO / MÉDIO / ALTO}

---

## 4. Plano de Implementação

| # | Passo | Responsável | Duração estimada |
|---|-------|-------------|-----------------|
| 1 | {passo} | {nome} | {minutos} |
| 2 | {passo} | {nome} | {minutos} |

**Duração total estimada:** {minutos}

---

## 5. Plano de Rollback

**Condição de rollback:** {quando reverter — ex.: erro após passo 2, downtime > X min}

**Passos:**

1. {passo de reversão 1}
2. {passo de reversão 2}

**Tempo de rollback estimado:** {minutos}

---

## 6. Critérios de Sucesso

- [ ] {critério verificável 1 — ex.: endpoint retorna 200}
- [ ] {critério verificável 2}
- [ ] Logs sem erros novos por {N} minutos pós-deploy

---

## 7. Aprovação

| Campo | Valor |
|-------|-------|
| **Status** | {PENDENTE / APROVADO / REJEITADO / CANCELADO} |
| **Aprovado por** | {nome} |
| **Data de aprovação** | {YYYY-MM-DD} |
| **Condições** | {observações do aprovador, se houver} |

---

**FileVersion:** 1.0.0 · **Skill:** `governance-change-request_V1.0.0`
