# Arquitetura ORM e Data Access para Delphi/Free Pascal

## Visão Geral

Este documento descreve os conceitos fundamentais para a construção de uma camada de acesso a dados robusta e desacoplada em Delphi/Free Pascal, cobrindo múltiplos bancos de dados e múltiplas engines de conexão. A arquitetura segue padrões consagrados como **Identity Map**, **Unit of Work**, **Entity Manager** e **Query Builder**, permitindo que o código de negócio seja completamente independente do banco e da engine utilizados.

---

## 1. TypeDatabase

### O que é

`TypeDatabase` é uma enumeração (ou tipo enumerado) que identifica de forma unívoca qual Sistema Gerenciador de Banco de Dados (SGBD) está sendo utilizado pela aplicação. Ele funciona como um **discriminador central** que permite ao restante da arquitetura tomar decisões específicas de dialeto SQL, tipos de dados, convenções de nomenclatura e comportamentos particulares de cada banco.

### Por que é necessário

Cada SGBD possui diferenças sutis (e às vezes drásticas) em:

- **Sintaxe SQL**: `LIMIT` vs `TOP` vs `FETCH FIRST`, `RETURNING` vs `OUTPUT`, `IFNULL` vs `ISNULL` vs `COALESCE`, entre outros.
- **Tipos de dados**: `SERIAL` (PostgreSQL), `AUTO_INCREMENT` (MySQL), `IDENTITY` (SQL Server), `AUTOINCREMENT` (SQLite), `GEN_ID` com generators (Firebird), `AUTOINCREMENT` (MSAccess).
- **Geração de identificadores**: sequences, generators, identity columns, autoincrement.
- **Suporte a transações**: níveis de isolamento disponíveis, savepoints, transações implícitas.
- **Esquemas e catálogos**: PostgreSQL usa schemas (`public`, `pg_catalog`), SQL Server usa schemas (`dbo`), Firebird não possui schemas, SQLite é single-file.
- **Funções nativas**: funções de data, string, matemáticas, e conversões variam enormemente.

### Definição típica

```pascal
type
  TTypeDatabase = (
    tdPostgreSQL,
    tdMySQL,
    tdSQLServer,
    tdFirebird,
    tdSQLite,
    tdMSAccess
  );
```

### Responsabilidades

| Responsabilidade | Descrição |
|---|---|
| **Seleção de dialeto SQL** | O QueryBuilder consulta o TypeDatabase para gerar SQL compatível com o banco alvo. |
| **Mapeamento de tipos** | Ao criar tabelas ou mapear entidades, o TypeDatabase determina como um tipo lógico (ex: `ftString`, `ftInteger`, `ftGuid`) se traduz no tipo nativo do banco. |
| **Estratégia de paginação** | PostgreSQL/MySQL usam `LIMIT/OFFSET`, SQL Server usa `OFFSET FETCH` ou `TOP`, Firebird usa `FIRST/SKIP`, SQLite usa `LIMIT/OFFSET`, MSAccess usa `TOP`. |
| **Geração de DDL** | Scripts de criação de tabelas, índices e constraints mudam drasticamente entre bancos. |
| **Estratégia de ID** | Define se o banco usa sequence, generator, identity, autoincrement ou GUID. |

### Exemplo de uso no QueryBuilder

```pascal
function TQueryBuilder.BuildPagination(AOffset, ALimit: Integer): string;
begin
  case FTypeDatabase of
    tdPostgreSQL, tdMySQL, tdSQLite:
      Result := Format(' LIMIT %d OFFSET %d', [ALimit, AOffset]);
    tdSQLServer:
      Result := Format(' OFFSET %d ROWS FETCH NEXT %d ROWS ONLY', [AOffset, ALimit]);
    tdFirebird:
      Result := Format(' FIRST %d SKIP %d', [ALimit, AOffset]);
    tdMSAccess:
      Result := Format(' TOP %d', [ALimit]); // MSAccess não suporta OFFSET nativo
  end;
end;
```

---

## 2. EntityManager

### O que é

O `EntityManager` é o **ponto central de orquestração** entre a aplicação e o banco de dados. Ele é responsável por gerenciar o ciclo de vida completo das entidades (objetos de negócio), desde sua criação e carregamento até sua persistência e remoção. Ele coordena o `IdentityMap`, o `UnitOfWork`, o `QueryBuilder` e a engine de conexão.

### Analogia

Pense no EntityManager como um **gerente de armazém**: ele sabe onde cada item (entidade) está, controla o que entrou e saiu (mudanças), e delega o trabalho de transporte (SQL) para os operários (engine + QueryBuilder).

### Responsabilidades detalhadas

#### 2.1 Gerenciamento do ciclo de vida

O EntityManager rastreia em que **estado** cada entidade se encontra:

```
[Transient] --persist()--> [Managed] --flush()--> [Persisted/Clean]
[Managed] --remove()--> [Removed] --flush()--> [Deleted do banco]
[Managed] --detach()--> [Detached]
[Detached] --merge()--> [Managed]
```

- **Transient**: objeto recém-criado, sem vínculo com o banco. Não possui ID atribuído pelo banco.
- **Managed (Gerenciado)**: objeto sob controle do EntityManager. Qualquer alteração em suas propriedades será detectada e persistida no próximo `Flush`.
- **Detached (Desanexado)**: objeto que já foi gerenciado, mas foi desconectado. Alterações nele não são rastreadas.
- **Removed (Removido)**: marcado para exclusão. Será deletado no próximo `Flush`.

#### 2.2 Operações principais

```pascal
type
  IEntityManager = interface
    // Registro e persistência
    procedure Persist(AEntity: TObject);
    procedure Remove(AEntity: TObject);
    procedure Merge(AEntity: TObject);
    procedure Detach(AEntity: TObject);
    procedure Flush;
    procedure Clear;

    // Consultas
    function Find<T: class>(const AId: TValue): T;
    function FindAll<T: class>: TObjectList<T>;
    function CreateQuery<T: class>: IQueryBuilder<T>;

    // Transações
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
  end;
```

#### 2.3 Persist

Registra um objeto transient para ser inserido no banco. O EntityManager:

1. Verifica se o objeto já está no IdentityMap (evita duplicatas).
2. Lê os metadados da entidade via Attributes (nome da tabela, colunas, chave primária).
3. Registra o objeto no UnitOfWork como "novo" (`INSERT` pendente).
4. Adiciona ao IdentityMap.

#### 2.4 Find

Busca uma entidade pelo seu identificador primário:

1. Primeiro consulta o IdentityMap — se já está em memória, retorna imediatamente (sem ir ao banco).
2. Se não encontrar, usa o QueryBuilder para gerar o `SELECT` adequado.
3. Executa via engine de conexão.
4. Faz o mapeamento do resultado (dataset → objeto).
5. Registra no IdentityMap e retorna.

#### 2.5 Flush

Materializa todas as alterações pendentes no banco de dados:

1. Consulta o UnitOfWork para obter as listas de objetos novos, modificados e removidos.
2. Ordena as operações respeitando dependências (foreign keys).
3. Gera os comandos SQL via QueryBuilder.
4. Executa tudo dentro de uma transação.
5. Atualiza os IDs gerados (para inserts com auto-increment/sequence).
6. Limpa as listas de pendências no UnitOfWork.

#### 2.6 Interação com outros componentes

```
┌─────────────────────────────────────────────────────┐
│                   EntityManager                     │
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ IdentityMap │  │  UnitOfWork  │  │QueryBuilder│  │
│  └──────┬──────┘  └──────┬───────┘  └─────┬──────┘  │
│         │                │                │         │
│         └────────┬───────┘                │         │
│                  │                        │         │
│           ┌──────▼────────────────────────▼──┐      │
│           │        Engine (Conexão)          │      │
│           │  FireDAC / UniDAC / Zeos / SQLDB │      │
│           └──────────────┬───────────────────┘      │
│                          │                          │
└──────────────────────────┼──────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Banco de  │
                    │    Dados    │
                    └─────────────┘
```

