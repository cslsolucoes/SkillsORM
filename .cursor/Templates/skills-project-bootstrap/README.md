# Skills Project Bootstrap Templates

Templates utilizados pelo script `.cursor/scripts/bootstrap-skills-project.ps1`
para materializar arquivos paramétricos na raiz de um projeto **Skills Pack**
(repositório cuja função primária é distribuir o pack `.cursor/`).

## Arquivos

| Template | Destino | Versionado | Descrição |
|----------|---------|------------|-----------|
| `CLAUDE.template.md` | `<repo>/CLAUDE.md` | sim | Instruções top-level para Claude Code |
| `README.template.md` | `<repo>/README.md` | sim | README de raiz com pré-requisitos, ciclo de vida, famílias e arquitetura |
| `LICENSE.template` | `<repo>/LICENSE` | sim | Licença MIT paramétrica |
| `privacy-policy.template.md` | `<repo>/privacy-policy.md` | sim | Política de privacidade |
| `workspace-context.template.json` | `<repo>/.workspace/context.json` | sim | Contexto do clone (projectName, projectType, frameworks) |

## Placeholders

| Token | Significado | Default |
|-------|-------------|---------|
| `{PROJECT_NAME}` | Nome do projeto/repo | nome do diretório raiz |
| `{COMPANY}` | Empresa | `CSL Tech Solutions` |
| `{AUTHOR}` | Autor principal | `Claiton de Souza Linhares` |
| `{GITHUB_URL}` | URL do GitHub | `https://github.com/cslsolucoes` |
| `{YEAR}` | Ano da licença | ano atual |
| `{EFFECTIVE_DATE}` | Data efetiva da policy | data atual ISO |

## Política de versionamento

Cada template carrega `internal_template_version: X.Y.Z` no frontmatter (`.md`)
ou em campo de metadata (`.json`/`LICENSE`). O script bootstrap compara com a
versão gravada no arquivo materializado:

- **Igual ou ausente no materializado:** no-op.
- **Template > materializado:** backup em `.cursor/Backup/skills-project/<timestamp>/`
  e sobrescrita.
- **Template < materializado:** warning, no-op (usuário customizou).

## Uso

```powershell
powershell -ExecutionPolicy Bypass -File .cursor/scripts/bootstrap-skills-project.ps1
powershell -ExecutionPolicy Bypass -File .cursor/scripts/bootstrap-skills-project.ps1 -ValidateOnly
```

Disparado automaticamente pela rule `project-autostart-bootstrap_V1.1.0`
quando detecta um Skills Project (`projectType: skills-pack` ou heurística:
existe `.cursor/skills/` populado e não existe `*.dpr`/`*.lpr` na raiz).

---

## Versão interna (deste pacote de templates)

| Campo | Valor |
|-------|-------|
| **FolderVersion** | 1.0.0 |
| **Data** | 2026-04-26 |
