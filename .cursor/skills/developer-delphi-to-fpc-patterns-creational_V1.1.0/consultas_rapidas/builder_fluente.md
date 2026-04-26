# Builder Fluente — regras do fluent API

## Regras obrigatórias

### 1. Cada configurador retorna `Self` (ou a interface do builder)

```pascal
function TQueryBuilder.From(const ATabela: string): TQueryBuilder;
begin
  FTabela := ATabela;
  Result := Self;   // ← permite encadeamento
end;
```

### 2. Exatamente um terminador que constrói o produto

```pascal
function TQueryBuilder.Build: TQueryConfig;  // ← terminador
begin
  // Validação obrigatória aqui
  if FTabela = '' then
    raise EInvalidOperation.Create('From() é obrigatório');
  Result := ...;  // constrói o produto imutável
end;
```

### 3. Validação no terminador, não nos configuradores

```pascal
// Errado: lança no configurador
function TBuilder.Limit(N: Integer): TBuilder;
begin
  if N <= 0 then raise ...; // cedo demais — usuário pode querer corrigir
  ...
end;

// Correto: lança só no Build
function TBuilder.Build: TProduto;
begin
  if FLimite < 0 then raise EInvalidOperation.Create('Limit inválido');
  ...
end;
```

### 4. Builder é descartado após Build (não reutilizar sem Reset)

```pascal
var B := TQueryBuilder.Create;
var Q1 := B.From('a').Select(['id']).Build;
B.Reset;  // limpar estado
var Q2 := B.From('b').Select(['nome']).Build;
B.Free;
```

---

## Padrão com interface (testável)

```pascal
type
  IQueryBuilder = interface
    function From(const ATabela: string): IQueryBuilder;
    function Select(const ACampos: array of string): IQueryBuilder;
    function Where(const ACond: string): IQueryBuilder;
    function Limit(N: Integer): IQueryBuilder;
    function Build: TQueryConfig;
  end;

  TQueryBuilder = class(TInterfacedObject, IQueryBuilder)
    ...
  end;

// Fábrica
function NewQueryBuilder: IQueryBuilder;
begin Result := TQueryBuilder.Create; end;
```

---

## Method chaining completo — exemplo

```pascal
var SQL := NewQueryBuilder
  .From('pedidos p')
  .Select(['p.id', 'p.total', 'c.nome'])
  .Join('clientes c', 'c.id = p.cliente_id')
  .Where('p.status = ''aberto''')
  .AndWhere('p.total > 100')
  .OrderBy('p.data', True)
  .Limit(20)
  .Skip(40)
  .Build
  .ToSQL;
```

---

## Checklist do builder fluente

- [ ] Todos os configuradores retornam `Self` / interface do builder
- [ ] `Build` valida e lança exceção descritiva
- [ ] `Build` produz objeto imutável ou record
- [ ] Estado interno limpo pelo `Reset` ou por novo `Create`
- [ ] Parâmetros obrigatórios validados no `Build`, não no configurador
- [ ] Builder não vaza referência ao produto parcial
