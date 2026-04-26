# EntityManager

**Tipos documentados:** `IEntityManager` (interface), `TEntityManager` (classe)
**Domínio:** Database/EntityManager
**Ficheiro:** `EntityManager.md`

## Interface — `IEntityManager`


> Interface do Entity Manager no ProvidersORM. Define o contrato para operacoes CRUD de alto nivel sobre `ITable`, com cache interno e integracao com `IQueryBuilder`.

**Unit:** `Providers.Database.EntityManager.Interfaces.pas`
**Tipo:** Interface
**Modulo:** Database / EntityManager (`src/Modulos/Database/EntityManager/`)
**GUID:** `{F7A8B9C0-6789-0123-4567-890123DEF012}`
**Diretiva:** `{$IFDEF USE_ENTITY_MANAGER}` -- compilada apenas quando `USE_ENTITY_MANAGER` esta definida em `ORM.Defines.inc`

---

## O que e?

`IEntityManager` e a interface que define o contrato para um gerenciador de entidades (Entity Manager) no ProvidersORM. Ela opera sobre instancias de `ITable`, oferecendo operacoes CRUD de alto nivel: `Find` (busca por chave primaria com cache), `List` (listagem completa), `ListWhere` (listagem filtrada), `Save` (insert ou update automatico), `Delete` (por entidade ou por ID) e `Update`.

O Entity Manager atua como camada de abstracao entre o codigo de negocio e o acesso direto ao banco. Ele recebe uma `IConnection` e uma `ITable` (template da entidade) e constroi queries internamente via `IQueryBuilder`, eliminando a necessidade de escrever SQL manualmente para operacoes basicas.

A interface segue o padrao **Fluent Interface** para configuracao: `Connection` e `Table` retornam `IEntityManager` para encadeamento.

---

## Caracteristicas

- **CRUD completo:** Find, List, ListWhere, Save, Delete, Update sobre `ITable`
- **Cache por chave primaria:** `Find` usa `TDictionary<string, ITable>` para cache; se a entidade ja foi buscada, retorna do cache
- **Save inteligente:** `Save` verifica a chave primaria -- se nula/vazia, executa INSERT; caso contrario, executa UPDATE
- **Integracao com IQueryBuilder:** Find, List e ListWhere constroem queries via `TQueryBuilder.New` internamente
- **Fluent Interface:** `Connection` e `Table` retornam `IEntityManager` para encadeamento
- **Overloads getter/setter:** `Connection` e `Table` possuem setter e getter
- **Delete por entidade ou ID:** dois overloads de `Delete` -- um recebe `ITable`, outro recebe `Variant` (ID)
- **Independente de engine:** opera sobre `IConnection` e `ITable`, sem dependencia de driver especifico
- **Diretiva condicional:** requer `USE_ENTITY_MANAGER` ativa em `ORM.Defines.inc`

---

## Funcionalidades

### Configuracao

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Connection` (setter) | `function Connection(const AConnection: IConnection): IEntityManager` | `IEntityManager` | Define a conexao de banco de dados |
| `Connection` (getter) | `function Connection: IConnection` | `IConnection` | Retorna a conexao configurada |
| `Table` (setter) | `function Table(const ATable: ITable): IEntityManager` | `IEntityManager` | Define a tabela-template (entidade base para clonagem em Find/List) |
| `Table` (getter) | `function Table: ITable` | `ITable` | Retorna a tabela-template configurada |

### Consultas

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Find` | `function Find(const AId: Variant): ITable` | `ITable` | Busca entidade por chave primaria; verifica cache primeiro, se nao encontrada consulta o banco via `IQueryBuilder` e armazena no cache; retorna `nil` se nao encontrada |
| `List` | `function List: TArray<ITable>` | `TArray<ITable>` | Retorna todas as entidades da tabela (SELECT * FROM tabela) |
| `ListWhere` | `function ListWhere(const AColumn, AOp: string; const AValue: Variant): TArray<ITable>` | `TArray<ITable>` | Retorna entidades filtradas por coluna, operador e valor (SELECT * FROM tabela WHERE coluna op valor) |

