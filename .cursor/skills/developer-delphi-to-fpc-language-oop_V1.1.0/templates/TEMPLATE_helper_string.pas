unit TEMPLATE_helper_string;
{
  TEMPLATE: String helper com metodos utilitarios (Delphi)
  Uso: declare em uma unit de utilitarios e use em qualquer lugar.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.RegularExpressions;

type
  // Estende o tipo string nativo com metodos de utilidade
  TStringExtHelper = class helper for string
  public
    // --- Verificacoes ---
    function IsEmail: Boolean;
    function IsCpf: Boolean;
    function IsCnpj: Boolean;
    function IsCep: Boolean;
    function IsNumeric: Boolean;
    function IsDate: Boolean;

    // --- Limpeza ---
    function OnlyDigits: string;
    function OnlyLetters: string;
    function RemoveSpaces: string;
    function NormalizeSpaces: string;
    function RemoveAccents: string;

    // --- Formatacao ---
    function AsCpf: string;         // '11144477735' -> '111.444.777-35'
    function AsCnpj: string;        // '11222333000181' -> '11.222.333/0001-81'
    function AsCep: string;         // '01310100' -> '01310-100'
    function AsTelefone: Boolean;   // formatar telefone
    function Capitalize: string;
    function TruncateTo(AMax: Integer; const ASufixo: string = '...'): string;
    function PadZero(AWidth: Integer): string;
    function Quote: string;         // 'texto' -> '"texto"'
    function SingleQuote: string;   // 'texto' -> '''texto'''

    // --- Conversao segura ---
    function ToIntOr(ADefault: Integer = 0): Integer;
    function ToDoubleOr(ADefault: Double = 0): Double;
    function ToCurrencyOr(ADefault: Currency = 0): Currency;
    function ToBoolOr(ADefault: Boolean = False): Boolean;
  end;

implementation

function TStringExtHelper.IsEmail: Boolean;
begin
  Result := TRegEx.IsMatch(Self.Trim,
    '^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
end;

function TStringExtHelper.IsCpf: Boolean;
var
  D: string;
  I, S, R: Integer;
begin
  D := OnlyDigits;
  Result := False;
  if Length(D) <> 11 then Exit;
  if D = StringOfChar(D[1], 11) then Exit;

  S := 0;
  for I := 1 to 9 do S := S + StrToInt(D[I]) * (11 - I);
  R := S mod 11; if R < 2 then R := 0 else R := 11 - R;
  if R <> StrToInt(D[10]) then Exit;

  S := 0;
  for I := 1 to 10 do S := S + StrToInt(D[I]) * (12 - I);
  R := S mod 11; if R < 2 then R := 0 else R := 11 - R;
  Result := R = StrToInt(D[11]);
end;

function TStringExtHelper.IsCnpj: Boolean;
var
  D: string;
  I, S, R: Integer;
  Pesos1: array[0..11] of Integer;
  Pesos2: array[0..11] of Integer;
begin
  D := OnlyDigits;
  Result := False;
  if Length(D) <> 14 then Exit;
  if D = StringOfChar(D[1], 14) then Exit;

  Pesos1 := [5,4,3,2,9,8,7,6,5,4,3,2,0,0];
  Pesos2 := [6,5,4,3,2,9,8,7,6,5,4,3,2,0];

  S := 0;
  for I := 0 to 11 do S := S + StrToInt(D[I+1]) * Pesos1[I];
  R := S mod 11; if R < 2 then R := 0 else R := 11 - R;
  if R <> StrToInt(D[13]) then Exit;

  S := 0;
  for I := 0 to 12 do S := S + StrToInt(D[I+1]) * Pesos2[I];
  R := S mod 11; if R < 2 then R := 0 else R := 11 - R;
  Result := R = StrToInt(D[14]);
end;

function TStringExtHelper.IsCep: Boolean;
begin
  Result := Length(OnlyDigits) = 8;
end;

function TStringExtHelper.IsNumeric: Boolean;
var
  D: Double;
begin
  Result := TryStrToFloat(Self.Trim, D);
end;

function TStringExtHelper.IsDate: Boolean;
var
  D: TDateTime;
begin
  Result := TryStrToDate(Self.Trim, D);
end;

function TStringExtHelper.OnlyDigits: string;
var C: Char;
begin
  Result := '';
  for C in Self do
    if C.IsDigit then Result := Result + C;
end;

function TStringExtHelper.OnlyLetters: string;
var C: Char;
begin
  Result := '';
  for C in Self do
    if C.IsLetter then Result := Result + C;
end;

function TStringExtHelper.RemoveSpaces: string;
begin
  Result := Self.Replace(' ', '');
end;

function TStringExtHelper.NormalizeSpaces: string;
begin
  Result := TRegEx.Replace(Self.Trim, '\s+', ' ');
end;

function TStringExtHelper.RemoveAccents: string;
const
  ComAcento    = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÇçÑñ';
  SemAcento    = 'AAAAAAaaaaaaeeeeeeeeiiiiiiiioooooooooooouuuuuuuuccnn';
var
  I, J: Integer;
begin
  Result := Self;
  for I := 1 to Length(Result) do
  begin
    J := Pos(Result[I], ComAcento);
    if J > 0 then Result[I] := SemAcento[J];
  end;
end;

function TStringExtHelper.AsCpf: string;
var D: string;
begin
  D := OnlyDigits.PadZero(11);
  if Length(D) = 11 then
    Result := Format('%s.%s.%s-%s',
      [Copy(D,1,3), Copy(D,4,3), Copy(D,7,3), Copy(D,10,2)])
  else
    Result := Self;
end;

function TStringExtHelper.AsCnpj: string;
var D: string;
begin
  D := OnlyDigits.PadZero(14);
  if Length(D) = 14 then
    Result := Format('%s.%s.%s/%s-%s',
      [Copy(D,1,2),Copy(D,3,3),Copy(D,6,3),Copy(D,9,4),Copy(D,13,2)])
  else
    Result := Self;
end;

function TStringExtHelper.AsCep: string;
var D: string;
begin
  D := OnlyDigits.PadZero(8);
  if Length(D) = 8 then
    Result := Format('%s-%s', [Copy(D,1,5), Copy(D,6,3)])
  else
    Result := Self;
end;

function TStringExtHelper.AsTelefone: Boolean;
begin
  Result := Length(OnlyDigits) in [10, 11];
end;

function TStringExtHelper.Capitalize: string;
var Parts: TArray<string>; I: Integer;
begin
  if Self.IsEmpty then Exit('');
  Parts := Self.Split([' ']);
  for I := 0 to High(Parts) do
    if not Parts[I].IsEmpty then
      Parts[I] := UpperCase(Parts[I][1]) + LowerCase(Copy(Parts[I],2,MaxInt));
  Result := String.Join(' ', Parts);
end;

function TStringExtHelper.TruncateTo(AMax: Integer;
  const ASufixo: string): string;
begin
  if Length(Self) <= AMax then Result := Self
  else Result := Copy(Self, 1, AMax - Length(ASufixo)) + ASufixo;
end;

function TStringExtHelper.PadZero(AWidth: Integer): string;
begin
  Result := Self.PadLeft(AWidth, '0');
end;

function TStringExtHelper.Quote: string;
begin
  Result := '"' + Self.Replace('"', '\"') + '"';
end;

function TStringExtHelper.SingleQuote: string;
begin
  Result := '''' + Self.Replace('''', '''''') + '''';
end;

function TStringExtHelper.ToIntOr(ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Self.Trim, ADefault);
end;

function TStringExtHelper.ToDoubleOr(ADefault: Double): Double;
begin
  if not TryStrToFloat(Self.Trim, Result) then
    Result := ADefault;
end;

function TStringExtHelper.ToCurrencyOr(ADefault: Currency): Currency;
begin
  Result := StrToCurrDef(Self.Trim.Replace(',','.'), ADefault);
end;

function TStringExtHelper.ToBoolOr(ADefault: Boolean): Boolean;
var Lower: string;
begin
  Lower := Self.Trim.ToLower;
  if Lower.IsEmpty then Exit(ADefault);
  Result := (Lower = '1') or (Lower = 'true') or (Lower = 'sim') or
            (Lower = 's') or (Lower = 'yes') or (Lower = 'y');
end;

end.
