---
name: documentation-portal-html
description: Skill para planear e gerar o portal HTML estático em Documentation/html/ (templates TEMPLATE_Docs_html_*), com delegação a outras skills documentation-* e hub Documentation/. NÃO é o agente doc-agent-orchestrator (esse coordena pipelines multi-etapa Documentação/Analise no ficheiro doc-agent-orchestrator_V1.1.4.md).
model: sonnet
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Orchestrator (skill — portal HTML)

## Responsabilidade única

Esta skill é o **ponto de entrada de delegação** para pedidos de documentação técnica baseados
no padrão `Documentation/`. Ela classifica o pedido do usuário, seleciona a skill especialista
correta (bootstrap, roadmap, arquitetura, RNs, portal HTML) e garante que regras transversais
(naming, hub resync, política de backup) sejam aplicadas. Existe separada do agente
`doc-agent-orchestrator` porque seu escopo é o **portal estático** `Documentation/html/` e
o **planejamento** de delegação — não a execução de pipelines multi-etapa de análise de código.

**Distinção obrigatória:** esta **skill** cobre o **portal estático** em **`Documentation/html/`** (ficheiros-modelo `TEMPLATE_Docs_html_*`, checklist em `TEMPLATE_Docs_html_README.md`). O **agente** **`doc-agent-orchestrator_V1.1.4.md`** é o orquestrador de **tarefas documentais multi-etapa** (hub `Documentation/`, migração, `Analise/` / `doc-agent-class-*`, etc.). Ver também a tabela em **`documentation-general_rules`**.

## When NOT to use

- Para coordenar pipelines multi-etapa de análise de código → usar `doc-agent-orchestrator`
- Para documentar classes individuais → usar `documentation-class-analysis-generator`
- Para gerar Overview/Architecture com profundidade técnica → usar `documentation-overview-architecture`
- Para migrar legado com backup → usar `documentation-migration-backup` diretamente
- Para criar/atualizar apenas o hub README → usar `documentation-readme-hub` diretamente

## Dependências (skills prévias)

| Skill | Quando executar antes |
|-------|-----------------------|
| `documentation-project-scan` | Recomendado antes de qualquer delegação para identificar gaps e evitar duplicação |

## When to use

- Quando o usuário pedir qualquer ação de documentação técnica baseada no padrão `Documentation/`.
- Quando o usuário pedir “planejar docs”, “organizar documentação”, “criar/atualizar hub”, “gerar arquitetura/RNs/telas”, “criar roadmap”, “migrar documentação legada” ou “verificar consistência”.

## Inputs

1. `<pedido_usuario>`: descrição do que deve ser documentado (o texto do usuário).
2. `<produto>` (opcional): nome do projeto/produto (usado apenas como placeholder, nunca como parte obrigatória do nome de arquivo).
3. `<versao_docs>` (opcional): versão inicial ou alvo no formato `Vx.y` (ex.: `V1.0`).
4. `<contexto>` (opcional): detalhes técnicos do domínio, públicos-alvo e restrições.
5. `<estruturas_existentes>` (opcional): caminhos relevantes já conhecidos (ex.: `Analise/`, `Arquitetura/`, etc.).
6. `<templates_root>` (opcional): pasta dos ficheiros-modelo — **default:** `.cursor/Templates/` (índice `README.md`).

## Ficheiros-modelo (base física)

- **`.cursor/Templates/`** reúne **`TEMPLATE_*.md`** (e HTML/JS) para **`Analise/`** e **`Documentation/`**.
- **Antes** de redigir artefactos novos do zero, **copiar** o `TEMPLATE_*` adequado (ver **`README.md`** nessa pasta) para o path canónico, renomear conforme skill `documentation-general_rules` (naming conventions) / política do projeto, preencher placeholders — **depois** aplicar o conteúdo operacional da skill especialista.
- O scaffold automático de **`{ClassName}.md`** continua a cargo de **documentation-paste_analysis_unit_class_method**; os modelos em **`.cursor/Templates/`** cobrem entradas **manuais** e **`Documentation/`** (`TEMPLATE_Docs_*`).
- Na **raiz** de **`Documentation/`** (se existir `Docs/` ou `docs/` na raiz, renomear para **`Documentation/`** primeiro), o bootstrap (**documentation-project-bootstrap**) deve criar **`ROTEIROS_CONSOLIDADO.md`** e **`LOGICA_DATABASE.md`** a partir de **`TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md`** e **`TEMPLATE_Docs_LOGICA_DATABASE.md`** (genéricos; renomear o segundo se o domínio não for “database”).
- Pasta **`html/`** (portal estático): **`TEMPLATE_Docs_html_README.md`** + **`TEMPLATE_Docs_html_index.html`** + **`TEMPLATE_Docs_html_docs-data.js`** (ver `.cursor/Templates/README.md`).

