---
name: documentation-paste_analysis_unit_class_method
description: Skill dona da pasta `Analise/` em qualquer projeto — scaffolding canónico derivado de `src/` (subpastas por domínio, `{ClassName}.md` sem prefixo T/I no nome do ficheiro), idempotente. Opcionalmente alinhada a entrypoint de build (.dpr, solution, etc.).
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Paste Analysis — Unit / Class / Method

## Responsabilidade única

Esta skill é a dona exclusiva do scaffolding da pasta `Analise/` em qualquer projeto — nenhuma outra skill deve criar, renomear ou reorganizar a árvore de subpastas por domínio e ficheiros `{ClassName}.md`. Resolve o problema de ausência ou inconsistência da estrutura física de análise por classe antes que qualquer outra skill de preenchimento de conteúdo possa actuar. Existe separada de `documentation-class-analysis-generator` porque scaffolding (estrutura + placeholders) e geração de conteúdo detalhado são responsabilidades distintas com agentes diferentes. Sem esta skill executada primeiro, qualquer tentativa de preencher ou indexar documentação de classe falha por falta de destino canónico.

## Papel canónico (fonte única para `Analise/`)

Esta skill é a **referência única** para:

- **Finalidade da pasta `Analise/`** (ou nome equivalente documentado no `README` do projeto): documentação **por classe ou interface**, derivada do código.
- **Estrutura física**: subpastas por domínio, ficheiros **`{ClassName}.md`** (nome **sem** prefixo **`T`** ou **`I`**; ex.: `Connection.md`), `README.md` mínimo por subpasta.
- **Convenção de nomenclatura** dos ficheiros gerados pelo scaffold (**`ClassName`** = sufixo Pascal após remover **`T`** ou **`I`** do identificador; não usar o nome da unit no ficheiro salvo regra de colisão).
- **Template mínimo** dos ficheiros **criados** pelo scaffold (placeholders).
- **Modos** `scaffold` / `sync` / `full`, idempotência e relatório de execução.

**Não duplicar** estas regras em `documentation-general_rules` nem em `documentation-project-feature`. A skill `documentation-project-feature` **preenche qualidade** (matriz, RN, checklist) **sobre** a estrutura produzida aqui; não redefine a árvore `Analise/`.

## Convenção T e I: nome do ficheiro (base) vs conteúdo

| Prefixo do tipo | Significado | Nome do ficheiro (base) | No corpo do `.md` |
|-----------------|-------------|-------------------------|-------------------|
| **`T`** | Classe (implementação típica Delphi/Free Pascal) | `Connection.md` (a partir de **`TConnection`**) | Documentar **`TConnection`** com tipo, unit e responsabilidade. |
| **`I`** | Interface | **Mesmo** `Connection.md` se existir **`IConnection`** no mesmo domínio | Documentar **`IConnection`** no mesmo ficheiro (secção ou bloco distinto) ou fundir numa vista única do “contrato Connection”. |

- **Regra:** **`{ClassName}.md`** onde **`ClassName`** é o nome Pascal **sem** o prefixo **`T`** ou **`I`** (ex.: `TConnection` / `IConnection` → **`Connection.md`**).
- O **título** do Markdown (`# …`) usa preferencialmente o **nome base** (`# Connection`); no **conteúdo** listar sempre os identificadores completos **`T…`** / **`I…`** e as **units** de declaração.
- Quando só existir um dos dois tipos (ex.: só **`TWidget`**), o ficheiro é **`Widget.md`** e o corpo documenta só esse identificador.

**Colisão de nomes** (dois tipos distintos que mapeiam para o mesmo base após remover `T`/`I` é raro; mais comum: **duas classes homónimas** em units diferentes no mesmo domínio): desambiguar no nome do ficheiro com sufixo curto da unit, ex. `Foo.Connection.md` / `Foo.Helpers.md`, e registar no relatório de scaffolding.