### Persistencia

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Save` | `function Save(const ATable: ITable): Integer` | `Integer` | Persiste a entidade: se chave primaria nula/vazia executa INSERT, caso contrario executa UPDATE; retorna linhas afetadas |
| `Delete` (por entidade) | `function Delete(const ATable: ITable): Integer` | `Integer` | Remove a entidade do banco via `ATable.ExecuteDelete`; retorna linhas afetadas |
| `Delete` (por ID) | `function Delete(const AId: Variant): Integer` | `Integer` | Remove a entidade por chave primaria: clona a estrutura da tabela-template, define o PK e executa delete; retorna linhas afetadas |
| `Update` | `function Update(const ATable: ITable): Integer` | `Integer` | Atualiza a entidade no banco via `ATable.ExecuteUpdate`; retorna linhas afetadas |

---

## Aplicabilidades

- **CRUD sem SQL manual:** operacoes basicas de persistencia usando apenas chamadas de metodo
- **Cache de entidades:** `Find` evita round-trips duplicados ao banco para a mesma chave primaria
- **Listagem filtrada:** `ListWhere` para consultas simples sem necessidade de construir `IQueryBuilder` manualmente
- **Save inteligente:** logica automatica de INSERT vs UPDATE baseada na presenca de chave primaria
- **Integracao com UnitOfWork:** entidades gerenciadas pelo `IEntityManager` podem ser registradas em `IUnitOfWork` para persistencia transacional em batch

---

## Exemplos de Uso

### Configuracao e Find

```pascal
uses
  Providers.Connection, Providers.Connection.Interfaces,
  Providers.Database.EntityManager, Providers.Database.EntityManager.Interfaces,
  Providers.Database.Table, Providers.Database.Table.Interfaces;

var
  Conn: IConnection;
  EM: IEntityManager;
  Cliente: ITable;
begin
  Conn := TConnection.New.FromConfig.Connect;

  EM := TEntityManager.New
    .Connection(Conn)
    .Table(TTable.New(TFields.New
      .AddField(TField.New.Column('id').IsPrimaryKey(True))
      .AddField(TField.New.Column('nome'))
      .AddField(TField.New.Column('email')),
      'clientes'));

  Cliente := EM.Find(42);
  if Cliente <> nil then
    WriteLn('Nome: ', Cliente.Fields('nome').Value);
end;
```

### List e ListWhere

```pascal
var
  EM: IEntityManager;
  Todos: TArray<ITable>;
  Ativos: TArray<ITable>;
  I: Integer;
begin
  EM := TEntityManager.New.Connection(Conn).Table(ClienteTable);

  // Listar todos
  Todos := EM.List;
  for I := 0 to High(Todos) do
    WriteLn(Todos[I].Fields('nome').Value);

  // Listar com filtro
  Ativos := EM.ListWhere('ativo', '=', 1);
  WriteLn('Ativos: ', Length(Ativos));
end;
```

### Save (INSERT ou UPDATE automatico)

```pascal
var
  EM: IEntityManager;
  Novo, Existente: ITable;
  Rows: Integer;
begin
  EM := TEntityManager.New.Connection(Conn).Table(ClienteTable);

  // INSERT (PK nula)
  Novo := EM.Table;
  Novo.Fields('nome').SetColumnValue('Maria');
  Novo.Fields('email').SetColumnValue('maria@email.com');
  Rows := EM.Save(Novo);
  WriteLn('Inserido, linhas: ', Rows);

  // UPDATE (PK preenchida)
  Existente := EM.Find(42);
  if Existente <> nil then
  begin
    Existente.Fields('email').SetColumnValue('novo@email.com');
    Rows := EM.Save(Existente);
    WriteLn('Atualizado, linhas: ', Rows);
  end;
end;
```

### Delete por entidade e por ID

```pascal
var
  EM: IEntityManager;
  Rows: Integer;
begin
  EM := TEntityManager.New.Connection(Conn).Table(ClienteTable);

  // Delete por ID
  Rows := EM.Delete(99);
  WriteLn('Removido por ID, linhas: ', Rows);

  // Delete por entidade
  var Cliente := EM.Find(42);
  if Cliente <> nil then
  begin
    Rows := EM.Delete(Cliente);
    WriteLn('Removido por entidade, linhas: ', Rows);
  end;
