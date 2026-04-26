<!-- internal_template_version: 1.0.0 -->
# SkillsORM — Skills Pack para desenvolvimento Delphi/FPC com IA

> Ciclo completo SSOT: da escrita ao laudo, unificando a robustez do **VCL (Windows)** com a versatilidade do **FMX (Windows/Linux/macOS)**. Ecossistema baseado em **VS Code** e **Cursor** com SSOT propagado por **24 scripts PS1/Python**.

| Métrica | Valor |
|---|---|
| Skills ativas | 213 (221 físicas) |
| Agentes especializados | 36 |
| Commands | 14 (7 Workflow + 7 Execution) |
| Rules `.mdc` | 12 |
| Scripts (PS1 + Python) | 24 |
| Manifesto | V1.24.0 · Config 2.0.0 |

Apresentação completa interativa: [`.cursor/ApresentationSkillsORM.html`](.cursor/ApresentationSkillsORM.html).

---

## Pré-requisitos

### Sistema operacional

- **Windows 10 / 11** (recomendado).
  Os scripts `bootstrap-*.ps1` criam **symlinks** entre `.cursor/` (SSOT) e os espelhos `.claude/`, `.vscode/`, `.continue/`, `.opencode/` — exigem **uma** das opções abaixo:
  - Sessão **PowerShell elevada como Administrador**, **ou**
  - **Modo Programador** ativado em *Configurações → Privacidade e Segurança → Para desenvolvedores*.
- **Linux/macOS:** suporte parcial via equivalentes Python (`bootstrap_*.py`). Symlinks funcionam nativamente sem privilégios elevados.

### Ferramentas obrigatórias

| Ferramenta | Versão mínima | Uso |
|---|---|---|
| **PowerShell** | 5.1+ (Windows) ou 7.x (multiplataforma) | execução dos scripts `bootstrap-*.ps1` |
| **Python** | 3.10+ | scripts `*.py` em `.cursor/scripts/` (validação, índices FTS5, sync) |
| **Git** | 2.30+ | versionamento |

### IDEs e assistentes de IA suportados

Os espelhos são gerados automaticamente — basta abrir o repositório em qualquer das ferramentas abaixo:

