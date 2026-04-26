---
name: audit-L04-docs
description: Relatório de auditoria do lote L04 — docs-to-structured-code + documentation-governance (2 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L03-build.md
version: 1.0
date: 2026-04-24
scope: 2 skills em .cursor/skills/developer-delphi-{docs-to-structured-code,documentation-governance}
---

# Relatório Auditoria — Lote L04 docs

**Data:** 24/04/2026
**Escopo:** 2 arquivos na família:

1. `developer-delphi-docs-to-structured-code_V1.0.0`
2. `developer-delphi-documentation-governance_V1.0.0`

**Contexto budget consumido:** ~13KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | docs-to-structured-code_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ⚠ | ✅ | ❌ | ⚠ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-docs-to-structured-code | **alta** |
| 2 | documentation-governance_V1.0.0 | ❌ | ❌ | ⚠ | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ⚠ | ⚠ | .cursor | .cursor (mas re-categorização em `documentation-*` a considerar) | documentation-skills-pack-governance | **alta** |

## Detalhe por arquivo

### Arquivo 1/2: `developer-delphi-docs-to-structured-code_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-docs-to-structured-code_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 140 linhas
**Model:** sonnet
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-docs-to-structured-code
description: Converte documentação canônica em codificação estruturada por projeto/módulo com rastreabilidade e validação Delphi/FPC.
model: sonnet
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 18):

> "Esta skill transforma documentação canônica do projeto (`Documentation/Arquitetura`, `Regras de Negocio`, `Roadmap`, `Analise`) em código Object Pascal estruturado, com rastreabilidade entre requisito e implementação, plano incremental e validação obrigatória em Delphi e FPC. Ela NÃO cria documentação nova, NÃO decide arquitetura macro e NÃO executa build autônomo — apenas converte especificações existentes em implementação rastreável."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ Sim. Checklist linha 72 exige `{$IFDEF}` conforme regra canônica; exemplo linha 95 usa `{$IFDEF FPC}`.

- **Q2 (ref quebrada):** ❌ Múltiplas:
  - Linha 133: `E:\CSL\ProvidersORM\Documentation` — **path absoluto do clone**. Viola portabilidade; se esta skill é propagada via `sync-cursor-pack` para outro clone, o path não existe.
  - Linha 135: `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md` — **skill renomeada** para `developer-delphi-programming-conditional-defines_V1.0.0`. Path morto.

- **Q3 (boilerplate):** ⚠ Leve — Checklist linhas 65-77 tem 9 bullets do template + 2 específicos (linhas 76-77).

- **Q4 (exemplo vazio):** ❌ Sim. Linhas 79-99 — `WriteLn('OK')` triviais para uma skill cuja essência é **conversão de docs em código estruturado**. Exemplo substantivo seria: partir de um trecho de documentação (ex.: "Módulo X deve expor `IConnection.ExecuteCommand(SQL: string): Boolean`") e mostrar a implementação estruturada resultante (unit + interface + impl).

- **Q5 (idioma):** ⚠ Leve — título da seção "Avaliacao de risco e confirmacao" (linha 126) sem acento, mas texto interno usa acentos. Inconsistência.

- **Q6 (regra ausente):** Não.

- **Q7 (anti-padrão ativo):** ❌ Sim. Mesmo `{$IFDEF FPC}`.

**Achados de nomenclatura (N):**

- **N1:** ⚠ — prefixo `developer-delphi-*` ok, mas o objeto "docs-to-structured-code" sugere também projetos web/outros stacks. Existe skill irmã `developer-web-docs-to-structured-code` (confirmado em lote L14 futuro). Como são skills distintas com conteúdo específico do stack, o prefixo ajuda. Mas **ambas podem ter sobreposição de workflow** — revisar em L14.

- **N2 (cross-compile explícito):** ⚠ — skill descreve "validação obrigatória em Delphi e FPC" (linha 18). Cross-compile explícito. **Candidato a rename** `developer-delphi-to-fpc-docs-to-structured-code`.

- **N3 (objeto técnico):** ✅ — `docs-to-structured-code` é claro (conversão docs→código).

- **N4 (sinônimo):** ✅ — nenhuma sobreposição dentro do stack Delphi.

- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Exemplos/templates internos:** pasta `exemplos/` **não existe**; tudo inline.

**Correção proposta:**

```diff
@@ linha 95 (Exemplo FPC — {$IFDEF})
 program SampleDocsToCodeFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
 begin
   WriteLn('OK -- developer-delphi-docs-to-structured-code');
 end.
```

