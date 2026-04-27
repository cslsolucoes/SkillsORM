# Versão interna — `.cursor/rules/`

**FolderVersion:** 1.6.5 · **Data:** 26/04/2026
**Política:** [../VERSION.md](../VERSION.md)

Rules activas (12):

- `documentation-migration-plan-mode_V1.0.0.mdc` (alwaysApply)
- **`project-autostart-bootstrap_V1.2.0.mdc` (alwaysApply)** — **V1.2.0 (26/04/2026):** nova FASE 2-A para Skills Project — quando `projectType: skills-pack` em `.workspace/context.json` ou heuristica `.cursor/skills/` populado + sem `.dpr`/`.lpr`, executa `bootstrap-skills-project.ps1` (materializa CLAUDE.md / LICENSE / privacy-policy.md / .workspace/context.json a partir de `.cursor/Templates/skills-project-bootstrap/`) e pula FASE 2/3 Delphi.
- `project-documentacao_V1.0.1.mdc` (template)
- `pack-inventory-autoupdate_V1.0.0.mdc` (`globs: .cursor/**`)
- `project-plans-persist_V1.0.0.mdc`
- `local_arquivos_V1.0.mdc`
- `scripts-nomenclature_V1.3.0.mdc` (`globs: .cursor/scripts/**`)
- **`backend-pascal-unit-naming_V1.6.0.mdc`** (alwaysApply) — **V1.6.0: Connection files naming** — §4.3: ficheiros que criam/abrem conexão a BD ou LDAP/AD usam infixo `<Domain>.Connection.<SubConcept>.pas` + companion `.Interfaces.pas`. Escopo: só criadores (quem faz `TFDConnection.Create`, `IConnection.New`, `Bind` LDAP); consumidores via DI mantêm naming regular.
- `backend-pascal-source-header_V1.0.0.mdc` — globs e campos parametrizados com `{BACKEND_ROOT}` / `{PACKAGES_ROOT}`; leitura de `.workspace/context.json.projectName` para placeholders.
- **`artifact-placement-policy_V1.2.0.mdc` (alwaysApply)** — política de classificação `.cursor/` vs `.workspace/` vs `.docs/`, offline-first de consulta a `pack_index_db.py`, frontmatter obrigatório, nomenclatura `<projectId>-*` em `.workspace/`. **V1.2.0 (26/04/2026):** nova **Regra 4-A — Estrutura espelhada** — `.workspace/` deve adotar o mesmo conjunto de subpastas de `.cursor/` (skills, rules, agents, Templates, commands, plans, scripts).
- **`pascal-encoding-no-escapes_V1.0.0.mdc` (alwaysApply)** — **V1.0.0 (22/04/2026):** proíbe escapes `#NNN`/`#$NNNN` em strings literais Pascal; usar sempre literais UTF-8. Excepções: `#0`, `#9`, `#10`, `#13` e outros caracteres de controlo não imprimíveis. Motivação: escapes gerados automaticamente durante as ondas V1.7.3–V1.7.5.
- **`documentation-file-versioning_V1.0.0.mdc`** — formaliza as 4 formas aceitas de versão em documentos `.md`/`.mdc` (FileVersion, internal_file_version, `**Versão**`, sufixo `_V{X.Y.Z}`); consumido por `check_docs_version`.
- **`local_arquivos_V1.0.mdc`** — política de localização canônica de artefatos (SSOT `.cursor/`, espelhos via symlinks, proibição de edição direta em `.claude/`/`.vscode/`/`.continue/`).

Rules removidas no destacamento standalone:

- ~~`workspace-gestorerp-rn-standard-format_V1.0.0.mdc`~~ — regra exclusiva do esquema RN-MXX multi-módulo de outro projecto; não se aplica a lib single-module.
- ~~`rn-dependency-declaration_V1.0.0.mdc`~~ — idem.

**Commands** (`commands/`): `migration-plan.md`, `sync-cursor-pack.md`, `validate-docs.md`, `consolidar.md`, `syncdb.md`.

## Relação com `.workspace/rules/`

A pasta `.workspace/rules/` (na raiz do workspace, ignorada por git/sync) contém instâncias concretas deste clone:

- `activedirectoryorm-naming_V1.0.0.mdc` — nomenclatura concreta para as units de `src/` do projecto ActiveDirectoryORM (prefixo `ActiveDirectory.*`, camadas Core/Commons/Views, cross-compiler Delphi+FPC). Instância de `backend-pascal-unit-naming_V1.6.0.mdc`.

Quando propagar o pack para outro clone, estas instâncias **não** são copiadas — cada projeto cria as suas em `.workspace/rules/`.

