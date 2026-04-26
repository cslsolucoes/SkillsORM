---
name: governance-constitution-policies
description: Skill consolidada que reúne as três políticas constitucionais de documentação — integração rules/docs/skills, resolução de conflitos na migração documental e definição de documento superseded. Substitui as skills individuais documentation-cursor-rules-integration, documentation-migration-conflict-resolution e documentation-superseded-definition.
model: sonnet
thinking: normal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance — Constitution Policies (consolidada)

Skill que unifica as três políticas constitucionais de documentação num único ponto de referência.

## Responsabilidade única

Esta skill é a constituição documental do workspace: define onde cada tipo de conteúdo reside (rules vs Documentation vs skills), como resolver colisões de destino durante migração, e quando um documento é considerado superseded — garantindo que nunca existam duas fontes canónicas para o mesmo tema e que toda a rastreabilidade de decisões documentais seja preservada.

## When to use

- Quando o agente precisar decidir se a norma está em **`.cursor/rules`**, em **`Documentation/`** ou numa **skill**.
- Ao criar ou rever `.mdc` para não duplicar conteúdo portátil que já tem skill dona.
- Quando o inventário (Fase 0) mostrar **colisão de destino** (vários ficheiros para o mesmo path canónico).
- Durante Fase C de migração, após detectar que o destino já está ocupado por candidato concorrente.
- Ao classificar um documento como **substituído** por outro durante migração ou revisão.
- Quando o utilizador pedir para arquivar versão antiga mantendo rastreabilidade em `Documentation/Backup/`.

## When NOT to use

- Para criar ou actualizar o hub `Documentation/README_Vx.y.md` → usar `documentation-readme-hub`.
- Para executar a migração física de ficheiros → usar `documentation-migration-backup`.
- Para definir estrutura de pastas do projecto ou convenções de código → usar rules `.cursor/rules/*.mdc` específicas do repositório.

## Inputs obrigatórios

| Input | Descrição |
|-------|-----------|
| Tipo de tarefa | Classificação da fonte / resolução de conflito / declaração de superseded |
| Contexto do documento | Path actual, path canónico pretendido, notas sobre conteúdo e âmbito |
| Inventário (quando aplicável) | Tabela de candidatos com origem, destino e evidência |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `documentation-migration-backup` — Fase 0 | Inventário de candidatos necessário para Secções 2 e 3 |
| `documentation-readme-hub` | Sincronização do hub após decisões de classificação ou arquivo |

---

## Secção 1 — Integração entre rules, Documentation e skills

### Papéis das fontes

| Fonte | Conteúdo | Quando prevalece |
|--------|-----------|-------------------|
| `.cursor/rules/*.mdc` | Especificações **deste** workspace | Tarefas de código, estrutura de pastas, `src/` |
| `Documentation/*.md` (e subpastas) | Ecossistema documental **do produto** | Criar, editar ou migrar documentação **do repositório** |
| Skills `documentation-*` / `project-*` | Procedimentos reutilizáveis entre projectos | Fluxos genéricos |
| `AGENTS.md` (raiz) | Índice e ponteiros para agentes e convenções | Complementar regras |

### Regra de não duplicação

- Conteúdo que aplicaria **igual** noutro repositório → **skill**.
- Conteúdo **específico** deste repo → **`.cursor/rules/*.mdc`** ou artefactos em **`Documentation/`**.

### Ordem de leitura sugerida (tarefas mistas docs + código)

1. `.cursor/rules` relevantes.
2. Skills especialistas (`documentation-*` ou `project-*`).
3. **`Documentation/`** para hub e mapa do produto.

---

## Secção 2 — Resolução de conflitos na migração documental

### Ordem de desempate (fixa)

Quando vários ficheiros disputam o **mesmo** destino, seleccionar **um** canónico aplicando, **nesta ordem**:

1. **Equivalência de escopo** ao propósito do documento no path alvo.
2. **Completude** do conteúdo face a esse propósito.
3. **Evidência de actualização** (data no corpo, changelog do ficheiro, ou histórico em Git).
4. **Consistência de versão e nome** (sufixo `_Vx.y`, coerência com `README_Vx.y` do hub).

### Tratamento do excedente

