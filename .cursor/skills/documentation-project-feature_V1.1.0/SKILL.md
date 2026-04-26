---
name: documentation-project-feature
description: Analisa qualquer projeto para criar ou revisar uma pasta `Analise/` com cobertura por funcionalidade (organização, regras de negócios, semântica e lógica), gerando matriz de lacunas, checklist operacional e rastreabilidade com exatidão e precisão.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Project Feature

## Responsabilidade única

Esta skill é responsável exclusivamente por analisar a cobertura documental por funcionalidade de um projeto — avaliando organização, regras de negócio, semântica e lógica — e por gerar matriz de lacunas, checklist operacional e backlog acionável com rastreabilidade. Ela opera sobre documentos já existentes ou após scaffold criado por `documentation-paste_analysis_unit_class_method`, sem redefinir a estrutura física de `Analise/`. A geração de novos arquivos individuais de análise (`{ClassName}.md`) e a árvore de pastas são responsabilidade exclusiva de `documentation-paste_analysis_unit_class_method`.

## When to use

- Quando o usuário pedir para analisar tecnicamente um projeto e estruturar documentação em `Analise/`.
- Quando houver necessidade de validar cobertura por funcionalidade com foco em:
  - organização documental
  - regras de negócios
  - semântica
  - lógica
- Quando a base de análise existir, mas estiver inconsistente (status divergente, lacunas, documentação parcial).

## When NOT to use

- Quando o objetivo for criar arquivos `{ClassName}.md` individuais ou montar a árvore de pastas de `Analise/` — usar `documentation-paste_analysis_unit_class_method`.
- Quando o pedido for documentar arquitetura de módulos — usar `documentation-architecture`.
- Quando a necessidade for um scan de inventário/descoberta de artefatos — usar `documentation-project-scan`.
- Quando o foco for criar análise de gaps genérica (Gaps, Status, Comparativo) — usar `documentation-analysis-index`.
- Quando o pedido for apenas migrar ou reorganizar documentos existentes — usar `documentation-migration-backup`.

## Diretriz permanente global (templates master)

- Skills com prefixo `documentation` e `projeto` são templates master.
- Essas skills só podem ser alteradas com solicitação direta e explícita do usuário.
- Sem solicitação direta, o agente pode usar essas skills, mas não deve editar seu conteúdo.
- **Ficheiros-modelo para `Analise/`:** copiar de **`documentation-paste_analysis_unit_class_method_V1.1.0/templates/`** (dentro de `.cursor/skills/`) — `TEMPLATE_Unit_ClassName.md`, `TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md`, `TEMPLATE_O_QUE_FALTA.md`, etc. — ao propor novos meta-documentos ou reestruturar cobertura.
- Em caso de necessidade de mudança:
  - registrar pendência
  - pedir autorização explícita para:
    - alteração da skill atual, ou
    - criação de nova skill
  - confirmar se a demanda é do tipo `documentation`, `projeto` ou outra específica.

## Inputs

