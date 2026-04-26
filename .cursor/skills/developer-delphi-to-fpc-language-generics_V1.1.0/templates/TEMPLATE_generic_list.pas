unit TEMPLATE_generic_list;
{
  TEMPLATE: Lista genérica com Add/Remove/Find/ForEach/Sort/Where
  Uso: copie, renomeie e adapte.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

// ---------------------------------------------------------------------------
// Lista genérica reutilizável com API fluente
// ---------------------------------------------------------------------------
type
  TPredicado<T>    = TFunc<T, Boolean>;
  TTransformacao<T, R> = TFunc<T, R>;
  TAcao<T>         = TProc<T>;

  TListaGenerica<T> = class
  private
    FItems: TList<T>;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): T;
    procedure SetItem(AIndex: Integer; const AValue: T);
  public
    constructor Create; overload;
    constructor Create(const AItems: TArray<T>); overload;
    destructor Destroy; override;

    // --- Mutação ---
    function Adicionar(const AItem: T): TListaGenerica<T>;
    function AdicionarRange(const AItems: TArray<T>): TListaGenerica<T>;
    function Inserir(AIndex: Integer; const AItem: T): TListaGenerica<T>;
    function Remover(const AItem: T): TListaGenerica<T>;
    function RemoverEm(AIndex: Integer): TListaGenerica<T>;
    function RemoverOnde(APred: TPredicado<T>): TListaGenerica<T>;
    procedure Limpar;

    // --- Busca ---
    function Contem(const AItem: T): Boolean;
    function IndiceOf(const AItem: T): Integer;
    function Primeiro: T;
    function Ultimo: T;
    function PrimeiroOnde(APred: TPredicado<T>): T;
    function ExisteOnde(APred: TPredicado<T>): Boolean;

    // --- Transformação (retornam novas listas) ---
    function Onde(APred: TPredicado<T>): TListaGenerica<T>;
    function Mapear<R>(AFunc: TTransformacao<T, R>): TListaGenerica<R>;
    function PrimeirosN(N: Integer): TListaGenerica<T>;
    function UltimosN(N: Integer): TListaGenerica<T>;
    function Inverter: TListaGenerica<T>;
    function Distinto: TListaGenerica<T>;

    // --- Agregação ---
    function Contar: Integer; overload;
    function ContarOnde(APred: TPredicado<T>): Integer;
    function VaziaOuNil: Boolean;

    // --- Ordenação ---
    function Ordenar: TListaGenerica<T>; overload;
    function Ordenar(AComparacao: TComparison<T>): TListaGenerica<T>; overload;
    function OrdenarDesc(AComparacao: TComparison<T>): TListaGenerica<T>;

    // --- Iteração ---
    procedure ParaCada(AAcao: TAcao<T>);

    // --- Conversão ---
    function ToArray: TArray<T>;
    function ToList: TList<T>;

    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: T read GetItem write SetItem; default;
  end;

implementation

constructor TListaGenerica<T>.Create;
begin
  inherited Create;
  FItems := TList<T>.Create;
end;

constructor TListaGenerica<T>.Create(const AItems: TArray<T>);
begin
  Create;
  FItems.AddRange(AItems);
end;

destructor TListaGenerica<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TListaGenerica<T>.GetCount: Integer;
begin Result := FItems.Count; end;

function TListaGenerica<T>.GetItem(AIndex: Integer): T;
begin Result := FItems[AIndex]; end;

procedure TListaGenerica<T>.SetItem(AIndex: Integer; const AValue: T);
begin FItems[AIndex] := AValue; end;

function TListaGenerica<T>.Adicionar(const AItem: T): TListaGenerica<T>;
begin FItems.Add(AItem); Result := Self; end;

function TListaGenerica<T>.AdicionarRange(const AItems: TArray<T>): TListaGenerica<T>;
begin FItems.AddRange(AItems); Result := Self; end;

function TListaGenerica<T>.Inserir(AIndex: Integer; const AItem: T): TListaGenerica<T>;
begin FItems.Insert(AIndex, AItem); Result := Self; end;

function TListaGenerica<T>.Remover(const AItem: T): TListaGenerica<T>;
begin FItems.Remove(AItem); Result := Self; end;

function TListaGenerica<T>.RemoverEm(AIndex: Integer): TListaGenerica<T>;
begin FItems.Delete(AIndex); Result := Self; end;

function TListaGenerica<T>.RemoverOnde(APred: TPredicado<T>): TListaGenerica<T>;
var I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
    if APred(FItems[I]) then FItems.Delete(I);
  Result := Self;
end;

procedure TListaGenerica<T>.Limpar;
begin FItems.Clear; end;

function TListaGenerica<T>.Contem(const AItem: T): Boolean;
begin Result := FItems.Contains(AItem); end;

function TListaGenerica<T>.IndiceOf(const AItem: T): Integer;
begin Result := FItems.IndexOf(AItem); end;

