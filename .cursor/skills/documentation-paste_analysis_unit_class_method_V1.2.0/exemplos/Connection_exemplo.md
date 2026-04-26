# Connection

**Tipos documentados:** `IConnection` (interface), `TConnection` (classe)
**Domínio:** Connections
**Ficheiro:** `Connection.md`

## Interface — `IConnection`


> Interface central de conexao com banco de dados no ProvidersORM. Define o contrato unico para todas as engines e todos os bancos suportados.

**Unit:** `Providers.Connection.Interfaces.pas`
**Tipo:** Interface
**Modulo:** Connections (`src/Modulos/Connections/`)
**GUID:** `{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}`
**Diretiva:** Sempre compilada (a interface em si nao depende de diretiva; metodos condicionais marcados abaixo)

---

## O que e?

`IConnection` e a interface que estabelece o contrato obrigatorio para qualquer conexao com banco de dados no ProvidersORM. Todo modulo que precisa de acesso a dados -- `TPoolConnections`, `TTables`, `TEntityManager`, `TQueryBuilder` -- depende exclusivamente desta interface, nunca da classe concreta.

A interface segue o padrao **Fluent Interface**: os setters de configuracao retornam `IConnection`, permitindo chamadas encadeadas como `Connection.Host('localhost').Port(5432).Database('mydb').Connect`. Os getters (overloads sem parametro) retornam o valor corrente, possibilitando leitura transparente.

`IConnection` abstrai completamente a engine de acesso a dados. O consumidor programa contra a interface e nao precisa saber se por tras esta UniDAC, FireDAC, ZeosLib ou SQLdb -- o comportamento e identico independentemente do driver compilado.

---

## Caracteristicas

- **Contrato unico:** uma unica interface para todas as engines (UniDAC, FireDAC, Zeos, SQLdb) e todos os bancos (PostgreSQL, MySQL, SQL Server, Firebird, SQLite, Access)
- **Fluent Interface:** todos os setters de configuracao retornam `IConnection`, viabilizando encadeamento
- **Overloads getter/setter:** cada propriedade de configuracao possui duas assinaturas -- setter (com parametro, retorna `IConnection`) e getter (sem parametro, retorna o valor)
- **Carregamento multiplo:** configuracao pode vir de INI, JSON, auto-deteccao (`FromConfig`) ou atributos RTTI (`FromClass`, condicional a `USE_ATTRIBUTES`)
- **Execucao SQL completa:** `ExecuteQuery` para SELECT (retorna `TDataSet`), `ExecuteCommand` para DML (retorna linhas afetadas), `ExecuteScalar` para valor escalar
- **Transacoes explicitas:** `BeginTransaction`, `Commit`, `Rollback` com consulta via `InTransaction`
- **Metadados em runtime:** listagem de tabelas, bancos, schemas, colunas e estrutura completa de tabela (DDL reverso)
- **Validacao de DLL:** `IsRequiredDllFound` verifica se a DLL nativa do banco esta acessivel antes de conectar
- **Reference counting:** herda de `IInterface` (Delphi/FPC), ciclo de vida gerenciado por contagem de referencia

---

## Engine

`IConnection` nao depende de diretiva de engine para ser compilada. Porem, a **implementacao** (`TConnection`) e condicionalmente compilada conforme a diretiva ativa em `ORM.Defines.inc`:

| Diretiva | Engine | Componente nativo |
|----------|--------|-------------------|
| `USE_FIREDAC` | FireDAC (Embarcadero) | `TFDConnection` / `TFDQuery` |
| `USE_UNIDAC` | UniDAC (Devart) | `TUniConnection` / `TUniQuery` |
| `USE_ZEOS` | ZeosLib (open source) | `TZConnection` / `TZQuery` |
| `USE_SQLDB` | SQLdb (Free Pascal) | `TSQLConnection` / `TSQLQuery` + `TSQLTransaction` |

Apenas **uma engine** e ativa por build. O consumidor da interface nao precisa saber qual esta em uso.

### Bancos suportados

| Banco | `TDatabaseTypes` | DLL obrigatoria |
|-------|-------------------|-----------------|
| PostgreSQL | `dtPostgreSQL` | `libpq.dll` |
| MySQL | `dtMySQL` | `libmysql.dll` |
| SQL Server | `dtMSSQL` | Varia por engine |
| Firebird | `dtFirebird` | `fbclient.dll` |
| SQLite | `dtSQLite` | `sqlite3.dll` (ou link estatico) |
| Access | `dtAccess` | Nenhuma (via ADOX/OLE DB) |

---

## Funcionalidades

### Configuracao fluente

