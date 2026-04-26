# ProvidersORM v2.0

> Biblioteca ORM para Delphi e Free Pascal com suporte multi-engine e arquitetura modular.

---

## O que é

**ProvidersORM** é uma biblioteca ORM (*Object-Relational Mapping*) escrita em **Object Pascal**, compatível com **Delphi** e **Free Pascal / Lazarus**. Fornece uma camada de abstração completa para acesso a bancos de dados relacionais, eliminando a dependência direta de um engine específico e permitindo trocar o driver de dados apenas por diretivas de compilação.

Opera exclusivamente no modo **ORM**: `TConnection` e `TTables` são objetos independentes (sem herança entre si), garantindo separação clara entre conexão e mapeamento de dados.

---

## Características

- **Multi-engine por compilação** — um único engine ativo por build, definido em `ORM.Defines.inc` via diretivas `{$IFDEF}`.
- **API Fluente obrigatória** — todos os métodos de configuração e mutação retornam a própria interface para encadeamento (ex.: `TConnection.New.Host('localhost').Port(5432).Database('mydb')`).
- **Factory pattern** — todas as classes principais expõem `New` como ponto de entrada (ex.: `TField.New`, `TTable.New`, `TConnection.New`).
- **Arquitetura modular** — módulos opcionais ativados por diretiva: `USE_POOLCONNECTIONS`, `USE_LOGGERS`, `USE_PARAMENTERS`, `USE_ATTRIBUTES`, `USE_ENTITY_MANAGER`, `USE_QUERY_BUILDER`.
- **Commons como fonte única** — tipos, constantes e enums compartilhados em `src/Commons` (Commons.Types, Commons.Consts, Commons.Exceptions), sem duplicação entre módulos.
- **Exceções hierárquicas por módulo** — todas derivam de `EDatabaseException`; faixas de código por módulo (10XXX Commons, 20XXX Fields, 30XXX Tables, 40XXX Connections, etc.).
- **Compatibilidade Delphi / FPC** — condicionais de engine e UI (`USE_FMX` / VCL) garantem portabilidade.
- **Configuração flexível de conexão** — suporte a configuração manual (fluente), `FromConfig` (INI / JSON / Database) e `FromJSONObject` (objeto JSON em memória).
- **CLI para bancos** — acesso direto via `mysql`, `sqlite3` e Firebird `isql`; parâmetros em `Data/config.ini`, `Data/config.json` e `Data/config1.json`.
- **Multi-compilador** — Delphi (dcc32/dcc64) e Free Pascal/Lazarus.
- **Multi-UI** — VCL/LCL e FireMonkey (FMX).

---

## Engines

### Engines de banco de dados (um por build)

Apenas **um engine** é compilado por build. A seleção é feita em `ORM.Defines.inc`:

| Diretiva | Engine | Delphi | FPC | Bancos suportados |
| --- | --- | --- | --- | --- |
| `USE_FIREDAC` | **FireDAC** (Embarcadero) | Sim | Não | PostgreSQL, MySQL, SQL Server, Firebird, SQLite, Access |
| `USE_UNIDAC` | **UniDAC** (DevArt) | Sim | Sim | PostgreSQL, MySQL, SQL Server, Firebird, SQLite, Access |
| `USE_ZEOS` | **ZeosLib** (open-source) | Sim | Sim (recomendado) | PostgreSQL, MySQL, SQL Server, Firebird, SQLite |
| `USE_SQLDB` | **SQLdb** (Free Pascal) | Não | Sim | PostgreSQL, MySQL, Firebird, SQLite |

> Detecção automática disponível: tenta na ordem UniDAC → FireDAC → Zeos → SQLdb.

### Comparativo completo de engines

| Critério | FireDAC | UniDAC | Zeos | SQLdb |
| --- | --- | --- | --- | --- |
| **Delphi** | Sim | Sim | Sim | Não |
| **Free Pascal** | Não | Sim | Sim | Sim |
| **Licença** | Inclusa no Delphi | Comercial (Devart) | Open source (LGPL) | Open source (LGPL) |
| **PostgreSQL** | Sim | Sim | Sim | Sim |
| **MySQL** | Sim | Sim | Sim | Sim |
| **SQL Server** | Sim | Sim | Sim | Sim |
| **Firebird** | Sim | Sim | Sim | Sim |
| **SQLite** | Sim | Sim | Sim | Sim |
| **Access** | Sim | Sim | Via ADO/OLE DB | Via ODBC |
| **Modo direto** | Parcial | Sim (sem libs cliente) | Não | Não |
| **Array DML (bulk)** | Sim | Sim | Limitado | Não |
| **Connection Pool** | Sim (nativo) | Sim (nativo) | Não nativo | Não nativo |
| **Monitoramento SQL** | Sim | Sim | Sim (`TZSQLMonitor`) | Básico |
| **Cached Updates** | Sim | Sim | Não | Não |
| **Cross-platform** | Win/macOS/iOS/Android/Linux | Win/macOS/iOS/Android/Linux | Win/Linux/macOS | Win/Linux/macOS/FreeBSD |

### Bancos de dados suportados

| Banco | Tipo |
| --- | --- |
| PostgreSQL | Relacional open-source |
| MySQL | Relacional open-source |
| SQL Server | Relacional Microsoft |
| Firebird | Relacional open-source |
| SQLite | Embedded / arquivo |
| Access | Embedded Microsoft |

### Comparativo geral de bancos de dados

| Característica | PostgreSQL | MySQL | SQL Server | Firebird | SQLite | Access |
| --- | --- | --- | --- | --- | --- | --- |
| **Licença** | Open source | Open source / Comercial | Comercial | Open source | Domínio público | Comercial (Office) |
| **Servidor** | Sim | Sim | Sim | Sim / Embedded | Embedded (arquivo) | Arquivo |
| **Schemas** | Sim | Não (banco = namespace) | Sim (`dbo`) | Não | Não | Não |
| **ID automático** | SERIAL / IDENTITY / Sequence | AUTO_INCREMENT | IDENTITY | Generator + Trigger | INTEGER PRIMARY KEY | AutoNumber |
| **RETURNING / OUTPUT** | `RETURNING` | Não (`LAST_INSERT_ID()`) | `OUTPUT INSERTED` | `RETURNING` | `last_insert_rowid()` | `@@IDENTITY` |
| **Paginação** | `LIMIT/OFFSET` | `LIMIT/OFFSET` | `OFFSET FETCH` / `TOP` | `FIRST/SKIP` (FB4+: `OFFSET FETCH`) | `LIMIT/OFFSET` | `TOP` (sem OFFSET nativo) |
| **Boolean nativo** | Sim | Não (`TINYINT(1)`) | Não (`BIT`) | Sim (FB3+) | Não (`INTEGER 0/1`) | Sim (`YESNO`) |
| **JSON nativo** | Sim (`JSONB`) | Sim (5.7+) | Sim (2016+) | Não | Extensão `json1` | Não |
| **Concorrência** | MVCC | InnoDB: MVCC | Lock + versioning | MVCC | WAL / file lock | File lock |
| **Deploy** | Servidor | Servidor | Servidor | Servidor / Embedded | Arquivo único | Arquivo único |
| **Popularidade Delphi/BR** | Alta | Média | Alta | Muito alta | Alta | Média (legado) |

### Engines de serviços auxiliares

| Tipo | Opções |
| --- | --- |
| HTTP/HTTPS | Indy (padrão), ICS, IPWorks, Synapse |
| E-mail (SMTP) | Indy, ICS, IPWorks, Synapse |
| WebSocket | Indy, TMS WebSocket, Bird Socket, Horse |
| LDAP | Synapse (sempre incluído) |

---

## Funcionalidades

### Núcleo ORM

Hierarquia de objetos mapeando a estrutura relacional:

```text
Field → Fields → Table → Tables → Schema → Schemas
```

Camadas auxiliares ativáveis por diretiva:

| Componente | Diretiva | Responsabilidade |
| --- | --- | --- |
| `TypeDatabase` | `USE_TYPEDATABASE` | Mapeamento de tipos por banco/engine |
| `EntityManager` | `USE_ENTITY_MANAGER` | Persistência e ciclo de vida de entidades |
| `QueryBuilder` | `USE_QUERY_BUILDER` | Construção de queries via API fluente |
| `IdentityMap` | `USE_ENTITY_MANAGER` | Cache de identidade de entidades |
| `UnitOfWork` | `USE_ENTITY_MANAGER` | Controle transacional em batch |
| `Attributers` | `USE_ATTRIBUTES` | Mapeamento por atributos RTTI |

### Conexão (modo ORM)

- `IConnection` / `TConnection` — abstração de conexão individual com suporte a `Connect`, `Disconnect`, `ExecuteQuery`, `ExecuteCommand` e controle de transações.
- Configuração fluente: `Host`, `Port`, `Username`, `Password`, `Database`, `Schema`, `Engine`, `DatabaseType`.
- Suporte a `FromConfig` (carrega de INI / JSON / Database) e `FromJSONObject` (JSON em memória).

### Pool de Conexões (`USE_POOLCONNECTIONS`)

- `IPoolConnections` / `TPoolConnections` — gerencia reaproveitamento de conexões com timeout.
- Eventos: `OnBeforeGetFromPool`, `OnAfterReturnToPool`.

### Query Builder (`USE_QUERY_BUILDER`)

API fluente para construção de SQL sem literais:

```pascal
TDatabase.New
  .Table('clientes')
  .AddField('nome').AddField('email')
  .Where('ativo = 1')
  .OrderBy('nome')
  .Build;
```

### Entity Manager (`USE_ENTITY_MANAGER`)

Persistência direta de objetos com atributos RTTI:

```pascal
TDatabase.NewEntityManager<TCliente>().Save(oCliente);
```

Inclui **IdentityMap** (evita duplicidade de carga) e **UnitOfWork** (agrupa alterações em transação).

### Módulo Parameters (`USE_PARAMENTERS`)

- API pública: `Parameters.Interfaces.pas` + `Parameters.pas` em `src/Main/`.
- Fontes de configuração:

| Fonte | Classe |
| --- | --- |
| Arquivo INI | `Parameters.Inifiles` |
| Objeto JSON | `Parameters.JsonObject` |
| Banco de dados | `Parameters.Database` |

### Módulo Loggers (`USE_LOGGERS`)

- API pública: `Loggers.Interfaces.pas` + `Loggers.pas` em `src/Main/`.
- Dez destinos disponíveis simultaneamente:

| Destino | Módulo |
| --- | --- |
| Banco de dados | `Loggers.Database` |
| CSV | `Loggers.CSV` |
| Arquivo texto | `Loggers.TextFiles` |
| XML | `Loggers.XML` |
| JSON | `Loggers.JsonObject` |
| HTTP/HTTPS | `Loggers.HTTPs` |
| E-mail | `Loggers.EMails` |
| WebSocket | `Loggers.WebSocket` |
| Log de eventos Windows | `Loggers.EventLogs` |
| Evento customizado | `Loggers.Events` |

### DDL / DML

Geração e execução de instruções DDL (CREATE, ALTER, DROP) e DML (SELECT, INSERT, UPDATE, DELETE) via camada de abstração do ORM, sem SQL literal obrigatório.

### Mapeamento por Atributos RTTI (`USE_ATTRIBUTES`)

Decoradores `[Table]` e `[Field]` sobre classes Pascal. `AttributeMapper` / `AttributeParser` processam via RTTI; `EntityRegistry` mantém registro centralizado das classes mapeadas.

### Exceções estruturadas

Hierarquia com código numérico por módulo, todas derivando de `EDatabaseException`:

| Faixa | Módulo |
| --- | --- |
| 10xxx | Commons |
| 20xxx | Fields |
| 30xxx | Tables |
| 40xxx | Connections |
| 50xxx | Parameters |
| 60xxx | Attributes |
| 70xxx | EntityManager |
| 80xxx | QueryBuilder |
| 90xxx | IdentityMap |
| 91xxx | UnitOfWork |
| 92xxx | TypeDatabase |
| 93xxx | Loggers |
| 94xxx | PoolConnections |

---

## Dialetos SQL e mapeamento de tipos por banco

> Referência rápida de diferenças de dialeto e mapeamento de tipos Delphi/FPC → SQL nativo, útil ao usar `IQueryBuilder`, `ITable.GetSQLCreateTable` e `ITypeDatabase`.

### Paginação por banco

| Banco | Sintaxe |
| --- | --- |
| PostgreSQL | `LIMIT 50 OFFSET 100` |
| MySQL | `LIMIT 50 OFFSET 100` |
| SQLite | `LIMIT 50 OFFSET 100` |
| Firebird (≤ 3) | `SELECT FIRST 50 SKIP 100 * FROM ...` |
| Firebird (4+) | `OFFSET 100 ROWS FETCH NEXT 50 ROWS` |
| SQL Server (2012+) | `OFFSET 100 ROWS FETCH NEXT 50 ROWS ONLY` |
| SQL Server (legado) | `SELECT TOP 50 ... WHERE id NOT IN (SELECT TOP 100 ...)` |
| Access | `SELECT TOP 50 ...` (sem OFFSET nativo) |

