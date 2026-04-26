---
name: documentation-general_rules
description: Convenções transversais de documentação entre skills (ordem de invocação, changelog em Markdown portátil, pacote para outro repositório/IA). Não define a pasta Analise/ — isso é documentation-paste_analysis_unit_class_method.
model: sonnet
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation — General rules (transversal)

## Responsabilidade única

Esta skill cobre o que **nenhuma outra skill de documentação possui como domínio próprio**: o
fluxo de invocação entre skills `documentation-*`, o padrão de changelog portátil em Markdown e
a política de transporte do pack para outro repositório ou ferramenta de IA. Ela não documenta
classes, não escaneia artefatos, não cria regras — apenas alinha o ecossistema documental.

## Papel

Esta skill cobre apenas o que **não tem outra skill dona**:

- Ordem recomendada de invocação entre skills documentais.
- Changelog em ficheiros `.md` quando o repositório **não** define política própria (ex.: sem equivalente a `Inicial_V1.0.mdc`).
- Como **transportar** o conjunto mínimo de skills para outro projeto ou outra ferramenta de IA.

**Proibido nesta skill:** repetir a árvore `Analise/`, templates de scaffold **`{ClassName}.md`** (nome base sem `T`/`I` no ficheiro; ex.: **Connection.md**), ou regras de derivação de domínio — isso é **exclusivo** de `documentation-paste_analysis_unit_class_method`.

**Ficheiros-modelo (físicos):** **`.cursor/Templates/`** — índice `README.md`. As skills `documentation-*` devem **copiar** o `TEMPLATE_*` adequado para `Analise/` ou **`Documentation/`** antes de expandir conteúdo (o scaffold automático da paste skill pode gerar o mínimo inline sem cópia explícita). Raiz documental canónica: **`Documentation/`**; se existir `Docs/` ou `docs/` na raiz, renomear para **`Documentation/`** antes de sincronizar.

## When to use

- Quando for necessário alinhar **fluxo** entre várias skills `documentation-*` num único pedido.
- Quando o utilizador pedir "padrão genérico de changelog em Markdown" sem tocar nas regras do projeto.
- Quando o utilizador pedir "o que copiar para outro repo / Claude / VS Code / Continue".

## When NOT to use

- Para documentar classes ou units → usar `documentation-paste_analysis_unit_class_method`
- Para escanear artefatos e identificar lacunas → usar `documentation-project-feature` ou `documentation-project-scan`
- Para criar ou modificar rules `.mdc` → usar `documentation-rules_creator`
- Para planejar migração de documentação com backup → usar `documentation-migration-backup`
- Para orquestrar pipelines documentais multi-etapa → usar `doc-agent-orchestrator`

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Pedido do usuário | texto | Descrição do que precisa ser alinhado entre skills documentais |

*(Nenhum artefato de entrada obrigatório — esta skill é consultiva/normativa.)*

## Dependências (skills prévias)

Nenhuma dependência obrigatória. Esta skill pode ser invocada como ponto de entrada para
alinhamento do fluxo documental.

## Workflow executável

1. Identificar qual(is) skill(s) de documentação devem ser invocadas no pedido.
2. Aplicar a ordem de invocação recomendada (seção abaixo).
3. Orientar sobre changelog portátil quando o repositório não tem política própria.
4. Orientar sobre transporte do pack quando solicitado.

## Ordem de invocação recomendada

```text
1. documentation-paste_analysis_unit_class_method     → estrutura Analise/ + placeholders (se faltar)
1b. documentation-overview-architecture               → modelo de qualidade para Overview + Arquitetura
                                                        (quando doc_type = overview/architecture/both)
2. documentation-class-analysis-generator             → documentação completa por tipo a partir do código (doc-agent-class-*); omitir se não for pedido "todas as classes / inventário de tipos"
3. documentation-project-feature                      → matriz de lacunas, checklist, backlog
   3b. documentation-business-rules                   → para cada módulo com lacuna de RN identificada no passo 3,
                                                        gerar RN_<Modulo>_Vx.y.md usando Documentation/Analise/ como fonte
4. documentation-project-scan                         → (opcional) inventário amplo Documentation/ + Analise/
5. documentation-migration-backup                     → só quando houver migração/remanejamento com backup
6. documentation-rules_creator                       → (opcional) sintetizar .cursor/rules a partir de evidências
7. governance-sdlc-lifecycle                          → (opcional) ao planejar releases, runbooks, matriz RN→teste ou revisar completude SDLC/segurança
```

