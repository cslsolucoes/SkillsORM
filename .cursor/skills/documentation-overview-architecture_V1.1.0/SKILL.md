---
name: documentation-overview-architecture
description: Guia para produzir documentação Overview (visao geral de projeto) e Architecture (arquitetura profunda por componente) no padrao de qualidade dos modelos ProvidersORM_Overview.md e ProvidersORM_Overview_Arquitetura.md. Define estrutura, secoes obrigatorias, profundidade de conteudo e criterios de aceite para ambos os tipos de documento.
model: opus
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — Overview + Architecture Quality Model

## Responsabilidade única

Esta skill é a **referência de qualidade de conteúdo** para documentos Overview e Architecture —
ela define as estruturas obrigatórias (5 seções por módulo no Overview, 8 sub-seções por
componente na Architecture), padrões de profundidade, formato de tabelas e diagramas ASCII.
Existe separada de `documentation-architecture` (que cuida de naming/path) porque seu foco é
**o que escrever e com qual profundidade**, não onde salvar o artefato.

## Papel canonico

Esta skill e a **referencia unica** para a **qualidade de conteudo** de documentos Overview e Architecture. Define a estrutura, profundidade, padroes repetitivos, formatos de tabela, diagramas e criterios de aceite que garantem documentacao ao nivel dos gold standards do projeto.

**Nao duplicar** com:
- `documentation-architecture` (file placement e naming em `Documentation/Arquitetura/`)
- `documentation-project-bootstrap` (scaffolding inicial)
- `documentation-class-analysis-generator` (docs por classe/interface)
- `documentation-portal-html` (portal HTML e delegacao)

## Consolidacao e fronteiras (pack versionado)

| Artefacto | Finalidade | Nao e responsabilidade |
| --- | --- | --- |
| `documentation-architecture` | Naming e path `Documentation/Arquitetura/Arquitetura_<modulo>_Vx.y.md` | Definir profundidade de conteudo |
| **Esta skill** | Modelo de qualidade: secoes, profundidade, padrao repetitivo, tabelas, diagramas, criterios | File placement, naming, scaffolding |
| `documentation-portal-html` | Portal HTML `Documentation/html/`, delegacao entre skills | Conteudo tecnico dos docs |
| `documentation-class-analysis-generator` | Corpo completo por tipo em `{ClassName}.md` (7 secoes) | Docs de nivel projeto/modulo |
| `documentation-general_rules` | Ordem de invocacao, changelog, transporte entre repos | Prescrever estrutura de docs |

## When NOT to use

- Para documentar classes individuais → usar `documentation-class-analysis-generator`
- Para scaffold de pastas ou estrutura inicial → usar `documentation-project-bootstrap`
- Para gerar portal HTML estático → usar `documentation-portal-html`
- Para naming/path de arquivos de arquitetura → usar `documentation-architecture`
- Para inventariar gaps de documentação → usar `documentation-project-scan`

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `documentation-project-scan` | Recomendado para identificar módulos existentes antes de gerar Overview |

## When to use

- Quando o usuario pedir para "gerar overview do projeto", "documentar a arquitetura", "criar visao geral".
- Quando o `doc-agent-orchestrator` delegar tarefa de criacao/revisao de Overview ou Architecture.
- Quando o usuario pedir para "revisar qualidade" de um documento Overview ou Architecture existente.
- Quando for necessario documentar um NOVO modulo seguindo o padrao dos modulos existentes.

## Diretriz de templates master

- Skills com prefixo `documentation` sao templates master.
- Alteracoes so podem ocorrer por solicitacao direta e explicita do usuario.

## Inputs

1. `<project_name>`: nome do projeto (ex.: `ProvidersORM`).
2. `<version>`: versao do documento (ex.: `v2.0`).
3. `<source_root>`: raiz do codigo-fonte (padrao: `src/`).
4. `<modules>`: lista de modulos a documentar (auto-detectada se omitido).
5. `<existing_docs>`: path de docs existentes para revisao (opcional).
6. `<doc_type>`: `overview` | `architecture` | `both` (padrao: `both`).

