---
name: audit-L01-architecture
description: Relatório de auditoria do lote L01 — architecture + orchestrator (3 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L09-patterns-programming.md
version: 1.0
date: 2026-04-24
scope: 3 skills em .cursor/skills/developer-delphi-architecture-* e developer-delphi-orchestrator
---

# Relatório Auditoria — Lote L01 architecture + orchestrator

**Data:** 24/04/2026
**Escopo:** 3 arquivos na família:

1. `developer-delphi-architecture-and-design_V1.0.0`
2. `developer-delphi-architecture-modules_V1.0.0`
3. `developer-delphi-orchestrator_V1.1.0`

**Contexto budget consumido:** ~18KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | architecture-and-design_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ⚠ | ✅ | ❌ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor + remover path absoluto | developer-delphi-to-fpc-architecture-and-design | **alta** |
| 2 | architecture-modules_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ⚠ | ✅ | ❌ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor + remover path absoluto + refs GestorERP | developer-delphi-to-fpc-architecture-modules | **alta** |
| 3 | orchestrator_V1.1.0 | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ | ⚠ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-orchestrator (ou rename com complemento) | **alta** |

## Detalhe por arquivo

### Arquivo 1/3: `developer-delphi-architecture-and-design_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-architecture-and-design_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linha 13-15)
**Tamanho:** 172 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-architecture-and-design
description: Arquitetura modular, facades, DI/IoC por interfaces, padrões Fluent/Factory e estratégia de evolução de schema.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 19):

> "Esta skill cobre decisões de arquitetura modular para projetos Delphi/FPC: fronteiras de módulos, contratos por interfaces (`I*`), injeção de dependência via constructor + Factory `New`, padrões Fluent e estratégia de evolução de schema (scripts up/down). Ela NÃO executa build, NÃO diagnostica erros de compilação e NÃO faz tuning de performance — cada um desses domínios tem sua própria skill especializada."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ Sim. A skill pertence à família "Delphi/FPC" (linha 19: *"projetos Delphi/FPC"*) e tem **Checklist Delphi+FPC** (linhas 52-64), mas o **"Exemplo mínimo compilável"** (linhas 66-85) usa `{$IFDEF FPC}` (linha 80) — padrão que a skill irmã `developer-delphi-programming-conditional-defines` proíbe (Regra 2). Auto-contradição transitiva: a skill exige *"Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines"* no próprio Checklist (linha 58) mas o exemplo da skill descumpre.
  - Regra cruzada declarada (linha 58): *"Diretivas {$IFDEF} conforme developer-delphi-programming-conditional-defines; sem mistura com paths"*
  - Exemplo que viola (linha 80): `{$IFDEF FPC}{$mode delphi}{$ENDIF}`
  - Padrão correto (conforme skill canônica): `{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}`

- **Q2 (ref quebrada):** ❌ Sim. Linha 165 aponta para skill antiga:
  - *"`.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`"* — esta skill foi renomeada para `developer-delphi-programming-conditional-defines_V1.0.0` no refactor §17 (17/04/2026). Path morto.
  - Linha 168: *"`E:\CSL\ProvidersORM\src` (modelo de referência)"* — **path absoluto** do clone este; viola boa prática de portabilidade. Se esta skill for propagada via `sync-cursor-pack` para outro clone, o path aponta para pasta que não existe naquele clone. Deveria ser `src/` (relativo) ou movido para `.workspace/` se essencialmente específico.

- **Q3 (boilerplate):** ⚠ Leve. Checklist Delphi+FPC (linhas 52-64) é **9 bullets copiados literais** de um template; skill adiciona apenas 3 bullets específicos (60-64). O padrão do pack é ter checklists personalizados por domínio.

- **Q4 (exemplo vazio):** ❌ Sim. Os 2 "Exemplo mínimo compilável" (Delphi e FPC, linhas 68-85) são `WriteLn('OK -- developer-delphi-architecture-and-design');` — não demonstram **nada** da responsabilidade da skill (arquitetura modular, DI/IoC, facade). A "Unit de referência" (linhas 87-135) é didática boa (IRepository + IService + TService com DI via constructor + Factory New), mas está separada do "Exemplo mínimo" sem integração.

