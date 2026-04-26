---
name: audit-L07-horse
description: Relatório de auditoria do lote L07 — developer-delphi-horse-* (18 skills) do plano pack-audit-context-isolated-waves v5.0.
plan: D:\Users\claiton.linhares\.claude\plans\quero-que-olhe-arquivo-bright-bear.md
previous: L06-fmx.md
version: 1.0
date: 2026-04-24
scope: 18 skills em .cursor/skills/developer-delphi-horse-*
---

# Relatório Auditoria — Lote L07 horse

**Data:** 24/04/2026
**Escopo:** 18 arquivos na família:

1. `developer-delphi-horse-orchestrator_V1.0.0`
2. `developer-delphi-horse-core_V1.0.0`
3. `developer-delphi-horse-client_V1.0.0`
4. `developer-delphi-horse-serialization_V1.0.0`
5. `developer-delphi-horse-security_V1.0.0`
6. `developer-delphi-horse-jwt_V1.0.0`
7. `developer-delphi-horse-cors_V1.0.0`
8. `developer-delphi-horse-handle-exception_V1.0.0`
9. `developer-delphi-horse-basic-auth_V1.0.0`
10. `developer-delphi-horse-compression_V1.0.0`
11. `developer-delphi-horse-etag_V1.0.0`
12. `developer-delphi-horse-paginate_V1.0.0`
13. `developer-delphi-horse-octet-stream_V1.0.0`
14. `developer-delphi-horse-clientip_V1.0.0`
15. `developer-delphi-horse-logger_V1.0.0`
16. `developer-delphi-horse-logger-console_V1.0.0`
17. `developer-delphi-horse-logger-logfile_V1.0.0`
18. `developer-delphi-horse-exception-logger_V1.0.0`

**Contexto budget consumido:** ~78KB

## Tabela-sumário

| # | Arquivo | Q1 | Q2 | Q3 | Q4 | Q5 | Q6 | Q7 | N1 | N2 | N3 | N4 | N5 | Placement atual | Placement correto | Nome proposto | Prioridade |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | horse-orchestrator_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ❌ | ✅ | ✅ | .cursor | .cursor | developer-delphi-horse-master-orchestrator | média |
| 2 | horse-core_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor + categoria | developer-delphi-to-fpc-horse-core | **alta** |
| 3 | horse-client_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ⚠ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-restrequest4delphi-client | média |
| 4 | horse-serialization_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ⚠ | ⚠ | ✅ | ⚠ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-dataset-serialize | média |
| 5 | horse-security_V1.0.0 | ✅ | ✅ | ⚠ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ❌ | ⚠ | ⚠ | .cursor | .cursor (split) | (split: jose-jwt + swagger) | **alta** |
| 6 | horse-jwt_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-jwt | média |
| 7 | horse-cors_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-cors | média |
| 8 | horse-handle-exception_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-handle-exception | média |
| 9 | horse-basic-auth_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-basic-auth | média |
| 10 | horse-compression_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-compression | média |
| 11 | horse-etag_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-etag | média |
| 12 | horse-paginate_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-paginate | média |
| 13 | horse-octet-stream_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-middleware-octet-stream | média |
| 14 | horse-clientip_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-util-clientip | média |
| 15 | horse-logger_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-logger | média |
| 16 | horse-logger-console_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-logger-provider-console | baixa |
| 17 | horse-logger-logfile_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-logger-provider-logfile | baixa |
| 18 | horse-exception-logger_V1.0.0 | ✅ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | ⚠ | ✅ | ✅ | ✅ | .cursor | .cursor | developer-delphi-to-fpc-horse-exception-logger | baixa |

**Observações globais:**

- **Zero Q1/Q7** — família Horse **não tem** anti-padrões `{$IFDEF FPC}` nos exemplos (diferente de L01/L03/L05). Horse já respeita a regra canônica implicitamente ou usa `{$MODE DELPHI}{$H+}` em exemplos FPC (não é `{$IFDEF}`).
- **Zero Q2** — nenhuma ref quebrada para `delphi-fpc-*` nesta família.
- **Todos com Q5 leve** — **18 skills** mencionam **"GestorERP"** nas "Notas GestorERP" (seção final de cada SKILL.md). Mesmo padrão híbrido de L06 FMX: conteúdo genérico + notas específicas do clone GestorERP.
- **Category incorreta em 18 skills** — todas declaram `category: project`, mas família é **dev-skill de framework terceiro reutilizável** → correto seria `category: developer-delphi`.

## Detalhe por arquivo

