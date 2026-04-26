---
name: audit-L05-mobile-errors
description: Relatório de auditoria do lote L05 — error-handling + mobile (iOS/Android setup/publishing, 5 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L04-docs.md
version: 1.0
date: 2026-04-24
scope: 5 skills em .cursor/skills/developer-delphi-{error-handling-and-diagnostics,ios-*,android-*}
---

# Relatório Auditoria — Lote L05 mobile + errors

**Data:** 24/04/2026
**Escopo:** 5 arquivos na família:

1. `developer-delphi-error-handling-and-diagnostics_V1.0.0`
2. `developer-delphi-ios-setup_V1.0.0`
3. `developer-delphi-ios-publishing_V1.0.0`
4. `developer-delphi-android-setup_V1.0.0`
5. `developer-delphi-android-publishing_V1.0.0`

**Contexto budget consumido:** ~35KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | error-handling-and-diagnostics_V1.0.0 | ❌ | ✅ | ⚠ | ⚠ | ⚠ | ✅ | ❌ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-error-handling-and-diagnostics | **alta** |
| 2 | ios-setup_V1.0.0 | ✅ | ❌ | ⚠ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | média |
| 3 | ios-publishing_V1.0.0 | ✅ | ❌ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | média |
| 4 | android-setup_V1.0.0 | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |
| 5 | android-publishing_V1.0.0 | ✅ | ✅ | ⚠ | ⚠ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | .cursor | .cursor | manter | baixa |

## Detalhe por arquivo

### Arquivo 1/5: `developer-delphi-error-handling-and-diagnostics_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-error-handling-and-diagnostics_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 155 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-error-handling-and-diagnostics
description: Taxonomia de exceções por domínio, diagnóstico e práticas seguras de tratamento de erro em Delphi/FPC.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill cobre a modelagem de hierarquias de exceções por domínio, investigação de falhas com base em logs e stack traces, padronização de blocos `try..except..finally` e propagação segura de erros em Delphi e FPC. Ela NÃO realiza refatoração arquitetural ampla e NÃO define estratégia de testes — seu foco é exclusivamente o tratamento correto, rastreável e seguro de erros em runtime."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ **Sim.** Checklist linha 58 exige `{$IFDEF}` conforme regra canônica. Exemplo linha 87 (`program SampleErrorFPC`) usa `{$IFDEF FPC}`. Linha 103-105 (Unit de referência) idem: `{$IFDEF FPC} {$mode delphi} {$ENDIF}`.

- **Q2 (ref quebrada):** Não.

- **Q3 (boilerplate):** ⚠ Leve. Checklist 9 bullets do template + 2 específicos (linhas 62-63).

- **Q4 (exemplo vazio):** ⚠ Leve. Os 2 exemplos linhas 67-97 usam `raise Exception.Create('OK ...')` — mostram `try..except` minimamente mas não demonstram o **foco da skill** (hierarquia de exceções por domínio). A "Unit de referência" (linhas 99-117) tem só `EDomainError = class(Exception);` sem demonstrar hierarquia multi-camada, códigos por domínio ou preservação de stack trace.

- **Q5 (idioma):** ⚠ Leve. Linha 143 "Avaliacao de risco e confirmacao" sem acentos (consistente com outros da família).

- **Q6 (regra ausente):** Não.

- **Q7 (anti-padrão ativo):** ❌ **Sim.** Linhas 87, 103 — `{$IFDEF FPC}`.

**Achados de nomenclatura (N):**

- **N1:** ✅.

- **N2 (cross-compile explícito):** ⚠ — skill declara explicitamente "Delphi e FPC" (linhas 3, 18). Cross-compile substantivo. **Candidato a rename** `developer-delphi-to-fpc-error-handling-and-diagnostics`.

- **N3:** ✅ — `error-handling-and-diagnostics` é objeto técnico preciso.

- **N4:** ✅ — distinto de `debugging-techniques` (este último foca em investigar bugs em desenvolvimento; este foca em modelagem de exceções por domínio).

- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** pasta `exemplos/` não existe; tudo inline.

**Correção proposta:**

```diff
@@ linha 87 (Exemplo FPC — {$IFDEF})
 program SampleErrorFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
 uses SysUtils;

@@ linha 103 (Unit de referência — {$IFDEF})
 unit Sample.Errors;
-{$IFDEF FPC}
+{$IF DEFINED(FPC)}
   {$mode delphi}
 {$ENDIF}
```

Sugestão adicional (Q4): enriquecer a "Unit de referência" com hierarquia real multi-camada (seria mais didático):

```diff
@@ linhas 99-117 (substituir Unit de referência trivial por hierarquia real)
-**Unit de referência (Delphi + FPC):**
-
-```pascal
-unit Sample.Errors;
-{$IFDEF FPC}
-  {$mode delphi}
-{$ENDIF}
-interface
-
-uses
-  SysUtils;
-
-type
-  EDomainError = class(Exception);
-
-implementation
-
-end.
-```
+**Unit de referência — hierarquia por domínio (Delphi + FPC):**
+
+```pascal
+unit Sample.Errors;
+{$IF DEFINED(FPC)}
+  {$mode delphi}
+{$ENDIF}
+interface
+
+uses
+  SysUtils;
+
+type
+  // Exceção base do projeto — raiz da hierarquia
+  EProviderError = class(Exception)
+  private
+    FErrorCode: Integer;
+  public
+    constructor CreateWithCode(const AErrorCode: Integer; const AMessage: string);
+    property ErrorCode: Integer read FErrorCode;
+  end;
+
+  // Exceções por domínio (herdam de EProviderError)
+  EConnectionError = class(EProviderError);  // 40XXX
+  EDatabaseError   = class(EProviderError);  // 30XXX
+  EConfigError     = class(EProviderError);  // 50XXX
+
+  // Exceções específicas (herdam da respectiva de domínio)
+  ENotConnected    = class(EConnectionError);
+  EInvalidHost     = class(EConnectionError);
+  EPrimaryKeyViolation = class(EDatabaseError);
+
+implementation
+
+constructor EProviderError.CreateWithCode(const AErrorCode: Integer; const AMessage: string);
+begin
+  inherited Create(Format('[%.5d] %s', [AErrorCode, AMessage]));
+  FErrorCode := AErrorCode;
+end;
+
+end.
+```
+
+**Uso típico (preservação de stack trace):**
+
+```pascal
+try
+  LConn.Connect;
+except
+  on E: EConnectionError do
+    // Captura todas as subclasses de conexão (ENotConnected, EInvalidHost, ...)
+    LogError(E.ErrorCode, E.Message);
+  on E: Exception do
+    // Fallback — re-lança preservando stack trace (use `raise` sem parâmetro)
+    raise;
+end;
+```
```

```diff
@@ linha 143 (acento)
-## Avaliacao de risco e confirmacao
+## Avaliação de risco e confirmação
```

**Comentário:** correções resolvem Q1/Q7 (IFDEF) + Q4 leve (exemplo substantivo com hierarquia real de 3 camadas + faixas de códigos por domínio, alinhado com a própria regra da skill — "pelo menos um tipo por domínio crítico" nas Métricas linha 132).

**Nome proposto:** `developer-delphi-to-fpc-error-handling-and-diagnostics` (N2 — skill explicitamente cross-compile).

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md:112, 159` (Família H + matriz).
- `developer-delphi-architecture-and-design_V1.0.0/SKILL.md:29` (When NOT to use).
- `developer-delphi-docs-to-structured-code_V1.0.0/SKILL.md:32` (When NOT to use).
- `developer-delphi-build-cross-compiler_V1.0.0/SKILL.md:32` (When NOT to use).
- `developer-delphi-debugging-techniques_V1.0.0/SKILL.md:32, 58` (When NOT to use + Dependências).

---

### Arquivo 2/5: `developer-delphi-ios-setup_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-ios-setup_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (frontmatter linha 3)
**Tamanho:** 203 linhas
**Model:** sonnet
**Category:** developer-delphi
**Family:** K (Mobile)
**Thinking:** false

**Frontmatter integral:**

```yaml
---
name: developer-delphi-ios-setup
version: 1.0.0
description: "Configuração completa da plataforma iOS para projetos Delphi FMX: PAServer, certificados Apple, provisioning profiles, SDK Manager e configuração .dproj."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
---
```

**Responsabilidade declarada** (linha 14):

> "Configurar o ambiente de desenvolvimento iOS para Delphi FMX: PAServer no Mac, certificados Apple Development/Distribution, provisioning profiles (Development/Ad Hoc/App Store), SDK Manager iOS e mapeamento `.dproj` para iOS Device 64-bit."

**Achados de qualidade (Q):**

- **Q1:** Não. Skill não tem exemplo Pascal com `{$IFDEF}`; só XML `.dproj` e configuração.

- **Q2 (ref quebrada):** ❌ Sim. Possível menção a `delphi-fpc-*` ou `project-*` desatualizados? Busca rápida no texto:
  - Linhas 185 (tabela família K) usam `developer-delphi-*` ✅.
  - Não aparecem refs `delphi-fpc-*` ou `project-*`.

  Corrigindo análise: **Q2 não é verdadeiro aqui.** Nenhuma ref quebrada detectada.

  **Re-classificação:** Q2 ✅.

- **Q3 (boilerplate):** ⚠ Leve. Skill usa template diferente das skills V2: não tem tabela "Versão interna (ficheiro)", "Responsabilidade única" é um parágrafo curto, falta seção "Inputs", "Workflow executável", "Dependências" detalhada. Template mais recente (11/04) mas com seções pack-V2 incompletas.

- **Q4:** Não — conteúdo substantivo sobre PAServer, certificados, provisioning, SDK Manager, `.dproj`.

- **Q5:** Não.

- **Q6 (regra ausente):** ⚠ Leve. Skill cita "PAServer rodando" como dependência mas não tem tabela "Dependências (skills prévias)". Recomendável adicionar para alinhar com template V2.

- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅. Skill é **iOS-only** (Delphi + PAServer Mac; FPC não publica iOS). Prefixo `developer-delphi-*` correto sem rename.

**Placement:** `.cursor/` correto (padrão reutilizável para qualquer projeto Delphi iOS).

**Exemplos/templates internos:** pasta `exemplos/` não existe; XML inline.

**Correção proposta:**

```diff
@@ após linha 12 (adicionar tabela Versão interna)
 # developer-delphi-ios-setup_V1.0.0

+## Versão interna (ficheiro)
+
+| Campo | Valor |
+|-------|-------|
+| **FileVersion** | 1.0.0 |
+| **Política** | `.cursor/VERSION.md` |
+
 ## Responsabilidade única
```

```diff
@@ após linha 22 (adicionar seção "Dependências (skills prévias)")
-## Dependências
+## Dependências (skills prévias)
+
+| Skill | Quando executar antes |
+|-------|-----------------------|
+| `developer-delphi-mobile-orchestrator_V1.1.0` | Para decidir plataforma (iOS ou Android) |
+| `developer-delphi-ios-publishing_V1.0.0` | Para publicar após setup completo |
+
+## Dependências do ambiente

 - Mac com Xcode instalado e conta Apple Developer ativa
```

**Comentário:** skill é sólida em conteúdo técnico; apenas carece de seções V2 padronizadas. Correções são cosméticas.

**Nome proposto:** manter.

**Dependências cruzadas afetadas:** nenhum rename proposto.

---

### Arquivo 3/5: `developer-delphi-ios-publishing_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-ios-publishing_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 145 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-ios-publishing
description: Publicacao de app iOS com Delphi (App Store, Enterprise interno e MDM), cobrindo dproj, provisioning, certificados, IPA e validacoes de distribuicao.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linhas 18-19):

