unit strings_unicode;
{
  EXEMPLO: Strings em Delphi — Unicode, AnsiString, UTF8String
  Compilavel: dcc32 / dcc64
  Demonstra:
    - string (UnicodeString): operacoes essenciais
    - Conversao entre string, UTF8String, AnsiString
    - Copy, Pos, Length, Trim, Split, Replace
    - TStringBuilder para concatenacao de alto desempenho
    - Comparacoes: SameText, CompareText, SameStr
}

interface

uses
  System.SysUtils, System.Classes, System.Text;

procedure DemonstrarStringBasico;
procedure DemonstrarConversoes;
procedure DemonstrarOperacoes;
procedure DemonstrarStringBuilder;
procedure DemonstrarComparacoes;

implementation

procedure DemonstrarStringBasico;
var
  S: string;
  Short: ShortString; // max 255 chars, stack-allocated
begin
  // string = UnicodeString (UTF-16, 2 bytes por char BMP)
  S := 'Olá, Mundo! こんにちは 🌍';

  // Length retorna numero de code units (WideChar), NAO de caracteres Unicode
  Writeln('Length = ', Length(S));     // pode ser > numero de grafemas

  // Indice 1-based em Delphi (nao 0-based como em Python/Java)
  Writeln('Primeiro char: ', S[1]);   // 'O'
  Writeln('Ultimo char:   ', S[High(S)]); // mesmo que S[Length(S)]

  // ShortString: max 255 bytes ANSI, sem GC, padrao legado
  Short := 'Hello';
  Short[0] := Chr(3); // ShortString[0] = comprimento!
  Writeln('Short length via [0]: ', Ord(Short[0])); // 3
end;

procedure DemonstrarConversoes;
var
  U: string;       // UTF-16
  A: AnsiString;   // CP do sistema (windows-1252 em pt-BR)
  U8: UTF8String;  // UTF-8 (alias para RawByteString codepage 65001)
begin
  U := 'Ação Straße Привет';

  // string -> UTF8String (para serializar JSON, salvar arquivo, HTTP)
  U8 := UTF8String(U);  // ou: UTF8Encode(U)
  Writeln('UTF8 bytes: ', Length(U8)); // mais que Length(U) para chars multibyte

  // UTF8String -> string
  U := string(U8);  // ou: UTF8Decode(U8)

  // string -> AnsiString (PERDA de dados para chars fora do CP!)
  // Usar apenas para APIs legadas
  A := AnsiString(U); // aviso do compilador: possivel perda

  // Forma correta para APIs Win32 ANSI:
  // AnsiToWide / WideToAnsi ou usar W (wide) versions da API

  // Bytes crus de uma string UTF-8
  var Bytes := TEncoding.UTF8.GetBytes(U);
  Writeln('Bytes UTF-8: ', Length(Bytes));

  // Reconstruir string de bytes UTF-8
  U := TEncoding.UTF8.GetString(Bytes);
end;

procedure DemonstrarOperacoes;
var
  S, R: string;
  Parts: TArray<string>;
  Pos1 : Integer;
begin
  S := '  Olá, Mundo!  ';

  // Trim
  R := Trim(S);          // remove espacos nas extremidades
  R := TrimLeft(S);      // so esquerda
  R := TrimRight(S);     // so direita

  // Busca
  Pos1 := Pos('Mundo', S); // 1-based; 0 = nao encontrou
  if Pos1 > 0 then
    Writeln('Encontrado na posicao ', Pos1);

  // Substituicao
  R := S.Replace(',', ';');           // primeira ocorrencia
  R := S.Replace(',', ';', [rfReplaceAll]); // todas

  // Extrair substring
  R := Copy(S, 3, 5); // a partir do char 3, 5 chars

  // Dividir
  Parts := S.Split([',', ' ']); // split por multiplos separadores

  // Maiusculas / Minusculas
  R := UpperCase(S);  // ou S.ToUpper
  R := LowerCase(S);  // ou S.ToLower

  // Verificar
  if S.StartsWith('  Olá') then Writeln('Comeca com Ola');
  if S.EndsWith('!  ')     then Writeln('Termina com !');
  if S.Contains('Mundo')   then Writeln('Contem Mundo');
  if S.IsEmpty             then Writeln('Vazia'); // nao e vazia aqui

  // Formatar
  R := Format('Nome: %s, Codigo: %d, Preco: %.2f', ['Joao', 42, 19.99]);

  // IntToStr / StrToInt
  R := IntToStr(42);
  var N := StrToIntDef('abc', -1); // retorna -1 se falhar

  // Tamanho em bytes (nao em chars)
  Writeln('Bytes na memoria: ', Length(S) * SizeOf(Char)); // SizeOf(Char)=2
end;

procedure DemonstrarStringBuilder;
var
  SB: TStringBuilder;
  I : Integer;
  R : string;
begin
  // Para concatenar muitas strings: usar TStringBuilder
  // Concatenacao com + em loop e O(n^2) — StringBuilder e O(n)
  SB := TStringBuilder.Create;
  try
    SB.Append('SELECT * FROM produto');
    SB.Append(' WHERE ativo = 1');
    SB.AppendLine; // + #13#10
    SB.AppendFormat(' ORDER BY %s', ['nome']);

    // Loop eficiente
    for I := 1 to 100 do
    begin
      SB.Append(I.ToString);
      if I < 100 then SB.Append(', ');
    end;

    R := SB.ToString;
    Writeln(R);
  finally
    SB.Free;
  end;
end;

procedure DemonstrarComparacoes;
var
  A, B: string;
begin
  A := 'Hello';
  B := 'hello';

  // Comparacao case-sensitive (padrao)
  Writeln(A = B);            // False
  Writeln(A <> B);           // True
  Writeln(A > B);            // False (H < h em Unicode)

  // Comparacao case-insensitive
  Writeln(SameText(A, B));                    // True
  Writeln(CompareText(A, B) = 0);            // True
  Writeln(String.CompareOrdinal(A, B) = 0);  // False (ordinal, case-sensitive)

  // Verificacoes
  Writeln(A.ToLower = B.ToLower); // True — comparacao normalizada

  // Para ordenacao correta (locale-aware):
  // System.SysUtils.AnsiCompareStr / AnsiCompareText
  Writeln(AnsiCompareText(A, B) = 0); // True, considera locale
end;

end.
