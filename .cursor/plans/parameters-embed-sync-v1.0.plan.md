---
name: parameters-embed-sync
description: Plano de sincronização do módulo Parameters embutido em ProvidersORM a partir do projeto-base ParametersORM, respeitando as customizações locais (IConnection, namespace Commons.Parameters.*, Exceptions.Parameters).
scope: src/Modulos/Parameters + src/Commons/Commons.Parameters.* + src/Main/Parameters.* + src/Modulos/Exceptions/Exceptions.Parameters.pas + src/Modulos/Exceptions/Exceptions.Parameters.Attributes.pas
sources:
  - E:/CSL/ParamentersORM/src/ (SSOT upstream)
destinations:
  - E:/CSL/ProvidersORM/src/ (embed customizado)
version: 1.1
date: 2026-04-23
status: REVISADO — decisões de aprovação aplicadas (Fases G/H/B.5)
---

## Revisão v1.1 — decisões incorporadas

1. **Fase H (Parameters.Database.pas)** — mudou de "NÃO APLICAR" para **APLICAR COM ADAPTAÇÃO**.
   Como a connection no embed **é** a `IConnection` do ProvidersORM (mesma lógica semântica), os deltas do upstream 1.0.7 (DLL SSOT via `Parameters.DynamicLibrary`) serão portados com adaptação: o que no upstream é "extrair DLL do engine inline" torna-se no embed "centralizar DLL resolution antes/ao lado da delegação a `IConnection`".
2. **Fase G (Parameters.DynamicLibrary.pas)** — mudou de "REJEITAR" para **IMPORTAR COM RENAME** (`Commons.Parameters.DynamicLibrary.pas` em `src/Commons/`). Consequência direta da Fase H: a unit passa a ser dependência de `Parameters.Database.pas` adaptado.
3. **Fase B.5 (Parameters.Attributes.Exceptions.pas)** — destino confirmado: `src/Modulos/Exceptions/Exceptions.Parameters.Attributes.pas` (alinhado com a convenção do módulo Exceptions centralizado do ProvidersORM).

### Política transversal — Versionamento e Changelog (ProvidersORM = Master)

Regra obrigatória para **todos** os arquivos tocados neste plano (importados, adaptados ou meramente copiados do upstream):

- **`Project:`** → `ProvidersORM` (nunca `ParamentersORM`).
- **`ProjectVersion:`** → versão corrente do ProvidersORM (ler de `ORM.Version.inc` / `Commons.Version`). Nunca carregar o `1.0.7` do upstream.
- **`FileVersion:`** → versão local do embed. Ao importar um arquivo novo (Attributes, DynamicLibrary), **iniciar em `1.0.0`** e registrar o delta no Changelog local. Ao continuar um arquivo já existente no embed, **incrementar** o FileVersion local.
- **`Date:`** → data do commit no ProvidersORM.
- **`Author:`** → preservar o autor original se houver co-autoria; caso contrário `Claiton de Souza Linhares`.
- **Changelog (file):** `ProvidersORM é Master` — o changelog local é o histórico do embed. Ao importar um arquivo inédito do upstream, a entrada inicial é:
  ```
  - 1.0.0 (2026-04-23): Import adaptado do upstream ParametersORM v<X>;
    rename de unit/uses para namespace ProvidersORM;
    delegação a IConnection preservada (quando aplicável).
  ```
  As entradas pré-existentes do upstream **não** são copiadas — o histórico do upstream vive em `E:/CSL/ParamentersORM/` e é referenciado por link/comentário se necessário.
- **`ORM.Version.inc` e `ORM.Defines.inc`:** usar exclusivamente os do ProvidersORM (raiz).

# Plano: Sincronização do `src/Modulos/Parameters` com o upstream ParametersORM

## 1. Contexto e premissas

### 1.1 Duas árvores, dois refactors paralelos
ProvidersORM embute uma cópia adaptada de `ParametersORM` e aplicou em 03/04/2026 um **refactor profundo** (v1.0.7 local): `TParametersDatabase` passou a delegar TODO acesso SQL à `IConnection` do módulo Connections — removeu ~3.500 linhas engine-specific (UniDAC/FireDAC/Zeos/SQLdb), campos (FEngine/FHost/FPort/…) e métodos privados (CreateInternalConnection, ConnectConnection, ConfigureFireDACDLLPaths, ConfigureZeosLibraryLocation…).

