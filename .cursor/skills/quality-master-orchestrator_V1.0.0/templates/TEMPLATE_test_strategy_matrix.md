# TEMPLATE — Test Strategy Matrix

**Skill:** `quality-test-strategy_V1.0.0`
**Feature / Módulo:** {nome}
**Data:** {YYYY-MM-DD}
**Responsável:** {nome}

---

## 1. Escopo da Feature

> {Descrição resumida do que será testado — funcionalidade, módulo, API afetada}

**Critérios de aceite de referência:** {link para spec ou issue}

---

## 2. Riscos Identificados

| Risco | Probabilidade | Impacto | Mitigação via teste |
|-------|:---:|:---:|-----|
| {risco 1} | {ALTA/MÉDIA/BAIXA} | {ALTO/MÉDIO/BAIXO} | {tipo de teste a cobrir} |
| {risco 2} | | | |

---

## 3. Matriz Cenário × Tipo de Teste

| Cenário | Unitário | Integração | Aceite (E2E) | Manual | Prioridade |
|---------|:---:|:---:|:---:|:---:|:---:|
| {cenário 1 — fluxo principal} | ✓ | ✓ | ✓ | | P0 |
| {cenário 2 — caso de borda} | ✓ | | | ✓ | P1 |
| {cenário 3 — tratamento de erro} | ✓ | ✓ | | | P1 |
| {cenário 4 — performance} | | | | ✓ | P2 |

**Legenda:** P0 = bloqueante para release · P1 = importante · P2 = desejável

---

## 4. Estratégia por Camada

### 4.1 Testes Unitários

- **Cobertura alvo:** {80% / críticos apenas / etc.}
- **Framework:** {DUnitX / Vitest / Jest / etc.}
- **Foco:** {lógica de negócio pura, sem I/O}
- **Mocks necessários:** {lista de dependências a mockar}

### 4.2 Testes de Integração

- **Banco de dados:** {real / in-memory / mock}
- **APIs externas:** {real / stub / mock}
- **Foco:** {fluxos end-to-end dentro do módulo}

### 4.3 Testes de Aceite (E2E)

- **Ferramenta:** {manual / automação — especificar}
- **Cenários cobertos:** {lista dos cenários críticos}
- **Critério de aceite:** alinhado com spec de {issue/doc}

---

## 5. Dados de Teste

| Categoria | Descrição | Origem |
|-----------|-----------|--------|
| {dados válidos} | {descrição} | {fixture / banco / gerado} |
| {dados inválidos} | {descrição} | {fixture / gerado} |
| {dados de borda} | {descrição} | {manual} |

---

## 6. Ambiente e Dependências

| Dependência | Versão / Config | Status |
|-------------|-----------------|--------|
| {banco de dados} | {versão} | {disponível / pendente} |
| {serviço externo} | {versão/stub} | {disponível / pendente} |

---

## 7. Definição de "Pronto para Release"

- [ ] Todos os testes P0 passando
- [ ] Cobertura unitária atingida ({meta}%)
- [ ] Zero bugs abertos de severidade CRÍTICA ou ALTA
- [ ] Testes de aceite validados pelo PO/stakeholder
- [ ] Regression guard executado: sem regressões

---

**FileVersion:** 1.0.0 · **Skill:** `quality-test-strategy_V1.0.0`
