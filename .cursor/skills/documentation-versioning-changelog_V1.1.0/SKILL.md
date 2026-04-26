---
name: documentation-versioning-changelog
description: Atualiza o changelog documental em `Documentation/Versionamento/CHANGELOG.md` com entradas formatadas, registrando inicializações, migrações, revisões e rollbacks de forma rastreável.
model: haiku
thinking: normal
category: documentation
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Documentation Versioning & Changelog

## Responsabilidade única

Esta skill é responsável exclusivamente por registrar no changelog documental (`Documentation/Versionamento/CHANGELOG.md`) todas as alterações relevantes do ecossistema de documentação — criações, migrações, revisões, rollbacks e arquivamentos. Ela garante rastreabilidade cronológica das versões documentais no formato padronizado do projeto, usando o template canônico como base quando o arquivo ainda não existe. Não realiza movimentação de arquivos, atualização do hub nem análise de lacunas — apenas registra o que já ocorreu em outras skills.

## Regra de exclusividade da pasta `Documentation/Versionamento/`

**INVARIANTE:** `Documentation/Versionamento/` contém **exclusivamente** o ficheiro `CHANGELOG.md`. Nenhum outro artefato (release notes, migration guides, technical briefs, upgrade notes, docs `ParametersORM_Changes_*.md`, `*_Upgrade_*.md`, `RELEASE_NOTES_*.md`, `MIGRATION_*.md`, etc.) deve ser criado nesta pasta.

Toda informação versionada — guia de migração, matrizes de compatibilidade, exemplos antes/depois, passos de upgrade de schema, rollback plan — deve ser **inline na entrada `## [Vx.y] — DD/MM/AAAA`** do próprio CHANGELOG, usando as subsecções `### Adicionado`, `### Alterado`, `### Corrigido`, `### Removido` e, quando necessário, blocos auxiliares dentro da mesma entrada (por exemplo: `### Breaking change -- rename ...`, tabelas Markdown com antes/depois, snippets SQL de migração).

Se o conteúdo técnico detalhado de uma release tiver volume incompatível com uma entrada de changelog concisa, as alternativas corretas **não** envolvem criar ficheiros em `Versionamento/`:

- **Análise da unit/classe afetada** → `Documentation/Analise/<Modulo>/<ClassName>.md` (skill `documentation-class-analysis-generator`).
- **Documentação arquitetural** → `Documentation/Arquitetura/<nome>.md` (skill `documentation-architecture`).
- **Regra de negócio** → `Documentation/Regras de Negocio/RN-MXX/...` (skill `documentation-business-rules`).

Referenciar esses documentos a partir da entrada do CHANGELOG (nunca o inverso).

## When NOT to use

- Quando o objetivo for mover ou reorganizar arquivos de documentação — usar `documentation-migration-backup`.
- Quando for necessário atualizar o índice/hub de documentos — usar `documentation-readme-hub`.
- Quando for necessário criar um novo documento de conteúdo (arquitetura, RN, análise) — usar a skill específica do tipo.
- Quando ainda não ocorreu nenhuma alteração no ecossistema — o changelog só registra ações já realizadas.
- Quando o registro for de changelog de código-fonte (não documental) — usar controle de versão Git, não esta skill.
- Quando for necessário criar um release notes / migration guide / upgrade notes autónomo → **proibido em `Versionamento/`** (ver "Regra de exclusividade" acima). Integrar o conteúdo como entrada inline do CHANGELOG, ou usar skills arquiteturais/análise para conteúdo que exceda o escopo de changelog.

## When to use

- Quando o ecossistema documental foi alterado (criação/revisão/migração) e for necessário registrar versionamento.
- Como parte final de roadmap/migração/bootstrap/review.

## Dependências (skills prévias)

| Skill | Quando executar antes |
| --- | --- |
| `documentation-migration-backup` | Quando houver movimentação de arquivos — registrar no changelog após a migração |
| `documentation-readme-hub` | Quando o hub foi atualizado — registrar a sincronização no changelog |

## Inputs

1. `<versao_docs>`: `Vx.y` do release documental.
2. `<acao>`: lista de ações ocorridas (ex.: criou RN, migrou docs, consolidou duplicatas, rollback).
3. `<evidencias>`: quais arquivos e destinos foram impactados (paths).
4. `<data>`: data no formato AAAA-MM-DD (ou deixar placeholder).

## Outputs

- `Documentation/Versionamento/CHANGELOG.md` atualizado no formato padrão.
- Registro consistente com movimentações para `Documentation/Backup/`.

**Base (ficheiro-modelo):** se o ficheiro não existir, criar a partir de **`templates/TEMPLATE_Docs_Changelog.md`**.

