---
name: governance-pack-checklist-validation
description: Checklist de validação para verificar que os espelhos (.claude/, .vscode/, .continue/, .opencode/) estão correctamente configurados com symlinks para .cursor/, que ficheiros protegidos não são symlinks, e que não existem referências residuais a paths obsoletos. Coerência estrutural do pack .cursor/.
model: haiku
thinking: minimal
category: governance-process
license: MIT
copyright: "Copyright (c) 2026 CSL Tech Solutions"
company: "CSL Tech Solutions"
author: "Claiton de Souza Linhares"
---

# Governance — Pack Checklist Validation

Checklist de validação para verificar que os espelhos e a estrutura do pack `.cursor/` estão coerentes.

**Execução automática:** `.\bootstrap-mirror-symlinks.ps1 -ValidateOnly`

## Responsabilidade única

Esta skill executa a validação estrutural completa do pack `.cursor/`, verificando que todos os espelhos (`.claude/`, `.vscode/`, `.continue/`, `.opencode/`) apontam correctamente via symlinks, que ficheiros protegidos não foram substituídos por links, e que não existem referências residuais a paths ou nomes de ficheiro obsoletos — garantindo coerência operacional do workspace antes de qualquer tarefa dependente da estrutura.

## When to use

- Antes de sincronizar o pack entre projectos (`sync-cursor-pack.ps1`).
- Após criar ou reparar symlinks com `bootstrap-mirror-symlinks.ps1`.
- Quando um agente reportar falha ao resolver path de skill, rule ou agente.
- Após renomear pastas de skills ou agentes (bump de versão).
- Como verificação de rotina ao iniciar sessão de trabalho no workspace.

## When NOT to use

- Para validar conteúdo semântico ou completude dos ficheiros `.md` → usar `documentation-analysis-index` ou `validate-docs`.
- Para compilar ou testar código-fonte do projecto → usar skills `developer-delphi-build-toolchain` ou `developer-delphi-to-fpc-build`.
- Para criar ou reparar symlinks (modo apenas leitura/diagnóstico) → executar `bootstrap-mirror-symlinks.ps1` sem `-ValidateOnly`.

## Inputs obrigatórios

| Input | Descrição |
|-------|-----------|
| Ambiente de execução | PowerShell com permissões suficientes (Administrador ou Modo Programador do Windows) |
| Raiz do workspace | Path absoluto da raiz onde `.cursor/`, `.claude/`, `.vscode/`, `.continue/`, `.opencode/` residem |

## Dependências (skills prévias)

| Skill | Motivo |
|-------|--------|
| `governance-pack-versioning-policy` | Os checks V8 e V11 dependem das convenções de nome definidas pela política de versionamento |

## Checks

| # | Check | Resultado esperado |
|---|-------|-------------------|
| V1 | Sem `Docs/` residual (excluir changelog/alias) | 0 ocorrencias em contexto nao-historico |
| V2 | Symlinks de directorio em `.claude/` | Todos `SymbolicLink` |
| V3 | Symlinks de directorio em `.continue/` | Todos `SymbolicLink` |
| V4 | Symlinks de directorio em `.vscode/` | Todos `SymbolicLink` |
| V13 | Symlinks de directorio em `.opencode/` | Todos `SymbolicLink` |
| V5 | Symlinks de ficheiro em cada mirror | Symlinks por mirror |
| V6 | Targets de symlinks resolvem correctamente | Todos validos |
| V7 | `.cursor/plans/` symlink funciona | `$true` |
| V8 | Sem referencia a `SKILL_V1.0.md` (naming antigo) | 0 ocorrencias |
| V9 | Configs protegidos NAO sao symlinks | Confirmado para: `.vscode/settings.json`, `tasks.json`, `extensions.json`, `.claude/settings.json`, `settings.local.json`. Em `tasks.json`, paths sob o repo devem usar `${workspaceFolder}/...`; absoluto só fora do workspace (ex.: FPC em `{FPC_ROOT}`). |
| V10 | README/SKILLS_DOC nao referenciam planos inexistentes | 0 falsos positivos |
| V11 | Sem "Como usar este template" em rules activas | 0 ocorrencias |
| V12 | README.md stale removido/substituido nos mirrors | Confirmado nos 4 mirrors |

