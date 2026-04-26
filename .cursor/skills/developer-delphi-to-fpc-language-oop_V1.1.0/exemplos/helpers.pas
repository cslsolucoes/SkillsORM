unit helpers;
{
  EXEMPLO: Class helpers e Record helpers em Delphi
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Class helper for string (estender sem herdar)
    - Class helper for TObject
    - Record helper for Integer
    - Limitacoes: so um helper ativo por tipo por escopo
    - Uso de helpers para adicionar metodos a tipos do RTL
}

interface

uses
  System.SysUtils, System.StrUtils, System.Math;

// ---------------------------------------------------------------------------
// Helper para string — adiciona metodos ao tipo string nativo
// ---------------------------------------------------------------------------
type
  TStringHelper = class helper for string
  public
    function Capitalize: string;
    function IsEmail: Boolean;
    function IsCpf: Boolean;
    function TruncateTo(AMaxLen: Integer; const ASufixo: string = '...'): string;
    function CountOccurrences(const ASubStr: string): Integer;
    function RemoveAccents: string;
    function OnlyDigits: string;
    function PadZero(AWidth: Integer): string;
  end;

// ---------------------------------------------------------------------------
// Helper para Integer
// ---------------------------------------------------------------------------
type
  TIntegerHelper = record helper for Integer
  public
    function ToString: string;
    function ToByte: Byte;
    function InRange(AMin, AMax: Integer): Boolean;
    function Clamp(AMin, AMax: Integer): Integer;
    function IsBetween(AMin, AMax: Integer): Boolean;
    function Abs: Integer;
  end;

// ---------------------------------------------------------------------------
// Helper para TObject — adicionar metodos a todas as classes
// ---------------------------------------------------------------------------
type
  TObjectHelper = class helper for TObject
  public
    function ClassName: string;
    function IsAssigned: Boolean;
  end;

implementation

// ---------------------------------------------------------------------------
// TStringHelper
// ---------------------------------------------------------------------------

function TStringHelper.Capitalize: string;
var
  I: Integer;
  Parts: TArray<string>;
begin
  if Self.IsEmpty then Exit('');
  Parts := Self.Split([' ']);
  for I := 0 to High(Parts) do
    if not Parts[I].IsEmpty then
      Parts[I] := UpperCase(Parts[I][1]) + LowerCase(Copy(Parts[I], 2, MaxInt));
  Result := String.Join(' ', Parts);
end;

function TStringHelper.IsEmail: Boolean;
var
  AtPos: Integer;
begin
  AtPos := Pos('@', Self);
  Result := (AtPos > 1) and
            (AtPos < Length(Self)) and
            (Pos('.', Copy(Self, AtPos, MaxInt)) > 1);
end;

function TStringHelper.IsCpf: Boolean;
var
  Digits: string;
  I, Sum, Rest: Integer;
begin
  Digits := OnlyDigits;
  Result := False;

  if Length(Digits) <> 11 then Exit;

  // Verificar se todos os digitos sao iguais (111.111.111-11 e invalido)
  if Digits = StringOfChar(Digits[1], 11) then Exit;

  // Verificar digitos verificadores
  Sum := 0;
  for I := 1 to 9 do
    Sum := Sum + StrToInt(Digits[I]) * (11 - I);
  Rest := Sum mod 11;
  if Rest < 2 then Rest := 0 else Rest := 11 - Rest;
  if Rest <> StrToInt(Digits[10]) then Exit;

  Sum := 0;
  for I := 1 to 10 do
    Sum := Sum + StrToInt(Digits[I]) * (12 - I);
  Rest := Sum mod 11;
  if Rest < 2 then Rest := 0 else Rest := 11 - Rest;

  Result := Rest = StrToInt(Digits[11]);
end;

function TStringHelper.TruncateTo(AMaxLen: Integer;
  const ASufixo: string): string;
begin
  if Length(Self) <= AMaxLen then
    Result := Self
  else
    Result := Copy(Self, 1, AMaxLen - Length(ASufixo)) + ASufixo;
end;

function TStringHelper.CountOccurrences(const ASubStr: string): Integer;
var
  Offset: Integer;
begin
  Result := 0;
  Offset := 1;
  while Offset <= Length(Self) do
  begin
    Offset := PosEx(ASubStr, Self, Offset);
    if Offset = 0 then Break;
    Inc(Result);
    Inc(Offset, Length(ASubStr));
  end;
end;

function TStringHelper.RemoveAccents: string;
const
  WithAccent   = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñ';
  WithoutAccent = 'AAAAAAaaaaaaeeeeeeeeiiiiiiiioooooooooooouuuuuuuuccnn';
var
  I, J: Integer;
begin
  Result := Self;
  for I := 1 to Length(Result) do
  begin
    J := Pos(Result[I], WithAccent);
    if J > 0 then
      Result[I] := WithoutAccent[J];
  end;
end;

function TStringHelper.OnlyDigits: string;
var
  C: Char;
begin
  Result := '';
  for C in Self do
    if C.IsDigit then
      Result := Result + C;
end;

function TStringHelper.PadZero(AWidth: Integer): string;
begin
  Result := Self.PadLeft(AWidth, '0');
end;

// ---------------------------------------------------------------------------
// TIntegerHelper
// ---------------------------------------------------------------------------

function TIntegerHelper.ToString: string;
begin
  Result := IntToStr(Self);
end;

function TIntegerHelper.ToByte: Byte;
begin
  Result := Byte(Self and $FF);
end;

function TIntegerHelper.InRange(AMin, AMax: Integer): Boolean;
begin
  Result := (Self >= AMin) and (Self <= AMax);
end;

function TIntegerHelper.Clamp(AMin, AMax: Integer): Integer;
begin
  Result := System.Math.Max(AMin, System.Math.Min(AMax, Self));
end;

function TIntegerHelper.IsBetween(AMin, AMax: Integer): Boolean;
begin
  Result := (Self > AMin) and (Self < AMax); // exclusivo, diferente de InRange
end;

function TIntegerHelper.Abs: Integer;
begin
  Result := System.Abs(Self);
end;

// ---------------------------------------------------------------------------
// TObjectHelper
// ---------------------------------------------------------------------------

function TObjectHelper.ClassName: string;
begin
  Result := Self.ClassType.ClassName;
end;

function TObjectHelper.IsAssigned: Boolean;
begin
  Result := Self <> nil;
end;

// ---------------------------------------------------------------------------
// Demonstracao de uso
// ---------------------------------------------------------------------------
procedure DemonstrarHelpers;
var
  S: string;
  N: Integer;
begin
  // TStringHelper
  S := 'joao da silva';
  Writeln(S.Capitalize);       // 'Joao Da Silva'

  S := 'usuario@email.com';
  Writeln(S.IsEmail);          // True

  S := '111.444.777-35';
  Writeln(S.IsCpf);            // True (CPF valido)

  S := 'Texto muito longo que precisa ser truncado';
  Writeln(S.TruncateTo(20));   // 'Texto muito longo...'

  S := 'a,b,a,c,a';
  Writeln(S.CountOccurrences('a')); // 3

  S := '42';
  Writeln(S.PadZero(6));       // '000042'

  // TIntegerHelper
  N := 42;
  Writeln(N.InRange(1, 100));  // True
  Writeln(N.Clamp(0, 30));     // 30
  Writeln((-5).Abs);           // 5

  // Combinacao
  Writeln(42.ToString.PadZero(5)); // '00042'
end;

end.
