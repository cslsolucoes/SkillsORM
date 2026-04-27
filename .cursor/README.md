# .cursor — SkillsORM
<!-- internal_file_version: 1.5.0 -->

---

## Versão do pack `.cursor/` (configuração do Cursor)

**Versão atual:** 2.0.0  
**Data:** 2026-04-25

### Changelog (configuração do Cursor)

- 2.0.0 (2026-04-25): Início do versionamento SemVer desta configuração do pack `.cursor/` no repositório **SkillsORM**.

## Versionamento da estrutura `.cursor/`

| Área | Manifesto | FolderVersion | Data |
| ---- | --------- | :-----------: | ---- |
| **Skills** | `skills/skills-pack-manifest_V1.25.0.md` | 1.25.0 | 26/04/2026 |
| **Agents** | `agents/agents-pack-manifest_V1.7.1.md` | 1.7.1 | 24/04/2026 |
| **Rules** | `rules/rules-pack-manifest_V1.6.5.md` | 1.6.5 | 26/04/2026 |
| **Templates** | `Templates/templates-pack-manifest_V1.1.0.md` | 1.1.0 | 16/04/2026 |
| **Commands** | `commands/commands-pack-manifest_V1.8.0.md` | 1.8.0 | 25/04/2026 |
| **Scripts** | `scripts/scripts-pack-manifest_V1.4.0.md` | 1.4.0 | 16/04/2026 |
| **Política de versionamento** | [`VERSION.md`](VERSION.md) → skill `governance-pack-versioning-policy_V1.0.0` | — | — |

### Scripts de automação

| Script | Tipo | Função |
| ------ | ---- | ------ |
| `bootstrap_autostart_mirrors.py` | Python | Auto-start de espelhos ao abrir pasta (cross-platform) |
| `bootstrap_mirror_symlinks.py` | Python | Cria/valida/repara symlinks dos espelhos |
| `bootstrap_reset.py` | Python | Reset controlado do ambiente de bootstrap |
| `sync_cursor_pack.py` | Python | Sincroniza o pack `.cursor/` entre projetos |
| `validate_pack.py` | Python | Valida integridade de skills/rules/agents. Flags: `--verbose`, `--no-instance-strings`, `--indexes-fresh` |
| **`pack_index_db.py`** | Python | **Gestor do índice SQLite (FTS5) do pack e do workspace.** Operações: `--init`, `--scan {cursor\|workspace\|all}`, `--query <keywords>`, `--stats`, `--full`. Duas DBs: `.cursor/index.db` (propagada via sync) + `.workspace/index.db` (local, ignorada). Invocado pelo command `/syncdb`. |
| `gen_reference_map.py` | Python | One-shot da Onda 0 do refactor — gera `.cursor/Backup/reference-map-20260417.json` com cruzadas dos 10 nomes antigos a renomear. |
| `bootstrap-autostart-mirrors.ps1` | PowerShell | Equivalente Windows-only do autostart Python |
| `bootstrap-mirror-symlinks.ps1` | PowerShell | Equivalente Windows-only do bootstrap Python |
| `bootstrap-reset.ps1` | PowerShell | Equivalente Windows-only do reset Python |
| `bootstrap-build-config.ps1` | PowerShell | Gera/valida arquivos de build do projeto |
| `bootstrap-form-unit.ps1` | PowerShell | Gera form units sob demanda (VCL/FMX/LCL) |
| `sync-cursor-pack.ps1` | PowerShell | Equivalente Windows-only do sync Python |

### Slash commands disponíveis

| Comando | Script invocado | Função |
| ------- | --------------- | ------ |
| `/consolidar` | `project-consolidate-orchestrator` | Auditoria workspace (cursor, docs, source). |
| `/migration-plan` | `documentation-migration-plan` | Plano de migração documental. |
| `/sync-cursor-pack` | `sync-cursor-pack.ps1` | Propaga pack para projectos destino. |
| **`/syncdb`** | **`pack_index_db.py --scan all`** | **Sincroniza índices SQLite (pack + workspace). Invocar após edições.** |
| `/validate-docs` | `documentation-project-scan` | Valida coerência da Documentation/. |

### Bases de dados de índice (SQLite + FTS5)

| Ficheiro | Conteúdo | Propagação |
| -------- | -------- | ---------- |
| `.cursor/index.db` | Metadados de skills + agents + rules + Docs do pack | **Sim** (via `sync-cursor-pack`; destino regenera no recebimento) |
| `.workspace/index.db` | Metadados de artefactos `<projectId>-*` em `.workspace/` | **Não** (ignorado por git/sync — regenerado pelo `/init` no destino) |

Schema com FTS5 + índices multi-coluna. Updates incrementais por hash SHA-256. Consulta: `python .cursor/scripts/pack_index_db.py --query "<keywords>"`.

> **SSOT:** `.cursor/` é a única fonte canónica. `.claude/`, `.vscode/`, `.continue/` e `.opencode/` são espelhos via symlinks — nunca editar directamente.

---

Índice da pasta **.cursor** do **SkillsORM** (workspace = raiz do repositório). Regras, skills, documentação de compilação e bancos CLI, agentes e planos.

---

## Estrutura

