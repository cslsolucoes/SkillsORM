---
name: documentation-project-plan-subplans
description: Para um projeto existente (qualquer pasta com .dpr/.lpr ou source), gera um plano-mestre de criação de documentação e o divide automaticamente em N subplanos focados (um por contexto/módulo), cada um dimensionado para caber em uma única janela de contexto do agente, salvos em `.cursor/plans/` como `docplan-<projeto>-<contexto>_<hash>.plan.md`. Use quando o usuário pedir "fazer o plano de documentação", "criar plano dividido em subplanos" ou "planejar documentação sem sobrecarregar contexto".
model: sonnet
thinking: extended
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# documentation-project-plan-subplans

## Versão interna (ficheiro)

| Campo           | Valor |
| --------------- | ----- |
| **FileVersion** | 1.0.0 |
| **Política**    | `.cursor/VERSION.md` |

## Responsabilidade única

Esta skill analisa um projeto existente, determina o número ideal de subplanos de documentação (com base na quantidade de módulos/units/telas), gera um **plano-mestre** (`docplan-<projeto>-MASTER.plan.md`) e N **subplanos focados** (`docplan-<projeto>-<contexto>_NNN.plan.md`) — todos em `.cursor/plans/`. Cada subplano cobre um contexto coeso o suficiente para ser executado por um agente em uma única janela de contexto, sem risco de perda de informação. Não cria documentação — apenas planeja; a criação pertence às skills `documentation-project-bootstrap`, `documentation-paste_analysis_unit_class_method` e `documentation-business-rules`.

## When to use

- Quando o usuário pedir **"fazer o plano de documentação"** de um projeto ou subprojeto.
- Quando o projeto tiver múltiplos módulos/telas e o plano único seria grande demais para um único contexto.
- Quando o usuário pedir **"dividir em subplanos"**, **"criar planos de contexto específico"** ou **"planejar documentação sem sobrecarregar contexto"**.
- Quando um projeto legado (ERP, VCL, etc.) precisar ter seu acervo documental planejado do zero.

## When NOT to use

- Para **executar** a documentação → usar `documentation-project-bootstrap` (estrutura), `documentation-paste_analysis_unit_class_method` (classes), `documentation-business-rules` (RNs), etc.
- Para **inventariar** documentação já existente → usar `documentation-project-scan`.
- Para **migrar** documentação de lugar → usar `documentation-migration-backup`.
- Para um projeto com 1–3 módulos simples onde um único plano basta → usar `documentation-migration-plan_V1.0.md` diretamente.

## Inputs

1. `<caminho_projeto>` *(obrigatório)*: caminho relativo ou absoluto da pasta do projeto (ex.: `PROJETO/Careli`, `PROJETO/COPA/Source`).
2. `<pasta_docs>` *(opcional)*: pasta de documentação a criar/popular (padrão: `<caminho_projeto>/Documentation`).
3. `<entrypoint>` *(opcional)*: arquivo `.dpr`, `.lpr`, `.csproj`, `package.json`, etc. — autodetectado se omitido.
4. `<granularidade>` *(opcional)*: `fino` (1 subplano por módulo), `médio` (1 por grupo temático — padrão), `grosso` (1 por camada/área). Padrão: `médio`.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| ----- | --------------------- |
| `project-estrutura` | Para mapear a estrutura de pastas/units antes de planejar |
| `documentation-project-scan` | Se já existir documentação parcial — inventariar antes de planejar |
| `documentation-general_rules` | Para naming e convenções de documentos nos subplanos |

## Outputs obrigatórios

1. **Plano-mestre** — arquivo `.cursor/plans/docplan-{PROJETO}-MASTER.plan.md`:
   - visão geral do projeto (módulos, telas, regras de negócio identificadas)
   - índice de todos os subplanos com escopo e dependências entre eles
   - estratégia de execução (ordem recomendada + paralelos possíveis)
   - estimativa de esforço por subplano
2. **N subplanos** — arquivos `.cursor/plans/docplan-{PROJETO}-{CONTEXTO}_{NNN}.plan.md`:
   - escopo preciso (quais units/telas/módulos cobrir)
   - checklist detalhado de documentos a criar
   - critérios de aceite testáveis
   - dependências de outros subplanos
   - agente recomendado para execução

## Passos executíveis

### Passo 1 — Descoberta do projeto

