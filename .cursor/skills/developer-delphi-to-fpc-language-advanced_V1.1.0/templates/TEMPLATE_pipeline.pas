unit TEMPLATE_pipeline;
{
  TEMPLATE: Pipeline funcional com TFunc<T,T> chainable
  Uso: copie, renomeie e adapte o tipo T.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Pipeline genérico imutável — cada passo retorna nova instância
// ---------------------------------------------------------------------------
type
  TPipeline<T> = class
  private
    FDados : TArray<T>;
    FCount : Integer;

    constructor CreateInternal(const ADados: TArray<T>; ACount: Integer);
  public
    constructor Create(const ADados: TArray<T>); overload;
    constructor Create(const ADados: TList<T>); overload;

    // Filtragem
    function Onde(APred: TFunc<T, Boolean>): TPipeline<T>;
    function PrimeirosN(N: Integer): TPipeline<T>;
    function UltimosN(N: Integer): TPipeline<T>;
    function Pular(N: Integer): TPipeline<T>;

    // Transformação
    function Mapear<R>(AFunc: TFunc<T, R>): TPipeline<R>;
    function Ordenar(ACmp: TComparison<T> = nil): TPipeline<T>;
    function OrdenarDesc(ACmp: TComparison<T>): TPipeline<T>;
    function Inverter: TPipeline<T>;
    function Distinto: TPipeline<T>;

    // Inspeção
    function Cada(AAcao: TProc<T>): TPipeline<T>;  // side-effect; retorna self
    function Log(const APrefixo: string = ''): TPipeline<T>;

    // Terminais — encerram o pipeline
    function ToArray: TArray<T>;
    function ToList: TObjectList<T>;    // só para class T
    function Primeiro: T;
    function PrimeiroOuDefault(const ADefault: T): T;
    function Ultimo: T;
    function Existe(APred: TFunc<T, Boolean>): Boolean;
    function Todos(APred: TFunc<T, Boolean>): Boolean;
    function Nenhum(APred: TFunc<T, Boolean>): Boolean;
    function Contar: Integer; overload;
    function ContarOnde(APred: TFunc<T, Boolean>): Integer;
    procedure ParaCada(AAcao: TProc<T>);

    property Count: Integer read FCount;
  end;

// Factory function
function Pipeline<T>(const ADados: TArray<T>): TPipeline<T>;

implementation

function Pipeline<T>(const ADados: TArray<T>): TPipeline<T>;
begin
  Result := TPipeline<T>.Create(ADados);
end;

constructor TPipeline<T>.Create(const ADados: TArray<T>);
begin
  inherited Create;
  FDados := Copy(ADados);
  FCount := Length(FDados);
end;

constructor TPipeline<T>.Create(const ADados: TList<T>);
begin
  inherited Create;
  FDados := ADados.ToArray;
  FCount := Length(FDados);
end;

constructor TPipeline<T>.CreateInternal(const ADados: TArray<T>; ACount: Integer);
begin
  inherited Create;
  FDados := ADados;
  FCount := ACount;
end;

function TPipeline<T>.Onde(APred: TFunc<T, Boolean>): TPipeline<T>;
var
  Res: TArray<T>;
  N  : Integer;
  I  : Integer;
begin
  SetLength(Res, FCount);
  N := 0;
  for I := 0 to FCount - 1 do
    if APred(FDados[I]) then begin Res[N] := FDados[I]; Inc(N); end;
  Result := TPipeline<T>.CreateInternal(Res, N);
end;

function TPipeline<T>.PrimeirosN(N: Integer): TPipeline<T>;
var Take: Integer;
begin
  Take   := Min(N, FCount);
  Result := TPipeline<T>.CreateInternal(Copy(FDados, 0, Take), Take);
end;

function TPipeline<T>.UltimosN(N: Integer): TPipeline<T>;
var Skip: Integer;
begin
  Skip   := Max(0, FCount - N);
  Result := TPipeline<T>.CreateInternal(Copy(FDados, Skip, FCount - Skip), Min(N, FCount));
end;

function TPipeline<T>.Pular(N: Integer): TPipeline<T>;
var Skip: Integer;
begin
  Skip   := Min(N, FCount);
  Result := TPipeline<T>.CreateInternal(Copy(FDados, Skip, FCount - Skip), FCount - Skip);
end;

function TPipeline<T>.Mapear<R>(AFunc: TFunc<T, R>): TPipeline<R>;
var
  Res: TArray<R>;
  I  : Integer;
begin
  SetLength(Res, FCount);
  for I := 0 to FCount - 1 do Res[I] := AFunc(FDados[I]);
  Result := TPipeline<R>.CreateInternal(Res, FCount);
end;

function TPipeline<T>.Ordenar(ACmp: TComparison<T>): TPipeline<T>;
var Copia: TArray<T>;
begin
  Copia := Copy(FDados, 0, FCount);
  if Assigned(ACmp) then
    TArray.Sort<T>(Copia, TComparer<T>.Construct(ACmp))
  else
    TArray.Sort<T>(Copia);
  Result := TPipeline<T>.CreateInternal(Copia, FCount);
end;

function TPipeline<T>.OrdenarDesc(ACmp: TComparison<T>): TPipeline<T>;
begin
  Result := Ordenar(function(const A, B: T): Integer begin Result := -ACmp(A, B); end);
end;

function TPipeline<T>.Inverter: TPipeline<T>;
var
  Res: TArray<T>;
  I  : Integer;
begin
  SetLength(Res, FCount);
  for I := 0 to FCount - 1 do Res[I] := FDados[FCount - 1 - I];
  Result := TPipeline<T>.CreateInternal(Res, FCount);
end;

function TPipeline<T>.Distinto: TPipeline<T>;
var
  Res : TArray<T>;
  N   : Integer;
  I, J: Integer;
  Cmp : IComparer<T>;
  Dup : Boolean;
begin
  Cmp := TComparer<T>.Default;
  SetLength(Res, FCount);
  N := 0;
  for I := 0 to FCount - 1 do
  begin
    Dup := False;
    for J := 0 to N - 1 do
      if Cmp.Compare(Res[J], FDados[I]) = 0 then begin Dup := True; Break; end;
    if not Dup then begin Res[N] := FDados[I]; Inc(N); end;
  end;
  Result := TPipeline<T>.CreateInternal(Res, N);
end;

function TPipeline<T>.Cada(AAcao: TProc<T>): TPipeline<T>;
var I: Integer;
begin
  for I := 0 to FCount - 1 do AAcao(FDados[I]);
  Result := Self;
end;

function TPipeline<T>.Log(const APrefixo: string): TPipeline<T>;
var I: Integer;
begin
  for I := 0 to FCount - 1 do
    Writeln(APrefixo, TValue.From<T>(FDados[I]).ToString);
  Result := Self;
end;

function TPipeline<T>.ToArray: TArray<T>;
begin Result := Copy(FDados, 0, FCount); end;

function TPipeline<T>.ToList: TObjectList<T>;
var I: Integer;
begin
  Result := TObjectList<T>.Create(False);
  for I := 0 to FCount - 1 do Result.Add(TObject(TValue.From<T>(FDados[I]).AsObject));
end;

function TPipeline<T>.Primeiro: T;
begin
  if FCount = 0 then raise EInvalidOpException.Create('Pipeline vazio');
  Result := FDados[0];
end;

function TPipeline<T>.PrimeiroOuDefault(const ADefault: T): T;
begin
  if FCount = 0 then Result := ADefault
  else               Result := FDados[0];
end;

function TPipeline<T>.Ultimo: T;
begin
  if FCount = 0 then raise EInvalidOpException.Create('Pipeline vazio');
  Result := FDados[FCount - 1];
end;

function TPipeline<T>.Existe(APred: TFunc<T, Boolean>): Boolean;
var I: Integer;
begin
  for I := 0 to FCount - 1 do
    if APred(FDados[I]) then Exit(True);
  Result := False;
end;

function TPipeline<T>.Todos(APred: TFunc<T, Boolean>): Boolean;
var I: Integer;
begin
  for I := 0 to FCount - 1 do
    if not APred(FDados[I]) then Exit(False);
  Result := True;
end;

function TPipeline<T>.Nenhum(APred: TFunc<T, Boolean>): Boolean;
begin Result := not Existe(APred); end;

function TPipeline<T>.Contar: Integer;
begin Result := FCount; end;

function TPipeline<T>.ContarOnde(APred: TFunc<T, Boolean>): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to FCount - 1 do
    if APred(FDados[I]) then Inc(Result);
end;

procedure TPipeline<T>.ParaCada(AAcao: TProc<T>);
var I: Integer;
begin
  for I := 0 to FCount - 1 do AAcao(FDados[I]);
end;

// ---------------------------------------------------------------------------
// USO:
//   var Nums := TArray<Integer>.Create(5,1,8,3,2,7,4,9,6,10);
//
//   // Filtrar pares, ordenar, pegar primeiros 3, mapear para string
//   var Resultado := Pipeline<Integer>(Nums)
//     .Onde(function(N: Integer): Boolean begin Result := N mod 2 = 0; end)
//     .Ordenar
//     .PrimeirosN(3)
//     .Mapear<string>(function(N: Integer): string begin Result := 'Item ' + N.ToString; end)
//     .ToArray;
//   // ['Item 2', 'Item 4', 'Item 6']
//
//   // Agregações
//   var P := Pipeline<Integer>(Nums);
//   Writeln(P.Existe(function(N: Integer): Boolean begin Result := N > 8; end));  // True
//   Writeln(P.Todos(function(N: Integer): Boolean begin Result := N > 0; end));   // True
//   Writeln(P.ContarOnde(function(N: Integer): Boolean begin Result := N mod 2=0; end)); // 5
//   Writeln(P.Primeiro);   // 5
//   Writeln(P.Ultimo);     // 10
//   P.Free;
// ---------------------------------------------------------------------------

end.
