---
name: version-migration-assistant
description: Gera guias de migração passo a passo para versões com breaking changes, incluindo scripts de transformação de código, checklist de validação e rollback plan, para que consumers atualizem com segurança e previsibilidade.
model: sonnet
thinking: extended
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Produzir guias de migração acionáveis para consumers afetados por breaking changes — não classificar breaking changes (use `version-breaking-change-guard`) nem deprecar APIs (use `version-deprecation-policy`).

## When to use

- Ao emitir uma versão MAJOR com breaking changes.
- Quando uma API, interface ou contrato é removido após período de deprecação.
- Quando consumers precisam de instruções explícitas para atualizar.

## When NOT to use

- Para detectar se uma mudança é breaking → use `version-breaking-change-guard`.
- Para deprecar APIs → use `version-deprecation-policy`.
- Para gerar release notes → use `version-release-notes`.

## Inputs obrigatórios

1. Lista de breaking changes da nova versão (de `version-breaking-change-guard`).
2. Versão de origem (consumers estão em vX.Y.Z).
3. Versão de destino (nova versão com breaking changes).

## Dependências (skills prévias)

- `version-breaking-change-guard` — lista de breaking changes identificados.
- `version-deprecation-policy` — lista de APIs deprecadas que serão removidas.

## Workflow executável

1. **Inventariar breaking changes** (APIs removidas, assinaturas alteradas, comportamentos modificados).
2. **Para cada breaking change:**
   a. Descrever o que mudou (antes/depois).
   b. Explicar por que mudou.
   c. Fornecer exemplo de código: antes → depois.
   d. Identificar automação disponível (codemod, script de migração).
3. **Gerar checklist de migração** ordenado por dependência.
4. **Documentar rollback plan:** como reverter se a migração falhar.
5. **Estimativa de esforço** por breaking change.
6. **Publicar** junto com o release da nova versão.

## Outputs obrigatórios

- Guia de migração `MIGRATION_vX_to_vY.md` com:
  - Sumário de breaking changes.
  - Instruções passo a passo por breaking change.
  - Exemplos antes/depois.
  - Checklist de validação pós-migração.
  - Rollback plan.

## Checklist de validação

- [ ] Todos os breaking changes cobertos no guia.
- [ ] Exemplos antes/depois presentes para cada breaking change.
- [ ] Checklist de validação pós-migração incluído.
- [ ] Rollback plan documentado.
- [ ] Guia publicado junto com o release.
- [ ] Consumers notificados da disponibilidade do guia.

## Anti-padrões

- Guia de migração publicado depois do release — consumers ficam bloqueados.
- Sem exemplos de código — instruções abstratas não são acionáveis.
- Sem rollback plan — consumers têm medo de migrar.
- Cobrir apenas alguns breaking changes — guia incompleto gera falsa confiança.

## Avaliação de risco

| Cenário | Risco | Mitigação |
|---------|-------|-----------|
| Breaking change não documentado | Alto | Revisar lista com `version-breaking-change-guard` antes de publicar |
| Consumer migra para versão errada | Médio | Especificar versão de origem e destino claramente |
| Rollback não testado | Médio | Validar rollback em ambiente de staging |

## Métricas de sucesso

- 100% dos breaking changes documentados no guia.
- Tempo médio de migração dos consumers dentro do estimado.
- Zero suporte tickets sobre "como migrar" após publicação do guia.

## Responsável principal

`doc-agent-orchestrator` — redige o guia com base nos inputs dos agentes técnicos.

## Referências

- `version-breaking-change-guard_V1.0.0/SKILL.md`
- `version-deprecation-policy_V1.0.0/SKILL.md`
- `version-release-notes_V1.0.0/SKILL.md`
- `governance-release-management_V1.0.0/SKILL.md`

## Versão interna (ficheiro)

| Campo       | Valor |
|-------------|-------|
| FileVersion | 1.0.0 |

## Changelog (este arquivo)

- 1.0.0 (09/04/2026): Criação direta em V2 — Onda F.