| Pasta / arquivo | Descrição |
| ----------------- | ----------- |
| **Templates/** | Ficheiros-modelo **`TEMPLATE_*.md`** (e HTML/JS) para criar documentação em **`Analise/`** e **`Documentation/`** — índice **[Templates/README.md](Templates/README.md)**; manifesto de área **`Templates/templates-pack-manifest_V1.1.0.md`**. Base obrigatória para as skills `documentation-*` ao gerar novos artefactos. |
| **rules/** | Rules activas (todas com FileVersion V2): `project-autostart-bootstrap_V1.0.1.mdc` (1.1.0), `project-documentacao_V1.0.1.mdc` (1.1.0), `documentation-migration-plan-mode_V1.0.0.mdc` (1.1.0). Política: skill **`documentation-rules_creator`**. |
| **skills/** | Skills `developer-*`, `governance-*`, `project-*`, `documentation-*` — manifesto: `skills/skills-pack-manifest_V1.25.0.md`. |
| **agents/** | Agentes com convenção `{domínio}-agent-{papel}_V*.md` — manifesto: `agents/agents-pack-manifest_V1.7.1.md`. |
| **commands/** | Comandos slash — manifesto: `commands/commands-pack-manifest_V1.8.0.md`. |
| **plans/** | Planos de execução — convenção `<nome>_<hash>.plan.md` (sem espaços). |
| **scripts/** | Scripts de automação (Python + PowerShell) — manifesto: `scripts/scripts-pack-manifest_V1.4.0.md`. |
| **[VERSION.md](VERSION.md)** | Stub → skill **`governance-pack-versioning-policy`** (política de versionamento). Cada área usa *manifest* `*-pack-manifest_V{SemVer}.md` (ex.: `agents/agents-pack-manifest_V1.7.1.md`, `skills/skills-pack-manifest_V1.25.0.md`, `rules/rules-pack-manifest_V1.6.5.md`, `Templates/templates-pack-manifest_V1.1.0.md`). |

---

## Regras (rules/)

### Templates genéricos (ponto de partida para qualquer projeto)

| Arquivo | Conteúdo principal |
| ------- | ------------------ |
| **project-fundamentos_V1.0.1.mdc** | Identidade do projeto, nomenclatura (prefixos, Fluent, Factory), exceções, padrões de design, legenda de status, referências a agents/skills. |
| **project-estrutura_V1.0.1.mdc** | Árvore de pastas, pacotes de terceiros, configuração de compilação, artefatos de build, acesso CLI a dados. |
| **project-documentacao_V1.0.1.mdc** | Matriz de responsabilidades, convenção `Analise/`, documentos-chave, roteiros de uso, preocupações transversais. |
| **project-roadmap_V1.0.1.mdc** | Visão estratégica, fases, hierarquia de módulos, checklists de status, critérios de qualidade, backlog. |
| **project-exemplos_V1.0.1.mdc** | Padrão de uso central, cenários por componente, wiring do ecossistema, anti-padrões. |

### Exemplo ORM completamente preenchido (referência)

| Pasta | Descrição |
| ----- | --------- |
| ~~rules-modelo-orm_V1.0/~~ | Removido do pack em 12/04/2026 (Templates V1.0.13, Fase 7). |

---

## Skills (skills/)

| Skill | Quando usar |
| ------- | ------------- |
| **documentation-project-expert** | Arquitetura ORM, Connection/Pool, hierarquia Fields/Tables, engines (FireDAC, UniDAC, Zeos, SQLdb), convenções, exceções. |
| **documentation-project-structure** | Mapa rápido do repositório (raiz, `src/`, `.cursor/`, `Analise/`, `Documentation/`, `ORM.Defines.inc`) para navegação e descoberta. |
| **developer-delphi-build-toolchain** | Compilação (Delphi, FPC, Go, Python), paths e config de build; acesso a bancos por CLI (mysql, sqlite3, isql, psql, sqlcmd), Data/config.ini e config.json. Docs em `exemplos/` dentro da skill. |
| **developer-delphi-programming-conditional-defines** | Diretivas de compilação (USE_*, ORM.Defines.inc), habilitar/desabilitar módulos e engines, blocos {$IFDEF}. Docs em `exemplos/` dentro da skill. |
| **documentation-paste_analysis_unit_class_method** | **Referência canónica para `Analise/`** — scaffolding genérico e idempotente: subpastas por domínio derivadas de `src/`, ficheiros **`{ClassName}.md`** (tipos **`T…`** / **`I…`**), modos scaffold/sync; input opcional lista DPR. Rodar antes de `documentation-project-feature` quando faltarem placeholders. |
| **documentation-class-analysis-generator** | **Preenchimento completo por tipo** a partir do código — orquestra `doc-agent-class-scanner` / `doc-agent-class-writer` / `doc-agent-class-indexer`; complementa o *paste* (estrutura/placeholders). Depois: `documentation-project-scan` / `documentation-project-feature` para lacunas e matriz. |
| **documentation-general_rules** | Transversal sem outro dono: ordem de invocação entre skills `documentation-*`, changelog `.md` portátil, pacote para outro repositório/IA. **Não** redefine `Analise/`. |
| **documentation-project-feature** | Matriz de lacunas, RN, semântica, checklist e backlog; **consome** o output do paste — não redefine a árvore física de `Analise/`. |
| **documentation-project-scan** | Inventário / scan de `Analise/`, `Documentation/`, gaps e classificação; distinto da criação de placeholders (paste). |
| **documentation-migration-backup** | Migração documental com backup, matriz origem→destino, fluxo anti-perda (incl. extensão `Analise/` na raiz quando aplicável). |
| **documentation-constitution-policies** | Três políticas constitucionais consolidadas: superseded-definition, migration-conflict-resolution, rules-integration. Substitui as skills individuais `documentation-superseded-definition`, `documentation-migration-conflict-resolution`, `documentation-cursor-rules-integration`. |
| **documentation-rules_creator** | Cria/recria **`.cursor/rules/`** com conteúdo **apenas específico do projeto**; define repartição com skills/agents (texto portátil não permanece nas rules). Em projetos novos, parte dos **templates genéricos** (`project-*.mdc`). Ver secção *Templates e modelo de referência* no SKILL. |

### Família `developer-delphi-horse-*` (18 skills — desde 12/04/2026)

| Skill | Quando usar |
| ------- | ------------- |
| **developer-delphi-horse-orchestrator** | Ponto de entrada único para o ecossistema Horse; classifica e roteia para a skill especializada |
| **developer-delphi-to-fpc-horse-core** | Servidor Horse, rotas (Get/Post/Put/Delete/Patch/All), grupos, THorseRequest/Response |
| **developer-delphi-to-fpc-horse-handle-exception** | Tratamento de exceções HTTP, EHorseException, callback de intercepção |
| **developer-delphi-to-fpc-horse-basic-auth** | Autenticação HTTP Basic (HorseBasicAuthentication, SkipRoutes) |
| **developer-delphi-to-fpc-horse-compression** | Compressão GZIP/DEFLATE de respostas (Accept-Encoding, threshold) |
| **developer-delphi-to-fpc-horse-cors** | CORS, preflight OPTIONS, origens/métodos/headers permitidos |
| **developer-delphi-to-fpc-horse-etag** | ETag automático, If-None-Match, 304 Not Modified |
| **developer-delphi-to-fpc-horse-exception-logger** | Log de exceções em disco (THorseExceptionLogger) |
| **developer-delphi-to-fpc-horse-jwt** | JWT Bearer em rotas Horse (HorseJWT, THorseJWTConfig, claims no request) |
| **developer-delphi-to-fpc-horse-logger** | Infraestrutura de log (THorseLoggerManager, RegisterProvider, variáveis de formato) |
| **developer-delphi-to-fpc-horse-logger-console** | Provider de log para console/stdout (desenvolvimento) |
| **developer-delphi-to-fpc-horse-logger-logfile** | Provider de log para ficheiro com rotação diária (produção) |
| **developer-delphi-to-fpc-horse-octet-stream** | Download/upload de ficheiros binários, TStream, TFileReturn |
| **developer-delphi-to-fpc-horse-paginate** | Paginação JSON, X-Paginate, limit/page, summary wrapper |
| **developer-delphi-to-fpc-horse-clientip** | Extrair IP real do cliente (CF-Connecting-IP, X-Real-IP, X-Forwarded-For) |
| **developer-delphi-to-fpc-horse-security** | TJWT, TJOSE, TJWTClaims, TJOSEConsumerBuilder; HorseSwagger / OpenAPI |
| **developer-delphi-to-fpc-http-client-rest** | Consumir REST APIs externas (TRequest, adapters CSV/DataSet) |
| **developer-delphi-to-fpc-dataset-serialize** | Serializar DataSet↔JSON (ToJSONArray, LoadFromJSON, TDataSetSerializeConfig) |

---

## Agentes (agents/)

### Desenvolvimento — CEO e kits

| Ficheiro | Função |
|----------|--------|
| **developer-agent-orchestrator_V2.2.0.md** | **CEO técnico** — classifica por extensão/path (Delphi vs Vue vs docs); delega; valida handoff cross-kit |
| **developer-delphi-agent-orchestrator_V1.2.0.md** | Sub-orquestrador **Delphi/FPC/Lazarus** — coordena experts Delphi + fluxo docs-to-code |
| **developer-vuejs-agent-orchestrator_V1.2.0.md** | Sub-orquestrador **VueJS/NodeJS** — matriz dos 4 experts web consolidados + docs-to-code |
| **developer-vuejs-agent-core-expert_V1.2.0.md** | Vue — linguagem, Composition API, arquitectura de componentes |
| **developer-vuejs-agent-routing-state-expert_V1.2.0.md** | Vue Router, Pinia, guards, lazy loading |
| **developer-web-agent-runtime-build-expert_V1.2.0.md** | Node.js runtime, Vite, env, cliente HTTP |
| **developer-web-agent-quality-expert_V1.2.0.md** | Testes, debug, segurança, performance, memory leaks |
| **developer-delphi-agent-orm-architect_V1.3.0.md** | ORM — arquitectura, Connection, Pool (ver **Templates/rules-modelo-orm_V1.0/**) |
| **developer-delphi-agent-modules-orchestrator_V1.3.0.md** | `src/Modulos/` — visão geral |
| **developer-delphi-agent-views-orchestrator_V1.3.0.md** | `src/Views` — forms Delphi/FPC (**não** SPA Vue) |
| **developer-delphi-agent-{connections,database,exceptions,loggers,parameters,poolconnections,views}-expert** | Especialistas por módulo ORM / Views (V1.3.0) |
| **governance-agent-orchestrator_V1.0.0.md** | Orquestra skills `governance-*` |
| **quality-agent-orchestrator_V1.0.0.md** | Orquestra skills `quality-*` |
| **version-agent-orchestrator_V1.0.0.md** | Orquestra skills `version-*` |

### Documentação

| Ficheiro | Função |
|----------|--------|
| **documentation-agent-orchestrator_V1.3.0.md** | Orquestra **todos** os `documentation-agent-*` (hub, migração, `Analise/`, class-*, políticas) |
| **documentation-agent-migration_V1.2.0.md** | Migração para template `Documentation/` + backup |
| **documentation-agent-review_V1.2.0.md** | Revisão / Pass-Fail documental |
| **documentation-agent-architecture_V1.2.0.md** | `Documentation/Arquitetura/`; quality model via `documentation-overview-architecture` |
| **documentation-agent-rules_V1.4.0.md** | `Documentation/Regras de Negocio/` |
| **documentation-agent-roadmap_V1.2.0.md** | Roadmap a partir de `Documentation/` |
| **documentation-agent-superseded-definition_V1.2.0.md** | Política superseded / Backup |
| **documentation-agent-migration-conflict-resolution_V1.2.0.md** | Colisão de destino / `_CONFLITO` |
| **documentation-agent-cursor-rules-integration_V1.2.0.md** | Integração rules vs docs vs skills |
| **documentation-agent-class-scanner_V1.2.0.md** | Inventário de tipos no código-fonte |
| **documentation-agent-class-writer_V1.2.0.md** | Escrita das 7 secções em cada `{ClassName}.md` |
| **documentation-agent-class-indexer_V1.2.0.md** | `README.md` índice + `FLOWCHART.md` (Mermaid) na raiz da análise |

**Vínculo a planos:** plano Delphi/FPC e plano VueJS/NodeJS partilham o mesmo CEO (`developer-agent-orchestrator_V2.2.0.md`); execução por kit via sub-orquestradores; governança documental via `documentation-agent-orchestrator_V1.3.0.md`.

---

## Documentos canônicos (fora de rules/)

- **Compilação:** skill **`developer-delphi-build-toolchain`** (exemplos em `skills/project-compile-database-docs_V1.0.1/exemplos/compile.md`)
- **Bancos CLI:** skill **`developer-delphi-build-toolchain`** (exemplos em `skills/project-compile-database-docs_V1.0.1/exemplos/database.md`)
- **Diretivas de compilação:** skill **`developer-delphi-programming-conditional-defines`** (exemplos em `skills/project-diretivas-compilacao_V1.0.1/exemplos/diretivas_compilacao.md`)

---

## Espelhos (`.claude`, `.vscode`, Continue e OpenCode)

Os espelhos são **ligações simbólicas** (symlinks) de `.cursor/` para `.claude/`, `.vscode/`, `.continue/` e `.opencode/`. Isto permite que Claude Code, VS Code, Continue.dev e [OpenCode](https://opencode.ai/docs) acedam ao mesmo conteúdo sem duplicação.

Na **raiz** do repositório, `opencode.json` (ficheiro real, não symlink) referencia `CLAUDE.md` e as rules do projeto para o motor de instruções do OpenCode; o template está em [Templates/mirror-config/opencode.json.template](Templates/mirror-config/opencode.json.template).

### Bootstrap (criar/verificar espelhos)

**Pré-requisito:** Para criar symlinks, **Administrador** (ou **Modo de Programador** com permissão real para symlinks). Ao correr sem elevação, o script pede **UAC** e relança a si próprio com **RunAs** (use `-NoElevation` para desactivar esse passo).

```powershell
# Criar symlinks em falta (abre UAC se necessário)
.\.cursor\scripts\bootstrap-mirror-symlinks.ps1

# Verificar estado (sem alterar nada)
.\.cursor\scripts\bootstrap-mirror-symlinks.ps1 -ValidateOnly

# Reparar symlinks quebrados
.\.cursor\scripts\bootstrap-mirror-symlinks.ps1 -Repair

# Substituir ficheiros reais stale por symlinks (backup .bak automatico)
.\.cursor\scripts\bootstrap-mirror-symlinks.ps1 -Force
```

### O que é espelhado (symlinks)

| Tipo | Itens |
| ---- | ----- |
| **Directorios** | `agents/`, `plans/`, `rules/`, `skills/`, `Templates/`, `commands/` |
| **Ficheiros** | `VERSION.md`, `README.md` |
| **Opcionais** | `Documentation/ROTEIROS_CONSOLIDADO.md`, `Documentation/LOGICA_DATABASE.md` (só se existirem) |

**Conflitos:** o script usa `Test-Path -LiteralPath` para não confundir symlink com pasta real. Se o link já estiver correcto, não duplica. Se existir **pasta ou ficheiro real** com o mesmo nome, renomeia para `nome.yyyyMMdd_HHmmss` e cria o symlink. Pastas `nome (2)` criadas pelo Explorador não são geridas pelo script — apague-as manualmente se forem duplicados acidentais.

### Ficheiros de configuração (NÃO são symlinks)

Ficheiros específicos de cada IDE permanecem como ficheiros reais:

- `.vscode/settings.json`, `tasks.json`, `extensions.json`
- `.claude/settings.json`, `settings.local.json`

Templates para inicializar estes ficheiros: **[.cursor/Templates/mirror-config/](Templates/mirror-config/README.md)**

### Checklist de validação

Validação dos espelhos integrada no script **bootstrap-mirror-symlinks.ps1** (`-ValidateOnly`).

**Nota (Continue):** o ficheiro **`.continue/rules/projeto-fonte-cursor.md`** (se existir) é exclusivo do Continue e **não** provém de `.cursor/rules/`. O script de bootstrap não o remove nem substitui.

---

## Referências externas

- **Analise:** [Analise/README.md](../Analise/README.md) — documentação por classe.
- **Documentação:** [Documentation/README.md](../Documentation/README.md) — hub e referência documental.
- **CHANGELOG:** [CHANGELOG.md](../CHANGELOG.md) — mudanças do projeto.

---

## Estado após reset (absorvido de BASE_STRUCTURE.md)

Estado real do repositório após `bootstrap-reset.ps1 -Force`:

```text
E:\Providers.2.1.0\              (raiz)
  .cursor\                        SSOT — NUNCA apagado
  .vscode\
    tasks.json                    perene — Auto Start task (folderOpen)
```

Tudo o que está fora de `.cursor\` e desse arquivo é **gerado** e pode ser apagado.

### Arquivos APAGADOS no reset (gerados/derivados)

| Arquivo / Pasta | Motivo |
| --------------- | ------ |
| `CLAUDE.md` | Gerado por `Install-MirrorConfigTemplate` |
| `.claude/settings.json` | Gerado por `Install-MirrorConfigTemplate` |
| `.claude/settings.local.json` | Gerado por `Install-MirrorConfigTemplate` |
| `.vscode/settings.json` | Gerado por `Install-MirrorConfigTemplate` |
| `.vscode/extensions.json` | Gerado por `Install-MirrorConfigTemplate` |
| `.claude/` (symlinks) | Recriados pelo bootstrap |
| `.vscode/` (symlinks) | Recriados pelo bootstrap |
| `.continue/` (pasta + symlinks) | Recriada pelo bootstrap |
| `.opencode/` (pasta + symlinks) | Recriada pelo bootstrap |
| `opencode.json` (raiz) | Gerado por `Install-MirrorConfigTemplate` |

### Como usar o reset

```powershell
# Reset padrão
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-reset.ps1"

# Reset com confirmação interativa
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-reset.ps1" -WhatIf

# Após o reset, reexecutar o bootstrap para recriar symlinks e configs
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1"
```

---

## Hub de Skills (absorvido de SKILLS_DOCUMENTATION)

A documentação consolidada de toda a pasta `.cursor/` — arquivo a arquivo — encontra-se agora distribuída entre as skills e esta secção do README.

### Visão geral da pasta `.cursor/`

A pasta `.cursor/` é o centro de configuração inteligente do workspace. Contém regras, skills, agentes, templates, documentação de compilação/banco e planos. Tudo versionado internamente com changelogs por arquivo e manifestos por área.

### Skills documentation-* (principais)

| Skill | Finalidade |
| --- | --- |
| `documentation-portal-html` | Portal HTML em `Documentation/html/` + plano de delegação |
| `documentation-constitution-policies` | Políticas consolidadas: integração rules/docs, conflitos migração, superseded |
| `documentation-project-bootstrap` | Inicializa ecossistema documental num projeto novo |
| `documentation-project-scan` | Varredura para descobrir artefactos e lacunas |
| `documentation-project-feature` | Análise por funcionalidade com matriz de lacunas |
| `documentation-readme-hub` | Atualiza hub `Documentation/README_Vx.y.md` + política resync |
| `documentation-architecture` | Docs de arquitetura em `Documentation/Arquitetura/` |
| `documentation-business-rules` | Regras de negócio em `Documentation/Regras de Negocio/` |
| `documentation-general_rules` | Convenções transversais + política idioma + naming |
| `documentation-paste_analysis_unit_class_method` | Scaffolding canónico de `Analise/` |
| `documentation-class-analysis-generator` | Conteúdo completo por classe/interface |
| `documentation-rules_creator` | Cria/recria regras em `.cursor/rules/` |
| `governance-sdlc-lifecycle` | Ciclo de vida SDLC |
| `documentation-overview-architecture` | Modelo de qualidade Overview + Architecture |

### Skills project-*

| Skill | Finalidade |
| --- | --- |
| `documentation-project-expert` | Expert ORM: arquitetura, Connection/Pool, Fields/Tables, engines |
| `developer-delphi-providers-orm-usage` | Como usar o projeto — modo Slim e modo Attributes |
| `documentation-project-structure` | Mapeamento do repositório |
| `developer-delphi-build-toolchain` | Compilação e acesso CLI a bancos (exemplos em `exemplos/`) |
| `developer-delphi-programming-conditional-defines` | Diretivas `USE_*`, `ORM.Defines.inc` (exemplos em `exemplos/`) |

### Skills Developer (canónicas — `developer-*`)

Skills de desenvolvimento: `developer-delphi-*` (Delphi/FPC/Lazarus, Windows Services, Linux, Shared Libs), `developer-vuejs-*`, `developer-web-*`. Prefixos legados `delphi-fpc-*` e `JS-*` foram substituídos pelos prefixos canónicos.

### Skills de governança (`governance-*`)

| Skill | Finalidade |
| --- | --- |
| `governance-pack-versioning-policy` | Política SemVer do pack `.cursor/` |
| `governance-pack-checklist-validation` | Checklist de validação dos espelhos |
| `governance-constitution-policies` | Políticas constitucionais consolidadas |
| `governance-sdlc-lifecycle` | Ciclo de vida SDLC |

---

## Workflow de Geração Documental

Sequência recomendada de invocação das skills `documentation-*` para gerar a documentação completa de um projecto, do zero ao SDLC:

| Ordem | Skill | Resultado |
| --- | --- | --- |
| 0 | `documentation-project-bootstrap` | Cria `Documentation/` com 13 subpastas obrigatórias, hub e changelog |
| 1 | `documentation-paste_analysis` | Cria `Analise/` (scaffolding: subpastas por domínio + `{ClassName}.md` placeholder) |
| 1b | `documentation-overview-architecture` | Modelo de qualidade Overview + Architecture em `Documentation/Arquitetura/` |
| 2 | `documentation-class-analysis-generator` | Preenche conteúdo completo em cada `{ClassName}.md` de `Analise/` |
| 3 | `documentation-project-feature` | Matriz de lacunas, RN semântica, checklist e backlog |
| 3b | `documentation-business-rules` | Regras de Negócio em formato **GestorDoc** (12 secções obrigatórias) |
| 4 | `documentation-project-scan` | Inventário completo + gaps detectados |
| 5 | `documentation-migration-backup` | Migração documental (se necessário) com backup e matriz origem/destino |
| 6 | `documentation-rules_creator` | Sintetiza `.cursor/rules/` a partir da documentação gerada |
| 7 | `governance-sdlc-lifecycle` | Matriz SDLC completa do projecto |

**Nota:** As ordens 1/1b e 3/3b podem executar em paralelo. A ordem 0 é pré-requisito para todas as outras.

---

## Formatos Mandatórios

### Regras de Negócio — formato GestorDoc

Todas as Regras de Negócio devem seguir o formato **GestorDoc** com **12 secções obrigatórias**:

1. Cabeçalho de identificação (ID, Módulo, Fase, Prioridade, Status, Título, Ref. Arquitetura)
2. PRE-CONDICOES
3. FLUXO PRINCIPAL
4. FLUXOS DE EXCECAO
5. VALIDACOES
6. TABELAS / CAMPOS DO BANCO DE DADOS
7. IMPACTO EM OUTRAS RNs
8. LGPD
9. ESBOCO DE IMPLEMENTACAO
10. NOTAS / OBSERVACOES
11. Assinaturas

**Referência:** `documentation-business-rules/exemplos/` (gold standard) e `documentation-business-rules/templates/TEMPLATE_Docs_RN.md`.

### Analise/ — nomenclatura de ficheiros

- **`{ClassName}.md`** sem prefixo `T`/`I` no nome do ficheiro (ex.: `TConnection` / `IConnection` geram `Connection.md`).
- Tipos `T…` e `I…` com o mesmo sufixo Pascal partilham o mesmo ficheiro.
- **Referência:** `documentation-paste_analysis/` (skill canónica para `Analise/`).

---

## Modelos Claude por Tier

Cada agent e skill declara `model:` no frontmatter para o Claude Code escolher automaticamente o modelo mais económico suficiente para a tarefa.

| Tier | Critério | Agentes | Skills |
|------|----------|---------|--------|
| **opus** | Domínio profundo + precisão crítica: arquitectura cross-engine, gold-standard | `dev-agent-providers-orm-expert`, `dev-agent-database-expert` | `documentation-overview-architecture` |
| **haiku** | Extração, scan, lookup, preenchimento de template, classificação por política | `doc-agent-class-scanner`, `doc-agent-class-indexer`, `doc-agent-superseded-definition`, `doc-agent-cursor-rules-integration`, `dev-agent-exceptions-expert`, `dev-agent-loggers-expert`, `dev-agent-parameters-expert`, `dev-agent-views-expert` | `governance-constitution-policies`, `documentation-versioning-changelog`, `documentation-screen-sketches`, `documentation-project-{examples,fundamentals,structure}-template`, `governance-pack-versioning-policy`, `governance-pack-checklist-validation`, `project-abrir-bancos-cli`, `developer-delphi-programming-conditional-defines`, `developer-delphi-{build-cross-compiler,packaging-delivery,documentation-governance}`, `developer-web-{packaging-deployment,build-tooling-quality}` |
| **sonnet** | Tudo o resto — raciocínio + escrita, código, análise, orquestração | 19 restantes | 40 restantes |

> `model:` em agents é nativo do Claude Code. `model:` em SKILL.md é uma convenção lida pelo Claude Code ao invocar a skill como agente (Agent tool, parâmetro `model`).

---

## Estrutura final `.cursor/`

```text
.cursor/
├── README.md                          ← este ficheiro (hub completo)
├── VERSION.md                         ← stub → skill governance-pack-versioning-policy
├── Templates/                         ← ficheiros-modelo TEMPLATE_*
├── agents/                            ← doc-agent-* e dev-agent-*
├── commands/                          ← comandos slash (/migration-plan, /sync-cursor-pack, /validate-docs)
├── plans/                             ← planos de execução
├── rules/                             ← rules activas (.mdc)
├── scripts/                           ← scripts PowerShell de automação
└── skills/                            ← skills developer-*, governance-*, documentation-*, project-* (90 ativas)
```

---

**Changelog (este arquivo):**

- 4.3.0 (26/04/2026): **E14 — Workspace Mirror Structure**: tabela de manifestos atualizada para `rules/rules-pack-manifest_V1.6.5.md` (FolderVersion 1.6.5, 26/04/2026); rule `artifact-placement-policy` bumpada V1.1.0 → V1.2.0 com nova **Regra 4-A — Estrutura espelhada**: `.workspace/` deve adotar o mesmo conjunto de subpastas de `.cursor/` (skills, rules, agents, Templates, commands, plans, scripts) quando aplicável. Adicionada categoria `Plans` na tabela de nomenclatura (Regra 4) com convenção `<slug>_v<major>.<minor>.plan.md`. internal_file_version 1.4.0 → 1.5.0.
- 4.2.0 (26/04/2026): **E13 — Documentation Quality Gates**: tabela de manifestos atualizada para `skills/skills-pack-manifest_V1.25.0.md` (FolderVersion 1.25.0, 26/04/2026); 5 skills da família `documentation-*` bumpadas in-place — `documentation-master-orchestrator` V1.1→V1.2 (workflow obrigatório de 5 fases), `documentation-project-bootstrap` V2.1→V2.2 (parâmetros `<output_path>`, `<structure_mode>`, `<portal_html>` + `Documentation/Decisions/`), `documentation-project-scan` V1.1→V1.2 (cruzamento dependências vs imports stack-aware), `documentation-general_rules` V2.0→V2.1 (formaliza 7 arquivos canônicos em `Decisions/`), `documentation-class-analysis-generator` V1.1→V1.2 (threshold ≥5 unidades = doc individual obrigatória).
- 4.1.0 (11/04/2026): Auditoria de coerência — corrigidos nomes de agentes Vue/ORM/Views (V1.0.2→V1.1.0, V1.1.1→V1.2.0); Commands e Scripts adicionados à tabela de manifestos; `pack-versioning-policy` renomeado para `governance-pack-versioning-policy` em todos os ponteiros; `documentation-sdlc-lifecycle` (fictício) substituído por `governance-sdlc-lifecycle`; `templates-pack-manifest` corrigido para V1.0.7; contagem de skills corrigida para 142; inventário do pack regenerado (JSON on-demand).
- 4.0.0 (04/04/2026): Migração Fases 3-7 — secções "Workflow de Geração Documental" (sequência 0-7), "Formatos Mandatórios" (GestorDoc + `{ClassName}.md`), "Estrutura final `.cursor/`"; skill `documentation-project-update` e pasta `commands/` na estrutura; tabela de skills actualizada.
- 3.0.0 (04/04/2026): Migração Fase 1 — absorvido conteúdo de `BASE_STRUCTURE.md` (secção "Estado após reset") e `SKILLS_DOCUMENTATION_v3.0.8.md` (secção "Hub de Skills"); tabela de skills actualizada com renomeações e novas skills.
- 2.0.6 (02/04/2026): Hub **`SKILLS_DOCUMENTATION_v3.0.7.md`** (v3.0.7); skill **`documentation-sdlc-lifecycle_V1.0.1`**; manifesto **`skills-pack-manifest_V1.0.5.md`**; pacote **1.0.14**.
- 2.0.5 (01/04/2026): Hub **`SKILLS_DOCUMENTATION_v3.0.6.md`** (auditoria coerência); **`doc-agent-orchestrator_V1.1.3.md`**; manifestos **`agents-pack-manifest_V1.0.7.md`**, **`skills-pack-manifest_V1.0.4.md`**, **`Templates/templates-pack-manifest_V1.0.6.md`**; pastas **`documentation-general_rules_V1.0.3`**, **`documentation-orchestrator_V1.0.2`**; scripts na tabela **scripts/**; pacote **1.0.13**.
- 2.0.4 (01/04/2026): Hub **`SKILLS_DOCUMENTATION_v3.0.5.md`** (SemVer do nome = **v3.0.5** no cabeçalho); espelhos/scripts actualizados.
- 2.0.3 (01/04/2026): Agentes **`doc-agent-class-scanner`**, **`doc-agent-class-writer`**, **`doc-agent-class-indexer`** (`*_V1.0.1.md`); manifesto **`agents-pack-manifest_V1.0.6.md`**.
- 2.0.2 (01/04/2026): Hub **`SKILLS_DOCUMENTATION_v3.0.4.md`** (rename + referências em espelhos); política nome = versão em **`documentation-general_rules`** e **VERSION.md** **1.0.11**; skills paste + class-analysis-generator (política obrigatória `Analise/`).
- 2.0.1 (01/04/2026): Skill **documentation-class-analysis-generator** e agentes **doc-class-*** (`*_V1.0.1.md`); manifestos **skills-pack-manifest_V1.0.3.md**, **agents-pack-manifest_V1.0.5.md**; pacote `.cursor` **1.0.10**.
- 2.0.0 (30/03/2026): **Espelhos via symlinks** — `bootstrap-mirror-symlinks.ps1` substitui robocopy; `scripts/` e `MIRRORS_VALIDATION.md` na tabela de estrutura; `SKILLS_DOCUMENTATION` actualizado para v3.0.3; pacote `.cursor` **1.0.9**.
- 1.9.0 (30/03/2026): Correcções de estado real — nomes de rules actualizados para V1.0.1 em toda a tabela de estrutura e secção *Regras*; entrada `VSCODE_UPDATE_FROM_CURSOR.md` removida (ficheiro não existe em `.cursor/`); descrição de `plans/` actualizada (pasta vazia); pacote `.cursor` **1.0.8**.
- 1.8.0 (30/03/2026): **Agentes** renomeados para sufixo = FileVersion interno (`dev-agent-orchestrator_V2.0.2.md`, `dev-agent-backend_V1.1.1.md`, etc.); manifesto `agents-pack-manifest_V1.0.4.md`. **READMEs** renomeados de `README_V1.0.md` → `README.md` em Constitution, Developer, agents e Templates/rules-modelo-orm. Pacote `.cursor` **1.0.7**.
- 1.7.1 (30/03/2026): Manifestos com **SemVer completa no nome**; pastas de skills = versão do **`SKILL.md`** (`*_V1.0.1/`, `project-expert_V1.1.12/`); **`Templates/templates-pack-manifest_V1.0.1.md`**; pacote `.cursor` **1.0.6**.
- 1.7.0 (30/03/2026): Adicionada entrada **`SKILLS_DOCUMENTATION_v3.0.2.md`** na tabela de estrutura — documentação consolidada de toda a pasta `.cursor/` (v3.0.0); pacote `.cursor` **1.0.5**.
- 1.6.4 (30/03/2026): **Skills** — `SKILL.md` por pasta `*_V1.0/`; **agents** — só `*_V1.0.md`; **Templates/** — `rules-modelo-orm_V1.0/`, `kit-delphi-fpc_V1.0/`, `kit-vuejs-nodejs_V1.0/`; manifestos `skills-pack-manifest` / `agents-pack-manifest` actualizados; pacote **`.cursor/VERSION.md` 1.0.4**.
- 1.6.3 (30/03/2026): **Constitution/** — índice **`README_V1.0.md`** e manifesto **`constitution-pack-manifest_V1.0.2.md`** (versão no nome dos ficheiros, alinhado a `constitution-*_V1.0.md`); pacote `.cursor` **1.0.3**.
- 1.6.2 (30/03/2026): **Pacote `.cursor` 1.0.2** — consolidação de rodapés duplicados (`Constitution/README`, `diretivas_compilacao`); bloco **Versão interna** em todos os `dev-agent-*` e harmonização `doc-agent-*` / `doc-agent-orchestrator`; **`compile.md`** com tabela FileVersion.
- 1.6.1 (30/03/2026): **[VERSION.md](VERSION.md)** — política de versionamento interno do pack `.cursor/`; `VERSION.md` por área (`agents`, `skills`, …); rubrica em ficheiros `.md`/`.mdc` e comentários em templates HTML/JS.
- 1.6.0 (30/03/2026): **Agentes** — CEO + sub-orquestradores Delphi/VueJS, 4 experts web consolidados; tabela em duas secções (dev/docs); vínculo explícito aos planos por kit; pasta `agents/` na estrutura.
- 1.5.0 (30/03/2026): **`rules/`** — sistema de templates genéricos (`project-fundamentos_V1.0.mdc`, `project-estrutura_V1.0.1.mdc`, `project-documentacao_V1.0.mdc`, `project-roadmap_V1.0.mdc`, `project-exemplos_V1.0.mdc`); originais ORM arquivados em Templates/rules-modelo-orm_V1.0 (removido em 12/04/2026); tabela de rules substituída por sub-tabelas (templates + exemplo ORM); `documentation-rules_creator` na tabela de skills atualizada.
- 1.4.0 (27/03/2026): **`.cursor/Constitution/`** — SSOT das políticas meta-documentais (`constitution-<finalidade>_V1.0.md`); skills/agentes actualizados.
- 1.3.0 (27/03/2026): Skills **documentation-superseded-definition**, **documentation-migration-conflict-resolution**, **documentation-cursor-rules-integration**; agentes **doc-agent-superseded-definition**, **doc-agent-migration-conflict-resolution**, **doc-agent-cursor-rules-integration**; **doc-agent-orchestrator** / **dev-agent-orchestrator** como gestores; políticas em `Documentation/` (posteriormente migradas para **Constitution**).
- 1.2.0 (27/03/2026): Pasta documental canónica **`Documentation/`** (antes `docs/`); roteiros e sync a partir de **`Documentation/`**; referências a `Docs/` no índice substituídas por **`Documentation/`**.
- 1.1.0 (27/03/2026): Roteiros canónicos em **`Documentation/ROTEIROS_CONSOLIDADO.md`** e **`Documentation/LOGICA_DATABASE.md`**; sync para `.claude/`, `.vscode/`, `.continue/` a partir de **`Documentation/`** (junto com `compile.md`, `database.md`, `diretivas_compilacao.md` desde `.cursor/`).
- 1.0.9 (27/03/2026): Tabela skills — **documentation-paste_analysis_unit_class_method** com **`{ClassName}.md`** (`T…` / `I…`); skill 1.2.0.
- 1.0.8 (27/03/2026): Tabela **rules/** — removida entrada **Exceptions_Unificado.mdc**; **Documentacao.mdc** cobre exceções + ExceptionORM.

- 1.0.7 (27/03/2026): Agentes renomeados **doc-agent-***/ **dev-agent-***; tabela de agentes; `dev-agent-orchestrator`; entrada **Documentacao.mdc** alinhada ao scaffold na skill paste.
- 1.0.6 (27/03/2026): Pasta **rules/** descrita como só workspace; **documentation-rules_creator** como dona da política rules vs skills/agents.
- 1.0.5 (27/03/2026): `documentation-general_rules`, `documentation-project-scan`, `documentation-migration-backup` na tabela; **paste_analysis** como dona canónica de `Analise/`; **Documentacao.mdc** descrita como específica do repo + ponteiros.
- 1.0.4 (27/03/2026): Adicionada skill `documentation-paste_analysis_unit_class_method`; atualizada entrada de `documentation-rules_creator` e `documentation-project-feature` com escopo pós-separação.
- 1.0.4 (27/03/2026): Nota sobre preservação de **`.continue/rules/projeto-fonte-cursor.md`** ao usar `/MIR` em `.continue\rules`.
- 1.0.3 (27/03/2026): Espelhos **`.vscode/`** e **`.continue/`** sem subpasta `cursor`; sync por `robocopy` de `skills`, `agents`, `rules`, `plans` + cópia dos MD na raiz.
- 1.0.2 (27/03/2026): Espelho **`.continue/cursor/`** e **`.continue/rules/`** (Continue.dev).
- 1.0.1 (27/03/2026): Seção Espelhos (`.claude/`, `.vscode/cursor/`), comandos de re-sincronização e restauro da seção Referências externas.
- 1.0.0 (26/03/2026): Índice da pasta `.cursor` do Projeto (regras, skills, agentes, documentos).

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 2.1.0 |
| **Política** | [VERSION.md](VERSION.md) |