Cada propriedade possui um **setter** (recebe valor, retorna `IConnection`) e um **getter** (retorna o valor atual). Isso permite tanto o encadeamento fluente quanto a leitura individual.

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Engine` (setter) | `function Engine(const AValue: TDatabaseEngine): IConnection` | `IConnection` | Define a engine de acesso a dados |
| `Engine` (getter) | `function Engine: TDatabaseEngine` | `TDatabaseEngine` | Retorna a engine configurada |
| `DatabaseType` (setter enum) | `function DatabaseType(const AValue: TDatabaseTypes): IConnection` | `IConnection` | Define o tipo de banco via enumerador |
| `DatabaseType` (setter string) | `function DatabaseType(const AValue: string): IConnection` | `IConnection` | Define o tipo de banco via nome textual (ex.: `'PostgreSQL'`) |
| `DatabaseType` (getter) | `function DatabaseType: TDatabaseTypes` | `TDatabaseTypes` | Retorna o tipo de banco configurado |
| `Host` (setter) | `function Host(const AValue: string): IConnection` | `IConnection` | Define o host/IP do servidor |
| `Host` (getter) | `function Host: string` | `string` | Retorna o host configurado |
| `Port` (setter) | `function Port(const AValue: Integer): IConnection` | `IConnection` | Define a porta de conexao |
| `Port` (getter) | `function Port: Integer` | `Integer` | Retorna a porta configurada |
| `Username` (setter) | `function Username(const AValue: string): IConnection` | `IConnection` | Define o usuario |
| `Username` (getter) | `function Username: string` | `string` | Retorna o usuario configurado |
| `Password` (setter) | `function Password(const AValue: string): IConnection` | `IConnection` | Define a senha |
| `Password` (getter) | `function Password: string` | `string` | Retorna a senha configurada |
| `Database` (setter) | `function Database(const AValue: string): IConnection` | `IConnection` | Define o nome do banco |
| `Database` (getter) | `function Database: string` | `string` | Retorna o nome do banco configurado |
| `Schema` (setter) | `function Schema(const AValue: string): IConnection` | `IConnection` | Define o schema padrao |
| `Schema` (getter) | `function Schema: string` | `string` | Retorna o schema configurado |
| `ConfigFilePath` (setter) | `function ConfigFilePath(const AValue: string): IConnection` | `IConnection` | Define o caminho do arquivo de configuracao |
| `ConfigFilePath` (getter) | `function ConfigFilePath: string` | `string` | Retorna o caminho do arquivo de configuracao |
| `DllBasePath` (setter) | `function DllBasePath(const AValue: string): IConnection` | `IConnection` | Define o diretorio base das DLLs nativas |
| `DllBasePath` (getter) | `function DllBasePath: string` | `string` | Retorna o diretorio base das DLLs |
| `IsRequiredDllFound` | `function IsRequiredDllFound: Boolean` | `Boolean` | Verifica se a DLL obrigatoria do banco configurado existe no caminho |

### Carregamento de configuracao

Metodos que preenchem as propriedades de conexao a partir de fontes externas.

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `FromIniFile` | `function FromIniFile(const AFilePath, ASection: string): IConnection` | `IConnection` | Carrega configuracao de um arquivo `.ini` (secao especifica) |
| `FromConfig` | `function FromConfig: IConnection` | `IConnection` | Auto-detecta arquivo de configuracao em `Data/` (`config.ini`, `config.db`, `config.json`) e carrega |
| `FromJSON` | `function FromJSON(const AJSON: string): IConnection` | `IConnection` | Carrega configuracao a partir de uma string JSON |
| `FromClass` | `function FromClass(const AClass: TClass): IConnection` | `IConnection` | Carrega configuracao a partir de atributos RTTI da classe (requer `{$IFDEF USE_ATTRIBUTES}`) |

> **Nota:** `FromClass` so esta disponivel quando a diretiva `USE_ATTRIBUTES` esta ativa em `ORM.Defines.inc`.

### Conexao

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Connect` | `function Connect: IConnection` | `IConnection` | Estabelece a conexao com o banco de dados. Valida DLL antes de conectar |
| `Disconnect` | `function Disconnect: IConnection` | `IConnection` | Encerra a conexao ativa |
| `IsConnected` | `function IsConnected: Boolean` | `Boolean` | Retorna `True` se ha conexao ativa |
| `Ping` | `function Ping: Boolean` | `Boolean` | Testa se a conexao esta responsiva (round-trip ao servidor) |

### Execucao SQL

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `ExecuteQuery` | `function ExecuteQuery(const ASQL: string): TDataSet` | `TDataSet` | Executa SELECT e retorna o dataset resultante |
| `ExecuteCommand` | `function ExecuteCommand(const ASQL: string): Integer` | `Integer` | Executa INSERT/UPDATE/DELETE e retorna o numero de linhas afetadas |
| `ExecuteScalar` | `function ExecuteScalar(const ASQL: string): Variant` | `Variant` | Executa SQL que retorna um valor unico escalar (primeira coluna, primeira linha) |

## Overloads parametrizados (v2.1)

Tres novos overloads aceitam um array de parametros posicionais (`array of Variant`) que sao vinculados ao SQL antes da execucao. A query deve usar placeholders `:param0`, `:param1`, ... (ou `?` para Zeos, via normalizacao interna em `TConnection.NormalizeParams`).

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `ExecuteQuery` (parametrizado) | `function ExecuteQuery(const ASQL: string; const AParams: array of Variant): TDataSet` | `TDataSet` | Executa SELECT com parametros vinculados; retorna o dataset resultante |
| `ExecuteCommand` (parametrizado) | `function ExecuteCommand(const ASQL: string; const AParams: array of Variant): Integer` | `Integer` | Executa INSERT/UPDATE/DELETE com parametros; retorna linhas afetadas |
| `ExecuteScalar` (parametrizado) | `function ExecuteScalar(const ASQL: string; const AParams: array of Variant): Variant` | `Variant` | Executa SQL parametrizado que retorna um valor escalar |

> **Nota FPC:** Em Free Pascal, `array of Variant` como parametro aberto requer que o chamador passe um array const literal ou uma variavel de tipo `TVariantArray`. O comportamento e identico ao Delphi em runtime.

---

### Transacoes

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `BeginTransaction` | `function BeginTransaction: IConnection` | `IConnection` | Inicia uma transacao explicita |
| `Commit` | `function Commit: IConnection` | `IConnection` | Confirma (commit) a transacao corrente |
| `Rollback` | `function Rollback: IConnection` | `IConnection` | Reverte (rollback) a transacao corrente |
| `InTransaction` | `function InTransaction: Boolean` | `Boolean` | Retorna `True` se ha transacao ativa |

### Versoes

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `GetServerVersion` | `function GetServerVersion: string` | `string` | Retorna a versao do servidor de banco de dados |
| `GetClientVersion` | `function GetClientVersion: string` | `string` | Retorna a versao da biblioteca cliente (DLL/driver) |

### Dados de conexao

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `GetConnectionData` | `function GetConnectionData: TConnectionData` | `TConnectionData` | Retorna um registro (`record`) com todos os dados da conexao atual (Engine, DatabaseType, Host, Port, Database, etc.) |

### Metadados