end;
```

---

## Relacionamentos

- [`TEntityManager`](TEntityManager.md) -- implementacao concreta desta interface (unit `Providers.Database.EntityManager.pas`)
- [`IConnection`](../../Connections/IConnection.md) -- conexao de banco de dados usada para execucao de queries e comandos
- [`ITable`] -- interface da entidade (tabela) gerenciada pelo EntityManager
- [`IField`] -- interface de campo; `GetPrimaryKey` retorna o campo PK usado por Find, Save e Delete
- [`IQueryBuilder`](../QueryBuilder/IQueryBuilder.md) -- usado internamente por Find, List e ListWhere para construir queries
- [`IUnitOfWork`](../UnitOfWork/IUnitOfWork.md) -- pode receber entidades gerenciadas pelo EntityManager para persistencia transacional
- `Commons.Types.pas` -- declara `TFieldArray` e tipos auxiliares
- `ORM.Defines.inc` -- diretiva `USE_ENTITY_MANAGER` controla a compilacao deste modulo

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (01/04/2026): Versao inicial -- documentacao completa da interface IEntityManager com metodos de configuracao, consulta, persistencia, exemplos de uso e relacionamentos.

---

## Classe — `TEntityManager`


> Implementacao concreta de `IEntityManager`. Gerencia entidades `ITable` com CRUD completo, cache por chave primaria via `TDictionary` e construcao de queries via `TQueryBuilder`.

**Unit:** `Providers.Database.EntityManager.pas`
**Tipo:** Classe (`TInterfacedObject`, implementa `IEntityManager`)
**Modulo:** Database / EntityManager (`src/Modulos/Database/EntityManager/`)
**Diretiva:** `{$IFDEF USE_ENTITY_MANAGER}` -- compilada apenas quando `USE_ENTITY_MANAGER` esta definida em `ORM.Defines.inc`

---

## O que e?

`TEntityManager` e a classe que implementa a interface `IEntityManager` e encapsula toda a logica de operacoes CRUD de alto nivel sobre entidades `ITable`. Internamente, ela usa `TQueryBuilder` para construir queries SELECT e delega INSERT/UPDATE/DELETE para os metodos nativos de `ITable` (`ExecuteInsert`, `ExecuteUpdate`, `ExecuteDelete`).

A classe mantem um cache interno (`FCache: TDictionary<string, ITable>`) que armazena entidades buscadas por `Find`, evitando round-trips duplicados ao banco para a mesma chave primaria. O `Save` implementa logica inteligente: verifica se a chave primaria esta preenchida para decidir entre INSERT e UPDATE.

Para consultas (`Find`, `List`, `ListWhere`), a classe clona a estrutura da tabela-template via `CloneTableStructure` e preenche os valores a partir do `TDataSet` retornado via `FillTableFromDataSet`.

---

## Caracteristicas

- **Factory pattern:** `TEntityManager.New` retorna `IEntityManager`
- **Cache com TDictionary:** `FCache: TDictionary<string, ITable>` indexado por `VarToStr(AId)` da chave primaria
- **Clonagem de estrutura:** `CloneTableStructure` cria nova `ITable` com campos clonados via `IField.Clone`
- **Preenchimento via DataSet:** `FillTableFromDataSet` percorre campos da tabela e busca valores correspondentes no `TDataSet` (com fallback para `LowerCase`)
- **Deteccao de PK:** `GetPrimaryKeyColumn` extrai o nome da coluna PK via `FTable.GetPrimaryKey`
- **Save inteligente:** PK nula/vazia -> `ExecuteInsert`; PK preenchida -> `ExecuteUpdate`
- **Integracao com TQueryBuilder:** Find, List e ListWhere constroem queries fluentemente
- **Compativel Delphi/FPC:** blocos `{$IF DEFINED(FPC)}` para units de sistema e type alias `TDBField`
- **Reference counting:** herda de `TInterfacedObject`

---

## Campos internos

### private

| Campo | Tipo | Descricao |
|-------|------|-----------|
| `FConnection` | `IConnection` | Conexao de banco de dados |
| `FTable` | `ITable` | Tabela-template usada como base para clonagem em Find/List |
| `FCache` | `TDictionary<string, ITable>` | Cache de entidades indexado pela chave primaria convertida para string |

---

## Metodos privados

| Metodo | Assinatura | Descricao |
|--------|-----------|-----------|
| `CloneTableStructure` | `function CloneTableStructure(const ATable: ITable): ITable` | Cria nova `ITable` com a mesma estrutura de campos (via `IField.Clone`) e mesmo `TableName`/`DatabaseTypes`; retorna `nil` se `ATable` for `nil` |
| `FillTableFromDataSet` | `procedure FillTableFromDataSet(const ATable: ITable; const ADataSet: TDataSet)` | Percorre os campos de `ATable`, busca campo correspondente no `ADataSet` (por nome exato ou lowercase), e define o valor via `SetColumnValueWithoutChange` |
| `GetPrimaryKeyColumn` | `function GetPrimaryKeyColumn: string` | Retorna o nome da coluna PK de `FTable` via `FTable.GetPrimaryKey.Column`; retorna string vazia se nao houver PK |

---

## Funcionalidades

### Tabela completa de metodos publicos

#### Construtor, destrutor e factory

| Metodo | Assinatura | Descricao |
|--------|-----------|-----------|
| `Create` | `constructor Create` | Inicializa `FCache := TDictionary<string, ITable>.Create` |
| `Destroy` | `destructor Destroy; override` | Libera `FCache` |
| `New` | `class function New: IEntityManager` | Factory: cria instancia e retorna como `IEntityManager` |

#### Configuracao (IEntityManager)

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Connection` (setter) | `function Connection(const AConnection: IConnection): IEntityManager` | `IEntityManager` | Define `FConnection` |
| `Connection` (getter) | `function Connection: IConnection` | `IConnection` | Retorna `FConnection` |
| `Table` (setter) | `function Table(const ATable: ITable): IEntityManager` | `IEntityManager` | Define `FTable` (tabela-template) |
| `Table` (getter) | `function Table: ITable` | `ITable` | Retorna `FTable` |

