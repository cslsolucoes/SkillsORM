# Plano de Absorção — `delphi-dev-plugin` → pack `.cursor/`

**Versão:** 1.0.0 · **Data:** 24/04/2026
**Plugin fonte:** `E:\SkillsORM\delphi-dev-plugin\` (versão 1.4.0)
**Destino:** `.cursor/skills/`, `.cursor/agents/`, `.cursor/commands/`
**Aprovado por:** _(aguardando aprovação explícita)_

---

## 0. Resumo executivo

O plugin `delphi-dev-plugin` contém artefatos complementares ao pack — focados em workflow
de desenvolvimento (auditoria, SPEC, escrita, testes, padrões) que **não existem** no pack atual.
A absorção complementa o pack sem duplicar, eliminando a dependência de instalação separada do plugin.

| Tipo | Qtd. plugin | Ação | Resultado no pack |
|---|---|---|---|
| Skills | 6 | 5 novas + 1 enriquecimento | +5 skills ativas |
| Agents | 4 | 4 novos | +4 agents |
| Commands | 7 | 5 novos + 2 análise | +5 commands |
| Rules | 0 | — | — |
| **Total** | **17** | — | **+14 artefatos** |

---

## 1. Inventário completo do plugin

### Skills (6)

| Nome plugin | Responsabilidade | `references/` |
|---|---|---|
| `delphi-laudo` | Laudo técnico completo de projetos Delphi | ✅ 6 arquivos (estrutura-laudo.md/en, code-smells, clean-code, estimativas, style-guide, tecnologias) |
| `delphi-spec` | Geração de SPEC a partir do código-fonte | ✅ 2 arquivos (spec-template.md/en) |
| `delphi-standards` | Padrões de codificação Delphi (Style Guide) | ✅ 5 arquivos (classes-structure, component-prefixes, forbidden-commands, formatting, naming-conventions) |
| `delphi-testes` | Testes DUnitX, modo explícito + automático | ✅ 1 arquivo (dunitx-patterns) |
| `delphi-write` | Escrita de código Delphi padronizado | ❌ sem references |
| `delphi-claudeignore` | Criação e manutenção de `.claudeignore` | ❌ sem references |

### Agents (4)

| Nome plugin | Papel |
|---|---|
| `delphi-auditor` | Subagente de auditoria técnica profunda |
| `delphi-spec-writer` | Subagente de geração de SPEC |
| `delphi-tester` | Subagente de implementação de testes DUnitX (dual-mode) |
| `delphi-writer` | Subagente de escrita de código padronizado |

### Commands (7)

| Comando | Descrição |
|---|---|
| `/about` | Apresentação do plugin |
| `/audit` | Laudo técnico completo do projeto |
| `/new-project` | Scaffold de novo projeto Delphi |
| `/review` | Revisão rápida de código |
| `/spec` | Geração de SPEC a partir do código |
| `/tdd` | Suite de testes DUnitX do projeto |
| `/write` | Escrita de nova unit/classe/serviço |

---

## 2. Análise de sobreposição com o pack atual

### Skills

| Plugin skill | Skill pack existente | Diagnóstico |
|---|---|---|
| `delphi-laudo` | _(nenhuma)_ | ✅ **SEM OVERLAP** — laudo/auditoria completa de projeto ausente no pack. Absorver como nova skill. |
| `delphi-spec` | `governance-spec-*` (5 skills) | ⚠️ **OVERLAP PARCIAL** — pack cobre SPEC a partir de requisitos; plugin gera SPEC por engenharia reversa do código. Escopo diferente → absorver como nova skill em `developer-delphi`. |
| `delphi-standards` | `developer-delphi-programming-core`, `language-*` | ⚠️ **OVERLAP PARCIAL** — pack cobre linguagem/OOP; plugin tem Style Guide com `references/` detalhadas (prefixos, formatação, comandos proibidos). Complementar → absorver como nova skill. |
| `delphi-testes` | `developer-delphi-testing-dunitx_V1.0.0` | 🔴 **OVERLAP DIRETO** — ambas cobrem DUnitX. Plugin adiciona: dual-mode automático pós-write + `references/dunitx-patterns.md`. → **Enriquecer** a skill existente (adicionar references/ + expandir description). |
| `delphi-write` | _(nenhuma próxima)_ | ✅ **SEM OVERLAP** — workflow de escrita de código guiado por padrões não existe no pack. Absorver como nova skill. |
| `delphi-claudeignore` | _(nenhuma)_ | ✅ **SEM OVERLAP** — gestão de `.claudeignore` ausente no pack. Absorver como nova skill. |

### Agents

Todos os 4 agents do plugin são novos no pack — sem sobreposição com os agents existentes
(`connections-expert`, `database-expert`, `exceptions-expert`, `loggers-expert`, etc.).

### Commands

| Comando plugin | Equivalente no pack | Diagnóstico |
|---|---|---|
| `/about` | _(nenhum)_ | 🟡 **DISPENSÁVEL** no pack — o `/about` é contextual do plugin público. Não absorver. |
| `/audit` | _(nenhum)_ | ✅ absorver → `.cursor/commands/audit.md` |
| `/new-project` | `iniciar.md` (bootstrap) | 🔴 **OVERLAP** — `iniciar.md` faz o bootstrap do projeto via scripts. Plugin `/new-project` tem escopo diferente (projeto Delphi novo com arquitetura). → Avaliar fusão ou manter separado. **Decisão: manter separado** como `/new-project.md` — o bootstrap é infra; este é arquitetural. |
| `/review` | `validate-docs.md` (docs) | ⚠️ **OVERLAP PARCIAL** — `validate-docs.md` valida documentação; `/review` revisa código. → absorver como `/review.md`. |
| `/spec` | `consolidar.md` (parcial) | ✅ absorver → `.cursor/commands/spec.md` |
| `/tdd` | _(nenhum)_ | ✅ absorver → `.cursor/commands/tdd.md` |
| `/write` | _(nenhum)_ | ✅ absorver → `.cursor/commands/write.md` |

---

## 3. Mapeamento plugin → pack (naming convention)

### Skills

| Plugin (origem) | Pack (destino) | Versão | Categoria | Ação |
|---|---|---|---|---|
| `delphi-laudo/` | `developer-delphi-project-audit_V1.0.0/` | 1.0.0 | `developer-delphi` | CRIAR |
| `delphi-spec/` | `developer-delphi-project-spec_V1.0.0/` | 1.0.0 | `developer-delphi` | CRIAR |
| `delphi-standards/` | `developer-delphi-coding-standards_V1.0.0/` | 1.0.0 | `developer-delphi` | CRIAR |
| `delphi-testes/` | `developer-delphi-testing-dunitx_V1.0.0/` | 1.0.0 → 1.1.0 | `developer-delphi` | ENRIQUECER (bump V1.1.0) |
| `delphi-write/` | `developer-delphi-coding-workflow_V1.0.0/` | 1.0.0 | `developer-delphi` | CRIAR |
| `delphi-claudeignore/` | `developer-delphi-claudeignore_V1.0.0/` | 1.0.0 | `developer-delphi` | CRIAR |

### Agents

| Plugin (origem) | Pack (destino) | Ação |
|---|---|---|
| `agents/delphi-auditor.md` | `.cursor/agents/developer-delphi-agent-auditor_V1.0.0.md` | CRIAR |
| `agents/delphi-spec-writer.md` | `.cursor/agents/developer-delphi-agent-spec-writer_V1.0.0.md` | CRIAR |
| `agents/delphi-tester.md` | `.cursor/agents/developer-delphi-agent-tester_V1.0.0.md` | CRIAR |
| `agents/delphi-writer.md` | `.cursor/agents/developer-delphi-agent-writer_V1.0.0.md` | CRIAR |

### Commands

| Plugin (origem) | Pack (destino) | Ação |
|---|---|---|
| `commands/about.md` | _(dispensar)_ | NÃO ABSORVER |
| `commands/audit.md` | `.cursor/commands/audit.md` | CRIAR |
| `commands/new-project.md` | `.cursor/commands/new-project.md` | CRIAR |
| `commands/review.md` | `.cursor/commands/review.md` | CRIAR |
| `commands/spec.md` | `.cursor/commands/spec.md` | CRIAR |
| `commands/tdd.md` | `.cursor/commands/tdd.md` | CRIAR |
| `commands/write.md` | `.cursor/commands/write.md` | CRIAR |

---

## 4. Estrutura de destino — skills com `references/`

As pastas `references/` dos skills do plugin são preservadas integralmente:

```
.cursor/skills/
  developer-delphi-project-audit_V1.0.0/
    SKILL.md                          ← adaptado ao template V2.0 do pack
    references/
      estrutura-laudo.md              ← copiado do plugin
      estrutura-laudo.en.md           ← copiado do plugin
      clean-code-delphi.md            ← copiado do plugin
      code-smells-delphi.md           ← copiado do plugin
      estimativas-modernizacao.md     ← copiado do plugin
      style-guide.md                  ← copiado do plugin
      tecnologias-delphi.md           ← copiado do plugin

  developer-delphi-project-spec_V1.0.0/
    SKILL.md
    references/
      spec-template.md                ← copiado do plugin
      spec-template.en.md             ← copiado do plugin

  developer-delphi-coding-standards_V1.0.0/
    SKILL.md
    references/
      classes-structure.md            ← copiado do plugin
      component-prefixes.md           ← copiado do plugin
      forbidden-commands.md           ← copiado do plugin
      formatting.md                   ← copiado do plugin
      naming-conventions.md           ← copiado do plugin

  developer-delphi-testing-dunitx_V1.0.0/   ← RENOMEAR pasta para _V1.1.0
    SKILL.md                          ← bump V1.0.0 → V1.1.0, expandir description
    references/                       ← NOVA subpasta
      dunitx-patterns.md              ← copiado do plugin
