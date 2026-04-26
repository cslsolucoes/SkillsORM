---
description: "Exemplos Attributes Mode — EntityManager, CRUD declarativo, QueryBuilder fluente"
alwaysApply: false
---

# Roteiro Attributes — EntityManager + QueryBuilder

> Requer `USE_ATTRIBUTES` (e `USE_ENTITY_MANAGER` para EntityManager) em `ORM.Defines.inc`.  
> Delphi XE7+ ou FPC 3.3.1+ com RTTI habilitado nas classes.

## 1. Declarar entidade com atributos

```pascal
uses Providers.Attributers.Interfaces;

type
  [Table('produtos')]
  TProduto = class
  private
    FId: Integer;
    FNome: string;
    FPreco: Currency;
    FAtivo: Boolean;
  public
    [Field('id')] [PrimaryKey] [AutoIncrement]
    property Id: Integer read FId write FId;

    [Field('nome')]
    property Nome: string read FNome write FNome;

    [Field('preco')]
    property Preco: Currency read FPreco write FPreco;

    [Field('ativo')]
    property Ativo: Boolean read FAtivo write FAtivo;
  end;
```

## 2. EntityManager.Save (INSERT ou UPDATE)

```pascal
// ORM.Defines.inc: {$DEFINE USE_ATTRIBUTES} + {$DEFINE USE_ENTITY_MANAGER}
uses Database, EntityManager;

var
  LEM: IEntityManager;
  LProd: TProduto;
begin
  LEM := TDatabase.New(LConn).NewEntityManager;

  LProd := TProduto.Create;
  try
    LProd.Nome := 'Caneta Azul';
    LProd.Preco := 2.50;
    LProd.Ativo := True;
    LEM.Save<TProduto>(LProd);
    // Se Id = 0 → INSERT; se Id > 0 → UPDATE
    Writeln('Id gerado: ', LProd.Id);
  finally
    LProd.Free;
  end;
end;
```

## 3. EntityManager.Find (por PK)

```pascal
var
  LProd: TProduto;
begin
  LProd := LEM.Find<TProduto>(42);
  if Assigned(LProd) then
    Writeln(LProd.Nome);
end;
```

## 4. EntityManager.FindAll

```pascal
var
  LList: TArray<TProduto>;
  LProd: TProduto;
begin
  LList := LEM.FindAll<TProduto>;
  for LProd in LList do
    Writeln(LProd.Nome, ' R$ ', LProd.Preco:0:2);
end;
```

## 5. EntityManager.Delete

```pascal
begin
  LProd := LEM.Find<TProduto>(42);
  if Assigned(LProd) then
    LEM.Delete<TProduto>(LProd);
end;
```

## 6. QueryBuilder — SELECT fluente

```pascal
// USE_QUERY_BUILDER não exige USE_ATTRIBUTES
uses Database, QueryBuilder;

var
  LQBL: IQueryBuilder;
  LDS: TDataSet;
begin
  LQBL := TDatabase.New(LConn).NewQueryBuilder;
  LDS := LQBL
    .Select(['id', 'nome', 'preco'])
    .From('produtos')
    .Where('ativo = :ativo AND preco > :preco_min')
    .Param('ativo', True)
    .Param('preco_min', 1.00)
    .OrderBy('nome')
    .Limit(10)
    .Build
    .Execute;
  try
    while not LDS.Eof do
    begin
      Writeln(LDS.FieldByName('nome').AsString);
      LDS.Next;
    end;
  finally
    LDS.Free;
  end;
end;
```

## 7. QueryBuilder + FromClass (com USE_ATTRIBUTES)

```pascal
// Com USE_ATTRIBUTES ativo, FromClass mapeia campos automaticamente
LDS := LQBL
  .FromClass<TProduto>
  .Where('ativo = :ativo')
  .Param('ativo', True)
  .Build
  .Execute;
```

## Referência canônica

- `src/Attributers/Providers.Attributers.pas`
- `src/Modulos/Database/EntityManager.pas`
- `src/Modulos/Database/QueryBuilder.pas`
- `src/Modulos/Database/IdentityMap.pas`, `UnitOfWork.pas`
- `.cursor/rules/roadmap_V1.0.mdc` seção 9.1