## Outputs obrigatorios

1. `Documentation/{ProjectName}_Overview.md` — visao geral completa do projeto.
2. `Documentation/{ProjectName}_Overview_Arquitetura.md` — arquitetura profunda por componente.

## Modelo de referencia (Gold Standard)

**Exemplos locais (OBRIGATORIO ler antes de gerar):**

A pasta `Exemplos/` dentro desta skill contem copias dos artefatos gold standard que servem como modelo de qualidade. **Antes de iniciar a geracao de qualquer documento Overview ou Architecture, o agente DEVE ler estes ficheiros para internalizar o padrao de profundidade, estrutura e formatacao esperados.**

| Ficheiro | Tipo | Descricao |
| --- | --- | --- |
| `Exemplos/ProvidersORM_Overview.md` | Overview | Visao geral completa do ProvidersORM (~2070 linhas) — padrao de 5 secoes por modulo, tabelas comparativas, exemplos fluentes |
| `Exemplos/ProvidersORM_Overview_Arquitetura.md` | Architecture | Arquitetura profunda (~1702 linhas) — sub-padrao de 8 secoes por componente, diagramas ASCII, implementacoes por engine |

**Como usar:**
1. Ler `Exemplos/ProvidersORM_Overview.md` para entender o padrao Overview (secoes projeto-level + 5 secoes repetitivas por modulo).
2. Ler `Exemplos/ProvidersORM_Overview_Arquitetura.md` para entender o padrao Architecture (secoes numeradas, sub-padrao por componente, engines, bancos).
3. Usar como referencia de profundidade, formato de tabelas, estilo de codigo e diagramas ASCII ao gerar novos documentos.
4. O output gerado deve ter qualidade e profundidade **equivalente** a estes exemplos.

**Documentos-modelo canonicos (paths originais no projeto):**
- Overview: `Documentation/ProvidersORM_Overview.md` (~2070 linhas)
- Architecture: `Documentation/ProvidersORM_Overview_Arquitetura.md` (~1702 linhas)

### 6.1 Padrao Overview — Estrutura Prescrita

O documento Overview segue uma estrutura em duas partes: secoes de nivel projeto + padrao repetitivo por modulo.

#### Parte 1 — Secoes de nivel projeto

| Ordem | Secao | Conteudo minimo | Formato |
| --- | --- | --- | --- |
| 1 | `# {Projeto} {versao}` | H1 + tagline blockquote | `> Biblioteca ORM para...` |
| 2 | `## O que e` | 2-4 paragrafos: identidade, compatibilidade, modo de operacao | Prosa |
| 3 | `## Caracteristicas` | Min 12 bullets com keyword bold | `- **Feature** -- descricao.` |
| 4 | `## Engines` | Sub-secoes: engines de banco (tabela diretiva x engines), comparativo completo (tabela 13+ criterios x engines), bancos/alvos suportados, comparativo geral (12 caract. x alvos), engines de servicos auxiliares | Tabelas |
| 5 | `## Funcionalidades` | Hierarquia de objetos (`Field -> ... -> Schemas`), tabela componente/diretiva/responsabilidade, sub-secoes por funcionalidade com codigo fluente | Tabelas + codigo |
| 6 | `## Dialetos e mapeamento de tipos` | Tabelas: paginacao, retorno de ID, quoting, mapeamento tipos, concatenacao — UMA linha por alvo | Tabelas |
| 7 | `## Modulos e API publica` | Tabela modulo/API publica/internas | Tabela |
| 8 | `## Formularios de teste / Pontos de entrada` | Tabela form/proposito | Tabela |

#### Parte 2 — Padrao repetitivo por modulo (5 secoes)

CADA modulo do projeto deve ter EXATAMENTE estas 5 secoes, nesta ordem:

