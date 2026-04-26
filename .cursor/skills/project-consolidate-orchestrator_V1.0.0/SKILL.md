---
name: project-consolidate-orchestrator
description: Orquestrador de consolidação/auditoria do workspace. Recebe "consolidar", "/consolidar" ou "consolidar <alvo>" e roteia para a skill especializada conforme o alvo. Alvos suportados - cursor (pack .cursor/), documentação (Documentation/), código fonte (projects/), tudo (executa os 3 em sequência). Se o alvo não for especificado, apresenta menu interativo ao usuário. Sempre read-only - nunca altera arquivos.
model: haiku
thinking: minimal
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-consolidate-orchestrator

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill é o **ponto de entrada único** para qualquer pedido de "consolidar" no workspace. Sua única responsabilidade é **classificar o alvo** e **despachar** para a skill especializada correta. Não executa checks diretamente; delega integralmente.

**Não cobre:** execução de correções automáticas, migração de arquivos, refatoração. Apenas roteamento.

## When to use

- "consolidar" (sem alvo) → apresentar menu.
- "consolidar cursor" / "auditar o pack" / "checar .cursor" → despachar para `project-consolidate-cursor`.
- "consolidar documentação" / "consolidar docs" / "auditar Documentation" → despachar para `project-consolidate-documentation`.
- "consolidar código fonte" / "consolidar código" / "auditar projects" → despachar para `project-consolidate-source`.
- "consolidar tudo" / "auditoria completa" → rodar os 3 em sequência.
- `/consolidar [alvo]` (slash command) → idem.

## When NOT to use

- Migração de documentação → `documentation-migration-plan`.
- Sincronização do pack entre projetos → `governance-pack-sync`.
- Validação semântica de documentação específica → `validate-docs` (command).
- Aplicar correções automaticamente → **nenhuma** das skills de consolidação altera arquivos. Para fixes, usar a skill correspondente ao domínio.

## Roteamento

| Entrada do usuário | Alvo | Skill delegada |
|---|---|---|
| `consolidar` / `/consolidar` | (pergunta) | — (apresenta menu) |
| `consolidar cursor` / `/consolidar cursor` / `auditar pack` | **cursor** | [`project-consolidate-cursor`](../project-consolidate-cursor_V1.1.0/SKILL.md) |
| `consolidar documentação` / `consolidar docs` / `consolidar documentacao` | **docs** | [`project-consolidate-documentation`](../project-consolidate-documentation_V1.0.0/SKILL.md) |
| `consolidar código fonte` / `consolidar código` / `consolidar source` / `consolidar code` | **source** | [`project-consolidate-source`](../project-consolidate-source_V1.0.0/SKILL.md) |
| `consolidar tudo` / `consolidar all` / `auditoria completa` | **all** | Os 3 em sequência |

## Menu interativo (quando alvo omisso)

```text
Consolidar o quê?

  [1] cursor          — audita o pack .cursor/ (versões, links, estrutura, nomenclatura, /init, autostart)
  [2] documentação    — audita Documentation/ (versões, links, estrutura, nomenclatura, hub, padrão)
  [3] código fonte    — audita projects/ (cabeçalhos Pascal, uses, estrutura, nomenclatura, build, .gitignore)
  [4] tudo            — executa os 3 em sequência

Escolha (1-4):
```

## Workflow executável

1. Identificar alvo na requisição do usuário (via match de palavras-chave na tabela acima).
2. Se alvo ausente → apresentar o menu interativo.
3. Confirmado o alvo:
   - **cursor**: invocar `project-consolidate-cursor`.
   - **docs**: invocar `project-consolidate-documentation`.
   - **source**: invocar `project-consolidate-source`.
   - **all**: invocar `cursor` → `docs` → `source`, concatenar relatórios num único arquivo.
4. Encaminhar parâmetros opcionais (`--output`, `--check`) conforme sintaxe do slash command.
5. Apresentar relatório final ao usuário.

## Script auxiliar

Todas as skills delegadas usam o mesmo script Python:

```powershell
python .cursor/scripts/validate_consolidated.py <alvo> [--check <dim>] [--output <file>]
```

## Referência cruzada

| Recurso | Path |
|---------|------|
| Skill cursor | [`.cursor/skills/project-consolidate-cursor_V1.1.0/`](../project-consolidate-cursor_V1.1.0/SKILL.md) |
| Skill documentation | [`.cursor/skills/project-consolidate-documentation_V1.0.0/`](../project-consolidate-documentation_V1.0.0/SKILL.md) |
| Skill source | [`.cursor/skills/project-consolidate-source_V1.0.0/`](../project-consolidate-source_V1.0.0/SKILL.md) |
| Command | [`.cursor/commands/consolidar.md`](../../commands/consolidar.md) |
| Script orquestrador | [`.cursor/scripts/validate_consolidated.py`](../../scripts/validate_consolidated.py) |

## Changelog (este arquivo)

- 1.0.0 (16/04/2026): criação — or