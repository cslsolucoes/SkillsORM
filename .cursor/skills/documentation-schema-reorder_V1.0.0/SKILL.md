---
name: documentation-schema-reorder
description: Renumeração atómica e cascata do esquema canónico de RNs (MXX) em Documentation/ + `.cursor/` + `.workspace/`. Usar quando o utilizador pedir para renumerar módulos MXX → MXX+N, inserir novos módulos contíguos, reorganizar a numeração global do projeto, ou quando uma banda de módulos novos precisar ser inserida deslocando os existentes. Triggers — "renumerar módulos", "renumerar MXX", "reestruturar esquema canónico", "inserir banda de módulos", "renumeração em cascata", "schema reorder", "shift MXX".
model: opus
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Esta skill conduz **renumerações atómicas e em cascata** do esquema canónico `MXX` em três áreas: `Documentation/`, `.cursor/` (SSOT) e `.workspace/`. Ela existe separada de `documentation-migration-plan` porque foca num tipo de mudança específico — renumeração global de IDs — que tem requisitos únicos (regex word-boundary, ordem *high-to-low*, dry-run obrigatório, backup triplo e janela de matriz inconsistente) e **não é uma migração de conteúdo**.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## When to use

- Utilizador pede para renumerar módulos (ex.: "renumere M08..M26 → M15..M33").
- Novos módulos precisam ocupar uma banda contígua dentro do esquema existente (ex.: "os 8 novos módulos Operacionais vão em M07..M14").
- Reorganização total da numeração global que afecte Documentation/RegrasNegocio/, ADRs, Roadmaps, matrizes de rastreabilidade, rules/skills que referenciem IDs.
- Trigger explícito: `/schema-reorder`, `/renumerar-mxx`, `/shift-modules`.

## When NOT to use

- Para renomear **conceito** de um módulo sem alterar IDs (ex.: `M07 Documentos e Comunicação` → `M07 Documentos Upload`) → usar `documentation-migration-plan` + edit pontual.
- Para criar apenas 1 módulo novo no fim do esquema (ex.: `M34`) sem deslocar outros → usar `documentation-project-bootstrap` + scaffold directo.
- Para refactor de código Pascal isolado sem impacto em IDs documentais → usar `developer-delphi-programming-oop-naming`.

## Dependências (skills prévias)

| Skill | Papel | Obrigatória? |
|---|---|---|
| `documentation-migration-backup` | Executa o snapshot físico pré-renumeração (Fase 0) | Sim |
| `schema-reorder-governance` | Valida que todas as áreas protegidas estão cobertas por plano aprovado | Sim (antes de Fase 2) |
| `documentation-migration-plan` | Pode ter produzido o plano mestre de renumeração que esta skill executa | Não (recomendada) |

## Workflow obrigatório

**REGRA ABSOLUTA:** Esta skill opera em **plan mode** até à Fase 3. Nada escreve no repositório sem aprovação explícita do utilizador (`"prossiga"` ou equivalente inequívoco) no gate P1b.

### Fase 0 — Backup triplo (pré-condição)

1. **Tag Git** no *main* actual: `pre-schema-reorder-<YYYYMMDD>-<HHmm>`.
2. **Branch dedicada** `chore/schema-reorder-<banda>` criada a partir do *main*.
3. **Snapshot físico** em `Documentation/Backup/Reestruturacao_<versão>_<YYYY-MM-DD>/` com:
   - Cópia integral de `Documentation/`, `.cursor/`, `.workspace/`.
   - `MANIFEST.md` com contagem de ficheiros por pasta.
   - `SHA-256` de pelo menos 5 ficheiros críticos (status, roteamento, matriz).

> **Sem backup triplo, a skill pára.** Não negociável.

### Fase 1 — Análise e mapping

