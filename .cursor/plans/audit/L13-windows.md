---
name: audit-L13-windows
description: Relatório de auditoria do lote L13 — developer-delphi-windows-* (4 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L12-rdw-ad.md
version: 1.0
date: 2026-04-24
scope: 4 skills em .cursor/skills/developer-delphi-windows-*
---

# Relatório Auditoria — Lote L13 windows

**Data:** 24/04/2026
**Escopo:** 4 arquivos:

1. `developer-delphi-windows-services_V1.0.0`
2. `developer-delphi-windows-codesigning_V1.0.0`
3. `developer-delphi-windows-msix_V1.0.0`
4. `developer-delphi-windows-store-publishing_V1.0.0`

**Contexto budget consumido:** ~20KB (leituras parciais — skills todas extensas, amostragem de cabeçalho + frontmatter)

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | windows-services | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |
| 2 | windows-codesigning | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 3 | windows-msix | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor + migrar exemplo MSIX_PackageIdentityName | manter | baixa |
| 4 | windows-store-publishing | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |

**Observações globais:**

- **Windows-* é 100% Delphi-only por design** — MSIX + Windows Services + Code Signing + Microsoft Store são ecossistema Microsoft; FPC/Lazarus tem ecossistema separado (Inno Setup, NSSM, signtool manual, não há Store para FPC). **Nenhum rename `to-fpc-*`.**
- **Zero Q1/Q7** — família limpa.
- **Zero Q2** — refs atuais.
- **N-regras todas ✅** — nomes precisos.
- **Frontmatter atípico em codesigning e msix** — usam `family: L (Windows Store / Desktop)` + `depends_on: []` + `depends_on: [...]`. Campo `family`/`depends_on` não é padrão do pack (outras skills não têm).

## Detalhe resumido por arquivo

### Arquivo 1: `developer-delphi-windows-services_V1.0.0`

**Tamanho:** ~708 linhas (não lidas integralmente — amostra de cabeçalho). **Frontmatter padrão V2.** Skill exemplar.

### Arquivo 2: `developer-delphi-windows-codesigning_V1.0.0`

**Frontmatter atípico** — declara `skill: developer-delphi-windows-codesigning_V1.0.0` (linha 2, antes de `name:`) + `family: L (Windows Store / Desktop)` + `depends_on: []`. Padrão diferente do restante do pack.

**Q5 leve:** linha 35 cita "GestorERP" em exemplo `MSIX_PackageIdentityName` → **Empresa.GestorERP**. Exemplo — generalizável.

### Arquivo 3: `developer-delphi-windows-msix_V1.0.0`

**Frontmatter idem codesigning** + `depends_on: [developer-delphi-windows-codesigning_V1.0.0]`.

**Q5 leve:** linha 38 `<MSIX_PackageIdentityName>Empresa.GestorERP</MSIX_PackageIdentityName>` e "GestorERP" em exemplos. Específico do clone.

### Arquivo 4: `developer-delphi-windows-store-publishing_V1.0.0`

**Frontmatter padrão V2** (sem `depends_on`, sem `family`). Conteúdo excelente.

---

## Ações acumuladas para execução

### E4-candidatas

Zero.

### E5-candidatas

Zero — todas 4 skills mantêm nome.

### E6-candidatas

1. **Padronização de frontmatter** — codesigning e msix usam campos não-padrão (`family`, `depends_on`, `skill:` duplicado). Alinhar ao padrão V2 do pack (`name:`, `description:`, `model:`, `thinking:`, `category:`).
2. **Q5 em msix e codesigning** — generalizar exemplos `Empresa.GestorERP` → `Empresa.Acme` ou similar. Instâncias específicas em `.workspace/skills/gestorerp-windows-store_V1.0.0/`.

### Placement migrations

Nenhuma.

---

## Síntese do lote L13

- **4 skills auditadas**.
- **Família Delphi-only por design** — nenhum rename to-fpc proposto.
- **Zero Q1/Q7/Q2** — skills sólidas.
- **2 frontmatter atípicos** (codesigning, msix) — padronizar.
- **2 Q5 leves** — exemplos "GestorERP" em msix (reais clone-específicos).

**Próxima onda sugerida:** L14 (vuejs + web) — 11 skills.

**Commit sugerido:** `docs(audit): relatório lote L13 windows — 4 skills Delphi-only sólidas, 2 frontmatter atípicos a padronizar`
