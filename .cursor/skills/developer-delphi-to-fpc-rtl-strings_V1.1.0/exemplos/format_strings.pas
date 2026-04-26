unit format_strings;
{
  Format — especificadores %s, %d, %f, %g, %e, %x, padding, alinhamento
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

procedure DemoFormatBasico;
procedure DemoFormatNumeros;
procedure DemoFormatPadding;
procedure DemoFormatFloat;
procedure DemoFloatToStrF;
procedure DemoFormatDateTime;

implementation

// ---------------------------------------------------------------------------
// DemoFormatBasico — especificadores principais
// ---------------------------------------------------------------------------

procedure DemoFormatBasico;
begin
  // %s — string
  Writeln(Format('Nome: %s', ['Alice']));

  // %d — decimal inteiro (Integer, Int64, etc.)
  Writeln(Format('Idade: %d anos', [30]));

  // %f — float com formatação padrão (6 casas)
  Writeln(Format('Valor: %f', [1234.5]));

  // %g — notação mais curta (sem zeros desnecessários)
  Writeln(Format('g: %g', [1234.5]));    // '1234.5'
  Writeln(Format('g: %g', [1234.0]));   // '1234'

  // %e — notação científica
  Writeln(Format('e: %e', [0.000123]));  // '1.23000e-4'

  // %n — float com separadores de milhar (locale-aware)
  Writeln(Format('n: %n', [1234567.89]));  // '1.234.567,89' (pt-BR)

  // %m — moeda (locale-aware)
  Writeln(Format('m: %m', [1500.0]));

  // %x — hexadecimal
  Writeln(Format('Hex: %x', [255]));   // 'FF'
  Writeln(Format('Hex: %x', [4096]));  // '1000'

  // %% — literal %
  Writeln(Format('Taxa: %d%%', [15])); // 'Taxa: 15%'

  // Múltiplos valores
  Writeln(Format('%s tem %d anos e saldo de R$%.2f', ['Bob', 25, 2300.5]));
end;

// ---------------------------------------------------------------------------
// DemoFormatNumeros — inteiros, width, zero padding
// ---------------------------------------------------------------------------

procedure DemoFormatNumeros;
begin
  // Width — largura mínima (alinha à direita por padrão)
  Writeln(Format('[%8d]', [42]));       // '[      42]'
  Writeln(Format('[%-8d]', [42]));      // '[42      ]' — alinha esquerda com -
  Writeln(Format('[%08d]', [42]));      // '[00000042]' — zero padding

  // Int64
  Writeln(Format('%d', [Int64(9876543210)]));

  // Negativo
  Writeln(Format('[%8d]', [-42]));      // '[     -42]'
  Writeln(Format('[%08d]', [-42]));     // '[-0000042]'

  // Hexadecimal com width
  Writeln(Format('[%8x]',  [255]));     // '[      FF]'
  Writeln(Format('[%08x]', [255]));     // '[000000FF]'
  Writeln(Format('[%.8x]', [255]));     // '[000000FF]' — precision em inteiros = min digits

  // Octal (não tem especificador nativo — converter manual)
  Writeln(Format('Octal de 255: %s', [OctToStr(255)]));

  // Índice explícito de argumento (Delphi suporta %0:d, %1:s etc.)
  Writeln(Format('%1:s tem %0:d anos', [30, 'Carol']));
  // 'Carol tem 30 anos' — %1: acessa arg[1], %0: acessa arg[0]
end;

// ---------------------------------------------------------------------------
// DemoFormatFloat — precisão decimal e notações
// ---------------------------------------------------------------------------

procedure DemoFormatFloat;
begin
  // %.Nf — N casas decimais
  Writeln(Format('%.0f', [3.7]));   // '4'  (arredonda)
  Writeln(Format('%.1f', [3.14]));  // '3.1'
  Writeln(Format('%.2f', [3.14]));  // '3.14'
  Writeln(Format('%.4f', [3.14]));  // '3.1400'
  Writeln(Format('%.6f', [3.14]));  // '3.140000'

  // Width + precision
  Writeln(Format('[%10.2f]', [3.14]));   // '[      3.14]'
  Writeln(Format('[%-10.2f]', [3.14]));  // '[3.14      ]'
  Writeln(Format('[%010.2f]', [3.14]));  // '[0000003.14]'

  // %.Nge — notação científica
  Writeln(Format('%.3e', [12345678.9]));  // '1.235e+7'
  Writeln(Format('%.3g', [0.00001234]));  // '1.23e-5'
  Writeln(Format('%.3g', [123.456]));     // '123'

  // NaN e Infinity
  Writeln(Format('%f', [1.0/0]));  // 'INF' ou similar (comportamento definido)
end;

// ---------------------------------------------------------------------------
// DemoFloatToStrF — controle preciso de formato de float
// ---------------------------------------------------------------------------

procedure DemoFloatToStrF;
begin
  // FloatToStrF(Value, Format, Precision, Digits)
  // ffFixed: casas decimais fixas
  Writeln(FloatToStrF(1234567.891, ffFixed,   15, 2));  // '1234567,89' (locale)
  Writeln(FloatToStrF(1234567.891, ffFixed,   15, 0));  // '1234568'

  // ffNumber: como ffFixed mas com separador de milhar
  Writeln(FloatToStrF(1234567.891, ffNumber,  15, 2));  // '1.234.567,89' (pt-BR)

  // ffCurrency: moeda
  Writeln(FloatToStrF(1234.5, ffCurrency, 15, 2));      // 'R$ 1.234,50' (locale)

  // ffScientific: notação científica
  Writeln(FloatToStrF(0.000123, ffScientific, 4, 2));   // '1,23E-4'

  // ffGeneral: mais compacto (sem zeros)
  Writeln(FloatToStrF(123.456, ffGeneral, 6, 0));       // '123,456'
  Writeln(FloatToStrF(123.0,   ffGeneral, 6, 0));       // '123'

  // Locale-safe (ponto decimal explícito)
  var FS := TFormatSettings.Create('en-US');  // sempre ponto
  Writeln(FloatToStrF(1234.56, ffFixed, 10, 2, FS));    // '1234.56'
  Writeln(FloatToStrF(1234.56, ffNumber, 10, 2, FS));   // '1,234.56'
end;

// ---------------------------------------------------------------------------
// DemoFormatDateTime — formatos de data/hora
// ---------------------------------------------------------------------------

procedure DemoFormatDateTime;
var D: TDateTime;
begin
  D := EncodeDateTime(2026, 4, 11, 14, 30, 45, 0);

  // Formatos de data
  Writeln(FormatDateTime('dd/mm/yyyy',     D));  // 11/04/2026
  Writeln(FormatDateTime('yyyy-mm-dd',     D));  // 2026-04-11
  Writeln(FormatDateTime('dd "de" mmmm "de" yyyy', D));  // 11 de abril de 2026

  // Formatos de hora
  Writeln(FormatDateTime('hh:nn:ss',       D));  // 14:30:45
  Writeln(FormatDateTime('hh:nn:ss.zzz',   D));  // 14:30:45.000
  Writeln(FormatDateTime('hh:nn AM/PM',    D));  // 02:30 PM

  // Data + hora
  Writeln(FormatDateTime('dd/mm/yyyy hh:nn:ss', D));
  Writeln(FormatDateTime('ddd, dd mmm yyyy',    D));  // Sáb, 11 abr 2026

  // DateTimeToStr / DateToStr / TimeToStr (locale)
  Writeln(DateTimeToStr(D));
  Writeln(DateToStr(D));
  Writeln(TimeToStr(D));

  // Tokens: d=dia, m=mês, y=ano, h=hora, n=minuto, s=seg, z=ms
  // mm antes de hh = minuto (não mês); depois de hh = minuto
  Writeln(FormatDateTime('mm/dd/yyyy', D));  // mês/dia/ano (EN style)
  Writeln(FormatDateTime('yyyy"Q"q',   D));  // trimestre: 2026Q2

  // TFormatSettings para locale-safe
  var FS := TFormatSettings.Create('pt-BR');
  Writeln(FormatDateTime('dddd, d "de" mmmm "de" yyyy', D, FS));
  // Sábado, 11 de abril de 2026

  // Format com %s para datas
  Writeln(Format('Gerado em: %s', [FormatDateTime('dd/mm/yyyy hh:nn', D)]));
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoFormatBasico;
//   DemoFormatNumeros;
//   DemoFormatPadding;
//   DemoFormatFloat;
//   DemoFloatToStrF;
//   DemoFormatDateTime;
// ---------------------------------------------------------------------------

end.