Paralelamente, em 22–23/04/2026, `ParametersORM` aplicou o seu próprio refactor (v1.0.7 upstream): migrou **apenas a resolução de DLLs** para uma nova unit `Parameters.DynamicLibrary` (SSOT de DLL). Manteve todo o código engine-specific inline.

**Implicação:** Os dois "1.0.7" são versões **divergentes e incompatíveis no caminho Database.pas**. A unit upstream `Parameters.DynamicLibrary` extrai código que, no embed, **já não existe**. Um copy-over cego quebra o embed.

### 1.2 Customizações ProvidersORM que DEVEM ser preservadas

| Customização | Motivo |
|---|---|
| `TParametersDatabase` usa `IConnection` como única conexão | Ecossistema unificado — Connections é o dono de DLL/driver/engine |
| Namespace `Commons.Parameters.*` (em vez de `Parameters.*` raiz) | Convenção ProvidersORM — tudo-partilhado em `src/Commons/` com prefixo `Commons.` |
| `Exceptions.Parameters.pas` em `src/Modulos/Exceptions/` | ProvidersORM tem módulo `Exceptions` centralizado — exceções do Parameters pertencem lá, não em Commons |
| Facades em `src/Main/Parameters.pas` e `src/Main/Parameters.Interfaces.pas` (FileVersion 1.0.4) | ProvidersORM adicionou `SetExceptions`/`SetLogger` (ecossistema unificado) — ausente no upstream |
| `FConfiguration`/DLL resolution delegada à `IConnection` | Connections já configura `ConfigureFireDACVendorLib` e `ConfigureZeosLibraryLocation` para o engine ativo — Parameters não duplica |

### 1.3 Inventário da diferença (22→23/04 wave no upstream)

| # | Arquivo upstream | Estado no upstream | Estado no embed | Tratamento |
|---|---|---|---|---|
| 1 | `src/Attributes/Parameters.Attributes.pas` (1341 L, v1.0.0, 22/04) | NOVO | **pasta vazia** `src/Modulos/Parameters/Attributes/` | Copiar com ajustes |
| 2 | `src/Attributes/Parameters.Attributes.Interfaces.pas` (284 L) | NOVO | ausente | Copiar |
| 3 | `src/Attributes/Parameters.Attributes.Types.pas` (462 L) | NOVO | ausente | Copiar |
| 4 | `src/Attributes/Parameters.Attributes.Consts.pas` (86 L) | NOVO | ausente | Copiar |
| 5 | `src/Attributes/Parameters.Attributes.Exceptions.pas` (161 L) | NOVO | ausente | Ajustar + migrar para `Modulos/Exceptions/` |
| 6 | `src/Commons/Parameters.Consts.pas` (v1.0.5, 23/04) | ALTERADO (+Breaking: `paramenters`→`parameters`; arrays DatabaseTypeDll*) | `src/Commons/Commons.Parameters.Consts.pas` v1.0.0 (06/04) | **Merge seletivo** com rename |
| 7 | `src/Commons/Parameters.Types.pas` (22/04) | ALTERADO | `src/Commons/Commons.Parameters.Types.pas` (06/04) | **Merge seletivo** com rename |
| 8 | `src/Commons/Parameters.Exceptions.pas` (607 L, v1.0.1, 22/04) | ALTERADO | `src/Modulos/Exceptions/Exceptions.Parameters.pas` | **Merge seletivo** com rename e módulo diferente |
| 9 | `src/Commons/Parameters.IOUtils.pas` (185 L, 22/04) | ALTERADO | absorvido em `src/Commons/Commons.IOUtils.pas` | Comparar; normalmente N/A |
| 10 | `src/Commons/Parameters.Messages.pas` (55 L, 22/04) | ALTERADO | absorvido em `src/Commons/Commons.Messages.pas` | Comparar; normalmente N/A |
| 11 | `src/Commons/Parameters.Version.pas` (209 L, 22/04) | ALTERADO | absorvido em `src/Commons/Commons.Version.pas` | N/A — ProvidersORM tem versão própria |
| 12 | `src/Commons/Parameters.DynamicLibrary.pas` (671 L, v1.0.1, 23/04) | **NOVO upstream** | NÃO EXISTE | **IMPORTAR com rename** → `src/Commons/Commons.Parameters.DynamicLibrary.pas` (dependência da Fase H adaptada) |
| 13 | `src/Commons/Parameters.FPC.inc` | (inalterado) | `src/Commons/Commons.FPC.inc` | N/A |
| 14 | `src/Database/Parameters.Database.pas` (7379 L, v1.0.7, 23/04) | ALTERADO | `src/Modulos/Parameters/Database/Parameters.Database.pas` (3359 L, v1.0.7 IConnection, 07/04) | **APLICAR COM ADAPTAÇÃO** — portar deltas upstream preservando delegação a `IConnection` |
| 15 | `src/Database/Parameters.Database.IniFile.pas` (79 L, 22/04) | ALTERADO | mesmo caminho (79 L) | **Diff + cherry-pick** |
| 16 | `src/Database/Parameters.Database.JSonObject.pas` (220 L, 22/04) | ALTERADO | mesmo caminho (220 L) | **Diff + cherry-pick** |
| 17 | `src/IniFiles/Parameters.Inifiles.pas` (2061 L, 22/04) | ALTERADO | `src/Modulos/Parameters/IniFiles/Parameters.Inifiles.pas` (2072 L, 07/04) | **Diff + cherry-pick** |
| 18 | `src/JsonObject/Parameters.JsonObject.pas` (3062 L, 22/04) | ALTERADO | `src/Modulos/Parameters/JsonObject/Parameters.JsonObject.pas` (3067 L, 07/04) | **Diff + cherry-pick** |
| 19 | `src/View/ufrmParameters.*` (dfm/lfm/pas) | INALTERADO (nov wave) | `src/Views/ufrmParameters.*` (+fmx) | Sem ação |
| 20 | `src/View/ufrmParametersAttributers.*` | INALTERADO | `src/Views/ufrmParametersAttributers.*` (+fmx) | Sem ação (revisitar após Attributes entrar) |

