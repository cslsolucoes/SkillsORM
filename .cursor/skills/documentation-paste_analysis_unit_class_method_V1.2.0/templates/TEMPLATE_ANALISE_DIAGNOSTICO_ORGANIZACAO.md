# {Escopo} — Diagnóstico, organização e inventários (documento unificado)

**Projecto:** {Nome do projecto}  
**Ficheiro alvo (após preencher):** `{Escopo}/ANALISE_DIAGNOSTICO_ORGANIZACAO.md`  
**Versão do documento:** 1.0.0  
**Data:** DD/MM/AAAA  

Copiar este template para **`ANALISE_DIAGNOSTICO_ORGANIZACAO.md`** na raiz de `{Escopo}/` (ex.: `Analise/`), substituir todos os `{…}` e remover linhas de instrução que não se aplicarem. Um único ficheiro substitui oito meta-documentos separados (guia, inventários, matriz, modelo, diagnóstico, relatório, scaffolding).

---

## Índice (manter ao publicar)

| # | Capítulo | Conteúdo |
|---|----------|------------|
| 1 | [Visão geral e âmbito](#cap1) | Objectivo, o que não substitui |
| 2 | [Guia operacional](#cap2) | Fluxo, ponte `.cursor`, checklist, precedência |
| 3 | [Modelo alvo e decisões](#cap3) | Decisão estrutural (ex. B2), excepções, DELETE |
| 4 | [Inventário canónico — `.dpr`](#cap4) | `uses` → `src/` |
| 5 | [Inventário `{Escopo}` vs `src`](#cap5) | Meta-docs, pastas, duplicidades, lacunas |
| 6 | [Matriz de migração](#cap6) | Anti-perda origem → destino |
| 7 | [Diagnóstico RN / semântica / lógica](#cap7) | Cobertura, lacunas, matriz por módulo, BL-01… |
| 8 | [Relatório de conformidade e Fase D](#cap8) | Skills, Pass/Fail, inputs skill paste |
| 9 | [Scaffolding e templates](#cap9) | Skill presente/ausente, inputs, modos |
| 10 | [Changelog consolidado](#cap10) | Histórico deste ficheiro |

---

<a id="cap1"></a>

## Capítulo 1 — Visão geral e âmbito

- **Finalidade:** {uma frase — ex. fonte única para diagnóstico da pasta de análise, alinhamento ao entrypoint de build, decisões de estrutura.}
- **Não substitui:** {ex. `README.md` do escopo, `O_QUE_FALTA*.md`, regras em `.cursor/rules`.}
- **Convenção de nomes (se aplicável):** `{ClassName}.md` = nome base **sem** `T`/`I` no ficheiro; `T…`/`I…` no conteúdo.

---

<a id="cap2"></a>

## Capítulo 2 — Guia operacional da pasta `{Escopo}/`

Uso operacional mínimo sem substituir documentos canônicos da `.cursor`.

### 2.1 Fluxo rápido

0. Alinhamento código ↔ doc: **Cap. 4** e **Cap. 5**.
1. Ler `{Escopo}/README.md`.
2. Validar backlog/status: `{caminho/O_QUE_FALTA ou equivalente}`.
3. Diagnóstico e conformidade: **Cap. 7** e **Cap. 8**.
4. Execução técnica: documentos em `.cursor/` (ajustar paths relativos ao projecto).

### 2.2 Ponte para canônicos `.cursor`

| Tema | Ficheiro típico | Notas |
|------|-----------------|-------|
| Compilação | `{raiz}/.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` | Delphi, FPC, etc. |
| Banco CLI | `{raiz}/.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md` | mysql, sqlite3, … |
| Diretivas | `{raiz}/.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md` ou equivalente | `USE_*` |
| Roteiros consolidados | `{raiz}/{DocsRaiz}/ROTEIROS_CONSOLIDADO.md` (ex.: `docs/`) | Se existir; template: `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md` |
| Lógica camada dados | `{raiz}/{DocsRaiz}/LOGICA_DATABASE.md` | Se existir; template: `TEMPLATE_Docs_LOGICA_DATABASE.md` |

### 2.3 Checklist mínimo

- [ ] Módulo localizado no índice `{Escopo}/README.md`.
- [ ] Estado conferido no backlog consolidado.
- [ ] Cap. 7 e 8 revistos quando houver mudança estrutural.
- [ ] Canônico `.cursor` consultado para ações técnicas.

### 2.4 Precedência

1. `src/` (código) prevalece.  
2. Canônicos `.cursor` prevalecem sobre guias.  
3. `{Escopo}/` actualizado para reflectir o estado real.

---

<a id="cap3"></a>

## Capítulo 3 — Modelo alvo — decisão {ID da decisão} ({nome curto})

**Contexto:** {problema / plano que originou a decisão.}

### 3.1 Decisão

**{ID} — {Opção escolhida}** — {resumo}.

**Motivos:**  
1. {Motivo 1}  
2. {Motivo 2}  
3. {Motivo 3}

**Complementos:**  
- {Fusões, novas pastas, inventários como fonte de verdade.}

### 3.2 Opções descartadas (opcional)

| ID | Opção | Motivo |
|----|-------|--------|
| {A} | {…} | {…} |

### 3.3 Excepções à decisão (opcional)

| Excepção | Justificativa |
|----------|---------------|
| {Caso} | {…} |

### 3.4 Critério de DELETE (futuro)

{Quando apagar `.md`; backup; confirmação explícita do utilizador.}

---

<a id="cap4"></a>

## Capítulo 4 — Inventário canónico — `{Projeto}.dpr` → `src/`

**Fonte:** `uses` de `{Projeto}.dpr`.  
**Total de entradas:** {N} units com path `src\...`.  
**Data:** DD/MM/AAAA.

### 4.1 {Módulo 1} (`src\…`)

| Unit no DPR | Path |
|-------------|------|
| {Unit.Nome} | src\…\{Unit.Nome}.pas |

*(Repetir subsecções por agrupamento lógico: Commons, Modulos, Main, Views, …)*

### 4.N Views (`src\Views\`)

**Nota:** forms em disco que **não** estão no `uses` do `.dpr`: {listar ou "nenhum".}

---

<a id="cap5"></a>

## Capítulo 5 — Inventário `{Escopo}/` versus `src/` (+ DPR)

**Referências:** Cap. 4, `{Projeto}.dpr`, árvore `{Escopo}/**/*.md` (**{N}** ficheiros na data do scan).

### 5.1 Meta-documentos (raiz `{Escopo}/`)

| Ficheiro | Papel | Estado |
|----------|--------|--------|
| README.md | Hub | [X] / [ ] |
| **ANALISE_DIAGNOSTICO_ORGANIZACAO.md** | Este documento | [X] |
| {outros} | {…} | [ ] |

### 5.2 Pastas por módulo

| Pasta em `{Escopo}` | Espelho em `src/` | Cobertura |
|---------------------|-------------------|-----------|
| {Modulo}/ | src/… | [X] / [P] {nota} |

### 5.3 Duplicidades resolvidas

| Problema | Acção |
|----------|--------|
| {…} | {fundir / redirect / …} |

### 5.4 Lacunas remanescentes

1. {Lacuna 1}  
2. {Lacuna 2}

---

<a id="cap6"></a>

## Capítulo 6 — Matriz de migração — anti-perda

**Data:** DD/MM/AAAA  
**Backup:** `backup/{nome_backup}/`  
**Regra:** não eliminar conteúdo útil sem registo; preferir fundir ou redirect.

| ficheiro_origem | ficheiro_destino | accao | notas |
|-----------------|------------------|-------|-------|
| `{Escopo}/…` | `{Escopo}/…` | fundir / criar / actualizar | {…} |

### DELETE

{Nenhum / listar com confirmação explícita.}

---

<a id="cap7"></a>

## Capítulo 7 — Diagnóstico (organização, RN, semântica, lógica)

### 7.1 Cobertura por funcionalidade

- `{Pasta1}/`: {o que cobre}.  
- `{Pasta2}/`: {o que cobre}.

### 7.2 Lacunas (organização, RN, semântica, lógica)

{Bullets por subsecção 7.2.x se necessário.}

### 7.3 Matriz de lacunas por módulo

| Módulo | Organização | RN id. | RN doc. | Semântica | Lógica | Acção | Prioridade | Evidência |
|--------|-------------|--------|---------|-----------|--------|-------|------------|-----------|
| `{Mod}` | Boa/Parcial | … | … | … | … | … | … | `{arquivo}` |

### 7.4 Checklist operacional por funcionalidade

- [ ] Organização, responsabilidade, RN, critérios de aceite, rastreabilidade, semântica, lógica, status único.

### 7.5 Recomendações

1. {…}  
2. {…}

### 7.6 Backlog testável (BL-01 …)

| ID | Funcionalidade | Regra | Critério testável | Evidência | Status |
|----|----------------|-------|--------------------|-----------|--------|
| BL-01 | {…} | {…} | {…} | `{…}` | [ ] / [X] |

### 7.7 Conformidade (skills / rules / agents)

- **Skills:** {Aderente / …}  
- **Rules:** {…}  
- **Agents:** {…}

---

<a id="cap8"></a>

## Capítulo 8 — Relatório de conformidade e Fase D (skill paste)

**Referência skill:** `.cursor/skills/documentation-paste_analysis_unit_class_method_V1.1.0/SKILL.md` (se existir no projecto).

### 8.1 Inputs do projecto

| Input | Valor |
|-------|--------|
| `<project_root>` | {raiz} |
| `<fonte_codigo>` | `src/` |
| `<entrypoint_build>` | `{Projeto}.dpr` |
| `<modo>` | `scaffold` / `sync` (evitar `full` sem confirmação) |
| `<idioma_saida>` | `pt-BR` |

### 8.2 Critérios de aceite da skill — estado

| Critério | Estado | Nota |
|----------|--------|------|
| `{Escopo}/` existe | Pass / … | |
| Subpastas + README | … | |
| `{ClassName}.md` por tipo relevante | Parcial / Pass | |
| Relatório de scaffolding emitido | Em aberto / Pass | |

### 8.3 Fase D (resumo)

| ID | Passo |
|----|--------|
| D.1 | Scan `src/` + DPR; criar faltantes; **emitir relatório de scaffolding**. |
| D.2 | (Opcional) Espelhos em `src/Modulos`. |
| D.3 | DELETE só com confirmação + linha na matriz (Cap. 6). |
| D.4 | Actualizar Cap. 5 e este capítulo após D.1. |

### 8.4 Classificação (Aderente / ressalva / não aderente)

{Aderente: …}  
{Ressalva: …}

### 8.5 Validação Pass/Fail

| Categoria | Resultado | Evidência |
|-----------|-----------|-----------|
| {…} | Pass / Fail / N/A | `{…}` |

### 8.6 Plano residual

1. {…}  
2. {…}

### 8.7 Conclusão

{Texto curto.}

---

<a id="cap9"></a>

## Capítulo 9 — Scaffolding e templates

**Skill:** `{nome-da-skill}` — **{está / não está}** presente em `{raiz}/.cursor/skills/`.

**Se ausente:** usar **`.cursor/Templates/`** neste repositório — [TEMPLATE_Unit_ClassName.md](TEMPLATE_Unit_ClassName.md); noutro projecto, copiar os `TEMPLATE_*` equivalentes para `.cursor/Templates/` ou pasta documentada no `README` raiz. Para lista DPR, seguir estrutura do **Cap. 4** deste documento (ou extrair de `{Projeto}.dpr`).

**Se presente:** executar conforme SKILL.md; modos `scaffold` | `sync` | `full` (último só com backup e confirmação).

| Modo | Uso |
|------|-----|
| `scaffold` | Criar só faltantes (recomendado). |
| `sync` | Acrescentar secções sem apagar conteúdo manual. |
| `full` | Destrutivo — evitar sem confirmação. |

---

<a id="cap10"></a>

## Capítulo 10 — Changelog consolidado (este arquivo)

- **1.0.0 (DD/MM/AAAA):** Criação de **ANALISE_DIAGNOSTICO_ORGANIZACAO.md** a partir do template unificado.

---

**Changelog (este arquivo):**

- 1.0.2 (27/03/2026): Inventário — roteiros **`{DocsRaiz}/ROTEIROS_CONSOLIDADO.md`** e lógica dados **`{DocsRaiz}/LOGICA_DATABASE.md`** (templates genéricos em `.cursor/Templates/`).
- 1.0.1 (27/03/2026): Referência à pasta canónica **`.cursor/Templates/`** (antes `Analise/TEMPLATES/`).
- 1.0.0 (27/03/2026): Criação do template unificado **TEMPLATE_ANALISE_DIAGNOSTICO_ORGANIZACAO.md** (10 capítulos); substitui oito templates meta-documentais eliminados.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
