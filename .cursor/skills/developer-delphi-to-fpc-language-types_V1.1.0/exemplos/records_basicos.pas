unit records_basicos;
{
  EXEMPLO: Records em Delphi — Value Objects com metodos
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Record com campos e metodos de instancia
    - class function (factory/constructor semantics)
    - class operator (overloading de operadores em record)
    - Record passado por valor vs por referencia (const/var)
    - Comparacao de records
    - Record como DTO (Data Transfer Object)
}

interface

uses
  System.SysUtils, System.Math;

// ---------------------------------------------------------------------------
// TPoint2D: record geometrico com metodos
// ---------------------------------------------------------------------------
type
  TPoint2D = record
  private
    FX, FY: Single;
  public
    // Factory method — equivalente ao constructor
    class function Create(AX, AY: Single): TPoint2D; static;

    // Metodos de instancia
    function Distance(const Other: TPoint2D): Single;
    function Normalize: TPoint2D;
    function ToString: string;

    // Operadores sobrecarregados
    class operator Add(const A, B: TPoint2D): TPoint2D;
    class operator Subtract(const A, B: TPoint2D): TPoint2D;
    class operator Equal(const A, B: TPoint2D): Boolean;
    class operator Multiply(const P: TPoint2D; Scalar: Single): TPoint2D;

    // Constantes de record
    class function Zero: TPoint2D; static;
    class function One : TPoint2D; static;

    property X: Single read FX write FX;
    property Y: Single read FY write FY;
  end;

// ---------------------------------------------------------------------------
// TRGB: record para cor com validacao
// ---------------------------------------------------------------------------
type
  TRGB = record
    R, G, B: Byte; // 0..255 cada canal
    class function FromHex(const AHex: string): TRGB; static;
    function ToHex: string;
    function Blend(const Other: TRGB; Alpha: Single): TRGB;
  end;

// ---------------------------------------------------------------------------
// TPessoa: DTO como record (imutavel por convencao)
// ---------------------------------------------------------------------------
type
  TPessoa = record
    Nome : string;
    Idade: Integer;
    CPF  : string;
    class function Novo(const ANome: string; AIdade: Integer;
      const ACPF: string): TPessoa; static;
    function EhValido: Boolean;
  end;

implementation

// ---------------------------------------------------------------------------
// TPoint2D
// ---------------------------------------------------------------------------

class function TPoint2D.Create(AX, AY: Single): TPoint2D;
begin
  Result.FX := AX;
  Result.FY := AY;
end;

class function TPoint2D.Zero: TPoint2D;
begin
  Result := TPoint2D.Create(0, 0);
end;

class function TPoint2D.One: TPoint2D;
begin
  Result := TPoint2D.Create(1, 1);
end;

function TPoint2D.Distance(const Other: TPoint2D): Single;
begin
  Result := Sqrt(Sqr(FX - Other.FX) + Sqr(FY - Other.FY));
end;

function TPoint2D.Normalize: TPoint2D;
var
  Len: Single;
begin
  Len := Sqrt(FX * FX + FY * FY);
  if IsZero(Len) then
    Result := TPoint2D.Zero
  else
    Result := TPoint2D.Create(FX / Len, FY / Len);
end;

function TPoint2D.ToString: string;
begin
  Result := Format('(%.2f, %.2f)', [FX, FY]);
end;

class operator TPoint2D.Add(const A, B: TPoint2D): TPoint2D;
begin
  Result := TPoint2D.Create(A.FX + B.FX, A.FY + B.FY);
end;

class operator TPoint2D.Subtract(const A, B: TPoint2D): TPoint2D;
begin
  Result := TPoint2D.Create(A.FX - B.FX, A.FY - B.FY);
end;

class operator TPoint2D.Equal(const A, B: TPoint2D): Boolean;
begin
  Result := SameValue(A.FX, B.FX, 1e-6) and SameValue(A.FY, B.FY, 1e-6);
end;

class operator TPoint2D.Multiply(const P: TPoint2D; Scalar: Single): TPoint2D;
begin
  Result := TPoint2D.Create(P.FX * Scalar, P.FY * Scalar);
end;

// ---------------------------------------------------------------------------
// TRGB
// ---------------------------------------------------------------------------

class function TRGB.FromHex(const AHex: string): TRGB;
var
  H: string;
  V: Int64;
begin
  H := AHex.TrimLeft(['#']);
  if Length(H) = 6 then
    H := 'FF' + H; // adicionar alpha
  V := StrToInt64('$' + H);
  Result.R := (V shr 16) and $FF;
  Result.G := (V shr 8)  and $FF;
  Result.B :=  V          and $FF;
end;

function TRGB.ToHex: string;
begin
  Result := Format('#%2.2X%2.2X%2.2X', [R, G, B]);
end;

function TRGB.Blend(const Other: TRGB; Alpha: Single): TRGB;
begin
  // Linear interpolation
  Result.R := Round(R * (1 - Alpha) + Other.R * Alpha);
  Result.G := Round(G * (1 - Alpha) + Other.G * Alpha);
  Result.B := Round(B * (1 - Alpha) + Other.B * Alpha);
end;

// ---------------------------------------------------------------------------
// TPessoa
// ---------------------------------------------------------------------------

class function TPessoa.Novo(const ANome: string; AIdade: Integer;
  const ACPF: string): TPessoa;
begin
  Result.Nome  := ANome;
  Result.Idade := AIdade;
  Result.CPF   := ACPF;
end;

function TPessoa.EhValido: Boolean;
begin
  Result := (not Nome.IsEmpty) and (Idade >= 0) and (Idade <= 130);
end;

// ---------------------------------------------------------------------------
// Demonstracao de uso
// ---------------------------------------------------------------------------
procedure TestarRecords;
var
  P1, P2, P3: TPoint2D;
  Cor       : TRGB;
  Pessoa    : TPessoa;
begin
  // TPoint2D — operadores
  P1 := TPoint2D.Create(3, 4);
  P2 := TPoint2D.Create(1, 1);

  P3 := P1 + P2;     // Add operator
  P3 := P1 - P2;     // Subtract
  P3 := P1 * 2.0;    // Multiply scalar

  Writeln(P1.Distance(P2):6:2);  // distancia euclidiana
  Writeln(P1 = P2);              // False
  Writeln(P1.Normalize.ToString); // vetor normalizado

  // TRGB
  Cor := TRGB.FromHex('#3498DB');
  Writeln(Cor.ToHex); // #3498DB

  // TPessoa — record como DTO
  Pessoa := TPessoa.Novo('Maria', 30, '123.456.789-00');
  if Pessoa.EhValido then
    Writeln('Pessoa valida: ', Pessoa.Nome);

  // Records sao copiados por VALOR
  var Copia := Pessoa;
  Copia.Nome := 'Joao';          // nao afeta Pessoa
  Writeln(Pessoa.Nome);          // ainda 'Maria'

  // Para evitar copia em parametros de funcao: usar const
  // procedure Process(const P: TPessoa); — sem copia, sem modificacao
  // procedure Modify(var P: TPessoa);   — sem copia, com modificacao
end;

end.
