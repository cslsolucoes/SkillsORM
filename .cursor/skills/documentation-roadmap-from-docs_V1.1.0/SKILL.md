---
name: documentation-roadmap-from-docs
description: Gera um roadmap detalhado de documentação a partir da pasta `Documentation/` (hub `README_Vx.y.md`, Arquitetura, Regras de Negocio, Esboco_Telas, Analise, Versionamento, Roadmap e Backup). Use quando o usuario pedir "criar roadmap" ou "planejar documentação" baseado nos arquivos já existentes dentro de `Documentation/`.
model: sonnet
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Roadmap From Docs

## Responsabilidade única

Esta skill é a responsável exclusiva pela geração de roadmaps documentais estruturados em fases (curta/média/longa) a partir dos artefactos existentes em `Documentation/`. Resolve o problema de não saber "o que falta documentar e em que ordem", transformando o estado atual dos docs em um plano priorizado com backlog, matriz de impacto e critérios de pronto testáveis. Existe separada de `documentation-project-scan` porque scan é diagnóstico (o que existe/falta) enquanto roadmap é planejamento (o que fazer, quando, por quem e com qual critério de conclusão). Garante que o roadmap seja derivado de evidências nos ficheiros existentes e não de suposições genéricas.

## When NOT to use

- Quando o objetivo for gerar conteúdo documental novo (classes, RNs, telas) — usar as skills específicas (`documentation-class-analysis-generator`, `documentation-business-rules`, `documentation-screen-sketches`).
- Quando o objetivo for apenas listar o que existe na `Documentation/` sem planejar ações — usar `documentation-project-scan`.
- Quando o objetivo for criar a estrutura inicial de documentação de um novo projeto — usar `documentation-project-bootstrap`.
- Quando o objetivo for atualizar um documento específico já existente — usar `documentation-project-update`.
- Quando não existir nenhum artefacto em `Documentation/` — executar `documentation-project-bootstrap` primeiro para criar a base mínima.

## When to use

- Quando o usuario pedir para **criar um roadmap de documentação** baseado no que já existe na pasta `Documentation/`.
- Quando o usuario disser que quer planejar "o que falta documentar", "próximas fases da documentação", "backlog documental" ou algo equivalente.

## Inputs obrigatorios

1. `Documentation/README_Vx.y.md` (hub com a árvore atual e versões).
2. Pelo menos um destes conjuntos:
   - `Documentation/Arquitetura/`
   - `Documentation/Regras de Negocio/`
   - `Documentation/Esboco_Telas/`
   - `Documentation/Analise/`
3. Opcional, mas recomendado:
   - `Documentation/Versionamento/` (política + changelog documental)
   - `Documentation/Roadmap/` (roadmap anterior para comparação)
   - `Documentation/Backup/` (histórico superseded)

## Outputs obrigatorios (estrutura)

A skill deve gerar um arquivo principal (ex.: `Documentation/Roadmap/Roadmap_Fase0_Vx.y.md`) e um bloco de backlog no corpo da resposta. Se o usuario indicar um nome/pasta de destino diferente, ajustar mantendo o mesmo conteúdo.

### Estrutura mínima do arquivo gerado (seções obrigatórias)

