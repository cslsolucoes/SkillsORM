---
name: governance-pack-sync
description: Sincroniza o pack .cursor/ de um projeto fonte (SSOT) para um ou mais projetos destino — copia skills/agents/templates/scripts/rules, remove orphãos, reconstrói symlinks via Bootstrap e valida integridade com validate_pack.py.
model: haiku
thinking: minimal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance — Pack Sync

Propaga o pack `.cursor/` de um projeto **fonte** (SSOT) para um ou mais projetos **destino**, garantindo que todos os projetos da família usem o mesmo pack versionado.

## Responsabilidade única

Esta skill encapsula o workflow completo de sincronização do pack `.cursor/` — desde a validação da fonte até a reconstrução dos symlinks no destino — usando `sync-cursor-pack.ps1` + `bootstrap-mirror-symlinks.ps1` + `validate_pack.py`. Não cobre versioning, criação de novas skills ou migração V2 (ver skills de referência abaixo).

## When to use

- Após migrar ou criar skills/agents no projeto fonte (SSOT) e querer propagar as mudanças.
- Ao inicializar um novo projeto da família com o pack existente.
- Quando o destino está desatualizado — manifest version do destino < versão da fonte.
- Para sincronizar múltiplos projetos destino de uma vez.

## When NOT to use

- Se o destino tem customizações locais em `.cursor/` não presentes na fonte — o sync deleta orphãos; risco de perda irreversível. Avaliar primeiro com `--whatif` / `-WhatIf`.
- Se `validate_pack.py` na fonte retorna issues — sincronizar fonte quebrada propaga problemas.
- Como substituto de Git merge/PR para alterações de código-fonte (`src/`, `app/`).
- Para versionar ou criar novas skills → usar `governance-pack-versioning-policy` + `governance-pack-checklist-validation`.

## Inputs obrigatórios

| Input | Descrição |
|-------|-----------|
| `fonte` | Caminho absoluto do projeto SSOT (ex.: `e:\Providers.2.1.0`) |
| `destino(s)` | Caminho(s) absoluto(s) dos projetos destino (ex.: `P:\EM_ANDAMENTO\GestorERP`) |

## Dependências (skills prévias)

| Skill | Papel |
|-------|-------|
| `governance-pack-checklist-validation` | Validar que a fonte está íntegra antes do sync |
| `governance-pack-versioning-policy` | Verificar versões dos manifestos fonte vs. destino |

## Workflow executável

### Passo 1 — Validar fonte

```bash
# Cross-platform (Python)
python3 "<fonte>/.cursor/scripts/validate_pack.py"
python3 "<fonte>/.cursor/scripts/bootstrap_mirror_symlinks.py" --validate-only
```

```powershell
# Windows (PowerShell alternativo)
python "<fonte>\.cursor\scripts\validate_pack.py"
powershell -ExecutionPolicy Bypass `
  -File "<fonte>\.cursor\scripts\bootstrap-mirror-symlinks.ps1" -ValidateOnly
```

**Critério de prosseguimento:** 0 issues em ambos os comandos.

### Passo 2 — Backup do destino

```bash
# Cross-platform (Python)
import shutil, datetime
ts = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
shutil.copytree('<destino>/.cursor', f'<destino>/Backup/.cursor_{ts}')
```

```powershell
# Windows (PowerShell alternativo)
$ts = Get-Date -Format "yyyyMMdd_HHmmss"
Copy-Item -Path "<destino>\.cursor" `
          -Destination "<destino>\Backup\.cursor_$ts" `
          -Recurse -Force
```

### Passo 3 — Verificar planos locais no destino

```bash
# Cross-platform
ls "<destino>/.cursor/plans"
```

Se existirem planos destino-específicos não presentes na fonte, salvá-los antes do sync — serão sobrescritos (orphãos removidos).

### Passo 4 — Simulação com `--whatif`

```bash
# Cross-platform (Python) — recomendado
python3 "<fonte>/.cursor/scripts/sync_cursor_pack.py" \
  --whatif --dest "<destino>"
```

```powershell
# Windows (PowerShell alternativo)
powershell -ExecutionPolicy Bypass `
  -File "<fonte>\.cursor\scripts\sync-cursor-pack.ps1" `
  -DestinationPaths "<destino>" `
  -WhatIf
```

Revisar output: itens a serem deletados/copiados. Confirmar antes de prosseguir.

### Passo 5 — Sync real