Metodos para inspecao da estrutura do banco em runtime. Usados internamente por `TTables` e disponiveis para o consumidor.

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `GetTableNames` | `function GetTableNames(const ASchema: string = ''): TStringArray` | `TStringArray` | Lista nomes de tabelas; filtra por schema se informado |
| `GetDatabaseNames` | `function GetDatabaseNames: TStringArray` | `TStringArray` | Lista nomes dos bancos de dados acessiveis no servidor |
| `GetSchemaNames` | `function GetSchemaNames(const ADatabase: string = ''): TStringArray` | `TStringArray` | Lista schemas do banco; filtra por database se informado |
| `GetColumnNames` | `function GetColumnNames(const ATableName: string; const ASchema: string = ''): TStringArray` | `TStringArray` | Lista nomes de colunas de uma tabela; filtra por schema se informado |
| `GetTableStructure` | `function GetTableStructure(const ATableName: string; const ASchema: string = ''): TArray<TDatabaseFields>` | `TArray<TDatabaseFields>` | Retorna a estrutura completa da tabela (tipo, tamanho, nullable, PK, FK, constraint, referenced table/column, update/delete rule) |

---

## Aplicabilidades

- **Conexao direta a banco:** cenario mais simples -- criar `IConnection`, configurar, conectar e executar SQL
- **Pool de conexoes:** `TPoolConnections` armazena e gerencia multiplas instancias de `IConnection`
- **ORM completo:** `TEntityManager` e `TQueryBuilder` recebem `IConnection` para persistencia e consultas
- **Metadados e DDL reverso:** `TTables` delega para `GetTableNames`, `GetColumnNames` e `GetTableStructure` de `IConnection` para descobrir a estrutura do banco em runtime
- **Testes e validacao:** `Ping` e `IsConnected` para health-check; `IsRequiredDllFound` para validacao pre-deploy
- **Migracao entre engines:** trocar de UniDAC para Zeos (ou qualquer outra engine) requer apenas mudar a diretiva em `ORM.Defines.inc`; o codigo consumidor nao muda
- **Configuracao externalizada:** `FromConfig`, `FromIniFile` e `FromJSON` eliminam credenciais hard-coded

---

## Exemplos de Uso

### Configuracao fluente e conexao

```pascal
uses
  Providers.Connection, Providers.Connection.Interfaces, Commons.Types;

var
  Conn: IConnection;
begin
  Conn := TConnection.New
    .Engine(teFireDAC)
    .DatabaseType(dtPostgreSQL)
    .Host('localhost')
    .Port(5432)
    .Username('admin')
    .Password('secret')
    .Database('myapp')
    .Schema('public')
    .DllBasePath('C:\Libs\pgsql')
    .Connect;

  if Conn.IsConnected then
    WriteLn('Conectado ao PostgreSQL via FireDAC');
end;
```

### Carregamento via FromConfig (auto-deteccao)

```pascal
var
  Conn: IConnection;
begin
  // Detecta automaticamente Data/config.ini (secao 'database')
  Conn := TConnection.New
    .FromConfig
    .Connect;

  WriteLn('Banco: ', Conn.Database);
  WriteLn('Host: ', Conn.Host);
end;
```

### Carregamento via FromIniFile

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New
    .FromIniFile('C:\Config\producao.ini', 'database')
    .Connect;
end;
```

### Carregamento via FromJSON

```pascal
var
  Conn: IConnection;
  LJSON: string;
begin
  LJSON := '{"host":"localhost","port":5432,"username":"admin",'
         + '"password":"secret","database":"myapp","database_type":"PostgreSQL"}';

  Conn := TConnection.New
    .FromJSON(LJSON)
    .Connect;
end;
```

### Execucao SQL

```pascal
var
  Conn: IConnection;
  DS: TDataSet;
  RowsAffected: Integer;
  Total: Variant;
begin
  Conn := TConnection.New.FromConfig.Connect;

  // SELECT -- retorna TDataSet
  DS := Conn.ExecuteQuery('SELECT id, nome FROM clientes WHERE ativo = 1');
  while not DS.Eof do
  begin
    WriteLn(DS.FieldByName('nome').AsString);
    DS.Next;
  end;

  // INSERT/UPDATE/DELETE -- retorna linhas afetadas
  RowsAffected := Conn.ExecuteCommand(
    'UPDATE clientes SET ativo = 0 WHERE ultimo_acesso < ''2025-01-01'''
  );
  WriteLn('Linhas atualizadas: ', RowsAffected);

  // Valor escalar -- primeira coluna da primeira linha
  Total := Conn.ExecuteScalar('SELECT COUNT(*) FROM clientes');
  WriteLn('Total de clientes: ', Total);
end;
```

### Transacoes

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New.FromConfig.Connect;

  Conn.BeginTransaction;
  try
    Conn.ExecuteCommand('INSERT INTO pedidos (cliente_id, valor) VALUES (1, 150.00)');
    Conn.ExecuteCommand('UPDATE estoque SET qtd = qtd - 1 WHERE produto_id = 42');
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;
```

### Metadados

```pascal
var
  Conn: IConnection;
  Tables: TStringArray;
  Columns: TStringArray;
  Structure: TArray<TDatabaseFields>;
  I: Integer;
begin
  Conn := TConnection.New.FromConfig.Connect;

  // Listar tabelas do schema 'public'
  Tables := Conn.GetTableNames('public');
  for I := 0 to High(Tables) do
    WriteLn('Tabela: ', Tables[I]);

  // Listar colunas de uma tabela
  Columns := Conn.GetColumnNames('clientes', 'public');
  for I := 0 to High(Columns) do
    WriteLn('Coluna: ', Columns[I]);

  // Estrutura completa (DDL reverso)
  Structure := Conn.GetTableStructure('clientes', 'public');
  for I := 0 to High(Structure) do
    WriteLn(Structure[I].FieldName, ' - ', Structure[I].DataTypeName,
            ' Nullable=', Structure[I].IsNullable);

  // Listar schemas e bancos
  WriteLn('Schemas: ');
  for I := 0 to High(Conn.GetSchemaNames) do
    WriteLn('  ', Conn.GetSchemaNames[I]);

  WriteLn('Bancos: ');
  for I := 0 to High(Conn.GetDatabaseNames) do
    WriteLn('  ', Conn.GetDatabaseNames[I]);
end;
```

### Validacao de DLL antes de conectar

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New
    .DatabaseType(dtPostgreSQL)
    .DllBasePath('C:\Libs\pgsql');

  if not Conn.IsRequiredDllFound then
  begin
    WriteLn('ERRO: DLL do PostgreSQL nao encontrada em C:\Libs\pgsql');
    Exit;
  end;

  Conn.Connect;