---

## 3. QueryBuilder

### O que é

O `QueryBuilder` é um componente que permite a **construção programática de consultas SQL** sem que o desenvolvedor precise escrever SQL puro. Ele fornece uma API fluente (fluent interface) que encadeia métodos para montar `SELECT`, `INSERT`, `UPDATE` e `DELETE`, e ao final gera o SQL adequado ao dialeto do banco de dados configurado.

### Por que é necessário

- **Portabilidade**: o mesmo código gera SQL correto para PostgreSQL, MySQL, SQL Server, Firebird, SQLite e MSAccess.
- **Segurança**: parâmetros são tratados como bindings, eliminando SQL Injection.
- **Manutenibilidade**: alterações na estrutura da query são feitas em código tipado, não em strings concatenadas.
- **Composição**: queries podem ser montadas condicionalmente, reutilizadas e compostas.

### Anatomia de uma query fluente

```pascal
var
  Pessoas: TObjectList<TPessoa>;
begin
  Pessoas := EntityManager.CreateQuery<TPessoa>
    .Select(['Nome', 'Email', 'DataNascimento'])
    .Where('Ativo = :pAtivo')
    .SetParam('pAtivo', True)
    .Where('Cidade = :pCidade')       // AND implícito
    .SetParam('pCidade', 'Brasília')
    .OrderBy('Nome')
    .Limit(50)
    .Offset(0)
    .ToList;
end;
```

### Componentes internos do QueryBuilder

#### 3.1 Cláusulas

Cada cláusula SQL é armazenada internamente como uma estrutura separada:

```pascal
type
  TQueryBuilder<T: class> = class(TInterfacedObject, IQueryBuilder<T>)
  private
    FSelectFields: TList<string>;
    FWhereConditions: TList<string>;
    FOrderByFields: TList<string>;
    FGroupByFields: TList<string>;
    FHavingConditions: TList<string>;
    FJoins: TList<TJoinClause>;
    FParams: TDictionary<string, TValue>;
    FLimit: Integer;
    FOffset: Integer;
    FTypeDatabase: TTypeDatabase;
    FTableName: string;    // extraído dos Attributes da entidade T
    FTableAlias: string;
  end;
```

#### 3.2 Geração SQL por dialeto

O método `ToSQL` monta o SQL final considerando o `TTypeDatabase`:

```pascal
function TQueryBuilder<T>.ToSQL: string;
begin
  Result := 'SELECT ' + BuildSelectClause
          + ' FROM ' + FTableName + ' ' + FTableAlias
          + BuildJoinClause
          + BuildWhereClause
          + BuildGroupByClause
          + BuildHavingClause
          + BuildOrderByClause
          + BuildPaginationClause;  // varia por banco
end;
```

#### 3.3 Tipos de Join

```pascal
type
  TJoinType = (jtInner, jtLeft, jtRight, jtFull, jtCross);

// Uso:
Query
  .Join(jtLeft, 'Pedidos', 'p', 'p.ClienteId = c.Id')
  .Join(jtInner, 'ItensPedido', 'i', 'i.PedidoId = p.Id');
```

#### 3.4 Subqueries

```pascal
Query
  .Where('DepartamentoId IN (' +
    SubQuery
      .Select(['Id'])
      .From('Departamentos')
      .Where('Ativo = :pAtivo')
      .ToSQL
  + ')');
```

#### 3.5 Operações DML

O QueryBuilder também gera `INSERT`, `UPDATE` e `DELETE`, normalmente chamados internamente pelo EntityManager durante o `Flush`:

```pascal
// INSERT
function BuildInsert(AEntity: TObject): string;
// Gera: INSERT INTO Pessoas (Nome, Email) VALUES (:pNome, :pEmail)
// PostgreSQL adiciona: RETURNING Id
// SQL Server adiciona: OUTPUT INSERTED.Id
// Firebird adiciona: RETURNING Id
// MySQL/SQLite: usa LAST_INSERT_ID() / last_insert_rowid() após o insert
// MSAccess: usa @@IDENTITY após o insert

// UPDATE
function BuildUpdate(AEntity: TObject): string;
// Gera: UPDATE Pessoas SET Nome = :pNome, Email = :pEmail WHERE Id = :pId

// DELETE
function BuildDelete(AEntity: TObject): string;
// Gera: DELETE FROM Pessoas WHERE Id = :pId
```

---

## 4. IdentityMap

### O que é

O `IdentityMap` é um **cache de primeiro nível** que garante que, dentro de um mesmo contexto (sessão/EntityManager), cada registro do banco de dados seja representado por **uma única instância de objeto** em memória. É um padrão descrito por Martin Fowler no livro *Patterns of Enterprise Application Architecture*.

### Problema que resolve

Sem o IdentityMap, o seguinte cenário seria problemático:

```pascal
var
  Cliente1, Cliente2: TCliente;
begin
  Cliente1 := EntityManager.Find<TCliente>(42);
  Cliente2 := EntityManager.Find<TCliente>(42);

  // SEM IdentityMap: Cliente1 <> Cliente2 (dois objetos diferentes!)
  // Alterar Cliente1.Nome não afeta Cliente2.
  // Qual versão é a "certa"? Conflito garantido.

  // COM IdentityMap: Cliente1 = Cliente2 (mesma instância!)
  // Qualquer alteração é vista por ambas as referências.
end;
```

### Implementação típica

A chave do mapa é composta pelo **tipo da entidade + valor da chave primária**:

```pascal
type
  TIdentityMap = class
  private
    FMap: TDictionary<string, TObject>;

    function BuildKey(AClass: TClass; const AId: TValue): string;
  public
    function Contains(AClass: TClass; const AId: TValue): Boolean;
    function Get(AClass: TClass; const AId: TValue): TObject;
    procedure Put(AClass: TClass; const AId: TValue; AEntity: TObject);
    procedure Remove(AClass: TClass; const AId: TValue);
    procedure Clear;
  end;

function TIdentityMap.BuildKey(AClass: TClass; const AId: TValue): string;
begin
  // Exemplo: "TCliente#42", "TPedido#1001"
  Result := AClass.ClassName + '#' + AId.ToString;
end;
```

### Fluxo de consulta com IdentityMap

```
Find<TCliente>(42)
       │
       ▼
┌──────────────┐    SIM    ┌─────────────────┐
│ Está no Map? │──────────>│Retorna instância│
└──────┬───────┘           │  existente      │
       │ NÃO               └─────────────────┘
       ▼
┌──────────────┐
│ Executa SQL  │
│ via Engine   │
└──────┬───────┘
       ▼
┌──────────────┐
│ Mapeia para  │
│ objeto       │
└──────┬───────┘
       ▼
┌──────────────┐
│ Armazena no  │
│ IdentityMap  │
└──────┬───────┘
       ▼
┌──────────────┐
│ Retorna nova │
│ instância    │
└──────────────┘
```

### Benefícios

- **Consistência**: garante uma única versão da verdade por entidade.
- **Performance**: evita idas desnecessárias ao banco para objetos já carregados.
- **Integridade referencial em memória**: se duas entidades referenciam o mesmo `TCliente`, ambas apontam para o mesmo objeto.
- **Detecção de mudanças**: o UnitOfWork pode comparar o estado atual do objeto com um snapshot armazenado no momento do carregamento.

### Considerações

- O IdentityMap deve ser **escopado** ao tempo de vida do EntityManager (sessão). Um EntityManager de vida longa pode consumir muita memória.
- Ao chamar `Clear` no EntityManager, o IdentityMap é limpo também.
- Entidades removidas devem ser retiradas do IdentityMap após o `Flush`.

---

## 5. UnitOfWork

### O que é

O `UnitOfWork` é o padrão responsável por **rastrear todas as mudanças** feitas em entidades gerenciadas e **consolidá-las em uma única transação** no momento do `Flush`. Ele funciona como um "caderno de anotações" que registra o que foi inserido, modificado e removido, para depois executar tudo de uma vez.

