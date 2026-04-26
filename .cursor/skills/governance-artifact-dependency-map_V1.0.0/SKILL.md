---
name: governance-artifact-dependency-map
description: Mapa de dependências externas do Providers.2.1.0 — engines de banco (FireDAC, UniDAC, Zeos, SQLdb), componentes VCL/FMX e packages FPC OPM, com versão em uso, versão mais recente, status (ativa/deprecated/vulnerável) e risco.
model: sonnet
thinking: normal
category: governance-artifact
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance Artifact — Dependency Map

## Responsabilidade única

Manter mapa atualizado de todas as dependências externas do Providers.2.1.0: engines de banco de dados
(FireDAC, UniDAC, Zeos, SQLdb), componentes VCL/FMX, packages FPC OPM e quaisquer outras
bibliotecas de terceiros — com versão em uso, versão mais recente disponível, status
(ativa/deprecated/vulnerável) e nível de risco. Esta skill **não** cobre inventário de artefatos
internos (→ `governance-artifact-inventory`) nem avalia breaking change em API interna
(→ `version-breaking-change-guard`).

## When to use

- Ao avaliar se uma dependência deve ser atualizada antes de release.
- Ao auditar segurança das dependências externas.
- Ao preparar release — verificar que nenhuma dependência vulnerável está em uso.
- Ao onboarding de novo membro — apresentar ecossistema de dependências.

## When NOT to use

- Para inventário de artefatos internos do projeto → usar `governance-artifact-inventory`.
- Para avaliar breaking change em API pública do Providers.2.1.0 → usar `version-breaking-change-guard`.
- Para rastreabilidade de requisitos → usar `governance-artifact-traceability`.

## Inputs obrigatórios

| Input | Tipo | Descrição |
|-------|------|-----------|
| Escopo de dependências | Texto | Quais categorias incluir (engines/componentes/OPM/todos) |
| Versão do projeto | Texto (SemVer) | Versão de referência do mapa |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-artifact-inventory_V1.0.0` | Inventário base para identificar dependências referenciadas |

## Workflow executável

1. **Listar dependências** — identificar todas as dependências externas em uso:
   - Engines de banco: FireDAC (Delphi built-in), UniDAC (DevArt), Zeos (open-source),
     SQLdb (FPC built-in)
   - Componentes VCL/FMX: bibliotecas de terceiros referenciadas no `.dpr`/`.lpr`
   - Packages FPC OPM: packages instalados via Online Package Manager do Lazarus
     (caminho padrão: `D:\fpc\config_lazarus\onlinepackagemanager\packages`)
   - Outras bibliotecas: arquivos `.dcu`, `.dcp` externos não pertencentes ao projeto

2. **Verificar versões** — para cada dependência listada, registrar:
   - Versão em uso no projeto (extraída de configuração, header ou release notes)
   - Versão mais recente disponível (verificar release notes do fornecedor)
   - Data da última verificação

3. **Classificar status e risco** — atribuir status a cada dependência:
   - `ativa`: versão suportada, sem vulnerabilidades conhecidas, atualização não urgente
   - `desatualizada`: versão em uso é anterior à atual; atualização recomendada
   - `deprecated`: fornecedor não mantém mais; plano de substituição necessário
   - `vulnerável`: vulnerabilidade de segurança conhecida; atualização urgente
   - Atribuir nível de risco: `baixo` / `médio` / `alto` / `crítico`

## Outputs obrigatórios

| Output | Localização | Formato |
|--------|-------------|---------|
| Mapa de dependências | `Documentation/DependencyMap.md` | Tabela Markdown |

### Estrutura obrigatória do mapa

```markdown
# Mapa de Dependências Externas — Providers.2.1.0

**Gerado em:** YYYY-MM-DD · **Versão do projeto:** X.Y.Z