### Retorno de ID após INSERT

| Banco | Mecanismo |
| --- | --- |
| PostgreSQL | `INSERT ... RETURNING id` |
| Firebird | `INSERT ... RETURNING id` |
| SQL Server | `INSERT ... OUTPUT INSERTED.id` ou `SELECT SCOPE_IDENTITY()` |
| MySQL | `SELECT LAST_INSERT_ID()` após INSERT |
| SQLite | `SELECT last_insert_rowid()` após INSERT |
| Access | `SELECT @@IDENTITY` após INSERT |

### Quoting de identificadores

| Banco | Abre | Fecha | Exemplo |
| --- | --- | --- | --- |
| PostgreSQL | `"` | `"` | `"public"."clientes"` |
| Firebird | `"` | `"` | `"CLIENTES"` |
| SQLite | `"` | `"` | `"clientes"` |
| MySQL | `` ` `` | `` ` `` | `` `clientes` `` |
| SQL Server | `[` | `]` | `[dbo].[clientes]` |
| Access | `[` | `]` | `[clientes]` |

### Mapeamento de tipos Delphi/FPC → SQL por banco

| Tipo Delphi/FPC | PostgreSQL | MySQL | SQL Server | Firebird | SQLite | Access |
| --- | --- | --- | --- | --- | --- | --- |
| `Integer` | `INTEGER` | `INT` | `INT` | `INTEGER` | `INTEGER` | `LONG` |
| `Int64` | `BIGINT` | `BIGINT` | `BIGINT` | `BIGINT` | `INTEGER` | `LONG` |
| `string` | `VARCHAR(n)` / `TEXT` | `VARCHAR(n)` / `TEXT` | `NVARCHAR(n)` | `VARCHAR(n)` | `TEXT` | `TEXT(n)` / `MEMO` |
| `Boolean` | `BOOLEAN` | `TINYINT(1)` | `BIT` | `BOOLEAN` (FB3+) / `SMALLINT` | `INTEGER` (0/1) | `YESNO` |
| `TDateTime` | `TIMESTAMP` | `DATETIME` | `DATETIME2` | `TIMESTAMP` | `TEXT` (ISO 8601) | `DATETIME` |
| `TDate` | `DATE` | `DATE` | `DATE` | `DATE` | `TEXT` | `DATETIME` |
| `TTime` | `TIME` | `TIME` | `TIME` | `TIME` | `TEXT` | `DATETIME` |
| `Currency` | `NUMERIC(18,4)` | `DECIMAL(18,4)` | `DECIMAL(18,4)` | `NUMERIC(18,4)` | `REAL` | `CURRENCY` |
| `Double` | `DOUBLE PRECISION` | `DOUBLE` | `FLOAT` | `DOUBLE PRECISION` | `REAL` | `DOUBLE` |
| `TBytes` / `TStream` | `BYTEA` | `LONGBLOB` | `VARBINARY(MAX)` | `BLOB SUB_TYPE 0` | `BLOB` | `OLEOBJECT` |
| `TGUID` | `UUID` | `CHAR(36)` | `UNIQUEIDENTIFIER` | `CHAR(16) OCTETS` | `TEXT` (36 chars) | `TEXT(36)` |

### Concatenação de strings por banco

| Banco | Operador / Função |
| --- | --- |
| PostgreSQL | `nome \|\| ' - ' \|\| email` |
| Firebird | `nome \|\| ' - ' \|\| email` |
| SQLite | `nome \|\| ' - ' \|\| email` |
| MySQL | `CONCAT(nome, ' - ', email)` |
| SQL Server | `nome + ' - ' + email` ou `CONCAT(...)` (2012+) |
| Access | `nome & ' - ' & email` |

---

## Módulos e API pública

| Módulo | API pública (`src/Main/`) | Internas (`src/Modulos/`) |
| --- | --- | --- |
| ORM Database | `Providers.Database.*` | `src/Modulos/Database/` |
| Connection | `Providers.Connection.*` | `src/Modulos/Connections/` |
| Pool | `Providers.PoolConnections.*` | `src/Modulos/PoolConnections/` |
| Parameters | `Parameters.pas`, `Parameters.Interfaces.pas` | `src/Modulos/Parameters/` |
| Loggers | `Loggers.pas`, `Loggers.Interfaces.pas` | `src/Modulos/Loggers/` |
| Exceptions | `Exceptions.*` | `src/Modulos/Exceptions/`, `src/Commons/` |

---

## Formulários de teste (`src/Views/`)

| Form | Propósito |
| --- | --- |
| `ufrmConnectionTeste` | Testar conexão direta |
| `ufrmPoolConnectionsTeste` | Testar pool de conexões |
| `ufrmDatabaseTeste` | Operações CRUD |
| `ufrmDatabaseAttributersTeste` | Mapeamento por atributos |
| `ufrmEcossistemaTeste` | Teste integrado de todo o ecossistema |
| `ufrmParameters` | Configuração de parâmetros |
| `ufrmParametersAttributers` | Parâmetros via atributos |
| `ufrmExceptionsTeste` | Exceções e tratamento de erros |
| `ufrmLoggers` | Logging e destinos |

---

---

## Módulo Parameters

> Gerenciamento centralizado de parâmetros de configuração a partir de banco de dados, INI ou JSON.

---

### Parameters: O que é

O **módulo Parameters** é o subsistema responsável por **ler, gravar e sincronizar parâmetros de configuração** da aplicação a partir de três fontes distintas: banco de dados relacional, arquivo INI e objeto JSON. Todos os provedores compartilham o mesmo contrato de interface (CRUD + utilitários), permitindo trocar a fonte sem alterar o código de negócio.

O módulo é ativado pela diretiva `USE_PARAMENTERS` em `ORM.Defines.inc` e expõe sua API pública via `Parameters.pas` + `Parameters.Interfaces.pas` em `src/Main/`.

Cada parâmetro é representado por um `TParameter`, agrupado em `TParameterList`, e identificado pelo par **título** (grupo/seção) + **chave** (nome único).

---

### Parameters: Diretivas de compilação

| Diretiva | Efeito quando ativa |
| --- | --- |
| `USE_PARAMENTERS` | Ativa o módulo inteiro — inclui `Parameters.pas`, `Parameters.Interfaces.pas` e todos os provedores no build |
| `USE_ATTRIBUTES` | Inclui o sub-pacote `Attributes/` — habilita `IAttributeParser`, `IAttributeMapper` e decoradores `[Parameter]` |
| `USE_FIREDAC` | Engine de banco para `TParametersDatabase` (Delphi XE7+, não disponível no FPC) |
| `USE_UNIDAC` | Engine de banco para `TParametersDatabase` (Delphi e FPC) |
| `USE_ZEOS` | Engine de banco para `TParametersDatabase` (Delphi e FPC; padrão no FPC) |
| `USE_SQLDB` | Engine de banco para `TParametersDatabase` (somente FPC) |

> Sem `USE_PARAMENTERS`, o compilador ignora todos os arquivos do módulo. Defina a diretiva em `ORM.Defines.inc` ou nas opções do projeto.

---

### Parameters: Características

- **Três fontes intercambiáveis** — Database, IniFile e JsonObject implementam a mesma interface; a troca é transparente para o chamador.
- **API Fluente** — todos os setters retornam a própria interface para encadeamento: `TParametersDatabase.New.Host('localhost').Port(5432).Connect.List`.
- **Factory pattern** — `TParametersDatabase.New`, `TParametersInifiles.New`, `TParametersJsonObject.New`.
- **Thread-safe** — os três provedores usam `TCriticalSection` internamente.
- **Ordem gerenciada automaticamente** — inserção, atualização e reordenação automática de parâmetros por campo `ordem`.
- **Parâmetros ativos/inativos** — suporte a flag de ativação; no INI usa prefixo `#`; no JSON usa campo `"ativo"`.
- **Sincronização bidirecional** — `LoadFromDatabase` / `SaveToDatabase` entre as três fontes.
- **Auto-criação de estrutura** — `AutoCreateTable` (Database) e `AutoCreateFile` (INI/JSON) criam o armazenamento se não existir.
- **Suporte a ContratoID / ProdutoID** — isolamento de parâmetros por contrato e produto.
- **Mapeamento declarativo por atributos RTTI** — subpacote `Attributes` permite anotar classes Pascal com `[Parameter]`, `[ParameterKey]`, `[ParameterValue]` etc. para mapeamento automático.
- **Exportação para JSON** — todos os provedores expõem `ToJSON: TJSONObject`.
- **Compatibilidade Delphi / Free Pascal** — aliases de tipos JSON (TJSONValue, TJSONBool) abstraem diferenças entre compiladores.

---

### Parameters: Engines

#### Fontes de parâmetros

| Provedor | Interface | Classe | Fonte |
| --- | --- | --- | --- |
| Banco de dados | `IParametersDatabase` | `TParametersDatabase` | SQLite, PostgreSQL, MySQL, SQL Server, Firebird, Access |
| Arquivo INI | `IParametersInifiles` | `TParametersInifiles` | Arquivo `.ini` no sistema de arquivos |
| Objeto JSON | `IParametersJsonObject` | `TParametersJsonObject` | Arquivo `.json` ou `TJSONObject` em memória |

#### Engines de banco de dados suportados (provedor Database)

O `TParametersDatabase` detecta automaticamente o engine disponível na compilação e conecta ao banco de parâmetros. A prioridade de detecção é:

| Prioridade | Diretiva | Engine |
| --- | --- | --- |
| 1 | `USE_UNIDAC` | UniDAC (DevArt) |
| 2 | `USE_FIREDAC` | FireDAC (Embarcadero) |
| 3 | `USE_ZEOS` | ZeosLib (open-source) |
| 4 | `USE_SQLDB` | SQLdb (Free Pascal) |

#### Bancos de dados suportados pelo provedor Database

| Banco | Observação |
| --- | --- |
| SQLite | Padrão para config local (`Config.db`) |
| PostgreSQL | Produção multi-usuário |
| MySQL / MariaDB | — |
| SQL Server | — |
| Firebird / InterBase | — |
| Access | Via ADOX no Windows |

#### Formatos de config para `FromConfig`

O `TParametersDatabase` lê as credenciais de conexão automaticamente a partir de arquivos de configuração presentes em `Data/`:

| Arquivo | Formato | Seção / Objeto |
| --- | --- | --- |
| `Config.db` | SQLite | Tabela `parametros` |
| `config.ini` | INI | `[database]` |
| `config.json` | JSON | objeto `"database"` |
| `config1.json` | JSON | objeto `"database"` (alternativo) |

---

### Parameters: Funcionalidades

#### CRUD de parâmetros

Todos os provedores expõem o mesmo conjunto de operações:

| Método | Descrição |
| --- | --- |
| `List: TParameterList` | Retorna todos os parâmetros do título/seção corrente |
| `Getter(AName): TParameter` | Obtém um parâmetro pelo nome da chave |
| `Insert(AParameter)` | Insere novo parâmetro (reordena automaticamente) |
| `Setter(AParameter)` | Atualiza parâmetro existente |
| `Delete(AName)` | Remove parâmetro pelo nome |
| `Exists(AName): Boolean` | Verifica existência |
| `Count: Integer` | Contagem de parâmetros na fonte |

#### Configuração fluente (provedor Database)

```pascal
TParametersDatabase.New
  .Host('localhost').Port(5432)
  .Username('admin').Password('secret')
  .Database('config.db')
  .TableName('parametros')
  .AutoCreateTable(True)
  .ContratoID(1).ProdutoID(1)
  .Title('ERP')
  .Connect
  .List;
```

#### FromConfig — carregamento automático

```pascal
// Detecta automaticamente config.db / config.ini / config.json em Data/
TParametersDatabase.New.FromConfig.List;

// Caminho explícito
TParametersDatabase.New.FromConfig('Data/config.json').List;
```

#### Sincronização entre fontes

```pascal
// Exportar parâmetros do banco para INI
TParametersInifiles.New
  .FilePath('backup.ini')
  .LoadFromDatabase(oConnection, 'parametros', 1, 1, 'ERP');

// Importar INI de volta ao banco
TParametersDatabase.New.FromConfig
  .ImportFromIniFile('backup.ini');
```

#### Mapeamento por atributos RTTI (`USE_ATTRIBUTES`)

Permite mapear classes Pascal declarativamente, sem código imperativo de leitura:

```pascal
[Parameter('ERP')]
[ContratoID(1)]
[ProdutoID(1)]
TConfigERP = class
  [ParameterKey('database_host')]
  [ParameterValue('localhost')]
  FHost: string;

  [ParameterKey('database_port')]
  [ParameterValue(5432)]
  [ParameterRequired]
  FPort: Integer;
end;
```