end;
```

### Versoes do servidor e cliente

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New.FromConfig.Connect;

  WriteLn('Servidor: ', Conn.GetServerVersion);
  WriteLn('Cliente:  ', Conn.GetClientVersion);
end;
```

---

## Relacionamentos

- [`TConnection`](TConnection.md) -- implementacao concreta desta interface (unit `Providers.Connection.pas`)
- [`TConnectionData`](../../Analise/Commons/TConnectionData.md) -- record retornado por `GetConnectionData` com snapshot dos dados da conexao
- [`TDatabaseEngine`](../../Analise/Commons/TDatabaseEngine.md) -- enumerador da engine ativa (propriedade `Engine`)
- [`TDatabaseTypes`](../../Analise/Commons/TDatabaseTypes.md) -- enumerador do tipo de banco (propriedade `DatabaseType`)
- [`TDatabaseFields`](../../Analise/Commons/TDatabaseFields.md) -- record retornado por `GetTableStructure` com estrutura de coluna
- [`TStringArray`](../../Analise/Commons/TStringArray.md) -- tipo array de string retornado pelos metodos de metadados
- [`TPoolConnections`](../PoolConnections/TPoolConnections.md) -- gerenciador de pool que armazena multiplas instancias de `IConnection`
- [`TTables`](../../Analise/Providers.Databases/TTables.md) -- delega para metodos de metadados de `IConnection` (GetTableNames, GetColumnNames, etc.)
- [`TEntityManager`](../../Analise/Database/TEntityManager.md) -- recebe `IConnection` para persistencia de entidades (requer `USE_ATTRIBUTES`)
- [`TQueryBuilder`](../../Analise/Database/TQueryBuilder.md) -- recebe `IConnection` para execucao de queries construidas
- `ORM.Defines.inc` -- define qual engine e compilada (`USE_FIREDAC`, `USE_UNIDAC`, `USE_ZEOS`, `USE_SQLDB`) e se `USE_ATTRIBUTES` esta ativo
- `Commons.Types.pas` -- declara `TDatabaseEngine`, `TDatabaseTypes`, `TConnectionData`, `TDatabaseFields`, `TStringArray`

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (03/04/2026): Adicionada secao "Overloads parametrizados (v2.1)" com os 3 novos overloads de ExecuteQuery/ExecuteCommand/ExecuteScalar e nota sobre FPC.
- 1.0.0 (01/04/2026): Versao inicial -- documentacao completa da interface IConnection com todas as categorias de metodos, exemplos de uso e relacionamentos.

---

## Classe — `TConnection`


> Implementacao concreta de `IConnection`. Gerencia a conexao real com o banco de dados por meio da engine selecionada em tempo de compilacao (UniDAC, FireDAC, Zeos ou SQLdb).

**Unit:** `Providers.Connection.pas`
**Tipo:** Classe (`TInterfacedObject`, implementa `IConnection`)
**Modulo:** Connections (`src/Modulos/Connections/`)
**Diretiva:** Sempre compilada; comportamento interno condicionado por `USE_FIREDAC`, `USE_UNIDAC`, `USE_ZEOS`, `USE_SQLDB` e `USE_ATTRIBUTES`

---

## O que e?

`TConnection` e a classe que implementa a interface `IConnection` e encapsula toda a logica de conexao, execucao SQL, transacoes e metadados para qualquer banco suportado pelo ProvidersORM. Internamente, ela cria e configura objetos nativos do driver selecionado (`TFDConnection`, `TUniConnection`, `TZConnection` ou `TSQLConnection`) de acordo com a diretiva de compilacao ativa.

A classe expoe a factory `TConnection.New` que retorna `IConnection`, garantindo que o consumidor sempre trabalhe contra a interface. Alem de implementar todos os metodos de `IConnection`, `TConnection` oferece funcionalidades adicionais nao expostas na interface: eventos de ciclo de vida de conexao (`OnBeforeConnect`, `OnAfterConnect`, etc.), injecao de dependencias opcionais (`SetExceptions`, `SetLogger`) e metodos de classe para validacao estatica de DLL (`IsRequiredDllFound` sem instancia).

O ciclo de vida da conexao e: configurar (fluente ou via carregamento externo) -> validar DLL -> `CreateNativeConnection` -> `ConfigureNativeConnection` -> conectar. Ao destruir, `DestroyNativeConnection` libera os objetos nativos.

---

## Caracteristicas

- **Factory pattern:** `TConnection.New` retorna `IConnection` -- o consumidor nunca precisa manipular a classe diretamente
- **Multi-engine:** compila com UniDAC, FireDAC, Zeos ou SQLdb; blocos `{$IF DEFINED(...)}` isolam o codigo especifico de cada driver
- **Multi-banco:** PostgreSQL, MySQL, SQL Server, Firebird, SQLite, Access, todos via a mesma classe
- **Eventos de ciclo de vida:** `OnBeforeConnect`, `OnAfterConnect`, `OnBeforeDisconnect`, `OnAfterDisconnect`, `OnConnectionError` (apenas na classe, nao na interface)
- **Injecao opcional:** `SetExceptions(IExceptions)` e `SetLogger(ILogger)` para integrar com o ecossistema de excecoes e logging do ORM
- **Validacao de DLL estatica:** `TConnection.IsRequiredDllFound(path, type)` permite verificar se a DLL existe **sem criar instancia**
- **Reference counting:** herda de `TInterfacedObject`; destruido automaticamente quando a ultima referencia de interface e liberada
- **Configuracao cruzada com PATH:** `AddDllDirectoryToPath` injeta o diretorio de DLLs no `%PATH%` do processo (Windows)
- **Suporte a atributos RTTI:** `FromClass`/`LoadFromClass` carrega configuracao a partir de atributos `[Connection(...)]` quando `USE_ATTRIBUTES` esta ativo

---

## Engine

A compilacao condicional determina quais objetos nativos sao criados internamente:

| Diretiva | Engine | Objetos nativos (`FConnection`, `FQuery`, `FExecQuery`) | Transacao |
|----------|--------|--------------------------------------------------------|-----------|
| `{$IF DEFINED(USE_FIREDAC)}` | FireDAC | `TFDConnection`, `TFDQuery`, `TFDQuery` | Gerenciada pelo `TFDConnection` |
| `{$IF DEFINED(USE_UNIDAC)}` | UniDAC | `TUniConnection`, `TUniQuery`, `TUniQuery` | Gerenciada pelo `TUniConnection` |
| `{$IF DEFINED(USE_ZEOS)}` | Zeos | `TZConnection`, `TZQuery`, `TZQuery` | Gerenciada pelo `TZConnection` |
| `{$IF DEFINED(USE_SQLDB)}` | SQLdb (FPC) | `TSQLConnection`, `TSQLQuery`, `TSQLQuery` | `FTransaction: TSQLTransaction` (campo adicional) |

> **Nota:** Apenas o SQLdb requer um objeto de transacao separado (`FTransaction`), pois `TSQLConnection` do Free Pascal nao gerencia transacoes internamente.

---

## Campos internos

### strict private

| Campo | Tipo | Descricao |
|-------|------|-----------|
| `FOnBeforeConnect` | `TNotifyEvent` | Evento disparado antes de conectar |
| `FOnAfterConnect` | `TNotifyEvent` | Evento disparado apos conexao bem-sucedida |
| `FOnBeforeDisconnect` | `TNotifyEvent` | Evento disparado antes de desconectar |
| `FOnAfterDisconnect` | `TNotifyEvent` | Evento disparado apos desconexao |
| `FOnConnectionError` | `TConnectionErrorEvent` | Evento disparado quando ocorre excecao em `Connect`; assinatura: `procedure(Sender: TObject; E: Exception) of object` |
| `FConnected` | `Boolean` | Estado atual da conexao (`True` = conectado) |
| `FInTransaction` | `Boolean` | Estado atual da transacao (`True` = transacao ativa) |
| `FEngine` | `TDatabaseEngine` | Engine selecionada (teFireDAC, teUnidac, teZeos, teSQLdb) |
| `FDatabaseType` | `TDatabaseTypes` | Tipo do banco configurado (dtPostgreSQL, dtMySQL, etc.) |
| `FDatabaseTypeStr` | `string` | Nome textual do tipo de banco (usado em `DatabaseType(string)`) |
| `FHost` | `string` | Host/IP do servidor |
| `FPort` | `Integer` | Porta de conexao |
| `FUsername` | `string` | Usuario de autenticacao |
| `FPassword` | `string` | Senha de autenticacao |
| `FDatabase` | `string` | Nome do banco de dados |
| `FSchema` | `string` | Schema padrao |
| `FConfigFilePath` | `string` | Caminho do arquivo de configuracao |
| `FDllBasePath` | `string` | Diretorio base para busca de DLLs nativas |

### private

| Campo | Tipo | Descricao |
|-------|------|-----------|
| `FConnection` | `TObject` | Objeto nativo de conexao (cast para tipo especifico conforme engine) |
| `FQuery` | `TObject` | Objeto nativo de query para SELECT (`ExecuteQuery`) |
| `FExecQuery` | `TObject` | Objeto nativo de query para DML (`ExecuteCommand`, `ExecuteScalar`) |
| `FExceptions` | `IExceptions` | Instancia opcional do gerenciador de excecoes do ORM |
| `FLogger` | `ILogger` | Instancia opcional do logger do ORM |
| `FTransaction` | `TObject` | Objeto nativo de transacao (`TSQLTransaction`); **apenas compilado com `USE_SQLDB`** |

---

## Metodos privados

| Metodo | Assinatura | Descricao |
|--------|-----------|-----------|
| `CreateNativeConnection` | `procedure CreateNativeConnection` | Cria os objetos nativos (`FConnection`, `FQuery`, `FExecQuery`, `FTransaction`) conforme a engine ativa |
| `ConfigureNativeConnection` | `procedure ConfigureNativeConnection` | Aplica as propriedades de configuracao (host, port, user, pass, database, schema, DLL path) nos objetos nativos |
| `DestroyNativeConnection` | `procedure DestroyNativeConnection` | Libera (`Free`) os objetos nativos criados por `CreateNativeConnection` |
| `LoadFromIniFile` | `procedure LoadFromIniFile(const AFilePath, ASection: string)` | Le arquivo `.ini` e preenche os campos de configuracao (host, port, username, password, database, database_type, schema, dll_base_path) |
| `LoadFromJSON` | `procedure LoadFromJSON(const AJSON: string)` | Faz parse de string JSON (via `fpjson`/FPC ou `System.JSON`/Delphi) e preenche os campos de configuracao |
| `ValidateRequiredDll` | `procedure ValidateRequiredDll` | Verifica se a DLL obrigatoria para o `FDatabaseType` existe em `FDllBasePath`; levanta excecao se nao encontrada |
| `LoadFromClass` | `procedure LoadFromClass(const AClass: TClass)` | Extrai atributos `[Connection(...)]` via RTTI e preenche os campos de configuracao; **apenas compilado com `USE_ATTRIBUTES`** |
| `GetTableNamesFromDriver` | `procedure GetTableNamesFromDriver(var AResult: TStringArray)` | Usa a API nativa do driver para listar tabelas (fallback quando SQL direto nao e aplicavel) |

---

## Funcionalidades

### Tabela completa de metodos publicos

