# Templates de configuração — espelhos IDE

**Localização:** `.cursor/Templates/mirror-config/`

Templates para inicializar ficheiros de configuração específicos de cada IDE/ferramenta nos espelhos (`.claude/`, `.vscode/`, `.continue/`) e **OpenCode** na raiz (`opencode.json`). Estes ficheiros são **copiados** (não symlinked) porque contêm paths e configurações locais.

---

## Templates disponíveis

| Template | Destino | Tipo |
|----------|---------|------|
| `vscode-settings.template.json` | `.vscode/settings.json` | Ficheiro real (copiar) |
| `vscode-tasks.template.json` | `.vscode/tasks.json` | Ficheiro real (copiar) |
| `vscode-extensions.template.json` | `.vscode/extensions.json` | Ficheiro real (copiar) |
| `claude-settings.template.json` | `.claude/settings.json` | Ficheiro real (copiar) |
| `claude-settings-local.template.json` | `.claude/settings.local.json` | PRIVADO (copiar, nao versionar) |
| `opencode.json.template` | `opencode.json` (raiz do repo) | Config OpenCode (`instructions`, `watcher`) |
| `continue-stub.template.md` | `.continue/` | Stub para futura config |

## Placeholders

| Placeholder | Descricao | Exemplo |
|-------------|-----------|---------|
| `{REPO_ROOT}` | Caminho absoluto da raiz (outros templates JSON que ainda o usem) | `<caminho-absoluto-do-clone>` (por máquina; **não** usar em `vscode-tasks.template.json` — preferir `${workspaceFolder}`) |
| `{PROJECT_NAME}` | Nome do projecto | `ProvidersORM` |
| `{PROJECT_DPR}` | Ficheiro principal `.dpr` | `ProvidersORM.dpr` |
| `{FPC_ROOT}` | Raiz da instalação FPC (**fora do repo** — manter absoluto) | `D:\fpc\fpc` |
| `{OLLAMA_HOST}` | Host do servidor Ollama | `192.168.1.100` |
| `{OLLAMA_MODEL}` | Modelo Ollama a utilizar | `qwen2.5-coder:32b-instruct-q6_K` |

### `vscode-tasks.template.json` (`.vscode/tasks.json`)

- **Todo o conteúdo versionado no repositório** (`.dpr`, `.opts`, `SQLite/`, `Data/`, scripts em `.cursor/`, etc.): usar exclusivamente **`${workspaceFolder}/<caminho-relativo>`** em `command` / `args`; **`options.cwd`:** `${workspaceFolder}`. Não embutir letra de unidade nem caminho absoluto do clone.
- **Labels e nome de projeto:** variável nativa `${workspaceFolderBasename}` — resolvida pelo VSCode sem necessidade de substituição por script.
- **Arquivos do projeto (`.dpr`):** `${workspaceFolder}/${workspaceFolderBasename}.dpr` — sem placeholder `{PROJECT_DPR}`.
- **Compilador FPC (fora do workspace):** variável de ambiente `${env:FPC_ROOT}` — definir `FPC_ROOT` no sistema ou em `terminal.integrated.env.windows` no `settings.json`. **Não** usar `{FPC_ROOT}` com substituição por script neste template.

## Como usar

1. **Automático:** O script `bootstrap-mirror-symlinks.ps1` copia os templates para os destinos quando estes não existem.
2. **Manual:** Copiar o template, renomear para o nome final, substituir `{PLACEHOLDERS}` pelos valores reais.

## Quando copiar vs quando usar symlink

- **Copiar:** ficheiros de configuração específicos da IDE (paths locais, extensões, permissões).
- **Symlink:** conteudo partilhado de `.cursor/` (rules, skills, agents, templates, etc.).

---

**Changelog (este arquivo):**

- 1.0.4 (12/04/2026): Seção `vscode-tasks.template.json` atualizada — política agora usa **`${workspaceFolderBasename}`** para labels/projeto e **`${env:FPC_ROOT}`** para compilador FPC; placeholders `{PROJECT_NAME}`, `{PROJECT_DPR}`, `{FPC_ROOT}` removidos deste template (substituição por script eliminada).
- 1.0.3 (12/04/2026): Política reforçada — **sempre** `${workspaceFolder}` para artefactos no repo; exemplos de placeholders sem projeto concreto; `{REPO_ROOT}` apenas noutros templates legados.
- 1.0.2 (12/04/2026): Política de paths em **`vscode-tasks.template.json`** — `${workspaceFolder}` no repo; `{FPC_ROOT}` fora; `{REPO_ROOT}` já não é usado neste template.
- 1.0.1 (03/04/2026): Template **`opencode.json.template`** → raiz `opencode.json`.
- 1.0.0 (30/03/2026): Criacao — templates de configuracao para espelhos IDE.

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.4 |
| **Politica** | `.cursor/VERSION.md` |
