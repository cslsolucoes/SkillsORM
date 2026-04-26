# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## REGRA ABSOLUTA DE INÍCIO DE SESSÃO

Ao iniciar qualquer conversa neste workspace, executar as fases abaixo
**antes** de responder qualquer outra solicitação do usuário.

---

## FASE 1 — Validação dos espelhos

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-mirror-symlinks.ps1" -ValidateOnly
```

Se falhar por falta de privilégios de Administrador: informar e **parar**.

---

## FASE 2 — Detecção de projeto existente

Verificar na raiz a existência de `*.dpr` ou `*.lpr` (excluindo `*.template`).

**Se encontrado:** extrair o nome de `program NomeProjeto;` e verificar os arquivos de build:

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1" -ValidateOnly
```

Se algum arquivo de build estiver ausente, gerá-lo automaticamente.

**Se NÃO encontrado:** executar a FASE 3.

---

## GATILHO DO CHAT — `/init` ou primeira mensagem sem projeto

**REGRA DE PRIORIDADE MÁXIMA:**
Se o usuário escrever `/init` **ou** esta for a primeira mensagem da sessão
e não existir `*.dpr` nem `*.lpr` na raiz:
→ **Interromper qualquer outra ação e iniciar imediatamente a FASE 3.**

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

Scripts auxiliares disponíveis:
- `bootstrap-mirror-symlinks.ps1` — cria/valida symlinks dos espelhos
- `bootstrap-build-config.ps1` — gera/valida arquivos de build do projeto
- `bootstrap-form-unit.ps1` — gera form units sob demanda (VCL/FMX/LCL)
- `bootstrap-reset.ps1` — reset do ambiente de bootstrap
- `sync-cursor-pack.ps1` — sincroniza o pack `.cursor/` entre projetos
- `validate_pack.py` — valida integridade do pack de skills/rules/agents

---

## FASE 3 — Criação interativa do projeto

> Fazer cada pergunta como mensagem **individual e explícita**, aguardar resposta
> antes de enviar a próxima. **NÃO gerar arquivos antes de coletar P1 e P2.**

### P1 — Nome do projeto *(obrigatório)*

```text
Qual é o nome do projeto?
(Será usado em `program NomeProjeto;` e como nome dos arquivos — ex.: ProvidersORM)
```

### P2 — Pasta de documentação *(obrigatório)*

```text
Qual é a pasta de documentação do projeto?
(Caminho relativo à raiz — ex.: Documentation · padrão: Documentation)
```

### P3 — Framework *(obrigatório)*

```text
Qual framework deseja gerar?
  1 — Delphi (VCL)      → .dpr + .dproj + dcc32.cfg + dcc64.cfg
  2 — FPC/Lazarus (LCL) → .lpr + .lpi + .lps + fpc32.opts + fpc64.opts
  3 — Ambos (Delphi + FPC/Lazarus)
```

### P4 — Formulário principal *(opcional)*

```text
Nome da unit do formulário principal?
(Padrão: ufrm.Main · classe: frmMain · Enter para padrão)
```

### P5 — Defines condicionais *(opcional)*

```text
Defines condicionais adicionais?
(Padrão: FRAMEWORK_VCL para Delphi / LCL para FPC · separar com ; · Enter para padrão)
```

### P6 — Versão RAD Studio *(opcional — só se P3 = 1 ou 3)*

```text
Versão do RAD Studio? (Padrão: 23.0 · Enter para padrão)
```

### P7, P8, P9 — Caminhos FPC *(opcional — só se P3 = 2 ou 3)*

```text
Caminho da instalação do FPC? (Padrão: D:\fpc\fpc · Enter para padrão)
```

```text
Caminho da instalação do Lazarus? (Padrão: D:\fpc\lazarus · Enter para padrão)
```

```text
Caminho dos pacotes OPM do Lazarus?
(Padrão: D:\fpc\config_lazarus\onlinepackagemanager\packages · Enter para padrão)
```

### Geração após coleta

**Opção 1 — Somente Delphi:**

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1" `
    -ProjectName "{P1}" -ConditionalDefines "{P5}" `
    -MainFormUnit "{P4_unit}" -MainFormClass "{P4_classe}" `
    -StudioVersion "{P6}" -SkipLazarusFiles