> "Esta skill governa o fluxo completo de publicação de aplicativos iOS gerados com Delphi, desde a validação do `.dproj` e certificados até a geração do `.ipa` assinado e distribuição (App Store, OTA Enterprise ou MDM). Cobre configuração de provisioning, `Info.plist`, `Entitlements.plist` e plano de renovação de certificados. Não aborda lógica de domínio, regras de negócio, compilação FPC ou design de UI — essas responsabilidades pertencem a skills dedicadas."

**Achados de qualidade (Q):**

- **Q1:** Não.

- **Q2 (ref quebrada):** ❌ Sim:
  - Linha 29: *"use `delphi-fpc-architecture-and-design`"* — skill renomeada §17 para `developer-delphi-architecture-and-design`. Ref morta.
  - Linha 33: *"use `delphi-fpc-orchestrator`"* — renomeada para `developer-delphi-orchestrator`. Ref morta.
  - Linha 49: Dependências — `delphi-fpc-orchestrator` (mesma ref morta).
  - Linha 133: Revisor — `delphi-fpc-testing-and-quality` → `developer-delphi-testing-and-quality`. Ref morta.

- **Q3 (boilerplate):** ⚠ Leve. Tem **2 checklists** (Checklist iOS linhas 61-70 + Checklist Delphi+FPC linhas 72-81). O Checklist Delphi+FPC é o boilerplate 9 bullets propagado; aqui é **incongruente** porque a skill explicitamente diz "Não aborda compilação FPC" (linha 19) e o Checklist menciona FPC.