**`IAttributeParser`** — extrai metadados via RTTI:

- `ParseClass(AClassType)` → `TParameterList`
- `GetClassTitle`, `GetClassContratoID`, `GetClassProdutoID`, `GetClassSource`
- `IsPropertyRequired`, `GetPropertyKey`, `GetPropertyDefaultValue`

**`IAttributeMapper`** — mapeamento bidirecional:

- `MapClassToParameters(AInstance)` → `TParameterList` com valores atuais
- `MapParametersToClass(AParameters, AInstance)` → preenche propriedades do objeto
- `SetParameterValue` / `GetParameterValue` — acesso direto por chave

**Aliases em português:**

| Atributo (EN) | Alias (PT) |
| --- | --- |
| `ParameterAttribute` | `Parametro` |
| `ParameterKeyAttribute` | `ChaveParametro` |
| `ParameterValueAttribute` | `ValorParametro` |
| `ParameterDescriptionAttribute` | `DescricaoParametro` |
| `ParameterTypeAttribute` | `TipoParametro` |
| `ParameterOrderAttribute` | `OrdemParametro` |
| `ParameterRequiredAttribute` | `ParametroObrigatorio` |

#### Tipos de valor suportados (`TParameterValueType`)

| Tipo | Constante |
| --- | --- |
| String | `pvtString` |
| Inteiro | `pvtInteger` |
| Float | `pvtFloat` |
| Booleano | `pvtBoolean` |
| Data/Hora | `pvtDateTime` |
| JSON | `pvtJSON` |

#### Fontes de parâmetro (`TParameterSource`)

| Fonte | Constante |
| --- | --- |
| Banco de dados | `psDatabase` |
| Arquivo INI | `psInifiles` |
| Objeto JSON | `psJsonObject` |

#### Exceções do módulo Parameters

| Código | Exceção |
| --- | --- |
| 50xxx | `EParametersConfigurationException` (base) |
| 1900–1910 | `EParametersAttributeException` (atributos RTTI) |

Códigos de atributos:

| Código | Descrição |
| --- | --- |
| 1901 | Parâmetro não encontrado |
| 1902 | Chave não encontrada |
| 1903 | Classe inválida |
| 1904 | RTTI não disponível |
| 1905 | Propriedade inválida |
| 1906 | Parâmetro obrigatório ausente |
| 1907 | Falha no parsing |
| 1908 | Falha no mapeamento |
| 1909 | Falha na validação |
| 1910 | Falha na conversão de valor |

#### Gerenciamento de tabela (provedor Database)

| Método | Descrição |
| --- | --- |
| `TableExists: Boolean` | Verifica existência da tabela |
| `CreateTable` | Cria tabela de parâmetros |
| `DropTable` | Remove tabela |
| `MigrateTable` | Migra estrutura |
| `ListAvailableDatabases` | Lista bancos disponíveis |
| `ListAvailableTables` | Lista tabelas do banco |

---

---

## Módulo Loggers

> Sistema de logging multi-destino com suporte a banco de dados, arquivo, HTTP, e-mail, WebSocket, XML, JSON, CSV e Event Log do Windows.

---

### Loggers: O que é

O **módulo Loggers** é o subsistema de registro de eventos do ProvidersORM. Permite gravar entradas de log simultaneamente em **até 10 destinos distintos** com API unificada, configuração fluente e suporte completo a Delphi e Free Pascal.

O módulo é ativado pela diretiva `USE_LOGGERS` em `ORM.Defines.inc` e expõe sua API pública via `Loggers.pas` + `Loggers.Interfaces.pas` em `src/Main/`.

Cada entrada de log é representada por um `TLogEntry` e identificada por nível (`TLogLevel`), categoria, timestamp e dados de contexto opcionais.

---

### Loggers: Diretivas de compilação

| Diretiva | Escopo | Efeito quando ativa |
| --- | --- | --- |
| `USE_LOGGERS` | Módulo inteiro | Inclui `Loggers.pas`, `Loggers.Interfaces.pas` e todos os provedores de destino no build |
| `USE_ATTRIBUTES` | Sub-pacote `Attributes/` | Habilita decoradores `[Logger]`, `[LoggerLevel]`, `[LoggerDestinations]` etc. |
| `USE_INDY` | HTTP / E-mail / WebSocket | Indy como engine de rede (padrão; ativa `USE_EMAIL_INDY`, `USE_HTTP_INDY`, `USE_WEBSOCKET_INDY`) |
| `USE_ICS` | HTTP / E-mail / WebSocket | Internet Component Suite como engine de rede |
| `USE_IPWORKS` | HTTP / E-mail / WebSocket | IPWorks 2024 (nSoftware, comercial) como engine de rede |
| `USE_SYNAPSE` | HTTP / E-mail | Synapse como engine HTTP e SMTP |
| `USE_SYNAPSE_WS` | WebSocket | Synapse WebSocket |
| `USE_TMS_WEBSOCKET` | WebSocket | TMS FNC WebSocket (comercial) |
| `USE_HORSE` | WebSocket | Horse SocketIO |
| `USE_BIRD_SOCKET` | WebSocket | BirdSocket Server |
| `USE_FIREDAC` | Provedor Database | Engine FireDAC para `TLoggerDatabase` |
| `USE_UNIDAC` | Provedor Database | Engine UniDAC para `TLoggerDatabase` |
| `USE_ZEOS` | Provedor Database | Engine ZeosLib para `TLoggerDatabase` |
| `USE_SQLDB` | Provedor Database | Engine SQLdb para `TLoggerDatabase` (FPC) |

> Sem `USE_LOGGERS`, o compilador ignora todos os arquivos do módulo. Múltiplos engines de rede podem coexistir; a prioridade de seleção é: Indy → ICS → IPWorks → Synapse.

---

### Loggers: Características

- **10 destinos simultâneos** — Database, CSV, TextFiles, XML, JSON, HTTP/HTTPS, E-mail, WebSocket, EventLog Windows e Eventos customizados.
- **5 níveis de log** — Debug → Info → Warn → Error → Fatal, com filtragem por nível mínimo.
- **4 formatos de saída** — Texto, JSON, XML e CSV.
- **3 modos de escrita** — Síncrono, assíncrono e buffered (com flush configurável).
- **API Fluente** — todos os setters retornam a própria interface; builder de entrada via `ILogEntryBuilder.Category().Level().Message().Save()`.
- **Factory pattern** — `TLoggerDatabase.New`, `TLoggerCSV.New`, `TLoggerHTTP.New` etc.
- **Thread-safe** — críticos internos em todos os provedores.
- **Rotação de arquivos** — por tamanho, data, semanal, mensal ou combinado (TextFiles).
- **Agregação de e-mails** — acumula entradas antes de enviar, configurável por contagem, intervalo ou nível mínimo.
- **Retry HTTP** — estratégia fixa, linear ou exponencial com códigos de status configuráveis.
- **Fallback HTTP** — URL alternativa em caso de falha ou timeout.
- **Mapeamento declarativo por atributos RTTI** — subpacote `Attributes` com `[Logger]`, `[LoggerKey]`, `[LoggerLevel]`, `[LoggerDestinations]` etc.
- **Sistema de eventos** — `ILoggerEventManager` com handlers para `OnBeforeWrite`, `OnAfterWrite`, `OnError`, `OnFlush`, `OnClear`, `OnLevelCheck` etc.
- **Auto-criação de estrutura** — `AutoCreateTable` (Database) e auto-criação de diretórios (arquivo).
- **Exportação via JSON** — `ToJSON` / `ReadArray` disponíveis em provedores de arquivo.
- **Compatibilidade Delphi / FPC** — aliases de tipos JSON abstraem diferenças entre compiladores.

---

### Loggers: Engines

#### Destinos e interfaces

| Destino | Interface | Subfolder | Disponível em |
| --- | --- | --- | --- |
| Banco de dados | `ILoggerDatabase` | `Databases/` | Delphi + FPC |
| CSV | `ILoggerCSV` | `CSV/` | Delphi + FPC |
| Arquivo texto | `ILoggerTextFiles` | `TextFiles/` | Delphi + FPC |
| XML | `ILoggerXML` | `XML/` | Delphi + FPC |
| JSON | `ILoggerJSONObject` | `JsonObject/` | Delphi + FPC |
| HTTP/HTTPS | `ILoggerHTTP` | `Https/` | Delphi + FPC |
| E-mail (SMTP) | `ILoggerEmail` | `Emails/` | Delphi + FPC |
| WebSocket | `ILoggerWebSocket` | `WebSocket/` | Delphi + FPC |
| Event Log Windows | `ILoggerEventLog` | `EventLogs/` | Windows only |
| Eventos customizados | `ILoggerEventManager` | `Events/` | Delphi + FPC |

#### Engines de banco de dados (provedor Database)

| Diretiva | Engine |
| --- | --- |
| `USE_UNIDAC` | UniDAC (DevArt) |
| `USE_FIREDAC` | FireDAC (Embarcadero) |
| `USE_ZEOS` | ZeosLib (open-source) |

Bancos suportados: PostgreSQL, MySQL, SQL Server, SQLite, Firebird, Access, ODBC, LDAP.

#### Engines HTTP

| Engine | Arquivo |
| --- | --- |
| Indy | `Loggers.HTTPs.Engines.Indy.pas` |
| Synapse | `Loggers.HTTPs.Engines.Synapse.pas` |
| Factory (auto) | `Loggers.HTTPs.Engines.Factory.pas` |

#### Engines de e-mail (SMTP)

| Engine | Arquivo |
| --- | --- |
| Indy | `Loggers.EMails.Engines.Indy.pas` |
| Synapse | `Loggers.EMails.Engines.Synapse.pas` |

Servidores SMTP pré-configurados: Gmail, Outlook, Yahoo, SendGrid, AWS SES.

#### Engines WebSocket

| Constante | Engine |
| --- | --- |
| `wseIndy` | Indy |
| `wseSynapse` | Synapse |
| `wseSynapseWS` | Synapse WebSocket |
| `wseBirdSocket` | BirdSocket |
| `wseICS` | ICS |
| `wseIPWorks` | IPWorks |
| `wseTMSFNC` | TMS FNC |
| `wseHorseSocketIO` | Horse Socket.io |

#### Autenticações HTTP suportadas

`None` · `Basic` · `Bearer Token` · `API Key` · `OAuth 2.0` · `Digest`

#### Autenticações SMTP suportadas

`None` · `LOGIN` · `PLAIN` · `CRAM-MD5` · `NTLM` · `OAuth 2.0`

#### Segurança SMTP

`None` · `TLS/STARTTLS` · `SSL/TLS direto` · `Auto-detect`

---

### Loggers: Funcionalidades

#### Níveis de log (`TLogLevel`)

| Nível | Constante | Uso |
| --- | --- | --- |
| 1 — Debug | `llDebug` | Diagnóstico detalhado |
| 2 — Info | `llInfo` | Operação normal |
| 3 — Warn | `llWarn` | Situação potencialmente problemática |
| 4 — Error | `llError` | Erro que impede uma operação |
| 5 — Fatal | `llFatal` | Erro crítico, pode encerrar a aplicação |

#### Formatos de saída (`TLogFormat`)

| Formato | Constante |
| --- | --- |
| Texto | `lfText` |
| JSON | `lfJSON` |
| XML | `lfXML` |
| CSV | `lfCSV` |

#### Modos de escrita (`TLogWriteMode`)

| Modo | Constante | Comportamento |
| --- | --- | --- |
| Síncrono | `lwmSync` | Bloqueante — espera confirmação |
| Assíncrono | `lwmAsync` | Não-bloqueante — fire and forget |
| Buffered | `lwmBuffered` | Acumula e envia em lote no flush |

#### Estrutura do registro (`TLogEntry`)

Campo: timestamp, level, category, message, exception, threadID, processID, context, data, metadata.

#### Configuração fluente — provedor Database

```pascal
TLoggerDatabase.New
  .Host('localhost').Port(5432)
  .Username('admin').Password('secret')
  .Database('logs.db')
  .TableName('app_logs')
  .DatabaseType('SQLite')
  .AutoCreateTable(True)
  .Log(llInfo, 'Aplicação iniciada').Category('startup').Save;
```

#### Configuração fluente — provedor HTTP

```pascal
TLoggerHTTP.New
  .BaseURL('https://logs.example.com')
  .Endpoint('/api/logs')
  .Method(lhmPOST)
  .ContentType(lhctJSON)
  .AuthType(lhatBearer).AuthToken('meu-token')
  .RetryStrategy(lhrsExponential).RetryMaxRetries(3).RetryEnabled(True)
  .FallbackEnabled(True).FallbackURL('https://backup.example.com')
  .SendLog(oEntry);
```

#### Configuração fluente — provedor E-mail

