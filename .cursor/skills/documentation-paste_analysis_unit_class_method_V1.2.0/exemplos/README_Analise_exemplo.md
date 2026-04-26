# ProvidersORM v2.0 - Analise por Classe/Interface

> Documentacao tecnica detalhada de cada classe, interface, record e enum do ProvidersORM, com exemplos de uso por metodo.

**Projeto:** ProvidersORM v2.0
**Modo:** Slim (`TConnection` + `TTables` independentes)
**Compilador:** Delphi / Free Pascal
**Diretivas:** `ORM.Defines.inc`

---

## Convencao de nomenclatura canonica

Os arquivos desta pasta seguem a politica `{ClassName}.md`, onde `ClassName` e o nome **sem** prefixo `T`, `I` ou `E`.

- Arquivos fundidos (I+T): contem secoes **Interface** e **Classe** no mesmo documento.
- Arquivos de excecao (E): contem secao **Excecao**.
- Arquivos de unit (sem prefixo): documentam units inteiras (ex.: `Commons.Consts.md`).

---

## Estrutura do Projeto

```text
Documentation/Analise/
├── README.md                          (este arquivo)
├── FLOWCHART.md                       (fluxogramas Mermaid da arquitetura)
├── Commons/                           (tipos, constantes, utilitarios compartilhados)
├── Connections/                       (Connection.md)
├── PoolConnections/                   (PoolConnections.md, Pool.md, PoolConnectionEvent.md)
├── Database/
│   ├── Fields/                        (Field.md, Fields.md)
│   ├── Tables/                        (Table.md, Tables.md)
│   ├── Schemas/                       (Schema.md, Schemas.md)
│   ├── EntityManager/                 (EntityManager.md)
│   ├── QueryBuilder/                  (QueryBuilder.md)
│   ├── IdentityMap/                   (IdentityMap.md)
│   ├── UnitOfWork/                    (UnitOfWork.md)
│   └── TypeDatabase/                  (TypeDatabase.md)
├── Exceptions/                        (ExceptionBase.md, ConnectionException.md, ParametersException.md, ExceptionsDatabase.md, Exceptions.SQL.md)
├── Loggers/
│   ├── Commons/                       (Loggers.Commons.*.md — units)
│   ├── Database/                      (Loggers.Database.*.md — units)
│   ├── CSV/                           (Loggers.CSV.*.md — units)
│   ├── TextFiles/                     (Loggers.TextFiles.*.md — units)
│   ├── XML/                           (LoggerXML.md)
│   ├── JsonObject/                    (LoggerJSONObject.md)
│   ├── HTTPs/                         (LoggerHTTP.md, LoggerHTTPEngine.md)
│   ├── EMails/                        (LoggerEmail.md, LoggerEmailEngine.md)
│   ├── WebSocket/                     (LoggerWebSocket.md)
│   ├── EventLogs/                     (LoggerEventLog.md)
│   ├── Events/                        (LoggerEventManager.md, LoggerEventSubscription.md)
│   └── Attributes/                    (Loggers.Attributes.*.md — units)
├── Parameters/
│   ├── Database/                      (ParametersDatabase.md)
│   ├── IniFiles/                      (ParametersInifiles.md)
│   ├── JsonObject/                    (ParametersJsonObject.md)
│   └── Attributes/                    (AttributeMapper.md, AttributeParser.md)
├── Attributers/                       (AttributeParser.md, AttributeMapper.md, AttributeRegistry.md)
├── Main/                              (Exceptions.md, Logger.md, Loggers.md, Parameters.md, Providers.Database.md, Providers.v200.md)
└── Providers.v161/                    (camada de compatibilidade v1.6.1 — nao renomeado)
```

---

## Indice por Modulo

### Commons — Tipos e Utilitarios Compartilhados [RN ✓]

