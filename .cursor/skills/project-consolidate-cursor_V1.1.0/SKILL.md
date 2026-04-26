---
name: project-consolidate-cursor
description: Auditoria completa do pack .cursor/ (skills, rules, agents, commands, Templates, scripts). Executa 6 checks - versionamento (FileVersion/FolderVersion), links Markdown quebrados, estruturação canónica, nomenclatura (scripts-nomenclature, convenção _V{X.Y.Z}/), se /init foi executado (detecta .dpr/.lpr + arquivos de build) e se o autostart foi feito (valida espelhos via bootstrap-mirror-symlinks.ps1 -ValidateOnly). Read-only. Use quando o usuário pedir "consolidar cursor", "consolidar pack" ou "auditar .cursor".
model: sonnet
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-consolidate-cursor

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Auditoria read-only do pack `.cursor/` em 6 dimensões. **Não altera arquivos.** Identifica desvios das convenções do pack e gera relatório Markdown com recomendações acionáveis.

## When to use

- "consolidar cursor" / "consolidar pack" / "/consolidar cursor"
- "auditar .cursor" / "checar o pack"
- Antes de `governance-pack-sync` (sincronização para outros projetos)
- Após criar/renomear skills, rules ou agents
- Como verificação de rotina (weekly check)

## When NOT to use

- Aplicar correções automáticas → esta skill é read-only; ver skills específicas por domínio.
- Validar conteúdo semântico de docs em `Documentation/` → `project-consolidate-documentation`.
- Validar código Pascal em `projects/` → `project-consolidate-source`.
- Reparar symlinks quebrados → `bootstrap-mirror-symlinks.ps1` (sem `-ValidateOnly`).

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-pack-checklist-validation` | Fornece checks V1–V13 dos espelhos (reutilizados no check 6) |
| `governance-pack-versioning-policy` | Define SemVer por ficheiro (base do check 1) |

## Os 6 checks

### Check 1 — Versionamento

Executa `python .cursor/scripts/validate_pack.py` e interpreta:

- `FileVersion` declarado em cada SKILL.md / rule .mdc / agent.md deve bater com o sufixo `_V{X.Y.Z}/` da pasta.
- `FolderVersion` de cada manifesto (`skills-pack-manifest_V*.md`, `rules-pack-manifest_V*.md`, etc.) deve corresponder à contagem real de pastas.
- Changelog consistente: primeira entrada = FileVersion atual.

### Check 2 — Links Markdown

Varre `.cursor/**/*.md`:

- Extrai padrão `\[([^\]]+)\]\(([^)]+)\)`.
- Ignora URLs `http://` / `https://` / âncoras internas `#secao`.
- Para cada link relativo: resolve contra o diretório do arquivo e verifica se o target existe.
- Reporta como FAIL cada link quebrado com `arquivo:linha` e alvo inválido.

### Check 3 — Estruturação

Verifica presença das pastas canónicas:

```text
.cursor/
├── skills/           (com skills-pack-manifest_V*.md)
├── rules/            (com rules-pack-manifest_V*.md)
├── agents/           (com agents-pack-manifest_V*.md)
├── commands/         (com commands-pack-manifest_V*.md)
├── Templates/        (com templates-pack-manifest_V*.md)
├── scripts/          (com scripts-pack-manifest_V*.md)
└── plans/
```

Cada pasta presente + seu manifesto presente = PASS. Manifesto ausente ou com filename drift = FAIL.

### Check 4 — Nomenclatura

Aplica:

- **Rule `scripts-nomenclature_V1.3.0`** — Python: `snake_case.py` com prefixo de `{bootstrap_, sync_, validate_, decompile_, gen_, database_}`. PowerShell: `kebab-case.ps1` com prefixo de `{bootstrap-, sync-, decompile-, database-}`.
- **Convenção SemVer de pastas** — `skills/<nome>_V{X.Y.Z}/`, `rules/<nome>_V{X.Y.Z}.mdc`, `agents/<nome>_V{X.Y.Z}.md`.
- **Manifestos** — nome = FolderVersion (`*-pack-manifest_V{FolderVersion}.md`).

Lista cada arquivo/pasta fora do padrão como FAIL.

### Check 5 — /init executado

Executa:

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1" -ValidateOnly
```

Verifica na raiz do workspace:

- `*.dpr` ou `*.lpr` presente (programa principal).
- `dcc32.cfg`, `dcc64.cfg` (se Delphi).
- `fpc32.opts`, `fpc64.opts` (se FPC/Lazarus).
- `{nome}.dproj` (Delphi) / `{nome}.lpi`, `{nome}.lps` (Lazarus).
- `.gitignore`, `.claudeignore`, `.cursorignore`, `.continueignore` (gerados pelo bootstrap).

Se ausente → FAIL com recomendação "executar `/init` ou `bootstrap-build-config.ps1` interativamente".

### Check 6 — Autostart feito

Executa:

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1" -ValidateOnly
```

Interpreta o output com checks V1–V13 (conforme `governance-pack-checklist-validation`):

- V1: sem referências `Docs/` residuais.
- V2–V4, V13: `.claude/`, `.continue/`, `.vscode/`, `.opencode/` como SymbolicLink.
- V5: ficheiros de cada mirror são symlinks.
- V6: targets resolvem.
- V7: `.cursor/plans/` acessível.
- V8: sem naming antigo `SKILL_V1.0.md`.
- V9: configs protegidos NÃO são symlinks.
- V10: sem refs a planos inexistentes.
- V11: sem "Como usar este template" em rules ativas.
- V12: README.md nos 4 mirrors são SymbolicLink.

Cada V com PASS/FAIL.