```pascal
TLoggerEmail.New
  .SMTPHost('smtp.gmail.com').SMTPPort(587)
  .SMTPUsername('user@gmail.com').SMTPPassword('senha')
  .SMTPSecurity(lesTLS)
  .FromAddress('app@empresa.com')
  .AddToAddress('ops@empresa.com')
  .Subject('[ERRO] Falha na aplicação')
  .AggregationStrategy(leasCountTime)
  .AggregationMaxCount(10)
  .AggregationEnabled(True)
  .SendLog(oEntry);
```

#### Configuração fluente — provedor CSV

```pascal
TLoggerCSV.New
  .FilePath('logs/app.csv')
  .Delimiter(lcdSemicolon)
  .HeaderStrategy(lchsFirstLine)
  .AutoFlush(True)
  .Encoding('UTF-8')
  .WriteLog(oEntry);
```

#### Configuração fluente — provedor EventLog (Windows)

```pascal
TLoggerEventLog.New
  .SourceName('MinhaAplicacao')
  .LogName('Application')
  .AutoCreateSource(True)
  .MappingStrategy(lelmsDirect)
  .ErrorEventType(leltError).ErrorEventID(1003)
  .FatalEventType(leltError).FatalEventID(1004)
  .WriteLog(oEntry);
```

#### Sistema de eventos (`ILoggerEventManager`)

Permite interceptar o ciclo de vida de cada log sem modificar os provedores:

| Evento | Quando é disparado |
| --- | --- |
| `OnBeforeWrite` | Antes de gravar — pode cancelar (`ACancel := True`) |
| `OnAfterWrite` | Após gravar — recebe flag de sucesso |
| `OnError` | Em caso de falha — pode marcar como tratado |
| `OnFlush` | Ao esvaziar buffer |
| `OnClear` | Ao limpar todos os registros |
| `OnConfigChanged` | Quando um campo de configuração muda |
| `OnLevelCheck` | Na verificação de nível — pode forçar `ShouldLog` |
| `OnLoggerCreated` | Ao criar um logger |
| `OnLoggerDestroyed` | Ao destruir um logger |

Registros retornam `ILoggerEventSubscription` com `Unsubscribe()` para cancelamento.

#### Loggers: Mapeamento por atributos RTTI (`USE_ATTRIBUTES`)

```pascal
[Logger('Autenticacao')]
[LoggerLevel(llWarn)]
[LoggerDestinations([ldDatabase, ldEmail])]
TLogAutenticacao = class
  [LoggerKey('smtp_host')]
  [LoggerValue('smtp.gmail.com')]
  FSMTPHost: string;

  [LoggerKey('min_level')]
  [LoggerRequired]
  FMinLevel: string;
end;
```

**Aliases em português:**

| Atributo (EN) | Alias (PT) |
| --- | --- |
| `LoggerAttribute` | `Logger` |
| `LoggerLevelAttribute` | `NivelLogger` |
| `LoggerCategoryAttribute` | `CategoriaLogger` |
| `LoggerFormatAttribute` | `FormatoLogger` |
| `LoggerDestinationsAttribute` | `DestinosLogger` |
| `LoggerKeyAttribute` | `ChaveLogger` |
| `LoggerValueAttribute` | `ValorLogger` |
| `LoggerDescriptionAttribute` | `DescricaoLogger` |
| `LoggerRequiredAttribute` | `LoggerObrigatorio` |

#### Rotação de arquivos (`TLogRotationStrategy`)

| Estratégia | Constante |
| --- | --- |
| Sem rotação | `lrsNone` |
| Por tamanho | `lrsSize` |
| Por data | `lrsDate` |
| Semanal | `lrsWeekly` |
| Mensal | `lrsMonthly` |
| Tamanho + data | `lrsSizeDate` |

#### Exceções do módulo Loggers

Hierarquia base: `ELoggersException` (ErrorCode + Operation).

| Faixa | Classe | Categoria |
| --- | --- | --- |
| 1000–1099 | `ELoggersConnectionException` | Conexão |
| 1100–1199 | `ELoggersSQLException` | SQL (27 códigos) |
| 1200–1299 | `ELoggersValidationException` | Validação |
| 1300–1399 | `ELoggersNotFoundException` | Operação |
| 1400–1499 | `ELoggersConfigurationException` | Configuração |
| 1500–1599 | `ELoggersFileException` | Arquivo / I/O |
| 1600–1699 | `ELoggersIniFileException` | INI |
| 1700–1799 | `ELoggersJsonObjectException` | JSON |
| 1800–1899 | — | Import / Export |

Função auxiliar `ConvertToLoggersException()` converte `Exception` genérica para o subtipo correto.

---

---

## Módulo Connections

> Abstração de conexão individual com banco de dados — configuração fluente, multi-engine, metadados e integração com ecossistema.

---

### Connections: O que é

O **módulo Connections** fornece a abstração `IConnection` / `TConnection`, que representa **uma conexão ativa com um banco de dados relacional**. É a unidade fundamental de acesso ao banco no ProvidersORM: recebe configuração por API fluente ou a partir de arquivo (INI, JSON) e expõe execução de SQL, controle de transações e consulta de metadados.

Opera no **modo ORM**: `TConnection` é totalmente independente de `TTables`, sem herança entre os dois. O `TPoolConnections` armazena um container de `IConnection` para reaproveitamento.

Fonte pública: `Providers.Connection.Interfaces.pas` + `Providers.Connection.pas` em `src/Modulos/Connections/`.

---

### Connections: Diretivas de compilação

O módulo Connections **não possui diretiva de ativação própria** — é compilado sempre que o projeto referencia `Providers.Connection.pas`. As diretivas controlam o engine ativo e funcionalidades opcionais:

| Diretiva | Efeito quando ativa |
| --- | --- |
| `USE_FIREDAC` | FireDAC como driver de banco (Delphi XE7+; indisponível no FPC) |
| `USE_UNIDAC` | UniDAC como driver de banco (Delphi e FPC) |
| `USE_ZEOS` | ZeosLib como driver de banco (Delphi e FPC; padrão automático no FPC) |
| `USE_SQLDB` | SQLdb como driver de banco (somente FPC) |
| `USE_ATTRIBUTES` | Habilita `TConnection.FromClass(TClass)` — carrega configuração de conexão via atributos RTTI na classe |

> Apenas **um engine** é compilado por build. A seleção é feita em `ORM.Defines.inc`; conflito entre múltiplos `USE_*` ativa resolução automática por prioridade (UniDAC → FireDAC → Zeos → SQLdb).

---

### Connections: Características

- **API Fluente completa** — cada método setter retorna `IConnection` para encadeamento: `TConnection.New.Host(...).Port(...).Connect`.
- **Factory pattern** — `TConnection.New: IConnection` como único ponto de entrada.
- **Multi-engine** — suporte a UniDAC, FireDAC, Zeos e SQLdb via diretivas de compilação; apenas um engine ativo por build.
- **Carregamento de configuração** — `FromConfig` (auto-detecta `config.db/ini/json`), `FromIniFile`, `FromJSON` (string) e `FromClass` (atributos RTTI, `USE_ATTRIBUTES`).
- **Validação de DLL** — `IsRequiredDllFound` verifica a DLL do driver antes de `Connect`; disponível como método de instância e método de classe (sem instância).
- **Gerenciamento de transações** — `BeginTransaction`, `Commit`, `Rollback`, `InTransaction`.
- **Eventos de ciclo de vida** — `OnBeforeConnect`, `OnAfterConnect`, `OnBeforeDisconnect`, `OnAfterDisconnect`, `OnConnectionError`.
- **Integração com ecossistema** — injeção opcional de `IExceptions` (`SetExceptions`) e `ILogger` (`SetLogger`); erros de conexão são logados automaticamente.
- **Metadados completos** — listagem de bancos, schemas, tabelas (por schema) e colunas; DDL reverso via `GetTableStructure`.
- **Compatibilidade Delphi / FPC** — condicionais em todas as uses e seções de código; suporte a Access via ADOX (Jet 32-bit / ACE 64-bit, Windows).

---

### Connections: Engines

#### Engines de banco de dados suportados (um por build)

| Diretiva | Engine | Delphi | FPC |
| --- | --- | --- | --- |
| `USE_UNIDAC` | UniDAC (DevArt) | Sim | Sim |
| `USE_FIREDAC` | FireDAC (Embarcadero) | Sim | Não |
| `USE_ZEOS` | ZeosLib (open-source) | Sim | Sim |
| `USE_SQLDB` | SQLdb (Free Pascal) | Não | Sim |

#### Bancos suportados por engine

| Banco | UniDAC | FireDAC | Zeos | SQLdb |
| --- | --- | --- | --- | --- |
| PostgreSQL | Sim | Sim | Sim | Sim |
| MySQL | Sim | Sim | Sim | Sim |
| SQL Server | Sim | Sim | — | Sim |
| SQLite | Sim | Sim | Sim | Sim |
| Firebird / InterBase | Sim | Sim | Sim | Sim |
| Access (.mdb/.accdb) | Sim | Sim | Sim (OLEDB) | — |

> Access via Zeos usa connectionstring OLEDB: Jet 4.0 (32-bit / `.mdb`) ou ACE 12.0 (64-bit / `.accdb`).

#### Fontes de configuração de conexão

| Método | Fonte |
| --- | --- |
| `FromConfig` | Auto-detecta `Data/config.db`, `config.ini` ou `config.json` |
| `FromIniFile(path, section)` | Arquivo INI — campos: host, port, username, password, database, schema, database_type, database_dll |
| `FromJSON(jsonString)` | String JSON em memória com os mesmos campos |
| `FromClass(TClass)` | Atributos RTTI `[Connection]` na classe (`USE_ATTRIBUTES`) |

---

### Connections: Funcionalidades

#### Configuração fluente

```pascal
TConnection.New
  .Engine(TDatabaseEngine.deZeos)
  .DatabaseType(TDatabaseTypes.dtPostgreSQL)
  .Host('localhost').Port(5432)
  .Username('postgres').Password('secret')
  .Database('mydb').Schema('public')
  .DllBasePath('C:\ORM\dll')
  .Connect;
```

#### Carregamento automático de configuração

```pascal
// Auto-detecta Data/config.db → Data/config.ini → Data/config.json
TConnection.New.FromConfig.Connect;

// A partir de INI
TConnection.New.FromIniFile('Data/config.ini', 'database').Connect;

// A partir de JSON string
TConnection.New.FromJSON('{"host":"localhost","port":5432,...}').Connect;
```

#### Execução de SQL

| Método | Retorno | Uso |
| --- | --- | --- |
| `ExecuteQuery(SQL)` | `TDataSet` | SELECT — retorna conjunto de linhas |
| `ExecuteCommand(SQL)` | `Integer` | INSERT / UPDATE / DELETE — retorna linhas afetadas |
| `ExecuteScalar(SQL)` | `Variant` | SELECT de valor único (COUNT, MAX, etc.) |

#### Controle de transações

```pascal
oConn.BeginTransaction;
try
  oConn.ExecuteCommand('INSERT INTO ...');
  oConn.ExecuteCommand('UPDATE ...');
  oConn.Commit;
except
  oConn.Rollback;
  raise;
end;
```

| Método | Descrição |
| --- | --- |
| `BeginTransaction` | Inicia transação explícita |
| `Commit` | Confirma e encerra transação |
| `Rollback` | Desfaz e encerra transação |
| `InTransaction: Boolean` | Verifica se há transação ativa |

#### Metadados

| Método | Descrição |
| --- | --- |
| `GetDatabaseNames: TStringArray` | Lista bancos disponíveis no servidor |
| `GetSchemaNames(ADatabase)` | Lista schemas do banco (PostgreSQL, SQL Server) |
| `GetTableNames(ASchema)` | Lista tabelas (filtro por schema opcional) |
| `GetColumnNames(ATable, ASchema)` | Lista colunas de uma tabela |
| `GetTableStructure(ATable, ASchema)` | Retorna `TArray<TDatabaseFields>` com tipo, PK, FK, regras ON UPDATE/DELETE |
| `GetServerVersion: string` | Versão do servidor de banco |
| `GetClientVersion: string` | Versão do driver/client |
| `GetConnectionData: TConnectionData` | Snapshot dos dados de configuração |

> `GetTableStructure` preenche `ConstraintName`, `ReferencedTable`, `ReferencedColumn`, `OnUpdateRule` e `OnDeleteRule` para PostgreSQL, MySQL, SQL Server, SQLite e Firebird.

#### Validação de DLL

```pascal
// Na instância (usa configuração corrente)
if not oConn.IsRequiredDllFound then
  raise Exception.Create('DLL do driver não encontrada');

// Sem instância
if not TConnection.IsRequiredDllFound('C:\dll', TDatabaseTypes.dtPostgreSQL) then
  ShowMessage('libpq.dll ausente');

// Versão por string
if not TConnection.IsRequiredDllFound('C:\dll', 'PostgreSQL') then ...
```

