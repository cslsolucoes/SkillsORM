---
name: documentation-project-scan
description: Executa uma varredura (scanner padrão) para descobrir artefatos documentais e lacunas no ecossistema `Documentation/` (ou equivalente) com base em padrões de nomes/pastas. Gera inventário/classificação e um backlog acionável. Raiz canónica `Documentation/`; incluir `Docs/` ou `docs/` legados na raiz até consolidarem.
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# documentation-project-scan

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.2.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill executa uma varredura sistêmica do ecossistema documental do projeto — descobre artefatos existentes, classifica-os (canônico/superseded/duplicado/órfão) e gera um backlog acionável de lacunas. Cobre `Documentation/`, `Analise/`, `Arquitetura/`, `Regras de Negocio/`, `Roadmap/` e pastas legadas. Não cria novos documentos nem faz scaffold de classes — essas responsabilidades pertencem a `documentation-paste_analysis_unit_class_method`; não migra nem consolida conteúdo — isso é `documentation-migration-backup`.

## When to use

- Quando o usuário pedir "ver o que existe", "mapear documentos", "descobrir lacunas", "fazer inventário do acervo".
- Sempre que o ecossistema `Documentation/` for parcial/ausente ou quando existir risco de duplicação/caminhos divergentes.

**Nota:** a pasta **`Analise/` na raiz do repositório** (análise por classe/interface) é inventariada aqui quando `<escopo>` incluir `Analise/`. A **criação** de ficheiros **`{ClassName}.md`** (tipos **`T…`** / **`I…`**) e da árvore de domínios é da skill **`documentation-paste_analysis_unit_class_method`**; este scan **classifica** e aponta lacunas, não substitui o scaffold.

**Templates para resolver lacunas "criar":** no backlog, quando a ação for criar um documento canónico, referenciar o **`TEMPLATE_*`** correspondente em **`.cursor/Templates/`** (índice `README.md`).

## When NOT to use

- Criar ou atualizar documentos individuais → usar `documentation-paste_analysis_unit_class_method` (classes) ou `documentation-business-rules`, `documentation-architecture` conforme tipo.
- Migrar/consolidar documentação existente → usar `documentation-migration-backup`.
- Gerar documentação de feature completa com análise de lacunas por módulo → usar `documentation-project-feature`.
- Atualizar documentação após mudança de código → usar `documentation-project-update`.
- Gerar índice de classes/interfaces para `Analise/` → usar `documentation-analysis-index`.

## Inputs

1. `<caminho_raiz>` (opcional): diretório base do repositório (padrão: raiz do projeto).
2. `<versao_docs>` (opcional): `Vx.y` para orientar critérios de naming.
3. `<escopo>` (opcional): lista de pastas a varrer:
   - `Documentation/`, `Docs/` ou `docs/` (legado), `Analise/`, `Arquitetura/`, `Regras de Negocio/`, `Esboco_Telas/`, `Roadmap/`
4. `<objetivo>` (opcional): "scan para gaps" ou "scan para duplicação".

## Dependências (skills prévias)

| Skill                     | Quando executar antes                                    |
| ------------------------- | -------------------------------------------------------- |
| `documentation-general_rules` | Para confirmar naming conventions antes de classificar |
| `documentation-project-structure`       | Para mapear estrutura do repositório antes do scan       |

## Outputs obrigatórios

1. **Relatório de inventário** (tabela):
   - path
   - categoria (hub/arquitetura/RN/telas/analise/versionamento/roadmap/openapi/etc.)
   - versão (se houver)
   - status (canônico/superseded/duplicado/transitório/órfão)
   - evidência (frase/cabeçalho que suporta a classificação)
2. **Lista de lacunas (backlog)**:
   - documento esperado (path canônico)
   - status atual (existente/parcial/ausente)
   - ação sugerida (criar/revisar/consolidar/mover para Backup)
   - critérios de aceite testáveis
3. **Lista de conflitos de destino**:
   - destino canônico → origens que competem
