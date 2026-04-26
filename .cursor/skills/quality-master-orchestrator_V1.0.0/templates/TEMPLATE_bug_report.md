# TEMPLATE — Bug Report

**Skill:** `quality-bug-triage_V1.0.0`
**ID:** {BUG-YYYY-NNN}
**Data:** {YYYY-MM-DD}
**Reportado por:** {nome}

---

## Classificação (Triage)

| Campo | Valor |
|-------|-------|
| **Severidade** | {CRÍTICO / ALTO / MÉDIO / BAIXO} |
| **Prioridade** | {P0 / P1 / P2 / P3} |
| **Tipo** | {funcional / performance / segurança / UI / dados / integração} |
| **Status** | {NOVO / TRIADO / EM ANDAMENTO / AGUARDANDO / RESOLVIDO / FECHADO} |
| **Atribuído a** | {nome / equipe} |
| **Versão afetada** | {vX.Y.Z} |
| **Ambiente** | {produção / staging / desenvolvimento} |

**Definição de severidade:**
- CRÍTICO: sistema inoperante ou perda de dados
- ALTO: funcionalidade principal bloqueada, sem contorno
- MÉDIO: funcionalidade degradada, contorno disponível
- BAIXO: cosmético, edge-case raro

---

## Descrição

**Resumo:** {Uma linha descrevendo o problema}

**Comportamento observado:**

> {O que acontece — mensagem de erro, comportamento incorreto, dado corrompido}

**Comportamento esperado:**

> {O que deveria acontecer}

---

## Reprodução

**Taxa de reprodução:** {sempre / intermitente (~X%) / raramente}

**Passos para reproduzir:**

1. {Passo 1}
2. {Passo 2}
3. {Passo 3 — ponto onde o bug ocorre}

**Pré-condições:**

- {Condição necessária para reproduzir}

---

## Evidências

| Tipo | Link / Descrição |
|------|-----------------|
| Screenshot | {link ou N/A} |
| Log de erro | {trecho ou link} |
| Stack trace | {trecho ou link} |
| Gravação | {link ou N/A} |

---

## Análise de Impacto

| Campo | Valor |
|-------|-------|
| **Módulo(s) afetado(s)** | {lista de módulos} |
| **Usuários/fluxos impactados** | {estimativa} |
| **Workaround disponível** | {sim — descrever / não} |
| **Regressão de versão anterior?** | {sim / não / desconhecido} |

---

## Resolução

**Causa raiz identificada:** {descrever após investigação}

**Fix aplicado em:** {commit / PR / branch}

**Testado em:** {ambiente} · **Data:** {YYYY-MM-DD}

**Notas de fechamento:** {observações relevantes}

---

**FileVersion:** 1.0.0 · **Skill:** `quality-bug-triage_V1.0.0`
