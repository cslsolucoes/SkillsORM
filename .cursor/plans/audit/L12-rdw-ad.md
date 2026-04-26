---
name: audit-L12-rdw-ad
description: Relatório de auditoria do lote L12 — REST-DataWare + Active Directory (8 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L11-providers-infra.md
version: 1.0
date: 2026-04-24
scope: 8 skills em .cursor/skills/developer-delphi-rest-dataware-* e developer-delphi-active-directory-*
---

# Relatório Auditoria — Lote L12 REST-DataWare + Active Directory

**Data:** 24/04/2026
**Escopo:** 8 arquivos na família:

**REST-DataWare (4 skills):**
1. `developer-delphi-rest-dataware-orchestrator_V1.0.0`
2. `developer-delphi-rest-dataware-expert_V1.0.0`
3. `developer-delphi-rest-dataware-estrutura_V1.0.0`
4. `developer-delphi-rest-dataware-roteiro_V1.0.0`

**Active Directory (4 skills):**
5. `developer-delphi-active-directory-orchestrator_V1.0.0`
6. `developer-delphi-active-directory-expert_V1.0.0`
7. `developer-delphi-active-directory-estrutura_V1.0.0`
8. `developer-delphi-active-directory-roteiro_V1.0.0`

**Contexto budget consumido:** ~35KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | rest-dataware-orchestrator | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-rest-dataware-master-orchestrator | média |
| 2 | rest-dataware-expert | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor + ref .workspace | developer-delphi-to-fpc-rest-dataware-framework | média |
| 3 | rest-dataware-estrutura | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-rest-dataware-file-structure | baixa |
| 4 | rest-dataware-roteiro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-rest-dataware-guide | baixa |
| 5 | active-directory-orchestrator | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ⚠ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-active-directory-master-orchestrator | média |
| 6 | active-directory-expert | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-active-directory-framework | média |
| 7 | active-directory-estrutura | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-active-directory-file-structure | baixa |
| 8 | active-directory-roteiro | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-active-directory-guide | baixa |

**Observações globais:**

- **Zero Q1/Q7** — famílias totalmente limpas de `{$IFDEF FPC}` anti-padrão.
- **Zero Q2** — todas as refs atualizadas (name no frontmatter, refs cruzadas para skills `developer-delphi-*` corretas).
- **2 orquestradores com N3 ❌** — mesmo padrão recorrente `orchestrator` genérico. Propor `-master-orchestrator`.
- **Skill active-directory-orchestrator** — frontmatter linha 2 declara `name: developer-delphi-active-directory` (sem `-orchestrator`) enquanto a pasta é `developer-delphi-active-directory-orchestrator_V1.0.0`. **Incongruência de name**, embora não seja Q2 formal (refs consumidoras usam o nome frontmatter ou o nome da pasta — padrão SDK aceita ambos). Registrar para padronização.
- **2 expert com N3 ⚠** — `-expert` genérico (mesmo padrão de `documentation-project-expert` já analisado em L09). Propor `-framework` (documenta o framework como um todo).
- **2 estrutura + 2 roteiro com N3 ⚠** — termos pt-BR `estrutura`/`roteiro` são ambíguos em um pack bilíngue. Propor `-file-structure` e `-guide`.
- **Paths relativos com placeholders** (`{ACTIVE_DIRECTORY_ORM_ROOT}`, `{REST_DATAWARE_ROOT}`, `{BACKEND_ROOT}`) — padrão exemplar de resolver via `.cursor/config.json._frameworks` + override em `.workspace/context.json`. **Modelo a propagar para outras skills do pack.**
- **3 skills do AD + 1 do RDW mencionam GestorERP** — em contexto apropriado (MXX patterns referenciados via `.workspace/skills/gestorerp-*`), o que é exemplar de separação.

## Detalhe resumido por arquivo

### Arquivos 1-4: `developer-delphi-rest-dataware-*` (4 skills)

**Padrão:** 3 expert-estrutura-roteiro + 1 orchestrator — estrutura típica de família que documenta framework terceiro.

**Achados comuns:**

- **N2** ⚠ em todos — frameworks RDW V2.1 são Delphi 7+ + FPC 3.0+ (RN-M00-001, linha 135 de estrutura). Cross-compile explícito. Rename `to-fpc-*` alta confiança.
- **N3** ⚠/❌ — `orchestrator` sozinho (1 skill), `expert`/`estrutura`/`roteiro` genéricos (3 skills).
- **Q3, Q4, Q6, Q7** ✅ — conteúdo substantivo (5 camadas, 11 componentes, 9 drivers, 5 transportes, 25 RNs).
- **Q5 leve** em expert (linhas 240-243 referencia MXX GestorERP mas aponta para `.workspace/` — correto).

**Correção sugerida:**

```diff
@@ rest-dataware-expert — já bem-estruturada, apenas N2/N3
(rename para developer-delphi-to-fpc-rest-dataware-framework)
```

### Arquivos 5-8: `developer-delphi-active-directory-*` (4 skills)

**Padrão:** idêntico ao RDW (3 expert-estrutura-roteiro + 1 orchestrator).

**Achados específicos:**

- **active-directory-orchestrator** — incongruência: `name: developer-delphi-active-directory` no frontmatter mas pasta `developer-delphi-active-directory-orchestrator_V1.0.0`. Fix necessário.
- **Q5 ⚠** em orchestrator/expert/estrutura — menção explícita a GestorERP e `Infrastructure/Integrations/ActiveDirectory/` (`{BACKEND_ROOT}`). Mas **corretamente** resolvido via placeholder `{BACKEND_ROOT}` de `.workspace/context.json`. Não é Q5 grave.
- **N2** ⚠ — framework AD usa Synapse (cross-compile Delphi+FPC).
- **N3** idem RDW.

**Correção sugerida:**

```diff
@@ active-directory-orchestrator linha 2 (corrigir name)
-name: developer-delphi-active-directory
+name: developer-delphi-active-directory-orchestrator
```

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma.

### E4-candidatas (Q1/Q7)

**Zero** — famílias limpas.

### E5-candidatas (renames propostos)

**Prioridade média:**

1. `developer-delphi-rest-dataware-orchestrator` → `developer-delphi-rest-dataware-master-orchestrator` (N3).
2. `developer-delphi-rest-dataware-expert` → `developer-delphi-to-fpc-rest-dataware-framework` (N2+N3).
3. `developer-delphi-active-directory-orchestrator` → `developer-delphi-active-directory-master-orchestrator` (N3).
4. `developer-delphi-active-directory-expert` → `developer-delphi-to-fpc-active-directory-framework` (N2+N3).

**Prioridade baixa:**

5. `developer-delphi-rest-dataware-estrutura` → `developer-delphi-to-fpc-rest-dataware-file-structure` (N2+N3 — pt→en).
6. `developer-delphi-rest-dataware-roteiro` → `developer-delphi-to-fpc-rest-dataware-guide` (N2+N3 — pt→en).
7. `developer-delphi-active-directory-estrutura` → `developer-delphi-to-fpc-active-directory-file-structure` (N2+N3).
8. `developer-delphi-active-directory-roteiro` → `developer-delphi-to-fpc-active-directory-guide` (N2+N3).

### E6-candidatas (Q2/Q3/Q4/Q5/Q6)

1. **active-directory-orchestrator:2** — corrigir `name: developer-delphi-active-directory` → `developer-delphi-active-directory-orchestrator` (congruência pasta↔frontmatter).
2. **Adoção do padrão placeholder `{FRAMEWORK_ROOT}`** — estas 8 skills modelam uso correto de `.cursor/config.json._frameworks` + override `.workspace/context.json`. Propagar padrão para outras skills com paths absolutos (ex.: L01 architecture-and-design, L10 performance-and-architecture).

### Placement migrations

Nenhuma.

---

## Síntese do lote L12

- **8 skills auditadas** com detalhe.
- **Zero Q1/Q7** + **Zero Q2** — famílias exemplares em consistência interna.
- **8 renames propostos** (4 média, 4 baixa prioridade).
- **Padrão placeholder** `{FRAMEWORK_ROOT}` exemplar para propagar.
- **1 incongruência name/pasta** em active-directory-orchestrator.

**Próxima onda sugerida:** L13 (windows-*) — 4 skills.

**Commit sugerido:** `docs(audit): relatório lote L12 RDW + AD — 8 skills limpas, 8 renames (4 master-orchestrator + 4 pt→en), 1 incongruência name`