Substituir Exemplo mínimo por algo substantivo:

```diff
@@ linhas 79-99 (substituir Exemplo mínimo por exemplo real de conversão docs→código)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleDocsToCodeDelphi;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-docs-to-structured-code');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleDocsToCodeFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-begin
-  WriteLn('OK -- developer-delphi-docs-to-structured-code');
-end.
-```
+## Exemplo: conversão documentação → código estruturado
+
+**Entrada (trecho de `Documentation/Arquitetura/Modulo.md`):**
+
+> "O módulo Usuários deve expor a interface `IUserService` com operação `Login(email, senha): TLoginResult`.
+> `Login` consulta o repositório `IUserRepository.FindByEmail`, valida a senha via `IPasswordHasher.Verify`
+> e retorna `TLoginResult` com (success: Boolean, userId: Integer, token: string)."
+
+**Saída estruturada (cross-compile Delphi+FPC):**
+
+```pascal
+unit Users.Service.Interfaces;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+interface
+
+type
+  TLoginResult = record
+    Success: Boolean;
+    UserId: Integer;
+    Token: string;
+  end;
+
+  IUserService = interface
+    ['{B3A6D9E1-7C24-4A15-9F3E-02F7C1E59D18}']
+    function Login(const AEmail, APassword: string): TLoginResult;
+  end;
+
+implementation
+
+end.
+```
+
+```pascal
+unit Users.Service.Impl;
+{$IF DEFINED(FPC)}{$mode delphi}{$ENDIF}
+interface
+
+uses Users.Service.Interfaces, Users.Repository.Interfaces, Common.PasswordHasher;
+
+type
+  TUserService = class(TInterfacedObject, IUserService)
+  private
+    FRepo: IUserRepository;
+    FHasher: IPasswordHasher;
+  public
+    constructor Create(const ARepo: IUserRepository; const AHasher: IPasswordHasher);
+    class function New(const ARepo: IUserRepository; const AHasher: IPasswordHasher): IUserService;
+    function Login(const AEmail, APassword: string): TLoginResult;
+  end;
+
+implementation
+
+constructor TUserService.Create(const ARepo: IUserRepository; const AHasher: IPasswordHasher);
+begin
+  inherited Create;
+  FRepo := ARepo;
+  FHasher := AHasher;
+end;
+
+class function TUserService.New(const ARepo: IUserRepository; const AHasher: IPasswordHasher): IUserService;
+begin
+  Result := TUserService.Create(ARepo, AHasher);
+end;
+
+function TUserService.Login(const AEmail, APassword: string): TLoginResult;
+var
+  LUser: IUser;
+begin
+  FillChar(Result, SizeOf(Result), 0);
+  LUser := FRepo.FindByEmail(AEmail);
+  if (LUser <> nil) and FHasher.Verify(APassword, LUser.PasswordHash) then
+  begin
+    Result.Success := True;
+    Result.UserId := LUser.Id;
+    Result.Token := GenerateToken(LUser.Id); // helper externo
+  end;
+end;
+
+end.
+```
+
+**Tabela de rastreabilidade:**
+
+| Requisito (docs) | Unit | Interface/Tipo | Método |
+|---|---|---|---|
+| `IUserService.Login(email, senha): TLoginResult` | `Users.Service.Interfaces` | `IUserService` | `Login` |
+| `TLoginResult` com (success, userId, token) | `Users.Service.Interfaces` | `TLoginResult` record | — |
+| Consulta repositório `IUserRepository.FindByEmail` | `Users.Service.Impl` | `TUserService` | `Login` linha 20 |
+| Validação via `IPasswordHasher.Verify` | `Users.Service.Impl` | `TUserService` | `Login` linha 20 |
```

```diff
@@ linha 133-135 (Referencias — refs quebradas)
-- `E:\CSL\ProvidersORM\Documentation`
-- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
-- `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`
+- `Documentation/` do projeto onde esta skill é aplicada (estrutura canônica: `Arquitetura/`, `Regras de Negocio/`, `Roadmap/`, `Analise/`)
+- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
+- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
```

```diff
@@ linha 126 (Avaliação de risco — acento)
-## Avaliacao de risco e confirmacao
+## Avaliação de risco e confirmação
```

**Comentário:** exemplo novo demonstra **exatamente** o objetivo da skill (docs → unit + interface + impl + tabela de rastreabilidade), tornando-a útil em vez de trivial. Exemplo anterior era `WriteLn('OK')` que não agrega nada.

**Nome proposto:** `developer-delphi-to-fpc-docs-to-structured-code` (N2 — skill declara "validação em Delphi e FPC" explícita).

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md` (se referenciar — não está na matriz explícita; validar em futuras ondas).
- `developer-delphi-architecture-and-design_V1.0.0/SKILL.md:33` (When NOT to use).
- `developer-web-docs-to-structured-code_V1.0.0/SKILL.md` — equivalente web; documenta família cruzada. Auditar em L14 para decidir se ambos seguem mesmo padrão de rename (web não é cross-compile, então não renomeia).

