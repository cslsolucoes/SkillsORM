---
name: governance-pack-versioning-policy
description: Política de versionamento interno do pack .cursor/ — convenção SemVer por ficheiro, sufixo _V{X.Y.Z} em pastas de skills e agentes, tabela FileVersion em cada artefacto, manifestos por área com SemVer no nome, hub SKILLS_DOCUMENTATION com versão no nome do ficheiro.
model: haiku
thinking: minimal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance — Pack Versioning Policy

Política de **versionamento interno** para tudo o que vive em `.cursor/` (regras, skills, agentes, planos, templates, etc.).

## Responsabilidade única

Esta skill define e aplica a convenção de versionamento SemVer para todos os artefactos do pack `.cursor/`, garantindo que cada ficheiro, pasta de skill, agente e manifesto de área tenha versão rastreável, changelog próprio e nome coerente — eliminando ambiguidade sobre qual versão está activa e quando foi alterada.

## When to use

- Ao criar ou renomear uma pasta de skill, agente ou template em `.cursor/`.
- Ao editar qualquer artefacto `.md`, `.mdc`, `.html` ou `.js` do pack que requeira bump de versão.
- Quando um manifesto de área precisar de ser actualizado após alterações estruturais.
- Ao sincronizar o pack entre projectos via `sync-cursor-pack.ps1`.
- Quando o utilizador perguntar qual convenção de nome ou versão usar para um novo artefacto.

## When NOT to use

- Para versionar ficheiros de código-fonte (`src/`) → usar controlo de versão Git (commits e tags).
- Para gerir versões de dependências externas (pacotes NuGet, npm, OPM) → usar ficheiros de manifesto de pacotes do ecossistema correspondente.
- Para documentar decisões de produto ou architecture records → usar `documentation-architecture` ou `documentation-business-rules`.

## Inputs obrigatórios

| Input | Descrição |
|-------|-----------|
| Tipo de artefacto | skill / agente / rule / template / manifesto / ficheiro avulso |
| Versão actual | SemVer actual (ex.: `1.0.0`) |
| Tipo de mudança | MAJOR / MINOR / PATCH conforme semântica definida nesta skill |
| Nome descritivo | Identificador kebab-case do artefacto (ex.: `governance-pack-versioning-policy`) |

## Dependências (skills prévias)

Nenhuma dependência — esta skill é a política de base referenciada pelas demais.

## Objectivo

- Cada artefacto é **rastreável**: sabe-se quando e porquê mudou.
- A **versão do pacote** resume o conjunto; cada ficheiro mantém o seu **histórico** no próprio documento.

## Regras por tipo de ficheiro

| Tipo | Onde registar |
| ---- | -------------- |
| **Markdown** (`.md`) | Bloco **Changelog (este arquivo):** no final, com entradas `- X.Y.Z (DD/MM/AAAA): descrição.` |
| **Rules Cursor** (`.mdc`) | Idem nos templates genéricos |
| **HTML / JS** (templates) | Comentário no topo: `<!-- internal_file_version: 1.0.0 -->` |
| **Pastas** (`agents/`, `skills/`, `rules/`, `Templates/`, etc.) | Manifesto **`{area}-pack-manifest_V{MAJOR}.{MINOR}.{PATCH}.md`** — o **nome do ficheiro** = valor **`FolderVersion`** no corpo. **Skills:** uma pasta por skill **`<identificador>_V{MAJOR}.{MINOR}.{PATCH}/`** com **`SKILL.md`** — o **sufixo da pasta** = FileVersion. |

## Semântica sugerida (Semantic Versioning por ficheiro)

- **MAJOR:** mudança incompatível de contrato ou estrutura.
- **MINOR:** novo conteúdo ou secção, retrocompatível.
- **PATCH:** correcções, clarificações, links.

## Workflow executável

1. Identificar o tipo de artefacto e a versão actual.
2. Classificar a mudança como MAJOR / MINOR / PATCH.
3. Calcular nova versão SemVer.
4. Actualizar o bloco **Versão interna** dentro do ficheiro.
5. Adicionar entrada no **Changelog** do ficheiro.
6. Renomear a pasta (se skill ou agente) para reflectir a nova versão.
7. Actualizar o manifesto da área (`{area}-pack-manifest_V*.md`) com nova `FolderVersion`.
8. Correr `bootstrap-mirror-symlinks.ps1 -ValidateOnly` para verificar coerência dos espelhos.

## Sincronização de espelhos

Os espelhos (`.claude/`, `.vscode/`, `.continue/`, `.opencode/`) são criados por **ligações simbólicas** via o script **bootstrap-mirror-symlinks.ps1**. Requer privilégios de Administrador ou Modo de Programador do Windows.

## Outputs obrigatórios

| Output | Descrição |
|--------|-----------|
| Versão actualizada no ficheiro | Bloco `FileVersion` reflecte nova versão SemVer |
| Entrada de changelog | Linha `- X.Y.Z (DD/MM/AAAA): descrição` adicionada |
| Pasta renomeada (se aplicável) | Sufixo `_VX.Y.Z` da pasta coincide com FileVersion do `SKILL.md` |
| Manifesto de área actualizado | `FolderVersion` no manifesto reflecte estado actual da pasta |

## Checklist de validação

- [ ] FileVersion no ficheiro coincide com sufixo da pasta (para skills/agentes).
- [ ] Entrada de changelog adicionada com data e descrição.
- [ ] Manifesto da área actualizado com nova `FolderVersion`.
- [ ] `bootstrap-mirror-symlinks.ps1 -ValidateOnly` executado sem erros.
- [ ] Sem dois ficheiros com a mesma versão SemVer no mesmo path canónico.
- [ ] READMEs sem versão no nome do ficheiro.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
|-------------|----------------|---------------|
| Editar conteúdo sem fazer bump de versão | Impossibilita rastreabilidade | Sempre calcular e aplicar nova SemVer após qualquer edição de conteúdo |
| Pasta com sufixo `_V1.0.0` mas FileVersion `1.1.0` no SKILL.md | Dessincronia entre pasta e conteúdo | Renomear pasta para coincidir com FileVersion do SKILL.md |
| Manifesto de área com `FolderVersion` desactualizado | Inventário de artefactos desactualizado | Actualizar `FolderVersion` e nome do ficheiro de manifesto após cada mudança estrutural |

## Avaliação de risco

- **Risco alto:** Dessincronia pasta/FileVersion após edição — agentes referem versão errada.
- **Risco médio:** Manifesto de área esquecido — inventário inconsistente.
- **Risco baixo:** Symlinks quebrados após renomear pasta — correr `bootstrap-mirror-symlinks.ps1 -ValidateOnly`.

## Métricas de sucesso

- 100% das skills e agentes em `.cursor/` com pasta cujo sufixo coincide com FileVersion do ficheiro principal.
- 0 manifestos de área com `FolderVersion` desactualizado.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent responsável | `doc-agent-orchestrator` |
| Humano responsável | Tech Lead |

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `pack-versioning-policy`; novo prefixo canônico `governance`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem).