```

---

## 5. Adaptações ao absorver para o pack

### Template SKILL.md V2.0

Cada SKILL.md do plugin será adaptado ao frontmatter padrão do pack:

```yaml
---
name: developer-delphi-<nome>
description: >
  <trigger do plugin preservado + palavras-chave em pt-BR>
  <adicionar: "Bilíngue pt-BR/en-US.">
model: sonnet
thinking: none   # ou extended para audit/spec
category: developer-delphi
---
```

### Bilinguismo

As skills do plugin têm lógica de detecção de idioma (pt-BR / en-US). Essa lógica é
preservada integralmente no corpo do SKILL.md — sem alteração.

### Trigger mechanism

O campo `description:` é o gatilho de ativação automática (regra N3 do pack).
Os triggers do plugin (já bem definidos por palavras-chave) são mantidos e estendidos
com os termos do ecossistema do pack quando relevante.

---

## 6. Antes / Depois

### Antes (pré-absorção)

```
.cursor/agents/   → 34 agents
.cursor/commands/ → 8 commands (autostart, consolidar, iniciar, migration-plan,
                                sync-cursor-pack, syncdb, validate-docs + manifest)
.cursor/skills/   → 186 ativas (189 físicas)
```

### Depois (pós-absorção)

```
.cursor/agents/   → 38 agents (+4)
.cursor/commands/ → 13 commands (+5: audit, new-project, review, spec, tdd, write)
.cursor/skills/   → 191 ativas + 1 enriquecida (testing-dunitx V1.1.0)
                    194 físicas (+5 novas + rename _V1.0.0→_V1.1.0 em testing-dunitx)