### Arquivo 1/18: `developer-delphi-horse-orchestrator_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-horse-orchestrator_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 135 linhas
**Model:** sonnet
**Category:** project
**Thinking:** minimal

**Frontmatter integral:**

```yaml
---
name: developer-delphi-horse-orchestrator
description: Orquestrador da família Horse para Delphi/FPC. Ponto de entrada único para Horse (servidor HTTP), middlewares (CORS, JWT, log, compressão, ETag, paginação, octet-stream, basic-auth, exception handling, ClientIP), segurança JWT/JOSE/Swagger, cliente HTTP RESTRequest4Delphi e serialização JSON↔DataSet. Classifica e roteia para a skill especializada correcta.
model: sonnet
thinking: minimal
category: project
---
```

**Responsabilidade declarada** (linhas 19-20):

> "Ponto de entrada único para o ecossistema **Horse** (servidor HTTP Express-like para Delphi/Lazarus FPC) e todos os pacotes complementares. Analisa o contexto e roteia para a skill especializada adequada — não resolve problemas directamente."

**Achados de qualidade (Q):**

- **Q1-Q4, Q6, Q7:** ✅.
- **Q5 (idioma):** ⚠ — linha 124-129 seção "Notas GestorERP" cita GestorERP como contexto.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2 (cross-compile explícito):** ⚠ — skill declara "Delphi/FPC" explicitamente (linhas 3, 20). Candidato a `to-fpc-*`.
- **N3:** ❌ — `orchestrator` sozinho é genérico (mesmo problema de L01, L02, L06). **Proposta:** `developer-delphi-horse-master-orchestrator` alinhando com proposta anterior `assembly-master-orchestrator` e `fmx-master-orchestrator`.
- **N4:** ✅.
- **N5:** ✅.

**Placement:** `.cursor/` correto.

**Correção proposta:**

```diff
@@ linha 7 (category incorreta)
-category: project
+category: developer-delphi
```

```diff
@@ linhas 124-129 (generalizar Notas GestorERP)
-## Notas GestorERP
-
-- Infraestrutura externa (synapse, TProcess) tratada em sessão separada
-- Verificar compatibilidade Delphi + FPC em todos os middlewares antes de adoptar
-- Para ambientes com proxy/Cloudflare: combinar `horse-cors` + `horse-clientip` + `horse-jwt`
-- JWT: `horse-jwt` (middleware de validação) usa `horse-security` (TJOSE, geração de token)
+## Notas de uso em produção
+
+- Verificar compatibilidade Delphi + FPC em todos os middlewares antes de adoptar
+- Para ambientes com proxy/Cloudflare: combinar `horse-cors` + `horse-clientip` + `horse-jwt`
+- JWT: `horse-jwt` (middleware de validação) usa `horse-security` (TJOSE, geração de token)
+- Notas específicas de cada projeto: ver `.workspace/skills/<projeto>-horse-deployment_V*/`.
```

**Nome proposto:** `developer-delphi-horse-master-orchestrator` (N3).

**Dependências cruzadas:** 17 skills irmãs referenciam como "orquestrador" implícito via "Skill orquestradora" em varias seções.

---

### Arquivo 2/18: `developer-delphi-horse-core_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-horse-core_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 283 linhas
**Model:** opus
**Category:** project
**Thinking:** extended

**Frontmatter integral:**

```yaml
---
name: developer-delphi-horse-core
description: Framework HTTP Horse para Delphi/Lazarus (FPC). Cobre THorse (routing, Use, Listen, Group), THorseRequest (Params, Query, Body, Headers, Cookie, Session, ContentFields) e THorseResponse (Send, Status, AddHeader, ContentType, SendFile, Download, RedirectTo). Fonte canônica: app/package/docs/pacotes/horse.md.
model: opus
thinking: extended
category: project
---
```

**Responsabilidade declarada** (linha 20):

> "Referência completa do framework **Horse** — servidor HTTP minimalista para Delphi e Lazarus (FPC), inspirado no Express.js. Cobre routing, middleware chain, request e response."

**Achados de qualidade (Q):**

- **Q1-Q7:** ✅. Exemplos demonstram uso real de Horse (routing, middleware, parâmetros, download).
- **Q5 (idioma):** ⚠ — linhas 272-276 "Notas GestorERP" com "Porta padrão: 9000 (dev) / 443 (prod via proxy reverso)" + "Middlewares globais registados no DPR" — conteúdo específico do GestorERP.

**Achados de nomenclatura (N):**