**Fluxos multi-etapa** (vários passos acima no mesmo pedido): ponto de entrada do agente **`doc-agent-orchestrator_V1.1.4.md`** — coordena especialistas `doc-agent-*` e skills `documentation-*` sem duplicar com `dev-agent-orchestrator`.

Ajustar conforme o pedido: nem todos os passos são obrigatórios.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Orientação de fluxo | Resposta ao usuário | Texto + tabela de ordem de invocação |
| Changelog portátil (quando pedido) | Final do documento alterado | Markdown |

## Decisões obrigatórias (V2.1.0+)

Toda documentação iniciada via `documentation-project-bootstrap` deve produzir, em `Documentation/Decisions/`, os 7 arquivos canônicos abaixo. **Nenhum é opcional para projetos não-triviais** — ausência = falha do bootstrap.

| Arquivo | Conteúdo | Origem |
| --- | --- | --- |
| `IGNORED_PATHS.md` | Pastas vazias (apenas `.gitkeep`), artefatos transitórios (`*.bak`, `*.bak.fase_*`, `*.v1`), pastas runtime (`venv/`, `__pycache__/`, `node_modules/`, `logs/`) — com motivo + decisão de origem (briefing/usuário/skill) | `documentation-project-bootstrap` |
| `NAMING_CONFLICTS.md` | Conflitos de casing/naming detectados durante a varredura (ex.: `Docs/` vs `docs/` em SO case-insensitive; `src/` vs `src.py/`; `Documentation/` vs `documentation/`) | `documentation-project-bootstrap` + `documentation-project-scan` |
| `AGGREGATION_RATIONALE.md` | Casos onde 1 `.md` cobre múltiplos arquivos de código (com lista das unidades agregadas + justificativa). Vazio inicialmente; preenchido pela fase 4 do workflow obrigatório | `documentation-class-analysis-generator` |
| `STRUCTURE_MODE.md` | Registra o modo escolhido: `canonical` (13 subpastas oficiais) ou `thematic` (numerada `NN_Tema/`). Quando `thematic`, anexar `STRUCTURE_MAPPING.md` cruzando temas locais ↔ subpastas canônicas | `documentation-project-bootstrap` |
| `PORTAL_DECISION.md` | Registra `<portal_html>` escolhido: `generate` / `skip` / `deferred` + motivo | `documentation-project-bootstrap` |
| `COEXISTENCE_NOTES.md` | Pastas-irmãs detectadas quando `<output_path>` é não-raiz (ex.: pastas de domínio como `Amostras XML/`, `SITFIS/` ao lado da pasta documental) | `documentation-project-bootstrap` |
| `DEPENDENCY_GAPS.md` | Imports do código sem entrada no manifesto de dependências. Vazio = manifesto completo | `documentation-project-scan` (passo 4) |

**Regra absoluta:** estes arquivos devem existir mesmo que vazios — vazio é resposta válida (significa "nada a registrar nesta categoria").

## Checklist de validação

- [ ] Ordem de invocação correta (paste → feature/scan → migration → rules)
- [ ] Changelog portátil usa formato `- X.Y.Z (DD/MM/AAAA): descrição` ao final do arquivo
- [ ] Transporte do pack lista no mínimo as 2 skills obrigatórias (paste + project-feature)
- [ ] Nenhuma regra de `documentation-rules_creator` ou `documentation-paste_analysis` duplicada aqui
- [ ] **V2.1.0+:** `Documentation/Decisions/` contém os 7 arquivos canônicos (mesmo que vazios)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Usar esta skill para documentar classes ou criar `{ClassName}.md` | Fora do escopo — cria duplicidade e conflito com `documentation-paste_analysis` | Redirecionar para `documentation-paste_analysis_unit_class_method` |
| Replicar a política de rules (`.cursor/rules`) nesta skill | `documentation-rules_creator` é a dona; duplicar gera inconsistência | Remover e referenciar `documentation-rules_creator` |
| Invocar esta skill como único passo de documentação | É uma skill de alinhamento, não de geração; não produz artefatos diretamente | Usar esta skill para definir o fluxo e invocar as skills específicas |
| Pular criação de `Documentation/Decisions/` (V2.1.0+) | Decisões implícitas (pastas vazias ignoradas, conflitos de naming, agregação de docs) ficam invisíveis e impossíveis de auditar | Garantir que o bootstrap crie os 7 arquivos canônicos, mesmo que vazios |
| Aplicar decisão de ignorar/agregar sem registrar em `Decisions/` (V2.1.0+) | Próximo agente/desenvolvedor não tem como reconstituir o raciocínio | Toda decisão de exclusão ou agregação deve ter linha em `IGNORED_PATHS.md` ou `AGGREGATION_RATIONALE.md` |