```

---

## 7. Estratégia de backup

- Skills CRIAR: operação de criação pura — rollback = `rm -rf` das 5 pastas novas
- Skill ENRIQUECER (`testing-dunitx`): antes de modificar, copiar pasta para `_V1.0.0_backup_absorb/`
- Agents e commands: criação pura — rollback trivial
- Plugin fonte permanece **intacto** em `delphi-dev-plugin/` durante toda a absorção

---

## 8. Atualização dos manifests pós-absorção

### `skills-pack-manifest` V1.21.0 → V1.22.0

_(a ser executado após a Onda E9 — este plano é a Onda E10)_

- Adicionar seção "Onda E10 — Absorção delphi-dev-plugin"
- Atualizar total: +5 skills novas, 1 enriquecida (V1.1.0)
- FolderVersion: 1.21.0 → 1.22.0

### `agents-pack-manifest` (versão atual)

- Adicionar os 4 novos agents
- Bump FolderVersion

### `commands-pack-manifest` (versão atual)

- Adicionar os 5 novos commands
- Bump FolderVersion

---

## 9. Ordem de execução

```
Bloco A — Skills novas (paralelo):
  A1. developer-delphi-project-audit_V1.0.0      (+ references/ 7 arquivos)
  A2. developer-delphi-project-spec_V1.0.0        (+ references/ 2 arquivos)
  A3. developer-delphi-coding-standards_V1.0.0   (+ references/ 5 arquivos)
  A4. developer-delphi-coding-workflow_V1.0.0
  A5. developer-delphi-claudeignore_V1.0.0

