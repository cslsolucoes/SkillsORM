---
name: audit-L09-patterns-programming
description: Relatório de auditoria do lote L09 do plano pack-audit-context-isolated-waves v5.0. Família patterns + programming (7 skills). Inclui o CASO-ZERO reportado pelo usuário (skill developer-delphi-programming-conditional-defines auto-contradiz sua própria Regra 2).
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
version: 1.0
date: 2026-04-24
scope: 7 skills em .cursor/skills/developer-delphi-patterns-*/ e .cursor/skills/developer-delphi-programming-*/
---

# Relatório Auditoria — Lote L09 patterns + programming

**Data:** 24/04/2026
**Escopo:** 7 arquivos na família:

1. `developer-delphi-patterns-behavioral_V1.1.0`
2. `developer-delphi-patterns-composition_V1.1.0`
3. `developer-delphi-patterns-creational_V1.1.0`
4. `developer-delphi-patterns-structural_V1.1.0`
5. `developer-delphi-programming-conditional-defines_V1.0.0` (**caso-zero**)
6. `developer-delphi-programming-oop-fluent_V1.0.0`
7. `developer-delphi-programming-oop-naming_V1.0.0`

**Contexto budget consumido:** ~35KB (7 SKILL.md + listagens de exemplos/templates/consultas_rapidas)

## Tabela-sumário (navegação — não substitui detalhe)

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | patterns-behavioral_V1.1.0 | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-patterns-behavioral | média |
| 2 | patterns-composition_V1.1.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ❌ | ⚠ | ✅ | .cursor | .cursor | (rever) | baixa |
| 3 | patterns-creational_V1.1.0 | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-patterns-creational | média |
| 4 | patterns-structural_V1.1.0 | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-patterns-structural | média |
| 5 | **programming-conditional-defines_V1.0.0** | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-programming-conditional-defines | **CRÍTICA** |
| 6 | programming-oop-fluent_V1.0.0 | ✅ | ❌ | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | ⚠ | .cursor | .cursor/ + migrar exemplos MXX para .workspace/ | manter | alta |
| 7 | programming-oop-naming_V1.0.0 | ✅ | ❌ | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | ⚠ | .cursor | .cursor/ + migrar exemplos MXX para .workspace/ | manter | alta |

**Legenda:** ✅ = sem achado · ⚠ = achado leve · ❌ = achado grave · prioridade: **CRÍTICA** / **alta** / média / baixa

## Detalhe por arquivo

### Arquivo 1/7: `developer-delphi-patterns-behavioral_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-patterns-behavioral_V1.1.0\SKILL.md`
**FileVersion:** (não declarado no frontmatter — apenas no nome da pasta: V1.1.0)
**Tamanho:** 61 linhas
**Model:** sonnet
**Category:** (ausente)

**Frontmatter integral:**

```yaml
---
name: developer-delphi-patterns-behavioral
description: Padrões comportamentais em Delphi — Strategy, Observer, Command, Chain of Responsibility, Mediator, State.
model: sonnet
---
```

**Responsabilidade declarada** (copiada — não há seção "Responsabilidade única"; há "Propósito"):

> "Dominar padrões comportamentais em Delphi: Strategy, Observer, Command+Undo, Chain of Responsibility, Mediator, State e Iterator. Foco em comunicação desacoplada entre objetos via interface."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** Não. A skill descreve exemplos em tabelas; não há regra + violação no próprio texto.
- **Q2 (ref quebrada):** Não. Não referencia outras skills por nome.
- **Q3 (boilerplate):** ⚠ Leve — a estrutura de seções ("Conteúdo" com tabelas `exemplos/`, `consultas_rapidas/`, `templates/` + "Fontes" + "Changelog") é copiada literal de patterns-creational e patterns-structural. Não é grave porque o conteúdo é distinto; mas falta seções obrigatórias do template V2 (Responsabilidade única, When to use, When NOT to use, Dependências, Anti-padrões, Métricas de sucesso, Responsável principal).
- **Q4 (exemplo vazio):** Não. Exemplos são concretos (strategy, observer, command, chain_of_resp, mediator, state, iterator).
- **Q5 (idioma):** Não.
- **Q6 (regra ausente):** Não para o tema da skill em si.
- **Q7 (anti-padrão ativo):** Não.

**Achados de nomenclatura (N):**

- **N1 (prefixo revela família + audiência):** ✅ — `developer-delphi-patterns-*` é claro.
- **N2 (cross-compile explícito):** ⚠ — Design patterns GoF funcionam em Delphi+FPC (interfaces, generics disponíveis nos dois). Não menciona FPC no frontmatter/descrição, mas menciona em outra skill da família (composition). **Candidato a rename** `developer-delphi-to-fpc-patterns-behavioral` **se** a auditoria dos arquivos `exemplos/*.pas` confirmar código cross-compile (not read yet — pertence a onda separada).
- **N3 (objeto técnico concreto):** ✅ — `patterns-behavioral` é preciso.
- **N4 (sem sinônimo oculto):** ✅ — as 4 skills `patterns-*` são complementares (creational / structural / behavioral / composition = orquestrador).
- **N5 (audiência explícita):** ✅ — é skill de padrões de design, audiência dev-delphi.

**Placement:**

- Atual: `.cursor/`
- Correto: `.cursor/` — padrões GoF são reutilizáveis, não dependem deste clone.
- Nenhuma migração necessária.

**Exemplos/templates internos:**

- `exemplos/strategy.pas` — ISortStrategy com 3 algoritmos (não lido nesta onda; conteúdo listado na tabela da skill).
- `exemplos/observer.pas` — IObserver/ISubject multicast.
- `exemplos/command.pas` — ICommand + TCommandHistory Undo/Redo.
- `exemplos/chain_of_resp.pas` — pipeline aprovação crédito.
- `exemplos/mediator.pas` — desacopla componentes UI.
- `exemplos/state.pas` — máquina de estados TContext (pedido).
- `exemplos/iterator.pas` — IEnumerator<T> customizado.
- `consultas_rapidas/behavioral_quando.md` — tabela: qual pattern para qual problema.
- `consultas_rapidas/observer_vs_events.md` — TNotifyEvent vs Observer vs anonymous method.
- `consultas_rapidas/command_undo.md` — Undo/Redo com TStack<ICommand>.
- `templates/TEMPLATE_strategy.pas` — Strategy com registro dinâmico.
- `templates/TEMPLATE_observer_multicast.pas` — Observer thread-safe weak refs.
- `templates/TEMPLATE_command_undo.pas` — Command+Undo/Redo completo.