## Engines de Banco de Dados
| Dependência | Versão em uso | Versão atual | Status | Risco | Notas |
|-------------|--------------|--------------|--------|-------|-------|
| FireDAC     | built-in RAD | built-in RAD | ativa  | baixo | Delphi only |
| UniDAC      | x.y.z        | x.y.z+1      | desatualizada | médio | Atualizar antes da v3.0 |
| Zeos        | x.y.z        | x.y.z        | ativa  | baixo | Open-source |
| SQLdb       | built-in FPC | built-in FPC | ativa  | baixo | FPC only |

## Componentes VCL/FMX
| Dependência | Versão em uso | Versão atual | Status | Risco | Notas |
|-------------|--------------|--------------|--------|-------|-------|
| ...         | ...          | ...          | ...    | ...   | ...   |

## Packages FPC OPM
| Dependência | Versão em uso | Versão atual | Status | Risco | Notas |
|-------------|--------------|--------------|--------|-------|-------|
| ...         | ...          | ...          | ...    | ...   | ...   |

## Ações pendentes
| Dependência | Ação requerida | Responsável | Prazo |
|-------------|---------------|-------------|-------|
| ...         | ...           | ...         | ...   |
```

## Checklist de validação

- [ ] Todas as engines de banco mapeadas (FireDAC, UniDAC, Zeos, SQLdb)
- [ ] Todos os componentes VCL/FMX externos listados
- [ ] Todos os packages FPC OPM listados
- [ ] Versão em uso registrada para cada dependência
- [ ] Status classificado (ativa/desatualizada/deprecated/vulnerável) para cada item
- [ ] Nível de risco atribuído para cada dependência
- [ ] Dependências vulneráveis com ação urgente registrada
- [ ] `Documentation/DependencyMap.md` criado/atualizado

## Anti-padrões

| Anti-padrão | Por que é errado | Como corrigir |
|-------------|-----------------|---------------|
| Dependência sem versão explícita | Impossível saber se está desatualizada ou vulnerável | Registrar versão exata para toda dependência, mesmo as built-in |
| Mapa desatualizado | Status e versão incorretos levam a decisões erradas | Atualizar o mapa a cada release e após qualquer update de dependência |
| Dependência vulnerável não marcada | Vulnerabilidade não sinalizada permanece em uso | Verificar status de segurança explicitamente no passo 3 |
| Engines não suportadas faltando no mapa | Lacuna na visibilidade de dependências críticas | Incluir as 4 engines canônicas (FireDAC, UniDAC, Zeos, SQLdb) obrigatoriamente |
| Ações pendentes sem responsável e prazo | Dependências vulneráveis ficam sem tratamento | Toda ação pendente com responsável humano e prazo explícito |

## Avaliação de risco

- **Parar e confirmar quando:** encontrar dependência com status `vulnerável` — não publicar
  release sem tratar ou documentar decisão explícita de aceitar o risco.
- **Parar e confirmar quando:** dependência com status `deprecated` — registrar plano de
  substituição com responsável e prazo antes de prosseguir.
- **Risco baixo:** engines built-in (FireDAC, SQLdb) — versão amarrada à ferramenta.
- **Risco alto:** componentes de terceiros com licença comercial (UniDAC) — verificar
  compatibilidade de versão com suporte ativo.

## Métricas de sucesso

- 100% das dependências externas mapeadas (nenhuma dependência sem entrada no mapa).
- Status de segurança verificado por release — nenhuma vulnerabilidade ignorada.
- Zero dependências `vulnerável` sem ação pendente registrada.
- Mapa atualizado a cada release e revisado trimestralmente.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent executor | `dev-agent-orchestrator` |
| Revisão e aprovação | Humano (Tech Lead) |

## Referências

- Inventário de artefatos: `governance-artifact-inventory_V1.0.0`
- Breaking change: `version-breaking-change-guard_V1.0.0`
- Release: `governance-release-management_V1.0.0`
- Caminho padrão OPM: `D:\fpc\config_lazarus\onlinepackagemanager\packages`
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
