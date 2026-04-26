---
name: version-release-notes
description: Gera release notes estruturadas a partir do changelog e dos commits da release, organizando por categoria (breaking changes, novas features, correções, deprecações) com linguagem orientada ao consumer.
model: haiku
thinking: normal
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Transformar dados técnicos (changelog, commits, tickets) em release notes legíveis e acionáveis para consumers — não classificar versões (use `version-semver-product`) nem gerar guias de migração (use `version-migration-assistant`).

## When to use

- Ao publicar qualquer versão (PATCH, MINOR ou MAJOR).
- Ao comunicar uma release para stakeholders não-técnicos.
- Para popular changelogs públicos (GitHub Releases, npm, etc.).

## When NOT to use

- Para classificar se uma mudança é breaking → use `version-breaking-change-guard`.
- Para instruções de migração detalhadas → use `version-migration-assistant`.
- Para deprecar APIs → use `version-deprecation-policy`.

## Inputs obrigatórios

1. Changelog interno da versão (entradas técnicas).
2. Lista de commits ou PRs incluídos na release.
3. Público-alvo (developers / end-users / both).

## Dependências (skills prévias)

- `version-semver-product` — confirmar versão e tipo (PATCH/MINOR/MAJOR).
- `version-breaking-change-guard` — lista de breaking changes para seção prioritária.

## Workflow executável

1. **Coletar:** changelog interno + commits + tickets fechados.
2. **Classificar por categoria:**
   - `## Breaking Changes` — obrigatório em versões MAJOR; link para migration guide.
   - `## New Features` — funcionalidades adicionadas (MINOR+).
   - `## Bug Fixes` — correções incluídas.
   - `## Deprecations` — APIs/comportamentos marcados como deprecated.
   - `## Improvements` — melhorias de performance, UX, DX.
   - `## Internal` — mudanças não visíveis ao consumer (opcional, para transparência).
3. **Adaptar linguagem** ao público-alvo (técnica para devs, funcional para end-users).
4. **Incluir links** para PRs, tickets e migration guide onde aplicável.
5. **Revisão:** checar que Breaking Changes têm link para `MIGRATION_vX_to_vY.md`.

## Outputs obrigatórios

- Release notes em markdown com categorias ordenadas (Breaking Changes primeiro se existirem).
- Versão e data no cabeçalho.
- Link para migration guide se versão MAJOR.

## Checklist de validação

- [ ] Versão e data no cabeçalho.
- [ ] Breaking Changes listados primeiro (se houver) com link para migration guide.
- [ ] Cada item tem referência ao PR ou ticket.
- [ ] Linguagem adequada ao público-alvo.
- [ ] Sem jargão interno que consumers não entendam.
- [ ] Seção de Deprecations presente se alguma API foi deprecada.

## Anti-padrões

- Release notes sem categorização — consumers não sabem o que é urgente.
- Breaking changes enterrados no meio de bug fixes — consumers não percebem.
- Linguagem técnica para end-users — inacessível.
- Release sem link para migration guide quando há breaking changes.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Breaking change não documentado nas release notes | Alto | Cruzar com lista de `version-breaking-change-guard` |
| Consumer ignora breaking changes | Médio | Seção Breaking Changes no topo, formatação destacada |

## Métricas de sucesso

- Release notes publicadas antes ou junto com o artefato.
- Zero suporte tickets do tipo "o que mudou nessa versão".
- Breaking changes com migration guide linkado em 100% das versões MAJOR.

## Responsável principal

`doc-agent-orchestrator` — coordena com agentes técnicos para coletar inputs e revisar conteúdo.

## Referências

- `version-semver-product_V1.0.0/SKILL.md`
- `version-breaking-change-guard_V1.0.0/SKILL.md`
- `version-migration-assistant_V1.0.0/SKILL.md`
- `governance-release-management_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.