1. Detectar entrypoint de build (`.dpr` / `.lpr` / equivalente).
2. Extrair lista de units/módulos do `uses` (Delphi/FPC) ou estrutura de pastas (outros).
3. Identificar:
   - **Módulos de domínio** (lógica de negócio, entidades, regras)
   - **Telas / Views / Forms** (interfaces de usuário)
   - **Infraestrutura** (banco, rede, utilitários)
   - **Documentação existente** (se houver) — inventariar sem modificar
4. Registrar totais: N_modules, N_forms, N_units, N_docs_existentes.

### Passo 2 — Particionamento em contextos

Regra de particionamento por `<granularidade>`:

| Granularidade | Critério de agrupamento |
|---|---|
| `fino` | 1 subplano por módulo/form individual |
| `médio` *(padrão)* | 1 subplano por grupo temático (cadastros, movimentos, relatórios, fiscais, etc.) |
| `grosso` | 1 subplano por camada (dados, negócio, telas, integração) |

**Regra de tamanho máximo por subplano:** no máximo 15 units/forms **ou** 3 módulos complexos por subplano. Se exceder, subdividir.

**Subplanos obrigatórios independentemente da granularidade:**

| Subplano fixo | Conteúdo |
|---|---|
| `INFRA` | Bootstrap da estrutura `Documentation/`, hub, changelog, portal HTML |
| `ARQUITETURA` | Visão geral arquitetural, camadas, dependências entre módulos |
| `BANCO` | Esquema de banco de dados, tabelas, relacionamentos (se aplicável) |
| `MASTER` | Índice geral + ordem de execução |

### Passo 3 — Geração do plano-mestre

Gerar `.cursor/plans/docplan-{PROJETO}-MASTER.plan.md` com:

```markdown
# Plano-mestre de Documentação — {PROJETO}
**Versão:** 1.0 · **Data:** DD/MM/AAAA
**Projeto:** {PROJETO} · **Caminho:** {caminho_projeto}
**Subplanos:** {N} · **Granularidade:** {granularidade}

> REGRA: Entrar em plan mode antes de executar qualquer subplano.

## Índice de subplanos
| # | Arquivo | Contexto | Units/Forms | Dependências | Esforço |
|---|---------|----------|-------------|--------------|---------|
| 01 | docplan-{PROJETO}-INFRA_001.plan.md | Bootstrap estrutura docs | — | — | baixo |
| 02 | docplan-{PROJETO}-ARQUITETURA_002.plan.md | Visão arquitetural | todos | 01 | médio |
| 03 | docplan-{PROJETO}-{CONTEXTO_A}_003.plan.md | {descrição} | {lista} | 01,02 | {alto/médio/baixo} |
| ... | ... | ... | ... | ... | ... |

## Estratégia de execução
- **Fase 0 (sequencial):** INFRA → ARQUITETURA → BANCO
- **Fase 1 (paralelo possível):** subplanos de domínio sem dependências cruzadas
- **Fase 2 (sequencial):** validação cruzada + fechamento

## Totais descobertos
- Units/módulos: {N}
- Forms/telas: {N}
- Documentos existentes: {N}
- Subplanos gerados: {N}
```

### Passo 4 — Geração dos subplanos

Para cada contexto identificado no Passo 2, gerar um arquivo seguindo o template:

```markdown
# Subplano {NNN} — {CONTEXTO} · {PROJETO}
**Plano-mestre:** docplan-{PROJETO}-MASTER.plan.md
**Escopo:** {descrição de 1 linha}
**Dependências:** {lista de subplanos anteriores ou "nenhuma"}
**Agente recomendado:** {doc-agent-orchestrator / dev-agent-delphi-orchestrator / etc.}

---

## Escopo detalhado
Units/forms cobertos:
- {unit_1} — {descrição breve}
- {unit_2} — ...

Documentos a criar:
| # | Tipo | Arquivo destino | Template base | Prioridade |
|---|------|-----------------|---------------|-----------|
| D01 | Analise | Documentation/Analise/{domínio}/{Classe}.md | TEMPLATE_Unit_ClassName.md | Alta |
| D02 | RN | Documentation/Regras de Negocio/RN-M{xx}/RN-M{xx}-001.md | TEMPLATE_Docs_RN.md | Alta |
| ... | ... | ... | ... | ... |

---

## Checklist de execução

### Pré-condições
- [ ] Subplanos dependentes concluídos: {lista}
- [ ] Bootstrap da estrutura Documentation/ feito (subplano INFRA)
- [ ] Templates disponíveis em `.cursor/Templates/`

### Execução
- [ ] Ler as units/forms do escopo
- [ ] Para cada unit: gerar documento Analise/{Domínio}/{Classe}.md
- [ ] Para cada regra de negócio identificada: gerar RN-M{xx}-{nnn}.md
- [ ] Para telas/forms: gerar esboço em Esboco_Telas/ (se aplicável)
- [ ] Atualizar hub Documentation/README_Vx.y.md com novos links

### Critérios de aceite
- [ ] Todos os documentos da tabela "Documentos a criar" existem no caminho destino
- [ ] Cada documento tem: cabeçalho de versão, data, changelog interno
- [ ] Nenhuma API ou método inventado — baseado exclusivamente no código lido
- [ ] Hub atualizado com links válidos para os novos documentos

---

## Versão interna
| Campo | Valor |
|-------|-------|
| FileVersion | 1.0 |
| Gerado por | documentation-project-plan-subplans |
| Data | DD/MM/AAAA |
```