## Excepcoes de nomenclatura reconhecidas

A regra canonica e `{ClassName}.md` (sem prefixo `T`/`I`). Existem duas excepcoes documentadas e reconhecidas como padrao (nao sao bugs):

### `{ClassName}.md` — canonico para classes e interfaces

- Regra principal: `TConnection` / `IConnection` geram `Connection.md`.
- Aplica-se a **todas** as classes e interfaces que exportam tipos `T…` ou `I…`.
- Quando ambos `T…` e `I…` existem com o mesmo sufixo, partilham o mesmo ficheiro.

### `{Unit}.{ClassName}.md` — excepcao para units sem classes exportadas

- Aplica-se a units que **nao exportam classes nem interfaces** (ex.: units de constantes, utilitarios, tipos simples).
- Exemplo: `Providers.Commons.Consts.pas` (sem `TConsts` nem `IConsts`) gera `Commons.Consts.md`.
- Tambem se aplica a **colisoes de nomes** quando duas classes homonimas de units diferentes caem no mesmo dominio.
- Este padrao e reconhecido e documentado — **nao e um bug** nem uma violacao da regra canonica.

### Resumo

| Situacao | Nome do ficheiro | Exemplo |
| --- | --- | --- |
| Classe/interface com `T`/`I` | `{ClassName}.md` | `Connection.md` |
| Unit sem classes exportadas | `{Unit}.{ClassName}.md` | `Commons.Consts.md` |
| Colisao de nomes (mesmo base) | `{Unit}.{ClassName}.md` | `Foo.Connection.md` |

## Politica obrigatoria e pedidos desalinhados

- **Obrigatório** neste pack / repositório anfitrião: o layout canónico é **subpastas por domínio** + **`Dominio/{ClassName}.md`** com **`ClassName` sem prefixo `T`/`I` no nome do ficheiro. **Não** é opcional “escolher” um layout paralelo.
- Pedidos informais do tipo **uma pasta por `T…`/`I…` com `README.md` dentro** estão **desalinhados** com esta skill: não são equivalentes ao modelo canónico. Resposta padrão: o fluxo de scaffold e de geração massiva (`documentation-class-analysis-generator`) segue **`Dominio/{ClassName}.md`**; cumprir o pedido alternativo só como **exceção** explícita (trabalho manual ou futuro), **sem** revogar a obrigatoriedade aqui.
- **`documentation-class-analysis-generator`** assume e aplica a mesma convenção ao preencher corpo, `README.md` índice e `FLOWCHART.md` — ver remissão nessa skill.

## When NOT to use

- Quando a estrutura `Analise/` já existir completa e o objetivo for preencher conteúdo detalhado — usar `documentation-class-analysis-generator`.
- Quando o objetivo for documentar regras de negócio (invariantes, pré/pós-condições) — usar `documentation-business-rules`.
- Quando o objetivo for documentar arquitetura geral do sistema (diagramas, ADRs, decisões) — usar `documentation-architecture`.
- Quando o objetivo for gerar um roadmap ou backlog documental — usar `documentation-roadmap-from-docs`.
- Quando o objetivo for criar telas/wireframes/esboços de UI — usar `documentation-screen-sketches`.

## When to use

