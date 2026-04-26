# Padrões Genéricos Comuns em Delphi

## Nullable<T> — valor opcional

```pascal
type
  TNullable<T> = record
  private
    FValue   : T;
    FHasValue: Boolean;
    function GetValue: T;
  public
    class function Create(const AValue: T): TNullable<T>; static;
    class function Empty: TNullable<T>; static;
    function OrElse(const ADefault: T): T;
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue;
    // operadores implícitos
    class operator Implicit(const AValue: T): TNullable<T>;
    class operator Implicit(const ANullable: TNullable<T>): T;
  end;

// Uso:
var Nome: TNullable<string> := TNullable<string>.Create('Maria');
if Nome.HasValue then Writeln(Nome.Value);
var Fallback := Nome.OrElse('Anônimo');

var Vazio: TNullable<Integer> := TNullable<Integer>.Empty;
Writeln(Vazio.HasValue);  // False
```

## Result<T, E> — error handling funcional

```pascal
type
  TResult<T, E> = record
  private
    FValue  : T;
    FError  : E;
    FSuccess: Boolean;
  public
    class function Ok(const AValue: T): TResult<T, E>; static;
    class function Fail(const AError: E): TResult<T, E>; static;
    property IsSuccess: Boolean read FSuccess;
    property Value: T read FValue;    // levanta exceção se IsSuccess = False
    property Error: E read FError;    // levanta exceção se IsSuccess = True
  end;

// Uso — sem try/except nos callers:
function DividirSafe(A, B: Double): TResult<Double, string>;
begin
  if B = 0 then Result := TResult<Double,string>.Fail('Divisão por zero')
  else           Result := TResult<Double,string>.Ok(A / B);
end;

var R := DividirSafe(10, 0);
if R.IsSuccess then Writeln(R.Value)
else                Writeln('Erro: ', R.Error);
```

## Lazy<T> — inicialização adiada

```pascal
type
  TLazy<T: class, constructor> = record
  private
    FInstance: T;
    FCreated : Boolean;
    function GetValue: T;
  public
    property Value: T read GetValue;
    procedure Free;
  end;

// Uso:
var Config: TLazy<TConfiguracao>;
// ... não criado ainda ...
Config.Value.Carregar('app.ini');  // cria na primeira chamada
Config.Value.Salvar;               // mesma instância
Config.Free;
```

## Observer<T> — pub/sub genérico

```pascal
type
  TEventHandler<T> = reference to procedure(const AEvento: T);

  TObservable<T> = class
  private
    FHandlers: TList<TEventHandler<T>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assinar(AHandler: TEventHandler<T>);
    procedure Cancelar(AHandler: TEventHandler<T>);
    procedure Publicar(const AEvento: T);
  end;

// Uso:
var OnProdutoAlterado := TObservable<TProduto>.Create;
OnProdutoAlterado.Assinar(
  procedure(const P: TProduto)
  begin
    Writeln('Produto alterado: ', P.Nome);
  end);
OnProdutoAlterado.Publicar(MeuProduto);
```

## Pipeline<T> — transformações encadeadas

```pascal
type
  TPipeline<T> = class
  private
    FDados: TArray<T>;
  public
    constructor Create(const ADados: TArray<T>);
    function Onde(APred: TFunc<T, Boolean>): TPipeline<T>;
    function Mapear<R>(AFunc: TFunc<T, R>): TPipeline<R>;
    function Ordenar(ACmp: TComparison<T> = nil): TPipeline<T>;
    function PrimeirosN(N: Integer): TPipeline<T>;
    function ToArray: TArray<T>;
    function Contar: Integer;
    destructor Destroy; override;
  end;

// Uso fluente:
var Resultado := TPipeline<TProduto>.Create(Produtos.ToArray)
  .Onde(function(P: TProduto): Boolean begin Result := P.Ativo; end)
  .Ordenar(function(const A, B: TProduto): Integer begin Result := CompareText(A.Nome, B.Nome); end)
  .PrimeirosN(10)
  .ToArray;
```

## Quando usar cada padrão

| Situação | Padrão |
|----------|--------|
| Prop pode não ter valor (NULL DB) | `TNullable<T>` |
| Função pode falhar sem exceção | `TResult<T, E>` |
| Objeto caro criado só se usado | `TLazy<T>` |
| Notificar múltiplos interessados | `TObservable<T>` |
| Transformar coleções passo a passo | `TPipeline<T>` |