#### Eventos de ciclo de vida

| Evento | Assinatura | Quando é disparado |
| --- | --- | --- |
| `OnBeforeConnect` | `TNotifyEvent` | Antes de abrir conexão |
| `OnAfterConnect` | `TNotifyEvent` | Após conexão bem-sucedida |
| `OnBeforeDisconnect` | `TNotifyEvent` | Antes de fechar conexão |
| `OnAfterDisconnect` | `TNotifyEvent` | Após conexão fechada |
| `OnConnectionError` | `TConnectionErrorEvent` | Exceção durante `Connect` — recebe `Sender` e `E: Exception` |

#### Integração com ecossistema

```pascal
TConnection.New
  .SetExceptions(oExceptions)  // IExceptions — erros são encaminhados
  .SetLogger(oLogger)           // ILogger — log de erro em Connect
  .FromConfig
  .Connect;
```

#### Verificação de conexão

| Método | Descrição |
| --- | --- |
| `IsConnected: Boolean` | Estado atual da conexão (campo interno) |
| `Ping: Boolean` | Envia round-trip ao servidor para confirmar conectividade |

#### Exceções do módulo Connections

Faixa de código **40xxx** (`EDatabaseException` → `EConnectionException` e derivadas).

---

---

## Módulo Database

> Núcleo ORM — hierarquia Field → Fields → Table → Tables → Schema → Schemas com geração de SQL, EntityManager, QueryBuilder, IdentityMap e UnitOfWork.

---

### Database: O que é

O **módulo Database** é o coração do ProvidersORM. Mapeia a estrutura relacional em objetos Pascal e gera SQL (DDL + DML) de forma automática, com suporte a schema, FK rules e sintaxe específica por banco.

A hierarquia completa é:

```text
IField → IFields → ITable → ITables → ISchema → ISchemas
```

Sobre ela, camadas opcionais ativáveis por diretiva completam o ORM:

| Componente | Diretiva | Padrão |
| --- | --- | --- |
| `ITypeDatabase` | `USE_TYPEDATABASE` | Sempre disponível |
| `IQueryBuilder` | `USE_QUERY_BUILDER` | Fowler Query Object |
| `IEntityManager` | `USE_ENTITY_MANAGER` | Repository + Active Record híbrido |
| `IIdentityMap<T>` | `USE_ENTITY_MANAGER` | Fowler Identity Map |
| `IUnitOfWork` | `USE_ENTITY_MANAGER` | Fowler Unit of Work |

Fonte pública: `Providers.Database.*` em `src/Modulos/Database/`.

---

### Database: Diretivas de compilação

O núcleo do módulo (Field, Fields, Table, Tables, Schema, Schemas, TypeDatabase) é compilado **sem diretiva de ativação**. As camadas opcionais são controladas individualmente:

| Diretiva | Componente ativado | Efeito |
| --- | --- | --- |
| `USE_QUERY_BUILDER` | `IQueryBuilder` / `TQueryBuilder` | Inclui o Query Builder fluente no build |
| `USE_ENTITY_MANAGER` | `IEntityManager`, `IIdentityMap`, `IUnitOfWork` | Inclui Entity Manager, Identity Map e Unit of Work (requer `USE_ATTRIBUTES`) |
| `USE_ATTRIBUTES` | `Attributers/` + `FromClass` | Habilita decoradores `[Table]`, `[Field]`; obrigatório para `USE_ENTITY_MANAGER` |
| `USE_FIREDAC` | Execução de SQL | FireDAC como engine para `ExecuteQuery`, `ExecuteCommand` etc. |
| `USE_UNIDAC` | Execução de SQL | UniDAC como engine |
| `USE_ZEOS` | Execução de SQL | ZeosLib como engine |
| `USE_SQLDB` | Execução de SQL | SQLdb como engine (FPC) |

> Se `USE_ENTITY_MANAGER` for definido sem `USE_ATTRIBUTES`, o compilador emite `WARN` e desativa `USE_ENTITY_MANAGER` automaticamente (ver `ORM.Defines.inc`).

---

### Database: Características

- **Hierarquia completa** — `IField → IFields → ITable → ITables → ISchema → ISchemas` com herança de interface (`ITable extends IFields`, `ISchema extends ITables`).
- **API Fluente** — todos os setters retornam a própria interface; métodos `New` como factory.
- **Geração de SQL automática** — INSERT, UPDATE, DELETE, CREATE TABLE e DROP TABLE gerados a partir dos metadados dos campos, sem SQL literal.
- **Versões otimizadas de DML** — `GenerateInsertSQLOptimized` omite campos NULL opcionais; `GenerateUpdateSQLOptimized` omite campos não modificados.
- **DDL multi-banco** — `GetSQLCreateTable` e `GetSQLDropTable` adaptam sintaxe, quoting de identificadores e cláusulas `IF EXISTS` para cada banco.
- **FK rules por campo** — `ConstraintName`, `ReferencedTable`, `ReferencedColumn`, `OnUpdateRule`, `OnDeleteRule` gerados no DDL com sintaxe correta por banco.
- **Audit fields** — campos `date_created`, `date_updated`, `is_deleted`, `is_active` configuráveis por tabela.
- **Change tracking** — `IsChanged`, `HasChanges`, `GetAllChangedFieldNames`, `ClearAllChanges`.
- **Metadados via conexão** — `GetTableNames`, `GetDatabaseNames`, `GetSchemaNames`, `GetColumnNames`, `GetTableStructure` delegados ao `IConnection`.
- **Progress callbacks** — `TOnLoadTablesProgress` e `TOnLoadFieldsProgress` para feedback em UI durante carregamento.
- **Serialização JSON** — `ToJSON` / `FromJSON` / `LoadFromJSON` em todos os níveis (IField, IFields, ITable, ITables).
- **QueryBuilder database-aware** — quoting e schema diferenciados por banco; multi-condição WHERE (AND), LIMIT / TOP automático.
- **EntityManager com cache** — `Find()` usa `TDictionary<string, ITable>` internamente.
- **UnitOfWork transacional** — `Commit` executa INSERT/UPDATE/DELETE em uma única transação; exceção dispara `Rollback` automático.
- **IdentityMap genérico** — `IIdentityMap<T: class>` previne duplicidade de instâncias para o mesmo ID.
- **TypeDatabase** — abstrai schema-support, quoting de identificadores e comportamento file-based por banco.

---

### Database: Engines

O módulo Database em si é **agnóstico de engine** — usa `IConnection` para executar SQL. A engine de banco ativa é selecionada em `ORM.Defines.inc` (veja seção **Engines** do documento principal).

#### Suporte a schemas por banco (`ITypeDatabase.SupportsSchema`)

| Banco | Suporta Schema |
| --- | --- |
| PostgreSQL | Sim |
| SQL Server | Sim |
| MySQL | Não |
| SQLite | Não |
| Firebird | Não |
| Access | Não |

#### Quoting de identificadores por banco

| Banco | Abre | Fecha |
| --- | --- | --- |
| PostgreSQL | `"` | `"` |
| Firebird | `"` | `"` |
| SQLite | `"` | `"` |
| MySQL | `` ` `` | `` ` `` |
| SQL Server | `[` | `]` |
| Access | `[` | `]` |

#### Bancos file-based (`TDatabaseTypeIsFileBased`)

SQLite e Access são file-based — influenciam criação de arquivo e caminho de DLL.

#### Tipos de variável Pascal → SQL (`TDatabaseVariableType`)

| Constante | Mapeamento |
| --- | --- |
| `ptNumericInteger` | INTEGER / BIGINT |
| `ptNumericFloat` | FLOAT / DOUBLE / NUMERIC |
| `ptCharacterString` | VARCHAR |
| `ptCharacterText` | TEXT / CLOB |
| `ptCharacterChar` | CHAR |
| `ptDatetime` | TIMESTAMP / DATETIME |
| `ptDatetimeTime` | TIME |
| `ptDatetimeDate` | DATE |
| `ptBoolean` | BOOLEAN |
| `ptBooleanInteger` | INTEGER (0/1) |

---

### Database: Funcionalidades

#### Hierarquia de objetos

```text
IField        — coluna: nome, tipo, nullable, PK, FK rules, valor, change-tracking
IFields       — container de IField: add/remove/find/HasChanges/GetPrimaryKey
ITable        — tabela: nome, alias, DML/DDL, audit fields  (extends IFields)
ITables       — container de ITable: load da conexão, callbacks de progresso
ISchema       — schema: nome + database (extends ITables)
ISchemas      — container de ISchema: load de schemas da conexão
```

#### IField — coluna

| Grupo | Métodos |
| --- | --- |
| Metadados | `Column`, `ColumnType`, `ColumnTypeCode`, `IsNull`, `IsPKey`, `Position` |
| FK | `ConstraintName`, `ReferencedTable`, `ReferencedColumn`, `OnUpdateRule`, `OnDeleteRule` |
| Valor | `Value`, `ToDefault`, `SetColumnValue`, `SetColumnValueWithoutChange` |
| Estado | `IsChanged`, `MarkChanged`, `MarkUnchanged`, `SetAsChanged`, `SetAsUnchanged` |
| Helpers | `IsFieldChanged`, `IsFieldPrimaryKey`, `FieldAllowsNull` |
| Serialização | `ToJSON`, `LoadFromJSON`, `Clone` |

#### IFields — container de campos

```pascal
TFields.New
  .DatabaseTypes(dtPostgreSQL)
  .AddField(TField.New.Column('id').ColumnType('INTEGER').IsPKey(True).IsNull(False))
  .AddField('nome', 'VARCHAR(100)', False)
  .AddField('email', 'VARCHAR(200)', True);
```

#### ITable — tabela com DML e DDL

```pascal
// Configuração
LTable := TTable.New
  .TableName('usuarios')
  .DatabaseTypes(dtPostgreSQL)
  .AuditFields(True)
  .FieldDateCreated('criado_em')
  .FieldDateUpdated('atualizado_em');

// Geração de DDL
LTable.GetSQLCreateTable('public');   // CREATE TABLE "public"."usuarios" (...)
LTable.GetSQLDropTable('public');     // DROP TABLE IF EXISTS "public"."usuarios"

// Execução de DDL
LTable.CreateTable(oConnection);
LTable.DropTable(oConnection);

// Geração de DML
LTable.GenerateInsertSQL;             // INSERT INTO "usuarios" (campos) VALUES (valores)
LTable.GenerateInsertSQLOptimized;    // omite campos NULL opcionais
LTable.GenerateUpdateSQL;             // UPDATE "usuarios" SET ... WHERE pk = ...
LTable.GenerateUpdateSQLOptimized;    // omite campos não modificados
LTable.GenerateDeleteSQL;             // DELETE FROM "usuarios" WHERE pk = ...
LTable.GenerateWhereByPrimaryKey;     // WHERE "id" = valor

// Execução de DML
LTable.ExecuteInsert(oConnection);
LTable.ExecuteUpdate(oConnection);
LTable.ExecuteDelete(oConnection);
```

#### ITables — carregamento de metadados

```pascal
TTables.New
  .Connection(oConnection)
  .DatabaseTypes(dtPostgreSQL)
  .Schema('public')
  .SetOnLoadTablesProgress(HandleTablesProgress)
  .SetOnLoadFieldsProgress(HandleFieldsProgress)
  .LoadFromConnection;   // carrega todas as tabelas e colunas do schema
```

Callbacks de progresso:

| Callback | Assinatura |
| --- | --- |
| `TOnLoadTablesProgress` | `(ACurrent, ATotal: Integer; ATableName: string)` |
| `TOnLoadFieldsProgress` | `(ATableName: string; ACurrent, ATotal: Integer; AColumnName: string)` |

#### ISchemas — schemas da conexão

```pascal
TSchemas.New
  .Connection(oConnection)
  .LoadSchemasFromConnection;  // IConnection.GetSchemaNames → cria ISchema para cada

oSchemas.Schema('public').LoadFromConnection;  // carrega tabelas do schema 'public'
```

#### IQueryBuilder — consultas fluentes (`USE_QUERY_BUILDER`)

```pascal
TQueryBuilder.New
  .Connection(oConnection)
  .Select('id, nome, email')
  .From('usuarios', 'public')          // schema opcional
  .Where('status', '=', 'ativo')
  .Where('idade', '>', 18)             // AND implícito
  .OrderBy('nome ASC, email DESC')
  .Limit(50)
  .Execute;                            // retorna TDataSet

// Só gerar SQL (sem executar)
LQueryBuilder.ToSQL;
```

**Tipos de JOIN suportados:**

| Constante | SQL gerado |
| --- | --- |
| `jtInner` | `INNER JOIN` |
| `jtLeft` | `LEFT JOIN` |
| `jtRight` | `RIGHT JOIN` |
| `jtFull` | `FULL OUTER JOIN` |
| `jtCross` | `CROSS JOIN` |

