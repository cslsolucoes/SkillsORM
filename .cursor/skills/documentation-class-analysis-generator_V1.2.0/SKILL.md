---
name: documentation-class-analysis-generator
description: Gera documentação completa por classe/interface com conteudo detalhado (O que e, Caracteristicas, Engine, Funcionalidades, Aplicabilidades, Exemplos de Uso, Relacionamentos) a partir do codigo-fonte. Generico para qualquer projeto. Orquestra agentes doc-agent-class-scanner, doc-agent-class-writer e doc-agent-class-indexer.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Class Analysis Generator

## Responsabilidade única

Esta skill é a responsável exclusiva pela geração de conteúdo detalhado (7 secções obrigatórias) de cada `{ClassName}.md` em `Analise/` ou `Documentation/Analise/`, extraindo informação diretamente do código-fonte. Resolve o problema de ficheiros placeholder sem conteúdo real após o scaffolding. Existe separada de `documentation-paste_analysis_unit_class_method` porque a geração de conteúdo requer parse profundo de código (assinaturas, campos, herança, exemplos) enquanto o scaffolding apenas cria a estrutura de ficheiros vazia. Orquestra três agentes especializados (`doc-agent-class-scanner`, `doc-agent-class-writer`, `doc-agent-class-indexer`) que operam em paralelo por módulo para cobrir projetos grandes de forma eficiente.

## Papel canonico

Esta skill e a **referencia unica** para a geracao de **conteudo completo** de documentacao por classe/interface. Complementa `documentation-paste_analysis_unit_class_method` (que faz scaffolding de estrutura) preenchendo cada `{ClassName}.md` com documentacao detalhada extraida diretamente do codigo-fonte.

**Nao duplicar** com `documentation-paste_analysis_unit_class_method` (scaffolding) nem `documentation-project-feature` (matriz de lacunas).

## Consolidacao e fronteiras (pack versionado)

| Artefacto | Finalidade | Nao e responsabilidade |
| --- | --- | --- |
| `documentation-paste_analysis_unit_class_method` (`documentation-paste_analysis_unit_class_method_V1.1.0/`) | Estrutura fisica `Analise/` ou `Documentation/Analise/`, placeholders, modos scaffold/sync/full | Preencher as 7 seccoes a partir do codigo |
| **Esta skill** | Corpo completo por tipo em `{ClassName}.md`, `README.md` indice, `FLOWCHART.md` | Redefinir convencao de nomes de ficheiros nem arvore de dominios |
| `documentation-project-feature` | Matriz de lacunas, RN, checklist **sobre** docs ja existentes | Gerar texto detalhado por classe |
| `documentation-project-scan` | Inventario documental, gaps, classificacao em `Documentation/` / `Analise/` | Parser de codigo nem escrita das 7 seccoes |
| `documentation-portal-html` | Encadear skills `documentation-*` em fluxos multi-etapa | Extrair assinaturas de fonte |
| `doc-agent-orchestrator` | Delegar `doc-agent-*` para hub, migracao, politicas | Nao substitui as fases `doc-agent-class-*`; pode **encadear** este fluxo quando o pedido for preenchimento massivo por classe |

**Ordem logica tipica:** `documentation-paste_analysis_unit_class_method` (se faltar estrutura) → **esta skill** (scan + escrita + indice) → `documentation-project-scan` / `documentation-project-feature` (validar cobertura e qualidade documental).

## Politica obrigatoria (`Analise/` e nome de ficheiro)

- A convencao **`{ClassName}.md`** (nome **sem** prefixo **`T`/`I`**) em subpastas por **dominio** — **nao** uma pasta por identificador `T…`/`I…` — e **obrigatoria** para o projeto anfitriao; norma completa: **`documentation-paste_analysis_unit_class_method`**.
- Pedidos como “pasta `TClasse` com `README.md`” sao **desalinhados**: o padrao e `Dominio/ClassName.md` (ex.: `Connections/Connection.md` para `TConnection`/`IConnection` no corpo). Seguir o pedido alternativo apenas como **excecao** manual explicita; **nao** substituir a politica do pack.
- As **7 seccoes**, o **`README.md`** indice e o **`FLOWCHART.md`** devem respeitar sempre esta convencao (incluindo exclusao de `Views`/forms quando definida nos inputs).

