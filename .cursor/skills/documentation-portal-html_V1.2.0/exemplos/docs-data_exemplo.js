// =============================================================================
// docs-data.js — Dados da documentação do Providers ORM v2.0
// Carregado por Documentation/html/index.html — ver README.md nesta pasta
// =============================================================================

const ORM_VERSION = '2.0.0';
const ORM_DATE    = '28/02/2026';
const ORM_AUTHOR  = 'Claiton de Souza Linhares';

// ---------------------------------------------------------------------------
// Módulos do ORM
// ---------------------------------------------------------------------------
const MODULES = [
  {
    id: 'connection',
    name: 'Connection',
    icon: '🔌',
    desc: 'Conexão com o banco de dados — TConnection / IConnection',
    interfaces: ['IConnection'],
    classes:    ['TConnection'],
    path:       'src/Modulos/Connections/',
    files: [
      'Providers.Connection.Interfaces.pas',
      'Providers.Connection.pas',
    ],
    analise: [
      'Analise/Connections/Connection.md',
    ],
    features: [
      'Fluent builder (DatabaseType, Host, Port, Username, Password, Database, Schema)',
      'Engines: FireDAC, UniDAC, Zeos (ativo), SQLdb (FPC)',
      'Bancos: PostgreSQL, MySQL, SQL Server, FireBird, SQLite, Access',
      'FromIniFile / FromJSON / FromConfig',
      'Connect / Disconnect / Ping / IsConnected',
      'ExecuteQuery / ExecuteCommand / ExecuteScalar',
      'BeginTransaction / Commit / Rollback / InTransaction',
      'GetServerVersion / GetClientVersion',
      'DllBasePath (carga de DLLs para Zeos/UniDAC)',
      'Integração com Parameters (FromParameters) e Loggers',
    ],
    example: `var LConn: IConnection;
begin
  LConn := TConnection.New
    .DatabaseType(dtPostgreSQL)
    .Host('localhost').Port(5432)
    .Username('postgres').Password('secret')
    .Database('mydb')
    .Connect;
  WriteLn(LConn.ExecuteScalar('SELECT version()'));
  LConn.Disconnect;
end;`,
  },

  {
    id: 'pool',
    name: 'Pool de Conexões',
    icon: '🏊',
    desc: 'Gerenciamento de múltiplas conexões — TPoolConnections / IPoolConnections',
    interfaces: ['IPoolConnections'],
    classes:    ['TPoolConnections'],
    path:       'src/Modulos/PoolConnections/',
    files: [
      'Providers.PoolConnections.Interfaces.pas',
      'Providers.PoolConnections.pas',
    ],
    features: [
      'Add / TryAdd — adicionar conexões ao pool',
      'Remove — remover por IConnection',
      'GetFromPool — obter conexão disponível',
      'GetByIndex — acesso por índice',
      'ReturnToPool — devolver ao pool',
      'Count / Clear',
      'GetPoolList (TStringList)',
      'Eventos: OnAdd, OnRemove, OnGetFromPool, OnReturnToPool',
    ],
    example: `var LPool: IPoolConnections;
begin
  LPool := TPoolConnections.New;
  LPool.TryAdd(TConnection.New.DatabaseType(dtSQLite).Database('config.db'));
  LPool.TryAdd(TConnection.New.DatabaseType(dtSQLite).Database('exception.db'));
  WriteLn('Pool: ', LPool.Count, ' conexões');
  LPool.Clear;
end;`,
  },

  {
    id: 'tables',
    name: 'Tables',
    icon: '🗃️',
    desc: 'Container de tabelas do banco — TTables / ITables',
    interfaces: ['ITables', 'ITable', 'IFields', 'IField'],
    classes:    ['TTables', 'TTable', 'TFields', 'TField'],
    path:       'src/Modulos/Database/',
    files: [
      'Tables/Providers.Database.Tables.Interfaces.pas',
      'Tables/Providers.Database.Tables.pas',
      'Tables/Providers.Database.Table.Interfaces.pas',
      'Tables/Providers.Database.Table.pas',
      'Fields/Providers.Database.Fields.Interfaces.pas',
      'Fields/Providers.Database.Fields.pas',
      'Fields/Providers.Database.Field.Interfaces.pas',
      'Fields/Providers.Database.Field.pas',
    ],
    features: [
      'LoadFromConnection — carrega tabelas reais do banco',
      'Table(nome) — acessa tabela por nome',
      'TablesCount / GetTableNames',
      'Schema / Database (fluent setters)',
      'DDL: GetSQLCreateTable(schema), GetSQLDropTable',
      'DML: ExecuteInsert / ExecuteUpdate / ExecuteDelete',
      'Fields: AddField, Field(nome), FieldsCount, IsPKey, FieldSize, IsNullable',
      'Foreign Keys, Indexes, Primary Keys',
      'Callbacks de progresso: OnProgress, OnProgressMax',
      'OnUpdateRule / OnDeleteRule (CASCADE, RESTRICT, SET NULL...)',
    ],
    example: `var LTables: ITables; LTable: ITable;
begin
  LTables := TTables.New
    .Connection(LConn)
    .LoadFromConnection;
  LTable := LTables.Table('usuarios');
  WriteLn('Colunas: ', LTable.Fields.FieldsCount);
  WriteLn(LTable.GetSQLCreateTable('public'));
end;`,
  },

  {
    id: 'query-builder',
    name: 'QueryBuilder',
    icon: '🔍',
    desc: 'Construção fluente de SQL — TQueryBuilder / IQueryBuilder',
    interfaces: ['IQueryBuilder'],
    classes:    ['TQueryBuilder'],
    path:       'src/Modulos/Database/QueryBuilder/',
    files: [
      'Providers.Database.QueryBuilder.Interfaces.pas',
      'Providers.Database.QueryBuilder.pas',
    ],
    note: 'Ativar: {$DEFINE USE_QUERY_BUILDER} em ORM.Defines.inc',
    features: [
      'Select / From / Where / OrderBy / GroupBy / Having',
      'Limit / Offset',
      'Join / LeftJoin / RightJoin / InnerJoin',
      'ToSQL — gerar SQL sem executar',
      'Execute — executar e retornar TDataSet',
      'Connection — associa IConnection',
    ],
    example: `var LQB: IQueryBuilder;
begin
  LQB := TQueryBuilder.New
    .Connection(LConn)
    .Select('id, nome, email')
    .From('usuarios')
    .Where('ativo = TRUE')
    .OrderBy('nome ASC')
    .Limit(50);
  WriteLn(LQB.ToSQL);
end;`,
  },

  {
    id: 'entity-manager',
    name: 'EntityManager',
    icon: '🏗️',
    desc: 'CRUD automático por mapeamento de classe — TEntityManager / IEntityManager',
    interfaces: ['IEntityManager'],
    classes:    ['TEntityManager'],
    path:       'src/Modulos/Database/EntityManager/',
    files: [
      'Providers.Database.EntityManager.Interfaces.pas',
      'Providers.Database.EntityManager.pas',
    ],
    note: 'Ativar: {$DEFINE USE_ENTITY_MANAGER} em ORM.Defines.inc',
    features: [
      'Save(objeto) — INSERT ou UPDATE por PK',
      'Find<T>(id) — busca por PK',
      'FindAll<T> — lista completa',
      'FindWhere<T>(where) — lista com filtro SQL',
      'Delete<T>(id) — delete por PK',
      'Connection — associa IConnection',
    ],
    example: `[Table('clientes', 'public')]
TCliente = class
  [PrimaryKey][Field('id')]   property Id: Integer ...
  [Field('nome', 200)]        property Nome: string ...
end;

LEM := TEntityManager.New.Connection(LConn);
LEM.Save(LCliente);           // INSERT
LCliente := LEM.Find<TCliente>(1);  // SELECT
LEM.Delete<TCliente>(1);      // DELETE`,
  },

  {
    id: 'attributers',
    name: 'Attributers',
    icon: '🏷️',
    desc: 'Mapeamento RTTI Classe ↔ Tabela via atributos — [Table][Field][PrimaryKey]',
    interfaces: ['IAttributeMapper', 'IAttributeParser', 'IAttributeRegistry'],
    classes:    ['TAttributeMapper', 'TAttributeParser', 'TAttributeRegistry'],
    path:       'src/Attributers/',
    files: [
      'Providers.Attributers.Interfaces.pas',
      'Providers.Attributers.pas',
    ],
    note: 'Ativar: {$DEFINE USE_ATTRIBUTES} em ORM.Defines.inc',
    features: [
      '[Table(nome)] / [Table(nome, schema)] — nome da tabela',
      '[Field(coluna)] — nome da coluna',
      '[Field(coluna, size)] — coluna com tamanho',
      '[Field(coluna, size, nullable)] — coluna com tamanho e nullable',
      '[PrimaryKey] — marca PK',
      'MapClass(TClasse) → ITable',
      'ParseObject(objeto) → dicionário coluna/valor',
      'AttributeRegistry — registro centralizado',
    ],
    example: `[Table('clientes', 'public')]
TCliente = class
  [PrimaryKey][Field('id')]      property Id: Integer read FId write FId;
  [Field('nome', 200)]           property Nome: string read FNome write FNome;
  [Field('email', 255, True)]    property Email: string read FEmail write FEmail;
private
  FId: Integer; FNome, FEmail: string;
end;`,
  },

  {
    id: 'parameters',
    name: 'Parameters',
    icon: '⚙️',
    desc: 'Configuração centralizada — TParameters / IParameters',
    interfaces: ['IParameters'],
    classes:    ['TParameters'],
    path:       'src/Main/',
    files: [
      'Parameters.Interfaces.pas',
      'Parameters.pas',
    ],
    features: [
      'FromIniFile — carrega de arquivo INI',
      'FromJSON — carrega de JSON inline',
      'FromDatabase — carrega de banco de dados',
      'Get(chave) / GetStr / GetInt / GetBool',
      'Set(chave, valor)',
      'Integração com TConnection.FromParameters / FromConfig',
    ],
  },

  {
    id: 'loggers',
    name: 'Loggers',
    icon: '📋',
    desc: 'Sistema de logging — TLoggers / ILoggers',
    interfaces: ['ILoggers', 'ILogger'],
    classes:    ['TLoggers'],
    path:       'src/Main/',
    files: [
      'Loggers.Interfaces.pas',
      'Loggers.pas',
    ],
    features: [
      'TextFile — log em arquivo texto',
      'CSV — log em arquivo CSV',
      'Database — log em tabela do banco',
      'WebSocket — log via WebSocket',
      'JSON — log estruturado JSON',
      'Múltiplos loggers simultâneos',
      'Log(mensagem, nível)',
      'LogDebug / LogInfo / LogWarn / LogError',
    ],
  },

  {
    id: 'exceptions',
    name: 'Exceptions',
    icon: '⚠️',
    desc: 'Módulo de exceções padronizadas — facade exception.db',
    interfaces: ['IExceptions', 'IExceptionDatabase'],
    classes:    ['TExceptions', 'TExceptionDatabase'],
    path:       'src/Modulos/Exceptions/',
    files: [
      'Exceptions.Interfaces.pas',
      'Exceptions.pas',
      'Exceptions.Database.Interfaces.pas',
      'Exceptions.Database.pas',
    ],
    features: [
      'Hierarquia EDatabaseException',
      'Faixas de código por módulo (100XXX Commons, 400XXX Connections, etc.)',
      'facade exception.db (SQLite) — mensagens por idioma (PT, EN, ES)',
      'exception_en.sql / exception_es.sql / exception.sql',
    ],
  },
];