### Problema que resolve

Sem o UnitOfWork, cada alteração em uma entidade geraria imediatamente um comando SQL, resultando em:

- Muitas transações pequenas (ineficiente).
- Dificuldade em manter consistência (se a terceira de cinco operações falhar, as duas primeiras já foram commitadas).
- Impossibilidade de otimizar a ordem das operações (respeitar foreign keys).

### Estados rastreados

```pascal
type
  TUnitOfWork = class
  private
    FNewEntities: TList<TObject>;       // Para INSERT
    FDirtyEntities: TList<TObject>;     // Para UPDATE
    FRemovedEntities: TList<TObject>;   // Para DELETE
    FCleanSnapshots: TDictionary<TObject, TEntitySnapshot>;
  public
    procedure RegisterNew(AEntity: TObject);
    procedure RegisterDirty(AEntity: TObject);
    procedure RegisterRemoved(AEntity: TObject);
    procedure RegisterClean(AEntity: TObject; ASnapshot: TEntitySnapshot);

    function GetNewEntities: TList<TObject>;
    function GetDirtyEntities: TList<TObject>;
    function GetRemovedEntities: TList<TObject>;

    procedure Commit;   // Chamado pelo Flush do EntityManager
    procedure Rollback;
    procedure Clear;
  end;
```

### Detecção de mudanças (Dirty Checking)

Existem duas estratégias principais:

#### 5.1 Snapshot-based (comparação de estado)

No momento em que a entidade é carregada do banco ou registrada como `Clean`, um snapshot (cópia dos valores) é salvo. No momento do `Flush`, os valores atuais são comparados com o snapshot:

```pascal
procedure TUnitOfWork.DetectChanges;
var
  Entity: TObject;
  Snapshot: TEntitySnapshot;
begin
  for Entity in FIdentityMap.AllEntities do
  begin
    Snapshot := FCleanSnapshots[Entity];
    if not Snapshot.Equals(Entity) then
      RegisterDirty(Entity);
  end;
end;
```

#### 5.2 Proxy-based (interceptação de setters)

Cada entidade é envolvida por um proxy que intercepta chamadas a setters de propriedades. Quando um setter é chamado, o proxy marca automaticamente a entidade como dirty. Essa abordagem é mais complexa em Delphi/FPC mas pode ser implementada com virtual method interception ou eventos.

### Ordenação de operações no Flush

O UnitOfWork deve respeitar a ordem correta para evitar violações de constraints:

1. **INSERT** em tabelas pais (sem dependências).
2. **INSERT** em tabelas filhas (que dependem das pais).
3. **UPDATE** em qualquer ordem (IDs já existem).
4. **DELETE** em tabelas filhas primeiro.
5. **DELETE** em tabelas pais por último.

### Diagrama do fluxo de Flush

```
Flush() chamado
       │
       ▼
┌──────────────────┐
│ DetectChanges()  │  ← compara snapshots
└──────┬───────────┘
       ▼
┌──────────────────┐
│ Ordenar operações│  ← respeitar FK
└──────┬───────────┘
       ▼
┌──────────────────┐
│ BEGIN TRANSACTION│
└──────┬───────────┘
       ▼
┌──────────────────┐
│ Executar INSERTs │ ← atualizar IDs gerados
└──────┬───────────┘
       ▼
┌──────────────────┐
│ Executar UPDATEs │
└──────┬───────────┘
       ▼
┌──────────────────┐
│ Executar DELETEs │
└──────┬───────────┘
       ▼
┌──────────────────┐
│    COMMIT        │
└──────┬───────────┘
       ▼
┌──────────────────┐
│ Limpar listas    │
│ Atualizar snaps  │
└──────────────────┘
```

---

## 6. Attributes (Atributos de Mapeamento)

### O que é

Attributes são **anotações declarativas** aplicadas a classes e propriedades que definem como uma entidade Delphi/FPC se mapeia para uma tabela e colunas no banco de dados. Eles são o mecanismo de **metadados** que o EntityManager, QueryBuilder e outros componentes consultam para saber como tratar cada entidade.

Em Delphi (desde XE e superiores), utiliza-se o recurso de **Custom Attributes** com RTTI avançado. Em Free Pascal, o suporte a attributes é mais limitado, sendo comum usar uma abordagem baseada em registro de metadados via código ou arquivos de configuração.

### Attributes fundamentais

#### 6.1 Mapeamento de tabela

```pascal
type
  TableAttribute = class(TCustomAttribute)
  private
    FName: string;
    FSchema: string;
  public
    constructor Create(const AName: string; const ASchema: string = '');
    property Name: string read FName;
    property Schema: string read FSchema;
  end;
```

Uso:

```pascal
[Table('clientes', 'public')]
TCliente = class
end;
```

#### 6.2 Mapeamento de coluna

```pascal
type
  ColumnAttribute = class(TCustomAttribute)
  private
    FName: string;
    FFieldType: TFieldType;
    FLength: Integer;
    FPrecision: Integer;
    FScale: Integer;
    FNullable: Boolean;
  public
    constructor Create(const AName: string;
                       AFieldType: TFieldType = ftString;
                       ALength: Integer = 255;
                       ANullable: Boolean = True);
    property Name: string read FName;
    property FieldType: TFieldType read FFieldType;
    property Length: Integer read FLength;
    property Nullable: Boolean read FNullable;
  end;
```

#### 6.3 Chave primária

```pascal
type
  PrimaryKeyAttribute = class(TCustomAttribute)
  end;

  AutoIncrementAttribute = class(TCustomAttribute)
  end;

  SequenceAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const ASequenceName: string);
    property Name: string read FName;
  end;
```

#### 6.4 Relacionamentos

```pascal
type
  ForeignKeyAttribute = class(TCustomAttribute)
  private
    FColumnName: string;
    FReferenceTable: string;
    FReferenceColumn: string;
  public
    constructor Create(const AColumn, ARefTable, ARefColumn: string);
  end;

  HasManyAttribute = class(TCustomAttribute)
  private
    FForeignKey: string;
  public
    constructor Create(const AForeignKey: string);
  end;

  BelongsToAttribute = class(TCustomAttribute)
  private
    FForeignKey: string;
  public
    constructor Create(const AForeignKey: string);
  end;
```

#### 6.5 Validação e constraints

```pascal
type
  NotNullAttribute = class(TCustomAttribute)
  end;

  UniqueAttribute = class(TCustomAttribute)
  end;

  IndexAttribute = class(TCustomAttribute)
  private
    FName: string;
    FUnique: Boolean;
  public
    constructor Create(const AName: string; AUnique: Boolean = False);
  end;

  DefaultValueAttribute = class(TCustomAttribute)
  private
    FValue: string;
  public
    constructor Create(const AValue: string);
  end;
```

### Exemplo completo de entidade mapeada

```pascal
[Table('clientes', 'public')]
TCliente = class
private
  FId: Int64;
  FNome: string;
  FEmail: string;
  FDataCadastro: TDateTime;
  FAtivo: Boolean;
  FLimiteCredito: Currency;
  FCidadeId: Int64;
  FPedidos: TObjectList<TPedido>;
public
  [PrimaryKey]
  [AutoIncrement]
  [Column('id', ftLargeint)]
  property Id: Int64 read FId write FId;

  [Column('nome', ftString, 150)]
  [NotNull]
  property Nome: string read FNome write FNome;

  [Column('email', ftString, 255)]
  [Unique]
  property Email: string read FEmail write FEmail;

  [Column('data_cadastro', ftDateTime)]
  [DefaultValue('CURRENT_TIMESTAMP')]
  property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

  [Column('ativo', ftBoolean)]
  [DefaultValue('true')]
  property Ativo: Boolean read FAtivo write FAtivo;

  [Column('limite_credito', ftCurrency)]
  property LimiteCredito: Currency read FLimiteCredito write FLimiteCredito;

  [Column('cidade_id', ftLargeint)]
  [ForeignKey('cidade_id', 'cidades', 'id')]
  property CidadeId: Int64 read FCidadeId write FCidadeId;

  [HasMany('cliente_id')]
  property Pedidos: TObjectList<TPedido> read FPedidos write FPedidos;
end;
```

