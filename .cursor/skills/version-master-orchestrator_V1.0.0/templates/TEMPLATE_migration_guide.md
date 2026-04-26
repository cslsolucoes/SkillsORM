# TEMPLATE — Migration Guide

**Skill:** `version-migration-assistant_V1.0.0`
**De:** {vX.Y.Z}
**Para:** {vX+1.0.0}
**Data:** {YYYY-MM-DD}
**Tempo estimado de migração:** {curto / médio / longo}

---

## Visão Geral

> {Resumo do que mudou nesta versão e por que o upgrade é necessário. 1-3 frases.}

---

## Pré-requisitos

- [ ] {Requisito 1 — ex.: versão mínima do compilador}
- [ ] {Requisito 2 — ex.: dependência atualizada para vY.Z}
- [ ] Backup do projeto realizado
- [ ] Testes de regressão passando na versão anterior

---

## Breaking Changes — Ações Obrigatórias

### BC-01: {Nome da mudança}

**Impacto:** {Descrição do que quebra}

**Antes:**
```pascal
{código antes}
```

**Depois:**
```pascal
{código depois}
```

**Passos:**
1. {Passo concreto 1}
2. {Passo concreto 2}

---

### BC-02: {Nome da mudança}

{repetir estrutura acima para cada breaking change}

---

## Mudanças Não-Breaking (Recomendadas)

| O que fazer | Por que | Prioridade |
|-------------|---------|------------|
| {ação recomendada} | {motivo} | {ALTA / MÉDIA / BAIXA} |

---

## Elementos Deprecated nesta Versão

| Elemento | Alternativa | Removido em |
|----------|-------------|-------------|
| `{elemento}` | `{alternativa}` | {vX+2.0.0} |

---

## Checklist de Migração

- [ ] Backup criado
- [ ] Breaking changes identificados e priorizados
- [ ] BC-01 migrado e testado
- [ ] BC-02 migrado e testado
- [ ] Elementos deprecated substituídos (ou plano registado)
- [ ] Testes de regressão passando na nova versão
- [ ] Build limpo sem warnings de deprecated

---

## Rollback

Se a migração falhar:

1. Restaurar backup do projeto
2. Reverter dependência para {vX.Y.Z}
3. {passo adicional de rollback, se necessário}

---

**FileVersion:** 1.0.0 · **Skill:** `version-migration-assistant_V1.0.0`