Bloco B — Skill enriquecida:
  B1. developer-delphi-testing-dunitx V1.0.0 → V1.1.0
      (adicionar references/dunitx-patterns.md + bump + expand description)

Bloco C — Agents novos (paralelo):
  C1. developer-delphi-agent-auditor_V1.0.0
  C2. developer-delphi-agent-spec-writer_V1.0.0
  C3. developer-delphi-agent-tester_V1.0.0
  C4. developer-delphi-agent-writer_V1.0.0

Bloco D — Commands (paralelo):
  D1. audit.md
  D2. new-project.md
  D3. review.md
  D4. spec.md
  D5. tdd.md
  D6. write.md

Pós-absorção:
  → validate_pack.py (0 CRITICAL)
  → validate-skills-consistency.py (0 CRITICAL)
  → agents-pack-manifest bump
  → commands-pack-manifest bump
  → skills-pack-manifest → V1.22.0 (só após E9)
  → Update skillsorm_analise_e_projecao.html
```

---

## 10. Checklist de execução

| Item | Status |
|---|---|
| A1 `project-audit` criada (+ 7 references) | ⬜ |
| A2 `project-spec` criada (+ 2 references) | ⬜ |
| A3 `coding-standards` criada (+ 5 references) | ⬜ |
| A4 `coding-workflow` criada | ⬜ |
| A5 `claudeignore` criada | ⬜ |
| B1 `testing-dunitx` → V1.1.0 (+ references/ + bump) | ⬜ |
| C1 agent `auditor` criado | ⬜ |
| C2 agent `spec-writer` criado | ⬜ |
| C3 agent `tester` criado | ⬜ |
| C4 agent `writer` criado | ⬜ |
| D1 command `audit.md` criado | ⬜ |
| D2 command `new-project.md` criado | ⬜ |
| D3 command `review.md` criado | ⬜ |
| D4 command `spec.md` criado | ⬜ |
| D5 command `tdd.md` criado | ⬜ |
| D6 command `write.md` criado | ⬜ |
| `validate_pack.py` 0 CRITICAL | ⬜ |
| `validate-skills-consistency.py` 0 CRITICAL | ⬜ |
| Manifests (agents + commands + skills) atualizados | ⬜ |
| `skillsorm_analise_e_projecao.html` atualizado | ⬜ |