### Leitura dos Attributes via RTTI

```pascal
procedure TMetadataReader.ReadEntityMetadata(AClass: TClass): TEntityMetadata;
var
  RttiCtx: TRttiContext;
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  Attr: TCustomAttribute;
begin
  RttiCtx := TRttiContext.Create;
  try
    RttiType := RttiCtx.GetType(AClass);

    // Lê atributo de tabela
    for Attr in RttiType.GetAttributes do
      if Attr is TableAttribute then
      begin
        Result.TableName := TableAttribute(Attr).Name;
        Result.Schema := TableAttribute(Attr).Schema;
      end;

    // Lê atributos de cada propriedade
    for RttiProp in RttiType.GetProperties do
      for Attr in RttiProp.GetAttributes do
      begin
        if Attr is ColumnAttribute then
          // Mapeia propriedade → coluna
        else if Attr is PrimaryKeyAttribute then
          // Marca como PK
        else if Attr is ForeignKeyAttribute then
          // Registra FK
        // ...
      end;
  finally
    RttiCtx.Free;
  end;
end;
```

---

## 7. Engines de Conexão

As engines de conexão são as bibliotecas que efetivamente se comunicam com os drivers dos bancos de dados. A arquitetura proposta abstrai a engine por trás de uma interface comum, permitindo trocar de engine sem impacto no restante do código.

### Interface comum de abstração

```pascal
type
  IDBConnection = interface
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
    function CreateQuery(const ASQL: string): IDBQuery;
    function CreateCommand(const ASQL: string): IDBCommand;
  end;

  IDBQuery = interface
    procedure SetParam(const AName: string; const AValue: TValue);
    procedure Open;
    function Eof: Boolean;
    procedure Next;
    function FieldByName(const AName: string): TValue;
    function RecordCount: Integer;
    procedure Close;
  end;

  IDBCommand = interface
    procedure SetParam(const AName: string; const AValue: TValue);
    function Execute: Integer;     // retorna rows affected
    function ExecuteReturning(const AField: string): TValue;
  end;
```

---

### 7.1 FireDAC

#### Visão geral

FireDAC é a engine de acesso a dados **nativa e oficial** do Delphi (Embarcadero), disponível desde o Delphi XE5. É a mais completa e integrada ao ecossistema RAD Studio. Não está disponível para Free Pascal.

#### Características

- **Drivers nativos** para todos os bancos suportados (PostgreSQL, MySQL, SQL Server, Firebird, SQLite, MSAccess e muitos outros).
- **Array DML**: permite enviar lotes de comandos em uma única roundtrip (altíssima performance para bulk inserts).
- **Macros de portabilidade**: `{IF PostgreSQL}...{ELSE}...{ENDIF}` dentro do SQL.
- **Mapeamento automático de tipos**: converte tipos Delphi para tipos do banco e vice-versa.
- **Conexão com pooling** integrado.
- **Suporte a LiveBindings** para ligação visual.
- **Cached Updates**: permite trabalhar offline e sincronizar.
- **Trace e monitoramento** nativos (TFDMoniFlatFileClientLink, TFDMoniRemoteClientLink).

#### Componentes-chave

| Componente | Função |
|---|---|
| `TFDConnection` | Conexão ao banco |
| `TFDQuery` | Execução de consultas e comandos |
| `TFDCommand` | Execução de comandos sem retorno de dados |
| `TFDTransaction` | Controle explícito de transações |
| `TFDManager` | Gerenciamento centralizado de conexões |
| `TFDPhysPgDriverLink` | Driver PostgreSQL |
| `TFDPhysMySQLDriverLink` | Driver MySQL |
| `TFDPhysMSSQLDriverLink` | Driver SQL Server |
| `TFDPhysFBDriverLink` | Driver Firebird |
| `TFDPhysSQLiteDriverLink` | Driver SQLite |
| `TFDPhysMSAccessDriverLink` | Driver MSAccess |

#### Implementação da abstração

```pascal
type
  TFireDACConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnection: TFDConnection;
    FTransaction: TFDTransaction;
  public
    constructor Create(const AConnectionString: string; ATypeDB: TTypeDatabase);
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
    function CreateQuery(const ASQL: string): IDBQuery;
    function CreateCommand(const ASQL: string): IDBCommand;
  end;

constructor TFireDACConnection.Create(const AConnectionString: string;
  ATypeDB: TTypeDatabase);
begin
  FConnection := TFDConnection.Create(nil);
  FTransaction := TFDTransaction.Create(nil);
  FTransaction.Connection := FConnection;
  FConnection.Transaction := FTransaction;

  case ATypeDB of
    tdPostgreSQL: FConnection.DriverName := 'PG';
    tdMySQL:      FConnection.DriverName := 'MySQL';
    tdSQLServer:  FConnection.DriverName := 'MSSQL';
    tdFirebird:   FConnection.DriverName := 'FB';
    tdSQLite:     FConnection.DriverName := 'SQLite';
    tdMSAccess:   FConnection.DriverName := 'MSAcc';
  end;

  FConnection.ConnectionString := AConnectionString;
  FConnection.LoginPrompt := False;
end;
```

#### Strengths e limitações

| Aspecto | Detalhe |
|---|---|
| Plataforma | Apenas Delphi (Windows, macOS, iOS, Android, Linux) |
| Licença | Incluída no Delphi Professional e superiores |
| Performance | Excelente, especialmente com Array DML |
| Facilidade | Alta integração com IDE e RAD |
| Multi-banco | Sim, via drivers específicos |
| Cross-compile FPC | Não disponível |

---

### 7.2 UniDAC (Universal Data Access Components)

#### Visão geral

UniDAC é uma biblioteca comercial da **Devart** que fornece acesso direto (sem necessidade de bibliotecas cliente em muitos casos) a uma grande variedade de bancos de dados. Funciona com **Delphi e Lazarus/Free Pascal**.

#### Características

- **Modo direto**: para PostgreSQL, MySQL, SQL Server, SQLite, InterBase/Firebird — conecta sem instalar bibliotecas cliente.
- **Cross-platform**: Windows, macOS, Linux, iOS, Android.
- **Compatível com Delphi e Free Pascal/Lazarus**.
- **API consistente** entre bancos.
- **Data Type Mapping** avançado.
- **Smart Fetch**: busca registros sob demanda para datasets muito grandes.
- **Encryption** integrada para SQLite.
- **Macros** para portabilidade de SQL.
- **Connection Pooling** integrado.

#### Componentes-chave

| Componente | Função |
|---|---|
| `TUniConnection` | Conexão ao banco |
| `TUniQuery` | Execução de consultas |
| `TUniSQL` | Execução de comandos sem dataset |
| `TUniTransaction` | Controle de transações |
| `TPgSQLUniProvider` | Provider PostgreSQL |
| `TMySQLUniProvider` | Provider MySQL |
| `TSQLServerUniProvider` | Provider SQL Server |
| `TInterBaseUniProvider` | Provider Firebird/InterBase |
| `TSQLiteUniProvider` | Provider SQLite |
| `TAccessUniProvider` | Provider MSAccess |

#### Implementação da abstração

```pascal
type
  TUniDACConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnection: TUniConnection;
  public
    constructor Create(const AConnectionString: string; ATypeDB: TTypeDatabase);
    // ... implementação segue o mesmo padrão da interface IDBConnection
  end;

constructor TUniDACConnection.Create(const AConnectionString: string;
  ATypeDB: TTypeDatabase);
begin
  FConnection := TUniConnection.Create(nil);

  case ATypeDB of
    tdPostgreSQL: FConnection.ProviderName := 'PostgreSQL';
    tdMySQL:      FConnection.ProviderName := 'MySQL';
    tdSQLServer:  FConnection.ProviderName := 'SQL Server';
    tdFirebird:   FConnection.ProviderName := 'InterBase';
    tdSQLite:     FConnection.ProviderName := 'SQLite';
    tdMSAccess:   FConnection.ProviderName := 'Access';
  end;

  FConnection.ConnectString := AConnectionString;
  FConnection.LoginPrompt := False;
end;
```

