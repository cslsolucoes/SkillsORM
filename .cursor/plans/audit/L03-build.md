---
name: audit-L03-build
description: Relatório de auditoria do lote L03 — developer-delphi-build-* + debugging-techniques (3 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L02-assembly.md
version: 1.0
date: 2026-04-24
scope: 3 skills em .cursor/skills/developer-delphi-build-* + developer-delphi-debugging-techniques
---

# Relatório Auditoria — Lote L03 build + debugging-techniques

**Data:** 24/04/2026
**Escopo:** 3 arquivos na família:

1. `developer-delphi-build-cross-compiler_V1.0.0`
2. `developer-delphi-build-toolchain_V1.0.0`
3. `developer-delphi-debugging-techniques_V1.0.0`

**Contexto budget consumido:** ~18KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | build-cross-compiler_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠ | ❌ | ❌ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-build-divergencies | **alta** |
| 2 | build-toolchain_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠ | ✅ | ❌ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-build-toolchain | **alta** |
| 3 | debugging-techniques_V1.0.0 | ⚠ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |

## Detalhe por arquivo

### Arquivo 1/3: `developer-delphi-build-cross-compiler_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-build-cross-compiler_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 137 linhas
**Model:** haiku
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-build-cross-compiler
description: Build por linha de comando (Delphi/FPC) com baseline de compatibilidade, tabela de divergências e quality gates.
model: haiku
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre o ciclo completo de build por linha de comando para projetos Delphi/FPC: configuração de `dcc*.cfg` e `fpc*.opts`, execução de compilação Win32/Win64, captura e documentação de divergências entre compiladores em tabela padronizada, e definição de quality gates de compilação. Ela NÃO faz design de domínio, NÃO diagnostica exceções em runtime e NÃO gerencia releases ou pacotes de entrega."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ **Sim.** Checklist linha 68 exige *"Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines"* (que proíbe `{$IFDEF}` em favor de `{$IF DEFINED()}`). Exemplo linha 92: `{$IFDEF FPC}{$mode delphi}{$ENDIF}` — viola a regra cruzada que o próprio Checklist invoca.

- **Q2 (ref quebrada):** ❌ **Múltiplas:**
  - Linha 29: *"use `delphi-fpc-architecture-and-design`"* — skill renomeada (§17, 09/04/2026) para `developer-delphi-architecture-and-design`. **Ref morta.**
  - Linha 32: *"use `delphi-fpc-error-handling-and-diagnostics`"* — renomeada para `developer-delphi-error-handling-and-diagnostics`. **Ref morta.**
  - Linha 41: *"ler `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`"* — skill renomeada para `developer-delphi-programming-conditional-defines_V1.0.0`. **Ref morta.** (Mesmo problema do CLAUDE.md já corrigido pela onda E1.)
  - Linha 130: mesma `project-diretivas-compilacao_V1.1.0/exemplos/...`. **Ref morta.**

- **Q3 (boilerplate):** ⚠ Leve. Checklist Delphi+FPC linhas 61-74 tem 9 bullets do template + 3 bullets específicos (linhas 72-74). Padrão do pack.

- **Q4 (exemplo vazio):** ❌ **Sim.** Linhas 80-96 — 2 exemplos `WriteLn('OK')` que não demonstram nada sobre cross-compilation (objetivo da skill). Deveriam demonstrar uma divergência Delphi↔FPC real (ex.: inline var que FPC rejeita, ou string handler diferente).

- **Q5 (idioma):** Não.

- **Q6 (regra ausente):** Não. Cobre os principais divergências em tabela (string default, inline vars, FireDAC).

- **Q7 (anti-padrão ativo):** ❌ **Sim.** Linha 92: `{$IFDEF FPC}{$mode delphi}{$ENDIF}` — padrão errado ensinado no exemplo. Mesmo problema propagado em L01 e L02.

**Achados de nomenclatura (N):**

- **N1:** ✅.

- **N2 (cross-compile explícito):** ⚠ — Este é **a skill mais cross-compile do pack**. Prefixo atual `developer-delphi-*` é enganoso — um humano buscando "divergências entre Delphi e FPC" olha primeiro skills com `to-fpc` no nome. **Rename urgente:** `developer-delphi-to-fpc-build-divergencies`.

- **N3 (objeto técnico):** ❌ — `build-cross-compiler` é impreciso. A skill **não é** "o cross-compiler" — ela **captura divergências** entre compiladores e define quality gates. Propostas N3:
  - `developer-delphi-to-fpc-build-divergencies` (foco no objeto real: divergências capturadas)
  - `developer-delphi-to-fpc-cross-compile-validation` (foco no processo: validação cross-compile)

- **N4 (sinônimo):** ❌ — **sobreposição com `developer-delphi-build-toolchain`** (arquivo 2 deste lote). Ambas cobrem build Delphi+FPC. Analisando conteúdo:
  - `build-cross-compiler`: foco em **divergências** (tabela + quality gates + workarounds Delphi↔FPC).
  - `build-toolchain`: foco em **paths e comandos** (compile.md, database.md).
  - Complementares em tese, mas na prática o usuário pode confundir (linha 33 de `build-toolchain` diz *"consultar comandos CLI de banco de dados"* → usa `build-toolchain`; linha 34 diz *"diagnosticar erros de compilação ou divergências cross-compiler"* → usa `build-cross-compiler`). **Decisão:** manter separação mas tornar nomes inequívocos.

- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** pasta `exemplos/` **não existe**. Todos os exemplos são inline.

**Correção proposta:**

```diff
@@ linha 29 (When NOT to use — ref quebrada)
-- Não usar para design de domínio ou arquitetura modular → use `delphi-fpc-architecture-and-design`.
+- Não usar para design de domínio ou arquitetura modular → use `developer-delphi-architecture-and-design`.

@@ linha 32 (ref quebrada)
-- Não usar para diagnóstico de exceções em runtime → use `delphi-fpc-error-handling-and-diagnostics`.
+- Não usar para diagnóstico de exceções em runtime → use `developer-delphi-error-handling-and-diagnostics`.

@@ linha 41 (ref quebrada path antigo)
-1. Ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` e `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`.
+1. Ler `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md` e `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`.

@@ linha 130 (Referencias — path antigo)
-- `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`
+- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
```

```diff
@@ linhas 76-96 (substituir Exemplo mínimo compilável por exemplo de divergência real)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleBuildDelphi;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-build-cross-compiler');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleBuildFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-begin
-  WriteLn('OK -- developer-delphi-build-cross-compiler');
-end.
-```
+## Exemplo: divergência real entre Delphi e FPC
+
+Unit que ilustra uma divergência típica capturada por esta skill — inline vars (só Delphi 10.3+), declaração tradicional (Delphi + FPC).
+
+**Versão que compila apenas em Delphi (inline vars — não portável):**
+
+```pascal
+unit Sample.Divergencies.DelphiOnly;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+interface
+
+function Somar(A, B: Integer): Integer;
+
+implementation
+
+function Somar(A, B: Integer): Integer;
+begin
+  var LResult: Integer := A + B;  // INLINE VAR — só Delphi 10.3+; FPC falha com E2029
+  Result := LResult;
+end;
+
+end.
+```
+
+**Versão portável (Delphi + FPC) — declaração tradicional:**
+
+```pascal
+unit Sample.Divergencies.Portable;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+interface
+
+function Somar(A, B: Integer): Integer;
+
+implementation
+
+function Somar(A, B: Integer): Integer;
+var
+  LResult: Integer;
+begin
+  LResult := A + B;
+  Result := LResult;
+end;
+
+end.
+```
+
+**Entrada esperada na tabela de divergências:**
+
+| Tópico | Delphi | FPC | Status | Workaround |
+|--------|--------|-----|--------|------------|
+| inline vars (`var X: T := ...`) | Suportado (10.3+) | Não suportado | Incompatível | Usar bloco `var..begin` tradicional |
```

**Comentário:** exemplo novo é didático (mostra o que a skill realmente captura) e também corrige o anti-padrão `{$IFDEF FPC}` → `{$IF DEFINED(FPC)}`.

**Nome proposto:** `developer-delphi-to-fpc-build-divergencies` — aplica N2 + N3 + N4:

- N2: `to-fpc` explícito.
- N3: `build-divergencies` é o objeto técnico real (não "cross-compiler" que é ferramenta, e skill não é a ferramenta).
- N4: separa conceitualmente de `build-toolchain` (paths) — esta foca em captura de divergências.

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md:105, 157, 181` (família G + matriz + dependências).
- `developer-delphi-architecture-and-design_V1.0.0/SKILL.md:28` (When NOT to use).
- `developer-delphi-architecture-modules_V1.0.0/SKILL.md:33, 59` (When NOT to use + Dependências).
- `developer-delphi-build-toolchain_V1.0.0/SKILL.md:34` (When NOT to use — auto-referência circular: menciona `delphi-fpc-build-cross-compiler` que deveria ser `developer-delphi-build-cross-compiler` ou após rename o novo nome).
- `developer-delphi-docs-to-structured-code` (se existir menciona) — validar na L04.

---

### Arquivo 2/3: `developer-delphi-build-toolchain_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-build-toolchain_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 12-15)
**Tamanho:** 145 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-build-toolchain
description: Use when the user asks about compiling the project (Delphi, FPC, Go, Python), build commands, config files (dcc32.cfg, fpc32.opts, go.mod, requirements.txt), or database CLI access (mysql, sqlite3, isql, psql, sqlcmd), paths of tools, or connection config (Data/config.ini, config.json). Canonical docs: .cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md and .cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/database.md.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill é a referência canônica para compilação (Delphi, FPC, Go, Python) e acesso a bancos por CLI no **repositório aberto no workspace**. Ela aponta para os documentos de verdade única (`compile.md` e `database.md`) e exige leitura desses arquivos antes de responder com paths, parâmetros ou comandos. Política de paths: **dentro do repo** usar sempre **`${workspaceFolder}/...`** em tarefas/editores; **fora do repo** (FPC, RAD, etc.) caminhos absolutos ou placeholders (`{FPC_ROOT}`). Ela NÃO implementa lógica de negócio, NÃO opera bancos diretamente e NÃO configura diretivas de engine — apenas orienta como compilar e aceder a bancos com os dados locais do workspace."