- **[Cursor](https://cursor.com)** (SSOT primário — `.cursor/`)
- **[Claude Code (CLI ou VS Code)](https://docs.claude.com/en/docs/claude-code)** (`.claude/`)
- **VS Code** com extensões compatíveis (`.vscode/`)
- **[Continue](https://continue.dev)** (`.continue/`)
- **[OpenCode](https://opencode.ai)** TUI/CLI (`.opencode/` + `opencode.json`)

### Toolchain Delphi/FPC (apenas para usar este pack em projetos reais)

Este repositório por si só **é um pack de skills**, não exige Delphi instalado. Para aplicar o pack em um projeto Delphi/FPC, você precisará:

| Toolchain | Quando | Caminho padrão |
|---|---|---|
| **RAD Studio Delphi 12+** (`dcc32` / `dcc64`) | projetos VCL/FMX | `C:\Program Files (x86)\Embarcadero\Studio\23.0` |
| **Free Pascal Compiler** | projetos LCL / cross-compile | `D:\fpc\fpc` |
| **Lazarus IDE** | projetos LCL | `D:\fpc\lazarus` |

Os caminhos são configuráveis via parâmetros do `bootstrap-build-config.ps1` ou via `.workspace/context.json`.

---

## Instalação rápida

### 1) Clonar o repositório

```powershell
git clone https://github.com/cslsolucoes/SkillsORM.git
cd SkillsORM
```

### 2) Validar/criar os espelhos (FASE 1 do autostart)

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1" -ValidateOnly
```

Se reportar problemas e você estiver em sessão **elevada** ou com **Modo Programador**, rode sem `-ValidateOnly`:

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1"
```

### 3) Materializar arquivos paramétricos de raiz (FASE 2-A — Skills Project)

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-skills-project.ps1" -ValidateOnly
```

Cria/atualiza `CLAUDE.md`, `LICENSE`, `privacy-policy.md`, `README.md`, `.workspace/context.json` a partir dos templates em [`.cursor/Templates/skills-project-bootstrap/`](.cursor/Templates/skills-project-bootstrap/) — idempotente, com backup automático em `.cursor/Backup/skills-project/<timestamp>/` quando o template tiver versão maior.

### 4) Abrir no editor

Abrir a pasta no Cursor / Claude Code / VS Code. As skills, agents, rules e commands são reconhecidos automaticamente via os espelhos.

---

## O Ciclo de Vida (7 commands de Workflow)

Cada command delega a um agente especializado. A skill `developer-delphi-coding-standards` está **sempre ativa** durante todas as fases.

```text
/new-project → /spec → /write → /tdd → /doc → /review → /audit
   bootstrap   especificar  escrever  testar  documentar  revisar  auditar
```

| Command | Função | Agente | Skill principal |
|---|---|---|---|
| `/new-project` | Scaffold Delphi/FPC + build config + claudeignore | writer | `coding-workflow` |
| `/spec` | SPEC por engenharia reversa, rastreável | spec-writer | `project-spec` |
| `/write` | Nova unit, serviço, form, interface (bilíngue) | writer | `coding-workflow` |
| `/tdd` | Suite DUnitX (mocks, AAA, TestCase parametrizado) | tester | `testing-dunitx V1.1` |
| `/doc` | Análise classe-a-classe + índice FTS5 | doc-orchestrator | `documentation-*` |
| `/review` | Code smells, SOLID, violações de padrão | reviewer | `coding-standards` |
| `/audit` | Laudo técnico completo, bilíngue, com estimativas | auditor | `project-audit` |

Outros 7 commands de **Execution**: `/autostart`, `/iniciar`, `/consolidar`, `/syncdb`, `/validate-docs`, `/sync-cursor-pack`, `/migration-plan`.

### Cenários típicos

**Projeto legado:** `/audit` → `/spec` → `/review` → `/write` (refactor guiado).
**Nova feature:** `/write` → tester auto-invocado → `/review` (validação SOLID).
**Projeto novo:** `/new-project` (P1..P9 interativo) → `/spec` (arquitetura upfront) → `/write` + `/tdd` iterativo.

---

## Famílias de skills (213 ativas)

| Família | Skills | Cobertura |
|---|---:|---|
| `developer-delphi-*` | 116 | Horse (16 ✅), FMX (7), Assembly (11), Language (6), VCL (3 ✨), FireDAC (4 ✨), Indy (4 ✨), JSON, Crypto, FastReport, CI-CD, Shared-Libs (4), Linux (3), Win-Services (3), Patterns (4), RTL (4), REST DataWare (4), Active Directory (4), Mobile (5), Threading (2), Testing (3) — *e mais 12* |
| `documentation-*` | 30 | project (6), migration (2), architecture, business-rules, api-openapi, portal-html, class-analysis, versioning, roadmap, … |
| `governance-*` | 21 | spec (5), artifact (4), team (3), pack-sync, sdlc-lifecycle, release, change-request, … |
| `developer-web-*` + `vuejs-*` | 17 (21 físicas) | Vue 3 Composition (V1.1 ✨), routing-state (V1.1 ✨), components (V1.1 ✨), forms-validation, api-integration, testing, Vue 2 → Vue 3 migration, Node.js API, build-tooling, … |
| `quality-*` | 10 | code-review, test-strategy, bug-triage, refactoring-safe, regression-guard, hotfix, tech-debt, acceptance, security-audit ✨ |
| `version-*` | 6 | semver-product, release-notes, breaking-change, deprecation, migration-assistant, orchestrator |

---

## Os 36 agentes (5 grupos)

- **Delphi Workflow (4):** Auditor · Spec-Writer · Writer · Tester
- **Delphi ORM Domain (11):** delphi-orchestrator · modules-orchestrator · views-orchestrator · connections-expert · database-expert · exceptions-expert · loggers-expert · orm-architect · parameters-expert · poolconnections-expert · views-expert
- **Vue · Web (5):** vuejs-orchestrator · vuejs-core-expert · vuejs-routing-state · web-quality-expert · web-runtime-build
- **Documentação (12):** doc-orchestrator · architecture · class-scanner · class-writer · class-indexer · migration · review · roadmap · rules · cursor-rules-integration · superseded-definition · migration-conflict-resolution
- **Plugin/Skill Dev (4):** agent-creator · plugin-validator · skill-reviewer · *(outros utilitários)*

---

## Implementação técnica — `.cursor/` (SSOT)

### Estrutura de pastas

```
.cursor/                      ← Fonte canónica (SSOT)
├── skills/                   ← 213 skills ativas (.md + frontmatter + exemplos)
├── agents/                   ← 36 agentes (.md)
├── commands/                 ← 14 slash-commands (.md)
├── rules/                    ← 12 rules (.mdc) com alwaysApply / globs / template
├── scripts/                  ← 24 scripts (10 PS1 + 14 Python)
├── Templates/                ← templates de scaffold (build-config, form-units, skills-project-bootstrap)
└── ApresentationSkillsORM.html  ← apresentação interativa do pack

.claude/  .vscode/  .continue/  .opencode/   ← espelhos via symlinks → .cursor/
.workspace/                                  ← estado por clone (context.json, index.db)
```

### 24 Scripts de bootstrap e infraestrutura

**Bootstrap (8):** `bootstrap-mirror-symlinks` (PS1+Python), `bootstrap-autostart-mirrors` (PS1+Python), `bootstrap-build-config.ps1`, `bootstrap-form-unit.ps1`, `bootstrap-skills-project.ps1`, `Bootstrap-Reset.ps1`, `bootstrap_reset.py`.

**Sync e propagação (3):** `sync-cursor-pack` (PS1+Python), `scaffold-modules-backend.ps1`.

**Validação (3):** `validate_pack.py` (1548 checks · 0 CRITICAL), `validate_consolidated.py`, `validate-skills-consistency.py`.

**Indexação FTS5 (2):** `pack_index_db.py`, `database_session_manager.py` (3 bases SQLite: pack/workspace/docs).

**Geração e transformação (5):** `gen_pack_inventory.py`, `gen_project_index.py`, `gen_fileversion.py`, `gen_audit_badge.py`, `transform-headers-backend.ps1`, `transform-headers-adorm.ps1`.

**Utilitários (3):** `decompile-chm` (PS1+Python), `apply_mit_to_skills.py`.

### 12 Rules

| Rule | Escopo | Função |
|---|---|---|
| `project-autostart-bootstrap_V1.2.0` | always | Valida espelhos · detecta Skills Project (FASE 2-A) · detecta `*.dpr`/`*.lpr` · criação interativa P1..P9 |
| `documentation-migration-plan-mode_V1.0.0` | always | Exige plano completo antes de operar áreas protegidas |
| `backend-pascal-unit-naming_V1.6.0` | always | `ModuleConcept.Feature.pas` · §4.3 conexões usam `.Connection.` |
| `artifact-placement-policy_V1.1.0` | always | Classifica `.cursor/` (SSOT) vs `.workspace/` (instância) vs `.docs/` |
| `pascal-encoding-no-escapes_V1.0.0` | always | Proíbe `#NNN`/`#$NNNN` em strings Pascal — usar UTF-8 |
| `local_arquivos_V1.0` | always | SSOT em `.cursor/`; nunca editar espelhos diretamente |
| `pack-inventory-autoupdate_V1.0.0` | globs | Atualiza manifests ao detectar mudanças em `.cursor/` |
| `scripts-nomenclature_V1.3.0` | globs | kebab-case PS1, snake_case Python, sufixo de versão |
| `backend-pascal-source-header_V1.0.0` | globs | Cabeçalho padrão em fontes Pascal novas |
| `documentation-file-versioning_V1.0.0` | tmpl | 4 formas aceitas de versão em `.md`/`.mdc` |
| `project-documentacao_V1.0.1` | tmpl | Estrutura canônica de documentação |
| `project-plans-persist_V1.0.0` | ctx | Persistência de planos em `.cursor/plans/` |

---

## Áreas protegidas (plan mode obrigatório)

Antes de criar, mover, renomear, fundir ou eliminar arquivos em qualquer das áreas abaixo, é **obrigatório apresentar um plano completo e aguardar aprovação explícita** do usuário — mesmo que ele diga "execute" ou "faça":

- `Documentation/` (recursivo)
- `.cursor/skills/` (recursivo)
- `.cursor/Templates/` (recursivo)
- `.cursor/agents/` (recursivo)
- `.cursor/rules/` (recursivo)

Detalhes em [`CLAUDE.md`](CLAUDE.md) §"Áreas protegidas".

---

## Documentação

- [`CLAUDE.md`](CLAUDE.md) — instruções top-level para Claude Code
- [`.cursor/ApresentationSkillsORM.html`](.cursor/ApresentationSkillsORM.html) — apresentação visual interativa
- [`.cursor/README.md`](.cursor/README.md) — hub do pack
- [`.cursor/Templates/skills-project-bootstrap/README.md`](.cursor/Templates/skills-project-bootstrap/README.md) — templates de bootstrap deste projeto
- [`privacy-policy.md`](privacy-policy.md) — política de privacidade
- [`LICENSE`](LICENSE) — MIT

## Suporte e contato

- **Empresa:** CSL Tech Solutions
- **Autor:** Claiton de Souza Linhares
- **GitHub:** https://github.com/cslsolucoes

---

## Licença

[MIT](LICENSE) — Copyright (c) 2026 CSL Tech Solutions.
