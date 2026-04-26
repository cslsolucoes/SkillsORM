unit TEMPLATE_string_format;
{
  TEMPLATE: Formatação de CPF/CNPJ, moeda, telefone, datas
  Funções puras — sem dependência de framework.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.RegularExpressions;

// ---------------------------------------------------------------------------
// Formatação de documentos brasileiros
// ---------------------------------------------------------------------------

// CPF: '12345678909' → '123.456.789-09'
function FormatarCPF(const ACPF: string): string;

// CPF limpo (só dígitos) de qualquer entrada
function LimparCPF(const ACPF: string): string;

// Validar CPF (dígitos verificadores)
function ValidarCPF(const ACPF: string): Boolean;

// CNPJ: '12345678000195' → '12.345.678/0001-95'
function FormatarCNPJ(const ACNPJ: string): string;

// Validar CNPJ
function ValidarCNPJ(const ACNPJ: string): Boolean;

// ---------------------------------------------------------------------------
// Formatação de telefone
// ---------------------------------------------------------------------------

// '11987654321' → '(11) 98765-4321'
// '1132498765'  → '(11) 3249-8765'
function FormatarTelefone(const ATel: string): string;

// Limpar só dígitos
function LimparTelefone(const ATel: string): string;

// ---------------------------------------------------------------------------
// Formatação monetária
// ---------------------------------------------------------------------------

// Currency → 'R$ 1.234,56'
function FormatarMoeda(AValor: Currency;
  const ASimbolo: string = 'R$'): string;

// Currency → '1.234,56' (sem símbolo)
function FormatarDecimalBR(AValor: Currency; ACasas: Integer = 2): string;

// String BR '1.234,56' → Currency (parse locale-safe)
function ParseDecimalBR(const S: string): Currency;

// ---------------------------------------------------------------------------
// Formatação de datas
// ---------------------------------------------------------------------------

// TDateTime → 'dd/mm/yyyy'
function DataBR(D: TDateTime): string;

// TDateTime → 'dd/mm/yyyy hh:nn:ss'
function DataHoraBR(D: TDateTime): string;

// TDateTime → 'yyyy-mm-dd' (ISO 8601)
function DataISO(D: TDateTime): string;

// TDateTime → 'yyyy-mm-ddThh:nn:ss' (ISO 8601 com hora)
function DataHoraISO(D: TDateTime): string;

// String 'dd/mm/yyyy' → TDateTime
function ParseDataBR(const S: string): TDateTime;

// String 'yyyy-mm-dd' → TDateTime
function ParseDataISO(const S: string): TDateTime;

// Tempo relativo: '2 horas atrás', 'há 3 dias'
function TempoRelativo(D: TDateTime): string;

// ---------------------------------------------------------------------------
// CEP
// ---------------------------------------------------------------------------
function FormatarCEP(const ACEP: string): string;  // '01310100' → '01310-100'

implementation

// ---------------------------------------------------------------------------
// Internos
// ---------------------------------------------------------------------------

function ApenasDigitos(const S: string): string;
begin
  Result := TRegEx.Replace(S, '[^0-9]', '');
end;

// ---------------------------------------------------------------------------
// CPF
// ---------------------------------------------------------------------------

function LimparCPF(const ACPF: string): string;
begin Result := ApenasDigitos(ACPF); end;

function FormatarCPF(const ACPF: string): string;
var D: string;
begin
  D := ApenasDigitos(ACPF);
  if D.Length <> 11 then begin Result := ACPF; Exit; end;
  Result := Format('%s.%s.%s-%s', [
    D.Substring(0, 3),
    D.Substring(3, 3),
    D.Substring(6, 3),
    D.Substring(9, 2)
  ]);
end;

function ValidarCPF(const ACPF: string): Boolean;
var D:   string;
    I, S1, S2, R: Integer;
begin
  D := ApenasDigitos(ACPF);
  Result := False;
  if D.Length <> 11 then Exit;
  // CPFs com todos os dígitos iguais são inválidos
  if TRegEx.IsMatch(D, '^(\d)\1{10}$') then Exit;

  // Primeiro dígito verificador
  S1 := 0;
  for I := 1 to 9 do S1 := S1 + StrToInt(D[I]) * (11 - I);
  R := S1 mod 11;
  if R < 2 then R := 0 else R := 11 - R;
  if R <> StrToInt(D[10]) then Exit;

  // Segundo dígito verificador
  S2 := 0;
  for I := 1 to 10 do S2 := S2 + StrToInt(D[I]) * (12 - I);
  R := S2 mod 11;
  if R < 2 then R := 0 else R := 11 - R;
  Result := R = StrToInt(D[11]);
end;

// ---------------------------------------------------------------------------
// CNPJ
// ---------------------------------------------------------------------------

function FormatarCNPJ(const ACNPJ: string): string;
var D: string;
begin
  D := ApenasDigitos(ACNPJ);
  if D.Length <> 14 then begin Result := ACNPJ; Exit; end;
  Result := Format('%s.%s.%s/%s-%s', [
    D.Substring(0, 2),
    D.Substring(2, 3),
    D.Substring(5, 3),
    D.Substring(8, 4),
    D.Substring(12, 2)
  ]);
end;

function ValidarCNPJ(const ACNPJ: string): Boolean;
const Pesos1: array[0..11] of Integer = (5,4,3,2,9,8,7,6,5,4,3,2);
      Pesos2: array[0..12] of Integer = (6,5,4,3,2,9,8,7,6,5,4,3,2);
var D: string;
    I, S, R: Integer;
begin
  D := ApenasDigitos(ACNPJ);
  Result := False;
  if D.Length <> 14 then Exit;
  if TRegEx.IsMatch(D, '^(\d)\1{13}$') then Exit;

  S := 0;
  for I := 0 to 11 do S := S + StrToInt(D[I+1]) * Pesos1[I];
  R := S mod 11;
  if R < 2 then R := 0 else R := 11 - R;
  if R <> StrToInt(D[13]) then Exit;

  S := 0;
  for I := 0 to 12 do S := S + StrToInt(D[I+1]) * Pesos2[I];
  R := S mod 11;
  if R < 2 then R := 0 else R := 11 - R;
  Result := R = StrToInt(D[14]);
end;

// ---------------------------------------------------------------------------
// Telefone
// ---------------------------------------------------------------------------

function LimparTelefone(const ATel: string): string;
begin Result := ApenasDigitos(ATel); end;

function FormatarTelefone(const ATel: string): string;
var D: string;
begin
  D := ApenasDigitos(ATel);
  case D.Length of
    10: Result := Format('(%s) %s-%s', [D.Substring(0,2), D.Substring(2,4), D.Substring(6,4)]);
    11: Result := Format('(%s) %s-%s', [D.Substring(0,2), D.Substring(2,5), D.Substring(7,4)]);
  else  Result := D;
  end;
end;

// ---------------------------------------------------------------------------
// Moeda
// ---------------------------------------------------------------------------

function FormatarMoeda(AValor: Currency; const ASimbolo: string): string;
var FSBR := TFormatSettings.Create('pt-BR');
begin
  if ASimbolo <> '' then
    Result := ASimbolo + ' ' + FloatToStrF(AValor, ffNumber, 15, 2, FSBR)
  else
    Result := FloatToStrF(AValor, ffNumber, 15, 2, FSBR);
end;

function FormatarDecimalBR(AValor: Currency; ACasas: Integer): string;
var FSBR := TFormatSettings.Create('pt-BR');
begin
  Result := FloatToStrF(AValor, ffNumber, 15, ACasas, FSBR);
end;

function ParseDecimalBR(const S: string): Currency;
var FSBR := TFormatSettings.Create('pt-BR');
    F: Double;
begin
  // Remove símbolo de moeda se presente
  var Limpo := S.Trim.Replace('R$', '').Replace('R$', '').Trim;
  if TryStrToFloat(Limpo, F, FSBR) then
    Result := F
  else
    raise EConvertError.CreateFmt('Valor inválido: "%s"', [S]);
end;

// ---------------------------------------------------------------------------
// Datas
// ---------------------------------------------------------------------------

function DataBR(D: TDateTime): string;
begin Result := FormatDateTime('dd/mm/yyyy', D); end;

function DataHoraBR(D: TDateTime): string;
begin Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', D); end;

function DataISO(D: TDateTime): string;
begin Result := FormatDateTime('yyyy-mm-dd', D); end;

function DataHoraISO(D: TDateTime): string;
begin Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', D); end;

function ParseDataBR(const S: string): TDateTime;
var FSBR := TFormatSettings.Create('pt-BR');
begin
  Result := StrToDateTime(S, FSBR);
end;

function ParseDataISO(const S: string): TDateTime;
var FSIso: TFormatSettings;
begin
  FSIso := TFormatSettings.Invariant;
  FSIso.ShortDateFormat := 'yyyy-mm-dd';
  FSIso.DateSeparator   := '-';
  Result := StrToDate(S, FSIso);
end;

function TempoRelativo(D: TDateTime): string;
var DiffSecs: Int64;
begin
  DiffSecs := SecondsBetween(Now, D);
  if DiffSecs < 60 then
    Result := 'agora'
  else if DiffSecs < 3600 then
    Result := Format('há %d minuto%s', [DiffSecs div 60, IfThen(DiffSecs div 60 > 1, 's', '')])
  else if DiffSecs < 86400 then
    Result := Format('há %d hora%s', [DiffSecs div 3600, IfThen(DiffSecs div 3600 > 1, 's', '')])
  else if DiffSecs < 2592000 then
    Result := Format('há %d dia%s', [DiffSecs div 86400, IfThen(DiffSecs div 86400 > 1, 's', '')])
  else if DiffSecs < 31536000 then
    Result := Format('há %d mê%s', [DiffSecs div 2592000, IfThen(DiffSecs div 2592000 > 1, 'ses', 's')])
  else
    Result := Format('há %d ano%s', [DiffSecs div 31536000, IfThen(DiffSecs div 31536000 > 1, 's', '')]);
end;

// ---------------------------------------------------------------------------
// CEP
// ---------------------------------------------------------------------------

function FormatarCEP(const ACEP: string): string;
var D: string;
begin
  D := ApenasDigitos(ACEP);
  if D.Length <> 8 then begin Result := ACEP; Exit; end;
  Result := D.Substring(0, 5) + '-' + D.Substring(5, 3);
end;

end.
