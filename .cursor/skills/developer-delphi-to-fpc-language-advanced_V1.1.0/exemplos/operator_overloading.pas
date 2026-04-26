unit operator_overloading;
{
  Operator overloading em Delphi — classes e records
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Operadores overloadáveis em Delphi
// Todos devem ser: class operator Add(...): T; (static — em records)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// TMoney — valor monetário imutável com operadores
// ---------------------------------------------------------------------------
type
  TMoney = record
  private
    FCentavos: Int64;  // armazenado em centavos para evitar float
    function GetValor: Double;
  public
    class function Create(AValor: Double): TMoney; static;
    class function Zero: TMoney; static;

    // Aritméticos
    class operator Add     (const A, B: TMoney): TMoney;
    class operator Subtract(const A, B: TMoney): TMoney;
    class operator Multiply(const A: TMoney; B: Double): TMoney;
    class operator Divide  (const A: TMoney; B: Double): TMoney;
    class operator Negative(const A: TMoney): TMoney;

    // Comparação
    class operator Equal          (const A, B: TMoney): Boolean;
    class operator NotEqual       (const A, B: TMoney): Boolean;
    class operator LessThan       (const A, B: TMoney): Boolean;
    class operator GreaterThan    (const A, B: TMoney): Boolean;
    class operator LessThanOrEqual(const A, B: TMoney): Boolean;
    class operator GreaterThanOrEqual(const A, B: TMoney): Boolean;

    // Conversão implícita/explícita
    class operator Implicit(AValor: Double): TMoney;
    class operator Explicit(const A: TMoney): Double;
    class operator Explicit(const A: TMoney): string;

    property Valor   : Double read GetValor;
    property Centavos: Int64  read FCentavos;
    function ToString: string;
  end;

// ---------------------------------------------------------------------------
// TFracao — fração racional com simplificação
// ---------------------------------------------------------------------------
type
  TFracao = record
  private
    FNum: Integer;
    FDen: Integer;
    class function MDC(A, B: Integer): Integer; static;
    procedure Simplificar;
  public
    class function Create(ANum, ADen: Integer): TFracao; static;

    class operator Add     (const A, B: TFracao): TFracao;
    class operator Subtract(const A, B: TFracao): TFracao;
    class operator Multiply(const A, B: TFracao): TFracao;
    class operator Divide  (const A, B: TFracao): TFracao;
    class operator Equal   (const A, B: TFracao): Boolean;
    class operator Implicit(AValor: Integer): TFracao;
    class operator Explicit(const A: TFracao): Double;
    class operator Explicit(const A: TFracao): string;

    function ToString: string;
  end;

implementation

// ---------------------------------------------------------------------------
// TMoney
// ---------------------------------------------------------------------------

class function TMoney.Create(AValor: Double): TMoney;
begin
  Result.FCentavos := Round(AValor * 100);
end;

class function TMoney.Zero: TMoney;
begin
  Result.FCentavos := 0;
end;

function TMoney.GetValor: Double;
begin
  Result := FCentavos / 100.0;
end;

function TMoney.ToString: string;
begin
  Result := Format('R$ %.2f', [Valor]);
end;

class operator TMoney.Add(const A, B: TMoney): TMoney;
begin Result.FCentavos := A.FCentavos + B.FCentavos; end;

class operator TMoney.Subtract(const A, B: TMoney): TMoney;
begin Result.FCentavos := A.FCentavos - B.FCentavos; end;

class operator TMoney.Multiply(const A: TMoney; B: Double): TMoney;
begin Result.FCentavos := Round(A.FCentavos * B); end;

class operator TMoney.Divide(const A: TMoney; B: Double): TMoney;
begin
  if B = 0 then raise EDivByZero.Create('Divisão por zero');
  Result.FCentavos := Round(A.FCentavos / B);
end;

class operator TMoney.Negative(const A: TMoney): TMoney;
begin Result.FCentavos := -A.FCentavos; end;

class operator TMoney.Equal(const A, B: TMoney): Boolean;
begin Result := A.FCentavos = B.FCentavos; end;

class operator TMoney.NotEqual(const A, B: TMoney): Boolean;
begin Result := A.FCentavos <> B.FCentavos; end;

class operator TMoney.LessThan(const A, B: TMoney): Boolean;
begin Result := A.FCentavos < B.FCentavos; end;

class operator TMoney.GreaterThan(const A, B: TMoney): Boolean;
begin Result := A.FCentavos > B.FCentavos; end;

class operator TMoney.LessThanOrEqual(const A, B: TMoney): Boolean;
begin Result := A.FCentavos <= B.FCentavos; end;

class operator TMoney.GreaterThanOrEqual(const A, B: TMoney): Boolean;
begin Result := A.FCentavos >= B.FCentavos; end;

class operator TMoney.Implicit(AValor: Double): TMoney;
begin Result := TMoney.Create(AValor); end;

class operator TMoney.Explicit(const A: TMoney): Double;
begin Result := A.Valor; end;

class operator TMoney.Explicit(const A: TMoney): string;
begin Result := A.ToString; end;

// ---------------------------------------------------------------------------
// TFracao
// ---------------------------------------------------------------------------

class function TFracao.MDC(A, B: Integer): Integer;
begin
  A := Abs(A); B := Abs(B);
  while B <> 0 do begin var T := B; B := A mod B; A := T; end;
  Result := A;
end;

procedure TFracao.Simplificar;
var M: Integer;
begin
  if FDen < 0 then begin FNum := -FNum; FDen := -FDen; end;
  M := MDC(Abs(FNum), FDen);
  if M > 1 then begin FNum := FNum div M; FDen := FDen div M; end;
end;

class function TFracao.Create(ANum, ADen: Integer): TFracao;
begin
  if ADen = 0 then raise EDivByZero.Create('Denominador zero');
  Result.FNum := ANum;
  Result.FDen := ADen;
  Result.Simplificar;
end;

function TFracao.ToString: string;
begin
  if FDen = 1 then Result := IntToStr(FNum)
  else             Result := Format('%d/%d', [FNum, FDen]);
end;

class operator TFracao.Add(const A, B: TFracao): TFracao;
begin Result := TFracao.Create(A.FNum*B.FDen + B.FNum*A.FDen, A.FDen*B.FDen); end;

class operator TFracao.Subtract(const A, B: TFracao): TFracao;
begin Result := TFracao.Create(A.FNum*B.FDen - B.FNum*A.FDen, A.FDen*B.FDen); end;

class operator TFracao.Multiply(const A, B: TFracao): TFracao;
begin Result := TFracao.Create(A.FNum*B.FNum, A.FDen*B.FDen); end;

class operator TFracao.Divide(const A, B: TFracao): TFracao;
begin Result := TFracao.Create(A.FNum*B.FDen, A.FDen*B.FNum); end;

class operator TFracao.Equal(const A, B: TFracao): Boolean;
begin Result := (A.FNum = B.FNum) and (A.FDen = B.FDen); end;

class operator TFracao.Implicit(AValor: Integer): TFracao;
begin Result := TFracao.Create(AValor, 1); end;

class operator TFracao.Explicit(const A: TFracao): Double;
begin Result := A.FNum / A.FDen; end;

class operator TFracao.Explicit(const A: TFracao): string;
begin Result := A.ToString; end;

// ---------------------------------------------------------------------------
// USO:
//   // TMoney
//   var Preco: TMoney := 10.50;          // Implicit(Double)
//   var Taxa: TMoney  := TMoney.Create(1.75);
//   var Total := Preco + Taxa;           // Add
//   Writeln(Total.ToString);             // R$ 12.25
//   Writeln(Total > TMoney.Create(10));  // True
//   var Dobro := Total * 2.0;            // Multiply
//   var ValD: Double := Dobro;           // Explicit
//
//   // TFracao
//   var A := TFracao.Create(1, 2);   // 1/2
//   var B := TFracao.Create(1, 3);   // 1/3
//   var C := A + B;                  // 5/6
//   Writeln(C.ToString);             // 5/6
//   var D := A * B;                  // 1/6
//   Writeln(string(D));              // 1/6 (Explicit(string))
//   Writeln(Double(A):0:4);          // 0.5000 (Explicit(Double))
// ---------------------------------------------------------------------------

end.
