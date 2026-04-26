unit string_helpers;
{
  TStringHelper — métodos nativos de string no Delphi moderno
  Compilavel: dcc32 / dcc64
  Uses: System.SysUtils (implícito via uses)
}

interface

uses
  System.SysUtils, System.Generics.Collections;

procedure DemoStringBasico;
procedure DemoStringBusca;
procedure DemoStringSplit;
procedure DemoStringTransformacao;
procedure DemoStringPaddingAlinhamento;

implementation

// ---------------------------------------------------------------------------
// DemoStringBasico — propriedades e métodos fundamentais
// ---------------------------------------------------------------------------

procedure DemoStringBasico;
var S: string;
begin
  S := '  Olá, Mundo! Delphi é incrível.  ';

  // Comprimento
  Writeln('Length: ', S.Length);
  Writeln('IsEmpty: ', S.IsEmpty);
  Writeln('"".IsEmpty: ', ''.IsEmpty);

  // Trim
  Writeln('Trim: "', S.Trim, '"');
  Writeln('TrimLeft: "', S.TrimLeft, '"');
  Writeln('TrimRight: "', S.TrimRight, '"');
  // Trim com chars específicos
  Writeln('Trim([" ","."]): "', '...teste...'.Trim(['.', ' ']), '"');

  // Case
  S := 'Olá, Mundo!';
  Writeln('ToLower: ', S.ToLower);
  Writeln('ToUpper: ', S.ToUpper);

  // Substring
  Writeln('Substring(5): ',    S.Substring(5));        // 'Mundo!'
  Writeln('Substring(5,5): ',  S.Substring(5, 5));     // 'Mundo'
  // Nota: índice base 0

  // Chars individuais
  Writeln('Chars[0]: ', S.Chars[0]);   // 'O'
  Writeln('Chars[5]: ', S.Chars[5]);   // 'M'
end;

// ---------------------------------------------------------------------------
// DemoStringBusca — Contains, IndexOf, StartsWith, EndsWith
// ---------------------------------------------------------------------------

procedure DemoStringBusca;
var S: string;
begin
  S := 'Delphi é a melhor linguagem para desktop';

  // Verificação de presença
  Writeln('Contains("melhor"): ',     S.Contains('melhor'));
  Writeln('Contains("MELHOR"): ',     S.Contains('MELHOR'));  // False (case-sensitive)

  Writeln('StartsWith("Delphi"): ',   S.StartsWith('Delphi'));
  Writeln('StartsWith("delphi"): ',   S.StartsWith('delphi'));  // False
  Writeln('StartsWith("delphi",True):', S.StartsWith('delphi', True));  // True (ignoreCase)

  Writeln('EndsWith("desktop"): ',    S.EndsWith('desktop'));

  // IndexOf — base 0, retorna -1 se não encontrado
  Writeln('IndexOf("melhor"): ',      S.IndexOf('melhor'));    // 13
  Writeln('IndexOf("xyz"): ',         S.IndexOf('xyz'));       // -1
  Writeln('IndexOf("a"): ',           S.IndexOf('a'));         // 1 (primeiro)
  Writeln('IndexOf("a",10): ',        S.IndexOf('a', 10));    // busca a partir de 10

  // LastIndexOf
  Writeln('LastIndexOf("a"): ',       S.LastIndexOf('a'));    // último 'a'

  // CountChar — contar ocorrências de um caractere
  Writeln('CountChar("a"): ',         S.CountChar('a'));

  // Compare
  Writeln('CompareOrdinal: ', string.CompareOrdinal('abc', 'ABC'));  // > 0
  Writeln('Compare ci: ',     string.Compare('abc', 'ABC', True));   // 0 (ci)
end;

// ---------------------------------------------------------------------------
// DemoStringSplit — Split com delimitadores, QuotedStr
// ---------------------------------------------------------------------------

procedure DemoStringSplit;
var S:    string;
    Partes: TArray<string>;
    P:    string;
