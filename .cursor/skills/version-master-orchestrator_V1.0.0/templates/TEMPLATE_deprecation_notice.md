# TEMPLATE — Deprecation Notice

**Skill:** `version-deprecation-policy_V1.0.0`
**Data de aviso:** {YYYY-MM-DD}
**Versão em que aparece:** {vX.Y.Z}
**Versão de remoção:** {vX+1.0.0 ou data}

---

## Elemento Deprecated

| Campo | Valor |
|-------|-------|
| **Tipo** | {classe / método / função / API / módulo / constante} |
| **Nome** | `{NomeExato}` |
| **Localização** | `{unit/arquivo:linha}` |
| **Deprecated desde** | {vX.Y.Z} |
| **Removido em** | {vX+1.0.0} — {YYYY-MM-DD estimado} |

---

## Motivo da Deprecação

{Explicar por que o elemento está sendo deprecated — problema que resolve, melhoria de design, breaking change necessário, conformidade com nova arquitetura, etc.}

---

## Alternativa Recomendada

**Use em vez disso:**

```pascal
{exemplo de código com a alternativa}
```

| Campo | Valor |
|-------|-------|
| **Elemento substituto** | `{NomeAlternativa}` |
| **Localização** | `{unit/arquivo}` |
| **Disponível desde** | {vX.Y.Z} |

---

## Guia de Migração Rápida

**Antes (deprecated):**

```pascal
{exemplo com o elemento deprecated}
```

**Depois (correto):**

```pascal
{exemplo com a alternativa}
```

Para guia completo: [TEMPLATE_migration_guide.md](./TEMPLATE_migration_guide.md)

---

## Aviso no Código

Adicionar ao elemento deprecated:

```pascal
// @deprecated desde vX.Y.Z — usar {Alternativa} (removido em vX+1.0.0)
// [DEPRECATED] {NomeExato} — ver {NomeAlternativa}
```

---

**FileVersion:** 1.0.0 · **Skill:** `version-deprecation-policy_V1.0.0`