#### Consultas

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Find` | `function Find(const AId: Variant): ITable` | `ITable` | Busca por PK: verifica `FCache` primeiro; se ausente, constroi `TQueryBuilder.New.Connection.Select('*').From(TableName, Schema).Where(PK, '=', AId).Limit(1).Execute`; clona estrutura, preenche do DataSet, armazena no cache |
| `List` | `function List: TArray<ITable>` | `TArray<ITable>` | SELECT * FROM tabela; itera pelo DataSet clonando e preenchendo cada linha; retorna array |
| `ListWhere` | `function ListWhere(const AColumn, AOp: string; const AValue: Variant): TArray<ITable>` | `TArray<ITable>` | SELECT * FROM tabela WHERE coluna op valor; itera pelo DataSet clonando e preenchendo cada linha |

#### Persistencia

| Metodo | Assinatura | Retorno | Descricao |
|--------|-----------|---------|-----------|
| `Save` | `function Save(const ATable: ITable): Integer` | `Integer` | Se PK nula/vazia -> `ATable.ExecuteInsert(FConnection)`; senao -> `ATable.ExecuteUpdate(FConnection)` |
| `Delete` (por entidade) | `function Delete(const ATable: ITable): Integer` | `Integer` | Executa `ATable.ExecuteDelete(FConnection)` |
| `Delete` (por ID) | `function Delete(const AId: Variant): Integer` | `Integer` | Clona `FTable`, define PK via `Fields(LPkCol).SetColumnValue(AId)`, executa `ExecuteDelete` |
| `Update` | `function Update(const ATable: ITable): Integer` | `Integer` | Executa `ATable.ExecuteUpdate(FConnection)` |

---

## Aplicabilidades

- **Persistencia de alto nivel:** operacoes CRUD sem SQL manual, com logica automatica de INSERT vs UPDATE
- **Cache de leitura:** `Find` reduz round-trips ao banco reutilizando entidades ja carregadas
- **Listagem com filtro:** `ListWhere` para consultas simples sem construir `IQueryBuilder` externamente
- **Integracao com UnitOfWork:** entidades retornadas por Find/List podem ser registradas em `IUnitOfWork` para persistencia em batch
- **Compatibilidade multi-engine:** opera exclusivamente sobre `IConnection` e `ITable`, sem dependencia de driver

---

## Exemplos de Uso

### Configuracao completa e Find com cache

```pascal
uses
  Providers.Connection, Providers.Connection.Interfaces,
  Providers.Database.EntityManager, Providers.Database.EntityManager.Interfaces,
  Providers.Database.Table, Providers.Database.Table.Interfaces,
  Providers.Database.Fields, Providers.Database.Fields.Interfaces,
  Providers.Database.Field, Providers.Database.Field.Interfaces;

