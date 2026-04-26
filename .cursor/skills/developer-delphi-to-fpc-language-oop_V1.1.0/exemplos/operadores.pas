unit operadores;
{
  EXEMPLO: Operator overloading em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - class operator em records: Add, Subtract, Multiply, Equal, LessThan
    - class operator Implicit e Explicit (conversao automatica)
    - class operator Negative, Positive
    - Operador em Money (Currency semantics)
}

interface

uses
  System.SysUtils, System.Math;

// ---------------------------------------------------------------------------
// TVector2: operadores aritmeticos
// ---------------------------------------------------------------------------
type
  TVector2 = record
  public
    X, Y: Single;
    class function Create(AX, AY: Single): TVector2; static;

    // Aritmeticos
    class operator Add     (const A, B: TVector2): TVector2;
    class operator Subtract(const A, B: TVector2): TVector2;
    class operator Multiply(const V: TVector2; S: Single): TVector2;  // V * scalar
    class operator Multiply(S: Single; const V: TVector2): TVector2;  // scalar * V
    class operator Divide  (const V: TVector2; S: Single): TVector2;
    class operator Negative(const V: TVector2): TVector2; // unario -

    // Comparacao
    class operator Equal   (const A, B: TVector2): Boolean;
    class operator NotEqual(const A, B: TVector2): Boolean;

    // Conversao implicita / explicita
    class operator Implicit(const V: TVector2): string;  // TVector2 -> string automatico
    class operator Explicit(const S: string): TVector2;  // string -> TVector2 com cast

    // Utilitarios
    function Length: Single;
    function Normalize: TVector2;
    function Dot(const Other: TVector2): Single;
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// TMoney: semantica monetaria
// ---------------------------------------------------------------------------
type
  TMoeda = (mdBRL, mdUSD, mdEUR);

  TMoney = record
  private
    FValor: Currency;
    FMoeda: TMoeda;
  public
    class function Create(AValor: Currency; AMoeda: TMoeda = mdBRL): TMoney; static;

    class operator Add     (const A, B: TMoney): TMoney;
    class operator Subtract(const A, B: TMoney): TMoney;
    class operator Multiply(const M: TMoney; Factor: Double): TMoney;
    class operator Equal   (const A, B: TMoney): Boolean;
    class operator LessThan(const A, B: TMoney): Boolean;
    class operator GreaterThan(const A, B: TMoney): Boolean;

    class operator Implicit(const M: TMoney): string;

    property Valor: Currency read FValor;
    property Moeda: TMoeda   read FMoeda;
  end;

implementation

// ---------------------------------------------------------------------------
// TVector2
// ---------------------------------------------------------------------------

class function TVector2.Create(AX, AY: Single): TVector2;
begin
  Result.X := AX;
  Result.Y := AY;
end;

class operator TVector2.Add(const A, B: TVector2): TVector2;
begin
  Result := TVector2.Create(A.X + B.X, A.Y + B.Y);
end;

class operator TVector2.Subtract(const A, B: TVector2): TVector2;
begin
  Result := TVector2.Create(A.X - B.X, A.Y - B.Y);
end;

class operator TVector2.Multiply(const V: TVector2; S: Single): TVector2;
begin
  Result := TVector2.Create(V.X * S, V.Y * S);
end;

class operator TVector2.Multiply(S: Single; const V: TVector2): TVector2;
begin
  Result := TVector2.Create(V.X * S, V.Y * S);
end;

class operator TVector2.Divide(const V: TVector2; S: Single): TVector2;
begin
  if IsZero(S) then
    raise EDivByZero.Create('Divisao por zero em TVector2');
  Result := TVector2.Create(V.X / S, V.Y / S);
end;

class operator TVector2.Negative(const V: TVector2): TVector2;
begin
  Result := TVector2.Create(-V.X, -V.Y);
end;

class operator TVector2.Equal(const A, B: TVector2): Boolean;
begin
  Result := SameValue(A.X, B.X, 1e-6) and SameValue(A.Y, B.Y, 1e-6);
end;

class operator TVector2.NotEqual(const A, B: TVector2): Boolean;
begin
  Result := not (A = B);
