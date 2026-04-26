---
name: documentation-analysis-index
description: Cria ou atualiza documentos de análise/índice em `Documentation/Analise/` com estrutura rastreável e acionável.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Analysis Index

## Responsabilidade única

Esta skill é responsável exclusivamente por criar e atualizar documentos de análise em `Documentation/Analise/`, garantindo que cada documento tenha objetivos claros, metodologia explícita, achados rastreáveis e recomendações acionáveis. Ela opera sobre um tópico por execução (ex.: Gaps, Status, Comparativo, Risco), transformando evidências e insumos existentes em documentos estruturados com critérios de aceite verificáveis. A atualização do hub de documentação e o registro no changelog são responsabilidade do orquestrador após a conclusão desta skill.

## When to use

- Quando o usuário pedir inventários, análise de lacunas, status e decisões documentais.
- Quando o scan identificar itens em `Documentation/Analise/` faltantes ou inconsistentes.

## When NOT to use

- Quando o objetivo for documentar a arquitetura de um módulo — usar `documentation-architecture`.
- Quando o pedido for um scan de descoberta de artefatos e lacunas — usar `documentation-project-scan`.
- Quando for necessário documentar regras de negócio — usar `documentation-business-rules`.
- Quando o foco for análise de cobertura por funcionalidade (matriz de lacunas com RN) — usar `documentation-project-feature`.
- Quando for preciso migrar ou reorganizar documentos existentes — usar `documentation-migration-backup`.
- Quando o objetivo for gerar ou atualizar o roadmap do produto — usar `documentation-roadmap-from-docs`.

## Inputs

1. `<topico>`: tema da análise (ex.: `Gaps`, `Status`, `Comparativo`, `Risco`).
2. `<versao_docs>`: `Vx.y`.
3. `<insumos>`: lista/tabelas/inventários já existentes, ou evidências.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-project-scan` | Quando o tópico for gaps ou inventário — para ter relatório de insumos já gerado |
| `documentation-general_rules` | Sempre — para naming, versioning e idioma canônicos |
| `documentation-project-feature` | Quando o tópico envolver análise de cobertura por funcionalidade |

## Passos executáveis

1. Definir objetivos da análise (o que a análise precisa responder).
2. Incluir metodologia (como foi classificado/criteriado).
3. Inserir seções:
   - achados (tabela/itens)
   - impactos (o que desbloqueia)
   - recomendações acionáveis (próximas ações)
4. Conectar com roadmap/backlog (quando aplicável): cada item deve ter ação concreta.

## Outputs

- `Documentation/Analise/Analise_<topico>_Vx.y.md`
- Atualização do hub se aplicável.

**Base (ficheiro-modelo):** copiar **`templates/TEMPLATE_Docs_Analise.md`** para o path canónico (ajustar nome/versão), depois preencher.

## Checklist de aceite

- Não contém "achismos": cada achado aponta para evidência ou referência.
- As recomendações são operacionalizáveis (criar/revisar/consolidar/mover para Backup).
- Naming/versioning conforme skill `documentation-general_rules` (naming conventions).

## Template de saída (arquivo)

1. Cabeçalho + escopo
2. Objetivos e metodologia
3. Tabelas/itens de achados
4. Impacto e recomendações
5. Checklist de aceite

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Criar análise sem insumos concretos | Produz "achismos" não rastreáveis que não passam nos critérios de aceite | Levantar evidências ou executar `documentation-project-scan` antes |
| Misturar múltiplos tópicos num único arquivo | Dilui o escopo e viola o princípio de responsabilidade única por documento | Criar um arquivo por tópico com naming `Analise_<topico>_Vx.y.md` |
| Recomendações sem ação concreta | Backlog não acionável; o time não sabe o próximo passo | Cada recomendação deve ter verbo de ação (criar/revisar/consolidar/mover) + critério de aceite |
| Usar este documento para documentar arquitetura | Mistura de preocupações; dificulta localização pelos consumidores da documentação | Criar documento separado via `documentation-architecture` |
| Omitir metodologia de classificação | Resultados não replicáveis; próxima execução pode divergir | Inserir seção explícita de metodologia com critérios e fontes |

## Avaliação de risco

- **Baixo:** Atualização de análise existente com insumos claros fornecidos pelo usuário.
- **Médio:** Criação de nova análise sem scan prévio — risco de achados incompletos.
- **Alto:** Análise de gaps estrutural sem evidências objetivas — resultado pode induzir decisões erradas.

## Métricas de sucesso

- Cada achado no documento aponta para pelo menos uma evidência ou referência verificável.
- As recomendações são convertíveis diretamente em itens de backlog sem retrabalho de interpretação.
- O documento segue naming e versioning canônicos (verificável via `documentation-general_rules`).
- O hub é atualizado ou sinalizado para atualização pelo orquestrador.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Executor da skill | Agente de documentação (Claude Code) |
| Aprovador do conteúdo | Usuário / tech lead do projeto |
| Mantenedor do template base | Responsável pelo pack `.cursor/Templates/` |

## Exemplo de referência canônica

- **`templates/TEMPLATE_Docs_Analise.md`**
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/Analise/` (quando existir)

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionados `thinking: extended`, `category: documentation`, seções `Responsabilidade única`, `When NOT to use`, `Dependências (skills prévias)`, `Anti-padrões`, `Avaliação de risco`, `Métricas de sucesso`, `Responsável principal`; reordenação canônica de seções; FileVersion 1.0.1 → 1.1.0.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
