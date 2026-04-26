# Versão interna — `.cursor/Templates/`

**FolderVersion:** 1.1.0 · **Data:** 16/04/2026  
**Política:** [../VERSION.md](../VERSION.md)

Ficheiros-modelo `TEMPLATE_*` (Markdown, HTML, JS) e templates de configuracao IDE (`mirror-config/`). Templates de dono unico movidos para dentro das skills em `.cursor/skills/<skill>/templates/`; templates partilhados (2+ skills) e templates de scripts permanecem na raiz ou em subpastas existentes.

Templates de skill ativos: **`SKILL_TEMPLATE_V2.0.md`** (padrão canônico V2, 17 seções universais + stack-specific); **`AGENT_TEMPLATE_V2.0.md`** (padrão canônico V2, 14 seções). `SKILL_TEMPLATE_V1.0.md` e `SKILL_TEMPLATE_WEB_V1.0.md` removidos (supersedidos pela V2.0).

## Subpastas ativas

| Subpasta | Conteúdo | Consumo |
| -------- | -------- | ------- |
| `build-config/` | Templates de build (dcc32/dcc64/fpc*/dpr/dproj/lpr/lpi/lps) + ignore files | `bootstrap-build-config.ps1` |
| `form-units/` | Templates VCL/FMX/LCL para form units (com cabeçalho Pascal padrão) | `bootstrap-form-unit.ps1` |
| `mirror-config/` | Configs para espelhos (.vscode, .claude, .continue) | `bootstrap-autostart-mirrors.ps1` |
| `source-headers/` | Cabeçalhos padrão para fontes Pascal (referenciado por templates e pela rule `backend-pascal-source-header`) | Manual ou via bootstrap |
| `kit-delphi-fpc_V1.0/`, `kit-vuejs-nodejs_V1.0/` | Kits de projeto referência | Skill `project-init-*` |

## Changelog (este arquivo)