---

## 2. Plano arquivo-a-arquivo

### FASE A — Preparação

**A.1** — Remover arquivos `.bak` obsoletos:
- `src/Modulos/Parameters/Database/Parameters.Database.pas.bak` (251 KB, pré-refactor de 17/02, não relevante)
- `src/Modulos/Parameters/Database/Parameters.Database.pas.claude.bak` (288 KB, snapshot 03/04)

**A.2** — Criar snapshot de segurança do embed atual:
- Copiar `src/Modulos/Parameters/` inteiro para `.cursor/Backup/parameters-pre-sync-<timestamp>/`
- Copiar `src/Main/Parameters.pas`, `src/Main/Parameters.Interfaces.pas`, `src/Commons/Commons.Parameters.*.pas`, `src/Modulos/Exceptions/Exceptions.Parameters.pas` para o mesmo backup

**A.3** — Skill de compatibilidade obrigatória:
- Invocar `governance-refactoring-compatibility-policy` ANTES de renomear ou remover qualquer API pública (compromisso com CLAUDE.md do projeto)

---

### FASE B — NOVO: Módulo Attributes (subpasta vazia → 5 units)

Objetivo: importar o subsistema de atributos RTTI → TParameter/TParameterList.

#### B.1 — `src/Modulos/Parameters/Attributes/Parameters.Attributes.Consts.pas`
- **Fonte:** `E:/CSL/ParamentersORM/src/Attributes/Parameters.Attributes.Consts.pas` (86 L)
- **Ação:** copiar íntegro
- **Ajuste:** `Project: ParamentersORM` → `Project: ProvidersORM (embed Parameters)`; adicionar entrada no Changelog local 1.0.0 (embed em `src/Modulos/Parameters/Attributes/`).
- **Uses:** se importa `Parameters.Consts` → substituir por `Commons.Parameters.Consts`.

#### B.2 — `src/Modulos/Parameters/Attributes/Parameters.Attributes.Interfaces.pas`
- **Fonte:** upstream (284 L) → copiar
- **Uses a renomear:**
  - `Parameters.Types` → `Commons.Parameters.Types`
  - `Parameters.Consts` → `Commons.Parameters.Consts`
  - `Parameters.Interfaces` → (mantém nome) OK
- Atualizar cabeçalho Project/ProjectVersion/Changelog.