## Como correr

```powershell
# Verificacao completa (sem alteracoes)
.\bootstrap-mirror-symlinks.ps1 -ValidateOnly

# Criar symlinks em falta
.\bootstrap-mirror-symlinks.ps1

# Reparar symlinks quebrados
.\bootstrap-mirror-symlinks.ps1 -Repair

# Substituir ficheiros reais stale por symlinks (backup automatico)
.\bootstrap-mirror-symlinks.ps1 -Force
```

## Workflow executável

1. Executar `bootstrap-mirror-symlinks.ps1 -ValidateOnly` para diagnóstico sem alterações.
2. Revisar output — identificar checks com falha (V1–V13).
3. Para symlinks em falta: executar `bootstrap-mirror-symlinks.ps1` (cria os que faltam).
4. Para symlinks quebrados: executar `bootstrap-mirror-symlinks.ps1 -Repair`.
5. Para ficheiros reais stale: executar com `-Force` (backup automático).
6. Re-executar com `-ValidateOnly` para confirmar 0 falhas.
7. Documentar qualquer anomalia residual como issue no backlog do projecto.

## Outputs obrigatórios

| Output | Descrição |
|--------|-----------|
| Relatório de checks | Lista de V1–V13 com status PASS / FAIL por check |
| 0 falhas confirmadas | Todos os 13 checks retornam resultado esperado |
| Acção correctiva (se falha) | Comando executado e resultado após correcção |

## Checklist de validação

- [ ] V1: Sem referências `Docs/` em contexto não-histórico.
- [ ] V2–V4, V13: Todos os directórios dos 4 mirrors são SymbolicLink.
- [ ] V5: Ficheiros de cada mirror são symlinks.
- [ ] V6: Targets de symlinks resolvem para `.cursor/` correctamente.
- [ ] V7: `.claude/plans` acessível via `Test-Path`.
- [ ] V8: Sem naming antigo `SKILL_V1.0.md`.
- [ ] V9: Ficheiros protegidos NÃO são symlinks.
- [ ] V10: Sem referências a planos inexistentes.
- [ ] V11: Sem secção "Como usar este template" em rules activas.
- [ ] V12: `README.md` nos 4 mirrors são SymbolicLink.

## Anti-padrões

| Anti-padrão | Por que errado | Como corrigir |
|-------------|----------------|---------------|
| Editar ficheiro directamente em `.claude/` em vez de `.cursor/` | `.claude/` é espelho — edição directa é sobrescrita na próxima sincronização | Editar sempre em `.cursor/` (SSOT) |
| `tasks.json` com raiz absoluta do repositório em `command`/`args` | Perde portabilidade entre pastas/máquinas | Preferir `${workspaceFolder}/...` para artefactos do repo; manter absoluto só para ferramentas fora do projeto (ex.: `fpc.exe` via `{FPC_ROOT}` no template) |
| Ignorar warnings do `-ValidateOnly` e prosseguir com tarefas | Symlinks quebrados causam falhas silenciosas em agentes | Corrigir todos os checks com FAIL antes de prosseguir |
| Correr `-Force` sem verificar o backup automático | `-Force` substitui ficheiros reais — se o backup falhar, conteúdo é perdido | Confirmar existência e integridade do backup antes de usar `-Force` |

## Métricas de sucesso

- 13/13 checks (V1–V13) com status PASS após execução do `-ValidateOnly`.
- Tempo médio de resolução de falhas de symlink inferior a 5 minutos.

## Responsável principal

| Papel | Quem |
|-------|------|
| Agent responsável | `doc-agent-orchestrator` |
| Humano responsável | Tech Lead |

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |

## Changelog (este arquivo)

- 1.0.1 (12/04/2026): Política de paths em `tasks.json` (check V9 + anti-padrão): `${workspaceFolder}` dentro do repo; absoluto só fora (ex.: FPC).
- 1.0.0 (09/04/2026): Reorganização §17 — skill movida de `pack-checklist-validation`; novo prefixo canônico `governance`. Conteúdo V2 preservado (FileVersion 1.1.0 da origem). Referências a `developer-delphi-build-cross-compiler` atualizadas para `developer-delphi-build-cross-compiler`.