**Correção proposta (texto completo antes/depois):**

Adicionar seções V2 obrigatórias (conforme padrão das skills mais recentes do pack).

```diff
@@ linha 57
 ## Fontes

 - `Doc-Delphi/ObjectPascalHandbook_AlexandriaVersion.pdf` — Cap. Patterns
 - GoF — Design Patterns (Gamma et al.)

+## When to use
+
+- Ao escolher algoritmo intercambiável em runtime (Strategy)
+- Ao notificar objetos sobre mudanças de estado (Observer)
+- Ao implementar operações reversíveis com histórico (Command+Undo)
+- Ao desenhar pipelines de processamento (Chain of Responsibility)
+- Ao desacoplar componentes UI que se comunicam (Mediator)
+- Ao modelar comportamento dependente de estado (State)
+- Ao expor iteração customizada (Iterator)
+
+## When NOT to use
+
+- Para padrões Creational → `developer-delphi-patterns-creational_V1.1.0`
+- Para padrões Structural → `developer-delphi-patterns-structural_V1.1.0`
+- Para escolher a família certa → `developer-delphi-patterns-composition_V1.1.0`
+
+## Dependências (skills prévias)
+
+| Skill | Quando executar antes |
+|-------|-----------------------|
+| `developer-delphi-language-oop_V1.1.0` | Sintaxe de interface e classes Delphi |
+| `developer-delphi-programming-oop-fluent_V1.0.0` | Padrão fluent obrigatório em builders |
+
+## Anti-padrões
+
+| Anti-padrão | Por que errado | Como corrigir |
+|---|---|---|
+| Strategy com `case TStrategy of sBubble: ... sQuick: ...` | Acopla cliente ao enum; impossível adicionar algoritmo novo sem editar o cliente | Usar ISortStrategy + polimorfismo de interface |
+| Observer retendo observers sem weak refs | Memory leak quando subject sobrevive ao observer | Usar TList<TWeakReference<IObserver>> ou notificar Detach explícito |
+| Command sem Undo quando a app promete "desfazer" | Feature anunciada não funciona | Todo ICommand exige Execute + Undo + Description |
+
+## Métricas de sucesso
+
+- 0 uses de `case` em lugar de Strategy pattern
+- 0 memory leaks em cadeia Observer/Subject (medido por FastMM)
+- Code review confirma uso de interface para cada pattern behavioral
+
+## Responsável principal
+
+| Papel | Quem |
+|---|---|
+| Executor | Desenvolvedor do módulo |
+| Revisor | Tech Lead |
+
 ## Changelog
```

**Comentário:** a skill está funcional mas carece de estrutura V2 consistente com skills mais novas. A seção Anti-padrões é particularmente importante porque captura erros comuns (case ladder em vez de Strategy, weak refs no Observer) que são o propósito da skill ensinar.

**Nome proposto:** `developer-delphi-to-fpc-patterns-behavioral` — **condicionado** à leitura dos `exemplos/*.pas` em onda separada confirmar que o código roda em Delphi+FPC. Se confirmado, N2 justifica o rename. Se algum exemplo usa feature Delphi-only (anonymous method variant não suportado, ex.), manter prefixo atual.

**Dependências cruzadas afetadas por esta correção:**

- `developer-delphi-patterns-composition_V1.1.0/SKILL.md` — referencia esta skill na tabela (linha 21 do composition). Se rename, atualizar.
- Nenhum outro arquivo `.cursor/` referencia esta skill por grep.

---

### Arquivo 2/7: `developer-delphi-patterns-composition_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-patterns-composition_V1.1.0\SKILL.md`
**FileVersion:** (não declarado no frontmatter)
**Tamanho:** 51 linhas
**Model:** sonnet
**Category:** (ausente)

**Frontmatter integral:**

```yaml
---
name: developer-delphi-patterns-composition
description: Orquestradora da Família C — Design Patterns Delphi. Mapeia as 3 micro-skills de padrões por categoria.
model: sonnet
---
```

**Responsabilidade declarada:**

> "Orquestradora da **Família C — Design Patterns**. Mapeia as 3 micro-skills de padrões e orienta sobre qual categoria usar para cada problema de design em Delphi."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** Não — conteúdo é específico de orquestrador.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅ — `patterns-composition` é distinguível das 3 irmãs.
- **N2:** ⚠ — Linha 46 declara "Compatibilidade Delphi + FPC — evitar features exclusivas". Skill é cross-compile de fato. Candidato a `developer-delphi-to-fpc-patterns-composition`.
- **N3:** ❌ — `composition` é ambíguo. Pode confundir com "composite pattern" (que é structural, não orquestrador). Melhor: `patterns-orchestrator` ou `patterns-family-index`.
  - Regra N3: segundo componente deve ser objeto técnico concreto. `composition` confunde porque coincide com nome de pattern. `orchestrator` é mais preciso.
- **N4:** ⚠ — `patterns-composition` pode colidir conceitualmente com "composição de objetos" usada em patterns-structural. Baixa severidade mas ambíguo.
- **N5:** ✅.

**Placement:** `.cursor/` — correto, orquestrador é reutilizável.

**Exemplos/templates internos:**

- `consultas_rapidas/mapa_skills_patterns.md` — quando usar cada skill.
- `consultas_rapidas/gof_tabela.md` — 23 padrões GoF classificados.
- `consultas_rapidas/patterns_delphi.md` — adaptações Delphi (interfaces, anonymous methods, generics).

**Correção proposta:**

Rename N3 para resolver ambiguidade com "Composite pattern":

```diff
---
-name: developer-delphi-patterns-composition
+name: developer-delphi-to-fpc-patterns-orchestrator
 description: Orquestradora da Família C — Design Patterns Delphi. Mapeia as 3 micro-skills de padrões por categoria.
 model: sonnet
 ---
-# developer-delphi-patterns-composition_V1.1.0
+# developer-delphi-to-fpc-patterns-orchestrator_V1.1.0
```

E adicionar seções V2 mínimas (When to use/NOT to use já existem implícitas; formalizar).

**Comentário:** a mudança principal é conceitual — `composition` confunde com o pattern Composite e com o princípio "composition over inheritance". `orchestrator` é mais claro e alinhado ao padrão de outras skills que têm orchestrator (horse-orchestrator, documentation-orchestrator, etc.).

**Nome proposto:** `developer-delphi-to-fpc-patterns-orchestrator` (aplica N2 + N3 + N4).

**Dependências cruzadas:**

- Agentes que referenciam Família C de patterns: nenhum grep direto em `.cursor/agents/`.
- `developer-delphi-orchestrator_V1.1.0` pode referenciar (verificar em L01).

