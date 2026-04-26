---
name: governance-artifact-inventory
description: Inventário centralizado de artefatos do Providers.2.1.0 — lista binários, documentos, scripts e configurações com versão, localização, owner e status (atual/deprecated/archived).
model: haiku
thinking: normal
category: governance-artifact
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Artifact — Artifact Inventory

## Responsabilidade única

Manter lista atualizada de todos os artefatos do projeto Providers.2.1.0 — binários compilados
(`.dcu`, `.dcp`, `.exe`), documentos (PRD, SPEC, Architecture docs), scripts (SQL, deployment),
configurações (`.ini`, `.json`, `.dpr`, `.lpr`) — com versão, localização, owner e status
(atual/deprecated/archived). Esta skill **não** trata rastreabilidade de requisitos
(→ `governance-artifact-traceability`) nem inventário de dívida técnica
(→ `quality-tech-debt-tracker`).

## When to use

- Ao preparar release de nova versão do Providers.2.1.0.
- Ao auditar artefatos do projeto (segurança, conformidade).
- Ao fazer onboarding de novo membro ou agent.
- Ao verificar se artefatos obsoletos foram removidos corretamente.

## When NOT to use

- Para rastreabilidade requisito ↔ código → usar `governance-artifact-traceability`.
- Para inventário de dívida técnica → usar `quality-tech-debt-tracker`.
- Para mapa de dependências externas → usar `governance-artifact-dependency-map`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Escopo do inventário | Texto | Quais categorias incluir (binários/docs/scripts/configs/todos) |
| Versão do projeto | Texto (SemVer) | Versão de referência do inventário |

## Dependências (skills prévias)

Nenhuma dependência obrigatória.

## Workflow executável

1. **Escanear diretórios** — percorrer a estrutura do projeto e identificar todos os artefatos
   nas categorias selecionadas:
   - `src/` → arquivos fonte (`.pas`, `.pp`, `.inc`)
   - Raiz e subpastas → binários de build (`.dcu`, `.dcp`, `.dproj`, `.lpi`)
   - `Documentation/` → documentos (PRD, SPEC, Architecture, RACI, Changelog)
   - `.cursor/scripts/` → scripts de automação (`.ps1`, `.py`)
   - Raiz → configurações (`.dpr`, `.lpr`, `fpc32.opts`, `fpc64.opts`, `.ini`, `.json`)

2. **Classificar por tipo** — para cada artefato identificado, registrar:
   - Nome e extensão
   - Tipo (binário/fonte/documento/script/configuração)
   - Versão (se aplicável — SemVer ou data de última modificação)
   - Localização (caminho relativo à raiz do projeto)
   - Owner (responsável humano ou módulo)
   - Status: `atual` (em uso ativo), `deprecated` (obsoleto, mantido por compatibilidade),
     `archived` (removido do fluxo ativo, mantido para referência)

3. **Gerar inventário** — montar `Documentation/ArtifactInventory.md` com tabela completa;
   separar seções por tipo de artefato; incluir data de geração e versão do projeto.

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Inventário de artefatos | `Documentation/ArtifactInventory.md` | Markdown com tabela |

### Estrutura obrigatória do inventário

```markdown
# Inventário de Artefatos — Providers.2.1.0 vX.Y.Z

**Gerado em:** YYYY-MM-DD · **Versão do projeto:** X.Y.Z

## Artefatos de Código-Fonte
| Nome | Localização | Módulo/Owner | Status |
|------|-------------|-------------|--------|
| ...  | ...         | ...         | atual  |

## Documentos
| Nome | Localização | Versão | Owner | Status |
|------|-------------|--------|-------|--------|
| ...  | ...         | ...    | ...   | atual  |

## Scripts de Automação
| Nome | Localização | Propósito | Owner | Status |
|------|-------------|-----------|-------|--------|
| ...  | ...         | ...       | ...   | atual  |

## Configurações
| Nome | Localização | Propósito | Owner | Status |
|------|-------------|-----------|-------|--------|
| ...  | ...         | ...       | ...   | atual  |
```

## Checklist de validação

- [ ] Todos os diretórios principais escaneados (src/, Documentation/, .cursor/scripts/, raiz)
- [ ] Todos os artefatos classificados com tipo, versão, localização e status
- [ ] Artefatos com status `deprecated` distinguidos dos `atual`
- [ ] Data de geração e versão do projeto registradas no inventário
- [ ] `Documentation/ArtifactInventory.md` criado/atualizado

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Inventário sem versão do artefato | Impossível saber se o artefato está atualizado | Incluir versão ou data de modificação para todo artefato |
| Listar artefatos deprecated como ativos | Confunde quem usa o inventário; artefatos obsoletos parecem válidos | Separar status `deprecated` de `atual` explicitamente |
| Inventário sem data de atualização | Não se sabe se o inventário está desatualizado | Incluir data de geração no cabeçalho |
| Escanear apenas binários | Documentos e scripts também são artefatos críticos | Incluir todas as categorias no escopo |
| Inventário gerado mas nunca revisado | Fica obsoleto rapidamente | Gerar a cada release e auditar trimestralmente |

## Avaliação de risco

- **Parar e confirmar quando:** encontrar artefato sem owner definido — não catalogar como
  "atual" sem identificar o responsável.
- **Risco baixo:** inventário de documentação apenas.
- **Risco médio:** inventário completo — verificar que artefatos deprecated não estão sendo
  referenciados em documentação ativa.

## Métricas de sucesso

- 100% dos artefatos públicos listados no inventário.
- Status atualizado para cada artefato (nenhum campo vazio).
- Localização de cada artefato verificável (path real no projeto).
- Inventário atualizado a cada release.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão e aprovação | Humano (Tech Lead) |

## Referências

- Rastreabilidade: `governance-artifact-traceability_V1.0.0`
- Dependências externas: `governance-artifact-dependency-map_V1.0.0`
- Dívida técnica: `quality-tech-debt-tracker_V1.0.0`
- Pasta de saída: `Documentation/`
- Política de documentação: `.cursor/skills/documentation-general_rules_V2.0.0/SKILL.md`

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.0.0 (09/04/2026): Skill nova V2 — criada para lacuna governance no plano de migração V2.6.