- **Q5 (idioma):** ⚠ Leve. Comentários em pt-BR misturados com nomes de artefato em inglês — padrão aceitável no pack, mas o título "Avaliacao de risco e confirmacao" (linha 161) está sem acento. Mesma linha 176 da skill seguinte. Inconsistência leve.

- **Q6 (regra ausente):** Não. A skill tem seções Workflow, Checklist, Anti-padrões, Métricas.

- **Q7 (anti-padrão ativo):** ❌ Sim. O `{$IFDEF FPC}` na linha 80 é anti-padrão ativo: o exemplo **ensina** o padrão errado (consistente com o problema caso-zero descrito em L09).

**Achados de nomenclatura (N):**

- **N1 (prefixo):** ✅ — `developer-delphi-architecture-and-design` revela família e escopo.
- **N2 (cross-compile explícito):** ⚠ — A skill **se declara** Delphi+FPC (linha 19 *"projetos Delphi/FPC"*, Checklist com `fpc32+fpc64` linha 54) mas o prefixo `developer-delphi-*` sugere só Delphi. Candidato forte a rename `developer-delphi-to-fpc-architecture-and-design` aplicando N2.
- **N3 (objeto técnico):** ✅ — `architecture-and-design` é preciso.
- **N4 (sinônimo):** ✅ — distinto de `architecture-modules` (um é design, outro é organização física).
- **N5 (audiência):** ✅ — dev-delphi.

**Placement:**

- Atual: `.cursor/`
- Correto: `.cursor/` (arquitetura genérica). **Mas** a ref `E:\CSL\ProvidersORM\src` (linha 168) é específica deste clone — deveria ser relativa (`src/` ou `<projeto>/src/`) ou migrar para nota em `.workspace/`.
- Plano de migração: manter skill em `.cursor/`, trocar path absoluto por relativo.

**Exemplos/templates internos:** pasta `exemplos/` **não existe** (só `SKILL.md` na pasta). Todos os exemplos são inline.

**Correção proposta (texto completo antes/depois):**

```diff
@@ linhas 66-85 (substituir Exemplo mínimo compilável)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-```pascal
-program SampleArchDelphi;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-architecture-and-design');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-```pascal
-program SampleArchFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-architecture-and-design');
-end.
-```
+## Exemplo mínimo compilável
+
+Programa mínimo que demonstra DI via Factory `New` — cross-compile Delphi+FPC. Para a hierarquia de interfaces completa, ver seção "Unit de referência" abaixo.
+
+**Delphi (dcc32 / dcc64):**
+```pascal
+program SampleArchDelphi;
+{$APPTYPE CONSOLE}
+uses Sample.Arch;
+var
+  LRepo: IRepository;
+  LSvc: IService;
+begin
+  LRepo := TStubRepository.New; // Factory + interface
+  LSvc := TService.New(LRepo);   // DI via constructor
+  WriteLn('Count=', LSvc.Execute);
+end.
+```
+
+**Free Pascal (fpc32 / fpc64):**
+```pascal
+program SampleArchFPC;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+{$APPTYPE CONSOLE}
+uses Sample.Arch;
+var
+  LRepo: IRepository;
+  LSvc: IService;
+begin
+  LRepo := TStubRepository.New;
+  LSvc := TService.New(LRepo);
+  WriteLn('Count=', LSvc.Execute);
+end.
+```
```

```diff
@@ linha 90 (dentro de Unit de referência — corrigir diretiva FPC)
 unit Sample.Arch;
-{$IFDEF FPC}
+{$IF DEFINED(FPC)}
   {$mode delphi}
   {$H+}
 {$ENDIF}
```

```diff
@@ linha 165 (corrigir ref quebrada)
-- `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`
+- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`

@@ linha 168 (remover path absoluto do clone)
-- `E:\CSL\ProvidersORM\src` (modelo de referência)
+- `src/` do projeto onde esta skill é aplicada (modelo de referência)
```

**Comentário:** as 3 correções acima resolvem simultaneamente Q1+Q7 (diretivas), Q2 (ref quebrada), Q4 (exemplo trivial) e Q5 leve (path absoluto). O exemplo novo passa de "WriteLn OK" para um uso real de DI+Factory+interface — exatamente o que a skill ensina.

**Nome proposto:** `developer-delphi-to-fpc-architecture-and-design` — aplica N2 com alta confiança (skill explicitamente Delphi+FPC em responsabilidade, checklist e exemplos).

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-architecture-modules_V1.0.0/SKILL.md:32, 57` (When NOT to use e Dependências)
- `developer-delphi-orchestrator_V1.1.0/SKILL.md:119` (tabela família I)
- `developer-delphi-orchestrator_V1.1.0/SKILL.md:157` (matriz de roteamento)
- CLAUDE.md: sem grep match.
- Manifesto `skills-pack-manifest_V1.17.0.md`: entrada de rename a adicionar.