1. `<caminho_raiz_projeto>`: raiz do projeto.
2. `<escopo>` (opcional): módulos/pastas prioritárias.
3. `<idioma_saida>` (opcional): padrão `pt-BR`.
4. `<profundidade>` (opcional): `rápida`, `padrão`, `profunda`.
5. `<stack>` (opcional): linguagem/plataforma para ajustar o padrão de granularidade documental.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-paste_analysis_unit_class_method` | Quando `Analise/` não existir — para criar o scaffold de pastas e arquivos `{ClassName}.md` |
| `documentation-project-scan` | Quando o estado do ecossistema documental for desconhecido — para ter inventário de partida |
| `documentation-general_rules` | Sempre — para naming, versioning e idioma canônicos |

## Passos executáveis

### 1) Descoberta do projeto

- Mapear estrutura técnica (módulos, camadas, componentes centrais).
- Mapear estrutura documental existente (`Analise/`, `Documentation/`, equivalentes).

### 2) Inventário da cobertura por funcionalidade

- Levantar documentos por módulo/funcionalidade.
- Classificar cobertura atual:
  - completo
  - parcial
  - ausente
- Registrar evidência de cada classificação.

### 3) Validação de organização, regras de negócios, semântica e lógica

- **Organização:** local correto, naming, índice e ausência de dispersão.
- **Regras de negócios:** regras explícitas, invariantes e rastreabilidade por funcionalidade.
- **Semântica:** texto do documento condiz com o estado real do código.
- **Lógica:** entradas, saídas, exceções, casos-limite e fluxos documentados.

### 4) Geração da matriz de lacunas

Para cada módulo/funcionalidade, gerar:

- `Módulo`
- `Organização`
- `Regra de negócio identificada (sim/não)`
- `Regra de negócio testável/documentada (sim/parcial/não)`
- `Semântica`
- `Lógica`
- `Ação recomendada`
- `Prioridade`
- `Evidência`

### 5) Geração do checklist operacional

Checklist mínimo por funcionalidade:

- organização validada
- responsabilidade clara
- regras de negócio explícitas
- critérios de aceite por regra
- rastreabilidade para evidências
- semântica consistente com o código
- lógica completa (incluindo exceções/casos-limite)
- status único entre documentos correlatos

### 6) Backlog e plano de execução

- Converter lacunas em backlog acionável.
- Priorizar por impacto e risco.
- Definir critério de pronto por item (testável).

## Outputs obrigatórios

1. Diagnóstico de cobertura atual em `Analise/`.
2. Matriz de lacunas por módulo/funcionalidade contendo:
   - organização
   - regras de negócios identificadas
   - regras de negócios testáveis/documentadas
   - semântica
   - lógica
   - ação recomendada
   - prioridade
   - evidência
3. Checklist operacional para "Analise completa" por funcionalidade.
4. Backlog acionável (`criar`, `revisar`, `consolidar`) com critérios de aceite testáveis.
5. Rastreabilidade: documento -> funcionalidade -> regra de negócio -> evidência.

## Checklist de aceite

- Cobertura por funcionalidade foi analisada com evidências objetivas.
- Matriz de lacunas inclui validação explícita de regras de negócios.
- Checklist final inclui seção específica de regras de negócios.
- Inconsistências semânticas/lógicas foram explicitadas.
- Backlog final é acionável e testável.
- O processo fica replicável em outros projetos com exatidão e precisão.

## Template de saída (resposta)

A resposta deve seguir esta ordem:

1. Resumo executivo (3-6 bullets)
2. Cobertura atual por módulo/funcionalidade
3. Matriz de lacunas (tabela)
4. Checklist operacional
5. Backlog priorizado com critérios de aceite
6. Recomendações de consolidação

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Executar esta skill sem scaffold prévio de `Analise/` | A skill analisa documentos existentes; sem eles, a análise é vazia ou inventada | Executar `documentation-paste_analysis_unit_class_method` primeiro para criar a estrutura |
| Redefinir a estrutura física de `Analise/` nesta skill | Duplica responsabilidade com `documentation-paste_analysis_unit_class_method` e cria conflito de autoridade | Limitar esta skill a qualidade, lacunas e rastreabilidade — nunca à estrutura física |
| Classificar cobertura sem evidência objetiva | Resultado não confiável; pode mascarar lacunas reais | Marcar explicitamente como "lacuna / evidência insuficiente" em vez de inferir |
| Misturar análise de múltiplos projetos em uma execução | Perda de rastreabilidade; backlog ambíguo | Executar uma instância por `<caminho_raiz_projeto>` |
| Gerar backlog sem critérios de aceite testáveis | Itens irrealizáveis ou não verificáveis pelo revisor | Cada item de backlog deve ter verbo de ação + critério de pronto mensurável |

## Avaliação de risco

- **Baixo:** Análise de cobertura com `Analise/` populada e escopo bem definido.
- **Médio:** Análise sem scaffold completo — risco de matriz incompleta.
- **Alto:** Análise sem evidências suficientes — risco de induzir decisões erradas de priorização.

## Métricas de sucesso

- A matriz de lacunas cobre 100% dos módulos identificados no `<escopo>`, com evidência registrada para cada classificação.
- O checklist operacional tem pelo menos um item verificável por funcionalidade analisada.
- O backlog gerado é acionável sem necessidade de reinterpretação (cada item tem verbo + critério de pronto).
- O resultado é replicável: outra execução com os mesmos insumos produz resultado equivalente.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Executor da skill | Agente de documentação (Claude Code) |
| Aprovador da análise | Usuário / tech lead do projeto |
| Mantenedor dos templates de `Analise/` | Responsável pela skill `documentation-paste_analysis_unit_class_method` |

## Observações de uso genérico

- Se o projeto não tiver pasta `Analise/`, invocar `documentation-paste_analysis_unit_class_method` primeiro para criar o scaffolding de pastas e arquivos **`{ClassName}.md`** (`T…` / `I…`); só então executar esta skill para popular com análise real.
- **Não redefinir** nesta skill a **estrutura física** de `Analise/` (subpastas por domínio, naming **`{ClassName}.md`**): isso é responsabilidade exclusiva de `documentation-paste_analysis_unit_class_method`. Aqui trata-se de **qualidade**, matriz de lacunas, RN, checklist e semântica **sobre** documentos já existentes ou após o scaffold.
- Ordem de fluxo entre skills: ver `documentation-general_rules` quando necessário.
- Se o naming local for diferente de **`ClassName.md`** (`T…` / `I…`), manter o padrão do projeto, preservando rastreabilidade.
- Quando não houver evidência suficiente, marcar explicitamente como lacuna em vez de inferir.

## Regras to consult (quando disponíveis)

- `.cursor/rules/Inicial_V1.0.mdc`
- `.cursor/rules/Documentacao_V1.0.mdc`
- `.cursor/rules/roadmap_V1.0.mdc`
- `.cursor/rules/local_arquivos_V1.0.mdc`

---

## Versão interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionados `thinking: extended`, `category: documentation`, seções `Responsabilidade única`, `When NOT to use`, `Dependências (skills prévias)`, `Anti-padrões`, `Avaliação de risco`, `Métricas de sucesso`, `Responsável principal`; tabelas convertidas para estilo `| --- |`; reordenação canônica de seções; FileVersion 1.0.1 → 1.1.0.
- 1.0.4 (27/03/2026): **`.cursor/Templates/`** como fonte de `TEMPLATE_*` para meta-documentos em `Analise/`.
- 1.0.3 (27/03/2026): Naming **`{ClassName}.md`** (`T…` / `I…`) alinhado a **documentation-paste_analysis_unit_class_method** 1.2.0.
- 1.0.2 (27/03/2026): Delimitação explícita — não redefinir estrutura física de `Analise/`; referência a `documentation-general_rules`.
- 1.0.1 (27/03/2026): Atualizada observação de uso — scaffolding de `Analise/` delegado para `documentation-paste_analysis_unit_class_method` quando a pasta não existir.
- 1.0.0 (27/03/2026): Criação da skill `documentation-project-feature` com processo completo para análise de projetos e geração/revisão da pasta `Analise/` com foco em organização, regras de negócios, semântica e lógica.