## Passos executáveis

1. Garantir que o arquivo alvo existe (usar **`templates/TEMPLATE_Docs_Changelog.md`** como ponto de partida se for criação inicial).
2. Inserir/atualizar entrada `## [Vx.y] — AAAA-MM-DD`.
3. Preencher subseções:
   - `### Adicionado`
   - `### Alterado`
   - `### Removido / Movido para Backup`
4. Para qualquer mover para Backup:
   - registrar `origem → Documentation/Backup/<nome>`
5. Se nenhum item ocorreu em alguma subseção:
   - usar `- N/A` (ou manter seção vazia conforme preferência do projeto) mantendo consistência.

## Critérios de aceite

- Formato do changelog segue `docs-changelog-format.md`.
- Entradas incluem evidência (paths) quando aplicável.
- Versionamento e `_Vx.y` do hub/doc estão coerentes.

## Regras transversais

- Consultar `docs-changelog-format.md`.
- Consultar skill `documentation-readme-hub` (hub resync rules) para refletir mapa final.

## Template de saída (arquivo)

- Seguir exatamente o bloco:
  - `## [Vx.y] — AAAA-MM-DD`
  - `### Adicionado`
  - `### Alterado`
  - `### Removido / Movido para Backup`

## Exemplo de referência canônica

- **`templates/TEMPLATE_Docs_Changelog.md`**
- `EXEMPLO DE DOCUMENTAÇÃO/Docs/Versionamento/CHANGELOG.md` (quando existir)

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
| --- | --- | --- |
| Registrar ações futuras (planejadas) no changelog | Changelog documenta o que aconteceu, não o que vai acontecer | Usar roadmap/backlog para planejamento; changelog somente pós-execução |
| Criar entrada sem paths de evidência | Impossível rastrear o que foi afetado em auditorias futuras | Sempre incluir paths de origem e destino nos itens de movimentação |
| Usar versão de changelog (`Vx.y`) desalinhada com o hub | Gera inconsistência entre CHANGELOG e README_Vx.y.md | Verificar a versão ativa do hub antes de criar a entrada |
| Omitir subseção `N/A` quando não houve itens | Ambiguidade — leitor não sabe se foi esquecido ou não ocorreu | Sempre usar `- N/A` em subseções sem itens |
| Criar ficheiros adicionais em `Documentation/Versionamento/` (ex.: `*_Changes_*.md`, `*_Upgrade_*.md`, `RELEASE_NOTES_*.md`, `MIGRATION_*.md`) | Quebra a invariante da pasta (só `CHANGELOG.md`) e fragmenta a rastreabilidade entre múltiplos documentos paralelos | Incorporar o conteúdo como blocos inline na entrada `## [Vx.y]` do CHANGELOG (tabelas antes/depois, snippets SQL, matrizes, rollback). Para conteúdo técnico volumoso que exceda o escopo, usar `Documentation/Analise/`, `Documentation/Arquitetura/` ou `Documentation/Regras de Negocio/` e referenciar a partir do CHANGELOG |

## Métricas de sucesso

- Cada alteração documental relevante tem exatamente uma entrada no CHANGELOG com data, versão e paths afetados.
- Nenhuma entrada contém items sem evidência (path ou referência verificável).
- A versão `Vx.y` do CHANGELOG está coerente com a versão do hub `Documentation/README_Vx.y.md`.

## Responsável principal

| Papel | Quem |
| --- | --- |
| Agent executor | `doc-agent-orchestrator` |
| Revisão humana | Responsável pela documentação do projeto |
| Aprovação final | Usuário / tech lead |

---

**Changelog (este arquivo):**

- 1.0.1 (27/03/2026): Base física **`templates/TEMPLATE_Docs_Changelog.md`**; passo 1 alinhado.
- 1.0.0 (27/03/2026): Versão inicial publicada neste repositório.
---

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog (este arquivo)
- 1.2.0 (23/04/2026): Adicionada secção "Regra de exclusividade da pasta `Documentation/Versionamento/`" tornando explícito que só `CHANGELOG.md` pertence à pasta; novo anti-padrão "ficheiros adicionais em Versionamento/"; cláusula extra em `When NOT to use` redirecionando release notes / migration guides / upgrade notes para conteúdo inline no CHANGELOG ou para `Analise/`, `Arquitetura/`, `Regras de Negocio/`.
- 1.1.0 (09/04/2026): Migração V2 — adicionadas seções Responsabilidade única, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal; frontmatter expandido com thinking e category.
- 1.0.1 (30/03/2026): Rubrica de versionamento interno (política: `.cursor/VERSION.md`).
- 1.0.0 (30/03/2026): Versionamento interno inicial (pacote `.cursor`).