> Regras de negócio: [RN_Commons_V1.0.md](../Regras%20de%20Negocio/RN_Commons_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Enum | [DatabaseEngine](Commons/DatabaseEngine.md) | Engine de banco ativo (UniDAC/FireDAC/Zeos/SQLdb) |
| Enum | [DatabaseTypes](Commons/DatabaseTypes.md) | Tipo de banco (PostgreSQL/MySQL/SQLServer/Firebird/SQLite/Access) |
| Enum | [DatabaseVariableType](Commons/DatabaseVariableType.md) | Categoria de tipo Pascal para SQL |
| Enum | [ConnectionStatus](Commons/ConnectionStatus.md) | Estado da conexao (Connected/Disconnected/Error) |
| Enum | [ConnectionMode](Commons/ConnectionMode.md) | Modo de configuracao (Manual/Parameters) |
| Record | [ConnectionData](Commons/ConnectionData.md) | Snapshot de configuracao de conexao |
| Record | [DatabaseFields](Commons/DatabaseFields.md) | Metadados de coluna com FK rules |
| Record Helper | [ConnectionDLL](Commons/ConnectionDLL.md) | Resolucao de caminho de DLL por banco |
| Classe | [DatabaseTypeClass](Commons/DatabaseTypeClass.md) | Helper estatico: FromString, DisplayName, VariableType |
| Classe | [File](Commons/File.md) | I/O de arquivo (compatibilidade FPC) |
| Classe | [Path](Commons/Path.md) | Manipulacao de caminhos (compatibilidade FPC) |
| Unit | [Commons.Consts](Commons/Commons.Consts.md) | 80+ constantes globais do framework |
| Unit | [Commons.Messages](Commons/Commons.Messages.md) | Callbacks de mensagem desacoplados |
| Unit | [Commons.StrUtils](Commons/Commons.StrUtils.md) | IfThen overloads (FPC) |
| Unit | [Commons.Exceptions](Commons/Commons.Exceptions.md) | Stub para Exceptions.Base |
| Unit | [Commons.Parameters.Types](Commons/Commons.Parameters.Types.md) | TParameter, TParameterList, TParameterSource, TParameterValueType |
| Unit | [Commons.Parameters.Consts](Commons/Commons.Parameters.Consts.md) | Defaults de conexao por banco |
| Unit | [Commons.Parameters.Exceptions](Commons/Commons.Parameters.Exceptions.md) | Stub para Exceptions.Parameters |
| Unit | [Commons.Loggers.SQL](Commons/Commons.Loggers.SQL.md) | Reservado (stub) |
| Unit | [Commons.SQL.Helpers](Commons/Commons.SQL.Helpers.md) | 8 funcoes de formatacao SQL + 5 helpers de TDataSet (v2.1) |

### Connections — Conexao com Banco de Dados [RN ✓] — atualizado v2.1

> Regras de negócio: [RN_Connections_V1.0.md](../Regras%20de%20Negocio/RN_Connections_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [Connection](Connections/Connection.md) | Contrato de conexao (IConnection) e implementacao multi-engine (TConnection); config fluente, SQL, transacoes, metadados; overloads parametrizados (v2.1) |

### PoolConnections — Pool de Conexoes (`USE_POOLCONNECTIONS`) [RN ✓]

> Regras de negócio: [RN_PoolConnections_V1.0.md](../Regras%20de%20Negocio/RN_PoolConnections_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [PoolConnections](PoolConnections/PoolConnections.md) | Container FIFO de IConnection com deduplicacao (IPoolConnections + TPoolConnections) |
| Record | [Pool](PoolConnections/Pool.md) | Entrada nomeada do pool (Id, Name, Connection) |
| Tipo | [PoolConnectionEvent](PoolConnections/PoolConnectionEvent.md) | Tipo de evento para operacoes do pool |

### Database — Nucleo ORM [RN ✓]

> Regras de negócio: [RN_Database_V1.0.md](../Regras%20de%20Negocio/RN_Database_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [Field](Database/Fields/Field.md) | Coluna individual: metadados, FK, valor, change-tracking (IField + TField) |
| Interface + Classe | [Fields](Database/Fields/Fields.md) | Container de IField (IFields + TFields) |
| Interface + Classe | [Table](Database/Tables/Table.md) | Tabela + DML/DDL + audit fields (ITable + TTable) |
| Interface + Classe | [Tables](Database/Tables/Tables.md) | Container de ITable: LoadFromConnection (ITables + TTables) |
| Interface + Classe | [Schema](Database/Schemas/Schema.md) | Schema + database (ISchema + TSchema) |
| Interface + Classe | [Schemas](Database/Schemas/Schemas.md) | Container de ISchema (ISchemas + TSchemas) |
| Interface + Classe | [EntityManager](Database/EntityManager/EntityManager.md) | Persistencia: Find, List, Save, Delete com cache (IEntityManager + TEntityManager) |
| Interface + Classe | [QueryBuilder](Database/QueryBuilder/QueryBuilder.md) | SQL fluente: Select, From, Where, OrderBy, Execute; 17 metodos avancados (v2.1) |
| Interface + Classe | [IdentityMap](Database/IdentityMap/IdentityMap.md) | Cache generico (Fowler Identity Map) |
| Interface + Classe | [UnitOfWork](Database/UnitOfWork/UnitOfWork.md) | Batch transacional (Fowler Unit of Work) |
| Interface + Classe | [TypeDatabase](Database/TypeDatabase/TypeDatabase.md) | Quoting e schema-support por banco |

### Exceptions — Hierarquia de Excecoes

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Classe | [ExceptionBase](Exceptions/ExceptionBase.md) | Raiz: ErrorCode + Operation |
| Classe | [ConnectionException](Exceptions/ConnectionException.md) | 5 subtipos, codes 40001-40019 |
| Classe | [ParametersException](Exceptions/ParametersException.md) | 8 subtipos, codes 500001-500809 |
| Interface + Classe | [ExceptionsDatabase](Exceptions/ExceptionsDatabase.md) | Banco de mensagens por codigo/constante (IExceptionsDatabase + TExceptionsDatabase) |
| Unit | [Exceptions.SQL](Exceptions/Exceptions.SQL.md) | Templates CREATE TABLE para 6 bancos |

### Loggers — Sistema de Logging Multi-Destino (`USE_LOGGERS`) [RN ✓]

> Regras de negócio: [RN_Loggers_V1.0.md](../Regras%20de%20Negocio/RN_Loggers_V1.0.md)

| Destino | Documento | Pasta |
| --- | --- | --- |
| XML | [LoggerXML](Loggers/XML/LoggerXML.md) | `Loggers/XML/` |
| JSON | [LoggerJSONObject](Loggers/JsonObject/LoggerJSONObject.md) | `Loggers/JsonObject/` |
| HTTP/HTTPS | [LoggerHTTP](Loggers/HTTPs/LoggerHTTP.md) + [LoggerHTTPEngine](Loggers/HTTPs/LoggerHTTPEngine.md) | `Loggers/HTTPs/` |
| E-mail (SMTP) | [LoggerEmail](Loggers/EMails/LoggerEmail.md) + [LoggerEmailEngine](Loggers/EMails/LoggerEmailEngine.md) | `Loggers/EMails/` |
| WebSocket | [LoggerWebSocket](Loggers/WebSocket/LoggerWebSocket.md) | `Loggers/WebSocket/` |
| Event Log | [LoggerEventLog](Loggers/EventLogs/LoggerEventLog.md) | `Loggers/EventLogs/` |
| Eventos | [LoggerEventManager](Loggers/Events/LoggerEventManager.md) + [LoggerEventSubscription](Loggers/Events/LoggerEventSubscription.md) | `Loggers/Events/` |

#### Loggers — Units de suporte (deixadas no lugar)

| Unit | Pasta |
| --- | --- |
| Loggers.Attributes.md, .Consts.md, .Exceptions.md, .Interfaces.md, .Types.md | `Loggers/Attributes/` |
| Loggers.CSV.md, .Consts.md, .Exceptions.md, .Interfaces.md, .Types.md | `Loggers/CSV/` |
| Loggers.Commons.Consts.md, .Exceptions.md, .Types.md | `Loggers/Commons/` |
| Loggers.Database.Consts.md, .Exceptions.md, .Interfaces.md | `Loggers/Database/` |
| Loggers.TextFiles.md, .Interfaces.md | `Loggers/TextFiles/` |

### Parameters — Gerenciamento de Parametros (`USE_PARAMENTERS`) [RN ✓]

> Regras de negócio: [RN_Parameters_V1.0.md](../Regras%20de%20Negocio/RN_Parameters_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [ParametersDatabase](Parameters/Database/ParametersDatabase.md) | CRUD via banco de dados (IParametersDatabase + TParametersDatabase) |
| Interface + Classe | [ParametersInifiles](Parameters/IniFiles/ParametersInifiles.md) | CRUD via arquivo INI (IParametersInifiles + TParametersInifiles) |
| Interface + Classe | [ParametersJsonObject](Parameters/JsonObject/ParametersJsonObject.md) | CRUD via objeto JSON (IParametersJsonObject + TParametersJsonObject) |
| Interface | [AttributeParser](Parameters/Attributes/AttributeParser.md) | Parse de atributos [Parameter] via RTTI |
| Interface | [AttributeMapper](Parameters/Attributes/AttributeMapper.md) | Mapeamento classe para TParameterList |

### Attributers — Mapeamento RTTI ORM (`USE_ATTRIBUTES`) [RN ✓]

> Regras de negócio: [RN_Attributers_V1.0.md](../Regras%20de%20Negocio/RN_Attributers_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [AttributeParser](Attributers/AttributeParser.md) | Parse de [Table], [Field], [PrimaryKey] via RTTI |
| Interface + Classe | [AttributeMapper](Attributers/AttributeMapper.md) | Mapeamento classe para ITable |
| Interface + Classe | [AttributeRegistry](Attributers/AttributeRegistry.md) | Cache singleton de ITables com TDictionary |

### Main — Facades Publicas [RN ✓]

> Regras de negócio: [RN_Main_V1.0.md](../Regras%20de%20Negocio/RN_Main_V1.0.md)

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Interface + Classe | [Exceptions](Main/Exceptions.md) | Facade para banco de mensagens (IExceptions + TExceptions) |
| Interface + Classe | [Logger](Main/Logger.md) | Logger principal: 5 niveis, 8 destinos (ILogger + TLogger) |
| Interface | [Loggers](Main/Loggers.md) | Gerenciador de multiplos loggers |
| Interface + Classe | [Parameters](Main/Parameters.md) | Facade unificada para 3 fontes (IParameters + TParameters) |
| Unit | [Providers.Database](Main/Providers.Database.md) | Factory v2.0.0 |
| Unit | [Providers.v200](Main/Providers.v200.md) | Factory v2.0.0 |

### Providers.v161 — Compatibilidade Retroativa

| Tipo | Documento | Descricao |
| --- | --- | --- |
| Enum | [TDatabaseProvider](Providers.v161/TDatabaseProvider.md) | 7 providers hardcoded |
| Classe | [TProviderConnectionHelper](Providers.v161/TProviderConnectionHelper.md) | Helpers de conexao |
| Classe | [TProviderFieldHelper](Providers.v161/TProviderFieldHelper.md) | Helpers de campo |
| Classe | [TProviderSQLBuilder](Providers.v161/TProviderSQLBuilder.md) | SQL de introspeccao |
| Classe | [TProviderTypeConverter](Providers.v161/TProviderTypeConverter.md) | Conversao de tipos |
| Classe | [TProviderCRUDModule](Providers.v161/TProviderCRUDModule.md) | Geracao DML |
| Unit | [Utilities](Providers.v161/Utilities.md) | Session, Loading, Navigation, Strings |

---

## Fluxogramas

Ver [FLOWCHART.md](FLOWCHART.md) para 4 diagramas Mermaid:

1. **Arquitetura geral** — modulos e camadas
2. **Hierarquia ORM** — Field ate Schemas
3. **Loggers fan-out** — 10 destinos simultaneos
4. **Grafo de dependencia** entre modulos

---

## Convencoes

- **Factory pattern** — `TXxx.New: IXxx` como ponto de entrada
- **API Fluente** — setters retornam a propria interface
- **Nomenclatura canonica** — arquivo `{ClassName}.md` sem prefixo `T`/`I`/`E`
- **Fusao I+T** — interface e classe documentadas no mesmo arquivo canonico
- **Diretivas** — modulos opcionais via `{$DEFINE USE_*}` em `ORM.Defines.inc`
- **Commons como fonte unica** — tipos/constantes compartilhados em `src/Commons/`