---

### Arquivo 3/7: `developer-delphi-patterns-creational_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-patterns-creational_V1.1.0\SKILL.md`
**FileVersion:** (não declarado)
**Tamanho:** 54 linhas
**Model:** sonnet
**Category:** (ausente)

**Frontmatter integral:**

```yaml
---
name: developer-delphi-patterns-creational
description: Padrões de criação em Delphi — Factory Method, Abstract Factory, Builder fluente, Singleton, Prototype, Object Pool.
model: sonnet
---
```

**Responsabilidade declarada:**

> "Dominar padrões de criação em Delphi: Factory Method, Abstract Factory, Builder fluente, Singleton thread-safe, Prototype e Object Pool. Cada padrão com implementação canônica via interface + factory function (`New`)."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** ⚠ — estrutura idêntica a patterns-behavioral e patterns-structural (Propósito, Quando usar, Conteúdo, exemplos/, consultas_rapidas/, templates/, Fontes, Changelog). Faltam as mesmas seções V2 obrigatórias. Changelog não tem entrada V1.1.0; apenas a V1.0.0 teria sentido pelo nome da pasta. **Possível Q3 grave:** o changelog ausente sugere cópia do template sem preenchimento.
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** ⚠ — falta menção à convenção `class function New: IXxx` como factory obrigatória (regra de `developer-delphi-programming-oop-fluent_V1.0.0`). A skill descreve Factory Method mas não referencia a regra canônica do projeto.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ⚠ — padrões Creational funcionam em Delphi+FPC. Candidato rename.
- **N3:** ✅ — `patterns-creational` é GoF canônico.
- **N4:** ✅.
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:**

- `exemplos/factory_method.pas`, `abstract_factory.pas`, `builder_pattern.pas`, `singleton.pas`, `prototype.pas`, `object_pool.pas`.
- `consultas_rapidas/factory_vs_new.md`, `singleton_riscos.md`, `builder_fluente.md`.
- `templates/TEMPLATE_factory_interface.pas`, `TEMPLATE_builder_fluente.pas`, `TEMPLATE_singleton_safe.pas`.

**Correção proposta:**

```diff
@@ linha 52 (adicionar antes de ## Fontes ou ao final)
+## Dependências (skills prévias)
+
+| Skill | Quando executar antes |
+|-------|-----------------------|
+| `developer-delphi-programming-oop-fluent_V1.0.0` | Factory obrigatória `class function New: IXxx` (ponto único de criação) |
+| `developer-delphi-programming-oop-naming_V1.0.0` | Naming `IXxx`/`TXxx`/`TXxxBuilder` |
+
+## Integração com o projeto
+
+Esta skill descreve padrões GoF; o projeto adota as seguintes regras concretas em cima deles:
+
+- **Factory:** `class function New(deps): IXxx` — exclusivo ponto de criação; nunca `TXxx.Create` no consumidor.
+- **Builder:** fluent chain `.OperacaoVerb.WithXxx.Execute` conforme `developer-delphi-programming-oop-fluent_V1.0.0`.
+- **Singleton:** desencorajado — preferir Dependency Injection via `class function New(deps)`.
+
+## Anti-padrões
+
+| Anti-padrão | Por que errado | Como corrigir |
+|---|---|---|
+| `TClass.Create` chamado diretamente pelo consumidor | Viola regra de Factory única do projeto | `TClass.New` sempre |
+| Singleton globalmente acessível | Dificulta teste, esconde dependências | Injetar via construtor + registry |
+| Builder sem `.Execute` terminal | Operação pode nunca executar | `.Execute` obrigatório no final da cadeia |
+
+## Métricas de sucesso
+
+- 0 chamadas diretas a `TClass.Create` no código consumidor
+- 100% das classes públicas expõem `class function New`
+- Builders sempre terminam em `.Execute`
+
```

**Nome proposto:** `developer-delphi-to-fpc-patterns-creational` (após confirmação de cross-compile em `exemplos/`).

**Dependências cruzadas:**

- `developer-delphi-patterns-composition_V1.1.0/SKILL.md:19` referencia.
- `developer-delphi-programming-oop-fluent_V1.0.0/SKILL.md:167` lista em "Skills relacionadas".
- `developer-delphi-programming-oop-naming_V1.0.0/SKILL.md:193` lista em "Skills relacionadas".

---

### Arquivo 4/7: `developer-delphi-patterns-structural_V1.1.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-patterns-structural_V1.1.0\SKILL.md`
**FileVersion:** (não declarado)
**Tamanho:** 54 linhas
**Model:** sonnet
**Category:** (ausente)

**Frontmatter integral:**

```yaml
---
name: developer-delphi-patterns-structural
description: Padrões estruturais em Delphi — Composite, Decorator, Adapter, Proxy, Facade, Bridge via interface.
model: sonnet
---
```

**Responsabilidade declarada:**

> "Dominar padrões estruturais em Delphi: Composite, Decorator, Adapter, Proxy, Facade e Bridge. Foco em composição via interface — nunca herança profunda."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** Não.
- **Q3:** ⚠ — mesma estrutura template das outras 3 patterns-* sem seções V2 obrigatórias. Changelog completamente ausente (linhas 51-54 vão direto para "Fontes" e fim).
- **Q4:** Não.
- **Q5:** Não.
- **Q6:** ⚠ — falta referência à convenção do projeto de "composição via interface" como preferência sobre herança, embora o próprio texto mencione. Poderia ter tabela comparativa concreta.
- **Q7:** Não.

**Achados de nomenclatura (N):** idênticos a creational — N2 ⚠ cross-compile candidato, demais ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:**

- `exemplos/composite.pas`, `decorator.pas`, `adapter.pas`, `proxy.pas`, `facade.pas`, `bridge.pas`.
- `consultas_rapidas/structural_quando.md`, `decorator_vs_proxy.md`, `composite_hierarquia.md`.
- `templates/TEMPLATE_decorator_chain.pas`, `TEMPLATE_adapter_legacy.pas`.

**Correção proposta:**

Adicionar changelog ausente + seções V2 (similar a patterns-creational acima):