- Quando o projeto não tiver pasta `Analise/` e for necessário criar a estrutura base antes de qualquer análise.
- Quando existir `Analise/` mas faltar subpastas ou arquivos para classes novas encontradas em `src/`.
- Quando o usuário pedir para "criar estrutura de análise", "montar pastas de análise por classe" ou "scaffolding de Analise/".
- Para **cobrir lacunas** face a uma **lista canónica de compilação** (opcional): ficheiro entrypoint (ex.: `*.dpr`, `*.csproj`) — gerar apenas **`{ClassName}.md`** em falta para **nomes base** derivados dos tipos `T`/`I` nas units obrigatórias, sem sobrescrever existentes.
- **Antes de invocar** `documentation-project-feature` em projetos sem `Analise/` prévia ou com estrutura incompleta.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-general_rules` | Sempre — verificar convenções de nomenclatura e idioma do projeto antes de criar qualquer ficheiro. |
| `documentation-project-bootstrap` | Quando o projeto não tiver nenhuma estrutura documental ainda (cria `Documentation/` e pastas base). |

## Diretriz de templates master

- Skills com prefixo `documentation` e `projeto` são templates master.
- Alterações só podem ocorrer por solicitação direta e explícita do usuário.
- Sem solicitação explícita, usar a skill sem editar seu conteúdo.

## Ficheiros-modelo físicos (`.cursor/Templates/`)

- **Índice:** `.cursor/Templates/README.md` (lista completa).
- **`Analise/`:** `templates/TEMPLATE_Unit_ClassName.md` (scaffold minimo, dentro desta skill), **`TEMPLATE_ClassName_Full_Documentation.md`** (documentacao completa por tipo — partilhado com **documentation-class-analysis-generator**; `.cursor/Templates/`), `templates/TEMPLATE_README_Modulo.md`, `templates/TEMPLATE_ESPECIFICACAO_Modulo.md`, `templates/TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md`, `templates/TEMPLATE_CHECKLIST_IMPLEMENTACAO.md`, `templates/TEMPLATE_PASSO_A_PASSO.md`, `templates/TEMPLATE_O_QUE_FALTA.md` (todos dentro desta skill).
- **`Documentation/`:** `TEMPLATE_Docs_*.md` e, se aplicável, `TEMPLATE_Docs_html_*` (portal em **`Documentation/html/`**). Checklist de conformidade do portal: **`documentation-portal-html`** (critérios *Portal HTML*) e **`TEMPLATE_Docs_html_README.md`** (secção *Conformidade e referência*).
- **Uso:** copiar o ficheiro para o destino final (`Analise/...` ou `Documentation/...`), renomear conforme convenções do projeto, preencher placeholders. Se na raiz existir `Docs/` ou `docs/`, renomear para `Documentation/` antes de novos artefactos.
- O **template mínimo** da secção «Template minimo de arquivo classe/metodo» abaixo deve permanecer **alinhado** a `documentation-paste_analysis/TEMPLATE_Unit_ClassName.md` (mesmos campos obrigatórios). Para conteúdo **completo** (7 secoes, tabelas, exemplos), usar **`TEMPLATE_ClassName_Full_Documentation.md`** apos scaffold ou via **documentation-class-analysis-generator**.

## Inputs

1. `<project_root>`: raiz do projeto (padrão: `.`).
2. `<fonte_codigo>` (opcional): padrão `src/` (aceitar pastas equivalentes: `lib/`, `packages/`, etc., conforme stack).
3. `<entrypoint_build>` (opcional): ficheiro de lista canónica de units (ex.: `ProvidersORM.dpr`, `Program.cs`, `.csproj` com referências) — uso: identificar units que **devem** ter doc em `Analise/` mesmo que o scan de pastas seja parcial.
4. `<modo>` (opcional): `scaffold` (default — criar apenas faltantes) | `sync` (adicionar novos sem sobrescrever) | `full` (recriar tudo — destrutivo, requer confirmação).
5. `<idioma_saida>` (opcional): `pt-BR` (default).

## Outputs obrigatorios

1. Pasta `Analise/` criada (se ausente).
2. Subpastas por domínio derivadas de `src/` (ex.: `Analise/Connections/`, `Analise/Database/`).
3. `README.md` mínimo em cada subpasta (placeholder com nome do módulo).
4. Arquivo **`{ClassName}.md`** por **nome base** distinto (agrupando **`T…`** e **`I…`** que partilham o mesmo sufixo; e/ou exigido pelo entrypoint quando aplicável).
5. Relatório de scaffolding: pastas criadas, arquivos criados, arquivos ignorados (já existiam), classes sem domínio mapeado.

## Regra de nomeacao

```text
Analise/
└── {Dominio}/                      ← prefixo lógico da unit sem namespace base
    ├── README.md                   ← placeholder mínimo do módulo
    └── {ClassName}.md              ← nome base sem T/I (ex.: Connection.md)
