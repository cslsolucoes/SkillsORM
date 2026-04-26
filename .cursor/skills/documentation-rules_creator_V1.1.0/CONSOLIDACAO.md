# Consolidacao de Escopo — documentation-rules_creator

## Objetivo

Definir limites claros entre a skill `documentation-rules_creator` e as skills já existentes para evitar choque operacional.

## Matriz de sobreposicao

| Skill | Sobreposicao | Decisao |
| --- | --- | --- |
| `documentation-project-feature` | Alta | Manter separação por domínio: `Analise/` (feature) vs `.cursor/rules` (rules_creator). |
| `documentation-project-scan` | Moderada | Usar scan como insumo quando necessário; não substituir escopo de `Documentation/`. |
| `documentation-project-bootstrap` | Moderada | Bootstrap continua focado em `Documentation/`; rules_creator foca em `.cursor/rules`. |
| `documentation-portal-html` | Baixa | Portal HTML continua macro para `Documentation/`; rules_creator atua em regras canônicas internas. |
| `project-*` | Baixa | Skills de domínio técnico permanecem fonte de convenções; rules_creator só consolida regras documentais. |

## Roteamento sem conflito

- `documentation-rules_creator`: gerar/revisar `Documentacao_V1.0.mdc`, `Inicial_V1.0.mdc`, `local_arquivos_V1.0.mdc`, `roadmap_V1.0.mdc`.
- `documentation-project-feature`: revisar cobertura e qualidade da pasta `Analise/`.
- `documentation-portal-html` e `documentation-*`: fluxo documental de `Documentation/`.
- `project-*`: convenções do domínio técnico e arquitetura do Projeto.

## Arvore de prioridade (resumo)

1. `rules` (fonte canônica)
2. `plans` (planejamento derivado das rules)
3. `skills` (execução guiada)
4. `agents` (especialização operacional)

---

**Changelog (este arquivo):**

- 1.0.0 (27/03/2026): Relatório inicial de consolidação de escopo, sobreposição e roteamento entre skills.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.1 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).