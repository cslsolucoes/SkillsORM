<!-- internal_template_version: 1.1.0 -->
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Tipo de projeto:** Skills Pack (repositório que distribui o pack `.cursor/`).
> Não é projeto Delphi/FPC — o autostart pula as fases de detecção/criação de `.dpr`/`.lpr`.

---

## REGRA ABSOLUTA DE INÍCIO DE SESSÃO

Ao iniciar qualquer conversa neste workspace, executar a fase abaixo
**antes** de responder qualquer outra solicitação do usuário.

pensar em portugues brasil

---

## FASE 1 — Validação dos espelhos

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1" -ValidateOnly
```

Se falhar por falta de privilégios de Administrador: informar e **parar**.

---

## FASE 2-A — Bootstrap do Skills Project

Este repositório é um **Skills Pack** (`projectType: skills-pack` em `.workspace/context.json`).
O autostart materializa idempotentemente os arquivos paramétricos de raiz
(`CLAUDE.md`, `LICENSE`, `privacy-policy.md`, `.workspace/context.json`)
a partir de `.cursor/Templates/skills-project-bootstrap/`:

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-skills-project.ps1" -ValidateOnly
```

Se algum arquivo estiver ausente ou desatualizado (template tem versão maior),
executar sem `-ValidateOnly`. As fases Delphi (FASE 2 / FASE 3) **não se aplicam**
a este projeto e devem ser puladas.

---

## REGRA — Áreas protegidas (plan mode obrigatório)

Antes de criar, mover, renomear, fundir ou eliminar arquivos em qualquer das áreas abaixo, **SEMPRE apresentar um plano completo e aguardar aprovação explícita** do usuário — mesmo que ele diga "execute" ou "faça":

| Área | Caminho |
| --- | --- |
| Documentação | `Documentation/` (recursivo) |
| Skills | `.cursor/skills/` (recursivo) |
| Templates | `.cursor/Templates/` (recursivo) |
| Agents | `.cursor/agents/` (recursivo) |
| Rules | `.cursor/rules/` (recursivo) |

O plano deve conter: resumo da operação, inventário de arquivos afetados, antes/depois, dependências e estratégia de backup. Template em `.cursor/plans/documentation-migration-plan_V1.0.md`.

Exceções: correções de typos isolados em arquivo individual quando o usuário fornecer o texto exato; conteúdo adicionado quando o usuário fornecer o texto exato; scaffold via skills com fluxo próprio de confirmação.

---

## SSOT — Fonte canónica dos espelhos

**`.cursor/` é a única fonte canónica (SSOT).** Nunca editar diretamente `.claude/`, `.vscode/`, `.continue/` ou `.opencode/` — essas pastas são espelhos via symlinks gerados por `bootstrap-mirror-symlinks.ps1`. Edições devem ser feitas em `.cursor/` e propagadas pelos scripts.

Scripts auxiliares disponíveis (em `.cursor/scripts/`):

- `bootstrap-mirror-symlinks.ps1` — cria/valida symlinks dos espelhos
- `bootstrap-skills-project.ps1` — materializa CLAUDE.md / LICENSE / privacy-policy.md / .workspace/context.json
- `bootstrap-build-config.ps1` — gera/valida arquivos de build de projeto Delphi/FPC (não usado em Skills Project)
- `bootstrap-form-unit.ps1` — gera form units sob demanda (não usado em Skills Project)
- `bootstrap-reset.ps1` — reset do ambiente de bootstrap
- `sync-cursor-pack.ps1` — sincroniza o pack `.cursor/` entre projetos
- `validate_pack.py` — valida integridade do pack de skills/rules/agents
- `apply_mit_to_skills.py` — injeta bloco legal MIT no frontmatter dos SKILL.md

---

## Arquitetura do repositório

```
.cursor/          ← Fonte canónica (SSOT): rules, skills, agents, templates, scripts
.claude/          ← Espelho via symlinks → .cursor/ (+ settings.json próprio)
.vscode/          ← Espelho via symlinks → .cursor/ (+ tasks.json, settings.json próprios)
.continue/        ← Espelho via symlinks → .cursor/
.opencode/        ← Espelho via symlinks → .cursor/
.workspace/       ← Estado por clone (context.json, index.db)
CLAUDE.md         ← Materializado pelo bootstrap (template em .cursor/Templates/skills-project-bootstrap/)
LICENSE           ← Materializado pelo bootstrap
privacy-policy.md ← Materializado pelo bootstrap
```

---

## Referências canónicas

- Regra Cursor: `.cursor/rules/project-autostart-bootstrap_V1.1.0.mdc`
- Templates do bootstrap: `.cursor/Templates/skills-project-bootstrap/`
- Skills disponíveis: `.cursor/README.md` (hub completo)
- Comandos de workflow: `.cursor/commands/` (`/autostart`, `/consolidar`, `/syncdb`, `/validate-docs`, `/sync-cursor-pack`, `/migration-plan`)

<!-- internal_template_version: 1.0.0 · atualizado: 2026-04-26 -->
