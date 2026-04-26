---
name: documentation-project-bootstrap
description: Inicializa o ecossistema documental em um projeto novo criando a estrutura canônica `Documentation/`, gerando o hub `README_V1.0.md`, criando o `Documentation/Versionamento/CHANGELOG.md` inicial e executando um scan inicial para lacunas (backlog documental). Use quando o usuario iniciar documentação "do zero" ou pedir "começar o padrão de Documentation". Raiz canónica `Documentation/`; se existir `Docs/` ou `docs/` na raiz, renomear para `Documentation/` antes do bootstrap.
model: haiku
thinking: minimal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Project Bootstrap

## Responsabilidade única

Esta skill cria o scaffold inicial de pastas e arquivos de documentação em um projeto novo — ela gera a estrutura `Documentation/`, subpastas por módulo e arquivos `README.md` mínimos. Existe separada de outras skills documentais porque foca exclusivamente no bootstrap (estado zero → estrutura básica), não em preenchimento de conteúdo.

## When to use

- Quando o usuário pedir para **criar documentação do zero** (bootstrap).
- Quando não existir `Documentation/` completo e for necessário inicializar o padrão.
- Quando o usuário pedir "começar o template Documentation", "montar hub e estrutura" ou "gerar documentação inicial".

## When NOT to use

- Projeto já tem `Documentation/` estruturado com conteúdo → usar `documentation-project-scan` para inventariar o que existe.
- Conteúdo existe mas está em local errado ou com naming divergente → usar `documentation-migration-backup` para mover e consolidar com segurança.
- O objetivo é analisar lacunas de qualidade por feature/módulo → usar `documentation-project-feature`.

## Inputs (necessarios)

1. `<versao_inicial>` (ex.: `V1.0`) para o hub e changelog.
2. Estrutura de módulos/áreas iniciais (pode ser lista livre), ex.:
   - `Arquitetura` (temas/areas)
   - `Regras de Negocio` (módulos iniciais)
   - `Esboco_Telas`
   - `Analise` (itens de lacunas, inventários)

## Outputs esperados

1. Pastas canônicas criadas (13 subpastas obrigatórias):
   - `Documentation/README_Vx.y.md`
   - `Documentation/Analise/`
   - `Documentation/Arquitetura/`
   - `Documentation/BancoDados/`
   - `Documentation/Contratos/`
   - `Documentation/Esboco_Telas/`
   - `Documentation/Estrutura/`
   - `Documentation/Mapeamento/`
   - `Documentation/Planejamento/`
   - `Documentation/Regras de Negocio/`
   - `Documentation/Roadmap/`
   - `Documentation/Versionamento/`
   - `Documentation/Backup/`
   - `Documentation/html/` — portal estático obrigatório (`index.html`, `docs-data.js`, `README.md` a partir de **`TEMPLATE_Docs_html_*`** e **`TEMPLATE_Docs_html_README.md`**)
2. Hub `Documentation/README_Vx.y.md` com:
   - versão + data
   - árvore vazia (placeholders) por subpasta
   - seção de "próximas ações / backlog documental" com o que falta
3. `Documentation/Versionamento/CHANGELOG.md` com entrada inicial `[Vx.y]`.
4. Relatório inicial de lacunas gerado via scan:
   - `documentation-project-scan` (ou saída equivalente no corpo da resposta)

## Passo a passo (procedimento)

1. **Criar ou consolidar estrutura `Documentation/`** (se existir `Docs/` ou `docs/` na raiz, renomear para `Documentation/` primeiro)
   - garantir as **13 subpastas obrigatórias** conforme estrutura alvo:

     ```text
     Documentation/
     ├── README_Vx.y.md
     ├── ROTEIROS_CONSOLIDADO.md  (opcional por decisão do projecto)
     ├── LOGICA_DATABASE.md       (opcional por decisão do projecto)
     ├── Analise/
     ├── Arquitetura/
     ├── BancoDados/
     ├── Contratos/
     ├── Esboco_Telas/
     ├── Estrutura/
     ├── Mapeamento/
     ├── Planejamento/
     ├── Regras de Negocio/
     ├── Roadmap/
     ├── Versionamento/
     ├── Backup/
     └── html/
     ```

   - ao criar ficheiros iniciais (hub, changelog, placeholders), **copiar** os **`TEMPLATE_Docs_*`** correspondentes de **`.cursor/Templates/`** (ver `README.md` nessa pasta), ajustar nomes/versão e só depois preencher conteúdo
   - **Na raiz da pasta documental**, opcionalmente criar a partir dos modelos **genéricos** (conforme decisão do projecto):
     - **`ROTEIROS_CONSOLIDADO.md`** ← `TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md` (bootstrap, roteiros de uso, checklist de validação; substituir `{placeholders}`) — **opcional por decisão do projecto**
     - **`LOGICA_DATABASE.md`** ← `TEMPLATE_Docs_LOGICA_DATABASE.md` (lógica de camada de dados para recriação; opcional se o projeto não tiver essa camada — renomear destino se preferir `LOGICA_{Modulo}.md`) — **opcional por decisão do projecto**
   - **Portal HTML (obrigatório):** pasta **`html/`** dentro da pasta documental com **`index.html`**, **`docs-data.js`** e **`README.md`**, copiados de **`TEMPLATE_Docs_html_index.html`**, **`TEMPLATE_Docs_html_docs-data.js`** e **`TEMPLATE_Docs_html_README.md`** (ver `.cursor/Templates/README.md` — secção HTML/JS).