#### Metodos de interface (IConnection)

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Engine` (setter) | `function Engine(const AValue: TDatabaseEngine): IConnection` | `IConnection` | Define a engine de acesso a dados |
| `Engine` (getter) | `function Engine: TDatabaseEngine` | `TDatabaseEngine` | Retorna a engine configurada |
| `DatabaseType` (setter enum) | `function DatabaseType(const AValue: TDatabaseTypes): IConnection` | `IConnection` | Define o tipo de banco via enumerador |
| `DatabaseType` (setter string) | `function DatabaseType(const AValue: string): IConnection` | `IConnection` | Define o tipo de banco via nome textual |
| `DatabaseType` (getter) | `function DatabaseType: TDatabaseTypes` | `TDatabaseTypes` | Retorna o tipo de banco configurado |
| `Host` (setter) | `function Host(const AValue: string): IConnection` | `IConnection` | Define o host/IP |
| `Host` (getter) | `function Host: string` | `string` | Retorna o host |
| `Port` (setter) | `function Port(const AValue: Integer): IConnection` | `IConnection` | Define a porta |
| `Port` (getter) | `function Port: Integer` | `Integer` | Retorna a porta |
| `Username` (setter) | `function Username(const AValue: string): IConnection` | `IConnection` | Define o usuario |
| `Username` (getter) | `function Username: string` | `string` | Retorna o usuario |
| `Password` (setter) | `function Password(const AValue: string): IConnection` | `IConnection` | Define a senha |
| `Password` (getter) | `function Password: string` | `string` | Retorna a senha |
| `Database` (setter) | `function Database(const AValue: string): IConnection` | `IConnection` | Define o nome do banco |
| `Database` (getter) | `function Database: string` | `string` | Retorna o nome do banco |
| `Schema` (setter) | `function Schema(const AValue: string): IConnection` | `IConnection` | Define o schema |
| `Schema` (getter) | `function Schema: string` | `string` | Retorna o schema |
| `ConfigFilePath` (setter) | `function ConfigFilePath(const AValue: string): IConnection` | `IConnection` | Define o caminho do arquivo de config |
| `ConfigFilePath` (getter) | `function ConfigFilePath: string` | `string` | Retorna o caminho do arquivo de config |
| `DllBasePath` (setter) | `function DllBasePath(const AValue: string): IConnection` | `IConnection` | Define o diretorio base de DLLs |
| `DllBasePath` (getter) | `function DllBasePath: string` | `string` | Retorna o diretorio base de DLLs |
| `IsRequiredDllFound` (instancia) | `function IsRequiredDllFound: Boolean` | `Boolean` | Verifica se a DLL obrigatoria existe |
| `FromIniFile` | `function FromIniFile(const AFilePath, ASection: string): IConnection` | `IConnection` | Carrega configuracao de arquivo INI |
| `FromConfig` | `function FromConfig: IConnection` | `IConnection` | Auto-detecta e carrega config de `Data/` |
| `FromJSON` | `function FromJSON(const AJSON: string): IConnection` | `IConnection` | Carrega configuracao de string JSON |
| `FromClass` | `function FromClass(const AClass: TClass): IConnection` | `IConnection` | Carrega config de atributos RTTI (`USE_ATTRIBUTES`) |
| `Connect` | `function Connect: IConnection` | `IConnection` | Conecta ao banco (valida DLL, cria objetos nativos, configura, conecta) |
| `Disconnect` | `function Disconnect: IConnection` | `IConnection` | Desconecta e destroi objetos nativos |
| `IsConnected` | `function IsConnected: Boolean` | `Boolean` | Retorna estado da conexao |
| `Ping` | `function Ping: Boolean` | `Boolean` | Testa conectividade com o servidor |
| `ExecuteQuery` | `function ExecuteQuery(const ASQL: string): TDataSet` | `TDataSet` | Executa SELECT, retorna dataset |
| `ExecuteCommand` | `function ExecuteCommand(const ASQL: string): Integer` | `Integer` | Executa DML, retorna linhas afetadas |
| `ExecuteScalar` | `function ExecuteScalar(const ASQL: string): Variant` | `Variant` | Executa SQL, retorna valor escalar |
| `BeginTransaction` | `function BeginTransaction: IConnection` | `IConnection` | Inicia transacao |
| `Commit` | `function Commit: IConnection` | `IConnection` | Confirma transacao |
| `Rollback` | `function Rollback: IConnection` | `IConnection` | Reverte transacao |
| `InTransaction` | `function InTransaction: Boolean` | `Boolean` | Retorna se ha transacao ativa |
| `GetServerVersion` | `function GetServerVersion: string` | `string` | Versao do servidor |
| `GetClientVersion` | `function GetClientVersion: string` | `string` | Versao do cliente/driver |
| `GetConnectionData` | `function GetConnectionData: TConnectionData` | `TConnectionData` | Snapshot dos dados de conexao |
| `GetTableNames` | `function GetTableNames(const ASchema: string = ''): TStringArray` | `TStringArray` | Lista tabelas (filtro por schema) |
| `GetDatabaseNames` | `function GetDatabaseNames: TStringArray` | `TStringArray` | Lista bancos no servidor |
| `GetSchemaNames` | `function GetSchemaNames(const ADatabase: string = ''): TStringArray` | `TStringArray` | Lista schemas (filtro por database) |
| `GetColumnNames` | `function GetColumnNames(const ATableName: string; const ASchema: string = ''): TStringArray` | `TStringArray` | Lista colunas de uma tabela |
| `GetTableStructure` | `function GetTableStructure(const ATableName: string; const ASchema: string = ''): TArray<TDatabaseFields>` | `TArray<TDatabaseFields>` | Estrutura completa da tabela |

#### Metodos adicionais (somente na classe, nao na interface)

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `New` | `class function New: IConnection` | `IConnection` | Factory: cria instancia de `TConnection` e retorna como `IConnection` |
| `IsRequiredDllFound` (static, por tipo) | `class function IsRequiredDllFound(const ADllBasePath: string; ADatabaseType: TDatabaseTypes): Boolean` | `Boolean` | Verifica DLL sem criar instancia (recebe enum) |
| `IsRequiredDllFound` (static, por nome) | `class function IsRequiredDllFound(const ADllBasePath, ADatabaseTypeName: string): Boolean` | `Boolean` | Verifica DLL sem criar instancia (recebe nome textual) |
| `SetExceptions` | `function SetExceptions(const AExceptions: IExceptions): IConnection` | `IConnection` | Injeta gerenciador de excecoes (opcional) |
| `SetLogger` | `function SetLogger(const ALogger: ILogger): IConnection` | `IConnection` | Injeta logger (opcional); erros de `Connect` sao logados se configurado |

#### Eventos (properties da classe)

| Evento | Tipo | Descricao |
|--------|------|-----------|
| `OnBeforeConnect` | `TNotifyEvent` | Disparado imediatamente antes de `Connect` executar a conexao nativa |
| `OnAfterConnect` | `TNotifyEvent` | Disparado imediatamente apos conexao bem-sucedida |
| `OnBeforeDisconnect` | `TNotifyEvent` | Disparado imediatamente antes de `Disconnect` encerrar a conexao |
| `OnAfterDisconnect` | `TNotifyEvent` | Disparado imediatamente apos desconexao |
| `OnConnectionError` | `TConnectionErrorEvent` | Disparado quando `Connect` captura uma excecao; recebe `Sender` (a instancia `TConnection`) e `E` (a excecao) |

#### Construtor e destrutor

| Metodo | Assinatura | Descricao |
|--------|-----------|-----------|
| `Create` | `constructor Create` | Inicializa campos com valores padrao; normalmente nao chamado diretamente (usar `New`) |
| `Destroy` | `destructor Destroy; override` | Chama `DestroyNativeConnection` e libera recursos |

---

## Queries Parametrizadas (v2.1)

Dois helpers privados dao suporte aos overloads parametrizados de `ExecuteQuery`, `ExecuteCommand` e `ExecuteScalar` introduzidos na v2.1.

### BindParams

```pascal
procedure BindParams(AQuery: TObject; const AParams: array of Variant)
```

Vincula o array de variantes ao objeto nativo de query (`FQuery` ou `FExecQuery`) antes da execucao. A estrategia de vinculacao depende da engine compilada:

| Engine | Estrategia |
|--------|-----------|
| FireDAC (`USE_FIREDAC`) | Vinculacao por nome: `Params.ParamByName('param0').Value := ...` |
| UniDAC (`USE_UNIDAC`) | Vinculacao por nome: `Params.ParamByName('param0').Value := ...` |
| SQLdb (`USE_SQLDB`) | Vinculacao por nome via `TParams.ParamByName` |
| Zeos (`USE_ZEOS`) | Vinculacao por indice: `Params[I].Value := ...` |

O parametro `AQuery` e do tipo `TObject` para manter compatibilidade com todos os blocos condicionais; cada bloco faz o cast para o tipo nativo adequado (`TFDQuery`, `TUniQuery`, `TZQuery`, `TSQLQuery`).

### NormalizeParams

```pascal
function NormalizeParams(const ASQL: string): string
```

Converte placeholders nomeados no estilo `:paramN` para o marcador posicional `?` exigido pelo ZeosLib. Ativo apenas dentro do bloco `{$IF DEFINED(USE_ZEOS)}`. Para as demais engines a funcao retorna o SQL sem alteracoes.

Exemplo: `:param0 AND :param1` e transformado em `? AND ?`.

---

## Aplicabilidades

- **Cenario mais simples:** `TConnection.New.Host('...').Database('...').Connect` -- conexao direta sem pool
- **Pool de conexoes:** `TPoolConnections` cria e gerencia multiplas instancias de `IConnection` (retornadas por `TConnection.New`)
- **Troca de engine:** mudar de UniDAC para Zeos requer apenas alterar a diretiva em `ORM.Defines.inc`; `TConnection` recompila com o novo driver, o consumidor nao muda
- **Validacao pre-deploy:** `TConnection.IsRequiredDllFound('C:\Libs', dtPostgreSQL)` -- verifica DLL sem criar conexao, util para instaladores ou verificacao de ambiente
- **Monitoramento via eventos:** atribuir handlers a `OnBeforeConnect` / `OnAfterConnect` para logging, metricas ou auditoria
- **Integracao com ecossistema ORM:** `SetExceptions` e `SetLogger` conectam a classe ao pipeline de excecoes e logging centralizado
- **Configuracao por atributos RTTI:** com `USE_ATTRIBUTES`, `FromClass(TMyDatabaseConfig)` le atributos `[Connection(...)]` para preencher todas as propriedades -- zero configuracao em codigo

---

## Exemplos de Uso

### Factory e configuracao fluente

```pascal
uses
  Providers.Connection, Providers.Connection.Interfaces, Commons.Types;