## When NOT to use

- Quando a pasta `Analise/` ainda não existe ou está incompleta — usar `documentation-paste_analysis_unit_class_method` primeiro para criar a estrutura.
- Quando o objetivo for documentar regras de negócio (invariantes, contratos de comportamento) — usar `documentation-business-rules`.
- Quando o objetivo for gerar um hub `README.md` geral de documentação — usar `documentation-readme-hub`.
- Quando o objetivo for documentar fluxos de telas/UI — usar `documentation-screen-sketches`.
- Quando o objetivo for auditar lacunas documentais sem gerar conteúdo — usar `documentation-project-scan`.

## When to use

- Quando o usuario pedir para "gerar documentacao completa por classe", "documentar todas as classes", "criar analise detalhada" ou "preencher docs de classe com exemplos".
- Quando existir `Analise/` ou `Documentation/Analise/` com stubs/placeholders e for necessario preencher com conteudo real.
- Quando o usuario pedir "overview de cada classe com exemplos de uso".
- Apos `documentation-paste_analysis_unit_class_method` ter criado a estrutura.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-paste_analysis_unit_class_method` | Sempre — a estrutura `Analise/` com subpastas e placeholders deve existir antes de gerar conteúdo. |
| `documentation-general_rules` | Sempre — verificar convenções de nomenclatura, idioma e estilo antes de escrever. |

## Diretriz de templates master

- Skills com prefixo `documentation` e `project` / `projeto` sao templates master.
- Alteracoes so podem ocorrer por solicitacao direta e explicita do usuario.

## Inputs

1. `<project_root>`: raiz do projeto (padrao: `.`).
2. `<fonte_codigo>` (opcional): padrao `src/` (aceitar `lib/`, `packages/`, etc.).
3. `<pasta_destino>` (opcional): padrao `Documentation/Analise/` ou `Analise/` conforme convencao do projeto.
4. `<idioma_saida>` (opcional): `pt-BR` (default) ou `en`.
5. `<excluir_pastas>` (opcional): pastas a ignorar (padrao: `Views/`, `Tests/`, `__tests__/`).
6. `<linguagem>` (opcional): auto-detectada a partir de extensoes (`.pas` = Pascal, `.cs` = C#, `.py` = Python, `.ts` = TypeScript, `.go` = Go, `.java` = Java, `.rs` = Rust).

## Outputs obrigatorios

1. Cada `{ClassName}.md` preenchido com as **7 secoes obrigatorias** (ver Template abaixo).
2. `README.md` raiz com indice completo e links para cada doc.
3. `FLOWCHART.md` com diagramas Mermaid da arquitetura.
4. Relatorio final: total de docs gerados, atualizados, ignorados.

## Template de cada ClassName.md

**Ficheiro-modelo fisico (copiar para `Analise/` ou `Documentation/Analise/`):** [templates/TEMPLATE_ClassName_Full_Documentation.md](templates/TEMPLATE_ClassName_Full_Documentation.md) — mesma estrutura que o bloco abaixo, com variantes ORM (fluxo interno, campos privados, GUID).

```markdown
# {TypeName}

> Descricao de uma linha.

**Unit:** `{NomeDaUnit}`
**Tipo:** Interface | Classe | Record | Enum | Exception
**Modulo:** {NomeDoModulo}
**Diretiva:** `{USE_XXX}` (ou "Sempre compilado")

---

## O que e?

[2-4 frases sobre o proposito e papel arquitetural]

---

## Caracteristicas

- **Bullet 1** -- descricao
- **Bullet 2** -- descricao

---

## Engine

(Somente se aplicavel — tabela de engines/diretivas)

| Diretiva | Engine | Suporte |
| --- | --- | --- |

---

## Funcionalidades

### [Grupo de metodos]

| Metodo | Assinatura | Descricao |
| --- | --- | --- |
| `NomeMetodo` | `function NomeMetodo(param: tipo): retorno` | O que faz |