// ---------------------------------------------------------------------------
// Tipos de banco suportados
// ---------------------------------------------------------------------------
const DATABASE_TYPES = [
  { const: 'dtPostgreSQL', name: 'PostgreSQL',          dll: 'libpq.dll (win32/64)' },
  { const: 'dtMySQL',      name: 'MySQL / MariaDB',     dll: 'libmysql.dll (win32/64)' },
  { const: 'dtSQLServer',  name: 'Microsoft SQL Server',dll: 'libsybdb-5.dll (FreeTDS)' },
  { const: 'dtFireBird',   name: 'Firebird',             dll: 'fbclient.dll (win32/64)' },
  { const: 'dtSQLite',     name: 'SQLite',               dll: '(embutido no Zeos)' },
  { const: 'dtAccess',     name: 'Microsoft Access',     dll: '(via ODBC)' },
];

// ---------------------------------------------------------------------------
// Engines de banco disponíveis (um por compilação via ORM.Defines.inc)
// ---------------------------------------------------------------------------
const ENGINES = [
  { define: 'USE_ZEOS',     name: 'Zeos (ZeosDBO)', status: 'ativo',   note: 'Engine padrão do projeto' },
  { define: 'USE_FIREDAC',  name: 'FireDAC',        status: 'suporte', note: 'Delphi RAD Studio' },
  { define: 'USE_UNIDAC',   name: 'UniDAC',         status: 'suporte', note: 'DevArt UniDAC' },
  { define: 'USE_SQLDB',    name: 'SQLdb (FPC)',     status: 'suporte', note: 'Free Pascal / Lazarus' },
];