- **Q4 (exemplo vazio):** ⚠ Leve. Linhas 91-103 — `Writeln('iOS publishing preflight check OK')` — trivial para uma skill que faz preflight real. Um exemplo mais rico seria um preflight que lê `Info.plist` ou valida bundle id.

- **Q5:** Não.

- **Q6 (regra ausente):** Não.

- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** todas ✅. Skill é **iOS-only**. Sem rename.

**Placement:** `.cursor/` correto.

**Correção proposta:**

```diff
@@ linha 29 (When NOT to use — refs quebradas)
-- Design de domínio ou regras de negócio → usar `delphi-fpc-architecture-and-design`.
+- Design de domínio ou regras de negócio → usar `developer-delphi-architecture-and-design`.

@@ linha 33 (ref quebrada)
-- Orquestração de múltiplas etapas Delphi → usar `delphi-fpc-orchestrator`.
+- Orquestração de múltiplas etapas Delphi → usar `developer-delphi-orchestrator`.

@@ linha 49 (Dependências — ref quebrada)
-| `delphi-fpc-orchestrator`         | Quando iOS for etapa de um fluxo multi-plataforma               |
+| `developer-delphi-orchestrator`   | Quando iOS for etapa de um fluxo multi-plataforma               |

@@ linha 133 (Responsável — ref quebrada)
-| Revisor            | `delphi-fpc-testing-and-quality`            |
+| Revisor            | `developer-delphi-testing-and-quality`      |
```