---

### Arquivo 2/3: `developer-delphi-architecture-modules_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-architecture-modules_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (linhas 13-15)
**Tamanho:** 191 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-architecture-modules
description: Modularização em Delphi — units, packages BPL (runtime/design-time), namespaces, resolução de dependências circulares, plugin via DLL, regras de coesão e acoplamento.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 19):

> "Esta skill cobre a organização modular de projetos Delphi: estrutura de units e packages (`.bpl`), distinção entre packages runtime e design-time, packages estáticos vs dinâmicos, detecção e resolução de dependências circulares entre units, dependency injection sem framework externo, arquitetura de plugin via DLL + interface, regras de coesão/acoplamento e convenções de nomenclatura por camada."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ Sim. Mesmo padrão do arquivo 1: Checklist Delphi+FPC (linhas 61-72) exige consistência cross-compile, mas o exemplo (linha 112) usa `{$IFDEF FPC}` + exemplo de unit (linha 124) idem.
- **Q2 (ref quebrada):** ❌ Sim.
  - Linha 185: *"`E:\CSL\ProvidersORM\src` (modelo de referência de modularização)"* — path absoluto do clone.
  - Linha 186: *"`.cursor/skills/project-diretivas-compilacao_V1.1.0/`"* — referência morta (skill renomeada).
- **Q3 (boilerplate):** ⚠ Leve. Checklist (linhas 61-72) tem 9 bullets do template + 2 específicos. Pelo menos tem bullets 64-66 específicos da skill (circular reference, interface pública, Factory pública).
- **Q4 (exemplo vazio):** ❌ Sim. "Exemplo mínimo compilável" linhas 97-118 são `WriteLn('OK')` — não demonstram modularização. A "Unit de referência" (linhas 120-147) é melhor mas também não mostra o problema real (circular dep resolution, plugin via DLL).
- **Q5 (idioma):** ⚠ Leve.
  - Linha 89-93: bloco "Namespace Delphi" usa `GestorERP.Clientes.Repository.SQLite` e `GestorERP.Common.Types` e `GestorERP.Plugins.Pagamento.Interfaces` como exemplos. **Isto é conteúdo específico do clone GestorERP** (mesmo problema detectado em L09 para `oop-fluent` e `oop-naming`). A skill está misturando padrão genérico com exemplos MXX de outro clone.
- **Q6 (regra ausente):** Não.
- **Q7 (anti-padrão ativo):** ❌ Sim. Mesmo `{$IFDEF FPC}` anti-padrão.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ⚠ — skill menciona FPC no Checklist e declara "Delphi" na responsabilidade (linha 19) — ambíguo. Na prática cobre Delphi+FPC. Candidato rename.
- **N3:** ✅ — `architecture-modules` claro.
- **N4:** ✅ — distinto de `architecture-and-design`.
- **N5:** ✅.

**Placement:**

- Atual: `.cursor/`
- Correto: `.cursor/` para conteúdo genérico. **Mas** os 3 exemplos de namespace (`GestorERP.*`) na linha 89-93 são específicos do clone GestorERP — deveriam ser genéricos (`Empresa.Produto.Modulo`) ou ir para `.workspace/` do GestorERP.

**Exemplos/templates internos:**

- `exemplos/bpl_module.pas` — módulo BPL exemplo (não lido nesta onda)
- `exemplos/circular_dep.pas` — resolução de circular dep
- `exemplos/modulo_isolado.pas` — interface pública + impl privada
- `exemplos/unit_namespaces.pas` — convenção de namespaces
- `templates/TEMPLATE_bpl_loader.pas` — loader de BPL em runtime
- `templates/TEMPLATE_modulo_interface.pas` — módulo com interface pública
- `consultas_rapidas/bpl_deploy.md`
- `consultas_rapidas/modularizacao_regras.md`
- `consultas_rapidas/namespaces_conv.md`

**Correção proposta:**

