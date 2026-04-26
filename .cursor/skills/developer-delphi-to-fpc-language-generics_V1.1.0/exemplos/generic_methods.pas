unit generic_methods;
{
  Generics — métodos genéricos em Delphi
  procedure/function com parâmetro de tipo próprio
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Métodos genéricos livres (standalone)
// ---------------------------------------------------------------------------

// Trocar dois valores de qualquer tipo
procedure Trocar<T>(var A, B: T);

// Retornar o maior de dois valores (requer IComparable)
function Maximo<T>(const A, B: T): T;

// Verificar se um array contém um elemento
function Contem<T>(const AArray: TArray<T>; const AItem: T): Boolean;

// Filtrar array retornando elementos que passam no predicado
function Filtrar<T>(const AArray: TArray<T>;
  APredicate: TFunc<T, Boolean>): TArray<T>;

// Mapear array aplicando transformação a cada elemento
function Mapear<T, R>(const AArray: TArray<T>;
  ATransform: TFunc<T, R>): TArray<R>;

// Reduzir (fold) array a um valor acumulado
function Reduzir<T>(const AArray: TArray<T>;
  AAccumulator: TFunc<T, T, T>; const AInicial: T): T;

// ---------------------------------------------------------------------------
// Classe com métodos genéricos
// ---------------------------------------------------------------------------
type
  TConversor = class
  public
    // Converter qualquer TObject para JSON simplificado
    class function ParaString<T>(const AValue: T): string;

    // Tentar converter string para tipo T (usa generics + RTTI simplificado)
    class function TentarConverter<T>(const AStr: string; out AResult: T): Boolean;
  end;

// ---------------------------------------------------------------------------
// Método genérico em classe genérica
// ---------------------------------------------------------------------------
type
  TTransformador<TSource> = class
  private
    FDados: TArray<TSource>;
  public
    constructor Create(const ADados: TArray<TSource>);
    function Filtrar(APredicate: TFunc<TSource, Boolean>): TTransformador<TSource>;
    function Mapear<TDest>(ATransform: TFunc<TSource, TDest>): TArray<TDest>;
    function ToArray: TArray<TSource>;
  end;

implementation

// ---------------------------------------------------------------------------
// Trocar<T>
// ---------------------------------------------------------------------------

procedure Trocar<T>(var A, B: T);
var Temp: T;
begin
  Temp := A;
  A    := B;
  B    := Temp;
end;

// ---------------------------------------------------------------------------
// Maximo<T> — usa TComparer<T>.Default para comparação genérica
// ---------------------------------------------------------------------------

function Maximo<T>(const A, B: T): T;
begin
  if TComparer<T>.Default.Compare(A, B) >= 0 then
    Result := A
  else
    Result := B;
end;

// ---------------------------------------------------------------------------
// Contem<T>
// ---------------------------------------------------------------------------

function Contem<T>(const AArray: TArray<T>; const AItem: T): Boolean;
var
  Cmp : IComparer<T>;
  Item: T;
begin
  Cmp := TComparer<T>.Default;
  for Item in AArray do
    if Cmp.Compare(Item, AItem) = 0 then
      Exit(True);
  Result := False;
end;

// ---------------------------------------------------------------------------
// Filtrar<T>
// ---------------------------------------------------------------------------

function Filtrar<T>(const AArray: TArray<T>;
  APredicate: TFunc<T, Boolean>): TArray<T>;
var
  Item: T;
  Res : TArray<T>;
  N   : Integer;
begin
  N := 0;
  SetLength(Res, Length(AArray));
  for Item in AArray do
    if APredicate(Item) then
    begin
      Res[N] := Item;
      Inc(N);
    end;
  SetLength(Res, N);
  Result := Res;
end;

// ---------------------------------------------------------------------------
// Mapear<T, R>
// ---------------------------------------------------------------------------

function Mapear<T, R>(const AArray: TArray<T>;
  ATransform: TFunc<T, R>): TArray<R>;
var I: Integer;
begin
  SetLength(Result, Length(AArray));
  for I := 0 to High(AArray) do
    Result[I] := ATransform(AArray[I]);
end;

// ---------------------------------------------------------------------------
// Reduzir<T>
// ---------------------------------------------------------------------------

function Reduzir<T>(const AArray: TArray<T>;
  AAccumulator: TFunc<T, T, T>; const AInicial: T): T;
var Item: T;
begin
  Result := AInicial;
  for Item in AArray do
    Result := AAccumulator(Result, Item);
end;

// ---------------------------------------------------------------------------
// TConversor
// ---------------------------------------------------------------------------

class function TConversor.ParaString<T>(const AValue: T): string;
begin
  // TValue.From<T>(AValue).ToString — reflexão simplificada
  Result := TValue.From<T>(AValue).ToString;
end;

class function TConversor.TentarConverter<T>(const AStr: string; out AResult: T): Boolean;
var V: TValue;
begin
  // Conversão básica via TValue — funciona para tipos primitivos
  try
    V := TValue.From<string>(AStr);
    AResult := V.AsType<T>;
    Result  := True;
  except
    Result := False;
  end;
end;

// ---------------------------------------------------------------------------
// TTransformador<TSource>
// ---------------------------------------------------------------------------

constructor TTransformador<TSource>.Create(const ADados: TArray<TSource>);
begin
  inherited Create;
  FDados := Copy(ADados);
end;

function TTransformador<TSource>.Filtrar(
  APredicate: TFunc<TSource, Boolean>): TTransformador<TSource>;
begin
  FDados := generic_methods.Filtrar<TSource>(FDados, APredicate);
  Result := Self;
end;

function TTransformador<TSource>.Mapear<TDest>(
  ATransform: TFunc<TSource, TDest>): TArray<TDest>;
begin
  Result := generic_methods.Mapear<TSource, TDest>(FDados, ATransform);
end;

function TTransformador<TSource>.ToArray: TArray<TSource>;
begin
  Result := Copy(FDados);
end;

// ---------------------------------------------------------------------------
// USO:
//   // Trocar
//   var A := 10; var B := 20;
//   Trocar<Integer>(A, B);  // A=20, B=10
//   var S1 := 'hello'; var S2 := 'world';
//   Trocar<string>(S1, S2);
//
//   // Máximo
//   Writeln(Maximo<Integer>(3, 7));     // 7
//   Writeln(Maximo<string>('b', 'a')); // b
//
//   // Filtrar + Mapear pipeline
//   var Nums := TArray<Integer>.Create(1,2,3,4,5,6,7,8,9,10);
//   var Pares := Filtrar<Integer>(Nums, function(N: Integer): Boolean begin Result := N mod 2 = 0; end);
//   var Dobros := Mapear<Integer,Integer>(Pares, function(N: Integer): Integer begin Result := N*2; end);
//   // Dobros = [4, 8, 12, 16, 20]
//
//   var Soma := Reduzir<Integer>(Nums, function(Acc, N: Integer): Integer begin Result := Acc+N; end, 0);
//   Writeln(Soma);  // 55
//
//   // Fluent
//   var T := TTransformador<Integer>.Create(Nums);
//   var Resultado := T
//     .Filtrar(function(N: Integer): Boolean begin Result := N > 3; end)
//     .Mapear<string>(function(N: Integer): string begin Result := IntToStr(N); end);
//   T.Free;
// ---------------------------------------------------------------------------

end.
