---
name: schema-reorder-governance
description: Governa as áreas protegidas do repositório (Documentation/, .cursor/skills/, .cursor/rules/, .cursor/agents/, .cursor/Templates/, .workspace/rules/) durante renumerações e reorganizações do esquema canónico. Usar sempre que uma operação de schema-reorder, split, merge ou mudança estrutural tocar nessas áreas. Garante plan mode obrigatório, backup triplo e aprovação humana explícita antes de qualquer write/move/rename/delete. Triggers — "áreas protegidas", "governança de renumeração", "aprovação de schema-reorder", "gate P1b", "plano mestre Documentation/", "split de RN".
model: opus
thinking: extended
category: governance
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

## Responsabilidade única

Esta skill é a **autoridade de aprovação** para qualquer operação estrutural em áreas protegidas do repositório. Ela não executa mudanças; ela **autoriza** (ou bloqueia) operações que outras skills (como `documentation-schema-reorder`, `documentation-migration-plan`, `documentation-project-bootstrap`, `backend-pascal-module-scaffold`) pretendem executar.

Os três principais pilares que ela garante são: **(1)** plan mode obrigatório, **(2)** backup triplo verificado, **(3)** aprovação humana explícita registada.

## Versão interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Política** | `.cursor/VERSION.md` |

## Âmbito — áreas protegidas (lista canónica)

Conforme `CLAUDE.md` §"REGRA — Áreas protegidas":

| Área | Caminho (recursivo) | Razão |
|---|---|---|
| Documentação | `Documentation/` | SSOT funcional das RNs, ADRs, Roadmap, Status, Matriz |
| Skills | `.cursor/skills/` | SSOT de procedimentos executáveis versionados |
| Rules | `.cursor/rules/` | SSOT de políticas e convenções |
| Agents | `.cursor/agents/` | SSOT de agentes orquestrados |
| Templates | `.cursor/Templates/` | Templates de scaffold (build-config, formulários) |
| Workspace rules | `.workspace/rules/` | Regras específicas deste clone (ex.: `gestorerp-mxx-naming`) |

**Ficheiros fora das áreas protegidas** (não sujeitos a esta skill): `projects/`, `legados/`, `Scripts/`, `package/`, `dll/`, `data/`.

## When to use

- Qualquer skill que pretenda criar/mover/renomear/eliminar ficheiros em áreas protegidas tem que **chamar esta skill antes de escrever**.
- O utilizador pede aprovação de um plano que toque em áreas protegidas.
- Uma renumeração (`documentation-schema-reorder`) pede o gate P1b.
- Uma migração (`documentation-migration-plan`) entra na fase de apply.
- Bump de versão de rule/skill canónica (V1.x → V2.0) que requer CHANGELOG consolidado.

## When NOT to use

- Edits pontuais de conteúdo dentro de um ficheiro existente (typos, correções de redacção) quando o utilizador fornece o texto exacto — permitido pelas excepções de `CLAUDE.md`.
- Scaffold de formulário ou unit via `backend-pascal-module-scaffold` que só escreve dentro de `projects/backend/MXX-*/` (fora de áreas protegidas).
- Leituras, validações, dry-runs, greps — nenhuma modificação física acontece.

## Gates obrigatórios

Esta skill define **três gates** que têm que ser satisfeitos em ordem. Sem os três, a skill invocadora **não pode escrever**.

### Gate G0 — Backup triplo verificado

| Componente | Evidência esperada |
|---|---|
| **Tag Git** | `git tag --list 'pre-<operação>-*'` devolve pelo menos uma entrada datada do dia corrente |
| **Branch dedicada** | `git branch --show-current` devolve `chore/<operação>-<escopo>` (não `main`) |
| **Snapshot físico** | `Documentation/Backup/<descritor>_<data>/MANIFEST.md` existe e contém contagens por pasta |

Se algum destes faltar, esta skill devolve `BLOCK: G0 — backup triplo incompleto` e a skill invocadora pára.

### Gate G1 — Plano aprovado em plan mode

Plano tem que estar persistido em `.workspace/plans/<descritor>_V<N>.md` (não apenas no chat) e conter:

1. **Resumo da operação** em 2-3 linhas.
2. **Inventário de ficheiros afectados** (pastas + ficheiros a renomear, ficheiros a editar) com totais.
3. **Antes/depois** — mapping explícito se for renumeração; diff estimado se for edit massivo.
4. **Dependências** — outras RNs, skills, rules, agents que referenciam o âmbito tocado.
5. **Estratégia de backup** — referência ao snapshot G0.
6. **Validações pós-apply** — checks `grep`, `validate_pack.py`, `wc -l` específicos da operação.
7. **Rollback** — comando exacto (`git reset --hard <tag>`) que reverte sem ambiguidade.

Se algum destes itens faltar, devolver `BLOCK: G1 — plano incompleto (item <N>)`.