---

## Aplicabilidades

- **Cenario 1:** descricao de uso real
- **Cenario 2:** descricao de uso real

---

## Exemplos de Uso

### [Grupo funcional]

```{linguagem}
// Exemplo de uso real
```

---

## Relacionamentos

- **Implementa:** `INomeInterface`
- **Usa:** `TOutraClasse`, `IOutraInterface`
- **Usado por:** `TConsumidor`
```

### Variacoes por tipo

| Tipo | Secao "Funcionalidades" | Secao extra |
| --- | --- | --- |
| Interface | Tabela de metodos com assinaturas | — |
| Classe | Tabela de metodos + campos internos (F*) | `## Campos Internos` |
| Enum | Tabela de "Valores" (constante + descricao) | — |
| Record | Tabela de "Campos" (campo + tipo + descricao) | — |
| Exception | Tabela de metodos + tabela de "Codigos de Erro" | `## Codigos de Erro` |

## Passos executaveis (orquestracao)

### Fase 0 — Preparacao

1. Detectar linguagem do projeto pelas extensoes dos arquivos fonte.
2. Detectar `<pasta_destino>` (prioridade: `Documentation/Analise/` > `Analise/`).
3. Se `<pasta_destino>` nao existir, invocar `documentation-paste_analysis_unit_class_method` em modo `scaffold` primeiro.

### Fase 1 — Scan (agente `doc-agent-class-scanner`)

1. Varrer `<fonte_codigo>` recursivamente (excluindo `<excluir_pastas>`).
2. Para cada arquivo-fonte, extrair:
   - Interfaces (pattern: `IXxx = interface`)
   - Classes (pattern: `TXxx = class`)
   - Records (pattern: `TXxx = record`)
   - Enums (pattern: `TXxx = (`)
   - Exceptions (classes que herdam de `Exception` ou base equivalente)
3. Para cada tipo encontrado, extrair:
   - Metodos com assinaturas completas
   - Campos internos (F* para classes)
   - Valores (para enums)
   - Campos (para records)
   - Heranca e interfaces implementadas
4. Agrupar por modulo/dominio (derivar do path relativo em `src/`).
5. Gerar inventario JSON intermediario para os escritores.

### Fase 2 — Escrita (agente `doc-agent-class-writer`)

1. Para cada tipo no inventario:
   - Verificar se `{ClassName}.md` ja existe com conteudo real (nao placeholder).
   - Se placeholder ou ausente: gerar conteudo completo seguindo o Template.
   - Se ja preenchido: ignorar (modo `sync`) ou sobrescrever (modo `full`).
2. Preencher as 7 secoes obrigatorias usando dados do scan.
3. Gerar exemplos de uso realistas baseados na API publica.
4. Identificar relacionamentos (uses, implementa, usado por) via analise de imports.

### Fase 3 — Indexacao (agente `doc-agent-class-indexer`)

1. Gerar/atualizar `README.md` raiz com:
   - Arvore de estrutura (em bloco `text`)
   - Tabelas por modulo com links para cada doc
   - Convencoes do projeto
2. Gerar/atualizar `FLOWCHART.md` com diagramas Mermaid:
   - Arquitetura geral (modulos e dependencias)
   - Hierarquia de tipos principais
   - Grafo de dependencias entre modulos
3. Validar todos os links no README (apontar para arquivos existentes).

### Fase 4 — Relatorio

1. Emitir resumo: docs criados, atualizados, ignorados, erros.
2. Listar tipos sem dominio mapeado (requer revisao manual).
3. Verificar cobertura: % de tipos com doc completo vs total encontrado.

## Estrategia de paralelizacao

- **Fase 1** (scan): usar agentes Explore em paralelo por modulo/subpasta.
- **Fase 2** (escrita): lancar multiplos `doc-agent-class-writer` em paralelo por modulo (batch de 4-8 docs por agente).
- **Fase 3** (indexacao): executar apos Fase 2 completar.

## Agentes associados

