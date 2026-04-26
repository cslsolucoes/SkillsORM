unit TEMPLATE_array_helpers;
{
  TEMPLATE: Operacoes comuns em TArray<T>
  Uso: unit de utilidades — referencie diretamente em seus projetos.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

// ---------------------------------------------------------------------------
// Helpers genericos para TArray<T>
// Uso: TArrayHelper<Integer>.Contem(A, 42)
// ---------------------------------------------------------------------------
type
  TArrayHelper<T> = class
  public
    // Verificar existencia
    class function Contem(const A: TArray<T>; const V: T): Boolean;

    // Filtrar
    class function Onde(const A: TArray<T>;
      APredicate: TPredicate<T>): TArray<T>;

    // Mapear (transformar)
    class function Mapa<TResult>(const A: TArray<T>;
      AFunc: TFunc<T, TResult>): TArray<TResult>;

    // Reduzir
    class function Reduzir(const A: TArray<T>; AFunc: TFunc<T, T, T>;
      const AInicial: T): T;

    // Primeiro/ultimo com predicado
    class function Primeiro(const A: TArray<T>; APredicate: TPredicate<T>;
      out AValor: T): Boolean;

    // Contar elementos que satisfazem condicao
    class function Contar(const A: TArray<T>;
      APredicate: TPredicate<T>): Integer;

    // Adicionar / remover (retorna novo array)
    class function Adicionar(const A: TArray<T>; const V: T): TArray<T>;
    class function RemoverEm(const A: TArray<T>; AIdx: Integer): TArray<T>;

    // Concatenar
    class function Concat(const A, B: TArray<T>): TArray<T>;

    // Inverter
    class function Inverter(const A: TArray<T>): TArray<T>;

    // Unico (sem duplicatas)
    class function Unico(const A: TArray<T>): TArray<T>;
  end;

// Helpers especializados para tipos comuns
function SomarInts(const A: TArray<Integer>): Int64;
function MediaDoubles(const A: TArray<Double>): Double;
function MaiorInt(const A: TArray<Integer>): Integer;
function MenorInt(const A: TArray<Integer>): Integer;

implementation

class function TArrayHelper<T>.Contem(const A: TArray<T>; const V: T): Boolean;
var
  Comp: IEqualityComparer<T>;
  E: T;
begin
  Comp := TEqualityComparer<T>.Default;
  for E in A do
    if Comp.Equals(E, V) then Exit(True);
  Result := False;
end;

class function TArrayHelper<T>.Onde(const A: TArray<T>;
  APredicate: TPredicate<T>): TArray<T>;
var
  L: TList<T>;
  E: T;
begin
  L := TList<T>.Create;
  try
    for E in A do
      if APredicate(E) then L.Add(E);
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

class function TArrayHelper<T>.Mapa<TResult>(const A: TArray<T>;
  AFunc: TFunc<T, TResult>): TArray<TResult>;
var
  I: Integer;
begin
  SetLength(Result, Length(A));
  for I := 0 to High(A) do
    Result[I] := AFunc(A[I]);
end;

class function TArrayHelper<T>.Reduzir(const A: TArray<T>;
  AFunc: TFunc<T, T, T>; const AInicial: T): T;
var
  E: T;
begin
  Result := AInicial;
  for E in A do
    Result := AFunc(Result, E);
end;

class function TArrayHelper<T>.Primeiro(const A: TArray<T>;
  APredicate: TPredicate<T>; out AValor: T): Boolean;
var
  E: T;
begin
  for E in A do
    if APredicate(E) then
    begin
      AValor := E;
      Exit(True);
    end;
  Result := False;
end;

class function TArrayHelper<T>.Contar(const A: TArray<T>;
  APredicate: TPredicate<T>): Integer;
var
  E: T;
begin
  Result := 0;
  for E in A do
    if APredicate(E) then Inc(Result);
end;

class function TArrayHelper<T>.Adicionar(const A: TArray<T>;
  const V: T): TArray<T>;
begin
  Result := Copy(A);
  SetLength(Result, Length(Result) + 1);
  Result[High(Result)] := V;
end;

class function TArrayHelper<T>.RemoverEm(const A: TArray<T>;
  AIdx: Integer): TArray<T>;
begin
  Result := Copy(A);
  Delete(Result, AIdx, 1);
end;

class function TArrayHelper<T>.Concat(const A, B: TArray<T>): TArray<T>;
begin
  SetLength(Result, Length(A) + Length(B));
  if Length(A) > 0 then Move(A[0], Result[0],         Length(A) * SizeOf(T));
  if Length(B) > 0 then Move(B[0], Result[Length(A)], Length(B) * SizeOf(T));
end;

class function TArrayHelper<T>.Inverter(const A: TArray<T>): TArray<T>;
var
  I: Integer;
begin
  SetLength(Result, Length(A));
  for I := 0 to High(A) do
    Result[I] := A[High(A) - I];
end;

class function TArrayHelper<T>.Unico(const A: TArray<T>): TArray<T>;
var
  Comp: IEqualityComparer<T>;
  Seen: TList<T>;
  E: T;
begin
  Comp := TEqualityComparer<T>.Default;
  Seen := TList<T>.Create;
  try
    for E in A do
      if not Seen.Contains(E) then
        Seen.Add(E);
    Result := Seen.ToArray;
  finally
    Seen.Free;
  end;
end;

function SomarInts(const A: TArray<Integer>): Int64;
var V: Integer;
begin
  Result := 0;
  for V in A do Inc(Result, V);
end;

function MediaDoubles(const A: TArray<Double>): Double;
var V: Double;
begin
  if Length(A) = 0 then Exit(0);
  Result := 0;
  for V in A do Result := Result + V;
  Result := Result / Length(A);
end;

function MaiorInt(const A: TArray<Integer>): Integer;
var V: Integer;
begin
  if Length(A) = 0 then Exit(Low(Integer));
  Result := A[0];
  for V in A do if V > Result then Result := V;
end;

function MenorInt(const A: TArray<Integer>): Integer;
var V: Integer;
begin
  if Length(A) = 0 then Exit(High(Integer));
  Result := A[0];
  for V in A do if V < Result then Result := V;
end;

// ---------------------------------------------------------------------------
// USO:
//
//   var Nums: TArray<Integer> := [3,1,4,1,5,9,2,6,5,3];
//
//   // Filtrar pares
//   var Pares := TArrayHelper<Integer>.Onde(Nums, function(V: Integer): Boolean
//     begin Result := V mod 2 = 0; end);
//
//   // Mapear para string
//   var Strs := TArrayHelper<Integer>.Mapa<string>(Nums, IntToStr);
//
//   // Soma total
//   Writeln(SomarInts(Nums));
//
//   // Maximo
//   Writeln(MaiorInt(Nums));
//
//   // Sem duplicatas
//   var Unicos := TArrayHelper<Integer>.Unico(Nums); // [3,1,4,5,9,2,6]
// ---------------------------------------------------------------------------

end.