var
  Conn: IConnection;
begin
  Conn := TConnection.New
    .Engine(teZeos)
    .DatabaseType(dtMySQL)
    .Host('192.168.1.100')
    .Port(3306)
    .Username('root')
    .Password('mysql123')
    .Database('loja')
    .DllBasePath('C:\Libs\mysql')
    .Connect;

  WriteLn('Conectado: ', Conn.IsConnected);
  WriteLn('Servidor: ', Conn.GetServerVersion);
end;
```

### FromConfig (auto-deteccao de arquivo)

```pascal
var
  Conn: IConnection;
begin
  // Le automaticamente Data/config.ini, secao 'database'
  Conn := TConnection.New
    .FromConfig
    .Connect;

  // Toda a configuracao veio do arquivo
  WriteLn('Banco: ', Conn.Database, ' em ', Conn.Host, ':', Conn.Port);
end;
```

### FromJSON

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New
    .FromJSON('{' +
      '"host": "db.empresa.com",' +
      '"port": 5432,' +
      '"username": "app_user",' +
      '"password": "p@ss",' +
      '"database": "producao",' +
      '"database_type": "PostgreSQL",' +
      '"schema": "public",' +
      '"database_dll": "C:\\Libs\\pgsql"' +
    '}')
    .Connect;
end;
```

### Transacoes com tratamento de erro

```pascal
var
  Conn: IConnection;
begin
  Conn := TConnection.New.FromConfig.Connect;

  Conn.BeginTransaction;
  try
    Conn.ExecuteCommand('INSERT INTO contas (nome, saldo) VALUES (''Joao'', 1000)');
    Conn.ExecuteCommand('INSERT INTO movimentos (conta, valor) VALUES (1, -500)');

    if Conn.InTransaction then
      Conn.Commit;
  except
    on E: Exception do
    begin
      Conn.Rollback;
      WriteLn('Transacao revertida: ', E.Message);
    end;
  end;
end;
```

### Consulta de metadados

