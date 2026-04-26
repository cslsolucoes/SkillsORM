---
name: skills-correction-and-split-plan
description: Plano de correções pós-auditoria bright-bear (C1-C5) e subdivisão de skills densas (D1-D3) do pack SkillsORM.
version: 1.0.0
date: 2026-04-24
scope: .cursor/skills/ · .cursor/rules/ · .cursor/plans/audit/
status: AGUARDANDO APROVAÇÃO
---

# Plano — Correções e Subdivisão de Skills

**Data:** 24/04/2026
**Base:** Auditoria `quero-que-olhe-arquivo-bright-bear.md` (22 ondas L01-L22 + E1-E8) verificada em 24/04/2026.
**Veredicto da auditoria:** "Executado com Alta Qualidade — mas não com Maestria Total." (22/22 ondas presentes, score médio 2.0/3.0, **E4 NÃO aplicado**).

> **REGRA DE ÁREA PROTEGIDA**: Todas as operações sobre `.cursor/skills/`, `.cursor/rules/` e `.cursor/agents/` exigem aprovação explícita antes de execução. Este documento é o plano — nenhuma alteração será feita sem confirmação do usuário.

---

## Sumário executivo

| # | Parte | Tipo | Arquivos afetados | Prioridade |
|---|---|---|---|---|
| C1 | Correção | Fix Q1+Q7 em `conditional-defines` | 1 SKILL.md | 🔴 CRÍTICA |
| C2 | Correção | Refs legacy em 9 skills/agents ativas | ~12 ocorrências em 9 arquivos | 🟠 Alta |
| C3 | Correção | Frontmatter `category:` errado | 9 skills | 🟡 Média |
| C4 | Correção | `rules-pack-manifest` desatualizado | 1 .md | 🟡 Média |
| C5 | Correção | Encoding UTF-8 corrompido | 10 agent .md | 🟡 Média |
| D1 | Subdivisão | `shared-libraries` 730→3 skills | 1 → 3 SKILL.md | 🟠 Alta |
| D2 | Subdivisão | `linux-servers` 707→2 skills | 1 → 2 SKILL.md | 🟠 Alta |
| D3 | Subdivisão | `windows-services` 557→2 skills | 1 → 2 SKILL.md | 🟡 Média |

**Total de arquivos impactados:** ~25 arquivos em `.cursor/skills/`, `.cursor/rules/`, `.cursor/agents/`.

---

## PARTE A — Correções

### C1 — Fix Q1+Q7: `developer-delphi-programming-conditional-defines` (CRÍTICA)

**Achado original (L09, score 3.0/3.0 — achado de maior prioridade de todo o pack):**
A skill ensina que `{$IFDEF}` deve ser **evitado** neste projeto (seção `## Por que NÃO usar {$IFDEF}`), mas ainda menciona `{$IFDEF}` em contextos prescritivos — criando auto-contradição (Q1) e ensinando o anti-padrão (Q7) em 4 pontos do arquivo.

**Evidência (verify_plan.py):** 7× `{$IFDEF}` / 0× `{$IF DEFINED}` — status `NÃO CORRIGIDO`.

**Ocorrências a corrigir (linha → problema → solução):**

| Linha | Texto atual | Texto corrigido |
|---|---|---|
| 3 (frontmatter `description`) | `how to write {$IFDEF} / {$IF DEFINED(...)} blocks` | `how to write {$IF DEFINED(...)} blocks (and why NOT to use {$IFDEF})` |
| 19 (§ Responsabilidade única) | `escrever blocos {$IFDEF} e {$IF DEFINED(...)} na ordem correta` | `escrever blocos {$IF DEFINED(...)} na ordem correta e garantir que nenhum {$IFDEF} de engine seja introduzido` |
| 40 (§ Inputs) | `Contexto do bloco {$IFDEF} a escrever` | `Contexto do bloco condicional {$IF DEFINED(...)} a escrever` |
| 82 (§ Checklist) | `Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines` | `Diretivas {$IF DEFINED(...)} conforme developer-delphi-programming-conditional-defines; sem nenhum {$IFDEF} de engine` |
| 131 (título de seção) | manter como-está (é seção explicativa "Por que NÃO usar") | — nenhuma alteração |
| 141 (corpo explicativo) | manter como-está (está descrevendo o que evitar) | — nenhuma alteração |
| 151 (tabela Anti-padrões) | manter como-está (coluna "Anti-padrão") | — nenhuma alteração |