```

### Exemplo

Projeto com `src/Providers.Connection.pas` contendo `TConnection` e `IConnection`:

```text
Analise/
└── Connections/
    ├── README.md
    └── Connection.md               ← TConnection e IConnection documentados no conteúdo
```

### Regras de derivacao de dominio

- Prefixo lógico = segmento do nome do arquivo de unit após o namespace base do projeto.
- Exemplos para namespace base `Providers`:
  - `Providers.Connection.pas` → domínio `Connections`
  - `Providers.Database.EntityManager.pas` → domínio `Database`
  - `Providers.PoolConnections.pas` → domínio `PoolConnections`
- Quando não houver namespace reconhecível, usar o nome do arquivo como domínio.

### ProvidersORM — prefixos `Providers.Database.*` e `Providers.Databases.*`

No repositório **ProvidersORM**, units **`Providers.Database.*`** (EntityManager, QueryBuilder, etc.) e **`Providers.Databases.*`** (Field, Table, …) derivam o **mesmo domínio curto** **`Database`**. A pasta canónica em `Analise/` é **`Analise/Database/`** (única), com `{ClassName}.md` para todas as classes de ambos os prefixos. **Não** recriar `Analise/Providers.Database/` nem `Analise/Providers.Databases/` como árvore paralela; após a fusão (28/03/2026) os redirects em disco foram **removidos** — qualquer link antigo a essas pastas deve apontar para **`Analise/Database/`**.

**Checklist pós-execução (fecho 100%):** (1) relatório com domínios, ficheiros criados, ignorados; (2) lista “classes sem domínio mapeado” vazia ou justificada; (3) cada domínio esperado do `src/` tem entrada em `Analise/` após migração acordada; (4) sem duplicação do conteúdo de **`Analise/Database/`** noutras pastas sob `Analise/` com nomes de pacote legados.

### ProvidersORM — prefixo `Providers.Attributers.*`

Units em **`src/Attributers`** usam o prefixo **`Providers.Attributers.*`**. A pasta canónica em `Analise/` é **`Analise/Attributers/`** (domínio curto). **Não** recriar **`Analise/Providers.Attributers/`** (renomeada em 28/03/2026); links antigos devem apontar para **`Analise/Attributers/`**.

### Pós-conclusão: actualizar links, limpar e estado final

Após **reestruturação**, **fusão de domínios** ou substituição de stubs por **`{ClassName}.md`** canónicos, o agente **não** considera o trabalho terminado só com a árvore criada. Executar **em sequência**:

1. **Auditoria de links** — Procurar no repositório (ex.: `Analise/`, `Documentation/`, `.cursor/rules`, hubs em Markdown) referências a caminhos **antigos** ou inválidos: pastas renomeadas, `../DominioAntigo/*.md` quando o conteúdo migrou, duplicados de nomes longos (`Unit.ClassName.md`) se o canónico já absorveu o texto. Corrigir links relativos para o **destino que existe** (tipicamente `Analise/{Dominio}/{ClassName}.md` ou `./` na mesma pasta após fusão).
2. **Limpeza do que deixou de ser necessário** — Remover **apenas** com critério: (a) ficheiros duplicados por cópia acidental (confirmar que o canónico ou o backup contém o conteúdo); (b) rascunhos temporários explícitos; (c) stubs de redirect **só** quando a política do projeto e o README raiz de `Analise/` autorizarem (ou após janela de compatibilidade acordada). **Nunca** apagar sem snapshot/`backup/` ou commit quando o lote for grande.
3. **Resultado final único** — O estado desejado é: **uma fonte canónica** por classe (`{ClassName}.md`); READMEs por domínio actualizados; índices (`Analise/README.md`, `Documentation/Analise/*` se existir) **sem** links para ficheiros inexistentes; redirects legados **mínimos** só se forem política explícita (compatibilidade de paths).
4. **Registo** — Mencionar no relatório de scaffolding ou numa linha no `CHANGELOG.md` / changelog do documento: “links actualizados; removidos X redundantes; estado final Y”.

A skill **`documentation-project-scan`** (passo 2b em `Analise/`) ajuda a detectar pastas órfãs e lacunas; combinar com grep por padrões de path antigo após mudanças físicas.

## Passos executaveis

### 1) Scan de src/

- Listar todos os arquivos de unit em `<fonte_codigo>` (`.pas`, `.go`, `.cs`, `.py`, `.ts`, etc.).
- Se `<entrypoint_build>` existir: extrair lista de units/ficheiros **obrigatórios** e cruzar com o scan (prioridade para não deixar buracos documentais).
- Para cada unit: extrair nome lógico e tipos declarados — priorizar identificadores **`T…`** (classes) e **`I…`** (interfaces) expostos na API do módulo.
- Derivar domínio para cada unit.

### 2) Verificacao de Analise/

- Verificar quais subpastas e arquivos já existem.
- Separar: `criar` (ausente) vs `ignorar` (já existe — idempotente).

### 3) Criacao de estrutura

- Para cada domínio novo: criar subpasta + `README.md` placeholder (pode partir de **`templates/TEMPLATE_README_Modulo.md`** dentro desta skill, copiado e adaptado).
- Para cada **nome base** novo (sem arquivo): criar **`{ClassName}.md`** com template mínimo (incluir no mesmo ficheiro `T…` e `I…` quando ambos existirem).
- Opcionalmente copiar **`templates/TEMPLATE_Unit_ClassName.md`** (dentro desta skill) como base antes de preencher.
- **Nunca sobrescrever** arquivos existentes no modo `scaffold` e `sync`.

### 4) Template minimo de arquivo classe/metodo

Cada **`{ClassName}.md`** criado deve conter:

```markdown
# {ClassName}

**Nome base (ficheiro):** `{ClassName}` (ex.: `Connection` → ficheiro **`Connection.md`**; **sem** `T`/`I` no nome do ficheiro).
**Tipos documentados:** listar identificadores completos (ex.: **`TConnection`**, **`IConnection`**) com **`T…`** / **`I…`** e **unit** de cada um.
**Unit(s):** `{Unit}` (repetir ou listar se várias)
**Domínio:** `{Dominio}`
**Ficheiro:** `{ClassName}.md`
**Status:** placeholder

## Responsabilidade

> Preencher com a responsabilidade da classe (**`T…`**) ou da interface (**`I…`**).

## Métodos principais

| Método | Assinatura | Descrição |
|---|---|---|
| - | - | - |

## Dependências

> Preencher com dependências conhecidas (outros tipos **`T…`** / **`I…`** ou units).

## Observações

> Preencher com regras de negócio, invariantes ou casos especiais.
```

**Conteúdo dos `.md` de classe (após scaffold):** apenas **descrição e responsabilidade**; não substituir código-fonte por implementação completa nos ficheiros de análise (detalhe de projeto pode estar em `Inicial_V1.0.mdc` ou equivalente).

### 5) Relatorio de scaffolding

Gerar resumo com:
- total de domínios/subpastas criados
- total de arquivos criados
- total ignorados (já existiam)
- lista de classes sem domínio mapeado (requer revisão manual)

## Lógica de decisao

| Condição | Ação |
|---|---|
| `Analise/` não existe | criar + scaffolding completo |
| `Analise/` existe, subpasta ausente | criar subpasta + README + arquivos |
| Subpasta existe, arquivo ausente | criar apenas o arquivo faltante |
| Arquivo já existe | ignorar (modo `scaffold`/`sync`) |
| `src/` ausente ou sem units reconhecíveis | criar `Analise/README.md` placeholder + avisar |

## Relacao com outras skills

| Skill | Relação |
|---|---|
| `documentation-project-feature` | Complementar — esta skill faz **estrutura e placeholders**; `feature` produz **matriz, RN, checklist** sem redefinir a árvore `Analise/`. |
| `documentation-project-scan` | Complementar — inventário de `Analise/` (e `Documentation/`) para gaps; não compete com a criação de ficheiros por classe. |
| `documentation-general_rules` | Ordem de invocação e convenções transversais (ex.: changelog em `.md` portátil); **não** define árvore `Analise/`. |
| `documentation-migration-backup` | Usar quando houver **remanejamento** em massa ou migração para `Documentation/` com backup; após matriz de migração. |
| `documentation-project-bootstrap` | Sem choque — `bootstrap` cria `Documentation/Analise/` (dentro da pasta documental); esta skill trata **`Analise/` na raiz** por convenção deste tipo de projecto. |
| `documentation-rules_creator` | Complementar — `rules_creator` usa `Analise/` como **input**; o **scaffolding** é sempre esta skill. |

## Criterios de aceite

- `Analise/` existe após execução.
- Cada domínio encontrado em `src/` tem subpasta em `Analise/` (quando aplicável ao modelo do projeto).
- Cada **nome base** relevante (derivado de **`T…`** / **`I…`**) tem arquivo **`{ClassName}.md`** (salvo excepções explicitamente listadas no relatório).
- Arquivos pré-existentes não foram sobrescritos nos modos seguros.
- Relatório de scaffolding foi emitido.
- Pós-conclusão: links no repo actualizados para caminhos canónicos; sem `.md` órfãos referenciados nos índices principais; remoções documentadas.
- Operação é replicável em qualquer projeto sem ajustes manuais além de namespace/entrypoint.

## Template de saida (resposta)

1. Resumo executivo (domínios encontrados, arquivos criados, ignorados)
2. Árvore de estrutura criada
3. Lista de classes sem domínio mapeado (pendências)
4. **Pós-conclusão:** links actualizados (ficheiros tocados); remoções ou stubs mantidos (justificação); estado final da árvore
5. Próximos passos (invocar `documentation-project-feature` para popular conteúdo, ou scan para validar)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Criar uma pasta `T{ClassName}/` com `README.md` dentro para cada tipo | Viola a convenção canónica `Dominio/{ClassName}.md`; gera duplicação e links quebrados | Usar `Dominio/{ClassName}.md` agrupando `T…` e `I…` no conteúdo do mesmo ficheiro |
| Usar o nome da unit como nome do ficheiro (ex.: `Providers.Connection.md`) | Dificulta navegação e quebra a convenção de nome base sem prefixo | Usar apenas `Connection.md`; aplicar `{Unit}.{ClassName}.md` só em colisões ou units sem classes |
| Sobrescrever ficheiros existentes em modo `scaffold` | Apaga trabalho já realizado (conteúdo preenchido por `documentation-class-analysis-generator`) | Respeitar a lógica idempotente: ignorar ficheiros que já existem |
| Executar esta skill para preencher as 7 secções de conteúdo detalhado | Esta skill só cria placeholders; preencher conteúdo é responsabilidade de `documentation-class-analysis-generator` | Após scaffold, invocar `documentation-class-analysis-generator` |

## Métricas de sucesso

- Todos os domínios presentes em `src/` têm subpasta correspondente em `Analise/` após execução (cobertura de domínios = 100%).
- Zero ficheiros pré-existentes sobrescritos em modo `scaffold` ou `sync` (idempotência verificada pelo relatório).
- Relatório de scaffolding emitido com contagem de domínios criados, ficheiros criados, ficheiros ignorados e lista de classes sem domínio mapeado (lista vazia ou justificada).

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-class-scanner` / `doc-agent-class-writer` |
| Revisão humana | Desenvolvedor responsável pelo módulo |
| Aprovação final | Tech lead / dono do repositório |

---

**Changelog (este arquivo):**

- 1.4.0 (04/04/2026): Secção "Excepções de nomenclatura reconhecidas" — documenta `{ClassName}.md` (canónico) vs `{Unit}.{ClassName}.md` (excepção para units sem classes exportadas e colisões de nomes); padrão reconhecido, não bug.
- 1.3.8 (01/04/2026): Lista de templates `Analise/` — **`TEMPLATE_ClassName_Full_Documentation.md`**; nota no template minimo vs documentacao completa.
- 1.3.7 (01/04/2026): Secção **Política obrigatória e pedidos desalinhados** — prevalece `Dominio/{ClassName}.md` sem `T`/`I` no nome do ficheiro; pastas `T…`/`I…`+`README` não são layout canónico; remissão a `documentation-class-analysis-generator`.
- 1.3.6 (28/03/2026): **ProvidersORM** — **`Analise/Attributers/`** (ex-`Providers.Attributers/`); secção dedicada no domínio curto.
- 1.3.5 (28/03/2026): **ProvidersORM** — redirects `Analise/Providers.Database/` e `Analise/Providers.Databases/` **removidos**; texto e checklist alinhados a **`Analise/Database/`** única.
- 1.3.4 (28/03/2026): Secção **Pós-conclusão** — auditoria de links no repo, limpeza de redundantes, estado final único; critérios de aceite e template de saída alinhados.
- 1.3.3 (28/03/2026): **ProvidersORM** — unificação `Providers.Database` + `Providers.Databases` → pasta **`Analise/Database/`**; checklist pós-execução (fecho 100%).
- 1.3.2 (27/03/2026): **`TEMPLATE_Docs_html_*`** — remissão a **`Documentation/html/`**, orchestrator e **`TEMPLATE_Docs_html_README.md`** (conformidade portal).
- 1.3.1 (27/03/2026): Ficheiros-modelo canónicos em **`.cursor/Templates/`** (antes `Analise/TEMPLATES/`); secção física de templates; passo 3 alinhado a `TEMPLATE_README_Modulo` / `TEMPLATE_Unit_ClassName`.
- 1.3.0 (27/03/2026): **`ClassName`** = nome base **sem** prefixo **`T`**/**`I`** no ficheiro (ex.: **`Connection.md`**); `T…`/`I…` apenas no conteúdo; agrupar T+I no mesmo `.md` quando partilham o sufixo.
- 1.2.1 (28/03/2026): Exemplo **Connection** — um só **`Connection.md`** (IConnection + TConnection no conteúdo); não manter stubs `IConnection.md` / `TConnection.md` / `Providers.*.TConnection.md` quando o canónico existe.
- 1.2.0 (27/03/2026): Nome de ficheiro **`{ClassName}.md`** (tipos **`T…`** / **`I…`**) em substituição de `{Unit}.{ClassName}.md`; template e critérios actualizados; colisão de nomes.
- 1.1.0 (27/03/2026): Papel canónico da pasta `Analise/`; input opcional `entrypoint_build`; relações atualizadas (`general_rules`, `scan`, `migration-backup`); `feature` explicitada como não redefinir estrutura física.
- 1.0.0 (27/03/2026): Criação da skill — scaffolding genérico e idempotente de `Analise/` derivado de `src/`.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.2.0 |
| **Política**    | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.2.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências (skills prévias), Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.1.0 (04/04/2026): Secção "Excepções de nomenclatura reconhecidas" — `{ClassName}.md` canónico vs `{Unit}.{ClassName}.md` para units sem classes exportadas; tabela resumo.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