```

**Opção 2 — Somente FPC/Lazarus:**

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1" `
    -ProjectName "{P1}" -ConditionalDefines "{P5}" `
    -MainFormUnit "{P4_unit}" -MainFormClass "{P4_classe}" `
    -FpcRoot "{P7}" -LazarusRoot "{P8}" -FpcOpmRoot "{P9}" -SkipProjectFiles
```

**Opção 3 — Ambos:**

```powershell
powershell -ExecutionPolicy Bypass -File ".cursor/scripts/bootstrap-build-config.ps1" `
    -ProjectName "{P1}" -ConditionalDefines "{P5}" `
    -MainFormUnit "{P4_unit}" -MainFormClass "{P4_classe}" `
    -StudioVersion "{P6}" -FpcRoot "{P7}" -LazarusRoot "{P8}" -FpcOpmRoot "{P9}"
```

Após execução, confirmar ao usuário a lista de arquivos criados.

---

## Compilação CLI

Guia completo: `.claude/skills/project-compile-database-docs_V1.0.1/exemplos/compile.md`

```powershell
# Delphi Win32
dcc32 NomeProjeto.dpr

# Delphi Win64
dcc64 NomeProjeto.dpr

# FPC Win32
D:\fpc\fpc\bin\i386-win32\fpc.exe @fpc32.opts NomeProjeto.lpr

# FPC Win64
D:\fpc\fpc\bin\x86_64-win64\fpc.exe @fpc64.opts NomeProjeto.lpr
```

---

## Arquitetura do repositório

```
.cursor/          ← Fonte canónica (SSOT): rules, skills, agents, templates, scripts
.claude/          ← Espelho via symlinks → .cursor/ (+ settings.json próprio)
.vscode/          ← Espelho via symlinks → .cursor/ (+ tasks.json, settings.json próprios)
.continue/        ← Espelho via symlinks → .cursor/
.opencode/        ← Espelho via symlinks → .cursor/ (OpenCode TUI/CLI; ver `opencode.json` na raiz)
src/
  Commons/        ← Tipos base, interfaces, utilitários partilhados
  Main/           ← Facades públicas (Connections.pas, Database.pas, etc.)
  Modulos/        ← Implementações por domínio
    Connections/  ← IConnection, TConnection, multi-engine (FireDAC/UniDAC/Zeos/SQLdb)
    Database/     ← ORM: Fields, Tables, Schemas, EntityManager, QueryBuilder
    Exceptions/   ← Exceções centralizadas + exception.db
    Loggers/      ← Sistema de log multi-destino
    Parameters/   ← Parâmetros (IniFile, JSON, Database)
    PoolConnections/ ← Pool de conexões
  Views/          ← Formulários de teste/demo (ufrm*) — sem lógica de negócio
Documentation/    ← Documentação canónica estruturada
```

Padrões obrigatórios: interfaces `I*`, implementações `T*`, factory `New`, estilo fluente.
Unit naming (backend Pascal): `ModuleConcept.Feature[.SubFeature].pas`
ex.: `Security.Domain.Entities.pas` · `Access.Auth.Jwt.pas` · `Customer.Repository.SqlServer.pas`
Regra: `.cursor/rules/backend-pascal-unit-naming_V1.1.0.mdc`
Compatibilidade Delphi + FPC obrigatória em todos os módulos de `src/`.

---

## Referências canónicas

- Regra Cursor: `.cursor/rules/project-autostart-bootstrap_V1.0.1.mdc`
- Compilação: skill `developer-delphi-build-toolchain` (exemplos em `.claude/skills/project-compile-database-docs_V1.0.1/exemplos/compile.md`)
- Banco de dados CLI: skill `developer-delphi-build-toolchain` (exemplos em `.claude/skills/project-compile-database-docs_V1.0.1/exemplos/database.md`)
- Diretivas de compilação: skill `developer-delphi-programming-conditional-defines` (exemplos em `.claude/skills/project-diretivas-compilacao_V1.0.1/exemplos/diretivas_compilacao.md`)
- Skills disponíveis: `.claude/README.md` (hub completo)
- Scripts de bootstrap: `.cursor/scripts/`
- Templates de projeto: `.cursor/Templates/build-config/`

<!-- internal_template_version: 1.0.2 -->