```diff
@@ linhas 89-93 (generalizar namespace)
-**Namespace Delphi (ponto como separador):**
-```
-Empresa.Produto.Modulo.Unit
-GestorERP.Clientes.Repository.SQLite
-GestorERP.Common.Types
-GestorERP.Plugins.Pagamento.Interfaces
-```
+**Namespace Delphi (ponto como separador):**
+```
+Empresa.Produto.Modulo.Unit
+Acme.Vendas.Repository.SQLite
+Acme.Common.Types
+Acme.Plugins.Pagamento.Interfaces
+```
+
+> Exemplos específicos por projeto (ex.: `GestorERP.Clientes.*`, `ProvidersORM.Modulos.Database.*`) ficam em `.workspace/skills/<projeto>-namespaces_V*/SKILL.md` do respectivo clone.
```

```diff
@@ linhas 97-118 (substituir Exemplo mínimo compilável)
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleModulesDelphi;
-{$APPTYPE CONSOLE}
-uses SysUtils;
-begin
-  WriteLn('OK -- developer-delphi-architecture-modules');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleModulesFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-{$APPTYPE CONSOLE}
-uses SysUtils;
-begin
-  WriteLn('OK -- developer-delphi-architecture-modules');
-end.
-```
+**Delphi (dcc32 / dcc64):**
+
+Programa demonstrando uso de módulo via interface pública (Factory). Resolve implicitamente o caso de circular-dep porque o host só conhece a interface.
+
+```pascal
+program SampleModulesDelphi;
+{$APPTYPE CONSOLE}
+uses SysUtils, Acme.Pagamento.Interfaces;
+var
+  LPag: IPagamentoModule;
+begin
+  LPag := TPagamentoFactory.New;  // módulo isolado atrás de interface
+  LPag.Initialize;
+  try
+    WriteLn('OK: ', LPag.Processar(100.50));
+  finally
+    LPag.Finalize;
+  end;
+end.
+```
+
+**Free Pascal (fpc32 / fpc64):**
+
+```pascal
+program SampleModulesFPC;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+{$APPTYPE CONSOLE}
+uses SysUtils, Acme.Pagamento.Interfaces;
+var
+  LPag: IPagamentoModule;
+begin
+  LPag := TPagamentoFactory.New;
+  LPag.Initialize;
+  try
+    WriteLn('OK: ', LPag.Processar(100.50));
+  finally
+    LPag.Finalize;
+  end;
+end.
+```
```

```diff
@@ linhas 124-125 (Unit de referência — corrigir IFDEF)
 unit GestorERP.Pagamento.Interfaces;
-{$IFDEF FPC}
+{$IF DEFINED(FPC)}
   {$mode delphi}
 {$ENDIF}
```

```diff
@@ linhas 185-186 (refs)
-- `E:\CSL\ProvidersORM\src` (modelo de referência de modularização)
-- `.cursor/skills/project-diretivas-compilacao_V1.1.0/`
+- `src/` do projeto onde esta skill é aplicada (modelo de referência de modularização)
+- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/`
```

**Comentário:** correções seguem mesmo padrão do arquivo 1 — substituir `WriteLn('OK')` por exemplo que demonstra a responsabilidade, corrigir IFDEF → IF DEFINED, corrigir refs quebradas, generalizar namespaces fora-do-clone.

**Nome proposto:** `developer-delphi-to-fpc-architecture-modules` — aplica N2 (skill explicitamente cross-compile).

**Dependências cruzadas afetadas:**

- `developer-delphi-architecture-and-design_V1.0.0/SKILL.md` (Skills relacionadas implícita)
- `developer-delphi-orchestrator_V1.1.0/SKILL.md:120` (tabela família I)
- Em 9 outras skills grepped que mencionam "architecture-modules" como dependência — validar em ondas posteriores.

---

### Arquivo 3/3: `developer-delphi-orchestrator_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-orchestrator_V1.1.0\SKILL.md`
**FileVersion:** 1.1.0 (linhas 13-15)
**Tamanho:** 265 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-orchestrator
description: Orquestra as skills do kit Delphi/FPC por cenário de desenvolvimento, mapeando todas as famílias A–K, com árvore de decisão, guia de quando usar cada skill e rastreabilidade.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 19):

