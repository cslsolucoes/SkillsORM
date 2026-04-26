# Versão interna — `.cursor/scripts/`

**FolderVersion:** 1.5.1 · **Data:** 26/04/2026
**Política:** [../VERSION.md](../VERSION.md)

Scripts de automação do pack `.cursor/`. Dois conjuntos coexistem: **Python** (cross-platform, canónico) e **PowerShell** (Windows-only, legado compatível).

**Política de nomenclatura** (não é ficheiro em `scripts/`): [scripts-nomenclature_V1.3.0.mdc](../rules/scripts-nomenclature_V1.3.0.mdc).

## Scripts Python (cross-platform) — FileVersion 1.0.x

| Arquivo | FileVersion | Função |
| ------- | :---------: | ------ |
| `bootstrap_autostart_mirrors.py` | 1.2.0 | Auto-start ao abrir pasta — valida espelhos, instala tasks.json e ignore files |
| `bootstrap_mirror_symlinks.py` | 1.0.0 | Cria/valida/repara symlinks dos espelhos (`.claude/`, `.vscode/`, `.continue/`, `.opencode/`) |
| `bootstrap_reset.py` | 1.0.0 | Reset controlado do ambiente de bootstrap |
| `sync_cursor_pack.py` | 1.0.0 | Sincroniza o pack `.cursor/` entre projetos; substituição de `GestorERP` por destino |
| `validate_pack.py` | 1.0.2 | Valida integridade de skills/rules/agents/commands/templates e manifestos |
| `gen_pack_inventory.py` | 1.2.1 | Gera um inventário completo do pack em JSON/Markdown (utilitário on-demand; SSOT de indexação é `.cursor/index.db`) |
| `decompile_chm.py` | 1.1.0 | Descompila `.chm` — Windows (`hh.exe`), Linux/macOS (7-Zip / chmlib); paridade lógica com `decompile-chm.ps1` |
| `database_session_manager.py` | 1.0.0 | Gerência de sessão CLI de bancos — 5 SGBDs (SQL Server, MySQL, SQLite, PostgreSQL, Firebird); cache por SGBD; varredura automática; comando `limpar` com TTL 7 dias |
| `validate_consolidated.py` | 1.0.0 | Orquestrador de consolidação/auditoria — 3 alvos (cursor, docs, source), 6-7 checks cada (versões, links, estrutura, nomenclatura, etc.); relatório Markdown read-only |
| `apply_mit_to_skills.py` | 1.0.0 | Injeta bloco legal MIT (license/copyright/company/author) no frontmatter dos `SKILL.md` em `.cursor/skills/` e `.workspace/skills/`. Migrado de `tools/` em 26/04/2026 |

## Scripts PowerShell (Windows-only) — legado compatível

| Arquivo | FileVersion | Função |
| ------- | :---------: | ------ |
| `decompile-chm.ps1` | 1.0.0 | Descompila `.chm` via `hh.exe` — espelho PowerShell de `decompile_chm.py` |
| `bootstrap-autostart-mirrors.ps1` | 1.0.8 | Equivalente Windows do `bootstrap_autostart_mirrors.py` |
| `bootstrap-mirror-symlinks.ps1` | 1.1.7 | Equivalente Windows do `bootstrap_mirror_symlinks.py` |
| `bootstrap-reset.ps1` | 1.4.0 | Equivalente Windows do `bootstrap_reset.py` |
| `bootstrap-build-config.ps1` | 1.1.0 | Gera/valida arquivos de build do projeto (Delphi/FPC); copia ignore templates no scaffold |
| `bootstrap-form-unit.ps1` | 1.0.0 | Gera form units sob demanda (VCL/FMX/LCL) — sem equivalente Python |
| `bootstrap-skills-project.ps1` | 1.0.0 | Materializa idempotentemente CLAUDE.md / LICENSE / privacy-policy.md / .workspace/context.json a partir de `.cursor/Templates/skills-project-bootstrap/` (Skills Project) — backup automático em `.cursor/Backup/skills-project/<timestamp>/` quando template > materializado |
| `sync-cursor-pack.ps1` | 1.0.1 | Equivalente Windows do `sync_cursor_pack.py` |