#### Strengths e limitações

| Aspecto | Detalhe |
|---|---|
| Plataforma | Delphi e Free Pascal (Windows, macOS, Linux, iOS, Android) |
| Licença | Comercial (Devart) |
| Modo direto | Sim, para a maioria dos bancos |
| Performance | Muito boa, especialmente em modo direto |
| Cross-compile FPC | Sim |
| Custo | Licença paga por desenvolvedor |

---

### 7.3 Zeos (ZeosLib)

#### Visão geral

ZeosLib é uma biblioteca **open source** (LGPL) de acesso a dados que suporta Delphi e Free Pascal/Lazarus. É amplamente utilizada na comunidade Free Pascal e oferece acesso nativo a vários bancos.

#### Características

- **Open source** (LGPL modificada — pode ser usada em projetos comerciais).
- **Suporta Delphi e Free Pascal/Lazarus**.
- **Drivers nativos** que se comunicam diretamente com as bibliotecas cliente dos bancos.
- **API TDataSet** padrão — componentes visuais como `TZQuery`, `TZReadOnlyQuery`, `TZTable`.
- **Suporte a prepared statements**.
- **Metadados**: leitura de estrutura do banco (tabelas, colunas, índices).
- Comunidade ativa e atualizado para bancos recentes.

#### Componentes-chave

| Componente | Função |
|---|---|
| `TZConnection` | Conexão ao banco |
| `TZQuery` | Consulta com dataset editável |
| `TZReadOnlyQuery` | Consulta somente leitura (mais performática) |
| `TZTable` | Acesso direto a tabela |
| `TZSQLProcessor` | Execução de scripts SQL |
| `TZSQLMonitor` | Monitoramento de SQL |

#### Protocolos de conexão

Cada banco é identificado por um protocolo string:

| Banco | Protocolo |
|---|---|
| PostgreSQL | `postgresql`, `postgresql-9`, etc. |
| MySQL | `mysql`, `mariadb-5`, etc. |
| SQL Server | `mssql`, `ado` |
| Firebird | `firebird`, `firebird-3.0`, etc. |
| SQLite | `sqlite`, `sqlite-3` |
| MSAccess | `ado` (via OLE DB/ODBC) |

#### Implementação da abstração

```pascal
type
  TZeosConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnection: TZConnection;
  public
    constructor Create(const AConnectionString: string; ATypeDB: TTypeDatabase);
    // ...
  end;

constructor TZeosConnection.Create(const AConnectionString: string;
  ATypeDB: TTypeDatabase);
begin
  FConnection := TZConnection.Create(nil);

  case ATypeDB of
    tdPostgreSQL: FConnection.Protocol := 'postgresql';
    tdMySQL:      FConnection.Protocol := 'mysql';
    tdSQLServer:  FConnection.Protocol := 'mssql';
    tdFirebird:   FConnection.Protocol := 'firebird';
    tdSQLite:     FConnection.Protocol := 'sqlite-3';
    tdMSAccess:   FConnection.Protocol := 'ado';
  end;

  // Parse connection string para Host, Port, Database, User, Password
  ParseConnectionString(AConnectionString, FConnection);
  FConnection.LoginPrompt := False;
end;
```

#### Strengths e limitações

| Aspecto | Detalhe |
|---|---|
| Plataforma | Delphi e Free Pascal (Windows, Linux, macOS) |
| Licença | Open source (LGPL modificada) |
| Custo | Gratuito |
| Performance | Boa, mas inferior a FireDAC e UniDAC em cenários específicos |
| Modo direto | Requer bibliotecas cliente instaladas |
| Documentação | Razoável, comunidade ativa |
| Cross-compile FPC | Sim |

---

### 7.4 SQLDB

#### Visão geral

SQLDB é a engine de acesso a dados **nativa do Free Pascal/Lazarus**, incluída na FCL (Free Component Library). É a opção padrão para projetos FPC que não querem dependências externas.

#### Características

- **Incluída no Free Pascal** — sem instalação adicional.
- **Multiplataforma**: Windows, Linux, macOS, FreeBSD, etc.
- **Conectores específicos** para cada banco.
- **API TDataSet** padrão.
- **Transações explícitas** obrigatórias (design seguro).
- **Suporte a prepared statements**.
- Mais simples e leve que as outras engines.

#### Componentes-chave

| Componente | Função |
|---|---|
| `TSQLConnection` | Classe base abstrata de conexão |
| `TPQConnection` | Conector PostgreSQL |
| `TMySQL80Connection` | Conector MySQL 8.0 |
| `TMSSQLConnection` | Conector SQL Server (via FreeTDS) |
| `TIBConnection` | Conector Firebird/InterBase |
| `TSQLite3Connection` | Conector SQLite |
| `TODBCConnection` | Conector ODBC (para MSAccess e outros) |
| `TSQLQuery` | Execução de consultas e comandos |
| `TSQLTransaction` | Controle de transações |

#### Implementação da abstração

```pascal
type
  TSQLDBConnection = class(TInterfacedObject, IDBConnection)
  private
    FConnection: TSQLConnection;
    FTransaction: TSQLTransaction;
  public
    constructor Create(const AConnectionString: string; ATypeDB: TTypeDatabase);
    // ...
  end;

constructor TSQLDBConnection.Create(const AConnectionString: string;
  ATypeDB: TTypeDatabase);
begin
  case ATypeDB of
    tdPostgreSQL:
      FConnection := TPQConnection.Create(nil);
    tdMySQL:
      FConnection := TMySQL80Connection.Create(nil);
    tdSQLServer:
      FConnection := TMSSQLConnection.Create(nil);
    tdFirebird:
      FConnection := TIBConnection.Create(nil);
    tdSQLite:
      FConnection := TSQLite3Connection.Create(nil);
    tdMSAccess:
      FConnection := TODBCConnection.Create(nil);
  end;

  FTransaction := TSQLTransaction.Create(nil);
  FTransaction.DataBase := FConnection;
  FConnection.Transaction := FTransaction;

  // Parse connection string e configurar
  ParseConnectionString(AConnectionString, FConnection);
  FConnection.LoginPrompt := False;
end;
```

#### Strengths e limitações

| Aspecto | Detalhe |
|---|---|
| Plataforma | Free Pascal (Windows, Linux, macOS, FreeBSD, etc.) |
| Licença | Open source (LGPL) — parte do FPC |
| Custo | Gratuito |
| Performance | Boa para uso geral |
| Simplicidade | Alta — poucos componentes, API direta |
| Requer libs cliente | Sim, para todos os bancos exceto SQLite |
| Delphi | Não disponível |
| Features avançadas | Limitadas comparado a FireDAC/UniDAC |

---

### Comparativo geral das engines

| Critério | FireDAC | UniDAC | Zeos | SQLDB |
|---|---|---|---|---|
| **Delphi** | Sim | Sim | Sim | Não |
| **Free Pascal** | Não | Sim | Sim | Sim |
| **Licença** | Inclusa no Delphi | Comercial | Open source | Open source |
| **PostgreSQL** | Sim | Sim | Sim | Sim |
| **MySQL** | Sim | Sim | Sim | Sim |
| **SQL Server** | Sim | Sim | Sim | Sim |
| **Firebird** | Sim | Sim | Sim | Sim |
| **SQLite** | Sim | Sim | Sim | Sim |
| **MSAccess** | Sim | Sim | Via ADO | Via ODBC |
| **Modo direto** | Parcial | Sim | Não | Não |
| **Array DML** | Sim | Sim | Limitado | Não |
| **Connection Pool** | Sim | Sim | Não nativo | Não nativo |
| **Monitoramento** | Sim | Sim | Sim | Básico |