> "Esta skill atua como ponto central de coordenação para tarefas multi-etapa no kit Delphi/FPC. Classifica o cenário de desenvolvimento, seleciona e ordena as skills especializadas necessárias, aplica gates de risco antes de ações destrutivas e consolida evidências de build, testes e documentação ao final do fluxo. Não executa implementações diretas — delega a skills especializadas com rastreabilidade explícita de cada etapa."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ Sim. Checklist Delphi+FPC exige `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines` (linha 192: *"Diretivas `{$IFDEF}` conforme..."*). Mas exemplo mínimo (linhas 212-218) usa `{$IFDEF FPC}` — padrão errado.

- **Q2 (ref quebrada):** ❌ Sim. Linha 69: tabela "Família C — Patterns (Design Patterns)" referencia `developer-delphi-patterns-composition` como **"Orquestradora Patterns"**. Em L09 já identificamos que este nome `composition` conflita com N3/N4 e foi proposto rename para `patterns-orchestrator`. Se L09 for executada, esta linha fica desatualizada. **Não é ref quebrada hoje, mas é uma co-referência a ajustar em onda E5.**
  - Linha 257 (mais crítico): referência direta a **path antigo** `project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md` — skill já renomeada. Ref quebrada.
  - Linha 183: `project-refactoring-compatibility-policy` — esta skill foi renomeada para `governance-refactoring-compatibility-policy` conforme CLAUDE.md corrigido nesta sessão. Ref quebrada.
- **Q3 (boilerplate):** ✅ — orchestrator tem conteúdo específico (famílias A-K, matriz de roteamento). Pouco boilerplate.

- **Q4 (exemplo vazio):** ❌ Sim. Linhas 197-219: 2 exemplos `WriteLn('OK -- developer-delphi-orchestrator V1.1.0');` — o clássico anti-padrão Q4. Para uma skill orquestradora, exemplo mínimo deveria mostrar **um fluxo orquestrado real** (ex.: "pedido: adicionar nova engine de banco" → passa por `programming-conditional-defines` + `architecture-modules` + `build-cross-compiler` + `testing-integration`).

- **Q5 (idioma):** ✅ — consistente.

- **Q6 (regra ausente):** Não.

- **Q7 (anti-padrão ativo):** ❌ Sim. `{$IFDEF FPC}` em 213 + Linha 214 `{$mode delphi}` dentro do bloco, conforme os outros 2 arquivos da família.

**Achados de nomenclatura (N):**

- **N1 (prefixo):** ✅ — prefixo claro.
- **N2 (cross-compile explícito):** ⚠ — orchestrator do "kit Delphi/FPC" (literal linha 3, 19). Prefixo `developer-delphi-*` é ambíguo. Candidato.
- **N3 (objeto técnico):** ❌ — `orchestrator` sozinho é genérico demais (aparece em ≥5 skills: developer-delphi-orchestrator, developer-vuejs-orchestrator, documentation-orchestrator, governance-orchestrator, quality-orchestrator, version-orchestrator, horse-orchestrator, mobile-orchestrator). **A palavra "orchestrator" não revela o objeto técnico orquestrado.** O leitor só sabe "é um orquestrador" mas não de quê.
  - Problema específico desta skill: ela orquestra **o kit Delphi/FPC** como um todo (famílias A-K). Outras orchestradoras são mais específicas (horse-, mobile-, assembly-). Esta é a "master orchestrator" do stack Delphi/FPC.
  - Proposta N3: `developer-delphi-to-fpc-kit-orchestrator` ou `developer-delphi-to-fpc-master-orchestrator`. Torna explícito que é "o" orchestrator do kit (nível master), não um sub-orquestrador de família.
- **N4 (sinônimo):** ✅ — nenhuma outra skill orquestra o kit inteiro.
- **N5 (audiência):** ✅.

**Placement:**

- Atual: `.cursor/`
- Correto: `.cursor/` — orchestrator é reutilizável.
- Nenhuma migração necessária.

**Exemplos/templates internos:**

- `consultas_rapidas/arvore_decisao.md`
- `consultas_rapidas/mapa_completo.md`
- `consultas_rapidas/quando_usar_cada.md`

**Correção proposta:**