## Changelog (este arquivo)

- 1.5.1 (26/04/2026): **FolderVersion** 1.5.1; `bootstrap-skills-project.ps1` ganhou um quinto target — `README.md` (template `README.template.md` com pré-requisitos, ciclo de vida, famílias, agentes, scripts e rules), espelhando o conteúdo da apresentação `.cursor/ApresentationSkillsORM.html`.
- 1.5.0 (26/04/2026): **FolderVersion** 1.5.0; novo script `bootstrap-skills-project.ps1` (1.0.0) — materializa idempotentemente os arquivos paramétricos de raiz de Skills Project (CLAUDE.md, LICENSE, privacy-policy.md, .workspace/context.json) a partir dos templates em `.cursor/Templates/skills-project-bootstrap/`; comparação SemVer entre `internal_template_version` e versão do arquivo materializado para decidir update/no-op/warning; backup automático antes de sobrescrever. Migração: `apply_mit_to_skills.py` movido de `<repo>/tools/` para `.cursor/scripts/` (`parents[1]` → `parents[2]` para manter REPO_ROOT correto).
- 1.4.0 (16/04/2026): **FolderVersion** 1.4.0; novo script `validate_consolidated.py` (1.0.0) — orquestrador de consolidação para 3 alvos (cursor, docs, source) com 6-7 checks cada; reutiliza `validate_pack.py` + `bootstrap-mirror-symlinks.ps1 -ValidateOnly` + `bootstrap-build-config.ps1 -ValidateOnly`; suporta `--check <dim>` e `--output <file>`; associado à skill `project-consolidate-orchestrator` e ao command `/consolidar`.
- 1.3.0 (16/04/2026): **FolderVersion** 1.3.0; novo script `database_session_manager.py` (1.0.0) — gerência de sessão CLI de 5 SGBDs com cache por pasta de SGBD, varredura automática, renovação 15 min e comando `limpar` com TTL 7 dias; política de nomenclatura atualizada para `scripts-nomenclature_V1.3.0.mdc` (prefixo Python `database_*`); `bootstrap-build-config.ps1` → 1.1.0 (copia ignore templates).
- 1.2.4 (12/04/2026): **FolderVersion** 1.2.4; `gen_pack_inventory.py` → 1.2.1 — `_generated` usa `date.today().isoformat()` em vez de string hardcoded.
- 1.2.3 (12/04/2026): **FolderVersion** 1.2.3; `bootstrap_autostart_mirrors.py` → 1.2.0 e `bootstrap-autostart-mirrors.ps1` → 1.0.8 — removida substituição de placeholders `{PROJECT_NAME}`, `{PROJECT_DPR}`, `{FPC_ROOT}` em `install_tasks_template`; template agora usa variáveis nativas VSCode (`${workspaceFolderBasename}`, `${env:FPC_ROOT}`) sem intervenção de script.
- 1.2.2 (11/04/2026): Política de nomenclatura migrada para rule [scripts-nomenclature](../rules/scripts-nomenclature_V1.3.0.mdc) (à data: V1.2.0; actual: V1.3.0); removida entrada obsoleta do inventário como ficheiro em `scripts/`.
- 1.2.1 (11/04/2026): Nomes canónicos `bootstrap_autostart_mirrors.py` e `bootstrap-autostart-mirrors.ps1` (política em `scripts-nomenclature_V1.0.md`, hoje `scripts-nomenclature_V1.2.0.mdc`).
- 1.2.0 (11/04/2026): Nomenclatura padronizada — validate_pack.py, gen_pack_inventory.py; novo scripts-nomenclature_V1.0.md.
- 1.1.0 (10/04/2026): `decompile_chm.py` 1.1.0 — backends multiplataforma (hh / 7z / chmlib); `decompile-chm.ps1` no manifesto.
- 1.1.0 (09/04/2026): Manifesto inicial da pasta `scripts/` — 6 scripts Python cross-platform adicionados; `gen_pack_inventory.py` como utilitário de inventário; FolderVersion 1.1.0 marca a adição do conjunto Python.
- 1.0.0 (legado): Apenas scripts PowerShell (sem manifesto formal).