#### B.3 — `src/Modulos/Parameters/Attributes/Parameters.Attributes.Types.pas`
- **Fonte:** upstream (462 L) → copiar
- **Uses a renomear** (se aplicável): idem B.2.
- Cabeçalho local.

#### B.4 — `src/Modulos/Parameters/Attributes/Parameters.Attributes.pas`
- **Fonte:** upstream (1341 L) → copiar
- **Uses a renomear:**
  - `Parameters.Consts` → `Commons.Parameters.Consts`
  - `Parameters.Types` → `Commons.Parameters.Types`
  - `Parameters.Exceptions` → `Exceptions.Parameters`
  - `Parameters.Attributes.*` → prefixo preservado (ficam no mesmo sub-pacote)
  - Se usar `Parameters.Version` → **remover** (ProvidersORM usa `Commons.Version`)
  - Se usar `Parameters.IOUtils` → `Commons.IOUtils`
  - Se usar `Parameters.Messages` → `Commons.Messages`
- Cabeçalho local; Changelog 1.0.0 "embed em ProvidersORM".

#### B.5 — `Parameters.Attributes.Exceptions.pas` → **DESLOCAMENTO para módulo Exceptions (CONFIRMADO)**
- **Fonte:** upstream `src/Attributes/Parameters.Attributes.Exceptions.pas` (161 L)
- **Destino aprovado:** `src/Modulos/Exceptions/Exceptions.Parameters.Attributes.pas` (alinhado com padrão `Exceptions.<sub>`)
- **Ajustes:**
  - `unit Parameters.Attributes.Exceptions` → `unit Exceptions.Parameters.Attributes`
  - `uses` das Attributes (`Parameters.Attributes.Consts` etc.) → manter (mesmo sub-pacote)
  - Em `Parameters.Attributes.pas` consumidor: `uses Parameters.Attributes.Exceptions` → `uses Exceptions.Parameters.Attributes`
  - Base class: se herda de `EParametersException`, ajustar para o equivalente em `Exceptions.Parameters` (que vive em `Modulos/Exceptions/`)
- **Validação de códigos:** conferir faixa de error codes contra `Documentation/Exceptions/` e `Data/exception.db` antes do commit.

---

### FASE C — UPDATE: `Commons.Parameters.Consts.pas` (v1.0.0 → v1.0.5 equivalente)

#### C.1 — `src/Commons/Commons.Parameters.Consts.pas`
- **Fonte:** `E:/CSL/ParamentersORM/src/Commons/Parameters.Consts.pas` v1.0.5 (23/04)
- **Deltas upstream (1.0.0→1.0.5):**
  - 1.0.1: `PARAMETERS_CONNECTION_KEYS`, `DEFAULT_PARAMETERS_SECTION_NAME`, `DEFAULT_PARAMETERS_CONNECT_DATABASE_TYPE`
  - 1.0.2: `SQL_CREATE_TABLE_ACCESS`, `SQL_CREATE_TABLE_ACCESS_ODBC`
  - 1.0.3: `TEngineDatabase` + `TDatabaseConfig` com `pteSQLdb`; `SQLDB_SUPPORTED_TYPES`; `DEFAULT_PARAMETERS_ENGINE` p/ USE_SQLDB
  - 1.0.4: `PARAMETERS_ORM_VERSION`; ProjectVersion 1.0.7
  - 1.0.5: `DEFAULT_DLL_*` (Firebird/MySQL/PostgreSQL/SQLite/SQLServer FreeTDS); arrays `DatabaseTypeDllPaths`/`Names` preenchidos em `initialization`; **BREAKING**: `DEFAULT_PARAMETERS_SECTION_NAME` `'paramenters'` → `'parameters'`