begin
  S := 'Alice,Bob,Carol,Dave,Eve';

  // Split por char único
  Partes := S.Split([',']);
  Writeln('Split por vírgula: ', Length(Partes), ' partes');
  for P in Partes do Write('[', P, '] ');
  Writeln;

  // Split por múltiplos delimitadores
  S := 'um dois,três;quatro-cinco';
  Partes := S.Split([' ', ',', ';', '-']);
  Writeln('Split múltiplo: ', Length(Partes), ' partes');
  for P in Partes do Write('[', P, '] ');
  Writeln;

  // Split com limite (Delphi 10.4+)
  S := 'a:b:c:d:e';
  Partes := S.Split([':'], 3);  // máximo 3 partes
  Writeln('Split com limite 3: ', Length(Partes));
  for P in Partes do Write('[', P, '] ');
  Writeln;
  // [a] [b] [c:d:e]

  // Join (inverso do Split)
  S := string.Join(', ', ['Alpha', 'Beta', 'Gamma']);
  Writeln('Join: ', S);

  // Join de TArray<string>
  var Nomes: TArray<string> := ['João', 'Maria', 'Pedro'];
  Writeln('Join array: ', string.Join(' | ', Nomes));

  // QuotedString
  var Q := 'don''t'.QuotedString;
  Writeln('QuotedString: ', Q);
  var DeQ := Q.DeQuotedString;
  Writeln('DeQuotedString: ', DeQ);
end;

// ---------------------------------------------------------------------------
// DemoStringTransformacao — Replace, Insert, Remove, Reverse
// ---------------------------------------------------------------------------

procedure DemoStringTransformacao;
var S: string;
begin
  S := 'O rato roeu a roupa do rei de Roma';

  // Replace
  Writeln('Replace "ro" → "XY": ', S.Replace('ro', 'XY'));
  Writeln('Replace ci: ', S.Replace('RO', 'XY', [rfIgnoreCase]));
  Writeln('Replace first only: ', S.Replace('ro', 'XY', [rfReplaceAll]));
  // rfReplaceAll = padrão; sem a flag = substitui só a primeira

  // Insert — base 1 (diferente de Substring que é base 0!)
  var T := S;
  Insert(' grande', T, 8);  // Insert usa índice base 1
  Writeln('Após Insert: ', T);

  // Delete — base 1
  T := 'Hello World';
  Delete(T, 6, 6);
  Writeln('Após Delete(6,6): ', T);  // 'Hello'

  // Copy — extrai substring (base 1)
  Writeln('Copy(5,5): ', Copy('Hello World', 5, 5));  // 'o Wor'

  // Reverse (via loop manual — TStringHelper não tem Reverse)
  S := 'Delphi';
  var Rev := '';
  var I: Integer;
  for I := S.Length - 1 downto 0 do
    Rev := Rev + S.Chars[I];
  Writeln('Reverse: ', Rev);  // 'ihpleD'
end;

// ---------------------------------------------------------------------------
// DemoStringPaddingAlinhamento — PadLeft, PadRight
// ---------------------------------------------------------------------------

procedure DemoStringPaddingAlinhamento;
var I: Integer;
begin
  // PadLeft (alinha à direita)
  Writeln('"42".PadLeft(8): "',    '42'.PadLeft(8), '"');      // '      42'
  Writeln('"42".PadLeft(8,"0"): "','42'.PadLeft(8, '0'), '"'); // '00000042'

  // PadRight (alinha à esquerda)
  Writeln('"OK".PadRight(10,"."): "', 'OK'.PadRight(10, '.'), '"'); // 'OK........'

  // Tabular dados
  Writeln('--- Tabela ---');
  var Dados: array[0..3] of record Nome: string; Valor: Integer; end;
  Dados[0].Nome := 'Alice';  Dados[0].Valor := 1500;
  Dados[1].Nome := 'Bob';    Dados[1].Valor := 12000;
  Dados[2].Nome := 'Carol';  Dados[2].Valor := 850;
  Dados[3].Nome := 'Dave';   Dados[3].Valor := 4200;

  for I := 0 to 3 do
    Writeln(Dados[I].Nome.PadRight(10) + IntToStr(Dados[I].Valor).PadLeft(8));
  // Alice        1500
  // Bob         12000
  // Carol         850
  // Dave          4200

  // Truncar se maior que largura (manual)
  var Longa := 'String muito longa para truncar';
  var MaxLen := 15;
  var Truncada := Longa.Substring(0, Min(Longa.Length, MaxLen));
  if Longa.Length > MaxLen then Truncada := Truncada + '...';
  Writeln('Truncada: "', Truncada, '"');
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoStringBasico;
//   DemoStringBusca;
//   DemoStringSplit;
//   DemoStringTransformacao;
//   DemoStringPaddingAlinhamento;
// ---------------------------------------------------------------------------

end.