```diff
@@ linha 54 (final — adicionar)
+## Dependências (skills prévias)
+
+| Skill | Motivo |
+|-------|--------|
+| `developer-delphi-language-oop_V1.1.0` | Sintaxe de interface |
+| `developer-delphi-programming-oop-naming_V1.0.0` | Naming IXxx/TXxx |
+
+## Anti-padrões
+
+| Anti-padrão | Por que errado | Como corrigir |
+|---|---|---|
+| Herança profunda para compor comportamento | Acopla filho a pai; frágil | Usar Decorator/Composite via interface |
+| Adapter dentro do consumidor (hardcoded) | Inviabiliza reuso do legacy | Mover Adapter para unit separada Commons.Adapters.* |
+| Proxy sem interface comum com o objeto real | Quebra transparência | Proxy implementa a mesma interface do real |
+
+## Métricas de sucesso
+
+- 0 hierarquias de herança > 3 níveis
+- 100% dos padrões estruturais via interface (`I*`)
+- Exemplos cross-compilam Delphi+FPC
+
+## Changelog
+
+- V1.1.0 (2026-04-11): Criação inicial.
```

**Nome proposto:** `developer-delphi-to-fpc-patterns-structural` (condicional).

**Dependências cruzadas:**

- `developer-delphi-patterns-composition_V1.1.0/SKILL.md:20`.

---

### Arquivo 5/7: `developer-delphi-programming-conditional-defines_V1.0.0/SKILL.md` — **CASO-ZERO**

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-programming-conditional-defines_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (declarado na tabela de versão interna, linha 14)
**Tamanho:** 158 linhas
**Model:** haiku
**Category:** developer-delphi

**Frontmatter integral:**

```yaml
---
name: developer-delphi-programming-conditional-defines
description: Use when the user asks about compilation directives (USE_*, ORM.Defines.inc), how to enable/disable modules or engines, or how to write {$IFDEF} / {$IF DEFINED(...)} blocks for FireDAC, UniDAC, Zeos, SQLdb, USE_ATTRIBUTES, USE_ENTITY_MANAGER, USE_QUERY_BUILDER, USE_PARAMENTERS, USE_LOGGERS, USE_POOLCONNECTIONS. Canonical doc: .cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md.
model: haiku
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (copiada literal, linhas 17-19):

> "Esta skill é a referência canônica para diretivas de compilação do projeto: habilitar/desabilitar engines e módulos via `ORM.Defines.inc`, escrever blocos `{$IFDEF}` e `{$IF DEFINED(...)}` na ordem correta, e garantir compatibilidade cross-compiler nas condicionais. Ela aponta para o documento de verdade única (`diretivas_compilacao.md`) e exige leitura desse arquivo antes de responder com diretivas ou código condicional. Ela NÃO compila o projeto e NÃO implementa lógica de negócio."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ **CRÍTICO — caso-zero do plano.**
  - Regra declarada (linha 51): *"Preferir `{$IF DEFINED(...)}`** para evitar símbolo não definido quando a diretiva não existe"*. E linha 52: *"Encadear com `{$ELSE} {$IF DEFINED(...)}`"*.
  - Exemplo que viola (linhas 91-104 — bloco "Exemplo mínimo compilável — Delphi"):

    ```pascal
    program SampleDiretivasDelphi;
    {$APPTYPE CONSOLE}
    {$I ORM.Defines.inc}
    begin
    {$IF DEFINED(USE_FIREDAC)}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=FireDAC');
    {$ELSEIF DEFINED(USE_ZEOS)}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=Zeos');
    {$ELSE}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=fallback');
    {$ENDIF}
    end.
    ```

    O exemplo usa `{$ELSEIF DEFINED(USE_ZEOS)}` — que contradiz a própria Regra 3 da skill ("Encadear com `{$ELSE} {$IF DEFINED(...)} ... {$ENDIF}`"). `ELSEIF` é justamente o que a regra pede para **NÃO** usar.

  - Exemplo que viola — FPC (linhas 109-121):

    ```pascal
    program SampleDiretivasFPC;
    {$IFDEF FPC}{$mode delphi}{$ENDIF}
    {$I ORM.Defines.inc}
    begin
    {$IF DEFINED(USE_SQLDB)}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=SQLdb');
    {$ELSEIF DEFINED(USE_ZEOS)}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=Zeos');
    {$ELSE}
      WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=fallback');
    {$ENDIF}
    end.
    ```

    Mesma violação + linha 110 começa com `{$IFDEF FPC}` (viola Regra 2 que pede preferir `{$IF DEFINED()}`).

  - Explicação: a skill é o **documento mestre** do padrão de diretivas condicionais. Quando o agente (ou humano) lê o SKILL.md e encontra a "Regra 2" declarando "preferir IF DEFINED" mas o "Exemplo mínimo compilável" logo abaixo usa `{$IFDEF FPC}` e `{$ELSEIF DEFINED(...)}`, o exemplo vence — porque é concreto e copy-pasteable. O resultado é que 25 outras skills do pack reproduzem o padrão errado dos exemplos aqui.

    Além disso, o exemplo não cobre a ordem canônica completa da própria skill (UNIDAC → FIREDAC → ZEOS → SQLDB → fallback). O exemplo Delphi só tem FIREDAC → ZEOS → fallback (falta UNIDAC e SQLDB — este último é FPC-only, mas UNIDAC aplica a Delphi). Isso viola a Regra 4 da skill sobre ordem fixa.

- **Q2 (ref quebrada):** Não. Todas as referências internas são ao próprio path V1.0.0 do documento canônico.

- **Q3 (boilerplate):** Não. A skill tem conteúdo próprio detalhado.

- **Q4 (exemplo vazio):** ⚠ parcial. Os exemplos usam `WriteLn('OK -- engine=X')` que é didático para mostrar qual ramo executou, mas não demonstra uso real (ex.: declaração de field por engine com padrão compacto descrito nas linhas 159-184 do `exemplos/diretivas_compilacao.md`). Poderia ter exemplo mais rico.

- **Q5 (idioma):** Não.

- **Q6 (regra ausente):** Não — a skill tem todas as regras declaradas, o problema é que não as obedece.

- **Q7 (anti-padrão ativo):** ❌ **CRÍTICO.** Os 2 "Exemplos mínimos compiláveis" são anti-padrão ativo — ensinam exatamente o que a própria skill proíbe. Isto é a fonte do problema reportado pelo usuário.

**Achados de nomenclatura (N):**

- **N1:** ✅ — `developer-delphi-programming-conditional-defines` é explícito.
- **N2:** ⚠ — O tema cross-compile é central na skill (Regra 2 menciona "evitar símbolo não definido quando a diretiva não existe" — problema típico quando rodando sem FPC ou sem Delphi). Candidato forte a rename `developer-delphi-to-fpc-programming-conditional-defines`.
- **N3:** ✅ — `programming-conditional-defines` é preciso tecnicamente.
- **N4:** ✅ — sem sinônimos.
- **N5:** ✅ — audiência dev-delphi consolidada.

**Placement:** `.cursor/` correto. Skill ensina padrão universal da linguagem Pascal com diretivas `USE_*` típicas de frameworks Delphi; reutilizável.

**Exemplos/templates internos:**

- `exemplos/diretivas_compilacao.md` — **319 linhas**, referência canônica. **Consistente** com as próprias regras (usa `{$IF DEFINED()}` + `{$ELSE} {$IF DEFINED()}...{$ENDIF}` em todos os blocos das linhas 159-269). **É o SKILL.md que contradiz o exemplo**, não o contrário.

**Correção proposta (texto completo antes/depois):**

Substituir os 2 blocos "Exemplo mínimo compilável" por versões consistentes com as Regras 2/3/4, e adicionar seção nova "Por que NÃO usar `{$IFDEF}` e `{$ELSEIF}` neste projeto":

```diff
@@ linhas 87-121 (substituir 2 blocos inteiros)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleDiretivasDelphi;
-{$APPTYPE CONSOLE}
-{$I ORM.Defines.inc}
-begin
-{$IF DEFINED(USE_FIREDAC)}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=FireDAC');
-{$ELSEIF DEFINED(USE_ZEOS)}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=Zeos');
-{$ELSE}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=fallback');
-{$ENDIF}
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleDiretivasFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-{$I ORM.Defines.inc}
-begin
-{$IF DEFINED(USE_SQLDB)}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=SQLdb');
-{$ELSEIF DEFINED(USE_ZEOS)}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=Zeos');
-{$ELSE}
-  WriteLn('OK -- developer-delphi-programming-conditional-defines: engine=fallback');
-{$ENDIF}
-end.
-```
+## Exemplo mínimo compilável (ordem canônica UNIDAC → FIREDAC → ZEOS → SQLDB → fallback)
+
+**Delphi (dcc32 / dcc64) — com encadeamento explícito e fallback nomeado:**
+
+```pascal
+program SampleDiretivasDelphi;
+{$APPTYPE CONSOLE}
+{$I ORM.Defines.inc}
+begin
+{$IF DEFINED(USE_UNIDAC)}
+  WriteLn('engine=UniDAC');
+{$ELSE} {$IF DEFINED(USE_FIREDAC)}
+  WriteLn('engine=FireDAC');
+{$ELSE} {$IF DEFINED(USE_ZEOS)}
+  WriteLn('engine=Zeos');
+{$ELSE} {$IF DEFINED(USE_SQLDB)}
+  WriteLn('engine=SQLdb');
+{$ELSE}
+  WriteLn('engine=none (fallback)');
+{$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}
+end.
+```
+
+**Free Pascal (fpc32 / fpc64) — idem, com modo Delphi:**
+
+```pascal
+program SampleDiretivasFPC;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+{$I ORM.Defines.inc}
+begin
+{$IF DEFINED(USE_UNIDAC)}
+  WriteLn('engine=UniDAC');
+{$ELSE} {$IF DEFINED(USE_FIREDAC)}
+  WriteLn('engine=FireDAC');
+{$ELSE} {$IF DEFINED(USE_ZEOS)}
+  WriteLn('engine=Zeos');
+{$ELSE} {$IF DEFINED(USE_SQLDB)}
+  WriteLn('engine=SQLdb');
+{$ELSE}
+  WriteLn('engine=none (fallback)');
+{$ENDIF} {$ENDIF} {$ENDIF} {$ENDIF}
+end.
+```
+
+## Por que NÃO usar `{$IFDEF}` e `{$ELSEIF}` neste projeto
+
+O padrão canônico do projeto é `{$IF DEFINED(X)}` + encadeamento `{$ELSE} {$IF DEFINED(Y)} ... {$ENDIF}` por 3 motivos técnicos:
+
+1. **Segurança contra símbolo não declarado:** `{$IFDEF USE_X}` falha silenciosamente se `USE_X` nunca foi definido em lugar algum (não aparece em `ORM.Defines.inc`, não foi passado via CLI). Já `{$IF DEFINED(USE_X)}` sempre retorna `False` de forma segura, sem depender de `USE_X` existir em algum dicionário.
+
+2. **Portabilidade FPC:** alguns modos de compilação do FPC (especialmente `{$mode delphi}` com versões mais antigas do 3.0.x) têm comportamentos inconsistentes com `{$ELSEIF DEFINED(X)}` vs `{$ELIFDEF X}`. O encadeamento explícito `{$ELSE} {$IF DEFINED(X)} ... {$ENDIF}` **sempre funciona igual** em Delphi + FPC + modo Delphi + modo ObjFPC.
+
+3. **Clareza de escopo:** cada `{$IF}` pareia com exatamente um `{$ENDIF}`. Num bloco aninhado profundo (5 engines + fallback) o leitor conta `{$ENDIF}`s e sabe onde cada ramo termina. `{$ELSEIF}` esconde esse escopo e dificulta review de código.
+
+**Regra:** use `{$ELSEIF}` apenas em projetos 100% Delphi (sem FPC). Neste projeto, o uso de `{$ELSEIF}` e `{$IFDEF}` é bloqueado pelo `validate-pack.py` + code-review.
```