- Mover para **`Documentation/Backup/`**.
- Nome do ficheiro: incluir sufixo **`_CONFLITO`** antes da extensão `.md`.
- **Nunca** manter dois ficheiros com o mesmo path canónico final.

### Registo obrigatório

- No hub **`Documentation/README_Vx.y.md`**: secção de histórico com origem dos candidatos, canónico escolhido e critério de desempate.
- Em **`Documentation/Versionamento/CHANGELOG.md`**: quando a colisão afectar o mapa de documentos.

---

## Secção 3 — Definição de documento superseded

### Critérios para classificar como superseded

Um documento é **superseded** quando se verifica **simultaneamente**:

1. Existe documento **substituto** (novo path em `Documentation/` ou nova versão no nome `_Vx.y`).
2. O substituto cobre o **mesmo âmbito funcional** que o documento antigo.
3. A versão ou a data de conteúdo do substituto é **posterior** ou está **explicitamente** indicada como vigente no hub.

### Destino obrigatório do documento superseded

- Mover para **`Documentation/Backup/`**.
- Recomenda-se manter rastreio no nome do ficheiro (ex.: sufixo de data ou `_superseded`).

---

## Workflow executável

### Fluxo para Secção 1 (classificação de fonte)

1. Identificar domínio da tarefa: código / norma meta-documental / documentação do produto / procedimento portátil.
2. Aplicar tabela "Papéis das fontes" para determinar a fonte canónica.
3. Verificar regra de não duplicação antes de criar conteúdo novo.
4. Registar decisão.

### Fluxo para Secção 2 (resolução de conflito)

1. Confirmar que Fase 0 (inventário) está concluída.
2. Aplicar os 4 critérios de desempate em ordem.
3. Mover excedentes para `Documentation/Backup/` com sufixo `_CONFLITO`.
4. Actualizar hub e changelog documental.

### Fluxo para Secção 3 (declaração de superseded)

1. Verificar os 3 critérios simultâneos de superseded.
2. Se critérios não satisfeitos → tratar como conflito (Secção 2).
3. Mover documento para `Documentation/Backup/` com sufixo `_superseded` ou data.
4. Actualizar hub e changelog.

## Outputs obrigatórios

| Output | Descrição |
|--------|-----------|
| Decisão de fonte (Secção 1) | Fonte canónica identificada: rules / Documentation / skill |
| Documento canónico no destino (Secção 2) | Um único ficheiro no path final; excedentes em Backup com sufixo `_CONFLITO` |
| Declaração de superseded (Secção 3) | Documento movido para Backup; hub e changelog actualizados |

## Checklist de validação

- [ ] Secção 1: Decisão de fonte documentada e sem duplicação entre rules/docs/skills.
- [ ] Secção 2: Apenas um ficheiro canónico por path; excedentes em `Documentation/Backup/` com sufixo `_CONFLITO`.
- [ ] Secção 2: Hub e `CHANGELOG.md` actualizados quando colisão afectar mapa documental.
- [ ] Secção 3: Os 3 critérios de superseded verificados antes de classificar.
- [ ] Secção 3: Documento superseded em `Documentation/Backup/` com rastreio no nome.
- [ ] Sem links órfãos no hub após qualquer operação de arquivo.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
|-------------|----------------|---------------|
| Classificar como superseded sem verificar equivalência de âmbito | Documentos com âmbitos diferentes podem ser ambos válidos | Aplicar os 3 critérios simultâneos da Secção 3 |
| Manter dois ficheiros com o mesmo path canónico final | Viola o princípio de fonte única | Aplicar ordem de desempate da Secção 2 e mover excedente para Backup com `_CONFLITO` |
| Copiar corpo integral de uma skill para um `.mdc` | Duplica conteúdo portátil | Referenciar a skill por nome na rule; não copiar parágrafos longos |

## Métricas de sucesso

- 0 paths canónicos com mais de um ficheiro activo.
- 100% dos documentos classificados como superseded ou CONFLITO têm registo no hub ou no `CHANGELOG.md` documental.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent responsável | `doc-agent-orchestrator` |
| Humano responsável | Tech Lead / Arquiteto |

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `documentation-constitution-policies`; novo prefixo canônico `governance`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem).
