---
name: autostart-bootstrap
description: Executa o protocolo de auto-start (espelhos + skills project + detecao + criacao interativa) conforme a rule project-autostart-bootstrap_V1.2.0.
---

# /autostart-bootstrap

Executa o protocolo de **Auto-start Bootstrap** do workspace: valida espelhos, detecta se este repo é um **Skills Project** (e materializa CLAUDE.md / LICENSE / privacy-policy.md / .workspace/context.json), ou um projeto Delphi/FPC — neste caso, se ausente, cria interativamente (P1..P9) e materializa build configs.

## Escopo

Invocar quando:

- Precisa executar manualmente o mesmo fluxo definido pela rule `project-autostart-bootstrap_V1.0.1.mdc`, ou
- O workspace esta em estado inconsistente (espelhos quebrados / build configs ausentes) e voce quer normalizar.

**Gatilho automatico (chat):** se o usuario escrever `/init` (ou primeira mensagem da sessao) e nao existir `*.dpr` nem `*.lpr` na raiz, o agente deve interromper qualquer outra acao e iniciar a FASE 3 (P1 como primeira pergunta).

## Skills invocadas

| Skill | Quando/Por que e chamada |
|-------|--------------------------|
| `developer-delphi-build-toolchain` | Apenas como referencia de compilacao CLI apos a criacao (nao executa por si) |

## Parâmetros

| Parâmetro | Tipo | Padrao | Descrição |
|-----------|------|--------|-----------|
| *(nenhum)* | — | — | O alvo e o workspace atual |

## Comportamento

1. **FASE 1 — Validar espelhos**: executar:
   - `powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1" -ValidateOnly`
   - Se falhar por falta de privilegios de Administrador: informar e **parar**.
   - Se indicar problemas corrigiveis e o processo estiver elevado: executar sem `-ValidateOnly`.
1a. **FASE 2-A — Skills Project**: ler `.workspace/context.json.projectType`. Se `skills-pack` (ou heuristica: `.cursor/skills/` populado e sem `.dpr`/`.lpr`):
   - `powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-skills-project.ps1" -ValidateOnly`
   - Se faltarem arquivos ou houver update pendente, executar sem `-ValidateOnly`.
   - **Pular FASE 2 e FASE 3 Delphi**.
2. **FASE 2 — Detectar projecto Delphi/FPC** (apenas se NAO for Skills Project):
   - Procurar na raiz: `*.dpr` (Delphi) e `*.lpr` (FPC/Lazarus), excluindo `*.template`.
   - Se existir `.dpr` ou `.lpr`: executar `bootstrap-build-config.ps1 -ValidateOnly`; se faltarem configs, executar sem `-ValidateOnly`.
3. **FASE 3 — Criacao interativa (quando ausente)**:
   - Fazer **uma pergunta por mensagem** e aguardar resposta (P1..P9), seguindo a rule.
   - **Nao** gerar arquivos antes de coletar P1 e P2.
   - Ao final, executar `bootstrap-build-config.ps1` com a opcao (Delphi / FPC / Ambos) correspondente.
4. **FASE 4 — Form units (sob demanda)**:
   - Somente quando o usuario solicitar explicitamente, usando `bootstrap-form-unit.ps1`.
5. **Confirmacao**:
   - Informar no chat o resultado (arquivos gerados) e como compilar (referenciar o guia do toolchain).

## Exemplos de uso

```text
# Rodar manualmente o protocolo de autostart do workspace
/autostart-bootstrap
```

## Saida

- Workspace validado (espelhos ok).
- Em **Skills Project**: arquivos paramétricos de raiz materializados/atualizados (CLAUDE.md, LICENSE, privacy-policy.md, .workspace/context.json) — nada de Delphi.
- Em projeto Delphi/FPC novo: criacao interativa + arquivos gerados conforme framework escolhido.
- Em projeto Delphi/FPC existente: build configs materializados quando necessario.

---

## Versão interna (arquivo)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Política** | `.cursor/VERSION.md` |

## Changelog

- 1.1.0 (26/04/2026): Adicionada FASE 2-A (Skills Project) — invoca `bootstrap-skills-project.ps1` quando `projectType: skills-pack` ou heuristica positiva; pula FASE 2/3 Delphi nesse caso. Alinhado a `project-autostart-bootstrap_V1.2.0.mdc`.
- 1.0.0 (24/04/2026): Versao inicial do comando `/autostart-bootstrap` alinhado a `project-autostart-bootstrap_V1.0.1.mdc`.