```text
## Modulo {NomeModulo}
> Tagline descritiva em uma linha.

### {NomeModulo}: O que e
[2-4 paragrafos: proposito, fonte publica, ativacao por diretiva, representacao de dados]
[Diagrama de hierarquia se aplicavel]

### {NomeModulo}: Diretivas de compilacao
| Diretiva | Efeito quando ativa |
| --- | --- |
| `USE_XXX` | Descricao |
> Nota de prioridade/conflito

### {NomeModulo}: Caracteristicas
- **Feature 1** -- descricao.
[Min 8 bullets]

### {NomeModulo}: Engines
#### Sub-categoria
| Diretiva/Constante | Engine/Destino | Disponibilidade |
[Todas as opcoes, sem omissoes]

### {NomeModulo}: Funcionalidades
#### Sub-grupo funcional
| Metodo | Retorno | Descricao |
[Tabelas de metodos]
#### Configuracao fluente
[Codigo com API fluente vertical]
#### Atributos RTTI (se aplicavel)
[Aliases PT/EN em tabela]
#### Excepcoes do modulo
| Faixa | Classe | Categoria |
```

**Modulos documentados no gold standard Overview (7):**
1. Parameters — 3 fontes, CRUD, fluent, FromConfig, atributos RTTI, aliases PT, tipos de valor, excepcoes
2. Loggers — 10 destinos, 5 niveis, 4 formatos, 3 modos de escrita, rotacao, agregacao email, retry HTTP, fallback, WebSocket engines, eventos, atributos RTTI
3. Connections — fluent, multi-engine, FromConfig, DLL validation, eventos de ciclo de vida, metadados (GetTableStructure com FK rules), Ping
4. Database — hierarquia IField->ISchemas, DML/DDL otimizado, FK rules, audit fields, change tracking, QueryBuilder, EntityManager, IdentityMap, UnitOfWork, TypeDatabase
5. Exceptions — hierarquia de classes (arvore texto), faixas de codigo, banco de mensagens SQLite, factory functions, ConvertToException, helpers
6. PoolConnections — FIFO, deduplicacao, 9 eventos, TPool com metadados, acesso UI, helpers de formatacao
7. Providers.v161 — camada de compatibilidade, tabela de migracao v1.6.1 -> v2.0

#### Secao final do Overview

```text
## Resumo de diretivas de compilacao por modulo
| Modulo | Diretiva de ativacao | Diretivas adicionais |
[UMA linha por modulo]

## Changelog (este arquivo)
- X.Y.Z (DD/MM/AAAA): Descricao detalhada referenciando o modulo.
```

### 6.2 Padrao Architecture — Estrutura Prescrita

O documento Architecture segue uma estrutura de componentes numerados com profundidade tecnica.

#### Estrutura geral

```text
# Arquitetura ORM e Data Access para {Linguagem}
## Visao Geral
[1-2 paragrafos descrevendo a arquitetura geral e padroes usados]

## 1. ComponenteA
[sub-padrao por componente — ver abaixo]

## 2. ComponenteB
[sub-padrao por componente]

...

## N. Comparativo Geral
[Tabela cruzada]

## N+1. Factory Pattern
[Unificacao da criacao]

## N+2. Resumo da Arquitetura
[Diagrama ASCII de camadas]

## N+3. Consideracoes Finais
[Paragrafo-resumo: qualidades alcancadas]
```

**Componentes documentados no gold standard Architecture (12):**
1. TypeDatabase — enumeracao central, responsabilidades, BuildPagination
2. EntityManager — ciclo de vida, Persist/Find/Flush, diagrama de interacao
3. QueryBuilder — clauses, SQL por dialeto, joins, subqueries, DML
4. IdentityMap — cache primeiro nivel, fluxo de consulta, BuildKey
5. UnitOfWork — DetectChanges, dirty checking, ordenacao FK, fluxo Flush
6. Attributes — Table/Column/PK/FK/HasMany/BelongsTo, RTTI, exemplo completo
7. Engines de Conexao (4 sub-secoes: FireDAC, UniDAC, Zeos, SQLDB)
8. Bancos de Dados (6 sub-secoes: PostgreSQL, MySQL, SQL Server, Firebird, SQLite, MSAccess)
9. Comparativo Geral dos Bancos
10. Factory Pattern
11. Resumo da Arquitetura (diagrama ASCII 5 camadas)
12. Consideracoes Finais

