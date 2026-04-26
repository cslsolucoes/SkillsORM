**Localização canónica (neste repositório):** `.cursor/Templates/` — ficheiros-modelo para criar documentação em **`Analise/`** e **`Documentation/`** (raiz documental canónica; `Docs/`/`docs/` na raiz devem ser renomeados para `Documentation/` quando aplicável). Copiar o ficheiro `TEMPLATE_*` correspondente para o destino final, preencher os campos `{…}` e registar o link no índice do módulo ou no hub `Documentation/README_Vx.y.md`.

---

## Kits de projeto (referência)

| Pasta | Descrição |
| --- | --- |
| **kit-delphi-fpc_V1.0/** | Kit mínimo Delphi/FPC (antes na raiz do repositório). |
| **kit-vuejs-nodejs_V1.0/** | Kit VueJS/NodeJS (antes na raiz do repositório). |

---

## Espelhos e configuracao de ferramentas

Os espelhos (`.claude/`, `.vscode/`, `.continue/`, `.opencode/`) sao vistas de `.cursor/` criadas por ligacoes simbolicas. Os ficheiros de configuracao especificos de cada IDE/ferramenta existem como **ficheiros reais** (nao symlinks) e podem ser inicializados a partir dos templates abaixo (inclui **`opencode.json`** na raiz do repositorio).

### Bootstrap

Correr **[bootstrap-mirror-symlinks.ps1](../scripts/bootstrap-mirror-symlinks.ps1)** em terminal elevado (Administrador) para criar todos os symlinks. Modos disponiveis: `-ValidateOnly`, `-Repair`, `-Force`.

### Templates de configuracao (`mirror-config/`)

| Template | Destino | Tipo |
| -------- | ------- | ---- |
| `vscode-settings.template.json` | `.vscode/settings.json` | Ficheiro real (copiar) |
| `vscode-tasks.template.json` | `.vscode/tasks.json` | Ficheiro real (copiar) |
| `vscode-extensions.template.json` | `.vscode/extensions.json` | Ficheiro real (copiar) |
| `claude-settings.template.json` | `.claude/settings.json` | Ficheiro real (copiar) |
| `claude-settings-local.template.json` | `.claude/settings.local.json` | PRIVADO (copiar, nao versionar) |
| `opencode.json.template` | `opencode.json` (raiz) | OpenCode — instrucoes e watcher |
| `continue-stub.template.md` | `.continue/` | Stub para futura configuracao |

**Quando copiar vs quando usar symlink:**

- **Copiar:** ficheiros de configuracao especificos da IDE (paths locais, extensoes, permissoes).
- **Symlink:** conteudo partilhado de `.cursor/` (rules, skills, agents, templates, etc.).

Ver [mirror-config/README.md](mirror-config/README.md) para detalhes de placeholders.

---

## Templates para `Analise/`

### Skill owner: `documentation-class-analysis-generator_V1.1.0/templates/`

> **Nota:** Template movido para dentro da skill em `.cursor/skills/documentation-class-analysis-generator_V1.1.0/templates/`.

| Template | Quando usar |
| --- | --- |
| [TEMPLATE_ClassName_Full_Documentation.md](../skills/documentation-class-analysis-generator_V1.1.0/templates/TEMPLATE_ClassName_Full_Documentation.md) | **Documentacao completa** por tipo (mesmo `{ClassName}.md`): cabecalho rico (unit, modulo, diretiva, GUID opcional), **O que e?**, **Caracteristicas**, **Engine**, **Funcionalidades** (tabelas de metodos), **Aplicabilidades**, **Exemplos de Uso**, **Relacionamentos**; secoes opcionais **Fluxo interno**, **Campos internos**, **Metodos privados**, **Codigos de Erro**. Alinhado a **documentation-class-analysis-generator** e a exemplos ORM (`IAttributeMapper`, `TEntityManager`). **Skill owner: `documentation-class-analysis-generator` — em `skills/.../templates/`** |

### Skill owner: `documentation-paste_analysis_unit_class_method_V1.2.0/templates/`

> **Nota:** Estes templates foram movidos para dentro da skill em `.cursor/skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/`.

| Template | Quando usar |
| --- | --- |
| [TEMPLATE_Unit_ClassName.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_Unit_ClassName.md) | **Scaffold minimo** de classe/interface (`{ClassName}.md` — nome base sem `T`/`I`): responsabilidade, campos/metodos resumidos, criterios de aceite. |
| [TEMPLATE_README_Modulo.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_README_Modulo.md) | Novo **README de módulo** (hub da subpasta, ex.: `Analise/Connections/README.md`). |
| [TEMPLATE_ESPECIFICACAO_Modulo.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_ESPECIFICACAO_Modulo.md) | Novo documento de **especificação de módulo** (`ESPECIFICACAO_{MODULO}.md`). Cobre estrutura de arquivos, diretivas, dependências e checklist de manutenção. |
| [TEMPLATE_CHECKLIST_IMPLEMENTACAO.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_CHECKLIST_IMPLEMENTACAO.md) | Novo **checklist de implementação** com ordem de dependências e critérios de conclusão por item. |
| [TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md) | Novo **meta-documento de diagnóstico e organização** (10 capítulos): guia operacional, modelo alvo/decisão, inventário DPR, inventário escopo vs `src`, matriz de migração, diagnóstico RN/semântica/lógica, relatório de conformidade, Fase D (skill paste), scaffolding e changelog consolidado. Substitui os oito templates meta-documentais anteriores. |
| [TEMPLATE_PASSO_A_PASSO.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_PASSO_A_PASSO.md) | Novo **roteiro passo a passo** para implementar ou recriar uma lógica. |
| [TEMPLATE_O_QUE_FALTA.md](../skills/documentation-paste_analysis_unit_class_method_V1.2.0/templates/TEMPLATE_O_QUE_FALTA.md) | Novo **documento de pendências** (`O_QUE_FALTA_100_PORCENTO.md`) — mapa completo `.cursor`/`src/`, checklist por categoria e sprint imediato. |

---

## Templates para `Docs/`

### Markdown

| Template | Quando usar |
| --- | --- |
| [TEMPLATE_Docs_README_Simples.md](../skills/documentation-readme-hub_V1.1.0/templates/TEMPLATE_Docs_README_Simples.md) | Hub de **referência rápida** (`Docs/README.md`) — índice curto sem versionamento, aponta para o hub versionado. **Skill owner: `documentation-readme-hub` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_README_Hub.md](../skills/documentation-readme-hub_V1.1.0/templates/TEMPLATE_Docs_README_Hub.md) | Hub **versionado e completo** (`Docs/README_Vx.y.md`) — índice de documentos canônicos, status por subpasta, backlog e regras de operação. **Skill owner: `documentation-readme-hub` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Analise.md](../skills/documentation-analysis-index_V1.1.0/templates/TEMPLATE_Docs_Analise.md) | Novo documento em `Docs/Analise/` (`Analise_{Escopo}_Vx.y.md`). **Skill owner: `documentation-analysis-index` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Overview.md](../skills/documentation-overview-architecture_V1.1.0/templates/TEMPLATE_Docs_Overview.md) | Novo documento de **visão geral do projeto** (`Documentation/Overview/{Projeto}_Overview_Vx.y.md`) — padrão 5 secções por módulo. **Skill owner: `documentation-overview-architecture` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Arquitetura.md](../skills/documentation-architecture_V1.1.0/templates/TEMPLATE_Docs_Arquitetura.md) | Novo documento em `Docs/Arquitetura/` (`Arquitetura_{Projeto}_Vx.y.md`). **Skill owner: `documentation-architecture` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_RN.md](../skills/documentation-business-rules_V3.1.0/templates/TEMPLATE_Docs_RN.md) | Novo documento em `Docs/Regras de Negocio/` (`RN_{Projeto}_Vx.y.md`). **Skill owner: `documentation-business-rules` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Roadmap.md](../skills/documentation-roadmap-from-docs_V1.1.0/templates/TEMPLATE_Docs_Roadmap.md) | Novo documento em `Docs/Roadmap/` (`Roadmap_FaseN_Vx.y.md`). **Skill owner: `documentation-roadmap-from-docs` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_EsbocTelas.md](../skills/documentation-screen-sketches_V1.1.0/templates/TEMPLATE_Docs_EsbocTelas.md) | Novo documento em `Docs/Esboco_Telas/` (`Telas_{Projeto}_Vx.y.md`). **Skill owner: `documentation-screen-sketches` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Changelog.md](../skills/documentation-versioning-changelog_V1.1.0/templates/TEMPLATE_Docs_Changelog.md) | Novo/atualização de `Docs/Versionamento/CHANGELOG.md`. **Skill owner: `documentation-versioning-changelog` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_Backup_README.md](../skills/documentation-migration-backup_V1.1.0/templates/TEMPLATE_Docs_Backup_README.md) | Política de backup/superseded (`Docs/Backup/README.md`) — regras de rastreabilidade e índice de arquivos movidos. **Skill owner: `documentation-migration-backup` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md](../skills/documentation-project-bootstrap_V2.1.0/templates/TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md) | Roteiros consolidados na **raiz da pasta documental** (`Documentation/ROTEIROS_CONSOLIDADO.md`) — bootstrap, modos de uso, checklist de validação. **Skill owner: `documentation-project-bootstrap` — em `skills/.../templates/`** |
| [TEMPLATE_Docs_LOGICA_DATABASE.md](../skills/documentation-project-bootstrap_V2.1.0/templates/TEMPLATE_Docs_LOGICA_DATABASE.md) | Documento de **lógica de camada** (ex.: acesso a dados) para recriação por outra equipa/IA (`Docs/LOGICA_DATABASE.md`). **Skill owner: `documentation-project-bootstrap` — em `skills/.../templates/`** |

### HTML / JavaScript (portal de documentação) — pasta `{DocsRaiz}/html/`

**Destino canónico:** `Documentation/html/` (alias legado: `Docs/html/` ou `docs/html/` quando a pasta documental ainda não foi renomeada).

> **Skill owner: `documentation-portal-html` — templates em `skills/documentation-portal-html_V1.2.0/templates/`.**

| Template | Quando usar |
| --- | --- |
| [TEMPLATE_Docs_html_README.md](../skills/documentation-portal-html_V1.2.0/templates/TEMPLATE_Docs_html_README.md) | **README da pasta** `Documentation/html/` — ficheiros esperados, cópia dos templates, abertura no browser, manutenção, contrato JS/HTML e checklist de conformidade. |
| [TEMPLATE_Docs_html_index.html](../skills/documentation-portal-html_V1.2.0/templates/TEMPLATE_Docs_html_index.html) | Novo portal HTML (`Documentation/html/index.html`) — layout completo com header, sidebar, cards de módulo, tabelas de engines/bancos e lista de exemplos. Lê dados de `docs-data.js`. |
| [TEMPLATE_Docs_html_docs-data.js](../skills/documentation-portal-html_V1.2.0/templates/TEMPLATE_Docs_html_docs-data.js) | Novo ficheiro de dados JS (`Documentation/html/docs-data.js`) — define `PROJECT_*`, `MODULES[]`, `DATABASE_TYPES[]`, `ENGINES[]` e `EXAMPLES[]` consumidos pelo portal HTML. |

---

## Convenção de nomes (canônica)

- **`{ClassName}.md`** = nome base Pascal **sem** prefixo `T` ou `I` (ex.: `Connection.md` para `TConnection`/`IConnection`).
- Documentos de módulo: sem prefixo de classe (ex.: `README.md`, `ESPECIFICACAO_CONNECTION.md`).
- Documentos Docs: `{Tipo}_{Projeto}_Vx.y.md` (ex.: `Arquitetura_ProvidersORM_V1.0.md`).
- Usar `Changelog (este arquivo)` em todos os documentos ao alterar.

---

## Skill de scaffolding

A skill **`documentation-paste_analysis_unit_class_method`** pode gerar `{ClassName}.md` em massa a partir do `ProvidersORM.dpr`. Ver [ANALISE_DIAGNOSTICO_ORGANIZACAO.md](../../Analise/ANALISE_DIAGNOSTICO_ORGANIZACAO.md#cap8) (Cap. 8 — Fase D) para os inputs e o modo de execução.

---

**Changelog (este arquivo):**

- 9.0.0 (12/04/2026): Fase 7 — pasta `rules-modelo-orm_V1.0/` deletada (ficou só README.md ponteiro após V2.0 reset de março 2026); referências stale corrigidas em 6 skills; secção renomeada para "Kits de projeto".
- 8.0.0 (12/04/2026): Fase 6 migração — `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md` e `TEMPLATE_Docs_LOGICA_DATABASE.md` movidos para `documentation-project-bootstrap_V2.1.0/templates/`; links actualizados.
- 7.0.0 (12/04/2026): Fase 5 migração — `TEMPLATE_Docs_Analise.md` movido para `documentation-analysis-index_V1.1.0/templates/`; `TEMPLATE_Docs_README_Simples.md` movido para `documentation-readme-hub_V1.1.0/templates/`; links actualizados.
- 6.0.0 (12/04/2026): Fase 4 migração — `TEMPLATE_ClassName_Full_Documentation.md` movido para `documentation-class-analysis-generator_V1.1.0/templates/`; link actualizado; secção "Partilhados (raiz)" convertida em "Skill owner".
- 5.0.0 (12/04/2026): Fase 3 migração — `TEMPLATE_Docs_Overview.md`, `TEMPLATE_Docs_Arquitetura.md`, `TEMPLATE_Docs_README_Hub.md`, `TEMPLATE_Docs_Changelog.md` e 3 templates HTML movidos para as respectivas skills (`documentation-overview-architecture`, `documentation-architecture`, `documentation-readme-hub`, `documentation-versioning-changelog`, `documentation-portal-html`); 4 templates `projeto_*_V2.0.mdc` movidos para `project-init-rules-generator_V1.0.0/templates/`; links actualizados; versões dos links corrigidas para V1.1.0/V1.2.0.
- 4.0.0 (04/04/2026): Fase 2 migração — subpastas de templates por skill owner **movidas para dentro das skills** em `.cursor/skills/<skill>/templates/`; links neste README actualizados para apontar para `../skills/...`; subpastas `documentation-paste_analysis/`, `documentation-business-rules/`, `documentation-screen-sketches/`, `documentation-roadmap-from-docs/`, `documentation-migration-backup/` removidas desta pasta. Templates partilhados/genéricos permanecem na raiz.
- 3.0.0 (04/04/2026): Templates de dono unico reorganizados em subpastas por skill owner: `documentation-paste_analysis/` (7 templates Analise/), `documentation-business-rules/` (TEMPLATE_Docs_RN), `documentation-screen-sketches/` (TEMPLATE_Docs_EsbocTelas), `documentation-roadmap-from-docs/` (TEMPLATE_Docs_Roadmap), `documentation-migration-backup/` (TEMPLATE_Docs_Backup_README). Templates partilhados permanecem na raiz. Tabelas e links actualizados.
- 2.0.0 (01/04/2026): **TEMPLATE_ClassName_Full_Documentation.md** — modelo de documentacao completa por tipo (7 secoes + variantes ORM); tabela *Analise/* distingue scaffold (`TEMPLATE_Unit_ClassName`) vs completo; remissao no `TEMPLATE_Unit_ClassName.md`.
- 1.9.0 (30/03/2026): Seccao **Espelhos e configuracao de ferramentas** — templates `mirror-config/`, tabela e bootstrap script.
- 1.8.0 (30/03/2026): Secção **Exemplo ORM e kits de projeto** — `rules-modelo-orm_V1.0`, `kit-delphi-fpc_V1.0`, `kit-vuejs-nodejs_V1.0`; rubrica de versionamento interno do índice (política: `.cursor/VERSION.md`).
- 1.7.0 (27/03/2026): README e tabela HTML — destino canónico **`Documentation/html/`**; cabeçalho do índice alinhado a **`Documentation/`**; alias legado `Docs/html` documentado.
- 1.6.0 (27/03/2026): **TEMPLATE_Docs_html_README.md** — modelo genérico para a pasta **`Docs/html`** / **`docs/html`** (política, cópia dos templates, abertura local, contrato dados).
- 1.5.0 (27/03/2026): **TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md** e **TEMPLATE_Docs_LOGICA_DATABASE.md** — modelos **genéricos** para a raiz de `Docs/`/`docs/`; bootstrap documental passa a incluí-los (skill **documentation-project-bootstrap**).
- 1.4.0 (27/03/2026): Pasta movida de `Analise/TEMPLATES/` para **`.cursor/Templates/`**; link Fase D corrigido (`../../Analise/...`); skills `documentation-*` passam a referir esta pasta como base física dos modelos.
- 1.3.0 (27/03/2026): Meta-documentos de `Analise/` unificados em **TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md**; removidos oito templates substituídos (DIAGNOSTICO, GUIA_OPERACIONAL, INVENTARIO, INVENTARIO_SRC_DPR, RELATORIO_CONFORMIDADE, MATRIZ_MIGRACAO, MODELO_ALVO_DECISAO, SCAFFOLDING_NOTA).
- 1.2.1 (27/03/2026): Link Fase D → **ANALISE_DIAGNOSTICO_ORGANIZACAO.md** Cap. 8.
- 1.2.0 (27/03/2026): Templates de `Docs/` complementados — README simples, Backup/README, portal HTML (`index.html`) e dados JS (`docs-data.js`).
- 1.1.0 (27/03/2026): Templates dos meta-documentos de `Analise/` adicionados (GUIA_OPERACIONAL, INVENTARIO_SRC_DPR, MATRIZ_MIGRACAO, MODELO_ALVO_DECISAO, O_QUE_FALTA, SCAFFOLDING_NOTA).
- 1.0.0 (27/03/2026): Criação do README central de templates com cobertura completa Analise/ e Docs/.

---

## Versão interna (ficheiro)

| Campo           | Valor                |
| --------------- | -------------------- |
| **FileVersion** | 1.0.10               |
| **Política**    | `.cursor/VERSION.md` |