var
  Conn: IConnection;
  EM: IEntityManager;
  Cliente1, Cliente2: ITable;
begin
  Conn := TConnection.New.FromConfig.Connect;

  EM := TEntityManager.New
    .Connection(Conn)
    .Table(TTable.New(TFields.New
      .AddField(TField.New.Column('id').IsPrimaryKey(True))
      .AddField(TField.New.Column('nome'))
      .AddField(TField.New.Column('email')),
      'clientes'));

  // Primeira chamada: consulta o banco e armazena no cache
  Cliente1 := EM.Find(1);

  // Segunda chamada: retorna do cache sem round-trip
  Cliente2 := EM.Find(1);

  // Cliente1 e Cliente2 sao a mesma referencia
end;
```

### ListWhere com iteracao

```pascal
var
  EM: IEntityManager;
  Resultados: TArray<ITable>;
  I: Integer;
begin
  EM := TEntityManager.New.Connection(Conn).Table(ClienteTemplate);

  Resultados := EM.ListWhere('cidade', '=', 'Sao Paulo');
  for I := 0 to High(Resultados) do
    WriteLn(Resultados[I].Fields('nome').Value, ' - ',
            Resultados[I].Fields('email').Value);
end;
```

### Save com logica automatica

```pascal
var
  EM: IEntityManager;
  NovoCliente: ITable;
begin
  EM := TEntityManager.New.Connection(Conn).Table(ClienteTemplate);

  // PK vazia -> INSERT
  NovoCliente := TTable.New(TFields.New
    .AddField(TField.New.Column('id').IsPrimaryKey(True))
    .AddField(TField.New.Column('nome').SetColumnValue('Carlos'))
    .AddField(TField.New.Column('email').SetColumnValue('carlos@email.com')),
    'clientes');

  EM.Save(NovoCliente); // Executa INSERT

  // Atribuir PK -> UPDATE
  NovoCliente.Fields('id').SetColumnValue(10);
  EM.Save(NovoCliente); // Executa UPDATE
end;
```

---

## Relacionamentos

- [`IEntityManager`](IEntityManager.md) -- interface implementada por esta classe
- [`TInterfacedObject`] -- classe-base com reference counting
- [`IConnection`](../../Connections/IConnection.md) -- conexao usada para execucao de queries e comandos; fornece `Schema` para `From`
- [`ITable`] -- interface da entidade; template para clonagem, destino de `ExecuteInsert`/`ExecuteUpdate`/`ExecuteDelete`
- [`TTable`] -- classe concreta criada por `CloneTableStructure` via `TTable.New(LFields, ATable.TableName)`
- [`IFields`] / [`TFields`] -- container de campos; usado na clonagem de estrutura
- [`IField`] / [`TField`] -- campo individual; `Clone`, `Column`, `Value`, `SetColumnValue`, `SetColumnValueWithoutChange`
- [`IQueryBuilder`](../QueryBuilder/IQueryBuilder.md) / [`TQueryBuilder`](../QueryBuilder/TQueryBuilder.md) -- usado internamente para construir SELECT em Find, List e ListWhere
- [`IUnitOfWork`](../UnitOfWork/IUnitOfWork.md) -- complementar; recebe entidades do EntityManager para persistencia transacional
- `ORM.Defines.inc` -- diretiva `USE_ENTITY_MANAGER` controla a compilacao

---

## Versao interna (ficheiro)

| Campo | Valor |
|-------|-------|
| **FileVersion** | 1.0.0 |
| **Politica** | `.cursor/VERSION.md` |

## Changelog (este arquivo)

- 1.0.0 (01/04/2026): Versao inicial -- documentacao completa da classe TEntityManager com campos internos, metodos privados e publicos, exemplos de uso e relacionamentos.