function TListaGenerica<T>.Primeiro: T;
begin
  if FItems.Count = 0 then raise EInvalidOpException.Create('Lista vazia');
  Result := FItems[0];
end;

function TListaGenerica<T>.Ultimo: T;
begin
  if FItems.Count = 0 then raise EInvalidOpException.Create('Lista vazia');
  Result := FItems[FItems.Count - 1];
end;

function TListaGenerica<T>.PrimeiroOnde(APred: TPredicado<T>): T;
var Item: T;
begin
  for Item in FItems do
    if APred(Item) then Exit(Item);
  raise EInvalidOpException.Create('Elemento não encontrado');
end;

function TListaGenerica<T>.ExisteOnde(APred: TPredicado<T>): Boolean;
var Item: T;
begin
  for Item in FItems do
    if APred(Item) then Exit(True);
  Result := False;
end;

function TListaGenerica<T>.Onde(APred: TPredicado<T>): TListaGenerica<T>;
var Item: T;
begin
  Result := TListaGenerica<T>.Create;
  for Item in FItems do
    if APred(Item) then Result.FItems.Add(Item);
end;

function TListaGenerica<T>.Mapear<R>(AFunc: TTransformacao<T, R>): TListaGenerica<R>;
var Item: T;
begin
  Result := TListaGenerica<R>.Create;
  for Item in FItems do
    Result.FItems.Add(AFunc(Item));
end;

function TListaGenerica<T>.PrimeirosN(N: Integer): TListaGenerica<T>;
var I: Integer;
begin
  Result := TListaGenerica<T>.Create;
  for I := 0 to Min(N, FItems.Count) - 1 do
    Result.FItems.Add(FItems[I]);
end;

function TListaGenerica<T>.UltimosN(N: Integer): TListaGenerica<T>;
var I, Inicio: Integer;
begin
  Result := TListaGenerica<T>.Create;
  Inicio := Max(0, FItems.Count - N);
  for I := Inicio to FItems.Count - 1 do
    Result.FItems.Add(FItems[I]);
end;

function TListaGenerica<T>.Inverter: TListaGenerica<T>;
var I: Integer;
begin
  Result := TListaGenerica<T>.Create;
  for I := FItems.Count - 1 downto 0 do
    Result.FItems.Add(FItems[I]);
end;

function TListaGenerica<T>.Distinto: TListaGenerica<T>;
var
  Cmp : IComparer<T>;
  Item: T;
begin
  Result := TListaGenerica<T>.Create;
  Cmp    := TComparer<T>.Default;
  for Item in FItems do
    if not Result.FItems.Contains(Item) then
      Result.FItems.Add(Item);
end;

function TListaGenerica<T>.Contar: Integer;
begin Result := FItems.Count; end;

function TListaGenerica<T>.ContarOnde(APred: TPredicado<T>): Integer;
var Item: T;
begin
  Result := 0;
  for Item in FItems do
    if APred(Item) then Inc(Result);
end;

function TListaGenerica<T>.VaziaOuNil: Boolean;
begin Result := FItems.Count = 0; end;

function TListaGenerica<T>.Ordenar: TListaGenerica<T>;
begin FItems.Sort; Result := Self; end;

function TListaGenerica<T>.Ordenar(AComparacao: TComparison<T>): TListaGenerica<T>;
begin
  FItems.Sort(TComparer<T>.Construct(AComparacao));
  Result := Self;
end;

function TListaGenerica<T>.OrdenarDesc(AComparacao: TComparison<T>): TListaGenerica<T>;
begin
  FItems.Sort(TComparer<T>.Construct(
    function(const A, B: T): Integer begin Result := -AComparacao(A, B); end));
  Result := Self;
end;

procedure TListaGenerica<T>.ParaCada(AAcao: TAcao<T>);
var Item: T;
begin
  for Item in FItems do AAcao(Item);
end;

function TListaGenerica<T>.ToArray: TArray<T>;
begin Result := FItems.ToArray; end;

function TListaGenerica<T>.ToList: TList<T>;
begin
  Result := TList<T>.Create;
  Result.AddRange(FItems);
end;

// ---------------------------------------------------------------------------
// USO:
//   var L := TListaGenerica<Integer>.Create([5,3,1,4,2]);
//
//   // Fluent
//   var Pares := L
//     .Onde(function(N: Integer): Boolean begin Result := N mod 2 = 0; end)
//     .Ordenar
//     .ToArray;
//   // [2, 4]
//
//   // Mapear para string
//   var Strs := L.Mapear<string>(
//     function(N: Integer): string begin Result := IntToStr(N); end);
//
//   L.ParaCada(procedure(N: Integer) begin Write(N,' '); end);
//   Writeln;
//
//   L.Free; Pares.Free; Strs.Free; // liberar novos objetos retornados
// ---------------------------------------------------------------------------

end.