**Achados de qualidade (Q):**

- **Q1:** ❌ Sim. Checklist (linha 81) exige conformidade com `developer-delphi-programming-conditional-defines`. Exemplo linha 102: `{$IFDEF FPC}{$mode delphi}{$ENDIF}` viola a regra.

- **Q2:** ❌ Refs quebradas:
  - Linha 31: *"use `project-abrir-bancos-cli`"* — esta skill foi renomeada/portada. No pack atual é `project-open-database-cli_V1.0.0` (conforme `ls` do L01 do plano). **Ref morta.**
  - Linha 33: *"use `delphi-fpc-architecture-and-design`"* — renomeada para `developer-delphi-architecture-and-design`. **Ref morta.**
  - Linha 34: *"use `delphi-fpc-build-cross-compiler`"* — renomeada para `developer-delphi-build-cross-compiler`. **Ref morta.**

- **Q3:** ⚠ Leve. Checklist 9 bullets do template.

- **Q4:** ❌ Sim. Linhas 86-106 — `WriteLn('OK')` triviais para uma skill cujo objeto é toolchain (poderia mostrar `dcc32 -B MeuProjeto.dpr` + `fpc @fpc64.opts MeuProjeto.lpr` como exemplo real de uso do toolchain).

- **Q5:** Não.

