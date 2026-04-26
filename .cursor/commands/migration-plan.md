---
name: migration-plan
description: Gera um plano de migracao documental para o projecto — analisa estado actual, identifica gaps, propoe fases de migracao com matriz origem/destino e dependencias.
---

# /migration-plan

Gera um plano de migracao documental para o projecto.

## Escopo

Invocar quando o projecto apresentar documentacao desorganizada, sem estrutura canonica, ou quando for necessario migrar de um formato legado para o padrao padrão (`Documentation/` com 13 subpastas). Aplica-se a qualquer projecto que use o pack `.cursor/`.

**NAO invocar** quando: a documentacao ja esta migrada e validada; nesse caso usar `/validate-docs` para verificacao de conformidade.

## Uso

```text
/migration-plan [opcoes]
```

## Skills invocadas

| Skill | Quando/Por que e chamada |
|-------|--------------------------|
| `documentation-project-scan` | Fase 1 — inventario completo do estado atual |
| `documentation-migration-backup` | Antes de qualquer alteracao — backup e matriz origem/destino |
| `documentation-project-bootstrap` | Define a estrutura alvo (13 subpastas canonicas) |
| `documentation-business-rules` | Formato padrão alvo para Regras de Negocio |

## Parâmetros

| Parâmetro | Tipo | Padrao | Descrição |
|-----------|------|--------|-----------|
| *(nenhum obrigatorio)* | — | — | Usa o projeto atual como alvo |

## Comportamento

1. **Inventario do estado actual**: analisa `Documentation/`, `Analise/`, `.cursor/` e qualquer pasta documental existente.
2. **Deteccao de formatos legados**: identifica documentos em formatos antigos (RN monoliticos, nomenclatura sem `Mxx`, ficheiros `T*.md` / `I*.md` em `Analise/`).
3. **Matriz origem/destino**: para cada documento legado, define o destino canonico e a transformacao necessaria.
4. **Fases de migracao**: agrupa as transformacoes em fases ordenadas por dependencia e prioridade.
5. **Plano de backup**: define o que sera movido para `Documentation/Backup/` antes da migracao.
6. **Estimativa de esforco**: por fase, indica quantidade de ficheiros e complexidade.

## Exemplos de uso

```text
# Gerar plano de migracao para o projecto atual
/migration-plan

# Apos revisar o plano, confirmar execucao
/migration-plan --confirmar
```

## Saida

Plano de migracao em Markdown com:

- Resumo executivo
- Inventario do estado actual (tabela)
- Matriz origem/destino (tabela)
- Fases ordenadas com dependencias
- Plano de backup
- Criterios de aceite por fase
- Estimativa de esforco

O plano e guardado em `.cursor/plans/` com a convencao `migration-plan_<hash>.plan.md`.

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Escopo, Skills invocadas (tabela), Parâmetros, Exemplos de uso; versão interna formalizada.
- 1.0.0 (04/04/2026): Versao inicial do comando.