## Avaliação de risco

- **Parar e confirmar quando:** o usuário pede para "documentar tudo" — esclarecer quais módulos/classes antes de prosseguir.
- **Risco baixo:** alinhamento de fluxo entre skills (sem modificar artefatos).
- **Risco médio:** orientar transporte do pack para outro repositório (verificar quais skills são necessárias para o contexto destino).

## Métricas de sucesso

- Nenhuma skill de documentação invocada fora de ordem (paste antes de scan, scan antes de migration)
- Nenhum conteúdo de `documentation-rules_creator` ou `documentation-paste_analysis` duplicado nesta skill

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech Lead / responsável pela documentação |

---

## Hub consolidado `.cursor/SKILLS_DOCUMENTATION`

- **Ficheiro:** na raiz de `.cursor/`, **`SKILLS_DOCUMENTATION_v{MAJOR}.{MINOR}.{PATCH}.md`** (ex.: `SKILLS_DOCUMENTATION_v3.0.8.md`).
- **Regra:** a **versão do hub** declarada no **cabeçalho** do Markdown **deve** coincidir com o **SemVer no nome do ficheiro**.
- **Ao alterar o conteúdo do hub:** ou manter o mesmo `vX.Y.Z` no nome, ou **renomear o ficheiro** e **actualizar todas as referências**: [.cursor/README.md](../../README.md) e [bootstrap-mirror-symlinks.ps1](../../scripts/bootstrap-mirror-symlinks.ps1) (refs operacionais activas; `BASE_STRUCTURE.md`, `MIRRORS_VALIDATION.md` e `Templates/mirror-config/` foram removidos no refactor). A mesma ideia aplica-se a manifestos `*-pack-manifest_V*.md` — ver [.cursor/VERSION.md](../../VERSION.md).
- **Não** usar o nome genérico `SKILLS_DOCUMENTATION.md` sem sufixo de versão nas remissões operacionais; usar sempre o path versionado actual do repositório.

## Convenção de nomenclatura de agentes

**Fonte canónica:** esta secção define o padrão para **todos** os ficheiros em `.cursor/agents/`. Não duplicar a regra noutros `.md` — remeter aqui.

**Padrão:** `{grupo}-agent-{nome}`

- **`{grupo}`:** identifica o ecossistema do agente — vem **antes** de `-agent-`.
- **`-agent-`:** fixo, separador literal.
- **`{nome}`:** papel específico (ex.: `orchestrator`, `migration`, `providers-orm-expert` dentro de `dev-agent-providers-orm-expert`).

**Grupos reconhecidos neste repositório:**

| Grupo | Prefixo ficheiro | Uso |
|-------|------------------|-----|
| Documentação (template `Documentation/`, migração documental, etc.) | `doc-agent-` | Orquestração e especialização **documental** |
| Desenvolvimento (código, módulos ORM, Views) | `dev-agent-` | Orquestração e especialização **de implementação** |

**Novo grupo:** só com convenção explícita acordada (ex.: `qa-agent-`); registar **nesta secção** (tabela + exemplo) antes de criar ficheiros; atualizar `.cursor/README.md`.

**Exemplo antes / depois:**

```text
Antes (evitar): doc-orchestrator-agent.md  ← sufixo -agent ambíguo
Depois (usar):  doc-agent-orchestrator_V1.2.0.md   ← grupo doc + agent + papel

Antes (evitar): providers-orm-expert.md     ← sem grupo
Depois (usar):  dev-agent-providers-orm-expert_V1.2.0.md
```

## Separação `.cursor/rules` vs skills / agentes (norma)

- A **política completa** ("rules = só projeto anfitrião; portátil em skills") está em **`documentation-rules_creator`**, secções *Princípio obrigatório*, *Matriz rápida* e *Política: `.cursor/rules` vs skills/agentes*.
- Esta skill (`general_rules`) mantém **fluxo entre skills** e **esta convenção de nomes de agentes** — não repetir parágrafos longos da política de rules.

## Changelog em ficheiros `.md` (portátil)

Quando o projeto **não** exigir outro formato, usar no **final** de cada documento alterado:

```markdown
---

**Changelog (este arquivo):**
- X.Y.Z (DD/MM/AAAA): descrição breve.
```

Versão e data alinhar à política do repositório anfitrião quando existir.

## Pacote para outro repositório / outra IA

