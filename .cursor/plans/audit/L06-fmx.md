---
name: audit-L06-fmx
description: Relatório de auditoria do lote L06 — developer-delphi-fmx-* (7 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L05-mobile-errors.md
version: 1.0
date: 2026-04-24
scope: 7 skills em .cursor/skills/developer-delphi-fmx-*
---

# Relatório Auditoria — Lote L06 fmx

**Data:** 24/04/2026
**Escopo:** 7 arquivos na família:

1. `developer-delphi-fmx-layout_V1.1.0` (orquestradora)
2. `developer-delphi-fmx-animations_V1.0.0`
3. `developer-delphi-fmx-components_V1.0.0`
4. `developer-delphi-fmx-containers_V1.0.0`
5. `developer-delphi-fmx-effects_V1.0.0`
6. `developer-delphi-fmx-frames_V1.0.0`
7. `developer-delphi-fmx-patterns_V1.0.0`

**Contexto budget consumido:** ~40KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | fmx-layout_V1.1.0 (orch) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ⚠ | ⚠ | .cursor | .cursor + revisar `.workspace/` | developer-delphi-fmx-master-orchestrator | média |
| 2 | fmx-animations_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | .cursor | .cursor + migrar exemplos GestorERP p/ .workspace | manter | média |
| 3 | fmx-components_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | .cursor | .cursor + migrar exemplos GestorERP | manter | média |
| 4 | fmx-containers_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | .cursor | .cursor + migrar "Paleta GestorERP" | manter | média |
| 5 | fmx-effects_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | zero |
| 6 | fmx-frames_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠ | .cursor | .cursor + migrar "Padrões GestorERP" | manter | média |
| 7 | fmx-patterns_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | .cursor | **.workspace/gestorerp-fmx-patterns_V1.0.0/** | (renomear/migrar) | **alta** |

## Detalhe por arquivo

### Arquivo 1/7: `developer-delphi-fmx-layout_V1.1.0/SKILL.md` (orquestradora)

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-layout_V1.1.0\SKILL.md`
**FileVersion:** 1.1.0 (tabela linha 15)
**Tamanho:** 216 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-layout
description: Orquestradora da Família A — FMX Layout. Delega para 6 micro-skills especializadas. Cobre hierarquia de containers, Align, Fill/Stroke, animações, efeitos GPU, componentes, frames herdáveis, LiveBindings, TMultiView e padrões de layout prontos para produção.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 20):

> "Ponto de entrada único para qualquer tarefa visual FMX. Identifica o domínio da tarefa e delega para a micro-skill adequada. Mantém contexto leve: toda a profundidade técnica está nas micro-skills referenciadas."

**Achados de qualidade (Q):**

- **Q1:** Não — sem exemplo compilável Pascal.
- **Q2:** Não — refs para `developer-delphi-fmx-*` corretas.
- **Q3:** Não.
- **Q4:** Não — exemplos inline demonstram uso real (estrutura declarativa `.fmx`, DestruirTudo, CarregarDados).
- **Q5:** Não — conteúdo consistente pt-BR.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ — FMX é Delphi-only por design (FPC não tem FMX).
- **N3:** ❌ — **mesmo problema de outras orquestradoras (L01, L02).** O nome `fmx-layout` sugere que a skill cobre **apenas layout**, mas ela é a **orquestradora da Família A inteira** (animations, components, containers, effects, frames, patterns). Conteúdo do SKILL.md linha 3 declara: *"Orquestradora da Família A — FMX Layout. Delega para 6 micro-skills"*. **Proposta N3:** `developer-delphi-fmx-master-orchestrator` (mesmo padrão proposto para `assembly-orchestrator` → `assembly-master-orchestrator` em L02).
- **N4:** ⚠ — `fmx-layout` colide conceitualmente com `fmx-containers` (que trata efetivamente de "layout" no sentido restrito). O nome atual confunde função (orquestradora) com tópico específico (layout/alignment).
- **N5:** ⚠ — linhas 117, 196-209 referenciam **GestorERP** diretamente (`UnitLogin.pas`, `FrmDasboard.pas`, `FrmListagem.pas`, `FrmModal.pas`, `FrmModeloCrud.pas`). Conteúdo específico deste clone externo. Mesma classificação placement híbrida de L09 (oop-fluent, oop-naming).

**Placement:**

- Atual: `.cursor/`.
- Correto: `.cursor/` **com** migração da seção "§4 — Padrões do projeto GestorERP" (linhas 194-209) para `.workspace/skills/gestorerp-fmx-patterns_V1.0.0/SKILL.md` do clone GestorERP (não deste clone ProvidersORM).

**Exemplos/templates internos:** `consultas_rapidas/mapa_skills_fmx.md`, `arquitetura_fmx.md`, `checklist_layout.md` (linhas 213-216).

**Correção proposta:**

```diff
@@ linhas 117, 194-209 (remover referências específicas do GestorERP)
 ### 2.1 Padrão de tela completa (layout típico GestorERP)
+(generalizar: "Padrão de tela completa (layout típico)")

@@ linhas 194-209 (mover seção §4 "Padrões do projeto GestorERP" para .workspace/ do GestorERP)
-## §4 — Padrões do projeto GestorERP
-
-Padrões identificados no código real do projeto:
-
-| Padrão | Localização | Micro-skill |
-|--------|-------------|-------------|
-| Drag sem titlebar | `UnitLogin.pas`: FArrastando, OnMouseMove | `fmx-patterns` |
-...
+<!-- Movido para .workspace/skills/gestorerp-fmx-patterns_V1.0.0/SKILL.md do clone GestorERP -->
+
+## §4 — Próximas camadas (referência genérica)
+
+Após escolher a micro-skill, consultar padrões específicos do projeto em:
+
+- `.workspace/skills/<projeto>-fmx-patterns_V*/SKILL.md` (se existir).
+- Ou `Documentation/UI/fmx-patterns.md` do projeto onde a skill é aplicada.
```

**Nome proposto:** `developer-delphi-fmx-master-orchestrator` (N3 — explícita que é master da Família A, distingue de `fmx-containers` que cobre layout propriamente dito).

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-fmx-animations_V1.0.0/SKILL.md:14` ("Skill orquestradora: `developer-delphi-fmx-layout_V1.1.0`" via seção "O que é esta skill" — verificar todas as irmãs; confirmado em pelo menos 4 skills).
- `developer-delphi-orchestrator_V1.1.0/SKILL.md:46` (Família A).
- `developer-delphi-fmx-components_V1.0.0/SKILL.md:15` ("Skill orquestradora: `developer-delphi-fmx-layout_V1.1.0`").
- `developer-delphi-fmx-containers_V1.0.0/SKILL.md:17` ("Orquestradora").
- `developer-delphi-fmx-effects_V1.0.0/SKILL.md:13` ("Skill orquestradora").
- `developer-delphi-fmx-frames_V1.0.0/SKILL.md:117` (tabela Skills relacionadas).
- `developer-delphi-fmx-patterns_V1.0.0/SKILL.md:93` (tabela Skills relacionadas).

---

### Arquivo 2/7: `developer-delphi-fmx-animations_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-animations_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (frontmatter linha 3)
**Tamanho:** 304 linhas
**Model:** sonnet

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-animations
version: 1.0.0
description: >
  Animações FMX no Delphi: TAnimator (runtime), TFloatAnimation / TColorAnimation
  (design-time e runtime), todos os TInterpolationType, padrões de cascade, hover,
  modal, tab-switch e lazy-load. Foco em GestorERP.
tags: [delphi, fmx, animations, interpolation, gesture, gestorerp]
model: sonnet
---
```

**Responsabilidade declarada** (linha 17-19):

> "Cobre **toda a API de animações do FMX**: `TAnimator` (animação programática de qualquer propriedade publicada `Single`, `TAlphaColor`, `TRectF`), classes declarativas `TFloatAnimation` / `TColorAnimation` / `TRectAnimation` / `TPathAnimation`, e padrões de uso no projeto GestorERP (entrada de tela, hover, modal, tab-switch, lazy-load)."

**Achados de qualidade (Q):**

- **Q1-Q4:** todos ✅ (exemplos concretos, API real, tabelas de interpolações completas).
- **Q5 (idioma):** ⚠ Leve — tags + description citam **"gestorerp"** e **"GestorERP"**. Conteúdo mistura padrão geral com casos específicos do GestorERP.
- **Q6:** Não.
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅ (FMX Delphi-only).
- **N3:** ✅ — `fmx-animations` preciso.
- **N4:** ✅.
- **N5:** ⚠ — mesmo padrão híbrido: conteúdo genérico (§1-§3) + padrões GestorERP (§4).

**Placement:** `.cursor/` **com** migração dos padrões GestorERP (§4, linhas 149-233) para `.workspace/skills/gestorerp-fmx-patterns_V1.0.0/` do clone GestorERP.

**Correção proposta:**

```diff
@@ linhas 1-10 (frontmatter — remover "GestorERP" da descrição e tags)
 ---
 name: developer-delphi-fmx-animations
 version: 1.0.0
 description: >
   Animações FMX no Delphi: TAnimator (runtime), TFloatAnimation / TColorAnimation
   (design-time e runtime), todos os TInterpolationType, padrões de cascade, hover,
-  modal, tab-switch e lazy-load. Foco em GestorERP.
-tags: [delphi, fmx, animations, interpolation, gesture, gestorerp]
+  modal, tab-switch e lazy-load.
+tags: [delphi, fmx, animations, interpolation, gesture]
 model: sonnet
 ---
```

```diff
@@ linha 148 (renomear seção §4)
-## § 4 — Padrões prontos GestorERP
+## § 4 — Padrões prontos (reutilizáveis em qualquer projeto FMX)
```

**Nome proposto:** manter.

---

### Arquivo 3/7: `developer-delphi-fmx-components_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-components_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (implícito no nome da pasta)
**Tamanho:** 225 linhas
**Model:** sonnet

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-components
description: Componentes FMX avançados — TMultiView, LiveBindings, inputs especializados e padrões GestorERP.
model: sonnet
---
```

**Responsabilidade declarada** (linha 10-13):

> "Cobre componentes FMX além dos básicos de layout: TMultiView, LiveBindings, inputs (TEdit/TMemo/TComboBox), TListView customizado, TArc como progressbar, e diálogos cross-platform com TDialogService. Parte da Família A — FMX Layout."

**Achados de qualidade (Q):**

- **Q1-Q4:** todos ✅.
- **Q5 (idioma):** ⚠ Leve — description menciona "padrões GestorERP"; §7 linhas 194-204 documenta "padrão GestorERP" com paleta de cores específica (vendas/estoque/financeiro/alertas).
- **Q6 (regra ausente):** ⚠ Leve — skill menciona LiveBindings mas não menciona quando NÃO usar (LiveBindings tem custo de complexidade). Poderia ter seção "Anti-padrões".
- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2:** ✅.
- **N3:** ✅.
- **N4:** ✅.
- **N5:** ⚠ — description inclui "padrões GestorERP" e §7 tem paleta específica GestorERP.

**Placement:** `.cursor/` **com** migração da §7 "progressbar_arc — padrão GestorERP" (linhas 194-204) para `.workspace/` do GestorERP.

**Correção proposta:**

```diff
@@ linha 3 (description — remover "GestorERP")
-description: Componentes FMX avançados — TMultiView, LiveBindings, inputs especializados e padrões GestorERP.
+description: Componentes FMX avançados — TMultiView, LiveBindings, inputs especializados, TListView, TArc, TDialogService.

@@ linhas 194-204 (§7 padrão GestorERP)
-## §7 — progressbar_arc.pas — padrão GestorERP
-
-O GestorERP usa arcos coloridos como indicadores de progresso em dashboards.
-Ver exemplo completo em `exemplos/progressbar_arc.pas`.
-
-Padrão de cores por domínio:
-- Vendas: `$FF3498DB` (azul)
-- Estoque: `$FF27AE60` (verde)
-- Financeiro: `$FFD4AC0D` (dourado)
-- Alertas: `$FFE74C3C` (vermelho)
+## §7 — progressbar_arc.pas — TArc como indicador circular
+
+Padrão reutilizável: `TArc` animado como indicador de progresso em dashboards.
+Ver exemplo completo em `exemplos/progressbar_arc.pas`.
+
+**Convenção de cores por domínio (exemplo genérico):**
+- Primária: `$FF3498DB` (azul)
+- Sucesso: `$FF27AE60` (verde)
+- Atenção: `$FFD4AC0D` (dourado)
+- Erro: `$FFE74C3C` (vermelho)
+
+Paletas específicas por projeto ficam em `.workspace/skills/<projeto>-fmx-palette_V*/`.
```

**Nome proposto:** manter.

---

### Arquivo 4/7: `developer-delphi-fmx-containers_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-containers_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linha 15)
**Tamanho:** 318 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-containers
description: Containers FMX: TRectangle, TLayout, TAlignLayout, Fill/Stroke, XRadius, Padding/Margins, tipografia FMX (TLabel, TText, TextSettings). Fundamentos de layout visual no FireMonkey — pré-requisito para todas as outras skills FMX.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 21-22):