// ---------------------------------------------------------------------------
// Exemplos disponíveis em Exemplos/
// ---------------------------------------------------------------------------
const EXAMPLES = [
  {
    name:   'ExemploConnection.dpr',
    path:   'Exemplos/Connections/',
    desc:   'TConnection fluente, FromIniFile, FromJSON, transação, Ping',
  },
  {
    name:   'ExemploPool.dpr',
    path:   'Exemplos/PoolConnections/',
    desc:   'TPoolConnections: Add, TryAdd, GetByIndex, Remove, Clear',
  },
  {
    name:   'ExemploDatabase.dpr',
    path:   'Exemplos/Database/',
    desc:   'TTables.LoadFromConnection, QueryBuilder, DDL (GetSQLCreateTable)',
  },
  {
    name:   'ExemploParameters.dpr',
    path:   'Exemplos/Parameters/',
    desc:   'TParameters FromIniFile / FromJSON, TConnection.FromConfig',
  },
  {
    name:   'ExemploLoggers.dpr',
    path:   'Exemplos/Loggers/',
    desc:   'TLoggers TextFile / CSV, múltiplos loggers simultâneos',
  },
  {
    name:   'ExemploProvidersORM.dpr',
    path:   'Exemplos/ProvidersORM/',
    desc:   'Integrado: Lite + Slim + QueryBuilder + DDL + Pool',
  },
  {
    name:   'ExemploForeignKey.dpr',
    path:   'Exemplos/',
    desc:   'Foreign Keys, OnUpdateRule/OnDeleteRule, relações entre tabelas',
  },
];