### Gate G2 — Aprovação humana explícita

O utilizador tem que ter escrito no chat uma aprovação **inequívoca**, registada na conversa, após ver o plano persistido. Frases aceites:

- `"prossiga"`, `"pode aplicar"`, `"executa"`, `"aprovado"`, `"ok, aplica"`, `"go"`.
- Equivalentes pt-BR: `"segue"`, `"pode ir"`.

Frases **não aceites** (ambíguas ou genéricas):

- `"ok"` isolado sem contexto recente do plano.
- `"sim"` isolado (sem confirmar qual plano).
- Silêncio ou assumir aprovação por continuidade.

Se G2 falhar, devolver `BLOCK: G2 — aprovação explícita ausente; pedir confirmação`.

## Fluxo de verificação

```
[skill invocadora pede execução]
        |
        v
  G0 — Backup triplo? --- não ---> BLOCK: G0
        |
       sim
        v
  G1 — Plano persistido e completo? --- não ---> BLOCK: G1 (item N)
        |
       sim
        v
  G2 — Aprovação explícita no chat? --- não ---> BLOCK: G2
        |
       sim
        v
  PASS: autorizado a escrever
```

## Interacção com outras skills

| Skill chamadora | Momento do gate | Efeito do BLOCK |
|---|---|---|
| `documentation-schema-reorder` | Antes da Fase 4 (Apply atómico) | Não corre o `renumber-modules.ps1 -Apply` |
| `documentation-migration-plan` | Antes da fase de write | Não edita ficheiros em `Documentation/` |
| `documentation-project-bootstrap` | Antes de criar esquema canónico inicial | Não escreve `RN-MXX/*` |
| `backend-pascal-module-scaffold` | **Não aplicável** se só toca `projects/backend/MXX-*/` | — |
| `skill-creator` / `rule-creator` | Antes de criar/bumpar ficheiros em `.cursor/skills/` ou `.cursor/rules/` | Não grava o novo artefacto |

## Registo de aprovações

Toda aprovação G2 tem que ser registada no plano mestre persistente:

```markdown
## §N — Registo de aprovações

- **<operação>** — plano `<caminho>` · aprovação do utilizador em `<data HH:mm>` via mensagem `"<frase>"` · gate G0 confirmado com tag `<tag>` + branch `<branch>` + snapshot `<path>`.
```

Esta secção serve de trilha de auditoria permanente. Nunca removida, apenas acumulada.

## Excepções documentadas

| Caso | Condição | Skill aplicável |
|---|---|---|
| Typo isolado | Utilizador fornece texto exacto antes/depois | Edit directo, sem gate |
| Adição de conteúdo em ficheiro | Utilizador fornece texto exacto e localização | Edit directo, sem gate |
| Scaffold via skill com fluxo próprio | Skill tem dry-run + confirmação interna | Skill usa o seu próprio fluxo, mas G0 backup continua obrigatório se tocar áreas protegidas |
| Criação de novo ficheiro em `.workspace/plans/` | `.workspace/plans/` **não** é área protegida no sentido editorial (é histórico) | Write directo permitido |

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Skill invocadora "esquece" de chamar esta governance | `CLAUDE.md` reforça plan mode; revisão em PR detecta ausência de §"Registo de aprovações" |
| Aprovação genérica `"ok"` interpretada como G2 | Lista positiva de frases aceites; em caso de dúvida, pedir confirmação explícita |
| Backup triplo simulado (tag sem snapshot) | Script de validação `validate_pack.py` verifica presença de `MANIFEST.md` no snapshot |
| Operação emergencial sem plano | Não existe excepção de emergência — se é emergência, aplicar manualmente, documentar retroactivamente no plano |

## Critérios de aceite

- Qualquer write em áreas protegidas tem registo correspondente na secção "Registo de aprovações" do plano mestre activo.
- Zero writes em áreas protegidas com G0/G1/G2 incompletos durante a sessão (verificável por `git log --name-only`).
- Skills chamadoras citam `schema-reorder-governance` no seu próprio output quando passam pelo fluxo.

## Referências

- `CLAUDE.md` §"REGRA — Áreas protegidas (plan mode obrigatório)"
- `.cursor/plans/documentation-migration-plan_V1.0.md` (template canónico de plano)
- `.cursor/skills/documentation-schema-reorder_V1.0.0/SKILL.md` (consumidor principal)
- `.cursor/skills/documentation-migration-plan_V1.1.0/SKILL.md` (consumidor secundário)

## Changelog

- **1.0.0 (18/04/2026):** Versão inicial. Formaliza os três gates G0/G1/G2 após a execução do split V2.0.0 do GestorERP (P1..P7) ter demonstrado, na prática, que toda operação em áreas protegidas precisava de backup triplo + plano persistido + aprovação explícita para não introduzir regressões silenciosas.