> "Containers, alinhamento automático, preenchimento visual (Fill/Stroke), cantos arredondados, espaçamento (Padding/Margins) e tipografia FMX. Esta skill é o **pré-requisito** de toda a Família A — entender TAlignLayout é obrigatório antes de usar animações, efeitos ou frames."

**Achados de qualidade (Q):**

- **Q1-Q4, Q6, Q7:** todos ✅ — skill excelente; tabela TAlignLayout com 16 valores, padrões Top+Client/Left+Client/Top+Bottom+Client, Fill/Stroke/XRadius/Padding/Margins detalhados.
- **Q5 (idioma):** ⚠ Leve — §7.3 linhas 265-281 "Paleta tipográfica do GestorERP" cita **"Hierarquia de tamanhos usada no projeto"** com constantes específicas. Conteúdo GestorERP-específico.

**Achados de nomenclatura (N):**

- **N1-N4:** ✅.
- **N5:** ⚠ — §7.3 específico GestorERP.

**Placement:** `.cursor/` + migração §7.3 (linhas 265-281) para `.workspace/` do GestorERP.

**Correção proposta:**

```diff
@@ linhas 265-281 (§7.3 Paleta GestorERP)
-### 7.3 Paleta tipográfica do GestorERP
-
-```pascal
-// Hierarquia de tamanhos usada no projeto:
-const
-  FONT_TITULO    = 22;  // títulos de tela
-  FONT_SUBTITULO = 16;  // subtítulos, KPI labels
-  FONT_CORPO     = 13;  // texto de corpo, listas
-  FONT_CAPTION   = 11;  // rodapés, metadados
-
-// Cores de texto:
-const
-  COR_TEXTO_PRINCIPAL  = $FF222222;  // dark (fundo claro)
-  COR_TEXTO_SECUNDARIO = $FF999999;  // muted
-  COR_TEXTO_CLARO      = $FFFFFFFF;  // branco (fundo escuro)
-  COR_TEXTO_DESTAQUE   = $FF4A90E2;  // azul link/ação
-```
+### 7.3 Paleta tipográfica (exemplo genérico)
+
+```pascal
+// Hierarquia de tamanhos — ajustar ao design system do projeto:
+const
+  FONT_TITULO    = 22;
+  FONT_SUBTITULO = 16;
+  FONT_CORPO     = 13;
+  FONT_CAPTION   = 11;
+
+// Cores de texto — ajustar ao tema:
+const
+  COR_TEXTO_PRINCIPAL  = $FF222222;
+  COR_TEXTO_SECUNDARIO = $FF999999;
+  COR_TEXTO_CLARO      = $FFFFFFFF;
+  COR_TEXTO_DESTAQUE   = $FF4A90E2;
+```
+
+> Paletas específicas de projetos ficam em `.workspace/skills/<projeto>-fmx-palette_V*/`.
```