- **Q6:** Não.

- **Q7:** ❌ Sim. Mesmo `{$IFDEF FPC}` anti-padrão.

**Achados de nomenclatura (N):**

- **N1:** ✅.

- **N2:** ⚠ — skill descreve **"Delphi, FPC, Go, Python"** (linha 3). É cross-compile massivo. Prefixo `developer-delphi-*` só acha Delphi. **Rename:** `developer-delphi-to-fpc-build-toolchain` (foca nas 2 linguagens Pascal — Go e Python podem ficar em skill separada futura ou serem subseção).

- **N3:** ✅ — `build-toolchain` é objeto técnico claro (o toolchain de build: compiladores, configs, paths).

- **N4:** ❌ — Sobreposição conceitual com `build-cross-compiler` (arquivo 1). **Diferenciação proposta:**
  - `build-toolchain`: comandos, paths, configs (o **como**).
  - `build-cross-compiler` → renomeio para `build-divergencies`: divergências capturadas entre Delphi↔FPC (o **o quê** + workarounds).

- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:**

- `exemplos/compile.md` — documento canônico de compilação (analisado em auditoria SIMAO prévia — conteúdo sólido, 498 linhas).
- `exemplos/database.md` — documento canônico de CLI de banco (403 linhas).

**Correção proposta:**

