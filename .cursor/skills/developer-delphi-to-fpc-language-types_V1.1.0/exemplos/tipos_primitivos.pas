unit tipos_primitivos;
{
  EXEMPLO: Tipos primitivos em Delphi/Object Pascal
  Compilavel: dcc32 / dcc64
  Demonstra:
    - Integer, Int64, Cardinal, Byte, Word
    - Single, Double, Extended, Currency
    - NativeInt/NativeUInt (tamanho de plataforma)
    - Limites (MinInt, MaxInt, High/Low)
    - Conversoes seguras e overflow
}

interface

uses
  System.SysUtils, System.Math;

procedure DemonstrarTiposInteiros;
procedure DemonstrarTiposFloat;
procedure DemonstrarNativeTypes;
procedure DemonstrarCurrency;

implementation

procedure DemonstrarTiposInteiros;
var
  B  : Byte;      // 0..255
  Sb : ShortInt;  // -128..127
  W  : Word;      // 0..65535
  Sm : SmallInt;  // -32768..32767
  I  : Integer;   // -2147483648..2147483647
  C  : Cardinal;  // 0..4294967295
  I64: Int64;     // -9223372036854775808..9223372036854775807
  U64: UInt64;    // 0..18446744073709551615
begin
  // Valores limite
  B   := High(Byte);    // 255
  Sb  := Low(ShortInt); // -128
  W   := High(Word);    // 65535
  I   := MaxInt;        // 2147483647
  C   := High(Cardinal);// 4294967295
  I64 := High(Int64);   // 9223372036854775807

  // Overflow silencioso (sem {$OVERFLOWCHECKS ON})
  B := 255;
  Inc(B); // B = 0 (wrap around) — sem excecao por padrao

  // Com verificacao de overflow:
  {$OVERFLOWCHECKS ON}
  try
    I := MaxInt;
    Inc(I); // dispara EIntOverflow
  except
    on E: EIntOverflow do
      Writeln('Overflow detectado: ', E.Message);
  end;
  {$OVERFLOWCHECKS OFF}

  // Conversoes seguras
  I   := 1000;
  I64 := I;        // widening: sempre seguro
  // I := I64;     // ERRO: narrowing sem cast — pode truncar

  if I64 <= MaxInt then
    I := Integer(I64); // cast explicito apos verificacao
end;

procedure DemonstrarTiposFloat;
var
  S: Single;   // 4 bytes, ~7 digitos significativos
  D: Double;   // 8 bytes, ~15 digitos
  E: Extended; // 10 bytes (x87) ou 8 bytes (Win64/ARM)
begin
  S := 3.14159265358979;
  D := 3.14159265358979;
  E := 3.14159265358979;

  // Comparacao direta de floats e PERIGOSA — usar epsilon
  if SameValue(S, D, 1e-5) then
    Writeln('Aproximadamente iguais');

  if IsZero(S - D, 1e-6) then
    Writeln('Diferenca negligenciavel');

  // Verificar NaN e Infinity
  D := 0.0;
  // D := 1.0 / D; // gera +Infinity
  if IsInfinite(D) then Writeln('Infinito');
  if IsNan(D)      then Writeln('NaN');

  // Arredondamento
  Writeln(FloatToStrF(3.14159, ffFixed, 8, 2)); // "3.14"
end;

procedure DemonstrarNativeTypes;
var
  N : NativeInt;  // Integer em Win32, Int64 em Win64
  UN: NativeUInt; // Cardinal em Win32, UInt64 em Win64
  P : Pointer;    // sempre tamanho de ponteiro
begin
  // NativeInt e util para aritmetica de ponteiros
  N := NativeInt(P);
  N := N + SizeOf(Integer); // avan?ar um elemento

  // SizeOf e plataforma-dependente
  Writeln('SizeOf(NativeInt) = ', SizeOf(NativeInt));   // 4 ou 8
  Writeln('SizeOf(Pointer)   = ', SizeOf(Pointer));     // 4 ou 8
  Writeln('SizeOf(Integer)   = ', SizeOf(Integer));     // sempre 4

  // Para codigo portavel entre 32/64 bits: usar NativeInt em loops de ponteiro
  UN := NativeUInt(P);
end;

procedure DemonstrarCurrency;
var
  Preco   : Currency;
  Desconto: Currency;
  Total   : Currency;
begin
  // Currency: 64-bit scaled integer, fator 10000
  // SEM erros de arredondamento para valores monetarios
  Preco    := 19.99;
  Desconto := 0.10; // 10%

  // Operacoes exatas
  Total := Preco * (1 - Desconto);
  Writeln(CurrToStr(Total)); // "17.991" — exato

  // Double seria impreciso:
  // var D: Double := 19.99 * 0.90; // pode dar 17.990999999...

  // Formatar como moeda
  Writeln(FormatCurr('#,##0.00', Total));     // "17.99"
  Writeln(FormatCurr('R$ #,##0.00', Total)); // "R$ 17.99"
end;

end.
