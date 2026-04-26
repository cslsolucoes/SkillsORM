---
name: project-consolidate-source
description: Auditoria completa de projects/ (Pascal Delphi/FPC - .dpr, .lpr, .pas, .dproj, .lpi). Executa 6 checks - cabeçalhos padrão (backend-pascal-source-header), uses quebrados, estruturação de módulos MXX (Core/Commons/Modulos), nomenclatura (backend-pascal-unit-naming), dry-run de build (dcc32/fpc), binários de build em .gitignore. Read-only. Use quando o usuário pedir "consolidar código fonte", "consolidar código" ou "auditar projects/".
model: sonnet
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-consolidate-source

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Auditoria read-only de `projects/` em 6 dimensões. **Não altera arquivos.** Identifica desvios das convenções Pascal do projeto (headers padrão, nomenclatura, estrutura modular) e gera relatório Markdown com recomendações.

## When to use

- "consolidar código fonte" / "consolidar código" / "consolidar source"
- "/consolidar source" / "/consolidar code"
- "auditar projects/" / "checar código Pascal"
- Antes de commit/push para main
- Antes de release (combinar com `version-release-notes`)
- Após scaffold de módulo novo (verificar conformidade)

## When NOT to use

- Aplicar correções → read-only; usar skills de refactoring por domínio.
- Auditar pack `.cursor/` → `project-consolidate-cursor`.
- Auditar `Documentation/` → `project-consolidate-documentation`.
- Executar testes → `developer-delphi-testing-dunitx` / `developer-delphi-testing-integration`.
- Compilar release final → `developer-delphi-to-fpc-build`.

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `developer-delphi-modular-backend-scaffold` | Define estrutura canónica de módulos MXX |

## Dependências (rules)

| Rule | Motivo |
|------|--------|
| [`backend-pascal-unit-naming_V1.4.0`](../../rules/backend-pascal-unit-naming_V1.4.0.mdc) | Convenções `Commons.*`, `Access.Controller.*`, `Security.Services.*` |
| [`backend-pascal-source-header_V1.0.0`](../../rules/backend-pascal-source-header_V1.0.0.mdc) | Cabeçalho obrigatório em `.pas`/`.dpr`/`.lpr` |

## Os 6 checks

### Check 1 — Cabeçalhos Pascal padrão

Varre `projects/**/*.pas`, `projects/**/*.dpr`, `projects/**/*.lpr` (excluindo `projects/package/` — pacotes de terceiros — e `projects/Compiled/`):

- Verifica se começa com bloco `{ ======== ... ======== }` padrão definido em [pascal-unit-header.template](../../Templates/source-headers/pascal-unit-header.template).
- Verifica campos obrigatórios: `Project:`, `ProjectVersion:`, `FileVersion:`, `Author:`, `Date:`, `Changelog (file):`.
- **Política:** FAIL apenas para **arquivos novos** (criados depois da rule `backend-pascal-source-header_V1.0.0`). Para legados, reporta como WARNING.

### Check 2 — Uses quebrados

Varre `.pas` atrás de seções `uses ... ;`:

- Extrai cada identificador de unit.
- Para cada identificador, verifica se:
  - Existe como `.pas` em `projects/` (recursivo).
  - Existe em `projects/package/` (terceiros).
  - É unit da RTL (lista conhecida: `System.*`, `Vcl.*`, `FMX.*`, `Winapi.*`, `Classes`, `SysUtils`, etc.).
  - É da lista conhecida de extras (`Horse.*`, `DataSet.Serialize`, `JOSE.*`, etc.).
- Identificadores não encontrados → FAIL como "possível uses quebrado".

### Check 3 — Estruturação de módulos MXX

Verifica `projects/backend/MXX-*/`:

- Deve ter `Core/` (único ponto público do módulo).
- Deve ter `Commons/` (entidades compartilhadas — nunca importado externamente).
- Deve ter `Modulos/Services/` e/ou `Modulos/Controllers/RDW/` / `Modulos/Controllers/Horse/`.
- Deve ter `config/` com `database.ini` + `postman/`.
- Outras pastas: `ORM/`, `modules/` (ORMs internos).

FAIL para cada módulo sem estrutura canónica.

### Check 4 — Nomenclatura Pascal

Aplica [`backend-pascal-unit-naming_V1.4.0`](../../rules/backend-pascal-unit-naming_V1.4.0.mdc):