**Comentário:** a correção resolve 3 problemas simultaneamente:

1. Os dois "Exemplos mínimos" passam a obedecer as próprias Regras 2/3/4 da skill.
2. Cobertura completa das 4 engines suportadas (UNIDAC + FIREDAC + ZEOS + SQLDB + fallback) em vez das apenas 2-3 antes.
3. A nova seção "Por que NÃO usar {$IFDEF}" explica **o motivo técnico** da preferência — o agente que lê aprende o porquê, não só o "o que". Isso fortalece a propagação do padrão correto.

**Nome proposto:** `developer-delphi-to-fpc-programming-conditional-defines`. Justificativa: a própria motivação da skill (Regra 2: *"evitar símbolo não definido"* + portabilidade FPC) é cross-compile. Hoje o nome `developer-delphi-*` sugere Delphi-only, mas a skill é a mais cross-compile do pack — portanto N2 aplica com alta confiança.

**Dependências cruzadas afetadas por rename:**

- `CLAUDE.md:199` (já corrigido na Onda E1 desta sessão).
- `developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md:13` aponta para `project-diretivas-compilacao_V1.0.1/` (path antigo — **Q2 a corrigir na onda L03**).
- `developer-delphi-patterns-creational_V1.1.0/SKILL.md` (se adicionada a seção "Dependências" sugerida) referenciaria.
- Nenhum agent `.cursor/agents/*.md` grepado contendo este nome hoje (verificar na L20/L21).
- 25 outras skills com `{$IFDEF}` em exemplos (lista na Onda E4) — após corrigir SKILL.md canônico, fica óbvio replicar o padrão correto.