| Agente | Arquivo | Responsabilidade |
| --- | --- | --- |
| `doc-agent-class-scanner` | `.cursor/agents/doc-agent-class-scanner_V1.0.1.md` | Varredura de codigo-fonte, extracao de tipos e metodos |
| `doc-agent-class-writer` | `.cursor/agents/doc-agent-class-writer_V1.0.1.md` | Geracao de conteudo completo por classe/interface |
| `doc-agent-class-indexer` | `.cursor/agents/doc-agent-class-indexer_V1.0.1.md` | Geracao de README.md indice e FLOWCHART.md |

## Adaptacao por linguagem

| Linguagem | Extensoes | Patterns de tipo | Factory | Fluent |
| --- | --- | --- | --- | --- |
| Pascal/Delphi | `.pas` | `TXxx = class`, `IXxx = interface`, `TXxx = record`, `TXxx = (` | `class function New` | `function X(...): ISelf` |
| C# | `.cs` | `class Xxx`, `interface IXxx`, `enum Xxx`, `record Xxx` | `new Xxx()` | builder pattern |
| Python | `.py` | `class Xxx`, `def __init__` | `Xxx()` | method chaining |
| TypeScript | `.ts` | `class Xxx`, `interface IXxx`, `enum Xxx`, `type Xxx` | `new Xxx()` | builder pattern |
| Go | `.go` | `type Xxx struct`, `type Xxx interface`, `func NewXxx` | `NewXxx()` | functional options |
| Java | `.java` | `class Xxx`, `interface IXxx`, `enum Xxx`, `record Xxx` | `Xxx.builder()` | builder pattern |
| Rust | `.rs` | `struct Xxx`, `trait Xxx`, `enum Xxx`, `impl Xxx` | `Xxx::new()` | builder pattern |

## Relacao com outras skills

| Skill | Relacao |
| --- | --- |
| `documentation-paste_analysis_unit_class_method` | Pre-requisito — cria estrutura e placeholders; esta skill **preenche** conteudo |
| `documentation-project-feature` | Complementar — `feature` produz matriz/RN/checklist **sobre** os docs gerados aqui |
| `documentation-project-scan` | Complementar — detecta lacunas; esta skill ou o utilizador as trata com novo ciclo |
| `documentation-portal-html` | Orquestra — pode delegar para esta skill quando o pedido e "gerar docs completos" por tipo |
| `documentation-general_rules` | Convencoes transversais (changelog, idioma, ordem entre skills) |

## Criterios de aceite

- Cada tipo encontrado no scan tem `{ClassName}.md` com as 7 secoes preenchidas.
- Tabelas de metodos contem assinaturas extraidas do codigo-fonte (nao inventadas).
- Exemplos de uso sao sintaticamente corretos para a linguagem do projeto.
- README.md raiz tem links validos para todos os docs gerados.
- FLOWCHART.md renderiza corretamente em Mermaid.
- Operacao e replicavel em qualquer projeto sem ajustes manuais alem de inputs.
- **V1.2.0+:** Threshold de agregação respeitado (ver seção abaixo).

## Threshold de agregação (regra dura, V1.2.0+)

A skill recusa criar README agregado para muitas unidades — força a granularidade adequada.

| Quantidade de unidades em mesma pasta/módulo | Política |
| --- | --- |
| **≥ 5 unidades** | Cada unidade EXIGE `{ClassName}.md` individual. Agregação em README de pasta NÃO é permitida |
| **2–4 unidades** | Agregação permitida apenas se houver justificativa em `Documentation/Decisions/AGGREGATION_RATIONALE.md` |
| **1 unidade** | Doc individual sempre obrigatório (não cabe agregar consigo mesmo) |

**Pré-condição:** antes de aceitar agregação para 2–4 unidades, a skill exige que `documentation-project-feature` em modo `coverage-plan` (fase 3 do workflow obrigatório do `documentation-master-orchestrator`) tenha registrado a justificativa em `AGGREGATION_RATIONALE.md` com:
- lista das unidades agregadas
- motivo (ex.: "scripts triviais de investigação ad-hoc, lógica < 30 linhas cada")
- quem aprovou a agregação
- data

