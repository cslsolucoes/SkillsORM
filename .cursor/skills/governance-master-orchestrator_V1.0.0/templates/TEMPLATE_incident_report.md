# TEMPLATE — Incident Report (Post-mortem)

**Skill:** `governance-incident-response_V1.0.0`
**INC-ID:** {INC-YYYY-NNN}
**Título:** {título descritivo do incidente}
**Data:** {YYYY-MM-DD}
**Autor:** {nome}

---

## 1. Resumo Executivo

> {3-5 linhas descrevendo o incidente, impacto e resolução — para stakeholders não técnicos}

| Campo | Valor |
|-------|-------|
| **Severidade** | {SEV1 / SEV2 / SEV3} |
| **Duração** | {HH:MM} (início: {HH:MM} → resolução: {HH:MM}) |
| **Usuários impactados** | {estimativa} |
| **Funcionalidades afetadas** | {lista} |
| **Status** | {RESOLVIDO / MONITORANDO / FECHADO} |

---

## 2. Linha do Tempo

| Hora | Evento |
|------|--------|
| {HH:MM} | Incidente detectado — {como: alerta / usuário / monitoramento} |
| {HH:MM} | IC ({nome}) assumiu coordenação |
| {HH:MM} | Causa raiz identificada: {breve descrição} |
| {HH:MM} | Mitigação aplicada: {ação} |
| {HH:MM} | Funcionalidade restaurada |
| {HH:MM} | Incidente encerrado, monitoramento iniciado |

---

## 3. Causa Raiz

**Causa imediata:**

> {O que diretamente causou o incidente}

**Causa raiz:**

> {Por que a causa imediata existia — falha de processo, código, configuração, observabilidade}

**Fatores contribuintes:**

- {fator 1}
- {fator 2}

---

## 4. Impacto

| Área | Impacto |
|------|---------|
| Usuários | {descrição} |
| Dados | {nenhum / descrição de dados afetados} |
| SLA | {SLA cumprido / violação de {N} min} |
| Financeiro | {estimativa ou N/A} |

---

## 5. Ações de Remediação

### Imediatas (já realizadas)

- [x] {ação realizada — ex.: serviço reiniciado}
- [x] {ação realizada}

### Preventivas (follow-up)

| Ação | Responsável | Prazo | Status |
|------|-------------|-------|--------|
| {ação preventiva} | {nome} | {YYYY-MM-DD} | {PENDENTE} |
| {monitoramento adicionado} | {nome} | {YYYY-MM-DD} | {PENDENTE} |

---

## 6. Lições Aprendidas

- {O que funcionou bem na resposta ao incidente}
- {O que pode ser melhorado}
- {Gaps de observabilidade ou processo identificados}

---

**FileVersion:** 1.0.0 · **Skill:** `governance-incident-response_V1.0.0`