Comportamentos automáticos:

- **Quoting de identificadores** por banco (ver tabela em `## Dialetos SQL e mapeamento de tipos por banco`)
- **Schema** incluso apenas para PostgreSQL e SQL Server
- **LIMIT** → `LIMIT n` (MySQL/PostgreSQL/SQLite/Firebird) ou `TOP n` (SQL Server/Access)
- **Proteção contra SQL injection** — escape de strings, NULL handling, formatação numérica

#### IEntityManager (`USE_ENTITY_MANAGER`)

**Ciclo de vida das entidades:**

| Estado | Descrição |
| --- | --- |
| **Transient** | Objeto recém-criado, sem vínculo com o banco; sem ID atribuído |
| **Managed** | Sob controle do EntityManager; alterações detectadas no próximo `Flush` |
| **Detached** | Já foi gerenciado, mas desconectado; mudanças não rastreadas |
| **Removed** | Marcado para exclusão; será deletado no próximo `Flush` |

```text
[Transient] --Save()--> [Managed] --Flush()--> [Persistido/Clean]
[Managed]   --Delete()-> [Removed] --Flush()--> [Deletado do banco]
```

```pascal
LEM := TEntityManager.New
  .Connection(oConnection)
  .Table(LUserTemplate);    // ITable como template de estrutura

// Leitura
LUser  := LEM.Find(123);                          // por PK — usa cache interno
LUsers := LEM.List;                               // todos os registros
LActive := LEM.ListWhere('status', '=', 'ativo'); // filtrado

// Persistência
LEM.Save(LUser);    // INSERT se sem PK, UPDATE se com PK
LEM.Update(LUser);  // UPDATE explícito
LEM.Delete(LUser);  // DELETE por ITable
LEM.Delete(123);    // DELETE por ID
```

> `Find` consulta primeiro o cache interno (`TDictionary`) antes de ir ao banco — mesma garantia do padrão **Identity Map** (Fowler): um único objeto em memória por PK dentro da mesma sessão.

#### IIdentityMap — mapa de identidade (`USE_ENTITY_MANAGER`)

```pascal
LMap := TIdentityMap<ITable>.New;
LMap.Add(123, LUser);
if LMap.Contains(123) then
  LUser := LMap.Get(123);
LMap.Remove(123);
LMap.Clear;
LMap.Count;
LMap.GetAll;   // TArray<ITable>
```

#### IUnitOfWork (`USE_ENTITY_MANAGER`)

```pascal
LUoW := TUnitOfWork.New.Connection(oConnection);

// Registrar intenções
LUoW.RegisterNew(LNovoUsuario)
    .RegisterDirty(LUsuarioAlterado)
    .RegisterDeleted(LUsuarioRemovido);

// Commit: executa INSERT → UPDATE → DELETE em uma única transação
LUoW.Commit;   // exceção → Rollback automático

// Descarta tudo (sem transação no banco)
LUoW.Rollback;
```

Ordem de execução no `Commit`:

1. `BeginTransaction`
2. INSERT para cada `RegisterNew` (via `GenerateInsertSQL`) — tabelas pai antes de filhas (respeita FK)
3. UPDATE para cada `RegisterDirty` (via `GenerateUpdateSQLOptimized`)
4. DELETE para cada `RegisterDeleted` (via `GenerateDeleteSQL`) — tabelas filhas antes de pais
5. `Commit` — ou `Rollback` automático se qualquer etapa falhar

> A inversão de ordem entre INSERT e DELETE é intencional: inserir pai → filho evita violação de FK; deletar filho → pai evita violação de FK na remoção.

#### ITypeDatabase

```pascal
LTD := TTypeDatabase.New.DatabaseType(dtPostgreSQL);
LTD.SupportsSchema;          // True
LTD.GetIdentifierQuote;      // '"'
LTD.GetIdentifierQuoteClose; // '"'
```

#### Exceções do módulo Database

| Faixa | Módulo |
| --- | --- |
| 20xxx | Fields |
| 30xxx | Tables |
| 70xxx | EntityManager |
| 80xxx | QueryBuilder |
| 90xxx | IdentityMap |
| 91xxx | UnitOfWork |
| 92xxx | TypeDatabase |

---

---

## Módulo Exceptions

> Hierarquia centralizada de exceções, banco SQLite de mensagens internacionalizadas e acesso a mensagens por código ou constante.

---

### Exceptions: O que é

O **módulo Exceptions** é o subsistema de tratamento de erros do ProvidersORM. Cumpre duas funções distintas:

1. **Hierarquia de classes** — todas as exceções do framework herdam de `EExceptionBase` e carregam `ErrorCode: Integer` e `Operation: string`, permitindo identificar programaticamente a origem e a natureza do erro.

2. **Banco de mensagens** (`exception.db`) — banco SQLite opcional que armazena mensagens de erro por código e idioma. Acessado via `IExceptionsDatabase` / `TExceptionsDatabase`; permite busca por código numérico ou por nome de constante, com suporte a argumentos de formatação (`%s`).

Fonte pública: `Exceptions.pas` + `Exceptions.Interfaces.pas` em `src/Main/`; implementação interna em `src/Modulos/Exceptions/`.

---

### Exceptions: Diretivas de compilação

O módulo Exceptions **não possui diretiva de ativação própria** — hierarquia de classes e banco de mensagens são sempre compilados. As diretivas relevantes controlam apenas o engine de acesso ao `exception.db`:

| Diretiva | Efeito quando ativa |
| --- | --- |
| `USE_FIREDAC` | FireDAC como engine para `TExceptionsDatabase` conectar ao `exception.db` |
| `USE_UNIDAC` | UniDAC como engine para `TExceptionsDatabase` |
| `USE_ZEOS` | ZeosLib como engine para `TExceptionsDatabase` |
| `USE_SQLDB` | SQLdb como engine para `TExceptionsDatabase` (FPC) |

> `TExceptionsDatabase` usa exclusivamente `IConnection` — sem dependência direta de engine. O banco `exception.db` é sempre SQLite, independentemente do engine compilado.

---

### Exceptions: Características

- **Raiz única** — `EExceptionBase` (herda de `Exception`); todas as exceções do framework derivam dela.
- **ErrorCode + Operation** — cada exceção carrega um código numérico e um nome de operação, presentes em todos os módulos.
- **Hierarquia por módulo** — cada módulo tem sua própria árvore de exceções com faixa de códigos exclusiva (veja tabela em Funcionalidades).
- **Banco de mensagens SQLite** — `Data/exception.db` armazena mensagens multi-idioma; tabela `messages` com campos: `code`, `constant_name`, `message`, `module`, `source_project`, `language`, `name`.
- **Busca dual** — `GetMessage` aceita código numérico (`Integer`) ou nome de constante (`string`).
- **Formatação com args** — `GetMessage(code, [arg1, arg2])` aplica `Format(message, args)` internamente.
- **Auto-criação da tabela** — DDL da tabela `messages` disponível para todos os 6 bancos suportados via `GetCreateTableMessagesSQL`.
- **Factory functions** — `CreateConnectionException`, `CreateSQLException`, `CreateValidationException` etc. simplificam a criação tipada.
- **Conversão automática** — `ConvertToParametersException` converte qualquer `Exception` genérica para o subtipo Parameters mais adequado, por análise semântica da mensagem.
- **Helpers** — `IsParametersException`, `GetExceptionErrorCode`, `GetExceptionOperation`.
- **Multi-idioma** — `Language` configurável; padrão `pt-BR`; campo `language` na PK da tabela.
- **Filtro por módulo e projeto** — `Module` e `SourceProject` no `IExceptionsDatabase` restringem a consulta.
- **Compatibilidade Delphi / FPC** — sem dependência direta de engine; usa apenas `IConnection` para acessar o `exception.db`.

---

### Exceptions: Engines

#### Banco de mensagens (`exception.db`)

O banco de mensagens é **sempre SQLite** (`Data/exception.db`). O `TExceptionsDatabase` usa exclusivamente `IConnection` (com engine selecionado em `ORM.Defines.inc`) para conectar — sem dependência direta de Zeos ou outro driver.

Fontes de localização do banco:

| Método | Fonte |
| --- | --- |
| `FromDefault` | `Data/exception.db` (relativo ao executável) |
| `FromFile(path)` | Caminho explícito |
| `FromConfig` | Lê o path do `config.ini` |
| `FromConfigJson` | Lê o path do `config.json` |
| `FromConnection(IConnection)` | Usa conexão externa já configurada |

#### DDL da tabela `messages` por banco

O módulo disponibiliza SQL `CREATE TABLE` adaptado para cada banco, usado por `GetCreateTableMessagesSQL(tableName, databaseType)`:

| Banco | Tipo da coluna `message` | Observação |
| --- | --- | --- |
| SQLite | `BLOB COLLATE BINARY` | Padrão para `exception.db` |
| PostgreSQL | `TEXT COLLATE "C"` | — |
| MySQL | `TEXT COLLATE utf8mb4_bin` | ENGINE=InnoDB, utf8mb4 |
| SQL Server | `NVARCHAR(MAX) COLLATE Latin1_General_Bin2` | Usa `IF NOT EXISTS` via `sys.objects` |
| Firebird | `BLOB SUB_TYPE TEXT CHARACTER SET UTF8` | — |
| Access | `MEMO` (nativo) / `LONGTEXT` (ODBC) | Dois templates disponíveis |

Chave primária em todos os bancos: `(code, language)`.

---

### Exceptions: Funcionalidades

#### Hierarquia de classes

```text
Exception
└── EExceptionBase
    ├── EConnectionException         (40001–40019)
    │   ├── EConnectionConnectionException
    │   ├── EConnectionSQLException
    │   ├── EConnectionValidationException
    │   ├── EConnectionConfigurationException
    │   └── EConnectionNotFoundException
    └── EParametersException         (500001–500809)
        ├── EParametersConnectionException
        ├── EParametersSQLException
        ├── EParametersValidationException
        ├── EParametersNotFoundException
        ├── EParametersConfigurationException
        ├── EParametersFileException
        ├── EParametersInifilesException
        └── EParametersJsonObjectException
```

Bases dos demais módulos (definidas em `Exceptions.Base`):

| Constante | Valor | Módulo |
| --- | --- | --- |
| `ERR_ATTRIBUTERS_BASE` | 60000 | Attributers |
| `ERR_ENTITYMANAGER_BASE` | 70000 | EntityManager |
| `ERR_QUERYBUILDER_BASE` | 80000 | QueryBuilder |
| `ERR_IDENTITYMAP_BASE` | 90000 | IdentityMap |
| `ERR_UNITOFWORK_BASE` | 91000 | UnitOfWork |
| `ERR_TYPEDATABASE_BASE` | 92000 | TypeDatabase |

#### Faixas de código por módulo

| Faixa | Módulo / Categoria |
| --- | --- |
| 40001–40019 | Connections (conexão, SQL, transação, config) |
| 50xxx | Parameters (base) |
| 500001–500009 | Parameters — Conexão |
| 501001–501015 | Parameters — SQL |
| 500201–500212 | Parameters — Validação |
| 500301–500310 | Parameters — Operações (CRUD) |
| 500401–500408 | Parameters — Configuração |
| 500501–500512 | Parameters — Arquivo |
| 500601–500608 | Parameters — INI |
| 500701–500711 | Parameters — JSON |
| 500801–500809 | Parameters — Import/Export |
| 60000+ | Attributers |
| 70000+ | EntityManager |
| 80000+ | QueryBuilder |
| 90000+ | IdentityMap |
| 91000+ | UnitOfWork |
| 92000+ | TypeDatabase |
| 93xxx | Loggers |
| 94xxx | PoolConnections |

#### Códigos Connections (40001–40019)

| Código | Constante |
| --- | --- |
| 40001 | `ERR_CONNECTION_NOT_ASSIGNED` |
| 40002 | `ERR_CONNECTION_FAILED` |
| 40003 | `ERR_CONNECTION_ALREADY_CONNECTED` |
| 40004 | `ERR_CONNECTION_NOT_CONNECTED` |
| 40005 | `ERR_DISCONNECT_FAILED` |
| 40006 | `ERR_CONNECTION_TIMEOUT` |
| 40007 | `ERR_CONNECTION_INVALID_CREDENTIALS` |
| 40008 | `ERR_CONNECTION_DATABASE_NOT_FOUND` |
| 40009 | `ERR_SQL_EXECUTION_FAILED` |
| 40010 | `ERR_SQL_QUERY_FAILED` |
| 40011 | `ERR_SQL_COMMAND_FAILED` |
| 40012 | `ERR_TRANSACTION_NOT_STARTED` |
| 40013 | `ERR_TRANSACTION_ALREADY_STARTED` |
| 40014 | `ERR_ENGINE_NOT_SUPPORTED` |
| 40015 | `ERR_DATABASE_TYPE_NOT_SUPPORTED` |
| 40016 | `ERR_CONFIG_FILE_NOT_FOUND` |
| 40017 | `ERR_CONFIG_INVALID` |
| 40018 | `ERR_SQL_TABLE_NOT_EXISTS` |
| 40019 | `ERR_SQL_TABLE_CREATE_FAILED` |