## Changelog (este arquivo)

- 1.6.5 (26/04/2026): **FolderVersion** 1.6.5 — `artifact-placement-policy` bumpada V1.1.0 → V1.2.0: nova **Regra 4-A — Estrutura espelhada** — `.workspace/` deve adotar o mesmo conjunto de subpastas de `.cursor/` (skills, rules, agents, Templates, commands, plans, scripts) quando aplicável; tudo que for relativo exclusivamente ao projeto fica em `.workspace/`. Adicionada categoria `Plans` na tabela de nomenclatura (Regra 4) com convenção `<slug>_v<major>.<minor>.plan.md`. Validação `validate_pack.py` deve verificar correspondência subpasta `.workspace/` ↔ `.cursor/` no V2.x+. Inventário: 12 ficheiros `.mdc` (sem mudança).
- 1.6.4 (26/04/2026): **FolderVersion** 1.6.4 — `project-autostart-bootstrap` bumpada V1.0.1 → V1.2.0: adicionada **FASE 2-A (Skills Project)** — quando `projectType: skills-pack` em `.workspace/context.json` ou heuristica positiva (`.cursor/skills/` populado + sem `.dpr`/`.lpr`), invoca novo script `bootstrap-skills-project.ps1` (em `.cursor/scripts/`) que materializa idempotentemente CLAUDE.md / LICENSE / privacy-policy.md / .workspace/context.json a partir de `.cursor/Templates/skills-project-bootstrap/`. Pula FASE 2/3 Delphi nesse cenário. Gatilho `/init` desativado em Skills Project. Inventário: 12 ficheiros `.mdc` (sem mudança).
- 1.6.2 (22/04/2026): **FolderVersion** 1.6.2 — nova rule `pascal-encoding-no-escapes_V1.0.0.mdc` (`alwaysApply`): proíbe escapes `#NNN`/`#$NNNN` em strings literais Pascal; usar sempre literais UTF-8. Motivação: durante as ondas V1.7.3–V1.7.5 do ActiveDirectoryORM, o assistente gerou escapes decimais em strings portuguesas. Inventário: 10 ficheiros `.mdc` (era 9).
- 1.6.1 (21/04/2026): **FolderVersion** 1.6.1 — destacamento do pack mãe (standalone ActiveDirectoryORM): removidas rules `workspace-gestorerp-rn-standard-format_V1.0.0` (esquema RN-MXX multi-módulo) e `rn-dependency-declaration_V1.0.0` (dependências cruzadas entre RN-MXX); rule `backend-pascal-unit-naming_V1.6.0` neutralizada (exemplos MXX → placeholder genérico); rule `artifact-placement-policy_V1.1.0` idem. Inventário: 9 ficheiros `.mdc` (era 11).
- 1.6.0 (20/04/2026): **FolderVersion** 1.6.0 — **Onda 3b (Connection files naming)**: `backend-pascal-unit-naming` bumpada V1.5.0 → V1.6.0 com nova §4.3 — ficheiros que criam/abrem conexão a BD (SQL Server, MySQL, Postgres, Firebird, SQLite) ou LDAP/AD usam obrigatoriamente o infixo `<Domain>.Connection.<SubConcept>.pas` + companion `.Interfaces.pas` com `I<Domain>Connection<SubConcept>`. Regra aplica-se apenas a criadores (não a consumidores DI). Rationale: grep único (`*.Connection.*.pas`) localiza todos os pontos de bootstrap de conexão — melhora auditabilidade, swap de fakes em testes, e isolamento de credentials/pooling/retry. Inventário: 10 ficheiros `.mdc` (sem mudança).
- 1.5.0 (20/04/2026): **FolderVersion** 1.5.0 — **Onda 3 (Horse-first consolidation)**: `backend-pascal-unit-naming` bumped V1.4.0 → V1.5.0 (`Modulos/Controllers/` plano passa a default; subpastas por framework reservadas para multi-framework real; defines `-DUSE_*` e escolha de framework HTTP passam a decisão da instância `.workspace/`); `artifact-placement-policy_V1.1.0` editada in-place (§Categoria A: texto neutro "ORMs Delphi, servidores HTTP Delphi, stacks frontend" em vez de enumeração com produtos específicos). Instância `.workspace/rules/gestorerp-mxx-naming` bumpada V2.0.0 → V2.1.0 (remove `Controllers/RDW/` + `Controllers/Horse/`; path `-U` de `Controllers\Horse` → `Controllers`). Arquivada skill `.workspace/skills/_archive/gestorerp-mxx-rest-dataware-controllers_V1.0.0/`; novas skills concretas `gestorerp-mxx-horse-controllers_V1.0.0/` e `gestorerp-backend-layering_V1.0.0/`. Fechadas truncaturas documentais em `README.md` (L489) e `CLAUDE.md` (L368); ambos equiparados no §Prerrogativas perenes. `projects/dcc32.cfg §6` ganhou `-DUSE_HORSE` (alinhamento com `dcc64.cfg`). Inventário: 10 ficheiros `.mdc` (sem mudança no inventário).
- 1.4.0 (18/04/2026): **FolderVersion** 1.4.0 — `artifact-placement-policy` bumped V1.0.0 → V1.1.0 (introduz dotfolder `.docs/` na raiz + scope `project` no `pack_index_db.py`); scripts `pack_index_db.py` → 1.1.0 (docstring) e `bootstrap-mirror-symlinks.ps1` (comentário clarificador); command `syncdb.md` → 1.1.0 (três bases); agent `documentation-agent-orchestrator_V1.4.0.md` desambigua `.docs/` vs legacy `Docs/`. Inventário: 10 ficheiros `.mdc` (sem mudança).
- 1.3.0 (17/04/2026): **FolderVersion** 1.3.0 (Onda 2 do refactor) — nova rule `artifact-placement-policy_V1.0.0.mdc` (`alwaysApply`, classificação `.cursor/`/`.workspace/`); `backend-pascal-unit-naming` atualizada V1.3.0 → V1.4.0 com SPLIT (conteúdo MXX migrou para `.workspace/rules/gestorerp-mxx-naming_V1.0.0.mdc`); `backend-pascal-source-header` atualizada FileVersion 1.0.0 → 1.1.0 (globs parametrizados com `{BACKEND_ROOT}`); referência a nova pasta `.workspace/rules/` (ignorada por git). Inventário: 10 ficheiros `.mdc` (era 9 — V1.3.0 de backend-pascal-unit-naming substituída por V1.4.0; +1 nova rule `artifact-placement-policy`).
- 1.2.0 (16/04/2026): **FolderVersion** 1.2.0; nova rule `backend-pascal-source-header_V1.0.0.mdc` — exige cabeçalho padrão em fontes Pascal novas (`projects/**/*.pas, *.dpr, *.lpr`); template canónico em `.cursor/Templates/source-headers/pascal-unit-header.template`; rule `scripts-nomenclature` atualizada V1.2.0 → V1.3.0. Inventário: 9 ficheiros `.mdc`.
- 1.1.0 (15/04/2026): **FolderVersion** 1.1.0; rule `backend-pascal-unit-naming` atualizada V1.2.0 → V1.3.0: adicionada estrutura `Modulos/Services/` + `Controllers/RDW/` + `Controllers/Horse/`; diretivas `USE_HORSE` e `USE_RESTDATAWARE`; tabela de desambiguação `Security.Services.*` × `Commons.Security.Service.*`.
- 1.0.9 (15/04/2026): **FolderVersion** 1.0.9; rule `backend-pascal-unit-naming` atualizada V1.1.0 → V1.2.0: adicionado prefixo `Commons.` obrigatório, convenção `Access.Controller.*`, project file sem prefixo de módulo, política `Core/` encapsulamento, commons policy expandida.
- 1.0.8 (14/04/2026): **FolderVersion** 1.0.8; nova rule `backend-pascal-unit-naming_V1.1.0.mdc` (nomenclatura canônica `ModuleConcept.Feature[.SubFeature].pas`).
- 1.0.7 (11/04/2026): **FolderVersion** 1.0.7; nova rule `scripts-nomenclature_V1.2.0.mdc` (nomenclatura de ficheiros em `.cursor/scripts/`).
- 1.0.6 (09/04/2026): **FolderVersion** 1.0.6; alinhamento nome=FolderVersion.
- 1.0.5 (09/04/2026): **FolderVersion** 1.0.5; migração V2 — adicionadas seções Escopo e Skills e agents referenciados às 3 rules activas.
- 1.0.4 (04/04/2026): **FolderVersion** 1.0.4; ponteiros de 1 linha eliminados.
- 1.0.3 (30/03/2026): Removida secção "Como usar este template" dos 5 ficheiros `project-*_V1.0.1.mdc`.
- 1.0.2 (30/03/2026): Ficheiro renomeado para `rules-pack-manifest_V1.0.2.md` (nome = FolderVersion SemVer completo).
- 1.0.1 (30/03/2026): Rubrica de versionamento interno do pack.
- 1.0.0 (30/03/2026): Versão inicial da rubrica de pasta.