**Bump de versão:** `_V1.0.0` → `_V1.1.0` (rename de pasta + atualização do frontmatter `version`).

**Arquivos a alterar:** 1 — `developer-delphi-programming-conditional-defines_V1.0.0/SKILL.md`.

---

### C2 — Fix refs legacy em skills/agents ativos

**Achado original (E8 §5 e §14):** 11 ocorrências de refs legacy espalhadas em 9 arquivos ativos.

**Mapa completo de substituições:**

#### Grupo 1 — `developer-assembly-*` ainda apontam para `developer-delphi-assembly-*` (4 skills)

Renames feitos pela onda E5 do bright-bear removeram o prefixo `delphi-` das 4 skills de assembly. As cross-references internas não foram atualizadas.

| Skill afetada | Linha aprox. | De | Para |
|---|---|---|---|
| `developer-assembly-instructions_V1.0.0` | ~325, ~356-358 | `developer-delphi-assembly-instructions_V1.0.0/` | `developer-assembly-instructions_V1.0.0/` |
| `developer-assembly-instructions_V1.0.0` | ~356 | `developer-delphi-assembly-x86-fundamentals_V1.0.0` | `developer-assembly-x86-fundamentals_V1.0.0` |
| `developer-assembly-instructions_V1.0.0` | ~357 | `developer-delphi-assembly-registers_V1.0.0` | `developer-assembly-registers_V1.0.0` |
| `developer-assembly-instructions_V1.0.0` | ~358 | `developer-delphi-assembly-stack-call_V1.0.0` | `developer-assembly-stack-call_V1.0.0` |
| `developer-assembly-registers_V1.0.0` | ~239, ~263-265 | `developer-delphi-assembly-*` (3 refs) | `developer-assembly-*` (equivalentes) |
| `developer-assembly-stack-call_V1.0.0` | cross-refs | `developer-delphi-assembly-*` (refs restantes) | `developer-assembly-*` |
| `developer-assembly-x86-fundamentals_V1.0.0` | cross-refs | `developer-delphi-assembly-*` (refs restantes) | `developer-assembly-*` |

#### Grupo 2 — `project-abrir-bancos-cli` → `project-open-database-cli` (2 arquivos)

| Arquivo | Local |
|---|---|
| `.cursor/skills/project-master-orchestrator_V1.2.0/SKILL.md` | seção de skills referenciadas |
| `.cursor/skills/developer-delphi-build-toolchain_V*/SKILL.md` | seção de cross-refs |

#### Grupo 3 — refs a skills/agents renomeados ou relocados (3 arquivos)

| Arquivo afetado | Ref legacy | Situação real | Ação |
|---|---|---|---|
| `developer-web-nodejs-api-middleware_*/SKILL.md` | `documentation-and-governance-web` | Skill não existe | Substituir por `documentation-general_rules_V2.0.0` ou remover ref |
| `developer-web-packaging-deployment_*/SKILL.md` | `documentation-and-governance-web` | Skill não existe | Idem |
| `governance-constitution-policies_*/SKILL.md` | `documentation-cursor-rules-integration`, `documentation-migration-conflict-resolution`, `documentation-superseded-definition` | 3 skills não existem com esses nomes | Substituir pelos nomes atuais ou remover |
| `documentation-portal-html_*/SKILL.md` | `documentation-constitution-policies`, `documentation-sdlc-lifecycle` | Renomeados para `governance-constitution-policies` e `governance-sdlc-lifecycle` | Atualizar os 2 nomes |
| `project-consolidate-cursor_*/SKILL.md` | `documentation-file-versioning` | Existe como **rule**, não skill | Ajustar texto: "rule `documentation-file-versioning`" |
| `project-query-docs-index_*/SKILL.md` | `developer-delphi-providers-pool` | Não existe | Remover ref ou apontar para `developer-delphi-agent-poolconnections-expert` |

> **Nota sobre agents:** `developer-delphi-agent-orm-architect`, `developer-delphi-agent-loggers-expert`, `developer-delphi-agent-parameters-expert` **existem** em `.cursor/agents/`. Os warnings do validador são falso-positivos (não distingue skill de agent). Nenhuma ação necessária para esses 3.

---

### C3 — Fix frontmatter `category:` em 9 skills