**Sem o registro, a skill aborta com erro** e instrui o invocador a executar o gate de coverage-plan primeiro.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Invocar esta skill sem ter executado o scaffold antes | Não há `{ClassName}.md` destino; o writer gera ficheiros em locais incorretos ou falha | Executar `documentation-paste_analysis_unit_class_method` primeiro para criar a estrutura |
| Inventar assinaturas de métodos sem ler o código-fonte | Documentação falsa que diverge do código real e engana consumidores da API | O `doc-agent-class-scanner` deve sempre extrair assinaturas diretamente dos ficheiros `.pas`/`.cs`/etc. |
| Sobrescrever ficheiros já preenchidos em modo `sync` | Apaga documentação corrigida manualmente ou enriquecida com contexto não inferível do código | Respeitar o modo `sync`: ignorar ficheiros com conteúdo real, somente atualizar placeholders |
| Documentar classes de `Views/` ou formulários de teste | Polui a análise técnica com código de UI sem lógica de negócio relevante | Incluir `Views/` em `<excluir_pastas>` ao invocar a skill |
| Criar README agregado para ≥ 5 unidades sem registrar (V1.2.0+) | Mascara cobertura insuficiente; futuras manutenções não sabem o que está documentado de fato | Sempre criar 1 `{ClassName}.md` por unidade quando ≥ 5 — a agregação é proibida nesta faixa |
| Agregar 2–4 unidades sem justificativa em `AGGREGATION_RATIONALE.md` (V1.2.0+) | Decisão implícita de cobertura sem trilha de auditoria | Executar `documentation-project-feature` em modo `coverage-plan` primeiro para registrar a justificativa |

## Métricas de sucesso

- Cada tipo encontrado no scan (`T…`, `I…`, records, enums, exceptions) tem `{ClassName}.md` com as 7 secções preenchidas (cobertura = 100% dos tipos encontrados).
- `README.md` raiz de `Analise/` actualizado com links válidos para todos os docs gerados (zero links quebrados verificados na Fase 3).
- `FLOWCHART.md` gerado com diagrama Mermaid que renderiza sem erros e cobre todos os módulos do projecto.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-class-writer` |
| Revisão humana | Desenvolvedor responsável pelo módulo documentado |
| Aprovação final | Tech lead / dono do repositório |

---

**Changelog (conteudo funcional):**

- 1.0.4 (01/04/2026): Remissao ao ficheiro-modelo fisico **`TEMPLATE_ClassName_Full_Documentation.md`** (`.cursor/Templates/`).
- 1.0.3 (01/04/2026): Agentes renomeados para **`doc-agent-class-scanner`**, **`doc-agent-class-writer`**, **`doc-agent-class-indexer`** (ficheiros `doc-agent-class-*_V1.0.1.md`); tabela e fases actualizadas.
- 1.0.2 (01/04/2026): Secao **Politica obrigatoria (`Analise/` e nome de ficheiro)** — alinhamento obrigatorio com paste skill; pedidos `T…`/`I…`+README como excecao apenas.
- 1.0.1 (01/04/2026): Integracao no pack Providers.2.1.0 — secao **Consolidacao e fronteiras**, tabela de agentes com sufixo `_V1.0.1.md`, ordem logica com paste/scan/feature, alinhamento `doc-agent-orchestrator`.

---

## Versao interna (ficheiro)

| Campo | Valor |
| --- | --- |
| **FileVersion** | 1.2.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.2.0 (26/04/2026): Nova seção **Threshold de agregação (regra dura)** — ≥5 unidades exige doc individual obrigatória; 2–4 unidades exigem registro em `Documentation/Decisions/AGGREGATION_RATIONALE.md` (gate via `documentation-project-feature` em modo `coverage-plan`); skill aborta sem o registro. Novo critério de aceite + 2 anti-padrões. Integra com workflow obrigatório de 5 fases do `documentation-master-orchestrator` V1.2.0.
- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.0.2 (01/04/2026): Referencias aos agentes `doc-agent-class-*_V1.0.1.md`.
- 1.0.1 (01/04/2026): Criacao da skill no pack versionado; espelho semantico ProvidersORM com fronteiras explicitas e agentes `_V1.0.1.md`.
