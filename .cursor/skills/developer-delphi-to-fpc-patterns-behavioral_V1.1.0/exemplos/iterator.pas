unit iterator;
{
  Iterator Pattern em Delphi — IEnumerator<T>; for..in em coleção customizada
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Produto de domínio
// ---------------------------------------------------------------------------
type
  TProduto = record
    Id:       Integer;
    Nome:     string;
    Preco:    Currency;
    Categoria: string;
    Ativo:    Boolean;
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// Enumerator básico — percorre array de TProduto
// ---------------------------------------------------------------------------
type
  TProdutoEnumerator = class
  private
    FDados:  TArray<TProduto>;
    FCursor: Integer;
  public
    constructor Create(const ADados: TArray<TProduto>);
    function MoveNext: Boolean;
    function GetCurrent: TProduto;
    property Current: TProduto read GetCurrent;
  end;

// ---------------------------------------------------------------------------
// Coleção básica com for..in
// ---------------------------------------------------------------------------
type
  TCatalogoProdutos = class
  private
    FItems: TList<TProduto>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Adicionar(const P: TProduto);
    function  Count: Integer;
    // Suporte a for..in
    function GetEnumerator: TProdutoEnumerator;
  end;

// ---------------------------------------------------------------------------
// Enumerator com filtro — itera apenas sobre itens que passam no predicado
// ---------------------------------------------------------------------------
type
  TFiltroProduto = reference to function(const P: TProduto): Boolean;

  TProdutoFilterEnumerator = class
  private
    FDados:   TArray<TProduto>;
    FFiltro:  TFiltroProduto;
    FCursor:  Integer;
    FCurrent: TProduto;
    function  AvancaAteProximo: Boolean;
  public
    constructor Create(const ADados: TArray<TProduto>; AFiltro: TFiltroProduto);
    function MoveNext: Boolean;
    function GetCurrent: TProduto;
    property Current: TProduto read GetCurrent;
  end;

// ---------------------------------------------------------------------------
// Vista filtrada — retorna enumerator com predicado
// ---------------------------------------------------------------------------
type
  TVistaProdutos = class
  private
    FFonte:  TCatalogoProdutos;
    FFiltro: TFiltroProduto;
  public
    constructor Create(AFonte: TCatalogoProdutos; AFiltro: TFiltroProduto);
    function GetEnumerator: TProdutoFilterEnumerator;
  end;

// ---------------------------------------------------------------------------
// Enumerator lazy — gera elementos sob demanda (sem array pré-alocado)
// ---------------------------------------------------------------------------
type
  TIntervaloEnumerator = class
  private
    FAtual: Integer;
    FFim:   Integer;
    FPasso: Integer;
  public
    constructor Create(AInicio, AFim: Integer; APasso: Integer = 1);
    function MoveNext: Boolean;
    function GetCurrent: Integer;
    property Current: Integer read GetCurrent;
  end;

  TIntervalo = record
    Inicio, Fim, Passo: Integer;
    function GetEnumerator: TIntervaloEnumerator;
    class function Criar(AInicio, AFim: Integer; APasso: Integer = 1): TIntervalo; static;
  end;

// ---------------------------------------------------------------------------
// Enumerator reverso — percorre lista de trás para frente
// ---------------------------------------------------------------------------
type
  TReversoEnumerator<T> = class
  private
    FLista:  TList<T>;
    FCursor: Integer;
  public
    constructor Create(ALista: TList<T>);
    function MoveNext: Boolean;
    function GetCurrent: T;
    property Current: T read GetCurrent;
  end;

  TReversoView<T> = class
  private
    FLista: TList<T>;
  public
    constructor Create(ALista: TList<T>);
    function GetEnumerator: TReversoEnumerator<T>;
  end;

implementation

// ---------------------------------------------------------------------------
// TProduto
// ---------------------------------------------------------------------------

function TProduto.ToString: string;
begin
  Result := Format('[%d] %s R$%.2f (%s)%s',
    [Id, Nome, Preco, Categoria, IfThen(Ativo, '', ' INATIVO')]);
end;

// ---------------------------------------------------------------------------
// TProdutoEnumerator
// ---------------------------------------------------------------------------

constructor TProdutoEnumerator.Create(const ADados: TArray<TProduto>);
begin inherited Create; FDados := ADados; FCursor := -1; end;

function TProdutoEnumerator.MoveNext: Boolean;
begin Inc(FCursor); Result := FCursor < Length(FDados); end;

function TProdutoEnumerator.GetCurrent: TProduto;
begin Result := FDados[FCursor]; end;

// ---------------------------------------------------------------------------
// TCatalogoProdutos
// ---------------------------------------------------------------------------

constructor TCatalogoProdutos.Create;
begin inherited Create; FItems := TList<TProduto>.Create; end;

destructor TCatalogoProdutos.Destroy;
begin FItems.Free; inherited; end;

procedure TCatalogoProdutos.Adicionar(const P: TProduto);
begin FItems.Add(P); end;

function TCatalogoProdutos.Count: Integer;
begin Result := FItems.Count; end;

function TCatalogoProdutos.GetEnumerator: TProdutoEnumerator;
begin Result := TProdutoEnumerator.Create(FItems.ToArray); end;

// ---------------------------------------------------------------------------
// TProdutoFilterEnumerator
// ---------------------------------------------------------------------------

constructor TProdutoFilterEnumerator.Create(const ADados: TArray<TProduto>;
  AFiltro: TFiltroProduto);
begin inherited Create; FDados := ADados; FFiltro := AFiltro; FCursor := -1; end;

function TProdutoFilterEnumerator.AvancaAteProximo: Boolean;
begin
  repeat
    Inc(FCursor);
    if FCursor >= Length(FDados) then Exit(False);
  until FFiltro(FDados[FCursor]);
  FCurrent := FDados[FCursor];
  Result := True;
end;

function TProdutoFilterEnumerator.MoveNext: Boolean;
begin Result := AvancaAteProximo; end;

function TProdutoFilterEnumerator.GetCurrent: TProduto;
begin Result := FCurrent; end;

// ---------------------------------------------------------------------------
// TVistaProdutos
// ---------------------------------------------------------------------------

constructor TVistaProdutos.Create(AFonte: TCatalogoProdutos; AFiltro: TFiltroProduto);
begin inherited Create; FFonte := AFonte; FFiltro := AFiltro; end;

function TVistaProdutos.GetEnumerator: TProdutoFilterEnumerator;
begin
  Result := TProdutoFilterEnumerator.Create(FFonte.FItems.ToArray, FFiltro);
end;

// ---------------------------------------------------------------------------
// TIntervaloEnumerator / TIntervalo
// ---------------------------------------------------------------------------

constructor TIntervaloEnumerator.Create(AInicio, AFim, APasso: Integer);
begin inherited Create; FAtual := AInicio - APasso; FFim := AFim; FPasso := APasso; end;

function TIntervaloEnumerator.MoveNext: Boolean;
begin Inc(FAtual, FPasso); Result := FAtual <= FFim; end;

function TIntervaloEnumerator.GetCurrent: Integer;
begin Result := FAtual; end;

function TIntervalo.GetEnumerator: TIntervaloEnumerator;
begin Result := TIntervaloEnumerator.Create(Inicio, Fim, Passo); end;

class function TIntervalo.Criar(AInicio, AFim, APasso: Integer): TIntervalo;
begin Result.Inicio := AInicio; Result.Fim := AFim; Result.Passo := APasso; end;

// ---------------------------------------------------------------------------
// TReversoEnumerator<T> / TReversoView<T>
// ---------------------------------------------------------------------------

constructor TReversoEnumerator<T>.Create(ALista: TList<T>);
begin inherited Create; FLista := ALista; FCursor := ALista.Count; end;

function TReversoEnumerator<T>.MoveNext: Boolean;
begin Dec(FCursor); Result := FCursor >= 0; end;

function TReversoEnumerator<T>.GetCurrent: T;
begin Result := FLista[FCursor]; end;

constructor TReversoView<T>.Create(ALista: TList<T>);
begin inherited Create; FLista := ALista; end;

function TReversoView<T>.GetEnumerator: TReversoEnumerator<T>;
begin Result := TReversoEnumerator<T>.Create(FLista); end;

// ---------------------------------------------------------------------------
// USO:
//   var Cat := TCatalogoProdutos.Create;
//   Cat.Adicionar(TProduto(1, 'Caneta', 2.50, 'Escritório', True));
//   Cat.Adicionar(TProduto(2, 'Mouse',  89.9, 'Tech',       True));
//   Cat.Adicionar(TProduto(3, 'Papel',  15.0, 'Escritório', False));
//
//   // for..in básico
//   for var P in Cat do
//     Writeln(P.ToString);
//
//   // Vista filtrada — só ativos da categoria Escritório
//   var Vista := TVistaProdutos.Create(Cat,
//     function(const P: TProduto): Boolean
//     begin Result := P.Ativo and (P.Categoria = 'Escritório'); end);
//
//   for var P in Vista do
//     Writeln(P.Nome);  // apenas Caneta
//
//   // Intervalo lazy
//   for var I in TIntervalo.Criar(1, 10, 2) do
//     Write(I, ' ');  // 1 3 5 7 9
//   Writeln;
//
//   // Reverso
//   var Lista := TList<string>.Create;
//   Lista.AddRange(['a', 'b', 'c']);
//   var Rev := TReversoView<string>.Create(Lista);
//   for var S in Rev do Write(S, ' ');  // c b a
// ---------------------------------------------------------------------------

end.