- **N1:** ✅.
- **N2 (cross-compile explícito):** ⚠ — skill **explicitamente Delphi+Lazarus FPC** (linhas 3, 20). Rename `to-fpc-*` alta confiança.
- **N3:** ✅ — `horse-core` é claro.
- **N4:** ✅.
- **N5:** ✅ — skill é **consumer-facing** (ensina a usar Horse, não a desenvolver Horse).

**Placement:** `.cursor/` correto.

**Correção proposta:**

```diff
@@ linha 7 (category)
-category: project
+category: developer-delphi
```

```diff
@@ linha 42 (Documento canônico — path relativo que pode não existir neste clone)
-`app/package/docs/pacotes/horse.md`
+`app/package/docs/pacotes/horse.md` (path relativo ao projeto onde esta skill é aplicada)
```

```diff
@@ linhas 272-276 (generalizar Notas GestorERP)
-## Notas GestorERP
-
-- Porta padrão: 9000 (dev) / 443 (prod via proxy reverso)
-- Middlewares globais registados no DPR: `Compression` → `CORS` → `Jhonson` → `HandleException` → `JWT`
-- FPC/Lazarus: usar `{$MODE DELPHI}{$H+}` e callbacks como procedimentos nomeados (não anônimos)
+## Notas de uso
+
+- Portas típicas: dev `9000`, prod `443` (via proxy reverso HTTPS)
+- Ordem recomendada de middlewares globais no DPR: `Compression` → `CORS` → `Jhonson` → `HandleException` → `JWT`
+- FPC/Lazarus: usar `{$MODE DELPHI}{$H+}` e callbacks como procedimentos nomeados (não anônimos)
+- Instâncias específicas por projeto: ver `.workspace/skills/<projeto>-horse-config_V*/`.
```

**Nome proposto:** `developer-delphi-to-fpc-horse-core` (N2 — cross-compile Delphi/Lazarus explícito).

**Dependências cruzadas afetadas por rename:**

- 17 outras skills horse-* que referenciam `developer-delphi-horse-core` em When NOT to use.
- `developer-delphi-horse-orchestrator_V1.0.0/SKILL.md:51` (matriz).

---

### Arquivo 3/18: `developer-delphi-horse-client_V1.0.0/SKILL.md`

**Path:** `e:\CSL\ProvidersORM\.cursor\skills\developer-delphi-horse-client_V1.0.0\SKILL.md`
**FileVersion:** 1.0.0
**Tamanho:** 343 linhas
**Model:** sonnet
**Category:** project
**Thinking:** minimal

**Responsabilidade declarada** (linha 20):

> "Cliente HTTP REST em Delphi — `RESTRequest4Delphi` com API fluente, adaptadores para CSV e DataSet."

**Achados de qualidade (Q):** Q1-Q7 ✅. Q5 ⚠ — linhas 327-337 "Notas GestorERP" + "GestorERP: motor em produção: RR4D_SYNAPSE".

**Achados de nomenclatura (N):**

- **N1:** ⚠ — skill está na família `horse-*` mas o objeto é `RESTRequest4Delphi` (cliente HTTP), não Horse (servidor). **Incongruência:** RESTRequest4Delphi é biblioteca independente que roda tanto em servidor quanto em qualquer app Delphi. Prefixo `horse-*` sugere vinculação a Horse.
- **N2:** ⚠ — RESTRequest4D funciona Delphi+FPC. Candidato a rename.
- **N3:** ✅ — `client` claro no contexto.
- **N4:** ⚠ — `horse-client` confunde com "cliente do Horse" (sugeria componente do Horse). Proposta: **separar da família horse-*** → `developer-delphi-to-fpc-restrequest4delphi-client` ou `developer-delphi-to-fpc-rest-client`.
- **N5:** ✅.

**Correção proposta:**

```diff
@@ linha 2 (rename)
-name: developer-delphi-horse-client
+name: developer-delphi-to-fpc-restrequest4delphi-client

@@ linha 7 (category)
-category: project
+category: developer-delphi
```

Generalizar Notas GestorERP similar aos anteriores.

**Nome proposto:** `developer-delphi-to-fpc-restrequest4delphi-client` (N1+N2+N4 — remove da família horse, sinaliza cross-compile, nome da lib explícito).

---

### Arquivo 4/18: `developer-delphi-horse-serialization_V1.0.0/SKILL.md`

**Tamanho:** 259 linhas | **Model:** sonnet | **Category:** project

**Responsabilidade:** serialização JSON↔DataSet via `dataset-serialize` (biblioteca independente, não Horse-specific).

**Achados Q:** Q1-Q7 ✅. Q5 ⚠ — Notas GestorERP.

