---
name: version-master-orchestrator
description: Ponto de entrada para todos os workflows de versionamento — semver, breaking changes, deprecação, guias de upgrade e notas de release. Coordena as 5 skills da família version-*.
model: sonnet
thinking: minimal
category: version
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Version Master Orchestrator

## Responsabilidade única

Ponto de entrada único para qualquer tarefa de versionamento de produto: calcular bumps SemVer, proteger APIs públicas contra breaking changes, formalizar deprecações, guiar upgrades entre versões e gerar notas de release estruturadas. Esta skill não executa as tarefas diretamente — seleciona a skill especialista correta e define a sequência de execução.

## When to use

- "nova versão", "release", "breaking change", "deprecar", "notas de release", "semver", "upgrade", "migração de versão", "changelog"
- Antes de qualquer refactor que altere API pública ou contratos entre módulos
- Ao preparar um release formal do produto

## When NOT to use

- Para documentação técnica canónica → `documentation-master-orchestrator`
- Para gestão de processos de release → `governance-master-orchestrator` (SDLC)
- Para refatoração segura → `quality-master-orchestrator`

## Skills coordenadas (5)

| Skill | Responsabilidade | Quando invocar |
|-------|-----------------|----------------|
| `version-semver-product` | Calcular bump (major/minor/patch), estruturar versão | Ao planejar qualquer nova versão |
| `version-breaking-change-guard` | Detectar e documentar breaking changes antes de refactor público | Antes de qualquer refactor que afete API pública |
| `version-deprecation-policy` | Formalizar deprecação com aviso, prazo e alternativa | Ao marcar feature/API como deprecated |
| `version-migration-assistant` | Guiar upgrade entre versões (passo a passo, incompatibilidades) | Ao documentar ou executar upgrade entre versões |
| `version-release-notes` | Gerar notas de release estruturadas a partir do histórico | Ao fechar um release |

## Sequência canônica de release

```
1. version-breaking-change-guard   ← identificar breaking changes
2. version-semver-product          ← calcular bump correto (major se BC, minor se feature, patch se fix)
3. version-deprecation-policy      ← formalizar itens deprecated (se houver)
4. version-migration-assistant     ← documentar guia de upgrade
5. version-release-notes           ← gerar notas de release finais
```

## Matriz de decisão

| Cenário | Skill |
|---------|-------|
| Calcular se bump deve ser major, minor ou patch | `version-semver-product` |
| Verificar se um refactor quebra contratos de API | `version-breaking-change-guard` |
| Marcar método/feature/módulo como deprecated | `version-deprecation-policy` |
| Documentar o que mudou para quem vai atualizar | `version-migration-assistant` |
| Gerar o CHANGELOG ou release notes formatado | `version-release-notes` |
| Release completo (todas as etapas) | Sequência canônica acima |

## Outputs esperados

| Skill | Output canônico |
|-------|----------------|
| `version-breaking-change-guard` | `TEMPLATE_breaking_change_impact.md` |
| `version-release-notes` | `TEMPLATE_release_notes.md` |
| `version-deprecation-policy` | `TEMPLATE_deprecation_notice.md` |
| `version-migration-assistant` | `TEMPLATE_migration_guide.md` |

Templates em `.cursor/skills/version-master-orchestrator_V1.0.0/templates/`.

## Anti-padrões

| Anti-padrão | Como corrigir |
|-------------|---------------|
| Fazer bump de versão sem checar breaking changes | Sempre rodar `version-breaking-change-guard` antes de `version-semver-product` |
| Deprecar sem prazo ou alternativa documentada | Usar `version-deprecation-policy` — aviso, prazo e alternativa são obrigatórios |
| Gerar release notes sem guia de upgrade | Para breaking changes, `version-migration-assistant` é pré-requisito das release notes |

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (11/04/2026): Criação — skill orquestradora da família `version-*` (5 skills).
- 1.1.0 (24/04/2026): Rename E5a — `version-master-orchestrator` -> `version-master-orchestrator`. Motivo: diferenciar master-orchestrator de sub-orchestrators (regra N3 do plano de refactor).