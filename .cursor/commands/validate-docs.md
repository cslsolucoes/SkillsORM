---
name: validate-docs
description: Verifica coerencia da documentacao do projecto — estrutura de pastas, formatos obrigatorios, links internos, gaps e conformidade com o pack .cursor/.
---

# /validate-docs

Verifica a coerencia da documentacao do projecto.

## Escopo

Invocar apos qualquer migracao documental, antes de entregas, ou para auditoria periodica de conformidade. Aplica-se ao projecto atual ou a um caminho especificado.

**NAO invocar** como substituto de `/migration-plan` — este comando apenas valida, nao executa migracoes.

## Uso

```text
/validate-docs [caminho opcional — padrao: projecto actual]
```

## Skills invocadas

| Skill | Quando/Por que e chamada |
|-------|--------------------------|
| `documentation-project-scan` | Inventario completo e deteccao de gaps |
| `documentation-project-bootstrap` | Referencia da estrutura esperada (13 subpastas) |
| `documentation-business-rules` | Formato padrão para validacao de RNs |

## Parâmetros

| Parâmetro | Tipo | Padrao | Descrição |
|-----------|------|--------|-----------|
| `[caminho]` | string | *(projecto atual)* | Caminho absoluto do projecto a validar |

## Comportamento

1. **Estrutura `Documentation/`**: verifica se as 13 subpastas obrigatorias existem (Analise, Arquitetura, BancoDados, Contratos, Esboco_Telas, Estrutura, Mapeamento, Planejamento, Regras de Negocio, Roadmap, Versionamento, Backup, html).
2. **Hub**: verifica existencia de `Documentation/README_Vx.y.md` e `Documentation/Versionamento/CHANGELOG.md`.
3. **Portal HTML**: verifica existencia de `Documentation/html/index.html` e `Documentation/html/docs-data.js`.
4. **Formato padrão**: para cada ficheiro em `Documentation/Regras de Negocio/`, verifica se contem as 12 seccoes obrigatorias.
5. **Nomenclatura `Analise/`**: verifica se ficheiros seguem `{ClassName}.md` sem prefixo `T`/`I`.
6. **Links internos**: detecta links quebrados entre documentos Markdown.
7. **Gaps**: lista documentos esperados (derivados de `src/`) que nao existem.

## Exemplos de uso

```text
# Validar projecto atual
/validate-docs

# Validar projecto especifico
/validate-docs E:\CaminhoDoProjeto
```

## Saida

Relatorio com:

- Checklist de conformidade (PASS/FAIL por criterio)
- Lista de gaps detectados
- Lista de links quebrados
- Recomendacoes de correccao

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Escopo, Skills invocadas (tabela), Parâmetros, Exemplos de uso; versão interna formalizada.
- 1.0.0 (04/04/2026): Versao inicial do comando.