```diff
@@ linha 31 (When NOT to use — ref quebrada)
-- Não usar para operar bancos interativamente via terminal → use `project-abrir-bancos-cli`.
+- Não usar para operar bancos interativamente via terminal → use `project-open-database-cli`.

@@ linha 33 (ref quebrada)
-- Não usar para definir arquitetura de módulos → use `delphi-fpc-architecture-and-design`.
+- Não usar para definir arquitetura de módulos → use `developer-delphi-architecture-and-design`.

@@ linha 34 (ref quebrada)
-- Não usar para diagnosticar erros de compilação ou divergências cross-compiler → use `delphi-fpc-build-cross-compiler`.
+- Não usar para diagnosticar erros de compilação ou divergências cross-compiler → use `developer-delphi-build-cross-compiler`.
```

```diff
@@ linhas 86-106 (substituir Exemplo mínimo compilável por exemplo de toolchain real)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleCompileDocsDelphi;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-build-toolchain');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleCompileDocsFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-begin
-  WriteLn('OK -- developer-delphi-build-toolchain');
-end.
-```
+## Exemplo: comandos reais do toolchain
+
+Esta skill é sobre **paths + comandos**, não sobre escrever código. Exemplos são invocações reais.
+
+**Delphi — compilar `MeuProjeto.dpr` em 32 e 64 bits:**
+
+```bat
+:: Compilação Delphi Win32 (lê dcc32.cfg automaticamente da raiz do projeto)
+dcc32 -B "MeuProjeto.dpr"
+
+:: Compilação Delphi Win64
+dcc64 -B "MeuProjeto.dpr"
+```
+
+**FPC/Lazarus — compilar `MeuProjeto.lpr` em 32 e 64 bits:**
+
+```bat
+:: Compilação FPC Win32 (@fpc32.opts é obrigatório; FPC não carrega automaticamente)
+fpc @fpc32.opts "MeuProjeto.lpr"
+
+:: Compilação FPC Win64
+fpc @fpc64.opts "MeuProjeto.lpr"
+```
+
+**Acesso a banco por CLI (exemplo SQLite):**
+
+```bat
+:: Abrir banco SQLite com paths do projeto (Data\config.ini aponta para Data\Config.db)
+sqlite3 "Data\Config.db"
+
+:: Executar script SQL em SQL Server via sqlcmd
+sqlcmd -S 10.100.2.3,1433 -U sa -P senha -d MeuBanco -i "Data\script.sql"
+```
+
+Para a lista completa de compiladores + bancos + paths, ler obrigatoriamente:
+
+- `exemplos/compile.md` (compilação)
+- `exemplos/database.md` (banco CLI)
```

**Comentário:** exemplo novo demonstra o propósito real da skill (toolchain = comandos CLI + paths) em vez de `WriteLn('OK')`.

**Nome proposto:** `developer-delphi-to-fpc-build-toolchain` (N2 — cross-compile Delphi+FPC + Go + Python).

**Dependências cruzadas afetadas:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md:256` (Referências cita exemplos/compile.md).
- `developer-delphi-build-cross-compiler_V1.0.0/SKILL.md:33` (When NOT to use menciona `developer-delphi-build-toolchain`).
- `developer-delphi-assembly-orchestrator_V1.1.0/SKILL.md:166` (Referencias).
- CLAUDE.md já corrigido na Onda E1 — aponta para `developer-delphi-build-toolchain_V1.0.0/exemplos/` (ficará desatualizado com rename; precisa atualizar junto).
- Conteúdo dentro dos próprios arquivos `exemplos/compile.md` e `exemplos/database.md` referencia path atual (validar).