**Achado original (E8 §8):** 37 discrepâncias heurísticas, das quais 28 são "legítimas" (skills `developer-delphi-*` que documentam stacks do projeto e foram classificadas como `category: project` intencionalmente). As 9 restantes são erros reais:

| Skill | `category` atual | `category` correto | Justificativa |
|---|---|---|---|
| `project-consolidate-cursor_V1.1.0` | `quality` | `project` | Prefixo `project-` → categoria `project` |
| `project-consolidate-documentation_V*/` | `quality` | `project` | Idem |
| `project-consolidate-orchestrator_V*/` | `quality` | `project` | Idem |
| `project-consolidate-source_V*/` | `quality` | `project` | Idem |
| `project-open-database-cli_V1.0.0` | `developer-delphi` | `project` | Skill de projeto, não de framework Delphi |
| `documentation-rules_creator_V1.1.0` | `governance-process` | `documentation` | Prefixo `documentation-` → categoria `documentation` |
| `governance-master-orchestrator_V1.0.0` | `governance` | `governance-process` | Orquestradores de governance seguem padrão `governance-process` |
| `governance-pack-checklist-validation_V*/` | `quality` | `governance-process` | Pertence ao domínio governance-process |
| `governance-spec-evolution_V*/` | `governance-process` | `governance-spec` | Prefixo específico `governance-spec-` |

**Ação:** editar frontmatter YAML em cada SKILL.md — alterar apenas o campo `category:`.

---

### C4 — Atualizar `rules-pack-manifest_V1.6.0.md`

**Achado original (E8 §10):** O manifesto declara "9 → 10 após adição de `pascal-encoding-no-escapes`" mas existem **12** `.mdc` ativos. Faltam no narrativo:

- `documentation-file-versioning_V1.0.0.mdc`
- `local_arquivos_V1.0.mdc`

**Ação:**
1. Atualizar o cabeçalho: `Rules activas (9 → 10 após adição...)` → `Rules activas (12):`.
2. Adicionar as 2 rules ao inventário narrativo com breve descrição.
3. Bump FolderVersion: `1.6.0` → `1.6.3` (patch de documentação).
4. Adicionar entrada no `## Changelog`: `1.6.3 (24/04/2026): alinha contagem para 12 rules reais; adiciona documentation-file-versioning_V1.0.0 e local_arquivos_V1.0 ao narrativo ativo.`

**Arquivo a alterar:** 1 — `.cursor/rules/rules-pack-manifest_V1.6.0.md`.

---

### C5 — Fix encoding UTF-8 nos 10 `developer-delphi-agent-*_V1.3.0`

**Achado original (L20):** 10 arquivos de agent Delphi salvos com encoding que perdeu acentos ANSI→UTF-8 durante conversão do bright-bear. Exemplos confirmados:

- `developer-delphi-agent-connections-expert_V1.3.0` linha 4: `"mdulo Connections"` → `"módulo Connections"`
- linha 13: `"lgica de negcio"` → `"lógica de negócio"`, `"excees"` → `"exceções"`
- linha 20: `"Responsabilidade nica"` → `"Responsabilidade única"`

**Escopo:** 10 arquivos `.cursor/agents/developer-delphi-agent-*_V1.3.0.md`.

**Estratégia:** Script Python que lê cada arquivo, aplica um mapa de substituições ANSI→UTF-8 (padrão conhecido de codificação Windows-1252 lida como Latin-1), valida e reescreve. Não alterar nenhum conteúdo além dos caracteres corrompidos.

**Mapa de substituições conhecidas:**
```
"mdulo"   → "módulo"
"nica"    → "única"
"lgica"   → "lógica"
"negcio"  → "negócio"
"excees"  → "exceções"
"exceo"   → "exceção"
"informaes" → "informações"
"configuraes" → "configurações"
"conexo"  → "conexão"
"viso"    → "visão"
"seo"     → "seção"
```

**Script a criar:** `.cursor/scripts/fix-agent-encoding.py` (temporário, descartável após uso).

---

## PARTE B — Subdivisão de Skills Densas

**Critério de seleção:** SKILL.md com > 400 linhas onde há fronteiras semânticas naturais que permitem criar skills filhas coesas, sem resumir nem perder exemplos de código.

**Inventário de candidatas (por tamanho):**