#### IExceptionsDatabase — banco de mensagens

```pascal
// Acesso ao banco padrão
oEx := TExceptionsDatabase.New
  .Language('pt-BR')
  .Module('ProvidersORM')
  .FromDefault
  .Connect;

// Busca por código
sMsg := oEx.GetMessage(40002);
sMsg := oEx.GetMessage(40008, ['meu_banco']);   // com formatação

// Busca por constante
sMsg := oEx.GetMessage('ERR_CONNECTION_FAILED');

// Record completo
oRec := oEx.GetMessageRecord(40002);
// oRec.Code, .ConstantName, .Message, .Module, .Language, .Name

// Verificar existência
if oEx.Exists(40002) then ...
if oEx.Exists('ERR_CONNECTION_FAILED') then ...

// Listar todas
aAll := oEx.ListAll;  // TArray<TMessageRecord>

oEx.Disconnect;
```

#### TMessageColumns — colunas da tabela `messages`

| Campo | Coluna no banco |
| --- | --- |
| `Code` | `code` |
| `ConstantName` | `constant_name` |
| `Message` | `message` |
| `Module` | `module` |
| `SourceProject` | `source_project` |
| `Language` | `language` |
| `Name` | `name` |

#### Factory functions (módulo Parameters)

```pascal
// Criação tipada de exceções
raise CreateConnectionException('Falha ao conectar', ERR_CONNECTION_FAILED, 'Connect');
raise CreateSQLException('Tabela não existe', ERR_SQL_TABLE_NOT_EXISTS, 'CreateTable');
raise CreateValidationException('Nome vazio', ERR_PARAMETER_NAME_EMPTY, 'Insert');
raise CreateNotFoundException('Parâmetro não encontrado', ERR_PARAMETER_NOT_FOUND, 'Get');
raise CreateConfigurationException('Engine não definido', ERR_ENGINE_NOT_DEFINED, 'Config');
raise CreateFileException('Arquivo não encontrado', ERR_FILE_NOT_FOUND, 'Load');
raise CreateInifilesException('Seção não encontrada', ERR_INI_SECTION_NOT_FOUND, 'Read');
raise CreateJsonObjectException('JSON inválido', ERR_JSON_INVALID_FORMAT, 'Parse');
```

#### ConvertToParametersException — conversão automática

```pascal
try
  // Operação com banco
except
  on E: Exception do
    raise ConvertToParametersException(E, 'MinhaOperacao');
    // Converte para EParametersConnectionException, EParametersSQLException etc.
    // com base na análise semântica da mensagem original
end;
```

#### Helpers

```pascal
IsParametersException(E)         // Boolean — E é EParametersException?
GetExceptionErrorCode(E)         // Integer — ErrorCode ou 0
GetExceptionOperation(E)         // string  — Operation ou ''
TableNotFoundMessage(msg, path)  // monta mensagem com dica de CreateTable / CLI
```

---

---

## Módulo PoolConnections

> Container de conexões reutilizáveis — gerencia um pool de `IConnection` com deduplicação, eventos de ciclo de vida e acesso para UI.

---

### PoolConnections: O que é

O **módulo PoolConnections** fornece `IPoolConnections` / `TPoolConnections`, um **container de `IConnection`** que permite reutilizar conexões já criadas em vez de abrir e fechar uma nova para cada operação. As conexões são retiradas do pool com `GetFromPool` e devolvidas com `ReturnToPool`.

O módulo é ativado pela diretiva `USE_POOLCONNECTIONS` em `ORM.Defines.inc` e expõe sua API pública via `Providers.PoolConnections.pas` + `Providers.PoolConnections.Interfaces.pas` em `src/Modulos/PoolConnections/`.

---

### PoolConnections: Diretivas de compilação

| Diretiva | Efeito quando ativa |
| --- | --- |
| `USE_POOLCONNECTIONS` | Ativa o módulo inteiro — inclui `TPoolConnections`, `IPoolConnections` e tipos auxiliares (`TPool`, `TPools`) no build |
| `USE_FIREDAC` | Engine das `IConnection` armazenadas no pool (FireDAC) |
| `USE_UNIDAC` | Engine das `IConnection` armazenadas no pool (UniDAC) |
| `USE_ZEOS` | Engine das `IConnection` armazenadas no pool (ZeosLib) |
| `USE_SQLDB` | Engine das `IConnection` armazenadas no pool (SQLdb, FPC) |

> O módulo é agnóstico de engine — armazena qualquer `IConnection` sem inspecionar o driver. A diretiva de engine só importa no momento em que cada `TConnection` é criada antes de ser adicionada ao pool.

---

### PoolConnections: Características

- **Container tipado** — armazena `IConnection` em array interno de `TPool` (`TPools = Array of TPool`).
- **Factory pattern** — `TPoolConnections.New: IPoolConnections`.
- **API fluente** — `Add`, `ReturnToPool`, `Remove`, `Clear` retornam `IPoolConnections` para encadeamento.
- **Deduplicação automática** — `Add` e `TryAdd` rejeitam conexão cuja chave `(engine + databasetype + host + username)` já exista no pool.
- **`TryAdd` com feedback** — retorna `Boolean`; `True` se adicionada, `False` se duplicada.
- **FIFO** — `GetFromPool` retira e remove o primeiro item (índice 0); `ReturnToPool` acrescenta ao final.
- **9 eventos de ciclo de vida** — `OnBeforeAdd`, `OnAfterAdd`, `OnBeforeRemove`, `OnAfterRemove`, `OnBeforeGetFromPool`, `OnAfterGetFromPool`, `OnBeforeReturnToPool`, `OnAfterReturnToPool`, `OnClear`.
- **`TPool` — entrada nomeada** — cada slot guarda `Id`, `Name` (`"Conexao N"`), `Connection`, `ConnectionInfo` (`TConnectionData`) e `ConnectionStatus` (`csConnected` / `csDisconnected`).
- **Acesso por UI** — `GetByIndex`, `GetByName`, `GetPoolList` (não fazem parte da `IPoolConnections`; usados em formulários de teste).
- **Metadados por slot** — `TPool.ListTable`, `TPool.ListDatabase`, `TPool.ListSchema` delegam a `ITables` para consulta de tabelas/bancos/schemas da conexão armazenada.
- **Helpers de UI** — `FormatConnectionInfo` formata string legível do status; `TableNamesToCVS` converte array de nomes em CSV.
- **Agnóstico de engine** — o pool armazena qualquer `IConnection` independentemente do engine compilado.
- **Compatibilidade Delphi / FPC** — sem dependência direta de engine; usa apenas `IConnection`.

---

### PoolConnections: Engines

O módulo é **completamente agnóstico de engine**. Armazena `IConnection` sem inspecionar a engine subjacente. A engine ativa é determinada pela diretiva em `ORM.Defines.inc` no momento em que cada `TConnection` foi criada.

A deduplicação usa os campos de `IConnection`:

| Campo da chave | Método `IConnection` |
| --- | --- |
| Engine | `Engine: TDatabaseEngine` |
| Tipo de banco | `DatabaseType: TDatabaseTypes` |
| Host | `Host: string` |
| Usuário | `Username: string` |

Qualquer engine suportado pelo `IConnection` pode ser poolado:

| Diretiva | Engine |
| --- | --- |
| `USE_UNIDAC` | UniDAC |
| `USE_FIREDAC` | FireDAC |
| `USE_ZEOS` | ZeosLib |
| `USE_SQLDB` | SQLdb |

---

### PoolConnections: Funcionalidades

#### IPoolConnections — interface pública

| Método | Retorno | Descrição |
| --- | --- | --- |
| `GetFromPool` | `IConnection` | Retira e remove o primeiro item do pool (`nil` se vazio) |
| `ReturnToPool(AConnection)` | `IPoolConnections` | Devolve conexão ao final do pool |
| `Add(AConnection)` | `IPoolConnections` | Adiciona (silencioso se duplicada) |
| `TryAdd(AConnection)` | `Boolean` | Adiciona; `True` = adicionada, `False` = duplicada |
| `Remove(AConnection)` | `IPoolConnections` | Remove primeira entrada com essa referência |
| `Count` | `Integer` | Quantidade de entradas no pool |
| `Clear` | `IPoolConnections` | Remove todas as entradas |

#### Uso básico

```pascal
// Criar e popular o pool
LPool := TPoolConnections.New;
LPool.Add(TConnection.New.Host('srv1').Port(5432).Database('db1').Connect);
LPool.Add(TConnection.New.Host('srv2').Port(5432).Database('db2').Connect);

// Retirar uma conexão, usá-la e devolver
LConn := LPool.GetFromPool;
try
  LConn.ExecuteCommand('UPDATE ...');
finally
  LPool.ReturnToPool(LConn);
end;

// Verificar deduplicação
if not LPool.TryAdd(oNovaConn) then
  ShowMessage('Conexão duplicada — não adicionada');

WriteLn(LPool.Count);  // 2
LPool.Clear;
```

#### PoolConnections: Eventos de ciclo de vida

| Evento | Assinatura | Quando |
| --- | --- | --- |
| `OnBeforeAdd` | `TPoolConnectionEvent` | Antes de adicionar ao pool |
| `OnAfterAdd` | `TPoolConnectionEvent` | Após adicionar |
| `OnBeforeRemove` | `TPoolConnectionEvent` | Antes de remover |
| `OnAfterRemove` | `TPoolConnectionEvent` | Após remover |
| `OnBeforeGetFromPool` | `TNotifyEvent` | Antes de retirar do pool |
| `OnAfterGetFromPool` | `TPoolConnectionEvent` | Após retirar (com a conexão retirada) |
| `OnBeforeReturnToPool` | `TPoolConnectionEvent` | Antes de devolver ao pool |
| `OnAfterReturnToPool` | `TPoolConnectionEvent` | Após devolver |
| `OnClear` | `TNotifyEvent` | Ao limpar todo o pool |

```pascal
// Assinatura do TPoolConnectionEvent
procedure MeuHandler(Sender: TObject; const AConnection: IConnection);
```

Eventos disponíveis apenas em `TPoolConnections` (não expostos via `IPoolConnections`).

#### TPool — entrada nomeada do pool

| Campo | Tipo | Descrição |
| --- | --- | --- |
| `Id` | `Integer` | ID sequencial gerado pelo pool |
| `Name` | `String` | `"Conexao N"` — nome legível para UI |
| `Connection` | `IConnection` | Referência à conexão armazenada |
| `ConnectionInfo` | `TConnectionData` | Snapshot dos dados de conexão no momento da adição |
| `ConnectionStatus` | `TConnectionStatus` | `csConnected` ou `csDisconnected` |

Métodos de metadados do slot:

| Método | Retorno | Implementação |
| --- | --- | --- |
| `ListTable` | `TStringArray` | `TTables.New.Connection(Connection).GetTableNames('')` |
| `ListDatabase` | `TStringArray` | `TTables.New.Connection(Connection).GetDatabaseNames` |
| `ListSchema(ADatabase)` | `TStringArray` | `TTables.New.Connection(Connection).GetSchemaNames(ADatabase)` |

#### Acesso para UI (métodos de classe, não na interface)

| Método | Descrição |
| --- | --- |
| `GetByIndex(AIndex)` | Retorna `IConnection` pelo índice (sem remover) |
| `GetByName(AName)` | Busca por `TPool.Name` (case-insensitive) |
| `GetPoolList: TPools` | Cópia completa do array para popular combos/listas |

#### Helpers de UI

```pascal
// Texto formatado para label/combo
s := FormatConnectionInfo(oConn);
// → '[CONECTADO] Engine: Zeos | Database: PostgreSQL | Host: localhost:5432 | User: admin | DB: mydb'

// Nomes de tabelas em CSV
csv := TableNamesToCVS(LPool.GetByIndex(0).GetTableNames(''));
// → 'clientes, pedidos, produtos'
```

#### Exceções do módulo PoolConnections

Faixa **94xxx** (`EDatabaseException` → subtipo específico).

---

---

## Módulo Providers.v161

> Camada de compatibilidade retroativa para código v1.6.0/v1.6.1 — helpers estáticos, utilitários VCL e SQL templates multi-provider.

---

### Providers.v161: O que é

**Providers.v161** é a **camada de compatibilidade retroativa** do ProvidersORM. Preserva as implementações da versão 1.6.0/1.6.1, permitindo que aplicações legadas continuem funcionando enquanto migram progressivamente para a arquitetura v2.0.

Não faz parte do build principal — não possui diretiva de ativação e não é referenciado pelos módulos atuais de `src/Modulos/`. Deve ser tratado como **código de referência e shim de compatibilidade**, não como implementação principal.