1. Listar **todas** as pastas `RN-MXX - *` em `Documentation/RegrasNegocio/`.
2. Listar **todos** os ficheiros `GestorERP_RN-Mxx-yyy_Mxx_Vz_z_z.md` (nome contém o ID 3 vezes: pasta, ID do documento, módulo owner).
3. Construir mapping explícito `{M08: M15, M09: M16, ..., M26: M33}`.
4. Listar ficheiros que vão receber apenas **substituições de conteúdo**: ADRs, Roadmap, Status, Matriz, README raiz, RNs existentes com refs cruzadas.
5. Listar ficheiros a **excluir** do refactor:
   - `Documentation/Backup/` (snapshots imutáveis).
   - `.workspace/plans/` (histórico de decisões — preserva IDs da época).
   - `legados/` (código legado referencial).
   - `projects/` (binários e código Pascal — refactor separado se aplicável).
   - Manifestos do próprio script (self-skip).
6. Identificar skills/rules em `.cursor/` que usam IDs `MXX` em exemplos ou tabelas — estes são **refactors semânticos** (não só substituição de string).

### Fase 2 — Geração do script `renumber-modules.ps1`

Script em PowerShell com os seguintes parâmetros obrigatórios:

```powershell
param(
  [Parameter(Mandatory)][string]$Mapping,        # "M08:M15,M09:M16,...,M26:M33"
  [Parameter(Mandatory)][string]$RootPath,       # raiz do repositório
  [switch]$Apply,                                # default $false → dry-run
  [string]$BackupRoot,                           # Documentation/Backup/<folder>/
  [string]$SkipPaths = ".cursor/Backup/,Documentation/Backup/,legados/,projects/,.workspace/plans/,CHANGELOG.md",
  [string]$LogFile                               # .workspace/plans/renumber-modules_{dryrun|apply}_<data>.md
)
```

**Regras do script (não-negociáveis):**

1. **Regex de word-boundary ASCII** (não `\b`, porque `_` é word-char em regex e anular `_M08_` nos nomes canónicos):
   ```
   (?<![A-Za-z0-9])M(08|09|1[0-9]|2[0-6])(?![A-Za-z0-9])
   ```
   Este lookaround evita tanto matches parciais (`M080` → não match) quanto ignora underscores adjacentes.
2. **Ordem de rename: high-to-low** (`M26 → M33` primeiro; `M08 → M15` por último).
   Sem isto, renomear `M08 → M15` primeiro colide com o próximo passo `M15 → M22`.
3. **Self-skip do próprio script** — o mapping no `$Mapping` default contém `M08`, `M09`, ..., `M26`; o script tem que se excluir.
4. **Dry-run obrigatório**: se `-Apply` não for passado, nenhuma mudança é feita. Apenas produz relatório `renumber-modules_dryrun_<data>.md` com:
   - Pastas a renomear (antigo → novo).
   - Ficheiros a renomear (antigo → novo).
   - Ficheiros a editar (path + número de substituições esperadas).
   - Total geral de substituições.
5. **Apply atómico**: se `-Apply` for passado, aplicar **todas** as mudanças numa sessão. Em caso de erro a meio, **não** fazer rollback automático — produzir log de erro, manter estado intermediário para o utilizador reverter via `git reset --hard <tag-backup>`.
6. **Log estruturado** `renumber-modules_apply_<data>.md` com contagens por pasta + ficheiro + conteúdo, erros e skips.

### Fase 3 — Dry-run e gate P1b (aprovação humana)

1. Executar o script com `-Apply:$false`.
2. Apresentar o relatório ao utilizador, destacando:
   - Totais esperados (`N pastas · N ficheiros · N conteúdos · N substituições`).
   - Paths de **alto risco** (ADRs numerados, `README_PRIORIDADE_EXECUCAO`, `Roadmap`, `Matriz_Rastreabilidade`).
   - Items excluídos (skip paths).
3. **Aguardar aprovação explícita** do utilizador. Sem isso, a skill pára.
4. Se o utilizador pedir ajustes (ex.: "adiciona `Scripts/` aos skip"), voltar à Fase 2.