| Skill | Linhas | Decisão | Estratégia |
|---|---|---|---|
| `developer-delphi-to-fpc-shared-libraries` | 730 | ✅ Subdividir | 3 skills filhas |
| `developer-delphi-to-fpc-linux-servers` | 707 | ✅ Subdividir | 2 skills filhas |
| `documentation-project-expert` | 599 | ⚠️ Manter | Ver nota D0 |
| `developer-delphi-windows-services` | 557 | ✅ Subdividir | 2 skills filhas |
| `documentation-overview-architecture` | 444 | ⚠️ Avaliar | Ver nota D4 |
| `developer-delphi-to-fpc-threading-advanced` | 444 | ⚠️ Manter | Ver nota D5 |
| `developer-delphi-windows-store-publishing` | 411 | ⚠️ Manter | Ver nota D4 |
| `developer-delphi-to-fpc-performance-and-architecture` | 390 | ⚠️ Avaliar | Abaixo do threshold crítico |

---

### D0 — Nota: `documentation-project-expert` (599 linhas — MANTER)

Esta skill é o **contexto completo do projeto ProvidersORM** — carregada em praticamente toda interação de desenvolvimento. Sua densidade é intencional: ela serve como "base de conhecimento única" para que o modelo não precise consultar múltiplos arquivos. Subdividir implicaria que o modelo carregaria apenas parte do contexto em cada sessão, perdendo coesão.

**Recomendação:** Não subdividir. Em vez disso, como melhoria futura, extrair apenas a seção `## ORM.Defines.inc` como documento `exemplos/orm-defines-reference.md` dentro da própria skill — mantendo o SKILL.md intacto e apenas adicionando um ponteiro.

---

### D1 — Subdivisão: `developer-delphi-to-fpc-shared-libraries_V1.0.0` (730 linhas → 3 skills)

**Justificativa:** 11 seções numeradas com 3 eixos temáticos claramente separáveis: (a) Windows DLL clássica, (b) Linux shared objects, (c) padrão avançado de plugins via interfaces.

**Estrutura atual → proposta:**

```
developer-delphi-to-fpc-shared-libraries_V1.0.0/ (ATUAL - 730 linhas)
│
├── developer-delphi-to-fpc-shared-libraries-windows_V1.0.0/ (NOVO ~260 linhas)
│   Seções: ⚠️ AVISO CRÍTICO (fronteira de memória), §1 sintaxe library,
│            §2 exports, §3 DllProc, §4 LoadLibrary/GetProcAddress,
│            §6 calling conventions, §7 .dproj multi-plataforma, §8 BPL vs DLL vs .so
│   Responsabilidade: criar, exportar e carregar DLLs em Windows (Win32/Win64)
│
├── developer-delphi-to-fpc-shared-libraries-linux_V1.0.0/ (NOVO ~100 linhas)
│   Seções: §5 dlopen/dlsym (Delphi Posix.Dlfcn + FPC dynlibs)
│   Responsabilidade: carregar .so em Linux via dlopen/dlsym — cross-compiler
│
└── developer-delphi-to-fpc-shared-libraries-plugins_V1.0.0/ (NOVO ~200 linhas)
    Seções: §9 Interface approach (sistema de plugins robusto),
             §10 versioning de DLL, §11 checklist production-ready
    Responsabilidade: arquitetura de plugins extensível via interfaces — Delphi+FPC
```

**Plano de execução D1:**
1. Criar as 3 pastas novas em `.cursor/skills/`.
2. Para cada skill filha: copiar o frontmatter da skill-mãe, ajustar `name`, `description`, `version: 1.0.0`, e a seção `## Responsabilidade única`.
3. Copiar as seções correspondentes (sem resumir — cópia fiel do conteúdo).
4. Em cada skill filha, adicionar seção `## Dependências (skills prévias)` referenciando as demais irmãs onde aplicável.
5. Renomear (ou arquivar) a skill-mãe → `_DEPRECATED_V1.0.0` com ponteiro para as 3 filhas.
6. Atualizar `developer-delphi-master-orchestrator` e qualquer skill que referencie `shared-libraries`.

**Busca de refs antes de deprecar:**

```bash
grep -r "shared-libraries" .cursor/skills/ .cursor/agents/ .cursor/rules/ --include="*.md" -l
```

---

### D2 — Subdivisão: `developer-delphi-to-fpc-linux-servers_V1.0.0` (707 linhas → 2 skills)

**Justificativa:** 11 seções numeradas com fronteira clara em §4: as seções 1-3 cobrem infraestrutura de desenvolvimento (setup, PAServer, compilação cruzada), as seções 4-11 cobrem o servidor em runtime (daemon, sinais, systemd, FPC runtime, DataSnap, checklist de deploy).