**Nome proposto:** manter.

---

### Arquivo 5/7: `developer-delphi-fmx-effects_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-effects_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 174 linhas
**Model:** sonnet

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-effects
description: Efeitos GPU FMX — sombras, blur, glow, reflexo e overlay fosco para modais. Família A — FMX Layout.
model: sonnet
---
```

**Responsabilidade declarada** (linha 10-12):

> "Cobre efeitos GPU do FireMonkey (FMX): sombras, blur, glow, reflexo, inner glow e o padrão de overlay fosco usado em modais. Parte da Família A — FMX Layout."

**Achados de qualidade (Q):**

- **Q1-Q7:** todos ✅ — skill exemplar (Q1 ausente, Q4 ausente, Q5 consistente, Q7 ausente).

**Achados de nomenclatura (N):**

- **N1-N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:** nenhuma. Skill é exemplar.

**Nome proposto:** manter.

---

### Arquivo 6/7: `developer-delphi-fmx-frames_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-frames_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 124 linhas
**Model:** sonnet

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-frames
description: TFrame no FireMonkey — criação, embedding, herança visual, ciclo de vida e padrões GestorERP.
model: sonnet
---
```

**Responsabilidade declarada** (linha 10-14):

> "Skill especializada em **TFrame no FireMonkey (FMX)**: criação, embedding, herança visual, ciclo de vida, padrões de uso real do GestorERP."

**Achados de qualidade (Q):**

- **Q1-Q4, Q6, Q7:** ✅.
- **Q5 (idioma):** ⚠ — description + linhas 46-90 explicitamente "Padrões do GestorERP". Conteúdo GestorERP-específico mas patterns são genéricos no código (DestruirTudo, Lazy-load, Herança Visual FMX, auto-map edt*↔txt*).

**Achados de nomenclatura (N):**

- **N1-N4:** ✅.
- **N5:** ⚠ — description reforça GestorERP; mas na prática os padrões são reutilizáveis (não são MXX-específicos).

**Placement:** `.cursor/` (patterns são genéricos) **com** remoção da auto-referência a "GestorERP" no description.

**Correção proposta:**

```diff
@@ linha 3 (description — remover "GestorERP")
-description: TFrame no FireMonkey — criação, embedding, herança visual, ciclo de vida e padrões GestorERP.
+description: TFrame no FireMonkey — criação, embedding, herança visual, ciclo de vida e padrões reutilizáveis (DestruirTudo, Lazy-load, CarregarDados, Herança Visual).

