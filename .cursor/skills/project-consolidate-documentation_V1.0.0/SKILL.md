---
name: project-consolidate-documentation
description: Auditoria completa de Documentation/ (Analise, Arquitetura, BancoDados, RegrasNegocio, Roteiro, Versionamento, etc.). Executa 7 checks - versionamento (FileVersion em cada .md), links Markdown quebrados, estruturação canónica, nomenclatura ({ClassName}.md em Analise, RN-MXX-NNN.md em RegrasNegocio), hub (README.md/README_Vx.y.md + CHANGELOG.md), portal HTML opcional, formato padrão (12 seções) em RegrasNegocio. Read-only. Use quando o usuário pedir "consolidar documentação", "consolidar docs" ou "auditar Documentation/".
model: sonnet
thinking: extended
category: project
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# project-consolidate-documentation

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Responsabilidade única

Auditoria read-only de `Documentation/` em 7 dimensões. **Não altera arquivos.** Identifica desvios das convenções documentais e gera relatório Markdown com recomendações.

## When to use

- "consolidar documentação" / "consolidar docs" / "/consolidar docs"
- "auditar Documentation/" / "checar a documentação"
- Antes de release (release-notes, versionamento)
- Após migração documental (após `/migration-plan`)
- Verificação periódica de conformidade

## When NOT to use

- Aplicar correções → read-only; usar skills específicas.
- Auditar pack `.cursor/` → `project-consolidate-cursor`.
- Auditar código Pascal → `project-consolidate-source`.
- Migrar/reorganizar docs → `documentation-migration-plan`.

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `documentation-project-scan` | Fornece inventário completo e detecção de gaps |
| `documentation-business-rules` | Define formato padrão (12 seções obrigatórias) |
| `documentation-versioning-changelog` | Define formato de CHANGELOG.md |

## Os 7 checks

### Check 1 — Versionamento dos docs

Varre `Documentation/**/*.md`:

- Cada documento deve ter seção "Versão interna" ou header com `FileVersion` SemVer.
- Hub (`README_Vx.y.md` ou `README.md`) deve ter versão visível no nome ou na primeira linha.
- Changelog consistente (primeira entrada = FileVersion atual).

### Check 2 — Links Markdown

Varre `Documentation/**/*.md`:

- Extrai `\[([^\]]+)\]\(([^)]+)\)`.
- Ignora URLs http/https e âncoras `#secao`.
- Resolve paths relativos ao diretório do arquivo.
- Reporta links quebrados como FAIL com `arquivo:linha`.

### Check 3 — Estruturação

Verifica subpastas canónicas de `Documentation/`:

**Obrigatórias (observadas no workspace):**

- `Analise/`
- `Arquitetura/`
- `BancoDados/`
- `Estrutura/`
- `Exports/`
- `Mapeamento/`
- `Planejamento/`
- `RegrasNegocio/`
- `Roteiro/`
- `Versionamento/`

**Recomendadas (warning, não FAIL se ausentes):**

- `Contratos/`
- `Esboco_Telas/`
- `Backup/`
- `html/` (portal)

Ausência de qualquer obrigatória → FAIL com recomendação "criar via `documentation-project-bootstrap`".

### Check 4 — Nomenclatura

- **`Analise/`**: cada `.md` deve seguir `{ClassName}.md` SEM prefixo `T`/`I`. Ex: `Users.md`, não `TUsers.md`.
- **`RegrasNegocio/`**: cada `.md` deve seguir `RN-M{NN}-{NNN}.md`. Ex: `RN-M01-001.md`.
- **`Arquitetura/`**: nomes em CamelCase ou `{feature}-overview.md`.
- **`BancoDados/`**: nomes em lowercase com hífens (`tabela-users.md`).
- Manifestos: `Documentation/Versionamento/CHANGELOG.md` obrigatório.

### Check 5 — Hub e Changelog

- Existência de `Documentation/README.md` OU `Documentation/README_Vx.y.md`.
- Existência de `Documentation/Versionamento/CHANGELOG.md`.
- Hub deve referenciar todas as subpastas obrigatórias via links relativos (validados no Check 2).

### Check 6 — Portal HTML (opcional)

- Existência de `Documentation/html/index.html` + `Documentation/html/docs-data.js` (se a skill `documentation-portal-html` foi ativada no projeto).
- Ausência → WARNING, não FAIL.

### Check 7 — Formato padrão em RegrasNegocio

Para cada `.md` em `Documentation/RegrasNegocio/`:

Verificar presença das **12 seções obrigatórias** definidas por `documentation-business-rules_V3.1.0`:

1. Cabeçalho (RN-MXX-NNN + Título)
2. Metadados (Status, Prioridade, Autor, Data)
3. Descrição
4. Regras (R01, R02, ...)
5. Condições de aplicação
6. Exceções
7. Dependências
8. Impactos
9. Rastreabilidade
10. Testes de aceitação
11. Histórico de mudanças
12. Referências

Cada seção ausente = FAIL com linha do defeito.

## Como executar

### Via slash command

```text
/consolidar docs                          # 7 checks, stdout
/consolidar docs --check gestordoc        # só RegrasNegocio
/consolidar docs --output Data/docs.md    # grava relatório
```

### Via script diretamente

```powershell
python .cursor/scripts/validate_consolidated.py docs
python .cursor/scripts/validate_consolidated.py docs --check links
python .cursor/scripts/validate_consolidated.py docs --output Data/docs_audit.md
```

## Checklist de validação

- [ ] Check 1 — Versionamento PASS (todos .md com FileVersion).
- [ ] Check 2 — Links quebrados PASS (0 broken).
- [ ] Check 3 — Estruturação PASS (10/10 subpastas obrigatórias).
- [ ] Check 4 — Nomenclatura PASS.
- [ ] Check 5 — Hub e Changelog PASS.
- [ ] Check 6 — Portal HTML (PASS ou WARNING).
- [ ] Check 7 — Formato padrão PASS (12/12 seções em cada RN).

## Anti-padrões

| Anti-padrão | Por que errado | Correção |
|-------------|----------------|----------|
| Docs sem FileVersion | Impede rastreabilidade de mudanças | Adicionar seção "Versão interna" conforme template |
| RN sem 12 seções padrão | Quebra contrato do formato | Usar `documentation-business-rules` como template |
| Links apontando para pasta obsoleta | Navegação quebrada | Corrigir após renomeações/migrações |
| Pastas obrigatórias ausentes | Hub incompleto | Executar `documentation-project-bootstrap` |

## Referência cruzada

| Recurso | Path |
|---------|------|
| Script orquestrador | [`.cursor/scripts/validate_consolidated.py`](../../scripts/validate_consolidated.py) |
| Scanner documental | [`documentation-project-scan_V1.1.0`](../documentation-project-scan_V1.1.0/SKILL.md) |
| Formato padrão | [`documentation-business-rules_V3.1.0`](../documentation-business-rules_V3.1.0/SKILL.md) |
| Command legado | [`.cursor/commands/validate-docs.md`](../../commands/validate-docs.md) |

## Changelog (este arquivo)

- 1.0.0 (16/04/2026): criação — 7 checks de `Documentation/`.