```bash
# Cross-platform (Python) — recomendado
python3 "<fonte>/.cursor/scripts/sync_cursor_pack.py" \
  --dest "<destino>"

# Múltiplos destinos
python3 "<fonte>/.cursor/scripts/sync_cursor_pack.py" \
  --dest "<destino1>" "<destino2>"
```

```powershell
# Windows (PowerShell alternativo)
powershell -ExecutionPolicy Bypass `
  -File "<fonte>\.cursor\scripts\sync-cursor-pack.ps1" `
  -DestinationPaths "<destino>" `
  -Force

# Múltiplos destinos (separar por vírgula)
-DestinationPaths "<destino1>","<destino2>"
```

### Passo 6 — Reconstruir symlinks e validar destino

```bash
# Cross-platform (Python) — recomendado
python3 "<destino>/.cursor/scripts/bootstrap_mirror_symlinks.py" --repair
python3 "<destino>/.cursor/scripts/validate_pack.py"
```

```powershell
# Windows (PowerShell alternativo — requer UAC/Admin)
powershell -ExecutionPolicy Bypass `
  -File "<destino>\.cursor\scripts\bootstrap-mirror-symlinks.ps1" `
  -Repair
python "<destino>\.cursor\scripts\validate_pack.py"
```

## Outputs obrigatórios

- `.cursor/` do destino atualizado (skills, agents, rules, templates, scripts, commands, plans, README.md, VERSION.md)
- 4 mirrors com symlinks íntegros: `.claude/`, `.vscode/`, `.continue/`, `.opencode/`
- `validate_pack.py` retorna 0 issues no destino
- Contagem de pastas `skills/` no destino == fonte

## Checklist de validação

- [ ] Fonte: `validate_pack.py` 0 issues + `Bootstrap -ValidateOnly` OK
- [ ] Backup do destino criado com timestamp
- [ ] `-WhatIf` revisado — nenhuma deleção inesperada
- [ ] `Bootstrap -Repair` executado com sucesso (exit code 0)
- [ ] Destino: `validate_pack.py` 0 issues

## Anti-padrões

| Anti-padrão | Consequência |
|-------------|-------------|
| Rodar sync sem `-WhatIf` primeiro | Deleção de arquivos destino-específicos sem revisão prévia |
| Não fazer backup antes do sync | Perda irreversível de customizações locais |
| Sincronizar com fonte com issues | Problemas propagados para todos os projetos destino |
| Editar `.claude/`/`.vscode/` diretamente no destino após sync | Sobrescritos na próxima sincronização (SSOT é `.cursor/`) |
| Executar `Bootstrap -Repair` sem Admin/UAC | Falha silenciosa na criação de symlinks |

## Avaliação de risco

**Alto.** O sync remove todos os arquivos no destino que não existem na fonte (orphãos). Um backup antes do sync é obrigatório. Revisar sempre o output do `--whatif` / `-WhatIf` antes de confirmar.

## Métricas de sucesso

- `validate_pack.py` 0 issues no destino
- `ls .cursor/skills | measure` no destino == fonte
- `Bootstrap -ValidateOnly` 0 erros no destino

## Responsável principal

`dev-agent-orchestrator` (CEO técnico) — coordena a operação e valida os resultados.

## Referências

| Artefato | Caminho |
|----------|---------|
| Script de sync (Python) | `.cursor/scripts/sync_cursor_pack.py` |
| Script de sync (PowerShell) | `.cursor/scripts/sync-cursor-pack.ps1` |
| Script de symlinks (Python) | `.cursor/scripts/bootstrap_mirror_symlinks.py` |
| Script de symlinks (PowerShell) | `.cursor/scripts/bootstrap-mirror-symlinks.ps1` |
| Script de validação | `.cursor/scripts/validate_pack.py` |
| Skill de versioning | `governance-pack-versioning-policy` |
| Skill de checklist | `governance-pack-checklist-validation` |
| Command relacionado | `.cursor/commands/sync-cursor-pack.md` |

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (09/04/2026): Adicionados equivalentes Python cross-platform (sync_cursor_pack.py, bootstrap_mirror_symlinks.py) em cada passo do workflow; atualizada tabela de Referências; linguagem de risco ajustada (robocopy /MIR → sync genérico); FileVersion 1.0.0 → 1.1.0.
- 1.0.0 (09/04/2026): Versão inicial — skill V2 canônica para sync do pack `.cursor/` entre projetos da família; 6-passo workflow com backup obrigatório, `-WhatIf`, Bootstrap e validate_pack.py; família `governance-pack-*`.