**Estrutura proposta:**

```
developer-delphi-to-fpc-linux-servers_V1.0.0/ (ATUAL - 707 linhas)
│
├── developer-delphi-to-fpc-linux-setup_V1.0.0/ (NOVO ~280 linhas)
│   Seções: §1 Pré-requisitos (Windows dev + Linux server), §2 PAServer
│            (instalação, daemon systemd, connection profile), §3 dcclinux64
│            (IDE, MSBuild CLI, deploy SCP), §8 runtime dependencies
│   Responsabilidade: configurar ambiente de cross-compile Delphi/FPC para Linux
│
└── developer-delphi-to-fpc-linux-daemon_V1.0.0/ (NOVO ~430 linhas)
    Seções: §4 projeto consola como base, §5 daemon UNIX clássico (fork+setsid),
             §6 signal handling (SIGTERM/SIGHUP/SIGPIPE) Delphi+FPC,
             §7 systemd unit file, §9 FPC/Lazarus diferenças vs Delphi (tabelas),
             §10 DataSnap/Web Server em Linux, §11 checklist pré-deploy
    Responsabilidade: implementar servidores daemon Linux em Delphi+FPC
```

**Plano de execução D2:** idêntico ao D1 (criar filhas, copiar seções, deprecar mãe, atualizar refs).

**Busca de refs antes de deprecar:**

```bash
grep -r "linux-servers" .cursor/skills/ .cursor/agents/ .cursor/rules/ --include="*.md" -l
```

---

### D3 — Subdivisão: `developer-delphi-windows-services_V1.0.0` (557 linhas → 2 skills)

**Justificativa:** 11 seções numeradas com fronteira clara em §7: as seções 1-6 cobrem criação e implantação básica (TService, eventos, threads, session-0 isolation, EventLogger, instalação via sc.exe), as seções 7-11 cobrem operação avançada (contas de serviço, recovery, debugging, IPC via named pipes, fontes de referência).

**Estrutura proposta:**

```
developer-delphi-windows-services_V1.0.0/ (ATUAL - 557 linhas)
│
├── developer-delphi-windows-services-setup_V1.0.0/ (NOVO ~280 linhas)
│   Seções: §1 wizard + estrutura .dpr, §2 tabela completa de eventos TService,
│            §3 padrão de thread em OnStart/OnStop, §4 session-0 isolation (CRÍTICO),
│            §5 TEventLogger, §6 instalação/desinstalação (sc.exe + auto-install)
│   Responsabilidade: criar, configurar e implantar Windows Services em Delphi
│
└── developer-delphi-windows-services-advanced_V1.0.0/ (NOVO ~280 linhas)
    Seções: §7 contas de serviço (tabela de decisão), §8 recovery actions (watchdog SCM),
             §9 debugging (4 métodos: RunAs Console, Attach, OutputDebugString, Sleep),
             §10 named pipes para IPC (serviço ↔ app desktop), §11 checklist pré-deploy,
             fontes de referência CHM Delphi 12
    Responsabilidade: operar, depurar e integrar Windows Services com outras aplicações
```

**Plano de execução D3:** idêntico ao D1/D2.

---

### D4 — Nota: Skills entre 400-450 linhas (avaliar caso-a-caso)

| Skill | Linhas | Avaliação |
|---|---|---|
| `documentation-overview-architecture_V1.1.0` | 444 | Visão geral de arquitetura — coesa por natureza; manter |
| `developer-delphi-to-fpc-threading-advanced_V1.1.0` | 444 | Par com `threading-basics`; já é uma subdivisão existente; manter |
| `developer-delphi-windows-store-publishing_V1.0.0` | 411 | Workflow sequencial único (10 passos Partner Center); manter |
| `developer-delphi-to-fpc-performance-and-architecture_V1.0.0` | 390 | Abaixo de 400; manter |

**Ação D4:** nenhuma agora. Reavaliação após D1-D3 (reduz o volume médio do pack, criando referência de tamanho ideal para avaliação futura).

---

## Sequência de execução aprovada