---

### Arquivo 3/3: `developer-delphi-debugging-techniques_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-debugging-techniques_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 168 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-debugging-techniques
description: Técnicas avançadas de depuração em Delphi — breakpoints condicionais, watches, CPU View, FastMM4, EurekaLog/MadExcept, OutputDebugString e estratégias de diagnóstico.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre técnicas avançadas de depuração de aplicações Delphi: uso do debugger integrado do IDE (breakpoints condicionais, watches, call stack, CPU View), rastreamento de memory leaks com FastMM4, geração de crash reports com EurekaLog/MadExcept, diagnóstico não-intrusivo com `OutputDebugString` e estratégias sistémicas como binary search debugging e logging estratégico. Ela NÃO modela hierarquias de exceções nem define políticas de tratamento de erro — essas responsabilidades pertencem a `developer-delphi-error-handling-and-diagnostics`."

**Achados de qualidade (Q):**

- **Q1:** ⚠ Leve. Linha 66 exige `OutputDebugString` protegido por `{$IFDEF DEBUG}` — e depois a tabela Anti-padrões (linha 133) reforça. Mas a skill usa `{$IFDEF DEBUG}` ela mesma no exemplo (linhas 98-100). DEBUG é global do build — aceitável usar `{$IFDEF DEBUG}`, mas para consistência total com regra canônica poderia ser `{$IF DEFINED(DEBUG)}`. **Baixa severidade** — DEBUG é define de compilador, não USE_X de engine.

- **Q2:** Não.

- **Q3:** ⚠ Leve. Checklist 9 bullets, mas bem-personalizado (linhas 65-72 são específicos da skill: FastMM4, OutputDebugString, crash reporter, breakpoints condicionais).

- **Q4:** Não — exemplo com try/except é didático e cross-compile.

- **Q5:** Não.

- **Q6:** Não — cobre FastMM4, crash reporters, atalhos IDE, estratégias.

- **Q7:** Não. O `{$IFDEF FPC}` na linha 114 é no exemplo FPC (declarando modo delphi) — **este sim é o anti-padrão clássico, mas leve neste contexto** porque é reconhecível como template propagado do pack.

**Achados de nomenclatura (N):**

- **N1:** ✅.

- **N2:** ⚠ — skill é **quase Delphi-only** (foca em IDE Delphi, FastMM4 é Delphi, EurekaLog/MadExcept são Delphi). Mas FPC também tem debugging (GDB integrado ao Lazarus, heaptrc). A skill cobre apenas o lado Delphi. **Poderia ser:**
  - Manter como `developer-delphi-debugging-techniques` (foco declarado: "aplicações Delphi" linha 18).
  - Ou dividir: `developer-delphi-debugging-techniques` (Delphi IDE + FastMM4 + EurekaLog) + skill nova `developer-delphi-to-fpc-debugging-techniques` (debugger Lazarus + heaptrc + cmp).

  **Decisão:** manter atual. Sintoma N2 baixo.

- **N3:** ✅ — `debugging-techniques` claro.