---

### Arquivo 6/7: `developer-delphi-programming-oop-fluent_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-programming-oop-fluent_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 186 linhas
**Model:** sonnet
**Category:** project
**Thinking:** normal

**Frontmatter integral:**

```yaml
---
name: developer-delphi-programming-oop-fluent
description: >
  Padrão transversal obrigatório — toda programação no projeto deve ser orientada a
  objeto com fluência total. Usar ao criar qualquer unidade de lógica de negócio,
  serviço, repositório ou camada de aplicação. Garante que procedures soltas, código
  global e lógica não encapsulada sejam substituídos por classes, interfaces e
  fluent builders com terminal .Execute.
model: sonnet
thinking: normal
category: project
---
```

**Responsabilidade declarada** (linha 18):

> "Garantir que **todo** código de negócio do projeto seja orientado a objeto com **fluência total**. Esta skill define o padrão transversal que se aplica a qualquer unit de domínio, serviço, repositório ou camada de aplicação. É a referência normativa consultada antes de criar qualquer unit de lógica de negócio."

**Achados de qualidade (Q):**

- **Q1:** Não. Skill é consistente internamente (exemplo de fluent chain usa exatamente o padrão que ensina).
- **Q2:** ❌ — linha 163: *"`backend-pascal-unit-naming_V1.2.0` — naming canônico de units"*. A rule atual é **V1.4.0** (confirmado em `.cursor/rules/backend-pascal-unit-naming_V1.4.0.mdc`). Referência **desatualizada**.
  - Também linha 167: *"`backend-pascal-unit-naming_V1.2.0.mdc`"* no texto "Cross-reference".
- **Q3:** Não — conteúdo é específico de OOP/fluent.
- **Q4:** Não — exemplos são rich (TAuthService com Login/Refresh/Logout/ValidateToken builders completos).
- **Q5:** ⚠ — exemplos misturam nomes genéricos (`TAuthService`) com referências MXX concretas do GestorERP (linhas 106-115 tabela "Exemplos concretos do GestorERP — M01"). Conflito de audiência: a skill diz ser "genérica para qualquer projeto" (linha 1 do changelog 1.0.0 em 17/04) mas os exemplos MXX são específicos do GestorERP. Isto é contradição Q5 e placement (artefato específico do clone misturado com genérico).
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ⚠ — `developer-delphi-programming-oop-fluent` tem 4 componentes no nome. N1 genericamente ok, mas `oop-fluent` poderia ser `fluent-api` para ser mais preciso (fluent é a novidade; oop é pressuposto em Delphi).
- **N2:** ⚠ — fluent API funciona Delphi+FPC (sintaxe de interface é a mesma). Candidato rename.
- **N3:** ✅ — `oop-fluent` é objeto técnico concreto.
- **N4:** ✅.
- **N5:** ⚠ — `category: project` + exemplos MXX sugerem que parte do conteúdo pertence a `.workspace/` (específico do GestorERP). Skill está misturando audiências: padrão genérico (`.cursor/`) + exemplos do clone específico (que deveriam estar em `.workspace/skills/gestorerp-*` ou similar).

**Placement:**

- Atual: `.cursor/`
- Correto: **híbrido** — o corpo (padrão fluent genérico) fica em `.cursor/`, **mas** a seção "Exemplos concretos do GestorERP — M01" (linhas 105-116) tem conteúdo específico do outro clone (GestorERP). Deveria:
  - Mover exemplos GestorERP para `.workspace/skills/gestorerp-oop-fluent-examples_V1.0.0/` do clone GestorERP.
  - Substituir os exemplos aqui por exemplos genéricos (TUserService, TOrderService, etc. sem referência a M01).

**Exemplos/templates internos:** pasta `exemplos/` não existe. Todos os exemplos são inline no SKILL.md.

**Correção proposta (Q2 + Q5):**

```diff
@@ linha 162-167
 - `developer-delphi-language-oop_V1.1.0` — sintaxe OOP Delphi
 - `developer-delphi-programming-oop-naming_V1.0.0` — convenção de nomenclatura
-- `backend-pascal-unit-naming_V1.2.0` — naming canônico de units
+- `backend-pascal-unit-naming_V1.4.0` — naming canônico de units (rule atual do pack)

 ## Skills relacionadas

 - `developer-delphi-modular-backend-scaffold_V1.0.0` — scaffold completo de módulo MXX
 - `developer-delphi-patterns-creational_V1.1.0` — padrões Factory/Builder
 - `project-orchestrator_V1.2.0` — orquestrador da família project-*
```

E substituir exemplos MXX por genéricos:

```diff
@@ linhas 105-116 (tabela "Exemplos concretos do GestorERP — M01")
-## Exemplos concretos do GestorERP — M01
-
-| Conceito | Interface | Classe | Unit |
-| --- | --- | --- | --- |
-| Auth service | `IAuthService` | `TAuthService` | `Commons.Security.Service.Auth.pas` |
-| Login builder | `ILoginBuilder` | `TLoginBuilder` | (em `Auth.Interfaces.pas`) |
-| OBAC engine | `IOBACService` | `TOBACService` | `Commons.Security.Service.Obac.pas` |
-| JWT utility | `IJwtService` | `TJwtService` | `Commons.Access.Auth.Jwt.pas` |
-| Audit writer | `IAuditWriter` | `TAuditWriter` | `Commons.Audit.Writer.pas` |
-| User repository | `IUserRepository` | `TUserRepository` | `Security.Repository.User.pas` |
-| Auth controller | `IAuthController` | `TAuthController` | `Access.Controller.Auth.pas` |
-| Bootstrap | `IBootstrap` | `TBootstrap` | `MainService.pas` (in `Core/`) |
+## Exemplos concretos (genéricos — substituir nomes conforme projeto)
+
+| Conceito | Interface | Classe | Unit |
+| --- | --- | --- | --- |
+| Service | `IUserService` | `TUserService` | `Commons.Users.Service.User.pas` |
+| Action builder | `ILoginBuilder` | `TLoginBuilder` | (em `<Service>.Interfaces.pas`) |
+| Repository | `IUserRepository` | `TUserRepository` | `Users.Repository.User.pas` |
+| Controller | `IUserController` | `TUserController` | `Access.Controller.Users.pas` |
+
+> Exemplos específicos de projetos derivados (ex.: módulos MXX do GestorERP, tabelas concretas do ERP do cliente) devem ser movidos para `.workspace/skills/<projeto>-oop-fluent-examples_V*/` do respectivo clone.
```