- **Ação:** aplicar deltas 1.0.1→1.0.4 integralmente.
- **1.0.5 — decisão crítica:**
  - `DEFAULT_DLL_*` e arrays → **REJEITAR**: ProvidersORM já tem `Commons.Consts` V1.0.2 com `DatabaseTypeDllPaths/Names` (a unit upstream explicitamente diz "alinhado a ProvidersORM Commons.Consts V1.0.2" — ou seja, upstream replicou; embed já tem a SSOT).
  - Typo `paramenters`→`parameters` → **APLICAR** com plano de migração (seção [DEPRECATION](#deprecation)); rebaptizar `DEFAULT_PARAMETERS_SECTION_NAME` e deixar alias temporário apontando para a nova string.
- **Rename:** unit `Parameters.Consts` → `Commons.Parameters.Consts`.
- **Cabeçalho:** atualizar Changelog local adicionando entrada 1.0.1 com as mudanças aplicadas.

---

### FASE D — UPDATE: `Commons.Parameters.Types.pas`

#### D.1 — `src/Commons/Commons.Parameters.Types.pas`
- **Fonte:** upstream `Parameters.Types.pas` (22/04)
- **Deltas:** diff para identificar tipos novos (`TEngineDatabase`, `TDatabaseConfig`, `pteSQLdb` se não absorvidos em Consts, eventuais records/enumerations novos).
- **Decisão por tipo:**
  - Novos tipos puros → **importar** com rename de unit
  - Tipos que duplicam algo já em `Commons.Types` → **REJEITAR**
- **Rename:** `Parameters.Types` → `Commons.Parameters.Types` (já existe — só atualizar).

---

### FASE E — UPDATE: `Exceptions.Parameters.pas`

#### E.1 — `src/Modulos/Exceptions/Exceptions.Parameters.pas`
- **Fonte:** upstream `src/Commons/Parameters.Exceptions.pas` v1.0.1 (607 L, 14/02)
- **Delta upstream 1.0.0→1.0.1:** novas classes/códigos — executar diff contra a cópia local para identificar.
- **Ação:** cherry-pick das exceções novas mantendo a estrutura de módulo ProvidersORM.
- **Rename:** unit name `Parameters.Exceptions` → `Exceptions.Parameters` (já é o nome local); ajustar `uses` consumidores no embed.

---

### FASE F — DECISÃO: `Parameters.IOUtils` / `Parameters.Messages` / `Parameters.Version`

#### F.1 — Avaliar absorção
- **`Parameters.IOUtils.pas` (185 L)**: diff contra `Commons.IOUtils.pas`.
  - Se funções do upstream **já existem** em `Commons.IOUtils`: **nenhuma ação**
  - Se há funções novas: importar **apenas as funções novas** para `Commons.IOUtils` ou criar `Commons.Parameters.IOUtils` se forem específicas de Parameters.
- **`Parameters.Messages.pas` (55 L)**: idem vs `Commons.Messages`.
- **`Parameters.Version.pas` (209 L)**: **IGNORAR** — ProvidersORM tem versionamento próprio (`Commons.Version` + `ORM.Version.inc`).

---

### FASE G — IMPORTAR COM RENAME: `Parameters.DynamicLibrary.pas` → `Commons.Parameters.DynamicLibrary.pas`

#### G.1 — Escopo
- Upstream v1.0.1 (23/04, 671 L): SSOT de DLL cliente por (engine, BD), provendo:
  1. Record helper `TParameterDatabaseTypesDLLHelper` (BaseDirectory/Directory/Path)
  2. Dispatchers `ResolveDllBasePath`, `GetVendorLibPath`, `GetVendorLibPathMySQLAlt`, `GetVendorLibDirectory`
  3. Leitor do parâmetro `database_dll` de `.ini` / `.json` / `.db` SQLite
  4. Configuradores `ConfigureZeosLibraryLocation` (USE_ZEOS) e `ConfigureFireDACVendorLib` (USE_FIREDAC) com AppendPathEnv
  5. Helper `AppendPathEnv` cross-compiler

#### G.2 — Destino
- **`src/Commons/Commons.Parameters.DynamicLibrary.pas`** (namespace ProvidersORM).

#### G.3 — Ajustes obrigatórios
- **Unit name:** `Parameters.DynamicLibrary` → `Commons.Parameters.DynamicLibrary`.
- **Uses a renomear (dentro da própria unit):**
  - `Parameters.Consts` → `Commons.Parameters.Consts`
  - `Parameters.Types` → `Commons.Parameters.Types`
  - `Parameters.Exceptions` → `Exceptions.Parameters`
  - `Parameters.IOUtils`/`Messages` → `Commons.IOUtils`/`Commons.Messages` (se função equivalente existir; caso contrário importar específica na Fase F)
- **Dedup vs Commons existentes:**
  - `Commons.Consts.DatabaseTypeDllPaths/Names` (V1.0.2) já fornece a tabela base — a unit importada deve **consumir** (ou referenciar) essa tabela em vez de re-declarar arrays próprios.
  - `Commons.Types.BaseDirectory/Directory/Path` (V1.0.5) já existe — se o helper upstream duplicar, **consolidar no record helper já existente**.
- **Integração com Connections:** verificar se `src/Modulos/Connections/` já oferece `ConfigureFireDACVendorLib`/`ConfigureZeosLibraryLocation`. Caso afirmativo:
  - Opção 1 (preferida): **delegar** a configuração ao Connections; a unit importada atua como **leitor** de `database_dll` do .ini/.json/.db e **dispatcher** — os configuradores viram wrappers finos sobre Connections.
  - Opção 2: manter configuradores próprios em `Commons.Parameters.DynamicLibrary` e Connections continua usando os seus — **apenas se dedup for impraticável**.

#### G.4 — Cabeçalho (ProvidersORM Master)
- `Project: ProvidersORM` · `ProjectVersion: <ORM.Version.inc>` · `FileVersion: 1.0.0` · `Date: 2026-04-23`.
- Changelog inicial conforme política (entrada única 1.0.0 "Import adaptado do upstream ParametersORM v1.0.1").

---

### FASE H — APLICAR COM ADAPTAÇÃO: `Parameters.Database.pas` (core)

#### H.1 — Premissa
A `IConnection` do embed **é** a Connection do ProvidersORM. A lógica semântica do upstream 1.0.7 (DLL SSOT) é transponível para o embed desde que ajustada para não duplicar o que `IConnection` já faz e que o code path engine-specific inline (que não existe no embed) seja substituído pelos métodos `IConnection.ExecuteQuery`/`ExecuteCommand`.

#### H.2 — Metodologia (3 passos)
1. **Identificar deltas upstream 1.0.6→1.0.7** fora de engine code (apenas os chamadores/hooks):
   - Migração de `GetDatabaseDllBasePath` → `Commons.Parameters.DynamicLibrary.ResolveDllBasePath`
   - Substituição de `ReadDatabaseDllFromConfigFile` → chamador da nova unit
   - Remoção dos `~180 linhas de VendorLib FireDAC duplicadas` em `CreateInternalConnection`/`ConnectConnection` — no embed **já removido** (passo null, beneficia de coerência)
   - Suporte a DLL de Firebird (novidade do upstream) → adicionar dispatch correspondente (se `IConnection` ainda não cobrir Firebird)
2. **Portar, preservando `IConnection`:**
   - Toda chamada a SQL do upstream (`FQuery.Open`/`FQuery.ExecSQL`) permanece como `FConnection.ExecuteQuery`/`ExecuteCommand` no embed.
   - Campos `FDllBasePath`/`FConfigFilePath`/`FDatabase`/`FTableName`/`FTituloFilter`/`FContratoID`/`FProdutoID` **permanecem** para poder passar para `ConfigureZeosLibraryLocation`/`ConfigureFireDACVendorLib` da nova unit (se essa configuração ainda couber a Parameters).
   - Ponto de decisão: se Connections **já lê** `database_dll` a partir do config do Parameters, esses campos tornam-se redundantes — **remover**.
3. **Cherry-pick de fixes fora do refactor de DLL:**
   - Diff fino entre `Parameters.Database.pas` upstream v1.0.7 e o último snapshot pré-refactor do embed (`Parameters.Database.pas.claude.bak` de 03/04 = 288 KB).
   - Selecionar bug fixes e pequenas melhorias (Access/SQLite/Firebird) que sejam **ortogonais** à delegação `IConnection`.

#### H.3 — Estrutura final esperada (embed v1.0.8)
```
unit Parameters.Database;
  // FConnection: IConnection (mantido)
  // Remoção final de campos engine-only se redundantes
  // DLL resolution delegada a Commons.Parameters.DynamicLibrary
  // SQL via FConnection.ExecuteQuery / ExecuteCommand
```
- Tamanho esperado: entre 3.300 e ~3.800 linhas (próximo do atual, não volta para 7k+).

#### H.4 — Cabeçalho (ProvidersORM Master)
- `Project: ProvidersORM` · `FileVersion: 1.0.8` · `Date: 2026-04-23`.
- Entry Changelog 1.0.8 obrigatório:
  - "Port adaptado do upstream ParametersORM v1.0.7: DLL resolution migrada para `Commons.Parameters.DynamicLibrary`; delegação a `IConnection` preservada; suporte a DLL de Firebird adicionado (se aplicável); cherry-pick de fixes ortogonais."

---

### FASE I — DIFF + CHERRY-PICK: Units com mudanças pequenas

#### I.1 — `src/Modulos/Parameters/Database/Parameters.Database.IniFile.pas`
- **Fonte vs embed:** ambos 79 L — diff line-by-line.
- Se somente datas/comentários mudaram: **atualizar cabeçalho** local com Changelog consolidado.
- Se há fix: cherry-pick e adicionar entrada Changelog 1.0.X local.

#### I.2 — `src/Modulos/Parameters/Database/Parameters.Database.JSonObject.pas`
- **Fonte vs embed:** ambos 220 L — diff line-by-line.
- Idem I.1.

#### I.3 — `src/Modulos/Parameters/IniFiles/Parameters.Inifiles.pas`
- **Fonte:** 2061 L (22/04) | **embed:** 2072 L (07/04) → embed tem +11 linhas
- Provavelmente embed adicionou integração com `IParameters.SetExceptions/SetLogger` (ecossistema 03/04).
- Diff revelará se upstream tem fix específico; cherry-pick manual.

#### I.4 — `src/Modulos/Parameters/JsonObject/Parameters.JsonObject.pas`
- **Fonte:** 3062 L (22/04) | **embed:** 3067 L (07/04) → embed tem +5 linhas
- Idem I.3.

---

### FASE J — FACADES: `Main/Parameters.*`

#### J.1 — `src/Main/Parameters.pas` (v1.0.4 local, 12/03 vs upstream v1.0.3, 15/02)
- Embed **AHEAD** do upstream (upstream não tocou em 1793 L Feb).
- **Ação:** sem mudança.
- **Validação:** confirmar que a nova lista `uses` continua a compilar após renomear nas Fases B-E.

#### J.2 — `src/Main/Parameters.Interfaces.pas` (v1.0.4 local, 03/04 vs upstream v1.0.2, 10/02)
- Embed **AHEAD** com `getter Connection: IConnection`.
- **Ação:** sem mudança.

---

### FASE K — VIEWS: `ufrmParameters*`

#### K.1 — `src/Views/ufrmParameters.*` e `src/Views/ufrmParametersAttributers.*`
- **Upstream não mudou** (não estão no wave Apr 22-23).
- **Ação:** sem mudança.
- **Após** importar módulo Attributes (Fase B), **validar** que `ufrmParametersAttributers.pas` continua a compilar — provavelmente usa `Parameters.Attributes.*` que agora existem novamente.

---

### FASE L — DEPRECATION: `paramenters`→`parameters` (breaking do upstream 1.0.5)
<a id="deprecation"></a>

#### L.1 — Estratégia recomendada
1. Adicionar em `Commons.Parameters.Consts`:
   ```pascal
   const
     DEFAULT_PARAMETERS_SECTION_NAME           = 'parameters';        // novo
     DEFAULT_PARAMETERS_SECTION_NAME_LEGACY    = 'paramenters'        // typo antigo
       deprecated 'Use DEFAULT_PARAMETERS_SECTION_NAME';
   ```
2. Em `Parameters.Inifiles`/`Parameters.JsonObject`: ler `parameters` **e** `paramenters` como fallback com 1 warning em log (via `SetLogger`).
3. Remoção programada do fallback: v2.1.0 (próxima MAJOR).

#### L.2 — Skills obrigatórias
- `governance-refactoring-compatibility-policy` — registrar BREAKING.
- `version-breaking-change-guard` — avaliar impacto em consumidores.
- `version-deprecation-policy` — agendar remoção.

---

### FASE M — VALIDAÇÃO

#### M.1 — Compilação cross-compiler
```powershell
# Delphi Win32
dcc32 ProvidersORM.dpr
# Delphi Win64
dcc64 ProvidersORM.dpr
# FPC Win32
D:\fpc\fpc\bin\i386-win32\fpc.exe @fpc32.opts ProvidersORM.lpr
# FPC Win64
D:\fpc\fpc\bin\x86_64-win64\fpc.exe @fpc64.opts ProvidersORM.lpr
```
**Gate:** 4× build limpo.

#### M.2 — Formulários de teste
- `ufrmParameters` — runtime smoke (IniFile/JsonObject/Database)
- `ufrmParametersAttributers` — runtime smoke Attributes (CRÍTICO após Fase B)
- `ufrmEcossistemaTeste` — SetExceptions/SetLogger continuam a fluir

#### M.3 — Regressão
- Invocar `quality-regression-guard` para snapshot antes/depois.

---

## 3. Ordem de execução sugerida

1. **Fase A** — backup + limpeza dos `.bak`
2. **Fase G** — confirmar decisão de REJEITAR DynamicLibrary (não-ação, apenas registrar)
3. **Fase H** — confirmar decisão de NÃO aplicar o Database.pas upstream (não-ação)
4. **Fase C** — `Commons.Parameters.Consts.pas` (deltas + deprecation typo)
5. **Fase D** — `Commons.Parameters.Types.pas` (deltas)
6. **Fase E** — `Exceptions.Parameters.pas` (deltas)
7. **Fase B** — módulo Attributes completo (5 units)
8. **Fase I** — cherry-pick nas 4 units pequenas
9. **Fase F** — análise IOUtils/Messages/Version (só se diff revelar novidade real)
10. **Fase L** — deprecation do typo
11. **Fase J/K** — confirmação (sem mudança)
12. **Fase M** — validação completa cross-compiler + forms

---

## 4. Critérios de aceitação

- [ ] 4× builds verdes (dcc32/dcc64/fpc32/fpc64)
- [ ] `ufrmParametersAttributers` funciona após Fase B
- [ ] `IParameters.SetExceptions`/`SetLogger` (embed 1.0.4) continua a funcionar
- [ ] `TParametersDatabase.Connection(IConnection)` continua a ser ponto único de conexão
- [ ] `DEFAULT_PARAMETERS_SECTION_NAME = 'parameters'` ativo + alias deprecated para `'paramenters'`
- [ ] Changelog local consolidado em cada unit tocada (formato "X.Y.Z (data): delta curto")
- [ ] `Exception.db` atualizado se novos códigos foram introduzidos (Fase E)
- [ ] Documentação atualizada em `Documentation/Arquitetura/` (se houver seção Parameters)
- [ ] `.cursor/` snapshot do embed pré-sync preservado em `.cursor/Backup/`

---

## 5. Riscos e mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Attributes.pas (1341 L) depender de `Parameters.Version` | Média | Baixo | Substituir por `Commons.Version` — diff driven |
| Exception code ranges colidirem com outras exceções ProvidersORM | Média | Médio | `governance-artifact-inventory` antes de importar códigos novos |
| `ufrmParametersAttributers` usar API mudada | Alta | Baixo | Form é de teste — ajustar diretamente |
| Typo `paramenters` em configs de produção | Alta | Alto | Fallback de leitura (Fase L.1) + logger warn |
| Diff de IniFiles/JsonObject revelar mudança comportamental | Baixa | Alto | Cherry-pick manual apenas com teste dedicado |
| Perda de feature DLL-resolution (Firebird novo no upstream) | Baixa | Médio | Verificar se `Connections` já cobre Firebird DLL — se não, reconsiderar Fase G |

---

## 6. Itens **fora** do escopo deste plano

- Adoção de `Parameters.DynamicLibrary` como unit (Fase G rejeita)
- Re-sincronização do `Parameters.Database.pas` (Fase H rejeita)
- Migração para nova estrutura de pastas
- Renomear `ParamentersORM`→`ParametersORM` nos headers (typo histórico — tratar separadamente)
- Atualização das skills/docs do pack `.cursor/` (já foi feita em sync separada)

---

## 7. Próximos passos

1. Revisar este plano e aprovar/ajustar as decisões das Fases G, H e L
2. Confirmar destino preferido para `Parameters.Attributes.Exceptions` (B.5): `Modulos/Exceptions/` vs `Modulos/Parameters/Attributes/`
3. Autorizar execução sequencial das Fases A→M
4. Opcional: agendar re-avaliação da Fase G em 2 semanas (verificar se `Connections` cobre `database_dll` read-from-config)