#### Sub-padrao por componente (OBRIGATORIO para cada componente)

```text
## N. NomeComponente

### O que e
[2-4 paragrafos conceituais: proposito, papel na arquitetura, padrao de design (citar Fowler se aplicavel)]

### Analogia (para conceitos complexos)
[Metafora do mundo real — ex: "gerente de armazem" para EntityManager]

### Por que e necessario
[Problema que resolve. OBRIGATORIO: codigo mostrando o cenario SEM o componente]

### Definicao tipica / Interface
[Declaracao de tipo/interface com assinaturas completas]

### Responsabilidades detalhadas
| Responsabilidade | Descricao |
| --- | --- |

### Sub-secoes numeradas (N.1, N.2, ...)
[Detalhamento de cada aspecto relevante com codigo]

### Fluxo / Diagrama (ASCII art, NAO Mermaid)
[Caixas com caracteres Unicode: ┌──┐ └──┘ │ ▼ ──>, fluxos verticais]

### Beneficios
- **Consistencia**: descricao.
- **Performance**: descricao.

### Consideracoes
- Caveats sobre memoria, escopo, ciclo de vida, etc.
```

#### Sub-padrao por engine (se o projeto usar multiplas engines)

```text
### N.X NomeEngine

#### Visao geral
[1-2 paragrafos: origem, plataforma, licenca]

#### Caracteristicas
[5-8 bullets com features-chave]

#### Componentes-chave
| Componente | Funcao |
[Min 6 linhas]

#### Implementacao da abstracao
[Codigo do constructor com case para TODOS os bancos/opcoes]

#### Strengths e limitacoes
| Aspecto | Detalhe |
[Min 6 linhas: plataforma, licenca, performance, modo direto, cross-compile, custo/features]
```

#### Sub-padrao por banco de dados (se multi-banco)

```text
### N.X NomeBanco

#### Visao geral
[1-2 paragrafos: posicionamento, popularidade]

#### Caracteristicas relevantes
| Caracteristica | Detalhe |
[Min 8 linhas: ID generation, RETURNING, schemas, paginacao, boolean, JSON, transacoes, concorrencia]

#### Dialeto SQL — particularidades
[6-8 exemplos SQL reais: paginacao, INSERT com ID, upsert, boolean, quoting, concatenacao]

#### Tipos de dados para mapeamento
| Tipo Delphi/FPC | Tipo NomeBanco |
[11 tipos obrigatorios: Integer, Int64, string, Boolean, TDateTime, TDate, TTime, Currency, Double, TBytes/TStream, TGUID]
```

### 6.3 Regras de Qualidade (enforcement)

| # | Regra | Verificacao |
| --- | --- | --- |
| Q1 | Tabelas como formato primario para listas comparativas | Nenhuma lista de > 3 itens fora de tabela |
| Q2 | Codigo realista com dados concretos | Sem `'foo'`, `'bar'`, `'xxx'` nos exemplos |
| Q3 | API Fluente com formatacao vertical | Cada `.Metodo()` em linha propria |
| Q4 | Diagramas ASCII (NAO Mermaid) | Caixas `┌──┐`, setas `│ ▼`, fluxos verticais |
| Q5 | Cobertura exaustiva | Todos os bancos/engines/tipos em CADA tabela |
| Q6 | Excepcoes por modulo | Faixa de codigos + hierarquia de classes |
| Q7 | Changelog com granularidade | Data + descricao referenciando modulo fonte |
| Q8 | Tagline blockquote por modulo | `> Descricao em uma linha.` |
| Q9 | Separadores `---` entre secoes `##` | Consistencia visual |
| Q10 | Sem duplicacao Overview/Architecture | Overview = "o que e como usar"; Architecture = "por que e como funciona" |
| Q11 | Sem stubs/placeholders | Todo conteudo deve ser real e preenchido |
| Q12 | Min linhas: Overview >= 400, Architecture >= 600 | Profundidade minima |