1. Copiar pastas de skills necessárias de `.cursor/skills/` (mínimo típico: `documentation-paste_analysis_unit_class_method`, `documentation-project-feature`; acrescentar `documentation-general_rules`, `documentation-project-scan`, `documentation-migration-backup`, `documentation-rules_creator` conforme o fluxo).
2. Referenciar no `README` do projeto ou em `AGENTS.md` quais skills carregar para tarefas documentais.
3. Se o projeto usar espelhos: após alterar `.cursor/`, executar **[bootstrap-mirror-symlinks.ps1](../../scripts/bootstrap-mirror-symlinks.ps1)** (symlinks para `.claude/`, `.vscode/`, `.continue/`, `.opencode/`) — ver `.cursor/README.md`; não usar cópia manual de índices como substituto da política de espelhos. (Nota: `MIRRORS_VALIDATION.md` foi removido; a validação está agora no próprio script via flag `-ValidateOnly`.)

## Relação com outras skills

| Skill | Conteúdo que não entra aqui |
|-------|----------------------------|
| `documentation-paste_analysis_unit_class_method` | Pasta `Analise/`, domínios, **`{ClassName}.md`** (nome base; ex.: Connection.md), modos scaffold/sync |
| `documentation-project-feature` | Matriz de lacunas, checklist "Analise completa", RN, semântica |
| `documentation-project-scan` | Inventário e classificação de artefactos |
| `documentation-migration-backup` | Migração para `Documentation/`, backup, superseded |
| `documentation-rules_creator` | **Dona da interação** entre `.cursor/rules` (só específico do workspace) e skills/agents; geração e política de repartição de conteúdo |
| `documentation-portal-html` | Portal estático em **`Documentation/html/`** (templates `TEMPLATE_Docs_html_*`) |
| `governance-sdlc-lifecycle` | **Dona** do ciclo de vida SDLC: tabela fase×artefato, runbooks, testes, segurança, checklists release |

---

## Política de idioma — documentação (absorvida de Constitution)

Conteúdo anteriormente em `.cursor/Constitution/constitution-language-policy_V1.0.md`. Absorvido em 04/04/2026.

### Idioma principal

- **Português (PT)** para narrativa, regras de negócio, roteiros e descrições de arquitetura **neste repositório**, salvo decisão explícita do projeto.
- **Inglês** para identificadores de código, nomes de APIs, paths de ficheiros, comandos CLI e termos técnico-industriais consagrados (ex.: *build*, *pool*, *connection string*) quando melhorarem a precisão.

### Consistência

- Escolher um glossário mínimo para o mesmo conceito (ex.: *conexão* vs *ligação*) e mantê-lo no hub ou num documento de referência.
- Evitar misturar PT e EN na mesma frase salvo citações ou nomes próprios.

### Changelogs e metadados

- Datas no formato **AAAA-MM-DD** ou **DD/MM/AAAA** de forma consistente por ficheiro.
- Versões alinhadas a **Semantic Versioning** quando o documento declarar `Vx.y`.

---

## Convenções de naming — documentação (absorvida de Constitution)

Conteúdo anteriormente em `.cursor/Constitution/constitution-naming-conventions_V1.0.md`. Absorvido em 04/04/2026.

### Pasta documental do produto

- **Canónico:** `Documentation/` (capital **D** inicial, nome completo).
- Se existir apenas `Docs/` ou `docs/` na raiz, **renomear** para `Documentation/` antes de criar novos artefactos (alinhamento com skills `documentation-*`).

### Hub

- Ficheiro índice: `README.md` (sem versão no nome).
- Manter **um** hub por versão major da documentação; incrementar minor quando o mapa de artefactos mudar de forma relevante.

### Documentos temáticos

- Padrão sugerido: `<Area>_<Assunto>_Vx.y.md` ou `Analise_<Topico>_Vx.y.md`.
- Incluir **versão** no nome quando o documento for canónico e evoluível (`_V1.0`, `_V1.1`).
- Evitar duplicar o mesmo destino com nomes divergentes; um canónico por tema.

### Backup e migração

- Artefactos substituídos ou arquivados: destino em `{DocsRaiz}/Backup/` com política descrita em `Backup/README.md`.

---

## Matriz de responsabilidades de documentação (absorvida de project-documentacao)