**Nome proposto:** `developer-delphi-programming-oop-fluent` → **manter**. A skill é OOP/Pascal genérico, serve Delphi e FPC. Um rename para `-to-fpc-*` confundiria porque o padrão fluent não é "cross-compile" per se — é OOP. Deixar como está é mais claro.

**Dependências cruzadas:**

- `documentation-project-expert_V1.0.0/SKILL.md` referencia indiretamente (padrão Fluent citado).
- `developer-delphi-modular-backend-scaffold_V1.0.0/SKILL.md` (Skill relacionada, linha 167).
- `developer-delphi-programming-oop-naming_V1.0.0/SKILL.md:185` lista como Dependência.

---

### Arquivo 7/7: `developer-delphi-programming-oop-naming_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-programming-oop-naming_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 210 linhas
**Model:** sonnet
**Category:** project
**Thinking:** normal

**Frontmatter integral:**

```yaml
---
name: developer-delphi-programming-oop-naming
description: >
  Convenção de nomenclatura OOP para módulos e submódulos Delphi: TModulo/IModulo,
  prefixo Commons. em Commons/, Controllers (não EntryPoint), fluent builder interfaces
  (IOperacaoBuilder). Escopo: apenas código Delphi (backend + módulos ORM).
model: sonnet
thinking: normal
category: project
---
```

**Responsabilidade declarada** (linhas 15-19):

> "Definir e aplicar a convenção de nomenclatura OOP para classes, interfaces e units Delphi do projeto. Garante que módulos mestres e submódulos sigam a hierarquia `TModulo / TModuloSubclasse`, que files em `Commons/` usem prefixo `Commons.`, que controllers usem `Controller` (não `EntryPoint`), e que fluent builders nomeiem suas interfaces conforme o padrão."
>
> "**Escopo:** apenas código Delphi (backend `projects/backend/` e módulos ORM em `projects/modules/`)."

**Achados de qualidade (Q):**

- **Q1:** Não.
- **Q2:** ❌ — Mesma ref quebrada de oop-fluent: linha 149 menciona `backend-pascal-unit-naming_V1.2.0.mdc`, linha 187 também. Rule atual é V1.4.0.
- **Q3:** Não.
- **Q4:** Não — exemplos são concretos.
- **Q5:** ⚠ — igual à oop-fluent: seção "Exemplos concretos do GestorERP — M01" (linha 105-116) com dados MXX do GestorERP (Auth, OBAC, JWT específicos daquele clone), enquanto a skill se declara genérica.
  - Linha 20: *"`projects/backend/` e módulos ORM em `projects/modules/`"* — caminhos que **este clone ProvidersORM não tem** (ProvidersORM tem `src/Modulos/`, não `projects/modules/`). Confusão entre clones.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ⚠ — `programming-oop-naming` com 3 componentes; parecido com oop-fluent.
- **N2:** ⚠ — naming-naming é pouco sobre cross-compile, mas a regra se aplica a Delphi+FPC.
- **N3:** ✅.
- **N4:** ✅ — distinto de oop-fluent (um é naming, outro é estilo de API).
- **N5:** ⚠ — escopo literal diz "backend + módulos ORM" com caminhos `projects/backend/` do GestorERP, não do ProvidersORM. Conteúdo mistura padrão genérico (Categoria A) + paths específicos de um clone (Categoria B).

**Placement:** híbrido — mesmo que oop-fluent. Corpo genérico fica em `.cursor/`, mas exemplos GestorERP + paths `projects/backend/` devem migrar para `.workspace/` do GestorERP.

**Exemplos/templates internos:** pasta `exemplos/` não existe; tudo inline.

**Correção proposta (Q2 + Q5):**

```diff
@@ linha 149
-Authority rule: `.cursor/rules/backend-pascal-unit-naming_V1.2.0.mdc`
+Authority rule: `.cursor/rules/backend-pascal-unit-naming_V1.4.0.mdc`

@@ linha 187
-- `backend-pascal-unit-naming_V1.2.0` — naming canônico de units (rule)
+- `backend-pascal-unit-naming_V1.4.0` — naming canônico de units (rule)

@@ linha 20 (escopo)
-**Escopo:** apenas código Delphi (backend `projects/backend/` e módulos ORM em `projects/modules/`).
+**Escopo:** apenas código Delphi. O layout físico do backend e módulos varia por projeto — este clone ProvidersORM usa `src/Modulos/`, clones derivados (ex.: GestorERP) podem usar `projects/backend/`. A regra de naming não depende do layout de pastas.

@@ linhas 105-116 (tabela de exemplos MXX)
-## Exemplos concretos do GestorERP — M01
-
-| Conceito | Interface | Classe | Unit |
-| --- | --- | --- | --- |
-| Auth service | `IAuthService` | `TAuthService` | `Commons.Security.Service.Auth.pas` |
-| Login builder | `ILoginBuilder` | `TLoginBuilder` | (em `Auth.Interfaces.pas`) |
-| OBAC engine | `IOBACService` | `TOBACService` | `Commons.Security.Service.Obac.pas` |
-| JWT utility | `IJwtService` | `TJwtService` | `Commons.Access.Auth.Jwt.pas` |
-| Audit writer | `IAuditWriter` | `TAuditWriter` | `Commons.Audit.Writer.pas` |
-| User repository | `IUserRepository` | `TUserRepository` | `Security.Repository.User.pas` |
-| Auth controller | `IAuthController` | `TAuthController` | `Access.Controller.Auth.pas` |
-| Bootstrap | `IBootstrap` | `TBootstrap` | `MainService.pas` (in `Core/`) |
+## Exemplos concretos (genéricos)
+
+| Conceito | Interface | Classe | Unit |
+| --- | --- | --- | --- |
+| Service | `IUserService` | `TUserService` | `Commons.Users.Service.User.pas` |
+| Action builder | `ILoginBuilder` | `TLoginBuilder` | (em `Users.Service.Interfaces.pas`) |
+| Repository | `IUserRepository` | `TUserRepository` | `Users.Repository.User.pas` |
+| Controller | `IUsersController` | `TUsersController` | `Access.Controller.Users.pas` |
+
+> Exemplos específicos por projeto (MXX do GestorERP, módulos internos do ProvidersORM, etc.) ficam em `.workspace/skills/<projeto>-oop-naming-examples_V*/SKILL.md` do respectivo clone.
```