## Outputs (o que a resposta deve conter)

1. Um **plano executável** de delegação para skills especialistas (com WHEN/WHAT por skill).
2. Evidência de aplicação de regras transversais:
   - nomenclatura/versão
   - política de idioma
   - atualização do hub resync
   - critérios de superseded/Backup (quando existir migração)
3. Checklist final “pronto para concluir”.

## Passos executáveis

### 1) Classificar o pedido

- Identificar se a solicitação é de:
  - bootstrap do zero
  - scan/gap analysis
  - geração por categoria (hub, arquitetura, RN, telas, análise)
  - roadmap orientado por `Documentation/`
  - migração de legado com Backup
  - update de versionamento/changelog
  - validação/review

### 2) Inicializar insumos (scan)

- Sempre que houver documentação existente ou risco de gaps/duplicação:
  - chamar `documentation-project-scan`
  - usar saída do scan como base para decidir ações `criar` vs `revisar/consolidar` vs `Backup`

### 3) Delegar para skill especialista

De acordo com a classificação do pedido:

- bootstrap: `documentation-project-bootstrap`
- roadmap: `documentation-roadmap-from-docs`
- migração: `documentation-migration-backup`
- hub: `documentation-readme-hub`
- arquitetura: `documentation-architecture`
- overview / architecture quality: `documentation-overview-architecture`
- regras de negócio por módulo (input: `Documentation/Analise/`): `documentation-business-rules` → `doc-agent-rules`
- telas: `documentation-screen-sketches`
- análise index: `documentation-analysis-index`
- versionamento: `documentation-versioning-changelog`
- OpenAPI: `documentation-api-openapi`
- SDLC / runbook / release / segurança / matriz testes: `governance-sdlc-lifecycle`

### 4) Garantir o hub resync (obrigatório)

- Após qualquer alteração/criação de docs:
  - atualizar `Documentation/README_Vx.y.md` conforme mapa final
  - remover referências que apontem para caminhos inexistentes
  - registrar histórico quando mover para `Documentation/Backup/`

### 5) Garantir ausência de duplicação e colisões

- Se houver conflitos de destino canônico:
  - resolver por canonicidade conforme política de colisão (superseded → Backup com `_CONFLITO`)

### 6) Checklist de conclusão

- Incluir checklist final detalhado e não permitir “concluir” sem atender os critérios de qualidade.

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Executar diretamente sem `documentation-project-scan` quando há docs existentes | Gera duplicação ou sobrescreve docs canônicos sem backup | Sempre chamar scan primeiro quando houver `Documentation/` existente |
| Delegar para a skill errada (ex.: usar esta skill para docs de classe) | Resultado não segue padrão da skill especialista | Ver tabela "Passos executáveis §3" e selecionar a skill correta pela categoria do pedido |
| Omitir o hub resync após criação/alteração de docs | Hub fica desatualizado; links quebrados para novos artefatos | Executar `documentation-readme-hub` obrigatoriamente após qualquer criação/move |
| Tratar arquivos superseded como ativos no hub | Confunde leitores; viola política de canonicidade | Mover para `Documentation/Backup/` e remover referência do hub |

## Métricas de sucesso

- Hub `Documentation/README_Vx.y.md` sincronizado após cada operação — zero links para paths inexistentes
- Plano de delegação gerado contém skill correta para cada categoria do pedido (verificar tabela §3)
- Nenhum arquivo duplicado/superseded permanece fora de `Documentation/Backup/` ao final

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Tech Lead / Autor do documento |
| Aprovação final | Desenvolvedor responsável pela área documentada |

## Regras transversais (rules)

Consultar (raiz de `Documentation/`):
- skill `documentation-general_rules` (naming conventions)
- skill `documentation-general_rules` (language policy)
- skill `documentation-readme-hub` (hub resync rules)
- skill `governance-constitution-policies` (superseded-definition)
- skill `governance-constitution-policies` (migration-conflict-resolution)
- skill `governance-constitution-policies` (rules-integration)

Skills especializadas (opcional): `governance-constitution-policies` (subsume superseded-definition, migration-conflict-resolution, cursor-rules-integration).

## Critérios de aceite da documentação gerada

- O hub `Documentation/README_Vx.y.md` está sincronizado com o mapa final.
- Todos os arquivos canônicos estão nos paths esperados.
- Arquivos superseded/duplicados foram movidos para `Documentation/Backup/` (ou classificados como “conflito” e tratados conforme política).
- Não existe duplicação residual no hub.
- A resposta inclui evidências/decisões (tabelas ou listas com campos de decisão).