```
C1 (1 arquivo)     → mais rápido, maior impacto (CRÍTICA)
C2 (9 arquivos)    → corrigir refs antes de qualquer rename
C3 (9 SKILL.md)    → edição isolada de frontmatter
C4 (1 .md)         → 1 arquivo simples
C5 (10 agents)     → script Python semi-automático
─── pausa para re-validação: validate-skills-consistency.py ───
D1 (1→3 skills)    → subdivisão shared-libraries
D2 (1→2 skills)    → subdivisão linux-servers
D3 (1→2 skills)    → subdivisão windows-services
─── validação final: validate_pack.py + validate-skills-consistency.py ───
```

---

## Inventário completo de arquivos afetados

### Parte A — Correções

| Arquivo | Ação | Onda |
|---|---|---|
| `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/SKILL.md` | Editar 4 linhas + rename pasta para `_V1.1.0` | C1 |
| `.cursor/skills/developer-assembly-instructions_V1.0.0/SKILL.md` | Atualizar 4 refs `delphi-assembly-*` | C2 |
| `.cursor/skills/developer-assembly-registers_V1.0.0/SKILL.md` | Atualizar 3 refs `delphi-assembly-*` | C2 |
| `.cursor/skills/developer-assembly-stack-call_V1.0.0/SKILL.md` | Atualizar refs `delphi-assembly-*` | C2 |
| `.cursor/skills/developer-assembly-x86-fundamentals_V1.0.0/SKILL.md` | Atualizar refs `delphi-assembly-*` | C2 |
| `.cursor/skills/project-master-orchestrator_V1.2.0/SKILL.md` | `project-abrir-bancos-cli` → `project-open-database-cli` | C2 |
| `.cursor/skills/developer-delphi-build-toolchain_V*/SKILL.md` | `project-abrir-bancos-cli` → `project-open-database-cli` | C2 |
| `.cursor/skills/developer-web-nodejs-api-middleware_*/SKILL.md` | Remover/substituir ref `documentation-and-governance-web` | C2 |
| `.cursor/skills/developer-web-packaging-deployment_*/SKILL.md` | Remover/substituir ref `documentation-and-governance-web` | C2 |
| `.cursor/skills/governance-constitution-policies_*/SKILL.md` | Substituir 3 refs documentation-* legacy | C2 |
| `.cursor/skills/documentation-portal-html_*/SKILL.md` | Atualizar 2 nomes renomeados | C2 |
| `.cursor/skills/project-consolidate-cursor_*/SKILL.md` | Ajustar ref `documentation-file-versioning` (rule, não skill) | C2 |
| `.cursor/skills/project-query-docs-index_*/SKILL.md` | Remover/substituir ref `developer-delphi-providers-pool` | C2 |
| `.cursor/skills/project-consolidate-cursor_V1.1.0/SKILL.md` | `category: quality` → `category: project` | C3 |
| `.cursor/skills/project-consolidate-documentation_*/SKILL.md` | `category: quality` → `category: project` | C3 |
| `.cursor/skills/project-consolidate-orchestrator_*/SKILL.md` | `category: quality` → `category: project` | C3 |
| `.cursor/skills/project-consolidate-source_*/SKILL.md` | `category: quality` → `category: project` | C3 |
| `.cursor/skills/project-open-database-cli_V1.0.0/SKILL.md` | `category: developer-delphi` → `category: project` | C3 |
| `.cursor/skills/documentation-rules_creator_V1.1.0/SKILL.md` | `category: governance-process` → `category: documentation` | C3 |
| `.cursor/skills/governance-master-orchestrator_V1.0.0/SKILL.md` | `category: governance` → `category: governance-process` | C3 |
| `.cursor/skills/governance-pack-checklist-validation_*/SKILL.md` | `category: quality` → `category: governance-process` | C3 |
| `.cursor/skills/governance-spec-evolution_*/SKILL.md` | `category: governance-process` → `category: governance-spec` | C3 |
| `.cursor/rules/rules-pack-manifest_V1.6.0.md` | Atualizar contagem 10→12, adicionar 2 rules, bump V1.6.3 | C4 |
| `.cursor/agents/developer-delphi-agent-*_V1.3.0.md` (10 arquivos) | Re-salvar com acentos UTF-8 corretos | C5 |

### Parte B — Subdivisões