- **N4:** ✅ — distinto de `assembly-debugging` (que é ASM-specific).

- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** tem `exemplos/`, `templates/`, `consultas_rapidas/` (linha final do bash listing).

**Correção proposta (baixa):**

```diff
@@ linhas 98-100 (exemplo — opcionalmente trocar {$IFDEF DEBUG})
 begin
-  {$IFDEF DEBUG}
+  {$IF DEFINED(DEBUG)}
   OutputDebugString('SampleDebuggingDelphi: iniciando');
   {$ENDIF}
   try

@@ linha 114 (exemplo FPC)
 program SampleDebuggingFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
 {$APPTYPE CONSOLE}
```

**Comentário:** correções consistência com regra canônica. Baixa prioridade — DEBUG é global e FPC é built-in.

**Nome proposto:** manter.

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma neste lote (CLAUDE.md já corrigido na sessão anterior desta fase).

### E4-candidatas (Q1/Q7 para fix imediato)

**Prioridade alta:**

1. `developer-delphi-build-cross-compiler_V1.0.0/SKILL.md:92` — `{$IFDEF FPC}` → `{$IF DEFINED(FPC)}` (parte da substituição completa do Exemplo mínimo por exemplo de divergência real — diff completo acima).
2. `developer-delphi-build-toolchain_V1.0.0/SKILL.md:102` — `{$IFDEF FPC}` → corrigido na substituição do Exemplo mínimo por exemplo de toolchain real — diff completo acima.

**Prioridade baixa (consistência):**

3. `developer-delphi-debugging-techniques_V1.0.0/SKILL.md:98-100, 114` — opcional, DEBUG é global.

### E5-candidatas (renames propostos)

**Prioridade alta:**

1. `developer-delphi-build-cross-compiler` → `developer-delphi-to-fpc-build-divergencies` (N2 + N3 + N4 — skill é **sobre divergências Delphi↔FPC**, nome atual é enganoso).
2. `developer-delphi-build-toolchain` → `developer-delphi-to-fpc-build-toolchain` (N2 — cross-compile Delphi+FPC+Go+Python).

**Prioridade baixa:**

3. `developer-delphi-debugging-techniques` → manter.

**Ordem do rename:** Frente E5 em 2 sub-etapas (build-divergencies primeiro porque tem mais refs circulares).

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 build-cross-compiler:29, 32, 41, 130** — 4 refs a skills renomeadas no §17 (09/04 e 17/04).
2. **Q2 build-toolchain:31, 33, 34** — 3 refs a skills renomeadas.
3. **Q4 build-cross-compiler e build-toolchain** — substituir exemplos triviais `WriteLn('OK')` por demonstrações reais (divergência Delphi↔FPC + comandos de toolchain). Diffs completos acima.
4. **Q3 nas 3 skills** — Checklist Delphi+FPC genérico; personalizar com bullets específicos de cada skill (build-cross-compiler já tem 3 específicos — ok; build-toolchain não tem — adicionar; debugging-techniques está bem personalizado).

### Placement migrations

Nenhuma.

---

## Síntese do lote L03

- **3 skills auditadas** com detalhe completo.
- **2 skills críticas** (build-cross-compiler e build-toolchain) com Q1+Q2+Q4+Q7 — todas as refs para famílias renomeadas `delphi-fpc-*` / `project-*`.
- **1 skill sólida** (debugging-techniques) com apenas Q1 muito leve.
- **2 renames propostos** `to-fpc-*`:
  - `build-cross-compiler` → `build-divergencies` (foco em divergências, N3+N4).
  - `build-toolchain` → `to-fpc-build-toolchain` (N2).
- **Total refs quebradas neste lote:** 7 (3 em toolchain + 4 em cross-compiler).

**Próxima onda sugerida:** L04 (docs) — 2 skills (docs-to-structured-code, documentation-governance).

**Commit sugerido:** `docs(audit): relatório lote L03 build + debugging — 7 refs quebradas, 2 renames críticos`