---

### Arquivo 2/2: `developer-delphi-documentation-governance_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-documentation-governance_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0 (tabela linhas 13-15)
**Tamanho:** 127 linhas
**Model:** haiku
**Category:** developer-delphi
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-documentation-governance
description: Governança documental das skills e artefatos: padrão de conteúdo, changelog, rastreabilidade e fontes.
model: haiku
thinking: extended
category: developer-delphi
---
```

**Responsabilidade declarada** (linha 18):

> "Esta skill governa a criação e manutenção de documentação técnica das skills e artefatos do projeto: aplica padrões de conteúdo, valida changelogs, mantém rastreabilidade de fontes e atualiza o hub documental consolidado (`.cursor/SKILLS_DOCUMENTATION_vX.Y.Z.md`). Ela NÃO compila código, NÃO implementa features e NÃO define arquitetura de módulos — seu escopo é exclusivamente a qualidade e consistência da documentação técnica do pack."

**Achados de qualidade (Q):**

- **Q1 (auto-contradição):** ❌ Sim — Checklist linha 59 exige `{$IFDEF}` conforme regra canônica; exemplo linha 82 usa `{$IFDEF FPC}`. Notavelmente, a skill cobre **governança de skills** e ela mesma descumpre a governança da skill canônica de diretivas. Auto-contradição dupla.

- **Q2 (ref quebrada):** ❌ Sim:
  - Linha 30: `use delphi-fpc-docs-to-structured-code` — skill renomeada para `developer-delphi-docs-to-structured-code`. Ref morta.
  - Linha 119: `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md` — skill renomeada. Ref morta.

- **Q3 (boilerplate):** ⚠ Leve — Checklist 9 bullets + 2 específicos.

- **Q4 (exemplo vazio):** ❌ Sim. Linhas 66-86 — `WriteLn('OK')` para uma skill cujo objeto é **governar documentação**. Exemplo substantivo seria: estrutura de changelog obrigatório, template de Referências, exemplo de hub `SKILLS_DOCUMENTATION_vX.Y.Z.md`.

- **Q5:** Não.

- **Q6 (regra ausente):** Não.

- **Q7 (anti-padrão ativo):** ❌ Sim.

**Achados de nomenclatura (N):**

- **N1:** ❌ — **problema crítico.** A skill governa **documentação das skills e artefatos do pack** (linha 18). Isto **não é específico do stack Delphi**. É meta-documentação do próprio `.cursor/`. Prefixo `developer-delphi-*` é **enganoso**: um dev olha e pensa "esta skill é sobre Delphi", mas ela trata de changelog, hub consolidado, padrão de conteúdo das skills — política de documentação do pack inteiro (incluindo skills web, governance, documentation, etc.).

  **Proposta:** renomear/mover para prefixo `documentation-*` ou `governance-*`:
  - Opção A: `documentation-skills-pack-governance` (categoria: documentation — governa pack de skills).
  - Opção B: `governance-pack-documentation` (categoria: governance — governança documental do pack).

  Na família `governance-*` já existe `governance-pack-checklist-validation`, `governance-pack-sync`, `governance-pack-versioning-policy`. Uma `governance-pack-documentation` se alinharia com as irmãs. Mas também faz sentido como `documentation-skills-pack-governance` na família `documentation-*`.

  **Recomendação:** `governance-pack-documentation` (alinha com outras `governance-pack-*`).

- **N2:** ✅ — cross-compile não se aplica (skill não é sobre código, é sobre governança).

- **N3:** ✅ — `documentation-governance` é objeto claro (se mantido o prefixo).

- **N4:** ⚠ — possível sobreposição com:
  - `governance-constitution-policies` (política constitucional de docs).
  - `documentation-general_rules` (regras gerais de docs).
  - `documentation-versioning-changelog` (changelog de docs).

  Auditoria L15/L16/L17 precisará confirmar se há sinônimo oculto. Hoje, a skill tem escopo específico (hub `SKILLS_DOCUMENTATION_vX.Y.Z.md` + governança do pack) que não sobrepõe 100% com as 3 acima.

- **N5:** ⚠ — audiência declarada "governança documental" mas prefixo sugere audiência "desenvolvedor Delphi". Incongruência com conteúdo.

**Placement:** `.cursor/` correto (skill é governança reutilizável). **Mas** audiência implícita precisa ser corrigida via rename (N1 + N5).

**Exemplos/templates internos:** pasta `exemplos/` não existe; tudo inline.

**Correção proposta (renomeação + Q2 + Q4 + Q7):**

```diff
@@ frontmatter (rename completo)
 ---