@@ linha 13 (remover "real do GestorERP")
-TFrame é o principal mecanismo de composição de UI em FMX. Diferente de TForm, um TFrame pode ser embutido dentro de outro controle, herdado visualmente, e reutilizado em múltiplos contextos.
 (mantém)

@@ linha 46 (renomear seção)
-## Padrões do GestorERP
+## Padrões reutilizáveis
```

**Nome proposto:** manter.

---

### Arquivo 7/7: `developer-delphi-fmx-patterns_V1.0.0/SKILL.md` — **PLACEMENT ERRADO**

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-fmx-patterns_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 99 linhas
**Model:** sonnet

**Frontmatter integral:**

```yaml
---
name: developer-delphi-fmx-patterns
description: Padrões visuais e de interação FMX no GestorERP — responsividade, modais, feedback e navegação.
model: sonnet
---
```

**Responsabilidade declarada** (linhas 10-16):

> "Skill especializada em **padrões visuais e de interação FMX** do GestorERP: drag sem titlebar, TStyleBook, arc progress, CRUD completo com confirmação.
>
> Estes padrões aparecem repetidamente no projeto e são implementados de forma específica — diferente do que a documentação oficial sugere."

**Achados de qualidade (Q):**

- **Q1-Q4, Q6, Q7:** todos ✅.
- **Q5 (idioma):** ❌ **SIM.** A skill declara ser "do GestorERP" (linha 3 + 12) e explicitamente menciona "Estes padrões... são implementados de forma específica — diferente do que a documentação oficial sugere". Apesar disso, o conteúdo dos patterns (drag sem titlebar, arc progress, TDialogService confirm, TStyleBook) **é genérico e reutilizável** — não há nada MXX-específico nem dependente deste clone.

**Achados de nomenclatura (N):**

- **N1:** ✅ (prefixo correto).
- **N2-N4:** ✅.
- **N5:** ❌ — **description afirma "GestorERP"** mas conteúdo é genérico. Classificação de placement incorreta: ou o nome deveria ser generalizado ou o placement deveria ser `.workspace/`.

**Placement:**

- Atual: `.cursor/`.
- Correto: **2 opções mutuamente exclusivas:**
  - **Opção A** (preferida): **generalizar description + conteúdo** — remover todas as menções a GestorERP, tornar 100% genérico. Permanece em `.cursor/`.
  - **Opção B**: mover para `.workspace/skills/gestorerp-fmx-patterns_V1.0.0/` do clone GestorERP. Perde reusabilidade.

**Decisão recomendada:** **Opção A** — patterns são universais; a incongruência está apenas nos textos. Correção cirúrgica.

**Correção proposta (Opção A):**

```diff
@@ linha 3 (description — remover "GestorERP")
-description: Padrões visuais e de interação FMX no GestorERP — responsividade, modais, feedback e navegação.
+description: Padrões visuais e de interação FMX reutilizáveis — drag sem titlebar, TStyleBook em runtime, TArc progressbar circular, CRUD com TDialogService. Reutilizáveis em qualquer projeto FMX.