## Como executar

### Via slash command

```text
/consolidar cursor                       # roda os 6 checks, stdout
/consolidar cursor --check links         # só links
/consolidar cursor --output Data/rel.md  # grava relatório
```

### Via script diretamente

```powershell
python .cursor/scripts/validate_consolidated.py cursor
python .cursor/scripts/validate_consolidated.py cursor --check version
python .cursor/scripts/validate_consolidated.py cursor --output Data/cursor_audit.md
```

## Outputs

Relatório Markdown com tabela resumo + detalhes + recomendações. Modelo em [exemplos/relatorio.md](exemplos/relatorio.md).

## Checklist de validação

- [ ] Check 1 — Versionamento PASS (0 drifts).
- [ ] Check 2 — Links quebrados PASS (0 broken).
- [ ] Check 3 — Estruturação PASS (7/7 pastas + manifestos).
- [ ] Check 4 — Nomenclatura PASS (0 arquivos fora do padrão).
- [ ] Check 5 — /init executado PASS (projeto detectado + builds OK).
- [ ] Check 6 — Autostart PASS (V1–V13 todos PASS).

## Anti-padrões

| Anti-padrão | Por que errado | Correção |
|-------------|----------------|----------|
| Aplicar fixes sem re-auditar | Validação precisa confirmar que fix resolveu | Re-executar `/consolidar cursor` após correção |
| Ignorar FAILs e prosseguir com sync | Pack inconsistente propaga drift a outros projetos | Resolver todos FAILs antes de `governance-pack-sync` |
| Manter `FileVersion` desalinhado com `_V{X.Y.Z}/` | Breaking discovery e cross-refs | Bump conforme política em `governance-pack-versioning-policy` |

## Integração com o orquestrador (19 critérios totais)

A partir de `validate_consolidated.py V1.1.0` (18/04/2026), o orquestrador cobre **3 alvos** e **19 checks** totais:

| Alvo | Checks | Skill especializada |
|------|-------:|---------------------|
| `cursor`  | 6  | **project-consolidate-cursor** (esta) |
| `docs`    | 7  | `project-consolidate-documentation` |
| `source`  | 6  | `project-consolidate-source` |
| **Total** | **19** | — |

Esta skill trata especificamente dos **6 checks do alvo `cursor`**. Para execução cruzada dos 3 alvos:

```powershell
python .cursor/scripts/validate_consolidated.py all
python .cursor/scripts/validate_consolidated.py all --strict   # WARN = FAIL (exit 1)
```

## Rules T2/T3 relacionadas (referência 18/04/2026)

| Rule | Tier | Escopo | Uso |
|------|------|--------|-----|
| `documentation-file-versioning_V1.0.0` | T2 | `Documentation/**/*.md` | Formaliza 4 formas aceitas de versão (FileVersion, internal_file_version, `**Versão**`, sufixo `_V{X.Y.Z}`) — consumido por `check_docs_version`. |
| `workspace-gestorerp-rn-standard-format_V1.0.0` | T3 | `Documentation/RegrasNegocio/RN-M*/GestorERP_RN-M*.md` | Define 12 secções canónicas + 3 níveis de maturidade (Stub/Draft/Final) — consumido por `check_docs_standard_format`. |

> **Nota T3 e sync:** ao usar `sync-cursor-pack.ps1` para propagar o pack `.cursor/` a outros projetos (ProvidersORM, ParamentersORM, etc.), o script deve **excluir** o padrão `workspace-*` para não replicar regras específicas do GestorERP. Ver `Templates/workspace-gestorerp/README.md` para o contrato T3.

## Referência cruzada

| Recurso | Path |
|---------|------|
| Script orquestrador (3 alvos, 19 checks) | [`.cursor/scripts/validate_consolidated.py`](../../scripts/validate_consolidated.py) |
| Validador do pack | [`.cursor/scripts/validate_pack.py`](../../scripts/validate_pack.py) |
| Bootstrap espelhos | [`.cursor/scripts/bootstrap-mirror-symlinks.ps1`](../../scripts/bootstrap-mirror-symlinks.ps1) |
| Bootstrap build | [`.cursor/scripts/bootstrap-build-config.ps1`](../../scripts/bootstrap-build-config.ps1) |
| Política versioning | [`.cursor/skills/governance-pack-versioning-policy_V1.0.0/`](../governance-pack-versioning-policy_V1.0.0/SKILL.md) |
| Checklist V1–V13 | [`.cursor/skills/governance-pack-checklist-validation_V1.0.0/`](../governance-pack-checklist-validation_V1.0.0/SKILL.md) |
| Rule T2 versioning docs | [`.cursor/rules/documentation-file-versioning_V1.0.0.mdc`](../../rules/documentation-file-versioning_V1.0.0.mdc) |
| Rule T3 formato RN | [`.cursor/rules/workspace-gestorerp-rn-standard-format_V1.0.0.mdc`](../../rules/workspace-gestorerp-rn-standard-format_V1.0.0.mdc) |
| Templates T3 | [`.cursor/Templates/workspace-gestorerp/README.md`](../../Templates/workspace-gestorerp/README.md) |

## Changelog (este arquivo)

- 1.1.0 (18/04/2026): documentação de integração com os 19 critérios do orquestrador (3 alvos: `cursor`/`docs`/`source`); referência às rules T2 `documentation-file-versioning` e T3 `workspace-gestorerp-rn-standard-format`; referência aos templates T3 `workspace-gestorerp/`; ampliação da secção de referência cruzada.
- 1.0.0 (16/04/2026): criação — 6 checks do pack `.cursor/` + reuse de `validate_pack.py` e scripts bootstrap.