**Achados N:** Mesmo problema do arquivo 3 — lib `dataset-serialize` é independente, não `horse-*`. Prefixo `horse-*` é enganoso.

**Correção:** rename `developer-delphi-to-fpc-dataset-serialize`. Category → `developer-delphi`.

---

### Arquivo 5/18: `developer-delphi-horse-security_V1.0.0/SKILL.md` — **SPLIT proposto**

**Tamanho:** 298 linhas | **Model:** opus | **Category:** project

**Responsabilidade declarada** (linha 20):

> "Referência completa de segurança JWT/JOSE e documentação Swagger/OpenAPI para APIs Horse. Cobre a geração e validação de tokens JWT (biblioteca base `delphi-jose-jwt`) e a documentação automática de API (`gbSwagger`)."

**Achados Q:**
- **Q3 (boilerplate):** ⚠ — skill cobre **2 temas distintos**: (a) JWT/JOSE (delphi-jose-jwt) + (b) Swagger (gbSwagger). São bibliotecas independentes com documentação separada. Junção numa única skill dificulta discovery.
- Q1-Q2, Q4, Q6, Q7 ✅. Q5 ⚠ Notas GestorERP.

**Achados N:**
- **N3 (objeto concreto):** ❌ — `horse-security` é ambíguo; junta JWT + Swagger.
- **N4:** ⚠ — sobreposição com `horse-jwt` (middleware que valida token) e lacuna em documentação Swagger standalone.
- **N5:** ⚠ — audiência mista (segurança JWT vs documentação API).

**Placement:** `.cursor/` com **split recomendado**:

- Nova skill 1: `developer-delphi-to-fpc-delphi-jose-jwt` (geração/validação JWT+JOSE).
- Nova skill 2: `developer-delphi-to-fpc-gbswagger` (documentação OpenAPI para Horse).

**Nome proposto:** **split em 2 skills** (decisão arquitetural — alta prioridade N3+N4).

---

### Arquivos 6-18/18: horse-jwt, horse-cors, horse-handle-exception, horse-basic-auth, horse-compression, horse-etag, horse-paginate, horse-octet-stream, horse-clientip, horse-logger, horse-logger-console, horse-logger-logfile, horse-exception-logger

**Padrão comum:**

- **FileVersion:** 1.0.0 em todos.
- **Model:** sonnet em todos.
- **Category:** project (incorreto; deveria ser `developer-delphi`).
- **Thinking:** minimal.
- **Q1-Q4, Q6, Q7:** ✅ em todos.
- **Q5:** ⚠ Notas GestorERP em todos.
- **N2:** ⚠ — todos cross-compile Delphi+FPC (exemplos Lazarus/FPC explícitos em várias skills).
- **N3:** ✅ — nomes precisos (`horse-cors`, `horse-jwt`, `horse-compression`, etc.).
- **N4:** ✅ — sem sobreposição entre si.
- **N5:** ✅.

**Convenção de nome proposta (alinhada com upstream Horse):**

Horse oficial usa nomenclatura `Horse.Middleware.Xxx` ou `Horse.Xxx`. Para refletir a natureza de middleware no nome da skill, propor padrão:

- `developer-delphi-to-fpc-horse-middleware-{jwt,cors,handle-exception,basic-auth,compression,etag,paginate,octet-stream}` (8 middlewares).
- `developer-delphi-to-fpc-horse-util-clientip` (utilitário, não middleware).
- `developer-delphi-to-fpc-horse-logger` (infraestrutura de logging).
- `developer-delphi-to-fpc-horse-logger-provider-{console,logfile}` (providers).
- `developer-delphi-to-fpc-horse-exception-logger` (middleware especializado; mantém nome explícito).

**Justificativa N3:** adicionar `middleware` / `util` / `provider` no nome torna claro o tipo do componente Horse — um dev novo identifica o escopo pelo nome.

**Correções em massa para as 13 skills desta seção:**

```diff
@@ em todos os SKILL.md (category incorreta)
-category: project
+category: developer-delphi
```

```diff
@@ Notas GestorERP — generalizar em todos
(aplicar padrão: "Notas de uso em produção" + sugestão de .workspace/ específico por projeto)
```

---

## Ações acumuladas para execução

### E1-candidatas

Nenhuma neste lote.

### E4-candidatas (Q1/Q7 para fix imediato)

**Família Horse está limpa de Q1/Q7.** Zero skills com `{$IFDEF FPC}` anti-padrão.

### E5-candidatas (renames propostos)

**Prioridade alta:**

