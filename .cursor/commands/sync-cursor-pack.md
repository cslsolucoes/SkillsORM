---
name: sync-cursor-pack
description: Propaga o pack .cursor/ do projecto actual para um ou mais projectos destino. Copia scripts, skills, Templates, agents; limpa orfaos; verifica coerencia.
---

# /sync-cursor-pack

Propaga o pack `.cursor/` para projectos destino.

## Escopo

Invocar quando for necessario sincronizar o pack `.cursor/` (skills, agents, templates, scripts) do projecto atual (fonte/SSOT) para outros projectos que usam o mesmo pack. Requer que o projeto fonte esteja estavel e validado.

**NAO invocar** quando o projecto destino tiver customizacoes locais nao presentes na fonte — verificar antes com `--modo=validate`.

## Uso

```text
/sync-cursor-pack [caminhos dos projectos destino separados por espaco]
```

## Skills invocadas

| Skill | Quando/Por que e chamada |
|-------|--------------------------|
| `documentation-project-update` | Atualiza manifesto e referencias apos sync |

## Parâmetros

| Parâmetro | Tipo | Padrao | Descrição |
|-----------|------|--------|-----------|
| `[caminho...]` | string | *(projeto atual)* | Caminhos absolutos dos projectos destino |
| `--modo=validate` | flag | — | Somente valida diferencas sem copiar |

## Comportamento

1. Usa o projecto actual como **fonte** (SSOT).
2. Para cada projecto destino indicado:
   - Compara `VERSION.md` da fonte e do destino.
   - Copia areas propagaveis: `scripts/`, `skills/`, `Templates/`, `agents/`, `commands/`, `rules/`, `plans/`, ficheiros raiz.
   - Remove skills/agents/dirs obsoletos no destino.
   - Reconstrói symlinks no destino via bootstrap.
3. Emite relatorio de sync.

## Script

```bash
# Windows
python .cursor/scripts/sync_cursor_pack.py --dest E:\ProjetoDestino

# Linux / macOS
python3 .cursor/scripts/sync_cursor_pack.py --dest /home/user/GestorERP

# Multiplos destinos
python3 .cursor/scripts/sync_cursor_pack.py --dest E:\ProjetoDestino E:\OutroProjeto

# Previa sem alterar
python3 .cursor/scripts/sync_cursor_pack.py --whatif --dest E:\ProjetoDestino
```

```powershell
# Windows (PowerShell alternativo)
powershell -ExecutionPolicy Bypass `
  -File ".cursor/scripts/sync-cursor-pack.ps1" `
  -DestinationPaths "E:\ProjetoDestino" -WhatIf
```

## Exemplos de uso

```text
# Sincronizar para um projeto destino
/sync-cursor-pack E:\ProjetoDestino

# Sincronizar para multiplos projectos
/sync-cursor-pack E:\ProjetoDestino E:\OutroProjeto

# Apenas validar diferencas sem copiar
/sync-cursor-pack E:\ProjetoDestino --modo=validate
```

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Escopo, Skills invocadas (tabela), Parâmetros, Exemplos de uso expandidos; versão interna formalizada.
- 1.0.0 (04/04/2026): Versao inicial do comando.