```diff
@@ linha 69 (Família C — após L09 aprovada)
- | `developer-delphi-patterns-composition` | V1.1.0 | **Orquestradora Patterns** — composição, DI, IoC, seleção de padrão correto |
+ | `developer-delphi-patterns-orchestrator` | V1.1.0 | **Orquestradora Patterns** — seleção de família (creational / structural / behavioral) |

@@ linha 183 (Dependências)
- | `project-refactoring-compatibility-policy` | Antes de renomear classes, métodos ou units no fluxo |
+ | `governance-refactoring-compatibility-policy` | Antes de renomear classes, métodos ou units no fluxo |
```

```diff
@@ linhas 197-219 (substituir Exemplos mínimos por workflow orquestrado)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32/dcc64):**
-
-```pascal
-program SampleOrchestrator;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-orchestrator V1.1.0');
-end.
-```
-
-**Free Pascal (fpc):**
-
-```pascal
-program SampleOrchestratorFPC;
-{$IFDEF FPC}
-  {$mode delphi}
-{$ENDIF}
-begin
-  WriteLn('OK -- developer-delphi-orchestrator V1.1.0');
-end.
-```
+## Exemplo de fluxo orquestrado
+
+Orquestrador não tem "exemplo mínimo compilável" — executa via delegação. Exemplo de cenário real:
+
+**Cenário:** adicionar nova engine de banco (ex.: USE_ORACLE).
+
+| Etapa | Skill delegada | Responsabilidade |
+|---|---|---|
+| 1 | `developer-delphi-programming-conditional-defines` | Declarar `USE_ORACLE` em `ORM.Defines.inc`; escrever blocos `{$IF DEFINED(USE_ORACLE)}` na ordem canônica |
+| 2 | `developer-delphi-architecture-modules` | Criar unit `Providers.Connection.Oracle.pas` + `.Interfaces.pas` seguindo padrão de módulos do projeto |
+| 3 | `developer-delphi-architecture-and-design` | Definir contrato `IOracleConnection` (se difere de `IConnection`) e DI no Factory |
+| 4 | `developer-delphi-build-cross-compiler` | Atualizar `dcc32.cfg` + `fpc64.opts` com paths de units Oracle |
+| 5 | `developer-delphi-testing-integration` | Criar fixture de integração usando banco Oracle real |
+| 6 | `developer-delphi-error-handling-and-diagnostics` | Mapear exceções Oracle para hierarquia do projeto |
+| 7 | `developer-delphi-documentation-governance` | Atualizar CHANGELOG, Analise/Connections/Connection.md |
+
+**Cenário:** migrar formulário VCL para FMX.
+
+| Etapa | Skill delegada |
+|---|---|
+| 1 | `developer-delphi-fmx-layout` (orchestrator família A) |
+| 2 | `developer-delphi-fmx-frames` (se usar herança de frames) |
+| 3 | `developer-delphi-programming-conditional-defines` (blocos condicionais VCL/FMX) |
+| 4 | `developer-delphi-testing-and-quality` (testes UI) |
+
+Para árvore de decisão completa: `consultas_rapidas/arvore_decisao.md`.
```

```diff
@@ linha 257 (Referências — corrigir path antigo)
-- skill `developer-delphi-programming-conditional-defines` (exemplos: `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`)
+- skill `developer-delphi-programming-conditional-defines` (exemplos: `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`)
```

**Comentário:** o orchestrator fica muito mais útil substituindo o "WriteLn OK" por exemplos de fluxos orquestrados reais. Isso transforma a skill de catálogo estático em guia ativo de uso.

**Nome proposto:** `developer-delphi-to-fpc-kit-orchestrator` — aplica N2 + N3 (adiciona "kit" como objeto técnico concreto do que é orquestrado). Alternativa: `developer-delphi-to-fpc-master-orchestrator` (sinaliza nível master do kit). Preferência por **`kit-orchestrator`** para reforçar que é o hub do kit completo.

**Dependências cruzadas afetadas:**

- Nenhum grep direto na pasta `.cursor/` pelo nome curto `developer-delphi-orchestrator` (só self-referências).
- Agentes `.cursor/agents/*.md` — validar na onda L20.
- CLAUDE.md — grep: sem match.

---

## Ações acumuladas para execução

### E1-candidatas (CLAUDE.md refs quebradas detectadas neste lote)

Nenhuma nova (E1 já aplicada).

### E4-candidatas (Q1/Q7 para fix imediato)

