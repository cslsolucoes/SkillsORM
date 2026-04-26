unit string_encoding;
{
  Encoding — UTF8Encode/Decode, TEncoding, AnsiString vs string, CodePage
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes;

procedure DemoUTF8EncDec;
procedure DemoTEncodingStrings;
procedure DemoAnsiVsUnicode;
procedure DemoCodePageConversao;
procedure DemoHTMLEntities;

implementation

// ---------------------------------------------------------------------------
// DemoUTF8EncDec — UTF8Encode / UTF8Decode (funções legacy mas úteis)
// ---------------------------------------------------------------------------

procedure DemoUTF8EncDec;
var Original: string;
    UTF8: UTF8String;
    Bytes: TBytes;
begin
  Original := 'Olá, coração, ação — Ü ñ ê';

  // UTF8Encode: string → UTF8String (AnsiString com CP 65001)
  UTF8 := UTF8Encode(Original);
  Writeln('Original  length: ', Original.Length);
  Writeln('UTF8String length: ', Length(UTF8));  // pode ser maior (multi-byte)

  // UTF8Decode: UTF8String → string
  var Back := UTF8Decode(UTF8);
  Writeln('Decode back: ', Back);
  Writeln('Igual? ', Back = Original);

  // Via TEncoding (abordagem moderna)
  Bytes := TEncoding.UTF8.GetBytes(Original);
  Writeln('UTF-8 bytes: ', Length(Bytes));
  Back := TEncoding.UTF8.GetString(Bytes);
  Writeln('Via TEncoding, igual? ', Back = Original);

  // Comparar tamanhos de encoding
  var B8  := TEncoding.UTF8.GetBytes(Original);
  var B16 := TEncoding.Unicode.GetBytes(Original);
  var BANSI := TEncoding.ANSI.GetBytes(Original);
  Writeln('UTF-8  bytes: ', Length(B8));
  Writeln('UTF-16 bytes: ', Length(B16));
  Writeln('ANSI   bytes: ', Length(BANSI));  // pode perder chars fora do codepage
end;

// ---------------------------------------------------------------------------
// DemoTEncodingStrings — GetString com offset; conversão entre encodings
// ---------------------------------------------------------------------------

procedure DemoTEncodingStrings;
var S:    string;
    Bytes: TBytes;
begin
  S := 'ABC ação XYZ';

  // GetBytes + GetString
  Bytes := TEncoding.UTF8.GetBytes(S);
  var Back := TEncoding.UTF8.GetString(Bytes);
  Writeln('Round-trip UTF-8: ', Back = S);

  // GetString com offset e contagem
  Bytes := TEncoding.UTF8.GetBytes('Hello World');
  var Parte := TEncoding.UTF8.GetString(Bytes, 6, 5);  // 'World'
  Writeln('GetString(6,5): ', Parte);

  // GetByteCount — tamanho sem converter
  Writeln('GetByteCount: ', TEncoding.UTF8.GetByteCount(S));

  // Convert entre encodings (TEncoding.Convert)
  var UTF8Bytes := TEncoding.UTF8.GetBytes('Olá');
  var UTF16Bytes := TEncoding.Convert(TEncoding.UTF8, TEncoding.Unicode, UTF8Bytes);
  Writeln('UTF-16 bytes após Convert: ', Length(UTF16Bytes));
  Writeln('UTF-16 string: ', TEncoding.Unicode.GetString(UTF16Bytes));

  // GetEncoding por nome
  var Enc := TEncoding.GetEncoding('UTF-8');
  try
    Writeln('By name "UTF-8": ', Enc.EncodingName);
  finally
    if not TEncoding.IsStandardEncoding(Enc) then Enc.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoAnsiVsUnicode — diferenças AnsiString vs string (UnicodeString)
// ---------------------------------------------------------------------------

procedure DemoAnsiVsUnicode;
var US: string;        // UnicodeString (UTF-16, 2 bytes por char BMP)
    AS_: AnsiString;   // AnsiString (1 byte por char, CP SO ou explícito)
    U8: UTF8String;    // UTF8String = AnsiString with CP 65001
    RawU8: RawByteString;  // sem codepage — útil para protocolo binário
begin
  US := 'Olá, Delphi!';
  AS_ := AnsiString(US);  // conversão implícita, pode perder chars fora da CP

  Writeln('UnicodeString Length: ', US.Length);  // 12 chars
  Writeln('AnsiString Length:    ', Length(AS_));  // 12 bytes (pt-BR CP 1252)

  // CodePage
  Writeln('AnsiString CodePage: ', StringCodePage(AS_));  // 1252 ou SO default
  U8 := UTF8String(US);
  Writeln('UTF8String CodePage: ', StringCodePage(U8));    // 65001

  // Acessar bytes de AnsiString diretamente
  var PByte := PByte(PAnsiChar(AS_));
  Write('Bytes de AnsiString: ');
  var I: Integer;
  for I := 0 to Length(AS_) - 1 do
    Write(PByte[I], ' ');
  Writeln;

  // RawByteString — sem CP: para buffers binários onde CP não importa
  RawU8 := RawByteString(PAnsiChar(U8));
  Writeln('RawByteString length: ', Length(RawU8));

  // String para envio via socket (bytes exatos)
  var BytesToSend := TEncoding.UTF8.GetBytes(US);
  Writeln('Bytes to send (UTF-8): ', Length(BytesToSend));
end;

// ---------------------------------------------------------------------------
// DemoCodePageConversao — converter entre codepages via TEncoding
// ---------------------------------------------------------------------------

procedure DemoCodePageConversao;
var S:     string;
    Bytes: TBytes;
begin
  S := 'Ação — coração — câmera';

  // UTF-8 bytes
  Bytes := TEncoding.UTF8.GetBytes(S);
  Writeln('UTF-8: ', Length(Bytes), ' bytes');

  // Windows-1252 bytes (pode perder caracteres não suportados)
  var CP1252 := TEncoding.GetEncoding(1252);
  try
    var Bytes1252 := CP1252.GetBytes(S);
    Writeln('CP1252: ', Length(Bytes1252), ' bytes');
    var Back := CP1252.GetString(Bytes1252);
    Writeln('CP1252 round-trip: ', Back = S);
  finally
    CP1252.Free;
  end;

  // ISO-8859-1 (Latin-1) — 28591
  var Latin1 := TEncoding.GetEncoding(28591);
  try
    var BytesL1 := Latin1.GetBytes(S);
    Writeln('ISO-8859-1: ', Length(BytesL1), ' bytes');
    // Alguns chars podem virar '?' se fora do Latin-1
  finally
    Latin1.Free;
  end;

  // Detectar encoding de um buffer
  Bytes := TEncoding.UTF8.GetPreamble;
  Bytes := Bytes + TEncoding.UTF8.GetBytes('Conteúdo UTF-8');
  var Enc: TEncoding;
  var BOMLen := TEncoding.GetBufferEncoding(Bytes, Enc, TEncoding.UTF8);
  try
    Writeln('Detectado: ', Enc.EncodingName, ' BOM=', BOMLen);
  finally
    if not TEncoding.IsStandardEncoding(Enc) then Enc.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoHTMLEntities — escapar/desescapar entidades HTML
// ---------------------------------------------------------------------------

procedure DemoHTMLEntities;
var S, Escaped: string;
begin
  S := '<script>alert("XSS & injection")</script>';

  // Escape manual (não há função nativa no RTL básico)
  Escaped := S
    .Replace('&', '&amp;')
    .Replace('<', '&lt;')
    .Replace('>', '&gt;')
    .Replace('"', '&quot;')
    .Replace('''', '&#39;');
  Writeln('Escaped: ', Escaped);

  // URL encode manual (básico)
  var URL := 'https://example.com/busca?q=ação&page=1';
  var Encoded := '';
  var I: Integer;
  for I := 1 to URL.Length do
  begin
    var C := URL.Chars[I - 1];
    if C.IsLetterOrDigit or C.IsInArray(['-', '_', '.', '~', '/', ':', '?', '=', '&']) then
      Encoded := Encoded + C
    else
      Encoded := Encoded + '%' + IntToHex(Ord(C), 2);
  end;
  Writeln('URL encoded: ', Encoded);

  // Decodificar é similar (% + 2 hex → char)
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoUTF8EncDec;
//   DemoTEncodingStrings;
//   DemoAnsiVsUnicode;
//   DemoCodePageConversao;
//   DemoHTMLEntities;
// ---------------------------------------------------------------------------

end.
