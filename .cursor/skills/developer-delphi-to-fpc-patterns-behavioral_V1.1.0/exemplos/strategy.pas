unit strategy;
{
  Strategy Pattern em Delphi — algoritmos de ordenação intercambiáveis
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface da estratégia
// ---------------------------------------------------------------------------
type
  ISortStrategy = interface
  ['{ST000001-0000-0000-0000-000000000001}']
    procedure Sort(var AArr: TArray<Integer>);
    function  GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Estratégias concretas
// ---------------------------------------------------------------------------
type
  TBubbleSortStrategy = class(TInterfacedObject, ISortStrategy)
  public
    procedure Sort(var AArr: TArray<Integer>);
    function  GetNome: string;
  end;

  TQuickSortStrategy = class(TInterfacedObject, ISortStrategy)
  private
    procedure QSort(var AArr: TArray<Integer>; Lo, Hi: Integer);
  public
    procedure Sort(var AArr: TArray<Integer>);
    function  GetNome: string;
  end;

  TMergeSortStrategy = class(TInterfacedObject, ISortStrategy)
  private
    procedure Merge(var AArr: TArray<Integer>; Lo, Mid, Hi: Integer);
    procedure MSort(var AArr: TArray<Integer>; Lo, Hi: Integer);
  public
    procedure Sort(var AArr: TArray<Integer>);
    function  GetNome: string;
  end;

  // Estratégia delegada para anon method — permite inline
  TLambdaSortStrategy = class(TInterfacedObject, ISortStrategy)
  private
    FNome: string;
    FSortProc: reference to procedure(var AArr: TArray<Integer>);
  public
    constructor Create(const ANome: string;
      ASortProc: reference to procedure(var AArr: TArray<Integer>));
    procedure Sort(var AArr: TArray<Integer>);
    function  GetNome: string;
  end;

// ---------------------------------------------------------------------------
// Contexto — usa a estratégia sem saber qual
// ---------------------------------------------------------------------------
type
  TSorter = class
  private
    FStrategy: ISortStrategy;
    FComparacoes: Integer;
  public
    constructor Create(AStrategy: ISortStrategy);
    procedure SetStrategy(AStrategy: ISortStrategy);
    procedure Sort(var AArr: TArray<Integer>);
    function  Benchmark(var AArr: TArray<Integer>): string;
    property Strategy: ISortStrategy read FStrategy write FStrategy;
  end;

// ---------------------------------------------------------------------------
// Registry de estratégias
// ---------------------------------------------------------------------------
type
  TSortRegistry = class
  private
    class var FReg: TDictionary<string, ISortStrategy>;
    class constructor Create;
    class destructor Destroy;
  public
    class procedure Registrar(const ANome: string; AStrat: ISortStrategy);
    class function  Obter(const ANome: string): ISortStrategy;
    class function  Nomes: TArray<string>;
  end;

// Helpers
function ArrayToStr(const AArr: TArray<Integer>): string;
function ArrCopia(const AArr: TArray<Integer>): TArray<Integer>;

implementation

uses System.Diagnostics;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function ArrayToStr(const AArr: TArray<Integer>): string;
var SB: TStringBuilder; I: Integer;
begin
  SB := TStringBuilder.Create;
  try
    SB.Append('[');
    for I := 0 to High(AArr) do
    begin
      if I > 0 then SB.Append(', ');
      SB.Append(AArr[I]);
    end;
    SB.Append(']');
    Result := SB.ToString;
  finally SB.Free; end;
end;

function ArrCopia(const AArr: TArray<Integer>): TArray<Integer>;
begin
  SetLength(Result, Length(AArr));
  if Length(AArr) > 0 then
    Move(AArr[0], Result[0], Length(AArr) * SizeOf(Integer));
end;

// ---------------------------------------------------------------------------
// TBubbleSortStrategy
// ---------------------------------------------------------------------------

procedure TBubbleSortStrategy.Sort(var AArr: TArray<Integer>);
var I, J, Tmp: Integer;
begin
  for I := High(AArr) downto 1 do
    for J := 0 to I - 1 do
      if AArr[J] > AArr[J+1] then
      begin
        Tmp := AArr[J]; AArr[J] := AArr[J+1]; AArr[J+1] := Tmp;
      end;
end;

function TBubbleSortStrategy.GetNome: string;
begin Result := 'BubbleSort'; end;

// ---------------------------------------------------------------------------
// TQuickSortStrategy
// ---------------------------------------------------------------------------

procedure TQuickSortStrategy.QSort(var AArr: TArray<Integer>; Lo, Hi: Integer);
var Pivot, I, J, Tmp: Integer;
begin
  if Lo >= Hi then Exit;
  Pivot := AArr[(Lo + Hi) div 2];
  I := Lo; J := Hi;
  while I <= J do
  begin
    while AArr[I] < Pivot do Inc(I);
    while AArr[J] > Pivot do Dec(J);
    if I <= J then
    begin
      Tmp := AArr[I]; AArr[I] := AArr[J]; AArr[J] := Tmp;
      Inc(I); Dec(J);
    end;
  end;
  QSort(AArr, Lo, J);
  QSort(AArr, I, Hi);
end;

procedure TQuickSortStrategy.Sort(var AArr: TArray<Integer>);
begin
  if Length(AArr) > 1 then
    QSort(AArr, 0, High(AArr));
end;

function TQuickSortStrategy.GetNome: string;
begin Result := 'QuickSort'; end;

// ---------------------------------------------------------------------------
// TMergeSortStrategy
// ---------------------------------------------------------------------------

procedure TMergeSortStrategy.Merge(var AArr: TArray<Integer>; Lo, Mid, Hi: Integer);
var Tmp: TArray<Integer>;
    I, J, K: Integer;
begin
  SetLength(Tmp, Hi - Lo + 1);
  I := Lo; J := Mid + 1; K := 0;
  while (I <= Mid) and (J <= Hi) do
  begin
    if AArr[I] <= AArr[J] then begin Tmp[K] := AArr[I]; Inc(I); end
    else begin Tmp[K] := AArr[J]; Inc(J); end;
    Inc(K);
  end;
  while I <= Mid  do begin Tmp[K] := AArr[I]; Inc(I); Inc(K); end;
  while J <= Hi   do begin Tmp[K] := AArr[J]; Inc(J); Inc(K); end;
  Move(Tmp[0], AArr[Lo], Length(Tmp) * SizeOf(Integer));
end;

procedure TMergeSortStrategy.MSort(var AArr: TArray<Integer>; Lo, Hi: Integer);
var Mid: Integer;
begin
  if Lo >= Hi then Exit;
  Mid := (Lo + Hi) div 2;
  MSort(AArr, Lo, Mid);
  MSort(AArr, Mid + 1, Hi);
  Merge(AArr, Lo, Mid, Hi);
end;

procedure TMergeSortStrategy.Sort(var AArr: TArray<Integer>);
begin
  if Length(AArr) > 1 then MSort(AArr, 0, High(AArr));
end;

function TMergeSortStrategy.GetNome: string;
begin Result := 'MergeSort'; end;

// ---------------------------------------------------------------------------
// TLambdaSortStrategy
// ---------------------------------------------------------------------------

constructor TLambdaSortStrategy.Create(const ANome: string;
  ASortProc: reference to procedure(var AArr: TArray<Integer>));
begin inherited Create; FNome := ANome; FSortProc := ASortProc; end;

procedure TLambdaSortStrategy.Sort(var AArr: TArray<Integer>);
begin FSortProc(AArr); end;

function TLambdaSortStrategy.GetNome: string;
begin Result := FNome; end;

// ---------------------------------------------------------------------------
// TSorter
// ---------------------------------------------------------------------------

constructor TSorter.Create(AStrategy: ISortStrategy);
begin inherited Create; FStrategy := AStrategy; end;

procedure TSorter.SetStrategy(AStrategy: ISortStrategy);
begin FStrategy := AStrategy; end;

procedure TSorter.Sort(var AArr: TArray<Integer>);
begin FStrategy.Sort(AArr); end;

function TSorter.Benchmark(var AArr: TArray<Integer>): string;
var SW: TStopwatch;
    Copia: TArray<Integer>;
begin
  Copia := ArrCopia(AArr);
  SW := TStopwatch.StartNew;
  FStrategy.Sort(Copia);
  SW.Stop;
  Result := Format('%s: %dms', [FStrategy.Nome, SW.ElapsedMilliseconds]);
  AArr := Copia;
end;

// ---------------------------------------------------------------------------
// TSortRegistry
// ---------------------------------------------------------------------------

class constructor TSortRegistry.Create;
begin
  FReg := TDictionary<string, ISortStrategy>.Create;
  Registrar('bubble', TBubbleSortStrategy.Create);
  Registrar('quick',  TQuickSortStrategy.Create);
  Registrar('merge',  TMergeSortStrategy.Create);
end;

class destructor TSortRegistry.Destroy;
begin FReg.Free; end;

class procedure TSortRegistry.Registrar(const ANome: string; AStrat: ISortStrategy);
begin FReg.AddOrSetValue(ANome.ToLower, AStrat); end;

class function TSortRegistry.Obter(const ANome: string): ISortStrategy;
begin
  if not FReg.TryGetValue(ANome.ToLower, Result) then
    raise EArgumentException.CreateFmt('Estratégia "%s" não registrada', [ANome]);
end;

class function TSortRegistry.Nomes: TArray<string>;
begin Result := FReg.Keys.ToArray; end;

// ---------------------------------------------------------------------------
// USO:
//   var Arr := TArray<Integer>.Create(5, 3, 8, 1, 9, 2, 7, 4, 6);
//
//   // Trocar estratégia em runtime
//   var Sorter := TSorter.Create(TBubbleSortStrategy.Create);
//   var A1 := ArrCopia(Arr);
//   Sorter.Sort(A1);
//   Writeln('Bubble: ', ArrayToStr(A1));
//
//   Sorter.SetStrategy(TQuickSortStrategy.Create);
//   var A2 := ArrCopia(Arr);
//   Sorter.Sort(A2);
//   Writeln('Quick: ', ArrayToStr(A2));
//
//   // Registry — escolha por string (ex.: vem de config)
//   var Strat := TSortRegistry.Obter('merge');
//   var A3 := ArrCopia(Arr);
//   Strat.Sort(A3);
//   Writeln('Merge: ', ArrayToStr(A3));
//
//   // Lambda — estratégia inline
//   var LStrat: ISortStrategy := TLambdaSortStrategy.Create('InsertionSort',
//     procedure(var A: TArray<Integer>)
//     var I, J, K: Integer;
//     begin
//       for I := 1 to High(A) do
//       begin K := A[I]; J := I - 1;
//         while (J >= 0) and (A[J] > K) do begin A[J+1] := A[J]; Dec(J); end;
//         A[J+1] := K;
//       end;
//     end);
//   TSortRegistry.Registrar('insertion', LStrat);
// ---------------------------------------------------------------------------

end.