## Passos executaveis

### Fase 0 — Prerequisitos

1. Verificar que `Documentation/` existe (se nao, criar ou renomear `Docs/`/`docs/`).
2. Identificar modulos do source: varrer `<source_root>` por subpastas em `Modulos/` ou equivalente.
3. Coletar informacoes de diretivas de compilacao (buscar `{$IFDEF USE_*}` ou equivalente).
4. Identificar engines disponiveis (buscar classes de conexao, providers, drivers).
5. Determinar `<doc_type>` (overview, architecture ou both).
6. Copiar templates de `.cursor/Templates/`: `TEMPLATE_Docs_Overview.md` e/ou `TEMPLATE_Docs_Arquitetura.md`.

### Fase 1 — Overview (se doc_type = overview ou both)

1. Preencher H1 + tagline: `# {Projeto} {versao}` + `> Descricao`.
2. Escrever `## O que e`: 2-4 paragrafos (identidade, compatibilidade, modo).
3. Escrever `## Caracteristicas`: min 12 bullets bold-keyword.
4. Escrever `## Engines`: tabelas comparativas (engines de banco, comparativo completo, bancos suportados, comparativo geral, engines auxiliares).
5. Escrever `## Funcionalidades`: hierarquia + tabela componente/diretiva + sub-secoes com codigo.
6. Escrever `## Dialetos e mapeamento`: 5 tabelas (paginacao, RETURNING, quoting, tipos, concatenacao).
7. Escrever `## Modulos e API publica`: tabela modulo/API.
8. Escrever `## Formularios de teste`: tabela form/proposito.
9. Para CADA modulo, escrever as 5 secoes: O que e, Diretivas, Caracteristicas, Engines, Funcionalidades.
10. Escrever `## Resumo de diretivas por modulo`: tabela cruzada.
11. Escrever `## Changelog`: entrada inicial com data e descricao.

### Fase 2 — Architecture (se doc_type = architecture ou both)

1. Preencher H1 + Visao Geral: padroes usados (Identity Map, Unit of Work, etc.).
2. Para CADA componente-chave, escrever as sub-secoes: O que e, Analogia (se complexo), Por que e necessario (com codigo do problema), Definicao tipica/Interface, Responsabilidades (tabela), Sub-secoes detalhadas, Fluxo/Diagrama (ASCII), Beneficios, Consideracoes.
3. Para CADA engine, escrever: Visao geral, Caracteristicas, Componentes-chave (tabela), Implementacao (codigo constructor com case), Strengths/limitacoes (tabela).
4. Para CADA banco, escrever: Visao geral, Caracteristicas (tabela), Dialeto SQL (6-8 exemplos), Tipos de dados (tabela 11 tipos).
5. Escrever comparativos gerais: engines (tabela cruzada), bancos (tabela cruzada).
6. Escrever Factory Pattern, Resumo da Arquitetura (diagrama ASCII de camadas), Consideracoes Finais.

### Fase 3 — Validacao

1. Verificar padrao de 5 secoes por modulo no Overview (sem secoes faltando).
2. Verificar sub-padrao por componente na Architecture (sem secoes faltando).
3. Verificar que TODAS as tabelas tem conteudo (nenhuma celula vazia).
4. Verificar que todos os exemplos de codigo sao sintaticamente validos.
5. Verificar cobertura: todos os modulos/engines/bancos presentes em cada tabela.
6. Verificar contagem de linhas: Overview >= 400, Architecture >= 600.
7. Verificar que diagramas usam ASCII art (nao Mermaid).
8. Verificar que nao ha stubs ou placeholders `{xxx}` restantes.
9. Delegar atualizacao do hub `Documentation/README_Vx.y.md` ao orchestrator.

## Criterios de aceite