---

## 8. Bancos de Dados — Características e Particularidades

### 8.1 PostgreSQL

#### Visão geral

PostgreSQL é um SGBD **relacional-objeto open source**, considerado o mais avançado em termos de conformidade com o padrão SQL e extensibilidade. É amplamente utilizado em aplicações de missão crítica.

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **Schemas** | Suporta múltiplos schemas por banco (`public`, `audit`, etc.) |
| **Sequences** | Mecanismo principal para geração de IDs (`CREATE SEQUENCE`, `NEXTVAL`) |
| **SERIAL/BIGSERIAL** | Atalho para coluna + sequence + default |
| **IDENTITY** | Suportado a partir do PostgreSQL 10 (`GENERATED ALWAYS AS IDENTITY`) |
| **RETURNING** | Retorna valores de colunas após INSERT/UPDATE/DELETE |
| **JSON/JSONB** | Tipos nativos para dados semiestruturados |
| **Arrays** | Colunas podem armazenar arrays nativos |
| **Tipos customizados** | ENUM, composite types, domain types |
| **Full-text search** | Busca textual avançada nativa |
| **Transações** | ACID completo, múltiplos níveis de isolamento, savepoints |
| **Concorrência** | MVCC (Multi-Version Concurrency Control) |
| **Extensões** | PostGIS, pg_trgm, hstore, uuid-ossp, etc. |

#### Dialeto SQL — particularidades

```sql
-- Paginação
SELECT * FROM clientes ORDER BY nome LIMIT 50 OFFSET 100;

-- Insert com retorno de ID
INSERT INTO clientes (nome, email) VALUES ('João', 'joao@email.com')
  RETURNING id;

-- Upsert (INSERT ... ON CONFLICT)
INSERT INTO clientes (email, nome) VALUES ('joao@email.com', 'João Silva')
  ON CONFLICT (email) DO UPDATE SET nome = EXCLUDED.nome;

-- Boolean nativo
SELECT * FROM clientes WHERE ativo = true;

-- String concatenation
SELECT nome || ' - ' || email FROM clientes;
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo PostgreSQL |
|---|---|
| `Integer` | `INTEGER` |
| `Int64` | `BIGINT` |
| `string` | `VARCHAR(n)` ou `TEXT` |
| `Boolean` | `BOOLEAN` |
| `TDateTime` | `TIMESTAMP` |
| `TDate` | `DATE` |
| `TTime` | `TIME` |
| `Currency` | `NUMERIC(18,4)` |
| `Double` | `DOUBLE PRECISION` |
| `TBytes` / `TStream` | `BYTEA` |
| `TGUID` | `UUID` |

---

### 8.2 MySQL

#### Visão geral

MySQL é um dos SGBDs mais populares do mundo, especialmente em aplicações web. Pertence à Oracle Corporation. Existe também o fork MariaDB, amplamente compatível.

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **AUTO_INCREMENT** | Mecanismo principal de geração de IDs |
| **Storage Engines** | InnoDB (padrão, transacional), MyISAM (legado, sem transações) |
| **Sem schemas** | Cada banco de dados funciona como um namespace (sem sub-schemas) |
| **LAST_INSERT_ID()** | Função para obter o ID gerado no último insert |
| **Collation** | Importante: `utf8mb4` para suporte completo a Unicode |
| **JSON** | Tipo nativo a partir do MySQL 5.7 |
| **Transações** | ACID com InnoDB; sem transações com MyISAM |
| **Full-text** | Suportado em InnoDB (MySQL 5.6+) e MyISAM |
| **Replicação** | Master-slave nativa |

#### Dialeto SQL — particularidades

```sql
-- Paginação
SELECT * FROM clientes ORDER BY nome LIMIT 50 OFFSET 100;

-- Insert — ID obtido após execução
INSERT INTO clientes (nome, email) VALUES ('João', 'joao@email.com');
-- Em seguida: SELECT LAST_INSERT_ID();

-- Upsert
INSERT INTO clientes (email, nome) VALUES ('joao@email.com', 'João Silva')
  ON DUPLICATE KEY UPDATE nome = VALUES(nome);

-- Boolean (armazenado como TINYINT)
SELECT * FROM clientes WHERE ativo = 1;

-- Backticks para identificadores reservados
SELECT `order`, `group` FROM `table`;

-- String concatenation
SELECT CONCAT(nome, ' - ', email) FROM clientes;
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo MySQL |
|---|---|
| `Integer` | `INT` |
| `Int64` | `BIGINT` |
| `string` | `VARCHAR(n)` ou `TEXT` |
| `Boolean` | `TINYINT(1)` |
| `TDateTime` | `DATETIME` |
| `TDate` | `DATE` |
| `TTime` | `TIME` |
| `Currency` | `DECIMAL(18,4)` |
| `Double` | `DOUBLE` |
| `TBytes` / `TStream` | `LONGBLOB` |
| `TGUID` | `CHAR(36)` ou `BINARY(16)` |

---

### 8.3 SQL Server

#### Visão geral

Microsoft SQL Server é um SGBD relacional comercial da Microsoft, amplamente utilizado em ambientes corporativos, especialmente integrado ao ecossistema .NET e Windows.

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **IDENTITY** | Mecanismo principal de geração de IDs |
| **SCOPE_IDENTITY()** | Retorna o último ID gerado no escopo atual |
| **OUTPUT clause** | Retorna colunas afetadas por INSERT/UPDATE/DELETE |
| **Schemas** | Suporta schemas (`dbo`, custom schemas) |
| **NEWID() / NEWSEQUENTIALID()** | Geração de GUIDs |
| **Transações** | ACID completo, snapshot isolation, savepoints |
| **TOP** | Limitar resultados (alternativa ao LIMIT) |
| **OFFSET FETCH** | Paginação (SQL Server 2012+) |
| **CTE** | Common Table Expressions avançadas |
| **JSON** | Suportado a partir do SQL Server 2016 |
| **Temporal Tables** | Tabelas com histórico temporal automático (2016+) |

#### Dialeto SQL — particularidades

```sql
-- Paginação (SQL Server 2012+)
SELECT * FROM clientes ORDER BY nome
  OFFSET 100 ROWS FETCH NEXT 50 ROWS ONLY;

-- Paginação legada
SELECT TOP 50 * FROM clientes WHERE id NOT IN
  (SELECT TOP 100 id FROM clientes ORDER BY nome) ORDER BY nome;

-- Insert com retorno de ID
INSERT INTO clientes (nome, email)
  OUTPUT INSERTED.id
  VALUES ('João', 'joao@email.com');

-- Ou alternativamente:
INSERT INTO clientes (nome, email) VALUES ('João', 'joao@email.com');
SELECT SCOPE_IDENTITY();

-- Boolean (armazenado como BIT)
SELECT * FROM clientes WHERE ativo = 1;

-- Colchetes para identificadores reservados
SELECT [order], [group] FROM [table];

-- String concatenation
SELECT nome + ' - ' + email FROM clientes;
-- Ou: SELECT CONCAT(nome, ' - ', email) FROM clientes;  (2012+)
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo SQL Server |
|---|---|
| `Integer` | `INT` |
| `Int64` | `BIGINT` |
| `string` | `NVARCHAR(n)` ou `NVARCHAR(MAX)` |
| `Boolean` | `BIT` |
| `TDateTime` | `DATETIME2` |
| `TDate` | `DATE` |
| `TTime` | `TIME` |
| `Currency` | `DECIMAL(18,4)` |
| `Double` | `FLOAT` |
| `TBytes` / `TStream` | `VARBINARY(MAX)` |
| `TGUID` | `UNIQUEIDENTIFIER` |

---

### 8.4 Firebird

#### Visão geral

Firebird é um SGBD relacional open source derivado do InterBase. É muito popular na comunidade Delphi, especialmente no Brasil, devido ao seu tamanho compacto, facilidade de deploy (embedded mode) e robustez.

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **Generators (Sequences)** | Mecanismo de geração de IDs: `GEN_ID(gen_nome, 1)` ou `NEXT VALUE FOR` |
| **RETURNING** | Retorna valores após INSERT/UPDATE/DELETE |
| **Sem schemas** | Namespace único por banco de dados |
| **Dialects** | Dialect 3 (padrão, recomendado) vs Dialect 1 (legado) |
| **Embedded mode** | Servidor embutido, sem instalação de serviço |
| **Transações** | ACID, snapshot isolation por padrão (MVCC) |
| **FIRST/SKIP** | Paginação (antes do Firebird 3); `OFFSET/FETCH` no Firebird 4+ |
| **Stored Procedures** | Selectable (retornam datasets) e Executable |
| **Triggers/Generators** | Padrão comum: trigger BEFORE INSERT que chama o generator |
| **Page size** | Configurável (4K, 8K, 16K, 32K) — afeta performance |

#### Dialeto SQL — particularidades

```sql
-- Paginação (Firebird 2.x / 3.x)
SELECT FIRST 50 SKIP 100 * FROM clientes ORDER BY nome;