2. **Gerar hub `Documentation/README_Vx.y.md`**
   - incluir versão/data
   - incluir árvore inicial (placeholder) por subpasta
   - incluir seções padrão:
     - "Visão geral do ecossistema documental"
     - "Status por subpasta"
     - "Backlog de documentação"
   - (opcional) link ou nota para **`.cursor/README.md`** onde o repositório lista skills por domínio
3. **Gerar `Documentation/Versionamento/CHANGELOG.md`**
   - adicionar entrada:
     - `## [Vx.y] — AAAA-MM-DD`
     - subseções mínimas: `### Adicionado` (inicialização)
4. **Executar scan inicial de artefatos e lacunas**
   - buscar documentos existentes (mesmo que fora de `Documentation/`)
   - detectar o que já existe vs. o que o template espera
   - produzir lista de lacunas com prioridade/impacto/dependência (ou delegar para `documentation-roadmap-from-docs` para montar o roadmap)

## Dependências (skills prévias)

Nenhuma dependência obrigatória — esta skill é o primeiro passo do ecossistema documental.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
| --- | --- | --- |
| Criar `Documentation/` manualmente sem esta skill | Gera estrutura inconsistente — subpastas faltando, naming divergente, sem hub e sem changelog | Usar esta skill com os inputs corretos para garantir as 13 subpastas e templates canônicos |
| Usar esta skill em projeto que já tem `Documentation/` estruturado | Risco de sobrescrever conteúdo existente e perder artefatos válidos | Executar `documentation-project-scan` primeiro para inventariar; só depois fazer bootstrap complementar |
| Pular criação do portal HTML | Portal `html/` é obrigatório; omiti-lo quebra a navegação estática do ecossistema | Sempre copiar templates `TEMPLATE_Docs_html_*` e criar `html/index.html`, `docs-data.js` e `README.md` |

## Métricas de sucesso

- Estrutura `Documentation/` criada com todas as 13 subpastas obrigatórias — verificável por `ls Documentation/` imediatamente após o bootstrap.
- Pelo menos 1 `README.md` (ou hub `README_Vx.y.md`) presente em cada subpasta criada — verificável por contagem de arquivos.

## Critérios de aceite (bootstrap concluído)

- [ ] Estrutura `Documentation/` canônica existe com **13 subpastas obrigatórias** (Analise, Arquitetura, BancoDados, Contratos, Esboco_Telas, Estrutura, Mapeamento, Planejamento, Regras de Negocio, Roadmap, Versionamento, Backup, html).
- [ ] Hub `Documentation/README_Vx.y.md` existe e contém placeholders por subpasta.
- [ ] `Documentation/Versionamento/CHANGELOG.md` contém entrada `[Vx.y] — <data>`.
- [ ] Portal HTML `Documentation/html/` existe com `index.html`, `docs-data.js` e `README.md`.
- [ ] `ROTEIROS_CONSOLIDADO.md` e `LOGICA_DATABASE.md` na raiz documental: **opcionais por decisão do projecto** — se omitidos, registar a decisão no hub ou changelog.
- [ ] Existe um backlog inicial (mesmo que em texto) apontando o que falta.
- [ ] Se havia documentos pré-existentes fora do padrão, eles foram inventariados no scan inicial (não ignorados).

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `doc-agent-orchestrator` |
| Responsável humano | Desenvolvedor |

## Exemplo de referência canônica

- **Obrigatório neste repositório:** **`.cursor/Templates/`** — `TEMPLATE_Docs_README_Hub.md`, `TEMPLATE_Docs_Changelog.md`, demais `TEMPLATE_Docs_*`.
- **Índice de skills:** **`.cursor/README.md`** (por domínio).
- **Opcional:** `EXEMPLO DE DOCUMENTAÇÃO/Docs/README_V1.5.md` quando existir no ambiente.

---

**Changelog (este arquivo):**

- 2.0.0 (04/04/2026): 13 subpastas obrigatórias (adicionadas BancoDados, Contratos, Estrutura, Mapeamento, Planejamento); `html/` promovido de opcional a obrigatório; `ROTEIROS_CONSOLIDADO.md` e `LOGICA_DATABASE.md` reclassificados como opcionais por decisão do projecto; diagrama de estrutura alvo no procedimento; critérios de aceite actualizados.
- 1.3.2 (27/03/2026): Entrada 1.2.0 clarificada — destino canónico **`Documentation/html/`** para o portal opcional.
- 1.3.1 (27/03/2026): Sem ficheiro de manifesto na raiz; índice de skills em **`.cursor/README.md`**.
- 1.3.0 (27/03/2026): Nome canónico da pasta documental **`Documentation/`** (antes `Docs/`); descrição e passos actualizados; regra de rename antes do bootstrap.
- 1.2.0 (27/03/2026): Pasta opcional **`Documentation/html/`** (alias legado `Docs/html/` / `docs/html/`) — templates **`TEMPLATE_Docs_html_*`** e **`TEMPLATE_Docs_html_README.md`**; outputs e passo 1 actualizados.
- 1.1.0 (27/03/2026): Bootstrap inclui **`ROTEIROS_CONSOLIDADO.md`** e **`LOGICA_DATABASE.md`** na raiz documental, a partir de **`TEMPLATE_Docs_ROTEIROS_CONSOLIDADO.md`** e **`TEMPLATE_Docs_LOGICA_DATABASE.md`** (genéricos); critério de aceite actualizado.
- 1.0.1 (27/03/2026): Bootstrap a partir de **`.cursor/Templates/`**; exemplo de referência actualizado.
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 2.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 2.1.0 (08/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter com thinking e category.
- 2.0.0 (04/04/2026): 13 subpastas obrigatórias; `html/` obrigatório; `ROTEIROS_CONSOLIDADO.md` e `LOGICA_DATABASE.md` opcionais; estrutura alvo no procedimento.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