Correção adicional (Q3 — Checklist Delphi+FPC incongruente):

```diff
@@ linhas 72-81 (remover Checklist Delphi+FPC — skill é iOS-only; manter apenas Checklist iOS)
-## Checklist Delphi+FPC
-
-- [ ] Compilação sem hints/warnings em Delphi (dcc32 + dcc64 onde aplicável)
-- [ ] Memory management: Create/Free em try..finally; sem leaks (`ReportMemoryLeaksOnShutdown`)
-- [ ] Tratamento de exceções: hierarquia do projeto (`EProviderError` ou equivalente)
-- [ ] Nomenclatura: prefixos `T`/`I`/`E`/`F`/`A` conforme `documentation-project-expert`
-- [ ] Diretivas `{$IFDEF}` conforme `developer-delphi-programming-conditional-defines`; sem mistura com paths
-- [ ] Separação UI/lógica: zero SQL ou regras de negócio em event handlers
-- [ ] Plano inclui validação cross-compiler (quando aplicável ao target iOS)
-- [ ] Referências a `compile.md` e `diretivas_compilacao.md` verificadas quando aplicável
-
+<!-- Removido: Checklist Delphi+FPC genérico não se aplica a iOS-only. Checklist iOS acima é suficiente. -->
```

**Comentário:** Q3 crítico aqui — Checklist Delphi+FPC é contraditório com a declaração explícita "Não aborda compilação FPC" (linha 19). Remoção reduz ruído e torna skill mais focada.