### Passo 5 — Confirmação ao usuário

Após gerar todos os arquivos, apresentar:
1. Resumo: N subplanos gerados, caminho do plano-mestre
2. Tabela com arquivos criados (nome + escopo + esforço estimado)
3. Ordem de execução recomendada
4. Próximo passo sugerido: "Execute o subplano INFRA para iniciar o bootstrap"

## Convenção de nomes dos arquivos

```
.cursor/plans/docplan-{PROJETO}-MASTER.plan.md
.cursor/plans/docplan-{PROJETO}-{CONTEXTO}_{NNN}.plan.md
```

| Placeholder | Regra |
|---|---|
| `{PROJETO}` | Nome do projeto em PascalCase sem espaços (ex.: `Careli`, `Copa`, `Oficinas`) |
| `{CONTEXTO}` | Nome do contexto em UPPER_SNAKE_CASE (ex.: `INFRA`, `CADASTROS`, `FISCAIS`) |
| `{NNN}` | Número sequencial de 3 dígitos: `001`, `002`, … |

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Gerar um único plano enorme para todo o projeto | Sobrecarrega o contexto do agente executor; etapas ficam interdependentes e difíceis de rastrear | Usar esta skill para particionar em subplanos de tamanho controlado |
| Criar subplanos sem escopo preciso (ex.: "documentar o sistema") | O agente não sabe por onde começar; gera documentação inconsistente | Cada subplano deve listar explicitamente as units/forms e os documentos esperados |
| Pular o subplano INFRA e começar pelos domínios | A estrutura `Documentation/` não existe; documentos criados ficam em pastas erradas | Sempre executar INFRA primeiro (bootstrap da estrutura) |
| Não registrar dependências entre subplanos | Subplanos executados fora de ordem geram referências quebradas | Preencher sempre a coluna "Dependências" na tabela do plano-mestre |
| Usar granularidade `fino` em projetos pequenos (<5 módulos) | Fragmentação excessiva; mais overhead do que benefício | Usar `médio` para projetos com 5–30 módulos; `fino` só para projetos >30 |

## Métricas de sucesso

- Plano-mestre gerado e salvo em `.cursor/plans/` com índice completo de subplanos.
- Cada subplano tem escopo, checklist e critérios de aceite — nenhum campo vazio.
- O número de subplanos é coerente com o tamanho do projeto (nem um plano monolítico, nem fragmentação excessiva).
- O usuário consegue iniciar execução do primeiro subplano sem dúvidas sobre o escopo.

## Responsável principal

| Papel    | Quem |
| -------- | ---- |
| Executor | `doc-agent-orchestrator` |
| Revisão  | `documentation-general_rules` |

---

## Changelog (este arquivo)

- 1.0.0 (10/04/2026): Versão inicial. Skill genérica para qualquer projeto — escaneia estrutura, particiona em subplanos por granularidade (fino/médio/grosso), gera plano-mestre + N subplanos em `.cursor/plans/`. Subplanos fixos obrigatórios: INFRA, ARQUITETURA, BANCO. Convenção de nomes `docplan-{PROJETO}-{CONTEXTO}_{NNN}.plan.md`. Inspirado na necessidade de documentar o projeto `Careli` (ERP legado VCL) sem sobrecarregar contexto.
