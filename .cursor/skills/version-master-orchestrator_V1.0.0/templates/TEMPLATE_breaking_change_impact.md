# TEMPLATE — Breaking Change Impact Report

**Skill:** `version-breaking-change-guard_V1.0.0`
**Data:** {YYYY-MM-DD}
**Versão alvo:** {vX.Y.Z}
**Autor:** {nome}

---

## 1. Identificação da Mudança

| Campo | Valor |
|-------|-------|
| **Módulo / API afetada** | {módulo ou interface pública} |
| **Tipo de mudança** | {remoção / renomeação / alteração de assinatura / quebra de contrato} |
| **Severidade** | {CRÍTICO / ALTO / MÉDIO} |

---

## 2. Descrição da Mudança

**Antes (estado atual):**

```pascal
{código ou assinatura atual}
```

**Depois (estado proposto):**

```pascal
{código ou assinatura nova}
```

---

## 3. Consumidores Impactados

| Consumidor | Arquivo | Tipo de impacto | Ação necessária |
|------------|---------|-----------------|-----------------|
| {módulo/unit} | {caminho} | {compilação / comportamento / dados} | {ajuste necessário} |

---

## 4. Estratégia de Migração

- [ ] Período de deprecação: {data início} → {data remoção}
- [ ] Alternativa disponível: {sim / não — descrever}
- [ ] Aviso formal: `version-deprecation-policy` aplicada em {data}
- [ ] Guia de upgrade: `version-migration-assistant` em {data}

---

## 5. Decisão

| Campo | Valor |
|-------|-------|
| **Decisão** | {APROVAR / REJEITAR / ADIAR} |
| **Justificativa** | {motivo} |
| **Bump de versão resultante** | {MAJOR — breaking change confirmado} |
| **Aprovado por** | {nome / data} |

---

**FileVersion:** 1.0.0 · **Skill:** `version-breaking-change-guard_V1.0.0`
