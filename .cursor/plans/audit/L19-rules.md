---
name: audit-L19-rules
description: Relatório de auditoria do lote L19 — .cursor/rules/*.mdc (10 arquivos + 1 manifest) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L18-project-quality-version.md
version: 1.0
date: 2026-04-24
scope: 10 rules .mdc + 1 manifest
---

# Relatório Auditoria — Lote L19 rules

**Data:** 24/04/2026
**Escopo:** 10 rules + 1 manifest:

1. `artifact-placement-policy_V1.0.0.mdc`
2. `backend-pascal-source-header_V1.0.0.mdc`
3. `backend-pascal-unit-naming_V1.4.0.mdc`
4. `documentation-migration-plan-mode_V1.0.0.mdc`
5. `local_arquivos_V1.0.mdc`
6. `pack-inventory-autoupdate_V1.0.0.mdc`
7. `project-autostart-bootstrap_V1.0.1.mdc`
8. `project-documentacao_V1.0.1.mdc`
9. `project-plans-persist_V1.0.0.mdc`
10. `scripts-nomenclature_V1.3.0.mdc`
11. `rules-pack-manifest_V1.3.0.md` (manifest)

**Contexto budget consumido:** ~8KB

## Tabela-sumário

| # | Arquivo | Q1-Q7 | N1 | N3 | N4 | N5 | Placement | Achado |
|---|---|---|---|---|---|---|---|---|
| 1 | artifact-placement-policy_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Exemplar — rule canônica da política |
| 2 | backend-pascal-source-header_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Template com placeholders; pode materializar em `.workspace/` |
| 3 | backend-pascal-unit-naming_V1.4.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Genérica; mapa MXX concreto em `.workspace/rules/` (menciona corretamente) |
| 4 | documentation-migration-plan-mode_V1.0.0 | ✅ | ✅ | ⚠ | ✅ | ✅ | .cursor/rules | Nome longo mas claro |
| 5 | local_arquivos_V1.0.mdc | ✅ | ❌ | ⚠ | ⚠ | ❌ | .cursor/rules + .workspace (split) | **N1 crítico**: nome em pt-BR + sem prefixo de família; **N5**: declara-se "template genérico" mas contém paths absolutos `E:\Pacote`; mix conteúdo genérico + instância |
| 6 | pack-inventory-autoupdate_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Exemplar |
| 7 | project-autostart-bootstrap_V1.0.1 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Exemplar |
| 8 | project-documentacao_V1.0.1.mdc | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor/rules | Nome em pt-BR (`documentacao`); template com placeholders; deveria ser `-documentation-` |
| 9 | project-plans-persist_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Exemplar |
| 10 | scripts-nomenclature_V1.3.0 | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor/rules | Exemplar |
| 11 | rules-pack-manifest_V1.3.0.md (manifest) | — | — | — | — | — | .cursor/rules | Manifest — Changelog V1.3.0 de 17/04/2026 |

**Observações globais:**

- **8 rules exemplares** — seguem padrão V2 (frontmatter com `alwaysApply`/`globs`/`description`, "Escopo", "Skills e agents referenciados", regras numeradas).
- **2 rules com N1/N5 problemáticos** — `local_arquivos` (sem prefixo família, paths absolutos) e `project-documentacao` (nome pt-BR divergente).
- **Sufixos de versão inconsistentes** — 8 rules usam SemVer completo `_V1.0.0`; 2 usam `_V1.0` (local_arquivos) e `_V1.0.1` (documentacao). Mais cosmético.

## Detalhe dos achados

### Arquivo 5: `local_arquivos_V1.0.mdc` — **N1 + N5 críticos**

**Achados:**

- **N1 ❌** — sem prefixo de família (`artifact-placement-*`, `backend-pascal-*`, `documentation-*`, `pack-*`, `project-*`, `scripts-*` são todos prefixados).
- **N3 ⚠** — `local_arquivos` em pt-BR com underscore, não segue convenção kebab-case.
- **N4 ⚠** — conceito "arquivos locais" poderia colidir com `backend-pascal-source-header` ou `scripts-nomenclature`.
- **N5 ❌** — description declara "Template canónico — locais de pacotes" mas o corpo contém paths específicos do clone (`E:\Pacote`, etc.) e fala de "regra ativa no workspace". **Mix genérico + instância.** Deveria ser split: (a) template em `.cursor/rules/` com placeholders; (b) instância gerada em `.workspace/rules/local_arquivos_V1.0.mdc` com paths reais do clone.
- **V1.0 vs V1.0.0** — sufixo SemVer incompleto.

**Correção proposta (split):**

```diff
# Renomear para consistência de convenção:
-local_arquivos_V1.0.mdc
+project-local-files-template_V1.0.0.mdc  (em .cursor/rules/)

# Criar instância em .workspace/rules/ (não existe ainda):
+.workspace/rules/providersorm-local-files_V1.0.0.mdc
```

### Arquivo 8: `project-documentacao_V1.0.1.mdc` — **N1 ⚠**

**Achados:**

- **N1 ⚠** — `documentacao` em pt-BR em um pack majoritariamente em EN. Convenção do pack para outras rules é EN (source-header, unit-naming, autostart-bootstrap, plans-persist) ou mista mas consistente.
- **Description linha 4** declara "Template genérico" com placeholders `{PROJECT_NAME}` — ok como template.

**Correção proposta:**

```diff
-project-documentacao_V1.0.1.mdc
+project-documentation-template_V1.0.2.mdc
```

(bump de patch pela correção de idioma)

### Manifesto `rules-pack-manifest_V1.3.0.md`

**Status:** FolderVersion 1.3.0 (17/04/2026). Changelog extensivo registrando todas as mudanças do pack rules. Mantém convenção de "sufixo = FolderVersion SemVer completo".

## Ações acumuladas para execução

### E4-candidatas

Zero.

### E5-candidatas

**Prioridade alta:**

1. `local_arquivos_V1.0.mdc` — split em template (`.cursor/`) + instância (`.workspace/`). Rename para padrão kebab-case + prefixo família.

**Prioridade baixa:**

2. `project-documentacao_V1.0.1.mdc` → `project-documentation-template_V1.0.2.mdc` (N1 idioma).

### E6-candidatas

1. **Sufixos SemVer** — local_arquivos usa `V1.0`, documentacao usa `V1.0.1`. Outras usam `V1.0.0`. Padronizar para SemVer completo sempre.

---

## Síntese do lote L19

- **10 rules + 1 manifest auditados**.
- **8 rules exemplares** — padrão V2 consistente.
- **2 rules com N1/N5** (local_arquivos com split pendente; project-documentacao com pt-BR).
- **Manifesto atualizado** (V1.3.0, 17/04/2026).

**Próxima onda sugerida:** L20 (agents developer-*) — 16 arquivos.

**Commit sugerido:** `docs(audit): relatório lote L19 rules — 10 rules, 8 exemplares, 1 split proposto (local_arquivos), 1 idioma (project-documentacao)`
