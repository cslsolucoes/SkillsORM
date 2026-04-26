---
name: loggers-parameters-master-absorption
description: Absorção plena de Loggers e Parameters ao Master ProvidersORM, organizada em ondas autocontidas em ordem técnica (cleanup → base → funcional → polimento → validação → docs). Destino final em .cursor/plans/loggers-parameters-master-absorption-v1.0.plan.md.
scope: src/Commons/Commons.{Types,Consts,Loggers.Types,Loggers.Consts,Parameters.Consts,Parameters.Types}.pas + src/Main/{Providers.v200,Providers.v200.Interfaces,Loggers,Loggers.Interfaces,Parameters,Parameters.Interfaces}.pas + src/Modulos/{Loggers,Parameters}/** + src/Attributers/Attributers.Loggers.* + src/Modulos/Exceptions/Exceptions.{Loggers,Parameters}.pas + ORM.Defines.inc + README.md (novo) + Documentation/ + Analise/
version: 1.0
date: 2026-04-23
---

## Contexto

O ProvidersORM é o **Master**. Parameters e Loggers já foram absorvidos em ondas anteriores (código em `src/Modulos/{Parameters,Loggers}/**`, facades em `src/Main/`, tipos em `src/Commons/Commons.{Parameters,Loggers}.*`, exceções em `src/Modulos/Exceptions/Exceptions.{Parameters,Loggers}.pas`). Persistem:

- **Duplicidades Types/Consts** entre `Commons.Loggers.*` e `Commons.*` (Master): `TLogDatabaseEngine`/`TLogDatabaseType`/`TLogConnectionData` vs `TDatabaseEngine`/`TDatabaseTypes`/`TConnectionData`; `TDatabaseTypeNames` com mesmo identificador em 2 units; blocos `DEFAULT_DATABASE_*` duplicados em `Commons.Loggers.Consts` vs `Commons.Parameters.Consts`.
- **Injeções ecossistema não-consumidas**: `TLogger.FParameters` existe mas nunca é lido; `TParametersImpl.FExceptions` nunca é consumido; `TParametersImpl.FLogger` usado apenas 1× (Refresh).
- **Factory unificado incompleto**: `TProviders` (`src/Main/Providers.v200.pas`) expõe `NewConnection` e `Parameter: IParameters`, falta `Logger: ILogger` e shared connection.
- **Shared connection ausente**: quando `USE_PARAMENTERS` + `USE_LOGGERS` estão ambos ativos (default em `ORM.Defines.inc` linhas 85-86) e o usuário não atribui Connection explícita, ambos os submódulos deveriam reusar a mesma `IConnection` criada por `TProviders.NewConnection` — comportamento "projeto único com switches de compilação".
- **Cosméticos**: 60 headers Loggers com `Project: LoggersORM`/`LoggersCSL`; residual `__history/` em `src/Modulos/Loggers/WebSocket/`; resíduo `pte*` em `Commons.Parameters.Types.pas`.
- **Documentação**: `Documentation/` e `Analise/` não refletem unificação; `README.md` na raiz **não existe**.

## Decisão arquitetural

- **Master (ProvidersORM) prevalece** — remoção direta de duplicidades no Loggers/Parameters, sem aliases `deprecated`. Call-sites atualizados no mesmo commit da onda.
- **Shared connection no TProviders** — se o usuário não atribuir Connection explícita, `TProviders.Parameter` e `TProviders.Logger` reusam a instância cacheada `FDefaultConnection` criada por `GetOrCreateDefaultConnection`.
- **Switches em `ORM.Defines.inc`** — default ON; `{$UNDEF USE_LOGGERS}`/`{$UNDEF USE_PARAMENTERS}` desligam sem impactar demais funcionalidades.
- **Ondas autocontidas** — cada onda tem pré-requisitos explícitos, escopo fechado, arquivos tocados, gate de validação e checkpoint. Contexto de desenvolvimento NÃO é carregado para a próxima onda.

## Ordem técnica (dependências ↓ risco ↓)

```
Onda 1  — Cleanup residuais                  (risco: zero   · dep: nenhuma)
Onda 2  — Unificar enums Types               (risco: médio  · dep: Onda 1)
Onda 3  — Eliminar duplicatas Consts         (risco: médio  · dep: Onda 2)
Onda 4  — Loggers consome IParameters        (risco: baixo  · dep: Ondas 2-3)
Onda 5  — Parameters consome IExceptions/ILogger  (risco: baixo  · dep: Ondas 2-3)
Onda 6  — TProviders + shared connection     (risco: médio  · dep: Ondas 4-5)
Onda 7  — Normalizar headers Loggers (60)    (risco: zero   · dep: Ondas 1-6)
Onda 8  — Validação integrada 4 targets      (risco: N/A    · dep: Ondas 1-7)
Onda 9  — Consolidar Documentation + Analise (risco: N/A    · dep: Onda 8)
Onda 10 — README.md raiz ProvidersORM        (risco: N/A    · dep: Onda 9)
```

Racional da ordenação:

- **Onda 1 primeiro** — cleanup cosmético descarrega ruído sem tocar semântica.
- **Ondas 2-3 core** — Types antes de Consts (Consts consome Types); Consts antes de código funcional (Ondas 4-6 consomem constantes unificadas).
- **Ondas 4-5 paralelas em conceito, sequenciais em commit** — ambas dependem só do core (2-3). Executadas sequencialmente para manter ondas atômicas; poderiam ser invertidas sem prejuízo.
- **Onda 6 depende de 4+5** — `TProviders.Logger` usa interface atualizada da Onda 4; shared connection assume que Parameters/Loggers já consomem corretamente as injeções das Ondas 4-5.
- **Onda 7 última de código** — headers e bump FileVersion consolidam **tudo** que mudou nas ondas 1-6 em uma única entrada Changelog por arquivo (evita 2 bumps).
- **Onda 8 valida** — antes de tocar docs.
- **Ondas 9-10 docs** — derivam do código estável; README deriva de Documentation.

Entre ondas: commit + build verde + checkpoint. Cada onda reinvocável a partir do seu bloco neste documento.

---

## Onda 1 — Cleanup residuais (risco zero)

**Pré-requisitos:** nenhum.

**Escopo:**

- Deletar `src/Modulos/Loggers/WebSocket/__history/Loggers.WebSocket.Consts.pas.~1~`.
- `rmdir src/Modulos/Loggers/WebSocket/__history`.
- Resíduo `pte*` em `Commons.Parameters.Types.pas` (header/comentário): localizar e trocar por `te*` ou remover menção.
- Verificar outros `__history/` órfãos em `src/` (Grep preventivo).

**Gate:** pasta `__history` inexistente; grep ZERO `\bpte[A-Z]` em `src/Commons/Commons.Parameters.Types.pas`; build verde (baseline).

**Checkpoint:** commit `chore(cleanup): remover __history e resíduo pte* — Onda 1`.

---

## Onda 2 — Unificar enums Engine/DatabaseType (core, Master prevalece)

**Pré-requisitos:** Onda 1 completa.

**Escopo:**

- `src/Commons/Commons.Types.pas`: expandir `TDatabaseTypes` para 9 valores:

```pascal
TDatabaseTypes = (dtNone, dtFireBird, dtMySQL, dtPostgreSQL, dtSQLite,
                  dtSQLServer, dtAccess, dtODBC, dtLDAP);
```

- `src/Commons/Commons.Loggers.Types.pas`: **remover** `TLogDatabaseEngine`, `TLogDatabaseType`, `TLogConnectionData`. Manter tipos Loggers-exclusivos (`TLogLevel`, `TLogEntry`, `TLogDestination`, `TLogFormat`, `TLogFilter`, `TLogConfig`, `TLogStatistics`, 8 attribute classes).
- Atualizar ~180 call-sites (auditoria Grep) para:
  - `TLogDatabaseEngine` → `TDatabaseEngine`
  - `TLogDatabaseType` → `TDatabaseTypes`
  - `TLogConnectionData` → `TConnectionData`
  - `lde{None,Unidac,FireDAC,Zeos}` → `te{None,Unidac,FireDAC,Zeos}`
  - `ldt{None,FireBird,MySQL,PostgreSQL,SQLite,SQLServer,Access,ODBC,LDAP}` → `dt{...}`
- Auditar `case TDatabaseTypes` em todo `src/` — adicionar cláusulas `dtODBC`/`dtLDAP` onde cláusula exaustiva é necessária.

**Arquivos tocados:**

- `src/Commons/Commons.Types.pas`
- `src/Commons/Commons.Loggers.Types.pas`
- `src/Main/Loggers.pas` + `Loggers.Interfaces.pas`
- `src/Modulos/Loggers/Databases/Loggers.Database.pas` + `.Interfaces.pas`
- `src/Views/ufrmLoggers.pas`
- Demais consumidores via auditoria Grep

**Gate:** grep ZERO `TLogDatabaseEngine|TLogDatabaseType|TLogConnectionData|\blde[A-Z]|\bldt[A-Z]`; build verde 4 targets.

**Checkpoint:** commit `refactor(types): unificar enums Engine/DatabaseType (Loggers → Master) — Onda 2`.

---

## Onda 3 — Eliminar duplicatas em `Commons.Loggers.Consts`

**Pré-requisitos:** Onda 2 completa.

**Escopo:**

- `src/Commons/Commons.Consts.pas`: estender `TDatabaseTypeNames` para 9 posições (`'ODBC'`, `'LDAP'`); estender `DatabaseTypeDllPaths`/`DatabaseTypeDllNames` (pode ser `''` para ODBC/LDAP).
- `src/Commons/Commons.Loggers.Consts.pas`: **remover**:
  - `TDatabaseTypeNames` (colisão com `Commons.Consts.TDatabaseTypeNames`)
  - `TDatabaseConfig` (se conteúdo for Loggers-específico, renomear para `LogDatabaseEngineMap`; se for universal, consolidar em `Commons.Consts`)
  - Blocos `DEFAULT_DATABASE_HOST_*`, `DEFAULT_DATABASE_PORT_*`, `DEFAULT_DATABASE_USERNAME_*`, `DEFAULT_DATABASE_PASSWORD_*`, `DEFAULT_DATABASE_NAME_*` — consumidores passam a importar `Commons.Parameters.Consts`.
- Adicionar `DEFAULT_LOGGERS_SECTION_NAME = 'loggers'` (para leitura via IParameters na Onda 4).
- Manter apenas Loggers-exclusivos: `DEFAULT_LOG_*` (TABLE_NAME/SCHEMA/AUTO_CREATE_TABLE/LEVEL/FORMAT/DESTINATIONS/CATEGORY), `LogEngineNames`, `LogDatabaseFireDac/Zeos/Unidac`.

**Arquivos tocados:**

- `src/Commons/Commons.Consts.pas`
- `src/Commons/Commons.Loggers.Consts.pas`
- Consumidores dos símbolos removidos (auditoria Grep)

**Gate:** grep ZERO identificadores removidos fora da origem; build verde 4 targets.

**Checkpoint:** commit `refactor(consts): remover duplicatas Commons.Loggers.Consts — Onda 3`.

---

## Onda 4 — Loggers consome IParameters

**Pré-requisitos:** Ondas 2-3 completas.

**Estado atual:** `FParameters: IParameters` e `SetParameters` existem em `TLogger` desde v1.0.1 (12/03/2026) mas o valor é armazenado e **nunca lido**.

**Escopo:**

- `src/Main/Loggers.Interfaces.pas`: adicionar `Parameters(const AParameters: IParameters): ILogger` fluente + getter `Parameters: IParameters`. `SetParameters` vira alias.
- `src/Main/Loggers.pas`: implementar fluent + getter. Em `Refresh`/`Configure`, quando `Assigned(FParameters)`, ler:
  - `loggers.level` → `SetLevel`
  - `loggers.destinations` → `SetDestinations`
  - `loggers.category` → `SetCategory`
- Propagar `FParameters` aos sub-destinos (10 destinos); cada sub-interface ganha `Parameters(IParameters)` fluente.
- Sub-destinos leem configuração específica em `Connect`/`Start`/`Send`:
  - **Database**: `database.table_name`, `database.schema`, `database.auto_create_table`
  - **Emails**: `email.{host,port,user,password,from,to,subject_prefix}`
  - **Https**: `http.{url,token,timeout,retries}`
  - **TextFiles**: `file.{path,max_size,rotation}`
  - **WebSocket**: `ws.{host,port,path}`
  - **EventLogs**: `eventlog.{source,application}`
  - **CSV/XML/JsonObject**: `output.path`

**Arquivos tocados:**

- `src/Main/Loggers.pas` + `Loggers.Interfaces.pas`
- `src/Modulos/Loggers/<Destino>/Loggers.<Destino>.{Interfaces,}.pas` (10 destinos × 2 arquivos)

**Gate:** `ufrmLoggers` e `ufrmEcossistemaTeste` runtime OK consumindo config via `IParameters`; build verde.

**Checkpoint:** commit `feat(loggers): consumir IParameters para configuração de destinos — Onda 4`.

---

## Onda 5 — Parameters consome IExceptions/ILogger

**Pré-requisitos:** Ondas 2-3 completas (independente da Onda 4 em código).

**Estado atual:** `FExceptions`/`FLogger` existem em `TParametersImpl` com setters `SetExceptions`/`SetLogger`. `FLogger` é usado **1 vez** (Refresh); `FExceptions` **0 vezes**.

**Escopo (4 sub-entregas):**

- **5.1 — `FExceptions` em error paths**: onde hoje se invoca `raise E`/`CreateParametersException`/`CreateDatabaseException`, quando `Assigned(FExceptions)` delegar a `FExceptions.Raise(...)`/`FExceptions.HandleException(...)`. Manter `raise` local como fallback.
- **5.2 — `FLogger` ampliado**: `if Assigned(FLogger) then FLogger.<Level>(...)` em:
  - `Connect`/`Disconnect` (info/error)
  - `FromConfig` (debug path resolvido)
  - `LoadFromConfig{Ini,Json,Database}` (info arquivo/tabela lidos)
  - `Read`/`Write`/`Delete` em `IParametersDatabase` (debug opt-in)
  - `ImportFromDatabase`/`ExportToDatabase` (info start/end + contagem)
  - Error paths (error antes de raise/handle)
- **5.3 — Propagação**: ao instanciar `FParametersDatabase`/`FParametersInifiles`/`FParametersJsonObject`, injetar `FExceptions`/`FLogger` se sub-instâncias tiverem setters equivalentes (verificar interface sub).
- **5.4 — Bump** `FileVersion` + Changelog nas units tocadas.

**Arquivos tocados:**

- `src/Main/Parameters.pas`
- `src/Modulos/Parameters/Database/Parameters.Database.pas`
- `src/Modulos/Parameters/IniFiles/Parameters.Inifiles.pas`
- `src/Modulos/Parameters/JsonObject/Parameters.JsonObject.pas`

**Gate:** `ufrmEcossistemaTeste` valida cadeia `SetExceptions`/`SetLogger` → erros logados/delegados quando atribuídos; build verde.

**Checkpoint:** commit `feat(parameters): consumir IExceptions/ILogger em error paths e eventos — Onda 5`.

---

## Onda 6 — `TProviders.Logger` + shared connection

**Pré-requisitos:** Ondas 4-5 completas.

**Estado atual:** `TProviders` expõe `NewConnection` e `Parameter: IParameters`. Falta `Logger: ILogger` e cache `FDefaultConnection` para compartilhar.

**Escopo:**

`src/Main/Providers.v200.Interfaces.pas`:

- Uses condicional adicionando `Loggers.Interfaces` (`USE_LOGGERS`) e `Parameters.Interfaces` (`USE_PARAMENTERS`) se ainda não re-exportados.
- Bump FileVersion + Changelog.

`src/Main/Providers.v200.pas`:

- Uses condicional `Loggers.Interfaces` + `Loggers` (USE_LOGGERS).
- Campo estático `class var FDefaultConnection: IConnection` (cache).
- Método privado `class function GetOrCreateDefaultConnection: IConnection` — cria via `TConnection.New` na primeira chamada; reutiliza nas seguintes.
- Getter público `class function DefaultConnection: IConnection` — retorna `GetOrCreateDefaultConnection`.
- Novos métodos (sob `USE_LOGGERS`):

```pascal
class function Logger: ILogger; overload;
class function Logger(const ACategory: string; ALevel: TLogLevel = llInfo): ILogger; overload;
```

- Implementação:
  - `Logger(...)` delega a `TLoggers.NewLogger` e **pré-associa** `GetOrCreateDefaultConnection` ao contexto da instância retornada. Mecanismo: setter interno do `TLogger` aceita "default connection" que será consumida pelos sub-destinos (`ILoggerDatabase.Connect`) se o usuário não chamar `.Connection(...)` explícita.
  - `Parameter: IParameters` (já existe): ajustar para também pré-associar `GetOrCreateDefaultConnection` ao `IParametersDatabase` interno com o mesmo mecanismo.
- Override explícito pelo usuário: se `.Connection(X)` for chamado no submódulo, `X` prevalece sobre `FDefaultConnection`.

Ajustes em `src/Main/Loggers.pas` e `src/Main/Parameters.pas`:

- Aceitar "default connection pré-associada" via novo setter interno (`SetDefaultConnection`) chamado por `TProviders`. O `Connect` do submódulo usa explícita se atribuída, senão default.

Comportamento esperado pós-Onda 6:

```pascal
// Projeto único, várias funcionalidades, uma conexão:
TProviders.Parameter
  .Database.TableName('config').Connect.List;

TProviders.Logger('MyApp', llInfo)         // compartilha a mesma conexão default
  .Destinations([ldFile, ldDatabase])
  .DatabaseTableName('system_logs');

// Override explícito se quiser conexão separada:
TProviders.Logger.Connection(MyOtherConn)...
```

**Arquivos tocados:**

- `src/Main/Providers.v200.pas`
- `src/Main/Providers.v200.Interfaces.pas`
- `src/Main/Loggers.pas` (setter interno `SetDefaultConnection`)
- `src/Main/Parameters.pas` (setter interno `SetDefaultConnection`)

**Gate:** novo formulário `ufrmProvidersSharedTeste` (ou extensão em `ufrmEcossistemaTeste`) valida cenário 1-conexão-para-ambos; override com `.Connection()` também funciona; build verde.

**Checkpoint:** commit `feat(providers): TProviders.Logger + shared connection (USE_LOGGERS + USE_PARAMENTERS) — Onda 6`.

---

## Onda 7 — Normalizar headers Loggers (Master rule)

**Pré-requisitos:** Ondas 1-6 completas.

**Escopo:** 60 units Loggers com `Project: LoggersORM`/`LoggersCSL`:

- `Project:` → `ProvidersORM`
- `ProjectVersion:` → `2.1.6` (de `ORM.Version.inc`)
- `Date:` → `23/04/2026`
- Bump `FileVersion` +0.0.1 (consolidando todas as mudanças das Ondas 1-6 naquela unit em uma única entrada Changelog)
- Entrada Changelog: `- X.Y.Z (23/04/2026): Header normalizado ao Master ProvidersORM; unificação Types/Consts (Ondas 2-3), consumo IParameters (Onda 4), shared connection (Onda 6) — conforme aplicável.`

**Arquivos tocados (60):**

- `src/Main/`: 2 · `src/Attributers/`: 2
- `src/Modulos/Loggers/CSV/`: 5 · `Databases/`: 2 · `Emails/`: 5 · `Engines/`: 9
- `EventLogs/`: 5 · `Events/`: 5 · `Https/`: 5 · `JsonObject/`: 7
- `TextFiles/`: 2 · `WebSocket/`: 5 · `XML/`: 5

**Gate:** grep ZERO `Project:\s+LoggersORM|LoggersCSL` em `src/`; build verde.

**Checkpoint:** commit `chore(headers): normalizar Project: ProvidersORM em 60 units Loggers — Onda 7`.

---

## Onda 8 — Validação integrada

**Pré-requisitos:** Ondas 1-7 completas.

**Escopo:**

- **Pré-requisito ambiente:** corrigir `dcc32.cfg`/`dcc64.cfg` linha 57 `dataset-serialize` → `horse-dataset-serialize` (blocker de validação). Verificar `fpc32.opts`/`fpc64.opts` (gerar se ausentes via `Bootstrap-BuildConfig.ps1`).
- **Build 4 targets:** `dcc32 ProvidersORM.dpr`, `dcc64 ProvidersORM.dpr`, `fpc @fpc32.opts ProvidersORM.lpr`, `fpc @fpc64.opts ProvidersORM.lpr` — todos verdes.
- **Runtime smoke em cadeia:**
  - `ufrmConnectionTeste` (baseline IConnection)
  - `ufrmPoolConnectionsTeste`
  - `ufrmDatabaseTeste` + `ufrmDatabaseAttributersTeste`
  - `ufrmParameters` + `ufrmParametersAttributers` (Onda 5 validada)
  - `ufrmLoggers` (Onda 4 validada)
  - `ufrmEcossistemaTeste` (cadeia completa SetExceptions+SetLogger+SetParameters)
  - `ufrmProvidersSharedTeste` (Onda 6 — shared connection)
  - `ufrmExceptionsTeste`
- **Greps finais (todos devem retornar ZERO):**
  - `Project:\s+LoggersORM|LoggersCSL`
  - `TLogDatabaseEngine|TLogDatabaseType|TLogConnectionData|\blde[A-Z]|\bldt[A-Z]`
  - `\bpte[A-Z]` em `src/Commons/`

**Gate:** todas as provas acima OK. Se qualquer falhar → retorna à onda responsável (rollback parcial via `git revert` do commit respectivo).

**Checkpoint:** commit `test: validação integrada Ondas 1-7 — Onda 8`.

---

## Onda 9 — Consolidar `Documentation/` e `Analise/`

**Pré-requisitos:** Onda 8 verde.

**Escopo:**

### 9.1 — `Documentation/`

- `Arquitetura/` — atualizar diagramas/textos citando `TLog*`/`lde*`/`ldt*` (removidos); documentar shared connection e ecossistema unificado `TProviders`.
- `Arquitetura/Loggers/` + `Arquitetura/Parameters/` — documentar consumo de `IParameters`/`IExceptions`/`ILogger`; lista de chaves convencionadas (`loggers.*`, `parameters.*`, `database.*`, `email.*`, etc.).
- `RegrasNegocio/` — atualizar RNs dos módulos tocados se contratos públicos mudaram (expansão `TDatabaseTypes` com `dtODBC`/`dtLDAP` é um breaking MINOR).
- `BancoDados/` — sem mudança esperada (esquemas `config` e `system_logs` preservados).
- `Esboco_Telas/` — sem mudança esperada.
- `Versionamento/CHANGELOG.md` — entrada consolidada v2.1.6:
  - **Breaking**: remoção `TLog*`/`lde*`/`ldt*`, `TDatabaseTypeNames` duplicado, `TDatabaseConfig` duplicado, `DEFAULT_DATABASE_*` duplicados em `Commons.Loggers.Consts`.
  - **Feature**: Loggers consome `IParameters` para configuração (Onda 4).
  - **Feature**: Parameters consome `IExceptions`/`ILogger` em error paths e eventos (Onda 5).
  - **Feature**: `TProviders.Logger: ILogger` + shared connection (Onda 6).
  - **Feature**: `TDatabaseTypes` expandido com `dtODBC`/`dtLDAP` (Onda 2).
- `README.md` (hub) — atualizar cross-links.

### 9.2 — `Analise/` (se presente)

- Invocar `documentation-paste_analysis_unit_class_method` para re-scan dos arquivos alterados.
- Atualizar `Analise/README.md` com resumo da consolidação.
- Verificar cobertura em `Analise/M0X-<Modulo>/` (convenção MXX).

### 9.3 — Skills a invocar

- `documentation-versioning-changelog`
- `documentation-architecture`
- `documentation-paste_analysis_unit_class_method`
- `documentation-review`
- `governance-refactoring-compatibility-policy`
- `version-breaking-change-guard`
- `version-release-notes`

**Gate:** `documentation-review` passa sem erros críticos.

**Checkpoint:** commit `docs: consolidar Documentation e Analise — Onda 9`.

---

## Onda 10 — Criar `E:/CSL/ProvidersORM/README.md` (raiz)

**Pré-requisitos:** Onda 9 completa (README deriva de Documentation consolidada).

**Escopo:** produzir novo `README.md` no molde dos referenciais:

- Principal: `E:/CSL/ParamentersORM/README.md` (3531 L) — estrutura completa.
- Secundário: `E:/CSL/LoggersORM/README.md` (507 L) — exemplos concisos Factory Pattern.

**Estrutura alvo (800-1500 L):**

1. Cabeçalho `# 🏛 Providers ORM v2.1.6` (Versão, Datas, Status, Compatibilidade: Delphi XE7+, FPC 3.3.1+/3.2.2+, Lazarus, FPCUnit).
2. Patch notes v2.1.6 (sumário das Ondas 1-9 — breakings + features).
3. Versões anteriores (linha do tempo agregando CHANGELOG).
4. Índice.
5. Descrição Geral (ecossistema unificado — acesso a dados, logging, exceções, parâmetros, atributos).
6. Arquitetura (árvore de pastas, facades `src/Main/`, convenções `I*`/`T*`/`New`/Fluent, tabela de dependências entre módulos).
7. Módulos (um bloco por módulo com propósito + entry unit + exemplo mínimo fluent):
   - **Connections** — `IConnection`/`TConnection` multi-engine (FireDAC/UniDAC/Zeos/SQLdb).
   - **PoolConnections** — `TPoolConnections` pool de conexões.
   - **Database** — ORM (Fields/Tables/Schemas/EntityManager/QueryBuilder/IdentityMap/UnitOfWork).
   - **Exceptions** — `Exceptions.*` centralizadas (Base, Database, Loggers, Parameters, SQL).
   - **Loggers** — destinos (TextFiles/Database/Email/HTTP/EventLog/WebSocket/CSV/JSON/XML/Events), Factory v2.0.0, consumo `IParameters`+`IConnection` (trechos adaptados do LoggersORM/README.md).
   - **Parameters** — fontes (Database/IniFiles/JsonObject), consumo `IConnection`, `SetLogger`/`SetExceptions` (trechos adaptados do ParametersORM/README.md).
   - **Attributers** — `Attributers.{Parameters,Loggers,Providers}.*` com `IAttributeRegistry`, `ConnectionAttribute`.
8. Diretivas de compilação (`ORM.Defines.inc`: `USE_FIREDAC`/`USE_UNIDAC`/`USE_ZEOS`/`USE_SQLDB` engines, `USE_PARAMENTERS`/`USE_LOGGERS`/`USE_POOLCONNECTIONS`/`USE_ATTRIBUTES` funcionalidades — todos default ON; `ORM.Version.inc`).
9. Instalação e Configuração (paths Zeos/UniDAC/Synapse/horse-dataset-serialize em `dcc32.cfg`/`dcc64.cfg`/`fpc*.opts`).
10. Compilação CLI (exemplos 4 targets).
11. Exemplos Práticos (end-to-end `TProviders.Parameter` + `TProviders.Logger` + shared connection — Onda 6 em ação).
12. Compatibilidade (matriz Delphi/FPC/SO/engines).
13. Testes (lista de `ufrm*Teste` em `src/Views/`).
14. Licença (aponta `LICENSE`).
15. Contribuindo (aponta `.cursor/` SSOT de skills/rules e `Documentation/`).

**Regras:**

- Emojis moderados (🏛 📋 🚀 ✅).
- Paths relativos ao repo.
- Links para: `[Plano Ondas 1-10](.cursor/plans/loggers-parameters-master-absorption-v1.0.plan.md)`, `CHANGELOG.md`, `Documentation/README.md`.

**Gate:** `README.md` criado; lint markdown sem erros críticos; preview visual OK.

**Checkpoint:** commit `docs: README.md raiz ProvidersORM v2.1.6 — Onda 10`.

---

## Fechamento

- Mover este plano de `D:\Users\claiton.linhares\.claude\plans\cheerful-forging-fox.md` para `E:/CSL/ProvidersORM/.cursor/plans/loggers-parameters-master-absorption-v1.0.plan.md`.
- Registrar link em `Documentation/Arquitetura/README.md`, `Analise/README.md` (se existir) e novo `README.md` raiz.
- Arquivar em `.cursor/plans/archived/` após release publicado.

## Riscos e rollback

- **Breaking sem deprecated** (Ondas 2-3): quebra call-sites não migrados. Mitigação: Grep completa antes/depois de cada onda; CI impede merge se restar identificador antigo.
- **Shared connection ambiguidade** (Onda 6): override explícito via `.Connection(X)` deve prevalecer. Cobrir em teste.
- **Ordem atômica**: cada onda é um commit; rollback = `git revert` do commit. Ondas posteriores dependem da integridade das anteriores.

## Fora do escopo

- Remoção física de `Loggers.Paramenters.*` (stubs vazios upstream) — sem impacto no embed.
- Atualização de `E:/CSL/LoggersORM` e `E:/CSL/ParamentersORM` upstream.
- Migração de estrutura de pastas.