-- Paginação (Firebird 4+)
SELECT * FROM clientes ORDER BY nome
  OFFSET 100 ROWS FETCH NEXT 50 ROWS;

-- Generator para ID
CREATE GENERATOR gen_clientes_id;

-- Obter próximo valor
SELECT GEN_ID(gen_clientes_id, 1) FROM RDB$DATABASE;
-- Ou (Firebird 3+):
SELECT NEXT VALUE FOR gen_clientes_id FROM RDB$DATABASE;

-- Insert com retorno de ID
INSERT INTO clientes (id, nome, email)
  VALUES (NEXT VALUE FOR gen_clientes_id, 'João', 'joao@email.com')
  RETURNING id;

-- Boolean (antes do Firebird 3: SMALLINT; Firebird 3+: BOOLEAN nativo)
-- Firebird 3+:
SELECT * FROM clientes WHERE ativo = TRUE;
-- Firebird 2.x:
SELECT * FROM clientes WHERE ativo = 1;

-- String concatenation
SELECT nome || ' - ' || email FROM clientes;
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo Firebird |
|---|---|
| `Integer` | `INTEGER` |
| `Int64` | `BIGINT` |
| `string` | `VARCHAR(n)` |
| `Boolean` | `BOOLEAN` (FB3+) ou `SMALLINT` (FB2) |
| `TDateTime` | `TIMESTAMP` |
| `TDate` | `DATE` |
| `TTime` | `TIME` |
| `Currency` | `NUMERIC(18,4)` |
| `Double` | `DOUBLE PRECISION` |
| `TBytes` / `TStream` | `BLOB SUB_TYPE 0` |
| `TGUID` | `CHAR(16) CHARACTER SET OCTETS` |

---

### 8.5 SQLite

#### Visão geral

SQLite é um mecanismo de banco de dados **embutido** (embedded), sem servidor, que armazena o banco inteiro em um único arquivo. É o banco de dados mais implantado no mundo (presente em celulares, navegadores, sistemas operacionais, etc.).

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **Sem servidor** | Biblioteca linkada diretamente na aplicação |
| **Arquivo único** | O banco inteiro é um arquivo `.db` ou `.sqlite` |
| **AUTOINCREMENT** | Geração de IDs via `INTEGER PRIMARY KEY` (implícito) ou `AUTOINCREMENT` (explícito) |
| **last_insert_rowid()** | Função para obter o último ID inserido |
| **Tipagem dinâmica** | SQLite é "flexibly typed" — a coluna sugere tipo, mas aceita qualquer valor |
| **Type affinities** | TEXT, NUMERIC, INTEGER, REAL, BLOB |
| **Transações** | ACID (com WAL mode para melhor concorrência) |
| **Sem ALTER TABLE completo** | Não suporta `DROP COLUMN` (até SQLite 3.35), `ALTER COLUMN TYPE`, etc. |
| **JSON** | Suportado via extensão json1 (geralmente habilitada) |
| **Foreign Keys** | Desabilitadas por padrão (`PRAGMA foreign_keys = ON`) |
| **In-memory** | Pode operar inteiramente em memória (`:memory:`) |

#### Dialeto SQL — particularidades

```sql
-- Paginação
SELECT * FROM clientes ORDER BY nome LIMIT 50 OFFSET 100;

-- Insert — ID obtido após execução
INSERT INTO clientes (nome, email) VALUES ('João', 'joao@email.com');
-- Em seguida: SELECT last_insert_rowid();

-- Upsert (SQLite 3.24+)
INSERT INTO clientes (email, nome) VALUES ('joao@email.com', 'João Silva')
  ON CONFLICT(email) DO UPDATE SET nome = excluded.nome;

-- Boolean (armazenado como INTEGER: 0 ou 1)
SELECT * FROM clientes WHERE ativo = 1;

-- String concatenation
SELECT nome || ' - ' || email FROM clientes;

-- Habilitar foreign keys (por conexão!)
PRAGMA foreign_keys = ON;
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo SQLite |
|---|---|
| `Integer` | `INTEGER` |
| `Int64` | `INTEGER` |
| `string` | `TEXT` |
| `Boolean` | `INTEGER` (0/1) |
| `TDateTime` | `TEXT` (ISO 8601) ou `REAL` (Julian day) |
| `TDate` | `TEXT` (ISO 8601) |
| `TTime` | `TEXT` (HH:MM:SS) |
| `Currency` | `REAL` ou `TEXT` |
| `Double` | `REAL` |
| `TBytes` / `TStream` | `BLOB` |
| `TGUID` | `TEXT` (36 chars) |

---

### 8.6 Microsoft Access (MSAccess)

#### Visão geral

Microsoft Access é um SGBD de desktop incluído no pacote Microsoft Office. Utiliza o formato `.accdb` (ou o legado `.mdb`). É frequentemente utilizado em aplicações pequenas, protótipos e ferramentas departamentais.

#### Características relevantes para o ORM

| Característica | Detalhe |
|---|---|
| **AutoNumber** | Mecanismo de geração de IDs automáticos |
| **@@IDENTITY** | Retorna o último AutoNumber gerado |
| **Acesso via OLE DB/ODBC** | Não possui driver nativo — conexão via `Microsoft.ACE.OLEDB` ou ODBC |
| **SQL limitado** | Dialeto SQL reduzido (Jet SQL / ACE SQL) |
| **Sem schemas** | Namespace único |
| **Sem RETURNING** | Não suporta `OUTPUT` ou `RETURNING` |
| **Sem OFFSET** | Paginação apenas com `TOP` (workarounds para offset) |
| **Tamanho limite** | 2 GB por arquivo `.accdb` |
| **Concorrência** | Limitada — file-based locking |
| **Transações** | Suportadas, mas com limitações |
| **Tipos peculiares** | `YESNO` para boolean, `CURRENCY`, `OLEOBJECT`, `MEMO` |

#### Dialeto SQL — particularidades

```sql
-- Paginação (apenas TOP, sem OFFSET nativo)
SELECT TOP 50 * FROM clientes ORDER BY nome;

-- Para "offset", é necessário workaround com subquery:
SELECT TOP 50 * FROM clientes
  WHERE id NOT IN (SELECT TOP 100 id FROM clientes ORDER BY nome)
  ORDER BY nome;

-- Insert — ID obtido após execução
INSERT INTO clientes (nome, email) VALUES ('João', 'joao@email.com');
-- Em seguida: SELECT @@IDENTITY;

-- Boolean (YESNO: True/False ou -1/0)
SELECT * FROM clientes WHERE ativo = True;

-- Delimitadores de identificadores: colchetes
SELECT [nome], [order] FROM [clientes];

-- String concatenation
SELECT nome & ' - ' & email FROM clientes;
-- Ou: SELECT nome + ' - ' + email FROM clientes;