@@ linhas 10-16 (O que é esta skill)
-## O que é esta skill
-
-Skill especializada em **padrões visuais e de interação FMX** do GestorERP:
-drag sem titlebar, TStyleBook, arc progress, CRUD completo com confirmação.
-
-Estes padrões aparecem repetidamente no projeto e são implementados de forma
-específica — diferente do que a documentação oficial sugere.
+## O que é esta skill
+
+Skill especializada em **padrões visuais e de interação FMX reutilizáveis**:
+drag sem titlebar, TStyleBook em runtime, TArc como progressbar circular,
+CRUD completo com confirmação via TDialogService.
+
+Estes padrões aparecem em projetos FMX desktop que implementam interfaces
+customizadas (sem a aparência padrão do sistema) e são úteis quando a
+documentação oficial do FMX não cobre o caso de uso completo.

@@ linha 30 (renomear seção)
-## Padrões do GestorERP
+## Padrões reutilizáveis

@@ Adicionar seção nova (após Arquivos desta skill)
+
+## Instâncias específicas por projeto
+
+Customizações visuais específicas de um projeto (paletas, cores MXX, layouts exclusivos)
+ficam em `.workspace/skills/<projeto>-fmx-patterns_V*/SKILL.md` do respectivo clone.
+Esta skill provê apenas os padrões **genéricos** (drag, TStyleBook, TArc, TDialogService).
```

**Nome proposto:** `developer-delphi-fmx-patterns` — **manter** (após generalização via Opção A).

**Dependências cruzadas afetadas:** nenhum rename se aplicar Opção A.

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma neste lote.

### E4-candidatas (Q1/Q7 para fix imediato)

Nenhuma. Família FMX está **limpa** de Q1/Q7 (sem `{$IFDEF FPC}` anti-padrão). FMX é Delphi-only e as skills não usam diretivas condicionais.

### E5-candidatas (renames propostos)

**Prioridade média:**

1. `developer-delphi-fmx-layout` → `developer-delphi-fmx-master-orchestrator` (N3+N4 — skill é orquestradora da Família A inteira, não apenas "layout"; colisão conceitual com `fmx-containers`).

**Sem rename:**

- fmx-animations, fmx-components, fmx-containers, fmx-effects, fmx-frames, fmx-patterns (6 skills).

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q5 fmx-layout:117, 194-209** — remover seção "§4 — Padrões do projeto GestorERP" (migrar para `.workspace/` do clone GestorERP).
2. **Q5 fmx-animations:1-10, 148** — generalizar frontmatter (remover tags/description "GestorERP") + seção §4.
3. **Q5 fmx-components:3, 194-204** — generalizar description + §7 (paleta genérica).
4. **Q5 fmx-containers:265-281** — generalizar §7.3 Paleta tipográfica.
5. **Q5 fmx-frames:3, 46** — generalizar description + título de seção.
6. **Q5 fmx-patterns:3, 10-16, 30** — generalização completa (Opção A acima).
7. **Q6 fmx-components** — adicionar seção "Anti-padrões" (quando NÃO usar LiveBindings).

### Placement migrations (Q5)

**Conteúdo específico de GestorERP em 5 das 7 skills FMX:**

- fmx-layout §4 → `.workspace/skills/gestorerp-fmx-patterns_V1.0.0/` (clone GestorERP)
- fmx-animations §4 → idem
- fmx-components §7 paleta → `.workspace/skills/gestorerp-fmx-palette_V1.0.0/`
- fmx-containers §7.3 paleta tipográfica → idem
- fmx-frames title + description → generalizar (sem migração, só cleanup de texto)
- fmx-patterns description + §§ → generalizar (Opção A)

Essas migrações são **tarefas no clone GestorERP**, não deste clone ProvidersORM. Aqui, apenas generalizamos os textos.

---

## Síntese do lote L06

- **7 skills auditadas** com detalhe completo.
- **0 skills com Q1/Q7** — FMX limpo de anti-padrões `{$IFDEF}`.
- **5 de 7 skills com Q5** — referências "GestorERP" no description/conteúdo; patterns genéricos mas com texto específico.
- **1 skill incongruente (fmx-patterns)** — declara "do GestorERP" mas conteúdo é universal. Decisão: **generalizar** (Opção A).
- **1 rename proposto:** `fmx-layout` → `fmx-master-orchestrator` (N3+N4 alinha com proposta de L01/L02 sobre orquestradoras mal-nomeadas).
- **1 skill exemplar (fmx-effects):** sem achados; servir de referência para estruturação das irmãs.

**Próxima onda sugerida:** L07 (horse) — 18 skills HTTP server Delphi+FPC. Família grande, cross-compile real.

**Commit sugerido:** `docs(audit): relatório lote L06 fmx — 7 skills limpas de Q1/Q7, 5 com Q5 (GestorERP cleanup), 1 rename N3 (master-orchestrator)`