**Nome proposto:** manter.

**Dependências cruzadas afetadas:** nenhum rename. Apenas corrigir 4 refs quebradas.

---

### Arquivo 4/5: `developer-delphi-android-setup_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-android-setup_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (frontmatter linha 3)
**Tamanho:** 280 linhas
**Model:** sonnet
**Category:** developer-delphi
**Family:** K (Mobile)
**Thinking:** false

**Frontmatter integral:**

```yaml
---
name: developer-delphi-android-setup
version: 1.0.0
description: "Configuração completa da plataforma Android para projetos Delphi FMX: Android SDK/NDK via SDK Manager, AndroidManifest.template.xml, modelo de permissões em dois níveis (manifesto + runtime) e Android Services."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
---
```

**Responsabilidade declarada** (linha 14):

> "Configurar o ambiente de desenvolvimento Android para Delphi FMX: Android SDK/NDK, ativação da plataforma Android 64-bit, AndroidManifest.template.xml com variáveis de placeholder, modelo de permissões em dois níveis (declaração no manifesto + solicitação em runtime via PermissionsService) e Android Services."

**Achados de qualidade (Q):**

- **Q1:** Não. Skill não tem `{$IFDEF}` em exemplo Pascal.

- **Q2:** Não — refs às skills família K atualizadas (linhas 257-262).

- **Q3 (boilerplate):** ⚠ Leve. Mesmo problema do ios-setup: falta tabela "Versão interna" e seções V2 padronizadas.

- **Q4:** Não — conteúdo rico (manifest template, tabela de permissões 16 entradas, Android Services, PermissionsService exemplo Pascal real).

- **Q5:** Não.

- **Q6 (regra ausente):** ⚠ Leve. Falta "Dependências (skills prévias)" tabulada.

- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** ✅. Skill Android-only (Delphi + FMX). Sem rename.

**Placement:** `.cursor/` correto.

**Correção proposta:** idêntica à ios-setup — adicionar tabela Versão interna e seção "Dependências (skills prévias)" tabulada.

**Nome proposto:** manter.

---

### Arquivo 5/5: `developer-delphi-android-publishing_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-android-publishing_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (frontmatter linha 3)
**Tamanho:** 292 linhas
**Model:** sonnet
**Category:** developer-delphi
**Family:** K (Mobile)
**Thinking:** false

**Frontmatter integral:**

```yaml
---
name: developer-delphi-android-publishing
version: 1.0.0
description: "Publicação de apps Android no Google Play: criação de keystore via keytool, configuração de assinatura no .dproj, geração de APK assinado e AAB, Google Play Console workflow (Internal→Production), Play App Signing e versionamento."
model: sonnet
category: developer-delphi
family: K (Mobile)
thinking: false
---
```

**Responsabilidade declarada** (linhas 14-15):

> "Cobrir o ciclo completo de publicação Android: criação e gestão segura de keystore, configuração de assinatura no `.dproj` via variáveis de ambiente, geração de APK assinado e AAB (obrigatório para Google Play), workflow do Google Play Console (Internal → Closed → Open → Production), Play App Signing, versionamento (`versionCode`/`versionName`) e checklist pré-publicação."

**Achados de qualidade (Q):**

- **Q1:** Não.

- **Q2:** Não — refs família K atualizadas.

- **Q3 (boilerplate):** ⚠ Leve. Mesmo problema dos outros 3 mobile (falta seções V2).

- **Q4 (exemplo vazio):** ⚠ Leve. Skill não tem "Exemplo mínimo compilável" — adequado porque skill é sobre processo de publicação (não código). **Não aplicar Q4 aqui.** ⚠ reavaliado para ✅.