-- Data literal (formato americano obrigatório)
SELECT * FROM clientes WHERE data_cadastro > #01/15/2024#;

-- Wildcard: * em vez de %
SELECT * FROM clientes WHERE nome LIKE 'Jo*';  -- Jet SQL
-- No modo ANSI (via ODBC): usa % normalmente
```

#### Tipos de dados para mapeamento

| Tipo Delphi/FPC | Tipo MSAccess |
|---|---|
| `Integer` | `LONG` (ou `INTEGER`) |
| `Int64` | `LONG` (Access não tem BIGINT nativo) |
| `string` | `TEXT(n)` (até 255) ou `MEMO` (longo) |
| `Boolean` | `YESNO` |
| `TDateTime` | `DATETIME` |
| `TDate` | `DATETIME` |
| `TTime` | `DATETIME` |
| `Currency` | `CURRENCY` |
| `Double` | `DOUBLE` |
| `TBytes` / `TStream` | `OLEOBJECT` ou `LONGBINARY` |
| `TGUID` | `TEXT(36)` |

---

## 9. Comparativo Geral dos Bancos de Dados

| Característica | PostgreSQL | MySQL | SQL Server | Firebird | SQLite | MSAccess |
|---|---|---|---|---|---|---|
| **Licença** | Open source | Open source / Comercial | Comercial | Open source | Domínio público | Comercial (Office) |
| **Servidor** | Sim | Sim | Sim | Sim / Embedded | Embedded | Arquivo |
| **Schemas** | Sim | Não (banco = namespace) | Sim | Não | Não | Não |
| **ID automático** | SERIAL / IDENTITY / Sequence | AUTO_INCREMENT | IDENTITY | Generator + Trigger | AUTOINCREMENT | AutoNumber |
| **RETURNING** | Sim | Não | OUTPUT clause | Sim | Não | Não |
| **Paginação** | LIMIT/OFFSET | LIMIT/OFFSET | OFFSET FETCH / TOP | FIRST/SKIP | LIMIT/OFFSET | TOP |
| **Boolean nativo** | Sim | Não (TINYINT) | Não (BIT) | Sim (FB3+) | Não (INTEGER) | Sim (YESNO) |
| **JSON nativo** | Sim (JSONB) | Sim | Sim | Não | Extensão | Não |
| **Concorrência** | MVCC | Lock-based (InnoDB: MVCC) | Lock + versioning | MVCC | WAL / file lock | File lock |
| **Tamanho máx.** | Ilimitado prático | Ilimitado prático | 524 PB | ~1 TB prático | ~281 TB teórico | 2 GB |
| **Deploy** | Servidor | Servidor | Servidor | Servidor / Embedded | Arquivo | Arquivo |
| **Popularidade Delphi** | Alta | Média | Alta | Muito alta (BR) | Alta | Média (legado) |

---

## 10. Factory Pattern — Unificando a Criação

Para que a aplicação seja verdadeiramente desacoplada, uma **factory** centraliza a criação dos componentes conforme a engine e banco configurados:

```pascal
type
  TEngineType = (etFireDAC, etUniDAC, etZeos, etSQLDB);

  TConnectionFactory = class
  public
    class function CreateConnection(
      AEngine: TEngineType;
      ADatabase: TTypeDatabase;
      const AConnectionString: string
    ): IDBConnection;
  end;

class function TConnectionFactory.CreateConnection(
  AEngine: TEngineType;
  ADatabase: TTypeDatabase;
  const AConnectionString: string
): IDBConnection;
begin
  case AEngine of
    etFireDAC:
      Result := TFireDACConnection.Create(AConnectionString, ADatabase);
    etUniDAC:
      Result := TUniDACConnection.Create(AConnectionString, ADatabase);
    etZeos:
      Result := TZeosConnection.Create(AConnectionString, ADatabase);
    etSQLDB:
      Result := TSQLDBConnection.Create(AConnectionString, ADatabase);
  end;
end;
```

### Uso na aplicação

```pascal
var
  Connection: IDBConnection;
  EM: IEntityManager;
  Cliente: TCliente;
begin
  // Configuração — pode vir de arquivo .ini, .json, registro, etc.
  Connection := TConnectionFactory.CreateConnection(
    etFireDAC,           // Engine
    tdPostgreSQL,        // Banco
    'Server=localhost;Port=5432;Database=meubanco;User_Name=postgres;Password=123'
  );

  EM := TEntityManager.Create(Connection, tdPostgreSQL);
  try
    EM.BeginTransaction;
    try
      Cliente := TCliente.Create;
      Cliente.Nome := 'Maria Silva';
      Cliente.Email := 'maria@email.com';
      Cliente.Ativo := True;

      EM.Persist(Cliente);
      EM.Flush;
      EM.Commit;

      WriteLn('Cliente inserido com ID: ', Cliente.Id);
    except
      EM.Rollback;
      raise;
    end;
  finally
    EM.Clear;
  end;
end;
```

---

## 11. Resumo da Arquitetura

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        CAMADA DE APLICAÇÃO                              │
│                                                                        │
│   Código de negócio trabalha apenas com:                               │
│   - Entidades (TCliente, TPedido, etc.)                                │
│   - EntityManager (Persist, Find, Remove, Flush)                       │
│   - QueryBuilder (consultas fluentes)                                  │
│   - Attributes (mapeamento declarativo)                                │
│                                                                        │
├──────────────────────────────────────────────────────────────────────────┤
│                       CAMADA DE ORQUESTRAÇÃO                           │
│                                                                        │
│   EntityManager coordena:                                              │
│   ├── IdentityMap (cache de identidade)                                │
│   ├── UnitOfWork (rastreamento de mudanças)                            │
│   └── QueryBuilder (geração de SQL por dialeto)                        │
│                                                                        │
├──────────────────────────────────────────────────────────────────────────┤
│                      CAMADA DE ABSTRAÇÃO                               │
│                                                                        │
│   IDBConnection / IDBQuery / IDBCommand                                │
│   Interface única independente de engine                               │
│                                                                        │
├──────────────────────────────────────────────────────────────────────────┤
│                        CAMADA DE ENGINE                                │
│                                                                        │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                │
│   │ FireDAC  │ │ UniDAC   │ │  Zeos    │ │  SQLDB   │                │
│   └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘                │
│        │            │            │             │                      │
├────────┼────────────┼────────────┼─────────────┼──────────────────────┤
│        │       CAMADA DE BANCO DE DADOS        │                      │
│        │                                       │                      │
│   ┌────▼────┐ ┌─────▼────┐ ┌──────▼───┐ ┌────▼─────┐               │
│   │PostgreSQL│ │  MySQL   │ │SQL Server│ │ Firebird │               │
│   └─────────┘ └──────────┘ └──────────┘ └──────────┘               │
│                                                                      │
│                  ┌──────────┐  ┌──────────┐                          │
│                  │  SQLite  │  │ MSAccess │                          │
│                  └──────────┘  └──────────┘                          │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 12. Considerações Finais

A arquitetura descrita neste documento permite construir aplicações Delphi/Free Pascal que sejam:

- **Portáveis entre bancos**: trocar de PostgreSQL para Firebird exige apenas mudar a configuração, sem alterar código de negócio.
- **Portáveis entre engines**: migrar de FireDAC para Zeos (por exemplo, ao portar de Delphi para Lazarus) é transparente.
- **Testáveis**: usando SQLite in-memory como banco de testes.
- **Performáticas**: o IdentityMap evita consultas redundantes, o UnitOfWork agrupa operações, e o QueryBuilder gera SQL otimizado para cada dialeto.
- **Manuteníveis**: o mapeamento via Attributes mantém a definição de persistência junto da entidade, facilitando a compreensão e manutenção do código.

Cada componente tem uma responsabilidade clara e bem delimitada, seguindo os princípios SOLID, e a comunicação entre eles é feita via interfaces, garantindo baixo acoplamento e alta coesão.
