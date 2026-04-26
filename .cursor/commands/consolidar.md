---
name: consolidar
description: Auditoria consolidada do workspace — cursor (pack .cursor/), documentação (Documentation/) ou código fonte (projects/). Invoca a skill especializada via orchestrator; gera relatório Markdown com PASS/FAIL por dimensão e recomendações. Read-only.
---

# /consolidar

Audita read-only um alvo do workspace. Verifica versionamento, links, estrutura, nomenclatura, e convenções específicas do alvo.

## Escopo

Invocar como verificação de rotina, antes de commit/push, antes de release, ou após mudanças estruturais. **Nunca altera arquivos** — apenas identifica desvios das convenções e gera relatório com recomendações acionáveis.

**NÃO invocar** como substituto de:
- `/migration-plan` (migração real de arquivos)
- `/sync-cursor-pack` (sincronização entre projetos)
- `/validate-docs` (validação semântica documental)

## Uso

```text
/consolidar                        # menu interativo
/consolidar cursor                 # audita .cursor/
/consolidar docs                   # audita Documentation/
/consolidar source                 # audita projects/
/consolidar all                    # roda os 3 em sequência
```

Opções:

- `--check <dim>` — roda só uma dimensão (`version|links|structure|naming|...`).
- `--output <file>` — grava relatório em arquivo (default: stdout).

## Skills invocadas

| Skill | Quando/Por que é chamada |
|-------|--------------------------|
| `project-consolidate-orchestrator` | Ponto de entrada — roteia por alvo |
| `project-consolidate-cursor` | Auditoria do pack `.cursor/` (6 checks) |
| `project-consolidate-documentation` | Auditoria de `Documentation/` (7 checks) |
| `project-consolidate-source` | Auditoria de `projects/` (6 checks) |

## Parâmetros

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `<alvo>` | string | *(pergunta)* | `cursor`, `docs`, `source` ou `all` |
| `--check <dim>` | string | `all` | Dimensão específica (depende do alvo) |
| `--output <file>` | path | stdout | Arquivo de saída |

## Dimensões por alvo

| Alvo | Dimensões |
|------|-----------|
| `cursor` | `version`, `links`, `structure`, `naming`, `init`, `autostart` |
| `docs` | `version`, `links`, `structure`, `naming`, `hub`, `html`, `gestordoc` |
| `source` | `headers`, `uses`, `structure`, `naming`, `build`, `ignore` |

## Comportamento

1. **Orchestrator identifica alvo.** Se omisso, apresenta menu `[1] cursor [2] docs [3] source [4] all`.
2. **Skill especializada** executa os checks (reutilizando `validate_pack.py`, `bootstrap-mirror-symlinks.ps1`, `bootstrap-build-config.ps1` quando aplicável).
3. **Script orquestrador** (`validate_consolidated.py`) consolida os resultados.
4. **Relatório Markdown** é apresentado (stdout) ou gravado (se `--output`).
5. **Exit code**: 0 se todos PASS, 1 se houver FAIL.

## Exemplos de uso

```text
# Menu interativo
/consolidar

# Auditoria completa do pack
/consolidar cursor

# Só links quebrados em docs
/consolidar docs --check links

# Grava relatório em arquivo
/consolidar source --output Data/audit_source.md

# Roda tudo e grava num único arquivo
/consolidar all --output Data/audit_full.md
```

## Saída

Relatório estruturado com:

- **Resumo:** tabela com PASS/FAIL por dimensão.
- **Detalhes por dimensão:** lista itens com status e mensagem.
- **Recomendações acionáveis:** comandos exatos para corrigir.
- **Próximos passos:** checklist para re-validação.

## Execução direta (sem slash command)

```powershell
python .cursor/scripts/validate_consolidated.py <alvo> [--check <dim>] [--output <file>]
```

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (16/04/2026): criação — slash command `/consolidar` com 3 alvos + orchestrator.