- **Q5:** Não — pt-BR sem acentos consistente.

- **Q6 (regra ausente):** Não — cobertura completa (keystore, .dproj, APK/AAB, Play Console, versionamento, assets, checklist 11 itens).

- **Q7:** Não.

**Achados de nomenclatura (N):**

- **N1-N5:** ✅. Android-only. Sem rename.

**Placement:** `.cursor/` correto.

**Correção proposta:** idem android-setup — adicionar tabela Versão interna + seção "Dependências (skills prévias)" tabulada.

**Nome proposto:** manter.

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma neste lote.

### E4-candidatas (Q1/Q7 para fix imediato)

**Prioridade alta:**

1. `developer-delphi-error-handling-and-diagnostics_V1.0.0/SKILL.md:87, 103` — `{$IFDEF FPC}` → `{$IF DEFINED(FPC)}` em 2 locais (Exemplo FPC + Unit de referência).

### E5-candidatas (renames propostos)

**Prioridade alta:**

1. `developer-delphi-error-handling-and-diagnostics` → `developer-delphi-to-fpc-error-handling-and-diagnostics` (N2 — skill declara "Delphi e FPC" explícito).

**Sem rename:**

- ios-setup, ios-publishing, android-setup, android-publishing (4 skills platform-specific).

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 ios-publishing:29, 33, 49, 133** — 4 refs quebradas `delphi-fpc-*`.
2. **Q3 ios-publishing:72-81** — remover Checklist Delphi+FPC incongruente (skill declara "não aborda FPC").
3. **Q3 nos 4 mobile** (ios-setup, ios-publishing, android-setup, android-publishing) — adicionar tabela "Versão interna (ficheiro)" padronizada.
4. **Q3/Q6 ios-setup:23-28 e android-setup:23-29** — seção "Dependências" atual lista dependências do ambiente (Mac, Xcode, SDK/NDK); adicionar seção "Dependências (skills prévias)" tabulada.
5. **Q4 error-handling-and-diagnostics:99-117** — substituir Unit de referência trivial por hierarquia real multi-camada (diff completo acima).
6. **Q4 ios-publishing:91-103** — substituir `Writeln('iOS publishing preflight check OK')` por exemplo de preflight mais substantivo (opcional, baixa prioridade).
7. **Q4 error-handling-and-diagnostics:67-81** — sugerir adicionar exemplo `try..except` com hierarquia customizada (opcional).
8. **Q5 error-handling-and-diagnostics:143** — "Avaliacao de risco e confirmacao" → "Avaliação de risco e confirmação" (acento).

### Placement migrations

Nenhuma.

---

## Síntese do lote L05

- **5 skills auditadas** com detalhe completo.
- **1 skill CRÍTICA** (error-handling-and-diagnostics) com Q1+Q7 — `{$IFDEF FPC}` em 2 locais.
- **1 skill com Q2 significativo** (ios-publishing) — 4 refs quebradas `delphi-fpc-*`.
- **4 skills mobile (ios/android setup+publishing)** — conteúdo sólido mas template V2 incompleto (falta tabela Versão interna + seção Dependências).
- **1 rename proposto:** `error-handling-and-diagnostics` → `-to-fpc-*` (N2).
- **Observação importante sobre mobile:** skills mobile são **platform-specific por natureza** (iOS via PAServer Mac é Delphi-only; FPC não publica iOS/Android via RAD Studio). Nenhuma precisa de rename `-to-fpc-*`. Foram suspeitas N2 no plano original baseadas em grep que retornou false-positive.

**Próxima onda sugerida:** L06 (fmx) — 7 skills `developer-delphi-fmx-*` (animations, components, containers, effects, frames, layout, patterns). FMX é Delphi-only por design; Q1/Q7 devem ser pequenos, foco em N3/N4.

**Commit sugerido:** `docs(audit): relatório lote L05 errors + mobile — 1 crítica (error-handling), 4 refs ios-publishing, template V2 incompleto nos 4 mobile`