1. Cabeçalho e contexto (versão/data + escopo desta fase)
2. Resumo executivo da fase
3. Roadmap da fase (lista ordenada de ciclos/passos + dependencias)
4. Entradas e saídas esperadas (quais artefatos devem existir no template)
5. Responsaveis (placeholders)
6. Critério de pronto da fase (testável)

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-project-scan` | Recomendado — executar scan para obter inventário atual de `Documentation/` antes de gerar o roadmap; evita itens "criar" para docs já existentes. |
| `documentation-general_rules` | Sempre — verificar convenções de nomenclatura, versionamento e idioma antes de criar arquivos de roadmap. |

## Princípios operacionais (extraídos das referências)

**Ficheiros-modelo:** novos artefactos listados no roadmap devem, quando aplicável, partir de **`templates/TEMPLATE_Docs_Roadmap.md`** (dentro desta skill) e **`.cursor/Templates/`** (`TEMPLATE_Docs_*`, índice `README.md`).

1. **Menos é mais no hub (README)**: o `Documentation/README_Vx.y.md` deve ser um índice curto e “navegável”, com links para conteúdo detalhado; nunca consolidar tudo no hub.
2. **Segmentar por tema**: cada subpasta do template (`Arquitetura/`, `Regras de Negocio/`, `Esboco_Telas/`, `Analise/`, etc.) representa uma categoria clara de leitura.
3. **Documentação útil e buscável**: cada item do roadmap e do backlog deve apontar diretamente para caminhos/arquivos e critérios de aceite testáveis.
4. **Plano de atualização sempre presente**: toda resposta deve incluir revisão contínua e gatilhos (criar, atualizar, mover para Backup).
5. **Evitar duplicação**: se um documento esperado já existe como canônico no hub, o roadmap deve preferir `revisar/consolidar` a `criar`.
6. **Ciclo de feedback e edição**: antes de finalizar um roadmap, o processo deve prever rascunho → feedback estrutural/gramática → edição → finalização.

### 1) Roadmap por fases

Gerar pelo menos 3 fases:
- **Fase Curta** (1–2 ciclos): itens essenciais para habilitar o uso do projeto (documentação mínima)
- **Fase Media** (3–5 ciclos): cobertura expandida por módulo e rastreabilidade completa
- **Fase Longa** (6+ ciclos): aprofundamentos, revisões e melhorias contínuas

Para cada fase, incluir:
- Objetivo operacional (1–3 bullets)
- Escopo documental (quais subpastas impacta)
- Entradas necessárias (quais documentos/artefatos devem existir ou serem criados)
- Saídas esperadas (arquivos gerados/atualizados)
- Dependencias (o que pode bloquear)
- Responsaveis (usar placeholders genéricos: `Responsavel_Arquitetura`, `Responsavel_RN`, `Responsavel_Analise`, `Responsavel_Review`)
- Criterio de pronto por fase (lista objetiva)

### 2) Backlog de documentação faltante

Criar uma lista organizada por prioridade com colunas:
- `Documento esperado` (path alvo dentro de `Documentation/`)
- `Status atual` (ex.: existente, parcial, ausente)
- `Ação` (criar, revisar, consolidar, mover para Backup)
- `Responsavel`
- `Criterio de aceite` (checklist curto e testável)
- `Dependencias`

### 3) Matriz prioridade × impacto × dependência

Gerar uma tabela (ou matriz em texto) com:
- prioridade: `Alta | Media | Baixa`
- impacto: `Alto | Medio | Baixo`
- dependência: `Baixa | Media | Alta`

Regras: a prioridade deve ser derivada do que desbloqueia mais rápido a utilidade do hub e a rastreabilidade.

### 4) Plano de revisão e atualização contínua

Incluir:
- cadência de revisão (ex.: mensal/por release documental)
- gatilhos (ex.: criação/atualização/movimentação de docs)
- responsáveis
- ciclo de feedback/edição (rascunho → feedback → edição final)
- checklist de verificação pós-merge (hub resync, links, duplicação, versionamento)

### 5) Critérios de pronto por fase

Além dos critérios dentro de cada fase, incluir um resumo consolidado:
- "Pronto para fase" = todas as ações do backlog daquela fase atendidas + hub sincronizado + ausência de duplicação residual.

## 4.4 Critérios de qualidade (verificáveis)

Esta seção define como a resposta deve ser checada antes de considerar o roadmap "concluido".

1. **Detalhamento operacional (não genérico)**
   - Nenhum item do roadmap pode ser apenas uma frase abstrata.
   - Para cada ação, incluir ao menos: `Documento esperado`, `Ação`, `Criterio de aceite`, `Responsavel`.
   - Se o usuario pedir "planilhar", "rastrear", "organizar", converter automaticamente o pedido em ações com entradas/saídas.

2. **Rastreabilidade documento → ação de roadmap**
   - Para cada documento existente (por exemplo, `Documentation/Arquitetura/...` e `Documentation/Regras de Negocio/...`), indicar explicitamente:
     - qual ação ele influencia no roadmap
     - qual lacuna ele resolve (ou não resolve)
   - Incluir uma tabela curta `Documento → Ação no roadmap` com pelo menos 5 linhas quando houver abundância de docs.

3. **Clareza de responsáveis/entradas/saídas**
   - Para cada fase, listar placeholders de responsáveis e o que cada papel faz.
   - Para cada ação do backlog, indicar:
     - entrada (arquivo atual ou ausência)
     - saída (arquivo esperado novo/revisado/movido)
     - critério de aceite (checklist mínimo)

4. **Ausência de duplicação com docs já existentes**
   - A skill deve comparar as rotas alvo do backlog com o hub (`Documentation/README_Vx.y.md`):
     - se o arquivo destino já existe e cobre o escopo esperado, o backlog deve mudar de `criar` para `revisar` (ou `N/A`).
     - se existe conteúdo parcial, pedir revisão/consolidação ao invés de duplicação.
   - Quando detectar colisão de destino (dois itens apontam para o mesmo path), resolver priorizando o documento mais canônico e enviar o excedente para Backup (conforme política do projeto).

## Template de saída (para padronizar)

A resposta deve seguir esta ordem:
1. Resumo executivo (3–6 bullets)
2. Lista de fases (curta/média/longa) com entradas/saídas/dependências
3. Backlog (tabela)
4. Matriz prioridade × impacto × dependência
5. Rastreabilidade (tabela Documento → Ação)
6. Plano de revisão contínua + checklist pós-mudança

## Exemplo de referência canônica

- **`templates/TEMPLATE_Docs_Roadmap.md`** (dentro desta skill) e **`.cursor/Templates/`** — índice `README.md`.
- **EXEMPLO DE DOCUMENTAÇÃO** (quando existir): `EXEMPLO DE DOCUMENTAÇÃO/Docs/README_V1.5.md` e subpastas `Docs/Arquitetura`, `Docs/Regras de Negocio`, `Docs/Esboco_Telas`, `Docs/Analise`.
- Em outro repositório, aplicar o mesmo layout conceitual e convenções, copiando os `TEMPLATE_*` necessários para `.cursor/Templates/` quando fizer sentido.

## Checklist final (antes de concluir)

- [ ] Aceite 4.4 — detalhamento operacional: cada ação do backlog/roadmap possui `Documento esperado`, `Ação`, `Criterio de aceite` e `Responsavel` (sem itens genéricos).
- [ ] Aceite 4.4 — rastreabilidade documento → ação: existe tabela `Documento → Ação no roadmap` cobrindo as lacunas relevantes.
- [ ] Aceite 4.4 — clareza de responsáveis/entradas/saídas: cada fase e cada item do backlog indicam entradas e saídas esperadas.
- [ ] Aceite 4.4 — ausência de duplicação: nenhum item “criar” aponta para um path já canônico no hub; destinos duplicados foram convertidos para `revisar/consolidar` ou para `Backup`.

- [ ] Hub resync: validação explícita de que `Documentation/README_Vx.y.md` está sincronizado com o mapa final e sem links órfãos.

- [ ] Roadmap tem fases com entradas/saídas/dependências e critérios de pronto.
- [ ] Backlog aponta documento esperado e critério de aceite testável.
- [ ] Rastreabilidade documento → ação está presente (tabela).
- [ ] Ausência de duplicação: nenhuma ação `criar` aponta para um arquivo já canônico existente no hub.
- [ ] Responsáveis e papéis estão claros (placeholders quando necessário).
- [ ] Plano de revisão contínua inclui gatilhos e checklist.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Gerar roadmap sem ler `Documentation/README_Vx.y.md` e as subpastas existentes | Roadmap baseado em suposições; itens "criar" para docs já existentes; duplicação | Sempre ler o hub e inventariar `Documentation/` antes de gerar (ou executar `documentation-project-scan` primeiro) |
| Criar itens genéricos no backlog sem `Documento esperado`, `Ação` e `Critério de aceite` | Itens inacionáveis; revisores não conseguem verificar se foram concluídos | Cada item do backlog deve ter caminho alvo, ação (criar/revisar/consolidar/mover) e checklist mínimo |
| Gerar roadmap com menos de 3 fases (curta/média/longa) | Não cobre o horizonte completo; projetos ficam sem plano de manutenção contínua | Sempre gerar as 3 fases com entradas/saídas/dependências e critério de pronto por fase |
| Apontar ação "criar" para documento já canônico no hub | Gera duplicação; confunde sobre qual é a fonte verdadeira | Verificar hub antes de adicionar item; usar `revisar/consolidar` quando o doc já existe |

## Métricas de sucesso

- Checklist final (4 itens do critério 4.4) integralmente preenchido na resposta: detalhamento operacional, rastreabilidade documento→ação, clareza de responsáveis e ausência de duplicação (zero itens "criar" apontando para paths já canônicos no hub).
- Roadmap gerado com 3 fases, cada uma com objetivo, entradas, saídas, dependências e critério de pronto explícitos.
- Arquivo `Documentation/Roadmap/Roadmap_Fase0_Vx.y.md` criado/atualizado com hub resincronizado após execução.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech lead / responsável pela documentação do projeto |
| Aprovação final | Product owner / dono do repositório |

---

**Changelog (este arquivo):**

- 1.0.1 (27/03/2026): Princípio **Ficheiros-modelo** — **`.cursor/Templates/`**; exemplo de referência actualizado.
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).