Os 3 arquivos têm `{$IFDEF FPC}` nos exemplos mínimos. Correções específicas em blocos `diff` por arquivo acima. Estes 3 são parte dos 25 arquivos afetados por Q1/Q7 (caso-zero L09 + propagação). **Sugestão:** agrupar em commit único junto com os demais 22 arquivos na Onda E4.

**Lista consolidada até L01+L09 (5 arquivos confirmados com Q1/Q7):**

1. `developer-delphi-programming-conditional-defines_V1.0.0/SKILL.md` (caso-zero, maior)
2. `developer-delphi-architecture-and-design_V1.0.0/SKILL.md` (L01 — este lote)
3. `developer-delphi-architecture-modules_V1.0.0/SKILL.md` (L01 — este lote)
4. `developer-delphi-orchestrator_V1.1.0/SKILL.md` (L01 — este lote)

### E5-candidatas (renames propostos neste lote)

1. `developer-delphi-architecture-and-design` → `developer-delphi-to-fpc-architecture-and-design` (N2 alta confiança — Checklist Delphi+FPC explícito)
2. `developer-delphi-architecture-modules` → `developer-delphi-to-fpc-architecture-modules` (N2 alta confiança)
3. `developer-delphi-orchestrator` → `developer-delphi-to-fpc-kit-orchestrator` (N2 + N3 — adiciona "kit" para desambiguar de 5+ outros orchestrators no pack)

**Pending cascade** (se rename de L09 aprovado): atualizar a linha 69 da tabela Família C do orchestrator quando `patterns-composition` → `patterns-orchestrator`.

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 architecture-and-design:165** — `project-diretivas-compilacao_V1.1.0` → `developer-delphi-programming-conditional-defines_V1.0.0`.
2. **Q2 architecture-and-design:168** — `E:\CSL\ProvidersORM\src` → `src/` (generalizar).
3. **Q2 architecture-modules:185** — `E:\CSL\ProvidersORM\src` → `src/`.
4. **Q2 architecture-modules:186** — `project-diretivas-compilacao_V1.1.0` → `developer-delphi-programming-conditional-defines_V1.0.0`.
5. **Q2 orchestrator:183** — `project-refactoring-compatibility-policy` → `governance-refactoring-compatibility-policy`.
6. **Q2 orchestrator:257** — `project-diretivas-compilacao_V1.1.0` → `developer-delphi-programming-conditional-defines_V1.0.0`.
7. **Q4 em todos 3** — substituir `WriteLn('OK')` por exemplos substantivos (diffs completos acima).
8. **Q5 architecture-modules:89-93** — generalizar namespaces `GestorERP.*` para `Acme.*` + nota sobre `.workspace/` para exemplos por-clone.
9. **Q3 em architecture-and-design e architecture-modules** — personalizar Checklist (remover bullets genéricos copiados).
10. **Q5 leve linhas 161/176** — adicionar acentos a "Avaliação" e "Referências".

### Placement migrations

Nenhuma skill deste lote precisa mover para `.workspace/`. Mas:

- `architecture-and-design:168` — path absoluto `E:\CSL\ProvidersORM\src` deve ser generalizado.
- `architecture-modules:89-93` — namespaces `GestorERP.*` devem ser generalizados; conteúdo específico do GestorERP deveria viver em `.workspace/skills/` daquele clone (não deste).
- `architecture-modules:185` — mesma questão.

---

## Síntese do lote L01

- **3 skills auditadas** com detalhe completo.
- **Todas 3 têm Q1+Q7** (`{$IFDEF FPC}` nos exemplos — sintoma do caso-zero L09).
- **Todas 3 têm Q2** (refs para `project-diretivas-compilacao_V1.1.0` que foi renomeada).
- **Todas 3 têm Q4** (exemplos mínimos triviais `WriteLn('OK')`).
- **2 skills têm Q5** (path absoluto do clone + namespaces MXX GestorERP).
- **3 renames candidatos** `to-fpc-*` (alta confiança — skills explicitamente cross-compile).
- **1 rename extra** N3 (`orchestrator` genérico → `kit-orchestrator`).

**Próxima onda sugerida:** L02 (assembly) — 11 skills, família maior, muitas Delphi-only mas com possíveis surpresas cross-compile no orchestrator e x86-fundamentals.

**Commit sugerido:** `docs(audit): relatório lote L01 architecture + orchestrator — Q1/Q2/Q4 em 3 skills`