### Portal HTML (`Documentation/html/`) — conformidade

Quando o projeto mantiver o portal estático, considerar **aceite** apenas se forem atendidos (ver também **`TEMPLATE_Docs_html_README.md`** — secção *Conformidade e referência*):

- Existem `index.html`, `docs-data.js` e `README.md` em `Documentation/html/` (ou `{DocsRaiz}/html/` coerente com a raiz documental).
- Comentários em `docs-data.js` referem o path canónico (`Documentation/html/index.html`), sem texto legado obsoleto (`Docs/html/…` quando a raiz já é `Documentation/`).
- Contrato JS: variáveis globais esperadas pelo `index.html` estão definidas e consistentes com o script de renderização.
- `README.md` local descreve política da pasta e abertura no browser; alterações relevantes registadas em `Documentation/Versionamento/CHANGELOG.md`.
- O hub `Documentation/README_Vx.y.md` menciona `html/` ou `html/README.md` quando o portal for parte do conjunto canónico (evitar índice órfão).

**Exemplo canónico neste repositório:** pasta `Documentation/html/` (estrutura e política já alinhadas).

## Template de saída (resposta)

A resposta deve seguir esta ordem:

1. Resumo executivo (3–6 bullets)
2. Mapa de delegação (tabela: Skill → WHEN → WHAT → entradas/saídas)
3. Regras transversais aplicadas (lista curta com evidências)
4. Checklist final “pronto para concluir”

## Exemplo de referência canônica

- **Ficheiros-modelo:** `.cursor/Templates/` — partilhados na raiz (`TEMPLATE_Docs_*`); templates por skill em `<skill>/templates/` dentro de `.cursor/skills/` (ex.: `documentation-paste_analysis_unit_class_method_V1.1.0/templates/TEMPLATE_Unit_ClassName.md`).
- Quando existir no projeto, usar também o layout de `EXEMPLO DE DOCUMENTAÇÃO/Docs/` como referência adicional.

---

**Changelog (este arquivo):**

- 1.1.5 (02/04/2026): Passo 3 — delegação para **`governance-sdlc-lifecycle`** (SDLC/runbook/release/segurança/matriz testes).
- 1.1.4 (01/04/2026): Título e **frontmatter** — distinção explícita face ao **agente** `doc-agent-orchestrator_V1.1.3.md` (pipelines multi-etapa); esta skill = portal HTML + planeamento `Documentation/`.
- 1.1.3 (27/03/2026): Subsecção **Portal HTML** nos critérios de aceite; referência **`Documentation/html/`**; changelog 1.0.3 clarificado (portal em `Documentation/html/`, não só `Docs/html`).
- 1.1.2 (27/03/2026): Políticas transversais em **`.cursor/Constitution/constitution-*_V1.0.md`** (SSOT); removidas referências só por nome em `Documentation/`.
- 1.1.1 (27/03/2026): Regras transversais com paths explícitos em `Documentation/`; skills especializadas opcionais para as três políticas novas.
- 1.1.0 (27/03/2026): Pasta documental canónica **`Documentation/`** (antes `Docs/`); critérios de aceite e changelog internos actualizados.
- 1.0.3 (27/03/2026): Portal HTML — **`TEMPLATE_Docs_html_README.md`** e par `index.html` / `docs-data.js`; destino canónico **`Documentation/html/`** (antes referido como `Docs/html`).
- 1.0.2 (27/03/2026): Nota sobre **`ROTEIROS_CONSOLIDADO.md`** / **`LOGICA_DATABASE.md`** na raiz documental e templates genéricos correspondentes (bootstrap).
- 1.0.1 (27/03/2026): Input `<templates_root>`; secção **Ficheiros-modelo** — **`.cursor/Templates/`** como base para `Analise/` e pasta documental (`Documentation/`); exemplo de referência actualizado.
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.2.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.2.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking: minimal e category: documentation.
- 1.1.0 (04/04/2026): Renomeada de **`documentation-master-orchestrator`** para **`documentation-portal-html`** — nome reflecte o foco real (portal HTML estático); pasta **`documentation-portal-html_V1.1.0/`**.
- 1.0.3 (02/04/2026): **FileVersion** 1.0.3 — passo 3 com delegação **`documentation-sdlc-lifecycle`**.
- 1.0.2 (01/04/2026): Secção funcional **1.1.4** (skill vs agente); pasta renomeada **`documentation-orchestrator_V1.0.2/`** (sufixo = FileVersion).
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