-name: developer-delphi-documentation-governance
+name: governance-pack-documentation
 description: Governança documental das skills e artefatos: padrão de conteúdo, changelog, rastreabilidade e fontes.
-model: haiku
+model: sonnet
 thinking: extended
-category: developer-delphi
+category: governance-process
 ---

-# developer-delphi-documentation-governance
+# governance-pack-documentation
```

```diff
@@ linha 30 (When NOT to use — ref quebrada + rename)
-- Não usar para implementar módulos a partir de documentação → use `delphi-fpc-docs-to-structured-code`.
+- Não usar para implementar módulos a partir de documentação → use `developer-delphi-docs-to-structured-code` (ou `developer-web-docs-to-structured-code` para web).

@@ linhas 66-86 (substituir Exemplo mínimo — não faz sentido `WriteLn` para skill de governança)
-## Exemplo mínimo compilável
-
-**Delphi (dcc32 / dcc64):**
-
-```pascal
-program SampleDocGovernanceDelphi;
-{$APPTYPE CONSOLE}
-begin
-  WriteLn('OK -- developer-delphi-documentation-governance');
-end.
-```
-
-**Free Pascal (fpc32 / fpc64):**
-
-```pascal
-program SampleDocGovernanceFPC;
-{$IFDEF FPC}{$mode delphi}{$ENDIF}
-begin
-  WriteLn('OK -- developer-delphi-documentation-governance');
-end.
-```
+## Exemplo: entradas canônicas numa skill bem-governada
+
+Esta skill não tem "exemplo compilável" porque não gera código — governa texto/metadados. Exemplo = estrutura obrigatória de SKILL.md:
+
+**1. Frontmatter obrigatório:**
+
+```yaml
+---
+name: <prefixo>-<slug-kebab>
+description: <1-2 frases objetivas>
+model: haiku|sonnet|opus
+thinking: minimal|normal|extended
+category: developer-delphi|documentation|governance|quality|version|project
+---
+```
+
+**2. Tabela "Versão interna (ficheiro)" após o H1:**
+
+```markdown
+## Versão interna (ficheiro)
+
+| Campo | Valor |
+|-------|-------|
+| **FileVersion** | 1.0.0 |
+| **Política** | `.cursor/VERSION.md` |
+```
+
+**3. Seções V2 obrigatórias (na ordem):**
+
+- `## Responsabilidade única` (1 parágrafo: o que faz + o que NÃO faz).
+- `## When to use` (bullets com contextos disparadores).
+- `## When NOT to use` (bullets + aponta para skills alternativas).
+- `## Inputs` (o que a skill recebe).
+- `## Workflow executável` (passos numerados).
+- `## Dependências (skills prévias)` (tabela).
+- `## Anti-padrões` (tabela: anti-padrão | por que | como corrigir).
+- `## Métricas de sucesso` (bullets mensuráveis).
+- `## Responsável principal` (tabela: papel | quem).
+- `## Referencias` (bullets com paths canônicos).
+- `## Changelog (este arquivo)` (entradas `- X.Y.Z (DD/MM/AAAA): ...`).
+
+**4. Hub consolidado `.cursor/SKILLS_DOCUMENTATION_vX.Y.Z.md`:**
+
+- Versão no nome = versão no cabeçalho interno (SemVer pack).
+- Lista todas as skills ativas + depreciadas.
+- Cada entrada com link para `SKILL.md` + versão + categoria.
+- Atualização obrigatória em toda operação que adicione/remova/renomeie skill.
+
+**5. Validação:**
+
+```bash
+python .cursor/scripts/validate_pack.py --indexes-fresh --no-instance-strings
+```
+
+Deve retornar "0 issues found" antes de fechar uma sessão de governança documental.
```

```diff
@@ linha 119 (Referencias — ref quebrada)
-- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
-- `.cursor/skills/project-diretivas-compilacao_V1.1.0/exemplos/diretivas_compilacao.md`
+- `.cursor/skills/developer-delphi-build-toolchain_V1.0.0/exemplos/compile.md`
+- `.cursor/skills/developer-delphi-programming-conditional-defines_V1.0.0/exemplos/diretivas_compilacao.md`
```

**Comentário:** rename `developer-delphi-documentation-governance` → `governance-pack-documentation` alinha com irmãs governance-pack-* e corrige incoerência de audiência (N1+N5). Exemplo novo substitui `WriteLn('OK')` trivial por estrutura real que a skill exige nas outras skills.

**Nome proposto:** `governance-pack-documentation` (N1+N5 — move para família governance alinhada com `governance-pack-{sync,checklist-validation,versioning-policy}`).

**Dependências cruzadas afetadas por rename:**

- `developer-delphi-orchestrator_V1.1.0/SKILL.md:247` ("Governança/changelog | developer-delphi-documentation-governance").
- `developer-delphi-docs-to-structured-code_V1.0.0/SKILL.md:30` (When NOT to use).
- `developer-delphi-build-cross-compiler_V1.0.0/SKILL.md:31` (When NOT to use: *"use developer-delphi-documentation-governance"*).
- Agent `documentation-agent-rules_V1.4.0.md` possivelmente (auditar em L21).

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma neste lote.

### E4-candidatas (Q1/Q7 para fix imediato)

1. `developer-delphi-docs-to-structured-code_V1.0.0/SKILL.md:95` — `{$IFDEF FPC}` → `{$IF DEFINED(FPC)}` (parte da substituição completa do exemplo — diff acima).
2. `developer-delphi-documentation-governance_V1.0.0/SKILL.md:82` — idem.

### E5-candidatas (renames propostos)

**Prioridade alta:**

1. `developer-delphi-docs-to-structured-code` → `developer-delphi-to-fpc-docs-to-structured-code` (N2).
2. `developer-delphi-documentation-governance` → `governance-pack-documentation` (N1+N5 — re-categorização de família: `developer-delphi-*` → `governance-*`). Esta é **mudança de família**, não apenas prefixo — mais impactante que os renames L01/L02/L03.

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Q2 docs-to-structured-code:133** — path absoluto `E:\CSL\ProvidersORM\Documentation` → `Documentation/` (relativo + nota sobre portabilidade).
2. **Q2 docs-to-structured-code:135** — `project-diretivas-compilacao_V1.1.0` → `developer-delphi-programming-conditional-defines_V1.0.0`.
3. **Q2 documentation-governance:30** — `delphi-fpc-docs-to-structured-code` → `developer-delphi-docs-to-structured-code`.
4. **Q2 documentation-governance:119** — `project-diretivas-compilacao_V1.1.0` → `developer-delphi-programming-conditional-defines_V1.0.0`.
5. **Q4 docs-to-structured-code:79-99** — substituir `WriteLn('OK')` por exemplo real de conversão docs→código (diff completo acima com user service como caso).
6. **Q4 documentation-governance:66-86** — substituir `WriteLn('OK')` por estrutura de SKILL.md bem-governada (diff completo acima).
7. **Q5 docs-to-structured-code:126** — `"Avaliacao de risco"` → `"Avaliação de risco"` (acento).
8. **Q3 nas 2 skills** — Checklist Delphi+FPC 9 bullets do template; ambas têm 2-3 bullets próprios — padrão aceitável.

### Placement migrations

Re-categorização de `documentation-governance` de `developer-delphi-*` para `governance-*` (não é migração `.cursor/` ↔ `.workspace/`, mas mudança de prefixo/família dentro de `.cursor/`).

---

## Síntese do lote L04

- **2 skills auditadas** com detalhe completo.
- **Ambas com Q1+Q2+Q4+Q7** — propagação do anti-padrão caso-zero + refs quebradas a skills renomeadas §17.
- **docs-to-structured-code**: conteúdo sólido em intenção; exemplo trivial precisa substituição substantiva. Rename N2 `to-fpc-*` recomendado.
- **documentation-governance**: incoerência grave de família — prefixo `developer-delphi-*` conflita com responsabilidade (governança de pack de skills). Rename recomendado para `governance-pack-documentation`.
- **Total refs quebradas neste lote:** 4 (2 em cada skill).
- **2 renames propostos** (1 alta prioridade cross-compile, 1 alta prioridade re-categorização de família).

**Próxima onda sugerida:** L05 (mobile + errors) — 5 skills (error-handling, ios-publishing, ios-setup, android-publishing, android-setup).

**Commit sugerido:** `docs(audit): relatório lote L04 docs — 2 skills com rename crítico (1 cross-compile, 1 re-categorização governance)`