| Operação | Arquivos criados | Arquivo origem |
|---|---|---|
| D1: shared-libraries → 3 filhas | `developer-delphi-to-fpc-shared-libraries-windows_V1.0.0/SKILL.md`, `...-linux_V1.0.0/SKILL.md`, `...-plugins_V1.0.0/SKILL.md` | `developer-delphi-to-fpc-shared-libraries_V1.0.0/SKILL.md` (deprecar) |
| D2: linux-servers → 2 filhas | `developer-delphi-to-fpc-linux-setup_V1.0.0/SKILL.md`, `developer-delphi-to-fpc-linux-daemon_V1.0.0/SKILL.md` | `developer-delphi-to-fpc-linux-servers_V1.0.0/SKILL.md` (deprecar) |
| D3: windows-services → 2 filhas | `developer-delphi-windows-services-setup_V1.0.0/SKILL.md`, `developer-delphi-windows-services-advanced_V1.0.0/SKILL.md` | `developer-delphi-windows-services_V1.0.0/SKILL.md` (deprecar) |

---

## Impacto no `skills-pack-manifest`

Após execução completa:
- Skills removidas (deprecadas): 3 (`shared-libraries`, `linux-servers`, `windows-services`)
- Skills criadas: 7 (3+2+2 filhas)
- Skills corrigidas: 1 (conditional-defines, com rename de pasta)
- **Saldo:** +4 skills → total 182 + 4 = **186 skills** (aproximado; contar após execução)
- Atualizar `skills-pack-manifest` para V1.20.0 após a execução completa.

---

## Estratégia de backup

Antes de qualquer alteração em `.cursor/skills/`:

```powershell
# Backup incremental (não duplicar o .cursor.old — criar novo snapshot)
$stamp = Get-Date -Format "yyyyMMdd-HHmm"
Copy-Item -Recurse "E:\SkillsORM\.cursor" "E:\SkillsORM\.cursor.backup-$stamp" -ErrorAction Stop
```

Ou, se o disco não comportar, backup apenas das pastas afetadas:

```powershell
$affected = @(
  "developer-delphi-programming-conditional-defines_V1.0.0",
  "developer-assembly-instructions_V1.0.0",
  "developer-assembly-registers_V1.0.0",
  "developer-assembly-stack-call_V1.0.0",
  "developer-assembly-x86-fundamentals_V1.0.0",
  "developer-delphi-to-fpc-shared-libraries_V1.0.0",
  "developer-delphi-to-fpc-linux-servers_V1.0.0",
  "developer-delphi-windows-services_V1.0.0"
)
foreach ($s in $affected) {
  Copy-Item -Recurse "E:\SkillsORM\.cursor\skills\$s" "E:\SkillsORM\.cursor.backup-skills\$s"
}
```

---

## Commit sugerido

```
fix(pack): correções pós-auditoria bright-bear + subdivisão de skills densas

C1: fix Q1+Q7 em conditional-defines (rename V1.0.0→V1.1.0)
C2: atualizar 11 refs legacy em 9 skills/agents ativos
C3: corrigir category frontmatter em 9 skills
C4: rules-pack-manifest V1.6.0→V1.6.3 (contagem 10→12)
C5: re-salvar 10 delphi-agent-*_V1.3.0 em UTF-8 (acentos)
D1: shared-libraries 730L → 3 skills (windows/linux/plugins)
D2: linux-servers 707L → 2 skills (setup/daemon)
D3: windows-services 557L → 2 skills (setup/advanced)
skills-pack-manifest V1.19.0→V1.20.0
```

---

## Checklist de verificação pós-execução

- [ ] `validate_pack.py` → 0 issues
- [ ] `validate-skills-consistency.py` → 0 CRITICAL (warns apenas em `plans/audit/L*.md`)
- [ ] `pack_index_db.py --stats` → count atualizado (≈186 skills)
- [ ] `developer-delphi-programming-conditional-defines` — grep `{$IFDEF}` nos campos prescritivos retorna 0 hits ambíguos
- [ ] `project-master-orchestrator` — sem menção a `project-abrir-bancos-cli`
- [ ] 4x `developer-assembly-*` — cross-refs apontam para `developer-assembly-*` (sem `delphi-`)
- [ ] 10 delphi-agent-*_V1.3.0 — grep `mdulo|nica|lgica|excees` retorna 0 hits
- [ ] 9 skills com `category:` corrigido — confirmados via grep no frontmatter
- [ ] rules-pack-manifest — conta 12 rules no narrativo
- [ ] 3 skills deprecadas com ponteiro para filhas
- [ ] Nenhuma skill filha supera 350 linhas

---

*Plano gerado em 24/04/2026. Aguarda aprovação explícita antes de qualquer execução.*