4. **Inventário de unidades de código** (V1.2.0+) — base para o gate de coverage-plan do `documentation-master-orchestrator`:
   - path do arquivo-fonte
   - linguagem
   - classe/módulo principal
   - declarado em manifesto de dependências? (sim/não)
5. **`DEPENDENCY_GAPS.md`** (V1.2.0+) — cruzamento imports vs manifesto, persistido em `Documentation/Decisions/`:
   - dependências importadas no código sem entrada no manifesto
   - sugestão de versão (quando inferível pelo lock file)

## Passos executíveis

### 1) Scanner padrão (incorporar regra de busca do plano)

Buscar por:
- entradas técnicas: `README*`, `CHANGELOG*`, `CONTRIBUTING*`, `LICENSE*`
- documentação: `Documentation/`, `Analise/`, `Arquitetura/`, `Regras*`, `Roadmap*`
- API/integração: `openapi*`, `swagger*`, rotas/contratos e exemplos
- execução/qualidade: scripts de build/test/deploy e runbooks
- UI/fluxos: wireframes, telas, forms/views, protótipos
- governança: `.cursor/rules`, `.claude`, `.vscode`, ADRs (se houver)

### 2) Classificar e versionar

- Determinar categoria e versão:
  - `_Vx.y` no nome do arquivo quando existente
  - campos internos no corpo quando existirem (quando não, usar evidencia mínima e marcar incerteza)

### 2b) Verificação `Analise/` (domínio vs pastas)

Quando `<escopo>` incluir **`Analise/`**:

- Listar **pastas** em `Analise/` que **não** correspondam a um domínio derivado de `src/` (ou a redirect documentado) — classificar como **legado / órfã** no relatório.
- Listar **domínios esperados** (a partir do mapa de units ou do README raiz) **sem** subpasta correspondente — backlog `criar` ou `reestruturar`.
- No **ProvidersORM**, a pasta canónica **`Analise/Database/`** cobre units `Providers.Database.*` e `Providers.Databases.*`; não deve existir **paralelo** `Analise/Providers.Database/` ou `Analise/Providers.Databases/` (removidos após fusão em `Database/`).

### 3) Derivar ações acionáveis

- Para cada artefato esperado do template:
  - mapear para estado atual
  - sugerir ação `criar` vs `revisar/consolidar` vs "superseded → Backup"
  - garantir critérios de aceite testáveis

### 4) Cruzamento dependências vs imports (V1.2.0+, stack-aware)

Para cada stack detectada no projeto, comparar imports do código com o manifesto de dependências:

| Stack | Manifesto de dependências | Fonte de imports |
| --- | --- | --- |
| Python | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile` | `import X` / `from X import` em `*.py` |
| Node.js | `package.json` (`dependencies` + `devDependencies`) | `require()` / `import` em `*.js`/`*.ts`/`*.jsx`/`*.tsx` |
| Pascal (Delphi/FPC) | `*.dpk` / `*.dproj` (Requires), `*.lpk` / `*.lpi` (RequiredPackages) | cláusula `uses` em `*.pas` / `*.dpr` / `*.lpr` |
| Rust | `Cargo.toml` (`[dependencies]`) | `use` / `extern crate` em `*.rs` |
| Go | `go.mod` (`require`) | `import` em `*.go` |
| Java/Kotlin | `pom.xml` / `build.gradle` | `import` em `*.java`/`*.kt` |

Saída obrigatória: `Documentation/Decisions/DEPENDENCY_GAPS.md` listando:
- módulos importados mas ausentes do manifesto
- sugestão de versão (quando lock file disponível)
- evidência (arquivo + linha)

> Nota: imports de stdlib/built-in não devem entrar como gap (manter lista de exclusão por stack).

## Critérios de aceite da skill

- O relatório inclui todos os campos obrigatórios do output.
- Conflitos de destino são explicitamente listados (destino → origens).
- O backlog é acionável: cada item tem critérios de aceite (não genérico).
- **V1.2.0+:** Inventário de unidades de código produzido (base para gate de coverage-plan).
- **V1.2.0+:** `DEPENDENCY_GAPS.md` gerado em `Documentation/Decisions/` com cruzamento imports vs manifesto (vazio é resposta válida — significa "manifesto completo").

## Regras transversais

- Usar skill `documentation-general_rules` (naming conventions) para naming.
- Respeitar skill `documentation-general_rules` (language policy) para idioma.
- Não inventar arquivos: se o scan não encontrar, classificar como ausente/parcial e listar no backlog.

## Template de saída (relatório)

O relatório deve conter ao menos:
1. Resumo executivo (3–6 bullets)
2. Tabela inventário
3. Backlog lacunas (tabela)
4. Conflitos de destino (lista)

## Exemplo de referência canônica

- **`.cursor/Templates/README.md`** — mapa de `TEMPLATE_*` por tipo de artefacto.
- "EXEMPLO DE DOCUMENTAÇÃO/Docs/…" (quando existir) como layout de referência.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| ----------- | ---------------- | ------------- |
| Inventar documentos que não foram encontrados no scan | Gera backlog falso e direciona esforço para trabalho inexistente | Classificar como ausente/parcial apenas o que o scan confirma; nunca criar entradas sem evidência |
| Usar este scan para criar ou scaffold de documentos | Mistura responsabilidades; cria arquivos sem estrutura correta | Usar `documentation-paste_analysis_unit_class_method` para criação; este scan apenas classifica |
| Não listar conflitos de destino quando há duplicação | Deixa ambiguidade sobre qual documento é canônico | Sempre gerar seção "Conflitos de destino" mesmo que vazia |
| Classificar documentos sem evidência no corpo | Rótulo arbitrário que muda a cada scan | Incluir evidência (citação do cabeçalho ou metadado) para cada classificação |
| Pular cruzamento de dependências vs imports (V1.2.0+) | Manifesto fica desalinhado do código real; build em outra máquina falha por dependência ausente | Sempre executar passo 4 e gerar `DEPENDENCY_GAPS.md`, mesmo se o resultado for vazio |
| Inventariar unidades de código sem registrar manifesto declarado (V1.2.0+) | Coverage-plan posterior fica cego à origem da dependência | Marcar cada unidade com flag `declarado em manifesto?` no inventário |

## Métricas de sucesso

- O relatório de inventário cobre 100% das pastas no `<escopo>` fornecido.
- Todo item do backlog tem critérios de aceite testáveis (não genérico).
- Conflitos de destino identificados no scan são todos explicitados na seção correspondente.
- Nenhum documento é inventariado sem evidência de classificação.

## Responsável principal

| Papel    | Quem                              |
| -------- | --------------------------------- |
| Executor | `doc-agent-orchestrator`          |
| Revisão  | `documentation-general_rules`     |

---

## Changelog (este arquivo)

- 1.2.0 (26/04/2026): Novo passo 4 — **cruzamento dependências vs imports** (stack-aware: Python, Node.js, Pascal, Rust, Go, Java/Kotlin); novo output **inventário de unidades de código** (base para gate de coverage-plan do `documentation-master-orchestrator` V1.2.0); novo output `DEPENDENCY_GAPS.md` em `Documentation/Decisions/`; 2 novos critérios de aceite; 2 novos anti-padrões.
- 1.1.0 (09/04/2026): Migração V2 — `thinking: extended`, `category: documentation`, Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal adicionados.
- 1.0.4 (28/03/2026): **ProvidersORM** — redirects `Analise/Providers.Database/` e `Analise/Providers.Databases/` removidos; nota de scan actualizada.
- 1.0.3 (28/03/2026): Passo **2b** — verificação de pastas `Analise/` vs domínios (órfãs, em falta; nota ProvidersORM **`Database/`**).
- 1.0.2 (27/03/2026): Lacunas "criar" — remeter a **`.cursor/Templates/`**; exemplo de referência actualizado.
- 1.0.1 (27/03/2026): Nota `Analise/` — criação de **`{ClassName}.md`** (`T…` / `I…`) remete a **documentation-paste_analysis_unit_class_method** 1.2.0.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