**Nome proposto:** `developer-delphi-programming-oop-naming` → **manter**. Mesmo raciocínio de oop-fluent.

**Dependências cruzadas:**

- `.cursor/rules/backend-pascal-unit-naming_V1.4.0.mdc` (ref a ser corrigida).
- `developer-delphi-programming-oop-fluent_V1.0.0/SKILL.md:163, 186-187` (Dependências).
- `developer-delphi-modular-backend-scaffold_V1.0.0/SKILL.md` (mencionado em "Skills relacionadas").
- `documentation-project-expert_V1.0.0/SKILL.md` (mencionado em "Skills relacionadas", linha 191).

---

## Ações acumuladas para execução

### E1-candidatas (CLAUDE.md refs quebradas detectadas neste lote)

Nenhuma adicional. A correção E1 já foi aplicada nesta sessão (commit separado).

### E4-candidatas (Q1/Q7 para fix imediato) — **CRÍTICO**

**Arquivo:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-programming-conditional-defines_V1.0.0\SKILL.md`

**Trecho a substituir:** linhas 87-121 (2 blocos "Exemplo mínimo compilável").

**Correção completa:** ver bloco `diff` completo na seção "Arquivo 5/7" acima, incluindo adição de nova seção "Por que NÃO usar `{$IFDEF}` e `{$ELSEIF}` neste projeto" (3 motivos técnicos).

**Propagação (lista de 25 skills com `{$IFDEF}` detectadas previamente, a corrigir):** listadas em ondas posteriores (L01, L03, L05, L10, L11, L14, L15, L16, L17, L18) quando forem auditadas. Por enquanto, deixar em E4.

### E5-candidatas (renames propostos nesta família)

1. `developer-delphi-patterns-behavioral` → `developer-delphi-to-fpc-patterns-behavioral` (condicional a leitura de `exemplos/*.pas` confirmar cross-compile)
2. `developer-delphi-patterns-composition` → `developer-delphi-to-fpc-patterns-orchestrator` (aplica N2 + N3 + N4 — ambiguidade com "Composite pattern")
3. `developer-delphi-patterns-creational` → `developer-delphi-to-fpc-patterns-creational` (condicional)
4. `developer-delphi-patterns-structural` → `developer-delphi-to-fpc-patterns-structural` (condicional)
5. `developer-delphi-programming-conditional-defines` → `developer-delphi-to-fpc-programming-conditional-defines` (aplica N2 alta confiança — skill é cross-compile por essência)
6. `developer-delphi-programming-oop-fluent` → **manter** (OOP é universal, não cross-compile specific)
7. `developer-delphi-programming-oop-naming` → **manter** (mesmo raciocínio)

Para cada rename aprovado na Onda E5, atualizar:

- Frontmatter `name:`
- Heading H1 do SKILL.md
- Changelog interno (nova entrada)
- Referências cruzadas nas skills listadas em "Dependências cruzadas" de cada seção acima
- CLAUDE.md se houver menção
- Manifesto `skills-pack-manifest_V1.17.0.md` → `V1.19.0.md` (Onda 5.7)
- Espelhos `.claude/`, `.vscode/`, `.continue/`, `.opencode/` via `Bootstrap-MirrorSymlinks.ps1 -Repair`

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 em patterns-behavioral/composition/creational/structural:** Adicionar seções V2 (When to use, When NOT to use, Dependências, Anti-padrões, Métricas, Responsável). Ver blocos `diff` específicos em cada seção acima.

2. **Q2 em programming-oop-fluent:** linhas 163, 167 — atualizar `backend-pascal-unit-naming_V1.2.0` → `V1.4.0`.

3. **Q2 em programming-oop-naming:** linhas 149, 187 — atualizar `backend-pascal-unit-naming_V1.2.0` → `V1.4.0`.

4. **Q3 em patterns-behavioral/creational/structural:** corrigir ausência de Changelog (apenas V1.1.0 aparece ou não aparece). Adicionar changelog standard.

5. **Q5 em programming-oop-fluent:** linhas 105-116 — substituir tabela "Exemplos concretos do GestorERP — M01" por exemplos genéricos (`TUserService` etc.). Mover exemplos MXX para `.workspace/skills/gestorerp-oop-fluent-examples_V1.0.0/` no clone GestorERP.

6. **Q5 em programming-oop-naming:** linhas 20, 105-116 — idem. Também corrigir escopo (linha 20) que menciona `projects/backend/` específico do GestorERP.

7. **Q6 em patterns-creational:** adicionar referência à convenção de Factory obrigatória (`class function New: IXxx`) e link cruzado com `developer-delphi-programming-oop-fluent_V1.0.0`.

### N-candidatas adicionais (nomenclatura)

- **N3 em patterns-composition:** o nome `composition` confunde com "Composite pattern" (que é structural) e "composição sobre herança" (princípio). Rename `patterns-composition` → `patterns-orchestrator` resolve.

### Placement migrations

Duas skills precisam split entre `.cursor/` (corpo genérico) e `.workspace/` (exemplos concretos do GestorERP):

1. `developer-delphi-programming-oop-fluent_V1.0.0`: corpo fica; tabela MXX migra.
2. `developer-delphi-programming-oop-naming_V1.0.0`: corpo fica; tabela MXX + referência `projects/backend/` migra.

Destino proposto: `.workspace/skills/gestorerp-oop-examples_V1.0.0/` **do clone GestorERP** (não deste clone ProvidersORM). Este clone **não** precisa criar essa pasta — o conteúdo MXX aqui é do outro projeto e deve sumir deste pack. Coordenação entre clones fora do escopo do ProvidersORM.

---

## Síntese do lote L09

- **7 skills auditadas** com detalhe completo por arquivo.
- **1 skill CRÍTICA** (Arquivo 5 — conditional-defines) com Q1+Q7 graves — **caso-zero** do problema reportado pelo usuário.
- **2 skills com mistura de audiência** (.cursor + .workspace do GestorERP) — Arquivos 6 e 7.
- **4 skills patterns-*** sólidas em conteúdo mas faltando seções V2 obrigatórias (Q3 leve).
- **7 renames candidatos** (5 confirmados N2, 2 mantidos).
- **6 refs quebradas Q2** (V1.2.0 → V1.4.0 da rule backend-pascal-unit-naming).

**Próxima onda sugerida:** L01 (architecture) — 3 skills, alinhamento com L09 (patterns + programming são bases da arquitetura).

**Commit sugerido:** `docs(audit): relatório lote L09 patterns + programming — caso-zero conditional-defines detalhado`