```pascal
var
  Conn: IConnection;
  Schemas, Tables, Cols: TStringArray;
  Structure: TArray<TDatabaseFields>;
  I: Integer;
begin
  Conn := TConnection.New.FromConfig.Connect;

  // Schemas do banco conectado
  Schemas := Conn.GetSchemaNames;
  for I := 0 to High(Schemas) do
    WriteLn('Schema: ', Schemas[I]);

  // Tabelas do schema 'public'
  Tables := Conn.GetTableNames('public');
  for I := 0 to High(Tables) do
    WriteLn('  Tabela: ', Tables[I]);

  // Colunas e estrutura de uma tabela
  Cols := Conn.GetColumnNames('clientes', 'public');
  for I := 0 to High(Cols) do
    WriteLn('    Coluna: ', Cols[I]);

  Structure := Conn.GetTableStructure('clientes', 'public');
  for I := 0 to High(Structure) do
    WriteLn('    ', Structure[I].FieldName, ': ',
            Structure[I].DataTypeName,
            IfThen(Structure[I].IsPrimaryKey, ' [PK]', ''),
            IfThen(Structure[I].IsForeignKey, ' [FK -> ' + Structure[I].ReferencedTable + ']', ''));
end;
```

### Eventos de ciclo de vida

```pascal
uses
  Providers.Connection, Providers.Connection.Interfaces, Commons.Types;

type
  TConnectionMonitor = class
    procedure BeforeConnect(Sender: TObject);
    procedure AfterConnect(Sender: TObject);
    procedure OnError(Sender: TObject; E: Exception);
  end;

procedure TConnectionMonitor.BeforeConnect(Sender: TObject);
begin
  WriteLn('[MONITOR] Iniciando conexao...');
end;

procedure TConnectionMonitor.AfterConnect(Sender: TObject);
begin
  WriteLn('[MONITOR] Conexao estabelecida com sucesso.');
end;

procedure TConnectionMonitor.OnError(Sender: TObject; E: Exception);
begin
  WriteLn('[MONITOR] ERRO ao conectar: ', E.Message);
end;

var
  Conn: TConnection;
  Monitor: TConnectionMonitor;
  IConn: IConnection;
begin
  Monitor := TConnectionMonitor.Create;
  try
    Conn := TConnection.Create;
    // Atribuir eventos antes de obter a interface
    Conn.OnBeforeConnect := Monitor.BeforeConnect;
    Conn.OnAfterConnect  := Monitor.AfterConnect;
    Conn.OnConnectionError := Monitor.OnError;

    IConn := Conn; // reference counting assume a partir daqui
    IConn
      .FromConfig
      .Connect;
  finally
    Monitor.Free;
  end;
end;
```

### Injecao de Exceptions e Logger

```pascal
uses
  Providers.Connection, Exceptions.Base, Loggers.Interfaces;

var
  Conn: IConnection;
  Exc: IExceptions;
  Log: ILogger;
begin
  Exc := TExceptions.New;
  Log := TLogger.New;

  Conn := TConnection.New;
  // Cast para TConnection para acessar metodos extras
  (Conn as TConnection).SetExceptions(Exc);
  (Conn as TConnection).SetLogger(Log);

  Conn.FromConfig.Connect;
  // Erros de Connect serao logados via ILogger e reportados via IExceptions
end;
```

### Validacao estatica de DLL (sem instancia)

```pascal
begin
  // Verificar antes de criar qualquer conexao
  if TConnection.IsRequiredDllFound('C:\Deploy\dll', dtPostgreSQL) then
    WriteLn('DLL PostgreSQL encontrada')
  else
    WriteLn('ERRO: libpq.dll nao encontrada em C:\Deploy\dll');

  // Variante com nome textual
  if TConnection.IsRequiredDllFound('C:\Deploy\dll', 'MySQL') then
    WriteLn('DLL MySQL encontrada');
end;
```

---

## Relacionamentos

- [`IConnection`](IConnection.md) -- interface implementada por esta classe; define o contrato publico
- [`TInterfacedObject`] -- classe-base Delphi/FPC que fornece reference counting (`_AddRef`, `_Release`, `QueryInterface`)
- [`TConnectionData`](../../Analise/Commons/TConnectionData.md) -- record retornado por `GetConnectionData`
- [`TDatabaseEngine`](../../Analise/Commons/TDatabaseEngine.md) -- enumerador da engine; campo `FEngine`
- [`TDatabaseTypes`](../../Analise/Commons/TDatabaseTypes.md) -- enumerador do tipo de banco; campo `FDatabaseType`
- [`TDatabaseFields`](../../Analise/Commons/TDatabaseFields.md) -- record retornado por `GetTableStructure`
- [`TConnectionErrorEvent`] -- tipo de evento declarado na propria unit: `procedure(Sender: TObject; E: Exception) of object`
- [`IExceptions`](../../Analise/Exceptions/IExceptions.md) -- interface do gerenciador de excecoes; injetada via `SetExceptions`
- [`ILogger`](../../Analise/Loggers/ILogger.md) -- interface de logging; injetada via `SetLogger`
- [`TPoolConnections`](../PoolConnections/TPoolConnections.md) -- gerencia multiplas instancias de `IConnection` criadas por `TConnection.New`
- [`TTables`](../../Analise/Providers.Databases/TTables.md) -- consome `IConnection` para metadados de tabela
- [`TEntityManager`](../../Analise/Database/TEntityManager.md) -- consome `IConnection` para persistencia de entidades
- [`TQueryBuilder`](../../Analise/Database/TQueryBuilder.md) -- consome `IConnection` para execucao de queries
- `ORM.Defines.inc` -- diretivas de compilacao (`USE_FIREDAC`, `USE_UNIDAC`, `USE_ZEOS`, `USE_SQLDB`, `USE_ATTRIBUTES`)
- `Commons.Types.pas` -- tipos compartilhados (`TDatabaseEngine`, `TDatabaseTypes`, `TConnectionData`, `TDatabaseFields`, `TStringArray`)
- `Commons.Consts.pas` -- constantes e mapeamento engine x banco (`TDatabaseTypeConfig`)
- `DataSet.Serialize` -- unit usada para serializacao de datasets (no `uses` da implementacao)

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.1.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.1.0 (03/04/2026): Adicionada secao "Queries Parametrizadas (v2.1)" com BindParams (vinculacao por nome para FireDAC/UniDAC/SQLdb, por indice para Zeos) e NormalizeParams (converte :paramN para ? no Zeos).
- 1.0.0 (01/04/2026): Versao inicial -- documentacao completa da classe TConnection com campos internos, metodos privados, metodos publicos, eventos, exemplos de uso e relacionamentos.
