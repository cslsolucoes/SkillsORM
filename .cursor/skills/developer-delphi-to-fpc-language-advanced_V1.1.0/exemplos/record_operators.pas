unit record_operators;
{
  Operators em records — TVector2, TRGBA, TDateRange
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Math;

// ---------------------------------------------------------------------------
// TVector2 — vetor 2D com operadores completos
// ---------------------------------------------------------------------------
type
  TVector2 = record
  public
    X, Y: Single;

    class function Create(AX, AY: Single): TVector2; static;
    class function Zero: TVector2; static;
    class function One: TVector2; static;
    class function Up: TVector2; static;    // (0, 1)
    class function Right: TVector2; static; // (1, 0)

    // Aritméticos vetor + vetor
    class operator Add     (const A, B: TVector2): TVector2;
    class operator Subtract(const A, B: TVector2): TVector2;
    class operator Negative(const A: TVector2): TVector2;

    // Aritméticos vetor * escalar
    class operator Multiply(const A: TVector2; B: Single): TVector2;
    class operator Multiply(B: Single; const A: TVector2): TVector2;
    class operator Divide  (const A: TVector2; B: Single): TVector2;

    // Comparação
    class operator Equal   (const A, B: TVector2): Boolean;
    class operator NotEqual(const A, B: TVector2): Boolean;

    // Conversão
    class operator Implicit(const A: TVector2): string;

    // Operações geométricas
    function Length: Single;
    function LengthSq: Single;
    function Normalized: TVector2;
    function Dot(const Other: TVector2): Single;
    function Distance(const Other: TVector2): Single;
    function Lerp(const Other: TVector2; T: Single): TVector2;
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// TRGBA — cor com canal alpha e operadores
// ---------------------------------------------------------------------------
type
  TRGBA = record
  public
    R, G, B, A: Byte;

    class function Create(AR, AG, AB: Byte; AA: Byte = 255): TRGBA; static;
    class function FromHex(const AHex: string): TRGBA; static;

    class operator Add(const A, B: TRGBA): TRGBA;  // blend aditivo clamp 255
    class operator Multiply(const A: TRGBA; B: Single): TRGBA; // escalar brightness
    class operator Equal(const A, B: TRGBA): Boolean;
    class operator Implicit(const A: TRGBA): string;  // '#RRGGBBAA'

    function ToHex: string;
    function WithAlpha(AAlpha: Byte): TRGBA;
    function Blend(const Other: TRGBA; T: Single): TRGBA;
  end;

const
  COLOR_BLACK   : TRGBA = (R:0;   G:0;   B:0;   A:255);
  COLOR_WHITE   : TRGBA = (R:255; G:255; B:255; A:255);
  COLOR_RED     : TRGBA = (R:255; G:0;   B:0;   A:255);
  COLOR_GREEN   : TRGBA = (R:0;   G:255; B:0;   A:255);
  COLOR_BLUE    : TRGBA = (R:0;   G:0;   B:255; A:255);
  COLOR_TRANSPARENT: TRGBA = (R:0; G:0; B:0; A:0);

implementation

// ---------------------------------------------------------------------------
// TVector2
// ---------------------------------------------------------------------------

class function TVector2.Create(AX, AY: Single): TVector2;
begin Result.X := AX; Result.Y := AY; end;

class function TVector2.Zero:  TVector2; begin Result := Create(0, 0); end;
class function TVector2.One:   TVector2; begin Result := Create(1, 1); end;
class function TVector2.Up:    TVector2; begin Result := Create(0, 1); end;
class function TVector2.Right: TVector2; begin Result := Create(1, 0); end;

class operator TVector2.Add(const A, B: TVector2): TVector2;
begin Result := Create(A.X+B.X, A.Y+B.Y); end;

class operator TVector2.Subtract(const A, B: TVector2): TVector2;
begin Result := Create(A.X-B.X, A.Y-B.Y); end;

class operator TVector2.Negative(const A: TVector2): TVector2;
begin Result := Create(-A.X, -A.Y); end;

class operator TVector2.Multiply(const A: TVector2; B: Single): TVector2;
begin Result := Create(A.X*B, A.Y*B); end;

class operator TVector2.Multiply(B: Single; const A: TVector2): TVector2;
begin Result := Create(A.X*B, A.Y*B); end;

class operator TVector2.Divide(const A: TVector2; B: Single): TVector2;
begin Result := Create(A.X/B, A.Y/B); end;

class operator TVector2.Equal(const A, B: TVector2): Boolean;
begin Result := SameValue(A.X, B.X) and SameValue(A.Y, B.Y); end;

class operator TVector2.NotEqual(const A, B: TVector2): Boolean;
begin Result := not (A = B); end;

class operator TVector2.Implicit(const A: TVector2): string;
begin Result := A.ToString; end;

function TVector2.Length: Single;
begin Result := Sqrt(X*X + Y*Y); end;

function TVector2.LengthSq: Single;
begin Result := X*X + Y*Y; end;

function TVector2.Normalized: TVector2;
var L: Single;
begin
  L := Length;
  if L > 0 then Result := Self / L
  else          Result := TVector2.Zero;
end;

function TVector2.Dot(const Other: TVector2): Single;
begin Result := X*Other.X + Y*Other.Y; end;

function TVector2.Distance(const Other: TVector2): Single;
begin Result := (Self - Other).Length; end;

function TVector2.Lerp(const Other: TVector2; T: Single): TVector2;
begin Result := Self + (Other - Self) * T; end;

function TVector2.ToString: string;
begin Result := Format('(%.3f, %.3f)', [X, Y]); end;

// ---------------------------------------------------------------------------
// TRGBA
// ---------------------------------------------------------------------------

class function TRGBA.Create(AR, AG, AB: Byte; AA: Byte): TRGBA;
begin Result.R := AR; Result.G := AG; Result.B := AB; Result.A := AA; end;

class function TRGBA.FromHex(const AHex: string): TRGBA;
var H: string;
begin
  H := AHex.TrimLeft(['#']);
  if Length(H) = 6 then H := H + 'FF';
  Result.R := StrToInt('$' + Copy(H,1,2));
  Result.G := StrToInt('$' + Copy(H,3,2));
  Result.B := StrToInt('$' + Copy(H,5,2));
  Result.A := StrToInt('$' + Copy(H,7,2));
end;

class operator TRGBA.Add(const A, B: TRGBA): TRGBA;
begin
  Result.R := Min(255, Integer(A.R) + Integer(B.R));
  Result.G := Min(255, Integer(A.G) + Integer(B.G));
  Result.B := Min(255, Integer(A.B) + Integer(B.B));
  Result.A := Min(255, Integer(A.A) + Integer(B.A));
end;

class operator TRGBA.Multiply(const A: TRGBA; B: Single): TRGBA;
begin
  Result.R := Min(255, Round(A.R * B));
  Result.G := Min(255, Round(A.G * B));
  Result.B := Min(255, Round(A.B * B));
  Result.A := A.A;
end;

class operator TRGBA.Equal(const A, B: TRGBA): Boolean;
begin
  Result := (A.R=B.R) and (A.G=B.G) and (A.B=B.B) and (A.A=B.A);
end;

class operator TRGBA.Implicit(const A: TRGBA): string;
begin Result := A.ToHex; end;

function TRGBA.ToHex: string;
begin Result := Format('#%0.2X%0.2X%0.2X%0.2X', [R, G, B, A]); end;

function TRGBA.WithAlpha(AAlpha: Byte): TRGBA;
begin Result := Create(R, G, B, AAlpha); end;

function TRGBA.Blend(const Other: TRGBA; T: Single): TRGBA;
begin
  Result.R := Round(R + (Other.R - R) * T);
  Result.G := Round(G + (Other.G - G) * T);
  Result.B := Round(B + (Other.B - B) * T);
  Result.A := Round(A + (Other.A - A) * T);
end;

// ---------------------------------------------------------------------------
// USO:
//   // TVector2
//   var V1 := TVector2.Create(3, 4);
//   var V2 := TVector2.Create(1, 0);
//   Writeln((V1 + V2).ToString);       // (4.000, 4.000)
//   Writeln(V1.Length:0:3);            // 5.000
//   Writeln(V1.Normalized.ToString);   // (0.600, 0.800)
//   Writeln(V1.Distance(V2):0:3);      // 4.243
//   var V3: string := V1;              // Implicit → '(3.000, 4.000)'
//   var Meio := V1.Lerp(V2, 0.5);      // ponto médio
//
//   // TRGBA
//   var Vermelho := COLOR_RED;
//   var Meio2 := Vermelho.Blend(COLOR_BLUE, 0.5);
//   Writeln(Meio2.ToHex);              // #7F007F (roxo)
//   var Escuro := Vermelho * 0.5;      // Multiply
//   Writeln(Escuro.ToHex);             // #7F0000
//   var Cor: string := COLOR_GREEN;    // Implicit → '#00FF00FF'
//   var CFromHex := TRGBA.FromHex('#FF8800');
// ---------------------------------------------------------------------------

end.