end;

class operator TVector2.Implicit(const V: TVector2): string;
begin
  Result := Format('(%.3f, %.3f)', [V.X, V.Y]);
end;

class operator TVector2.Explicit(const S: string): TVector2;
var
  Parts: TArray<string>;
  Clean: string;
begin
  // Parsear formato '(X, Y)'
  Clean := S.Trim(['(', ')', ' ']);
  Parts := Clean.Split([',']);
  if Length(Parts) < 2 then
    raise Exception.CreateFmt('Formato invalido para TVector2: %s', [S]);
  Result := TVector2.Create(
    StrToFloatDef(Parts[0].Trim, 0),
    StrToFloatDef(Parts[1].Trim, 0));
end;

function TVector2.Length: Single;
begin
  Result := Sqrt(X * X + Y * Y);
end;

function TVector2.Normalize: TVector2;
var
  Len: Single;
begin
  Len := Length;
  if IsZero(Len) then
    Result := TVector2.Create(0, 0)
  else
    Result := Self / Len;
end;

function TVector2.Dot(const Other: TVector2): Single;
begin
  Result := X * Other.X + Y * Other.Y;
end;

function TVector2.ToString: string;
begin
  Result := Self; // usa operator Implicit
end;

// ---------------------------------------------------------------------------
// TMoney
// ---------------------------------------------------------------------------

class function TMoney.Create(AValor: Currency; AMoeda: TMoeda): TMoney;
begin
  Result.FValor := AValor;
  Result.FMoeda := AMoeda;
end;

class operator TMoney.Add(const A, B: TMoney): TMoney;
begin
  if A.FMoeda <> B.FMoeda then
    raise Exception.Create('Nao e possivel somar moedas diferentes');
  Result := TMoney.Create(A.FValor + B.FValor, A.FMoeda);
end;

class operator TMoney.Subtract(const A, B: TMoney): TMoney;
begin
  if A.FMoeda <> B.FMoeda then
    raise Exception.Create('Nao e possivel subtrair moedas diferentes');
  Result := TMoney.Create(A.FValor - B.FValor, A.FMoeda);
end;

class operator TMoney.Multiply(const M: TMoney; Factor: Double): TMoney;
begin
  Result := TMoney.Create(M.FValor * Factor, M.FMoeda);
end;

class operator TMoney.Equal(const A, B: TMoney): Boolean;
begin
  Result := (A.FMoeda = B.FMoeda) and (A.FValor = B.FValor);
end;

class operator TMoney.LessThan(const A, B: TMoney): Boolean;
begin
  if A.FMoeda <> B.FMoeda then
    raise Exception.Create('Comparacao entre moedas diferentes');
  Result := A.FValor < B.FValor;
end;

class operator TMoney.GreaterThan(const A, B: TMoney): Boolean;
begin
  if A.FMoeda <> B.FMoeda then
    raise Exception.Create('Comparacao entre moedas diferentes');
  Result := A.FValor > B.FValor;
end;

class operator TMoney.Implicit(const M: TMoney): string;
const
  Simbolos: array[TMoeda] of string = ('R$', 'US$', '€');
begin
  Result := Format('%s %s', [Simbolos[M.FMoeda], FormatCurr('#,##0.00', M.FValor)]);
end;

// ---------------------------------------------------------------------------
// USO:
//   var V1 := TVector2.Create(3, 4);
//   var V2 := TVector2.Create(1, 2);
//   var V3 := V1 + V2;         // Add operator
//   var V4 := V1 * 2.0;        // Multiply operator
//   Writeln(V1.ToString);      // '(3.000, 4.000)' via Implicit
//   Writeln(string(V1));       // mesmo que acima
//
//   var P  := TMoney.Create(100.00);
//   var D  := TMoney.Create(15.00);
//   var T  := P + D;            // Add operator: R$ 115.00
//   var C  := P * 0.9;          // Multiply: R$ 90.00 (10% desconto)
//   Writeln(string(T));         // 'R$ 115.00' via Implicit
// ---------------------------------------------------------------------------

end.
