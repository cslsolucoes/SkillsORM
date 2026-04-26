unit string_conversion;
{
  Conversões String ↔ Integer/Float/DateTime/Boolean/Currency
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

procedure DemoConversaoInteiro;
procedure DemoConversaoFloat;
procedure DemoConversaoData;
procedure DemoConversaoBooleano;
procedure DemoConversaoHex;
procedure DemoFormatSettings;

implementation

// ---------------------------------------------------------------------------
// DemoConversaoInteiro — StrToInt, TryStrToInt, IntToStr, StrToInt64
// ---------------------------------------------------------------------------

procedure DemoConversaoInteiro;
var N: Integer;
    N64: Int64;
begin
  // Básico
  N := StrToInt('42');
  Writeln('StrToInt: ', N);

  // StrToIntDef — retorna default se falhar (sem raise)
  N := StrToIntDef('xyz', -1);
  Writeln('StrToIntDef falhou: ', N);  // -1

  // TryStrToInt — retorna Boolean
  if TryStrToInt('100', N) then
    Writeln('TryStrToInt OK: ', N)
  else
    Writeln('TryStrToInt falhou');

  if not TryStrToInt('abc', N) then
    Writeln('TryStrToInt "abc": falhou como esperado');

  // IntToStr
  Writeln('IntToStr: ', IntToStr(255));

  // Int64
  N64 := StrToInt64('9876543210');
  Writeln('StrToInt64: ', N64);
  Writeln('IntToStr(Int64): ', IntToStr(N64));

  // Hexadecimal → Integer (prefixo $)
  N := StrToInt('$FF');
  Writeln('$FF = ', N);  // 255

  N := StrToInt('$1A3F');
  Writeln('$1A3F = ', N);  // 6719

  // Integer → Hex
  Writeln('IntToHex(255,4): ', IntToHex(255, 4));   // '00FF'
  Writeln('IntToHex(255,2): ', IntToHex(255, 2));   // 'FF'
end;

// ---------------------------------------------------------------------------
// DemoConversaoFloat — StrToFloat, TryStrToFloat, FloatToStr, locale
// ---------------------------------------------------------------------------

procedure DemoConversaoFloat;
var F:  Double;
    FS: TFormatSettings;
begin
  // ATENÇÃO: StrToFloat é LOCALE-DEPENDENTE
  // Em pt-BR: separador decimal = ','
  // Em en-US: separador decimal = '.'
  // Isso causa bugs se o código roda em ambiente com locale diferente!

  // Locale-safe: usar TFormatSettings
  FS := TFormatSettings.Invariant;  // ponto como decimal, sem milhar
  F := StrToFloat('3.14', FS);
  Writeln('StrToFloat("3.14", Invariant): ', F:0:2);

  // Com locale pt-BR explícito
  var FSBR := TFormatSettings.Create('pt-BR');
  F := StrToFloat('3,14', FSBR);
  Writeln('StrToFloat("3,14", pt-BR): ', F:0:2);

  // TryStrToFloat — seguro
  if TryStrToFloat('1.234,56', F, FSBR) then
    Writeln('TryStrToFloat pt-BR: ', F:0:2)
  else
    Writeln('TryStrToFloat falhou');

  // StrToFloatDef
  F := StrToFloatDef('xyz', 0.0, FS);
  Writeln('StrToFloatDef falhou: ', F:0:2);  // 0.00

  // FloatToStr (locale-dependente)
  Writeln('FloatToStr: ', FloatToStr(3.14));

  // FloatToStr locale-safe
  Writeln('FloatToStr Invariant: ', FloatToStr(3.14, FS));  // '3.14'

  // Precisão controlada
  Writeln('FloatToStrF Fixed: ', FloatToStrF(1234.5678, ffFixed, 10, 2, FS));   // '1234.57'
  Writeln('FloatToStrF Number: ', FloatToStrF(1234.5678, ffNumber, 10, 2, FSBR)); // '1.234,57'

  // Currency
  var C: Currency := 1234.56;
  Writeln('CurrToStr: ', CurrToStr(C));
  Writeln('CurrToStrF: ', CurrToStrF(C, ffFixed, 2));
end;

// ---------------------------------------------------------------------------
// DemoConversaoData — StrToDate, StrToDateTime, DateTimeToStr
// ---------------------------------------------------------------------------

procedure DemoConversaoData;
var D: TDateTime;
begin
  // StrToDate — locale-dependente (dd/mm/yyyy em pt-BR)
  D := StrToDate('11/04/2026');
  Writeln('StrToDate: ', DateToStr(D));

  // TryStrToDate — seguro
  if TryStrToDate('31/02/2026', D) then
    Writeln('StrToDate OK: ', DateToStr(D))
  else
    Writeln('StrToDate "31/02": inválido como esperado');

  // Locale-safe com TFormatSettings
  var FS := TFormatSettings.Create('en-US');
  D := StrToDate('04/11/2026', FS);
  Writeln('StrToDate en-US (MM/DD/YYYY): ', FormatDateTime('dd/mm/yyyy', D));  // 11/04/2026

  // StrToDateTime
  D := StrToDateTime('11/04/2026 14:30:00');
  Writeln('StrToDateTime: ', FormatDateTime('dd/mm/yyyy hh:nn:ss', D));

  // ISO 8601 (yyyy-mm-dd) — não há função nativa direta; usar ParseDateTime
  var FSIso := TFormatSettings.Invariant;
  FSIso.ShortDateFormat := 'yyyy-mm-dd';
  FSIso.DateSeparator   := '-';
  D := StrToDate('2026-04-11', FSIso);
  Writeln('ISO 8601: ', FormatDateTime('dd/mm/yyyy', D));

  // DateTimeToStr / DateToStr / TimeToStr
  D := Now;
  Writeln('Now → DateToStr: ', DateToStr(D));
  Writeln('Now → TimeToStr: ', TimeToStr(D));
  Writeln('Now → DateTimeToStr: ', DateTimeToStr(D));

  // EncodeDate / DecodeDate
  D := EncodeDate(2026, 4, 11);
  var Ano, Mes, Dia: Word;
  DecodeDate(D, Ano, Mes, Dia);
  Writeln(Format('Decodificado: %d/%d/%d', [Dia, Mes, Ano]));
end;

// ---------------------------------------------------------------------------
// DemoConversaoBooleano — BoolToStr, StrToBool, TryStrToBool
// ---------------------------------------------------------------------------

procedure DemoConversaoBooleano;
var B: Boolean;
begin
  // BoolToStr — True='-1'/False='0' por padrão
  Writeln('BoolToStr(True): ',  BoolToStr(True));   // '-1'
  Writeln('BoolToStr(False): ', BoolToStr(False));  // '0'

  // BoolToStr com UseBoolStrs=True → 'True'/'False'
  Writeln('BoolToStr(True, True): ',  BoolToStr(True, True));   // 'True'
  Writeln('BoolToStr(False, True): ', BoolToStr(False, True));  // 'False'

  // StrToBool — aceita 'true','false','yes','no','on','off','1','0','-1'
  Writeln('StrToBool("true"): ',  StrToBool('true'));
  Writeln('StrToBool("yes"): ',   StrToBool('yes'));
  Writeln('StrToBool("1"): ',     StrToBool('1'));
  Writeln('StrToBool("false"): ', StrToBool('false'));

  // TryStrToBool — sem raise
  if not TryStrToBool('xyz', B) then
    Writeln('TryStrToBool "xyz": falhou como esperado');
end;

// ---------------------------------------------------------------------------
// DemoConversaoHex — IntToHex, HexToInt (via StrToInt com $)
// ---------------------------------------------------------------------------

procedure DemoConversaoHex;
begin
  // Integer → Hex (largura mínima com zero-padding)
  Writeln('IntToHex(0):        ', IntToHex(0, 2));         // '00'
  Writeln('IntToHex(255):      ', IntToHex(255, 2));       // 'FF'
  Writeln('IntToHex(65535):    ', IntToHex(65535, 4));     // 'FFFF'
  Writeln('IntToHex(16777215): ', IntToHex(16777215, 6));  // 'FFFFFF' (RGB max)

  // Hex → Integer
  Writeln('$FF = ',     StrToInt('$FF'));      // 255
  Writeln('$FFFF = ',   StrToInt('$FFFF'));    // 65535
  Writeln('0xFF = ',    StrToInt('0x' + 'FF')); // sem suporte 0x — usar $

  // Cor RGB → Hex string
  var R := 255; var G := 128; var B := 0;
  var HexCor := '#' + IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
  Writeln('Cor (255,128,0) = ', HexCor);  // '#FF8000'

  // Hex → RGB
  var Cor := '$FF8000';
  var ValCor := StrToInt(Cor);
  Writeln(Format('R=%d G=%d B=%d',
    [(ValCor shr 16) and $FF,
     (ValCor shr  8) and $FF,
      ValCor         and $FF]));
end;

// ---------------------------------------------------------------------------
// DemoFormatSettings — locale-safe: construção explícita de TFormatSettings
// ---------------------------------------------------------------------------

procedure DemoFormatSettings;
begin
  // Invariant — nunca depende do sistema
  var FSInv := TFormatSettings.Invariant;
  Writeln('Invariant decimal: "', FSInv.DecimalSeparator, '"');  // '.'
  Writeln('Invariant thousand: "', FSInv.ThousandSeparator, '"'); // ','

  // pt-BR
  var FSBR := TFormatSettings.Create('pt-BR');
  Writeln('pt-BR decimal: "', FSBR.DecimalSeparator, '"');  // ','
  Writeln('pt-BR date format: ', FSBR.ShortDateFormat);    // 'dd/MM/yyyy'

  // en-US
  var FSUS := TFormatSettings.Create('en-US');
  Writeln('en-US decimal: "', FSUS.DecimalSeparator, '"');  // '.'
  Writeln('en-US date format: ', FSUS.ShortDateFormat);    // 'M/d/yyyy'

  // Locale-safe round-trip de float
  var OriginalFloat := 1234.56;
  var SFloat := FloatToStr(OriginalFloat, FSInv);
  var BackFloat := StrToFloat(SFloat, FSInv);
  Writeln('Float round-trip: ', OriginalFloat = BackFloat);

  // Locale-safe round-trip de data
  var D := EncodeDate(2026, 4, 11);
  var SDate := FormatDateTime('yyyy-mm-dd', D, FSInv);
  Writeln('ISO date: ', SDate);  // '2026-04-11'
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoConversaoInteiro;
//   DemoConversaoFloat;
//   DemoConversaoData;
//   DemoConversaoBooleano;
//   DemoConversaoHex;
//   DemoFormatSettings;
// ---------------------------------------------------------------------------

end.