- Arquivos em `Commons/` devem começar com prefixo `Commons.`.
- Controllers devem ser `Access.Controller.*.pas`.
- Services devem ser `Security.Services.*.pas` (evitar `Security.Repository.*`).
- Form units seguem `ufrm.*.pas` ou convenção definida.
- Project file (`*.dpr`/`*.lpr`) na **raiz** de `projects/` (sem prefixo MXX).

FAIL para cada arquivo fora do padrão.

### Check 5 — Build CLI dry-run

Para cada `*.dpr` e `*.lpr` na raiz de `projects/`:

- Verifica existência de `dcc32.cfg` (Delphi) ou `fpc32.opts` (FPC) correspondente.
- Verifica existência de `.dproj` (Delphi) ou `.lpi`+`.lps` (Lazarus).
- **Opcional (se disponível):** executa `dcc32 -Q <projeto>.dpr` (syntax check only) ou `fpc -s @fpc32.opts <projeto>.lpr` (no link).
- Sem dcc32/fpc no PATH → WARNING (skip).

### Check 6 — Binários de build não versionados

Verifica que os seguintes padrões estão presentes em `.gitignore`:

- `Compiled/`
- `*.exe`, `*.dcu`, `*.dcp`, `*.dcpil`
- `*.identcache`, `*.local`, `*.rsm`, `*.map`, `*.~*`
- `*.compiled`, `*.o`, `*.ppu` (FPC)

Também verifica que `projects/Compiled/` **não tem** `.git` tracking ativo.

FAIL por padrão ausente em `.gitignore`.

## Como executar

### Via slash command

```text
/consolidar source                       # 6 checks, stdout
/consolidar source --check headers       # só cabeçalhos
/consolidar source --output Data/src.md  # grava relatório
```

### Via script diretamente

```powershell
python .cursor/scripts/validate_consolidated.py source
python .cursor/scripts/validate_consolidated.py source --check uses
python .cursor/scripts/validate_consolidated.py source --output Data/source_audit.md
```

## Checklist de validação

- [ ] Check 1 — Cabeçalhos Pascal padrão PASS (arquivos novos).
- [ ] Check 2 — Uses quebrados PASS (0 identificadores não encontrados).
- [ ] Check 3 — Estruturação de módulos PASS.
- [ ] Check 4 — Nomenclatura PASS.
- [ ] Check 5 — Build CLI dry-run PASS (ou WARNING se compilador ausente).
- [ ] Check 6 — Binários em `.gitignore` PASS.

## Anti-padrões

| Anti-padrão | Por que errado | Correção |
|-------------|----------------|----------|
| `.pas` novo sem header padrão | Impede rastreabilidade de mudanças | Aplicar template `pascal-unit-header.template` |
| `Core/` importando de `Modulos/` | Quebra encapsulamento (`Core/` é saída pública) | Inverter: `Modulos/` usa `Core/`, nunca o contrário |
| DPR com prefixo de módulo (`M01.Seguranca.Backend.dpr`) | Convenção atual dispensa prefixo | Renomear para `Seguranca.Backend.dpr` |
| `Compiled/` versionado | Binários inflam o repo | Adicionar em `.gitignore` |
| Unit `Security.Repository.*` | Padrão atual é `Security.Services.*` | Renomear conforme V1.3.0 |

## Referência cruzada

| Recurso | Path |
|---------|------|
| Script orquestrador | [`.cursor/scripts/validate_consolidated.py`](../../scripts/validate_consolidated.py) |
| Rule naming | [`.cursor/rules/backend-pascal-unit-naming_V1.4.0.mdc`](../../rules/backend-pascal-unit-naming_V1.4.0.mdc) |
| Rule header | [`.cursor/rules/backend-pascal-source-header_V1.0.0.mdc`](../../rules/backend-pascal-source-header_V1.0.0.mdc) |
| Template header | [`.cursor/Templates/source-headers/pascal-unit-header.template`](../../Templates/source-headers/pascal-unit-header.template) |
| Scaffold MXX | [`developer-delphi-modular-backend-scaffold_V1.0.0`](../developer-delphi-modular-backend-scaffold_V1.0.0/SKILL.md) |
| Bootstrap build | [`.cursor/scripts/bootstrap-build-config.ps1`](../../scripts/bootstrap-build-config.ps1) |

## Changelog (este arquivo)

- 1.0.0 (16/04/2026): criação — 6 checks de `projects/` Pascal.