- 1.1.0 (16/04/2026): **FolderVersion** 1.1.0; nova subpasta `source-headers/` com `pascal-unit-header.template` — cabeçalho padrão referenciado pela rule `backend-pascal-source-header_V1.0.0.mdc`; `build-config/` ganhou 4 templates de ignore (`.gitignore.template`, `.claudeignore.template`, `.cursorignore.template`, `.continueignore.template`) consumidos pelo `bootstrap-build-config.ps1` (v1.1.0); templates `form-units/{UNIT_NAME}.vcl|.fmx|.lcl.pas.template` e `build-config/{PROJECT_NAME}.dpr|.lpr.template` prefixam o cabeçalho Pascal padrão.
- 1.0.13 (12/04/2026): **FolderVersion** 1.0.13; Fase 7 — pasta `rules-modelo-orm_V1.0/` deletada; referências stale corrigidas em 6 skills (`project-init-rules-generator`, 4 `documentation-project-*-template`, `documentation-rules_creator`); `Templates/README.md` 1.0.10; ficheiro renomeado de `_V1.0.12.md` para `_V1.0.13.md`.
- 1.0.12 (12/04/2026): **FolderVersion** 1.0.12; Fase 6 migração — `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md` e `TEMPLATE_Docs_LOGICA_DATABASE.md` → `documentation-project-bootstrap_V2.1.0/templates/`; `Templates/README.md` 1.0.9; ficheiro renomeado de `_V1.0.11.md` para `_V1.0.12.md`.
- 1.0.11 (12/04/2026): **FolderVersion** 1.0.11; Fase 5 migração — `TEMPLATE_Docs_Analise.md` → `documentation-analysis-index_V1.1.0/templates/`; `TEMPLATE_Docs_README_Simples.md` → `documentation-readme-hub_V1.1.0/templates/`; `Templates/README.md` 1.0.8; ficheiro renomeado de `_V1.0.10.md` para `_V1.0.11.md`.
- 1.0.10 (12/04/2026): **FolderVersion** 1.0.10; Fase 4 migração — `TEMPLATE_ClassName_Full_Documentation.md` movido para `documentation-class-analysis-generator_V1.1.0/templates/`; `Templates/README.md` 1.0.7 — link actualizado; ficheiro renomeado de `_V1.0.9.md` para `_V1.0.10.md`.
- 1.0.9 (12/04/2026): **FolderVersion** 1.0.9; Fase 3 migração — 11 templates de dono único movidos para skills: `projeto_*_V2.0.mdc` (×4) → `project-init-rules-generator_V1.0.0/templates/`; `TEMPLATE_Docs_Overview.md` → `documentation-overview-architecture_V1.1.0/templates/`; `TEMPLATE_Docs_Arquitetura.md` → `documentation-architecture_V1.1.0/templates/`; `TEMPLATE_Docs_README_Hub.md` → `documentation-readme-hub_V1.1.0/templates/`; `TEMPLATE_Docs_Changelog.md` → `documentation-versioning-changelog_V1.1.0/templates/`; 3 templates HTML → `documentation-portal-html_V1.2.0/templates/`; `Templates/README.md` 1.0.6 — links actualizados; ficheiro renomeado de `_V1.0.7.md` para `_V1.0.9.md`.
- 1.0.8 (12/04/2026): **FolderVersion** 1.0.8; `vscode-tasks.template.json` → 1.3.0 — removidos placeholders `{PROJECT_NAME}`, `{PROJECT_DPR}`, `{FPC_ROOT}`; template usa exclusivamente variáveis nativas VSCode (`${workspaceFolderBasename}`, `${workspaceFolder}`, `${env:FPC_ROOT}`), eliminando substituição por script de bootstrap. `mirror-config/README.md` → 1.0.4.
- 1.0.7 (09/04/2026): **FolderVersion** 1.0.7; limpeza pós-migração V2 — `SKILL_TEMPLATE_V1.0.md` (5 seções, supersedido) e `SKILL_TEMPLATE_WEB_V1.0.md` (template web V1, stack agora integrada no V2.0) removidos; `SKILL_TEMPLATE_V2.0.md` e `AGENT_TEMPLATE_V2.0.md` documentados como templates canônicos; ficheiro renomeado de `_V1.0.6.md` para `_V1.0.7.md`.
- 1.0.6 (04/04/2026): **FolderVersion** 1.0.6; Fase 2 migracao — subpastas de templates por skill owner (`documentation-paste_analysis/`, `documentation-business-rules/`, `documentation-screen-sketches/`, `documentation-roadmap-from-docs/`, `documentation-migration-backup/`) movidas para dentro de cada skill em `.cursor/skills/<skill>/templates/`. Templates partilhados permanecem na raiz. Links em `README.md` actualizados para `../skills/...`.
- 1.0.5 (04/04/2026): **FolderVersion** 1.0.5; templates de dono unico reorganizados em subpastas por skill owner: `documentation-paste_analysis/` (7), `documentation-business-rules/` (1), `documentation-screen-sketches/` (1), `documentation-roadmap-from-docs/` (1), `documentation-migration-backup/` (1). Templates partilhados (2+ skills) permanecem na raiz. Templates de scripts (`build-config/`, `form-units/`, `mirror-config/`) inalterados. README.md e SKILL.md actualizados com novos caminhos.
- 1.0.4 (01/04/2026): **FolderVersion** 1.0.4; ficheiro renomeado para **`templates-pack-manifest_V1.0.4.md`** (nome do ficheiro = FolderVersion SemVer completo; correcção de drift face a entrada de changelog 1.0.4 anterior). Novo **TEMPLATE_ClassName_Full_Documentation.md** (documentacao completa por tipo; alinhado a generator + exemplos ORM).
- 1.0.2 (30/03/2026): Pasta `mirror-config/` com templates de configuracao para espelhos IDE (.vscode, .claude, .continue); seccao "Espelhos e configuracao de ferramentas" em `README.md`; pacote `.cursor` 1.0.9.
- 1.0.1 (30/03/2026): **FolderVersion** 1.0.1; ficheiro renomeado de `VERSION.md` para **`templates-pack-manifest_V1.0.1.md`** (nome do ficheiro = FolderVersion SemVer completo).
- 1.0.0 (30/03/2026): Versão inicial da rubrica de pasta.