- [ ] Todos os modulos cobertos no Overview com padrao de 5 secoes.
- [ ] Todos os componentes cobertos na Architecture com sub-padrao completo.
- [ ] Secoes numeradas `## N.` na Architecture.
- [ ] Min 1 diagrama ASCII por componente na Architecture.
- [ ] Todos os exemplos de codigo compilaveis/executaveis.
- [ ] Tabelas como formato primario (sem listas de > 3 itens fora de tabela).
- [ ] Sem stubs, placeholders ou `TODO`.
- [ ] Changelog preenchido com data e descricao.
- [ ] Overview >= 400 linhas, Architecture >= 600 linhas.
- [ ] Cross-references consistentes entre Overview e Architecture.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Gerar Overview com menos de 5 seções por módulo | Quebra o padrão repetitivo; docs ficam inconsistentes | Usar exatamente as 5 seções: O que é, Diretivas, Características, Engines, Funcionalidades |
| Usar Mermaid em vez de ASCII art na Architecture | Não renderiza em todos os ambientes; padrão do projeto é ASCII | Usar caixas `┌──┐ └──┘ │ ▼` e setas `-->` em texto puro |
| Deixar stubs ou `{placeholder}` no output | Documento incompleto; quebra critério de aceite Q11 | Preencher todo conteúdo com dados reais do projeto |
| Omitir engines ou bancos de tabelas comparativas | Cobertura incompleta; leitores assumem ausência como não-suporte | Incluir TODOS os engines/bancos em CADA tabela, marcando "N/A" se não aplicável |
| Combinar Overview e Architecture em um único documento | Viola separação "o que/como usar" vs "por que/como funciona" | Gerar dois documentos separados conforme outputs obrigatórios |

## Métricas de sucesso

- Overview gerado contém exatamente 5 seções para cada módulo documentado (sem seções faltando ou extras)
- Architecture gerada contém diagrama ASCII por componente e sub-padrão completo (8 sub-seções)
- `validate_pack.py` passa sem erros após geração; contagem de linhas: Overview >= 400, Architecture >= 600
- Nenhum placeholder `{xxx}` ou stub `TODO` no output final

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `doc-agent-orchestrator` / `doc-agent-architecture` |
| Revisão humana | Tech Lead / Autor do documento |
| Aprovação final | Desenvolvedor responsável pelo módulo |

## Rules to consult

- skill `documentation-general_rules` (naming conventions)
- skill `documentation-general_rules` (language policy)
- skill `documentation-readme-hub` (hub resync rules)
- skill `documentation-constitution-policies` (rules-integration)

## Relacao com outras skills

| Skill | Relacao |
| --- | --- |
| `documentation-architecture` | Complementar — `architecture` define path/naming; **esta skill** define qualidade de conteudo |
| `documentation-portal-html` | Complementar — portal HTML delega para esta skill quando o pedido for Overview/Architecture |
| `documentation-class-analysis-generator` | Independente — opera em nivel de classe (7 secoes); esta skill opera em nivel de projeto/modulo |
| `documentation-project-scan` | Pre-requisito opcional — fornece inventario de modulos e gaps |
| `documentation-general_rules` | Transversal — define ordem de invocacao e changelog generico |

## Agentes associados

| Agente | Arquivo | Quando usar |
| --- | --- | --- |
| `doc-agent-orchestrator` | `.cursor/agents/doc-agent-orchestrator_V1.1.4.md` | Delega para esta skill em tarefas Overview/Architecture |
| `doc-agent-architecture` | `.cursor/agents/doc-agent-architecture_V1.0.3.md` | Usa esta skill para qualidade de conteudo em `Documentation/Arquitetura/` |

## Templates de saida

**Ficheiros-modelo fisicos (copiar antes de preencher):**

- Overview: `templates/TEMPLATE_Docs_Overview.md`
- Architecture: `../documentation-architecture_V1.1.0/templates/TEMPLATE_Docs_Arquitetura.md` (versao enriquecida)

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: extended e category: documentation.
- 1.0.0 (04/04/2026): Criacao da skill com modelo de qualidade extraido de ProvidersORM_Overview.md e ProvidersORM_Overview_Arquitetura.md.