| Responsabilidade | Onde | Conteúdo principal |
| ---------------- | ---- | ------------------ |
| **Regras para criação** | Skill **documentation-project-fundamentals-template** | Changelog, nomenclaturas, padrões, exceções. |
| **Locais de arquivos** | Skill **documentation-project-structure-template** | Paths, pacotes, compilação, módulos externos. |
| **Processos de execução** | Skill **documentation-project-roadmap-template** | Fases, módulos, checklists de status. |
| **Diretivas de compilação** | Skill **developer-delphi-programming-conditional-defines** | Diretivas USE_* e blocos {$IFDEF}. |
| **Documentação deste repo** | **project-documentacao_V1.0.1.mdc** | Roteiros, assimilações, ponteiros específicos do projecto. |
| **Scaffold `Analise/`** | Skill **documentation-paste_analysis_unit_class_method** | Estrutura, `{ClassName}.md`, modos scaffold/sync/full. |
| **Qualidade / lacunas** | Skill **documentation-project-feature** | Matriz de lacunas, checklist, backlog. |
| **Scan amplo** | Skill **documentation-project-scan** | Inventário completo, gaps, classificação. |
| **Regras de Negócio por módulo** | Skill **documentation-business-rules** + **doc-agent-rules** | `RN_<Modulo>_Vx.y.md` por módulo |
| **Uso prático do projeto** | Skill de roteiro + roadmap do projecto | Fluxo de uso; leitura obrigatória das regras do projecto. |

### Como criar ou alterar documentação

1. **Scaffold / placeholders:** skill **documentation-paste_analysis_unit_class_method**.
2. **Matriz de lacunas / cobertura:** skill **documentation-project-feature**.
3. **Migração com backup:** skill **documentation-migration-backup**.
4. **Inventário amplo:** skill **documentation-project-scan**.
5. **Fluxo entre skills e changelog genérico:** esta skill (**documentation-general_rules**).
6. **Atualizar índice:** `Analise/README.md` após qualquer alteração estrutural.

---

## Referências

- Fluxo documental: [`documentation-paste_analysis_unit_class_method`](../documentation-paste_analysis_unit_class_method_V1.2.0/SKILL.md)
- Política de rules: [`documentation-rules_creator`](../documentation-rules_creator_V1.1.0/SKILL.md)
- Ciclo de vida SDLC: [`governance-sdlc-lifecycle`](../governance-sdlc-lifecycle_V1.0.0/SKILL.md)
- Agent orquestrador: `.cursor/agents/doc-agent-orchestrator_V1.2.0.md`
- Scripts de espelhos: `.cursor/scripts/bootstrap-mirror-symlinks.ps1`

---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 2.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 2.1.0 (26/04/2026): Nova seção **Decisões obrigatórias** — formaliza os 7 arquivos canônicos em `Documentation/Decisions/` (`IGNORED_PATHS`, `NAMING_CONFLICTS`, `AGGREGATION_RATIONALE`, `STRUCTURE_MODE`, `PORTAL_DECISION`, `COEXISTENCE_NOTES`, `DEPENDENCY_GAPS`) com origem por skill; novo critério de validação; 2 novos anti-padrões (pular Decisions; aplicar decisão sem registrar). Integra com `documentation-master-orchestrator` V1.2.0, `documentation-project-bootstrap` V2.2.0 e `documentation-project-scan` V1.2.0.
- 2.0.0 (08/04/2026): Migração V2 — adicionadas seções Categoria, Responsabilidade única,
  When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal;
  thinking: normal; frontmatter expandido com category.
- 1.1.13 (04/04/2026): Absorvida matriz de responsabilidades de `project-documentacao_V1.0.1.mdc`; secção "Como criar ou alterar documentação".
- 1.1.12 (04/04/2026): Absorvido conteúdo de `constitution-language-policy_V1.0.md` e `constitution-naming-conventions_V1.0.md`.
- 1.1.10 (02/04/2026): Ordem de invocação — item 7 **`documentation-sdlc-lifecycle`**.
- 1.1.9 (01/04/2026): Ordem de invocação com **`documentation-class-analysis-generator`**; nota **`doc-agent-orchestrator_V1.1.3`**.
- 1.1.11 (02/04/2026): Exemplo de hub **`SKILLS_DOCUMENTATION_v3.0.7.md`** na secção *Hub consolidado*.
- 1.1.8 (01/04/2026): Exemplo de hub **`SKILLS_DOCUMENTATION_v3.0.6.md`** na secção *Hub consolidado*.
- 1.1.7 (01/04/2026): Secção **Hub consolidado `.cursor/SKILLS_DOCUMENTATION`** — SemVer do nome do ficheiro = versão do cabeçalho.
- 1.1.0 (27/03/2026): **Convenção de nomenclatura de agentes**; **Separação rules vs skills**.
- 1.0.0 (27/03/2026): Criação — skill mínima transversal.