### Fase 4 — Apply atómico

1. Verificar que a branch `chore/schema-reorder-<banda>` está activa.
2. Verificar que o snapshot `Documentation/Backup/<folder>/` existe e tem `MANIFEST.md`.
3. Executar o script com `-Apply`.
4. Validar resultados:
   - `find Documentation/RegrasNegocio/ -type d -name 'RN-M*' | wc -l` — conta pastas.
   - `grep -rc 'RN-M\(08\|09\|1[0-9]\|2[0-6]\)-' Documentation/ --exclude-dir=Backup | awk -F: '$2>0'` — zero matches fora de Backup (vestígios).
   - `python3 .cursor/scripts/validate_pack.py` — 0 erros.
5. Commit na branch com mensagem `chore(schema): renumber M<antigo-baixo>..M<antigo-alto> → M<novo-baixo>..M<novo-alto> (P<N>)`.

### Fase 5 — Refactor semântico (skills/rules que usam IDs)

Após a renumeração literal, rever:

1. Skills que mencionam MXX em exemplos → actualizar para novos IDs.
2. Rules que têm tabelas de mapping → bump de versão + nova entrada changelog.
3. Workspace rule `<projectId>-mxx-naming_V*.mdc` → bump + tabela actualizada.
4. Agents que orquestram por MXX → actualizar referências.

> Este passo é **semântico**, não mecânico — requer revisão manual do que faz sentido no contexto novo. O script não cobre isto.

## Artefactos produzidos

- `.cursor/scripts/renumber-modules.ps1` (novo ou actualizado).
- `.workspace/plans/renumber-modules_dryrun_<data>.md`.
- `.workspace/plans/renumber-modules_apply_<data>.md`.
- `Documentation/Backup/Reestruturacao_<versão>_<data>/` (snapshot físico + MANIFEST).
- Branch `chore/schema-reorder-<banda>` com 1 commit (Fase 4).
- Bump de versão do `<projectId>-mxx-naming_V*.mdc` (Fase 5).

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Regex `\b` trata `_` como word-char → falha detectar `_M08_` | Usar lookarounds ASCII explícitos `(?<![A-Za-z0-9])` / `(?![A-Za-z0-9])` |
| Renomear `M08 → M15` antes de `M15 → M22` colide | Ordem obrigatória **high-to-low** |
| Script renumera o próprio mapping | Self-skip em skip paths |
| Backup em `Documentation/Backup/` seria renumerado | Skip path obrigatório |
| Código Pascal em `projects/` fica dessincronizado com doc | Tratar como refactor separado; registar no plano mestre |
| Histórico em `.workspace/plans/` perderia referência aos IDs da época | Skip path — são documentos históricos imutáveis |
| Matriz inconsistente entre dry-run e apply (editor alterou ficheiro entretanto) | Apply só aceita se `git status` está limpo na branch de schema-reorder |

## Critérios de aceite

- Dry-run e apply produzem contagens idênticas (pastas + ficheiros + conteúdos).
- Zero matches de IDs antigos em `Documentation/` (excluindo `Backup/`).
- `validate_pack.py` retorna 0 erros.
- Commit único na branch com diff limpo.
- Plano mestre (`gestorerp-rn-*-split-strategy_V*.md` ou equivalente) actualizado com resultados.
- Backup triplo confirmado em §10 do plano mestre.

## Exemplos

- `exemplos/renumber-m08-m33.md` — exemplo real executado no GestorERP em 2026-04-18 (banda Operacional M07..M14).

## Changelog

- **1.0.0 (18/04/2026):** Versão inicial. Extraída da experiência de P1+P2 do split V2.0.0 do GestorERP (renumeração atómica M08..M26 → M15..M33 com 2 513 substituições, 0 erros). Codifica os 3 fixes técnicos não-triviais descobertos em P1a: regex word-boundary ASCII, self-skip, skip de `.workspace/plans/`.