Localização: `src/Modulos/Providers.v161/` com 13 arquivos em 3 subpastas:

```text
Providers.v161/
├── Commons/     4 arquivos — helpers de conexão, campo, SQL e tipos
├── Modulos/     2 arquivos — CRUD e gerenciamento de campos
└── Utilities/   7 arquivos — tipos, constantes, strings, session, loading, navegação
```

---

### Providers.v161: Diretivas de compilação

O módulo **não possui diretiva de ativação** — não é referenciado por nenhum `{$IFDEF}` do build principal do ProvidersORM v2.0. Deve ser adicionado manualmente ao projeto legado como unidade avulsa.

| Diretiva | Observação |
| --- | --- |
| Nenhuma (`USE_*`) | O módulo é incluído apenas via `uses` direto; sem controle condicional de compilação |
| `FRAMEWORK_VCL` / `USE_FMX` | `Utilities.Loading` e `Utilities.Navigation` dependem de VCL — não compatíveis com FMX |
| `USE_FIREDAC` / `USE_UNIDAC` / `USE_ZEOS` / `USE_SQLDB` | Não usados internamente — `Providers.v161` não depende de `IConnection` |

> Para migração progressiva, inclua `Providers.v161` apenas em projetos que ainda dependem da API v1.6.x. Novos módulos devem usar exclusivamente a arquitetura v2.0.

---

### Providers.v161: Características

- **Helpers estáticos** — todas as classes usam métodos de classe (`class function`); sem instância, sem interface, sem fluent API.
- **Monolítico** — cada arquivo cobre múltiplas responsabilidades, ao contrário da arquitetura modular do v2.0.
- **7 providers hardcoded** — suporte fixo a FireBird, FireBird3, MySQL, MariaDB, PostgreSQL, SQLite e SQL Server.
- **SQL templates embutidos** — consultas de introspecção (`INFORMATION_SCHEMA`, `RDB$`, `PRAGMA`) diretamente no código.
- **DataSet-based** — operações sobre `TDataSet` diretamente, sem modelo de entidades.
- **VCL-specific** — `Utilities.Loading` (TActivityIndicator), `Utilities.Navigation` (modal/non-modal) e `Vcl.Session` dependem de VCL.
- **Sem interface pública formal** — nenhum arquivo de interfaces (`.Interfaces.pas`); API é acesso direto às classes.
- **Sem fluent API** — configuração por atribuição de variáveis ou parâmetros de função.
- **Nenhuma dependência reversa** — módulos v2.0 não importam nada de `Providers.v161`.

---

### Providers.v161: Engines

O módulo suporta **7 providers de banco de dados** com SQL templates e comportamentos individuais:

| Constante | Banco |
| --- | --- |
| `dpFireBird` | Firebird (versões anteriores à 3) |
| `dpFireBird3` | Firebird 3+ |
| `dpMySQL` | MySQL |
| `dpMariaDB` | MariaDB |
| `dpPostgreSQL` | PostgreSQL |
| `dpSQLite` | SQLite |
| `dpSQLServer` | SQL Server |

#### Comparativo v1.6.1 vs v2.0

| Aspecto | Providers.v161 | ProvidersORM v2.0 |
| --- | --- | --- |
| Arquitetura | Helpers estáticos monolíticos | Módulos com interfaces |
| SQL | Templates hardcoded | `QueryBuilder` dinâmico |
| Tipos | Strings e enums simples | `TDatabaseTypes` + `TDatabaseVariableType` |
| Campos | Filtros sobre `TDataSet` | `IField` / `IFields` com change-tracking |
| CRUD | SQL gerado manualmente | `ITable.Execute*` + `IUnitOfWork` |
| Conexão | Helper de validação e porta default | `IConnection` fluente com pool |
| Logging | Log em arquivo via `TSession` | `ILogger` multi-destino |
| UI | VCL direto (TActivityIndicator, modal) | Desacoplado de UI |

---

### Providers.v161: Funcionalidades

#### Commons — helpers de banco

**`TProviderConnectionHelper`** (`Providers.Common.Connection.pas`)

- Nomes-mestre dos providers (display names)
- Portas padrão por provider: PostgreSQL → 5432, MySQL → 3306, SQL Server → 1433, Firebird → 3050
- Formatação de connection string legível

**`TProviderFieldHelper`** (`Providers.Common.FieldHelper.pas`)

- Detecção de chave primária
- Verificação de tipo de campo
- Formatação de valores para SQL

**`TProviderSQLBuilder`** (`Providers.Common.SQLBuilder.pas`)

SQL de introspecção por banco:

| Banco | Fonte de metadados |
| --- | --- |
| PostgreSQL / MySQL / SQL Server | `INFORMATION_SCHEMA.COLUMNS` |
| Firebird / FireBird3 | `RDB$RELATION_FIELDS` / `RDB$FIELDS` |
| SQLite | `PRAGMA table_info(tabela)` |

**`TProviderTypeConverter`** (`Providers.Common.TypeConverter.pas`)

- Mapeamento de tipo nativo do banco → `TProvicerTypeVariable`
- Detecção de numérico, caractere e datetime para cada provider

#### Modulos — CRUD e campos

**`TProviderCRUDModule`** (`Providers.Module.CRUD.pas`)

| Método | Gera |
| --- | --- |
| `BuildInsertSQL` | `INSERT INTO tabela (campos) VALUES (valores)` |
| `BuildUpdateSQL` | `UPDATE tabela SET campo=valor WHERE pk=id` |
| `BuildDeleteSQL` | `DELETE FROM tabela WHERE pk=id` |
| `BuildSelectSQL` | `SELECT * FROM tabela WHERE pk=id` |

Retorna `TCRUDResult` (record com SQL gerado + status de sucesso).

**`TProviderFieldManager`** (`Providers.Module.FieldManager.pas`)

- Extração de metadados de campos a partir de `TDataSet`
- Filtro de campos por regras de exclusão (campos auditoria: `DELETED`, `DATA_CADASTRO`, `DATA_ALTERACAO`)
- `TFieldInfo` (record): `Table`, `Name`, `Value`, `DefaultValue`, `Typed`, `Encript`, `Changed`

#### Utilities — utilitários gerais

**`Utilities.Types`** — tipos centrais do módulo:

```pascal
TDatabaseProvider = (dpNone, dpFireBird, dpFireBird3, dpMySQL,
                     dpMariaDB, dpPostgreSQL, dpSQLite, dpSQLServer);
TProviderStatus    = (dsInactive, dsEdit, dsInsert, dsDeleted);
TProvicerTypeVariable = (ptNone, ptNumericInteger, ptNumericFloat,
                         ptCharacterString, ptCharacterText, ptCharacterChar,
                         ptDatetime, ptDatetimeTime, ptDatetimeDate,
                         ptBoolean, ptBooleanInteger);
TFieldRecord = record
  Table, Session, Name, Value, DefaultValue, Typed: String;
  Encript, Changed: Boolean;
end;
TTipoVariavel = record
  Numerico, Caracter, Hora, Data, DataHora, Booleano: String;
  function tipo(AValor: String): Integer;
end;
```

**`Utilities.Consts`** — constantes de UI e formatação (cores, formatos de data, charset, info de adaptador de rede).

**`Utilities.Strings`** (~12 000 linhas) — biblioteca de string: manipulação, encoding, formatação de documentos (CPF, CNPJ, telefone), validação.

**`Utilities.Session`** / **`Vcl.Session`** — estado de sessão da aplicação:

| Campo | Tipo | Uso |
| --- | --- | --- |
| Datas de período | `TDate` | Período de filtro corrente |
| Usuário logado | `string` | Identificação do usuário |
| Configurações JSON | `TJSONObject` | Configurações dinâmicas da sessão |

> `Vcl.Session.pas` e `Utilities.Session.pas` são idênticos — manter apenas um na migração.

**`Utilities.Loading`** (VCL) — indicador animado de carregamento (`TActivityIndicator`); exibe sobreposição modal durante operações longas.

**`Utilities.Navigation`** (VCL) — abertura de formulários VCL:

```pascal
TNavigation.OpenModal(TfrmMeuForm);           // modal
TNavigation.OpenNonModal(TfrmMeuForm, Self);  // não-modal com owner
```

#### Tipos v1.6.1 × v2.0 — guia de migração

| v1.6.1 | Equivalente v2.0 |
| --- | --- |
| `TDatabaseProvider` | `TDatabaseEngine` + `TDatabaseTypes` em `Commons.Types` |
| `TProvicerTypeVariable` | `TDatabaseVariableType` em `Commons.Types` |
| `TProviderCRUDModule` | `ITable.GenerateInsertSQL` / `IUnitOfWork` |
| `TProviderFieldManager` | `IFields` / `IField` em `Database/Fields/` |
| `TProviderSQLBuilder` | `IQueryBuilder` em `Database/QueryBuilder/` |
| `TProviderTypeConverter` | `ITypeDatabase` em `Database/TypeDatabase/` |
| `TSession` | Sem equivalente direto — integrar com `IParameters` |
| `TNavigation` | Sem equivalente — UI responsabilidade da aplicação |
| `TLoading` | Sem equivalente — UI responsabilidade da aplicação |

---

## Resumo de diretivas de compilação por módulo

| Módulo | Diretiva de ativação | Diretivas adicionais |
| --- | --- | --- |
| **Parameters** | `USE_PARAMENTERS` | `USE_ATTRIBUTES` (mapeamento RTTI), engines de banco (`USE_FIREDAC` / `USE_UNIDAC` / `USE_ZEOS` / `USE_SQLDB`) |
| **Loggers** | `USE_LOGGERS` | `USE_ATTRIBUTES`; HTTP/E-mail/WS: `USE_INDY`, `USE_ICS`, `USE_IPWORKS`, `USE_SYNAPSE`, `USE_SYNAPSE_WS`, `USE_TMS_WEBSOCKET`, `USE_HORSE`, `USE_BIRD_SOCKET`; engines de banco |
| **Connections** | *(sempre compilado)* | `USE_FIREDAC` / `USE_UNIDAC` / `USE_ZEOS` / `USE_SQLDB` (engine ativo), `USE_ATTRIBUTES` (habilita `FromClass`) |
| **Database** | *(núcleo sempre compilado)* | `USE_QUERY_BUILDER` (Query Builder), `USE_ENTITY_MANAGER` (EntityManager + IdentityMap + UnitOfWork), `USE_ATTRIBUTES` (obrigatório para Entity Manager), engines de banco |
| **Exceptions** | *(sempre compilado)* | `USE_FIREDAC` / `USE_UNIDAC` / `USE_ZEOS` / `USE_SQLDB` (engine para `TExceptionsDatabase`) |
| **PoolConnections** | `USE_POOLCONNECTIONS` | Engines de banco (definem o driver das `IConnection` armazenadas) |
| **Providers.v161** | *(sem diretiva — inclusão manual)* | `FRAMEWORK_VCL` / `USE_FMX` afetam utilitários VCL; sem dependência de engines v2.0 |

---

## Changelog (este arquivo)

- 2.0.0 (01/04/2026): Enriquecimento a partir de `ProvidersORM_CONCEITOS_Overview.md` — comparativo completo de engines (Array DML, Pool, Monitoring), comparativo geral de 6 bancos, nova seção `Dialetos SQL e mapeamento de tipos por banco` (paginação, RETURNING, quoting, tipos Delphi→SQL, concatenação), ciclo de vida do EntityManager, JOIN types no QueryBuilder, ordenação FK no UnitOfWork.
- 1.9.0 (01/04/2026): Adição da subseção `Diretivas de compilação` em todos os módulos (Parameters, Loggers, Connections, Database, Exceptions, PoolConnections, Providers.v161) com tabelas de diretivas `{$IFDEF}` relevantes por módulo.
- 1.8.0 (01/04/2026): Adição da documentação completa do módulo Providers.v161 (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Providers.v161`.
- 1.7.0 (01/04/2026): Adição da documentação completa do módulo PoolConnections (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/PoolConnections`.
- 1.6.0 (01/04/2026): Adição da documentação completa do módulo Exceptions (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Exceptions`.
- 1.5.0 (01/04/2026): Adição da documentação completa do módulo Database (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Database`.
- 1.4.0 (01/04/2026): Adição da documentação completa do módulo Connections (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Connections`.
- 1.3.0 (01/04/2026): Adição da documentação completa do módulo Loggers (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Loggers`.
- 1.2.0 (01/04/2026): Adição da documentação completa do módulo Parameters (O que é, Características, Engines, Funcionalidades) gerada a partir de `src/Modulos/Parameters`.
- 1.1.0 (01/04/2026): Expansão com engines auxiliares, tabela de exceções completa, formulários de teste, compatibilidade Delphi/FPC por engine e diretivas de UI.
- 1.0.0 (31/03/2026): Criação do documento de visão geral (O que é, Características, Engines, Funcionalidades).
