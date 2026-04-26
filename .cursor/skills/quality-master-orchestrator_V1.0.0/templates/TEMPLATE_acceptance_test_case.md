# TEMPLATE — Acceptance Test Case

**Skill:** `quality-acceptance-testing_V1.0.0`
**Feature:** {nome da feature}
**Issue / Story:** #{número}
**Data:** {YYYY-MM-DD}
**Testador:** {nome}

---

## Critério de Aceite de Referência

> {Copiar ou referenciar os critérios de aceite da spec / issue}

---

## Caso de Teste: {CT-001} — {Título descritivo}

**Cenário:** {Descrição do fluxo sendo testado — ex.: "Usuário cria conexão válida com PostgreSQL"}

**Pré-condições:**

- {Condição 1 — ex.: banco de dados disponível na porta 5432}
- {Condição 2 — ex.: usuário autenticado}

**Passos:**

| # | Ação | Dado de entrada |
|---|------|-----------------|
| 1 | {ação 1} | {dado ou N/A} |
| 2 | {ação 2} | {dado ou N/A} |
| 3 | {ação 3} | {dado ou N/A} |

**Resultado esperado:**

> {Descrição precisa do que deve acontecer — comportamento visível, estado do sistema, mensagem exibida}

**Resultado obtido:** {PASS / FAIL / BLOQUEADO}

**Evidência:** {screenshot / log / link}

**Notas:** {observações relevantes ou bug ID se FAIL}

---

## Caso de Teste: {CT-002} — {Título — cenário alternativo ou de erro}

{Repetir a estrutura acima para cada critério de aceite adicional}

---

## Resultado Consolidado

| Caso | Título | Resultado |
|------|--------|-----------|
| CT-001 | {título} | {PASS / FAIL / BLOQUEADO} |
| CT-002 | {título} | {PASS / FAIL / BLOQUEADO} |

**Decisão final:**

| Campo | Valor |
|-------|-------|
| **Feature aprovada para release?** | {SIM / NÃO / CONDICIONAL} |
| **Condição (se condicional)** | {detalhar o que precisa ser corrigido} |
| **Aprovado por** | {nome / data} |

---

**FileVersion:** 1.0.0 · **Skill:** `quality-acceptance-testing_V1.0.0`