1. `developer-delphi-horse-core` → `developer-delphi-to-fpc-horse-core` (N2 explícito).
2. `developer-delphi-horse-client` → `developer-delphi-to-fpc-restrequest4delphi-client` (N1+N2+N4 — separar da família horse; RESTRequest4D é independente).
3. `developer-delphi-horse-serialization` → `developer-delphi-to-fpc-dataset-serialize` (N1+N2+N4 — separar da família horse).
4. `developer-delphi-horse-security` → **split em 2 skills** (N3+N4):
   - `developer-delphi-to-fpc-delphi-jose-jwt` (JWT/JOSE).
   - `developer-delphi-to-fpc-gbswagger` (Swagger/OpenAPI).

**Prioridade média (aplicar N2+N3 em massa):**

5. `developer-delphi-horse-orchestrator` → `developer-delphi-horse-master-orchestrator` (N3 — alinha com fmx-master-orchestrator, assembly-master-orchestrator).
6. `developer-delphi-horse-jwt` → `developer-delphi-to-fpc-horse-middleware-jwt`.
7. `developer-delphi-horse-cors` → `developer-delphi-to-fpc-horse-middleware-cors`.
8. `developer-delphi-horse-handle-exception` → `developer-delphi-to-fpc-horse-middleware-handle-exception`.
9. `developer-delphi-horse-basic-auth` → `developer-delphi-to-fpc-horse-middleware-basic-auth`.
10. `developer-delphi-horse-compression` → `developer-delphi-to-fpc-horse-middleware-compression`.
11. `developer-delphi-horse-etag` → `developer-delphi-to-fpc-horse-middleware-etag`.
12. `developer-delphi-horse-paginate` → `developer-delphi-to-fpc-horse-middleware-paginate`.
13. `developer-delphi-horse-octet-stream` → `developer-delphi-to-fpc-horse-middleware-octet-stream`.
14. `developer-delphi-horse-clientip` → `developer-delphi-to-fpc-horse-util-clientip`.
15. `developer-delphi-horse-logger` → `developer-delphi-to-fpc-horse-logger`.
16. `developer-delphi-horse-logger-console` → `developer-delphi-to-fpc-horse-logger-provider-console`.
17. `developer-delphi-horse-logger-logfile` → `developer-delphi-to-fpc-horse-logger-provider-logfile`.
18. `developer-delphi-horse-exception-logger` → `developer-delphi-to-fpc-horse-exception-logger`.

### E6-candidatas (Q2/Q3/Q4/Q5/Q6 residuais)

1. **Category incorreta em 18 skills** — `category: project` → `category: developer-delphi` em todas.
2. **Q5 em 18 skills** — "Notas GestorERP" → generalizar (substituir por "Notas de uso em produção" + ponteiro para `.workspace/skills/<projeto>-*`).
3. **Paths relativos em horse-core:42 e outras skills** — referências `app/package/docs/pacotes/*.md` existem no clone? Verificar em sessão dedicada; se não existirem neste clone (apenas no GestorERP), documentar que são paths relativos ao projeto consumidor.

### Placement migrations

Conteúdo "Notas GestorERP" das 18 skills → **deve migrar** para `.workspace/skills/gestorerp-horse-deployment_V1.0.0/SKILL.md` do clone GestorERP. Aqui, apenas generalizar.

---

## Síntese do lote L07

- **18 skills auditadas** com detalhe completo.
- **Zero Q1/Q7** — família Horse limpa de anti-padrões `{$IFDEF FPC}`.
- **Zero Q2** — sem refs quebradas.
- **18 com Q5 leve** — "Notas GestorERP" em todas; generalizar.
- **18 com category incorreta** — `project` → `developer-delphi`.
- **15+ renames propostos** — aplicar N2 (`to-fpc-*`) em 17 skills + 1 split (horse-security).
- **2 skills fora da família "real" Horse** — horse-client (RESTRequest4D) e horse-serialization (dataset-serialize) são bibliotecas **independentes** do Horse; rename remove da família horse.
- **1 skill com split recomendado** — horse-security cobre 2 bibliotecas distintas (JWT+Swagger).
- **1 master orchestrator** — horse-orchestrator → horse-master-orchestrator (N3).

**Próxima onda sugerida:** L08 (language + rtl) — 9 skills `developer-delphi-language-*` + `developer-delphi-rtl-*`.

**Commit sugerido:** `docs(audit): relatório lote L07 horse — 18 skills limpas de Q1/Q7, 15 renames to-fpc, 1 split (security), 18 category fix`
