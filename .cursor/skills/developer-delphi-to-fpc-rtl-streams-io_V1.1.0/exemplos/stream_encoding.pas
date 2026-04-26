unit stream_encoding;
{
  TStreamReader/Writer, TEncoding (UTF-8/UTF-16/ANSI), BOM, DetectEncoding
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

procedure DemoEncodingBasico;
procedure DemoStreamReaderWriter;
procedure DemoDetectEncoding;
procedure DemoConversaoEncoding;
procedure DemoBOMHandling;

implementation

// ---------------------------------------------------------------------------
// DemoEncodingBasico — TEncoding.GetBytes / GetString
// ---------------------------------------------------------------------------

procedure DemoEncodingBasico;
var UTF8, UTF16, ANSI: TEncoding;
    Original: string;
    BytesUTF8, BytesUTF16, BytesANSI: TBytes;
begin
  Original := 'Olá, ação, coração — UTF-8 vs UTF-16 vs ANSI';

  UTF8  := TEncoding.UTF8;
  UTF16 := TEncoding.Unicode;    // UTF-16 LE
  ANSI  := TEncoding.ANSI;       // CP padrão do SO

  BytesUTF8  := UTF8.GetBytes(Original);
  BytesUTF16 := UTF16.GetBytes(Original);
  BytesANSI  := ANSI.GetBytes(Original);

  Writeln('String original: ', Original);
  Writeln('UTF-8  bytes: ', Length(BytesUTF8));
  Writeln('UTF-16 bytes: ', Length(BytesUTF16));
  Writeln('ANSI   bytes: ', Length(BytesANSI));

  // Decodificar de volta
  var Back := UTF8.GetString(BytesUTF8);
  Writeln('Decode UTF-8: ', Back);

  // GetEncoding por CodePage
  var CP1252 := TEncoding.GetEncoding(1252);  // Windows-1252
  try
    Writeln('CodePage 1252 name: ', CP1252.EncodingName);
  finally
    CP1252.Free;
  end;

  // Preamble (BOM)
  var Preamble := UTF8.GetPreamble;
  Writeln('UTF-8 BOM length: ', Length(Preamble));  // 3 bytes EF BB BF
  Preamble := UTF16.GetPreamble;
  Writeln('UTF-16 BOM length: ', Length(Preamble)); // 2 bytes FF FE
end;

// ---------------------------------------------------------------------------
// DemoStreamReaderWriter — TStreamWriter e TStreamReader com encoding
// ---------------------------------------------------------------------------

procedure DemoStreamReaderWriter;
const ARQ = 'encoding_test.txt';
var MS: TMemoryStream;
    SW: TStreamWriter;
    SR: TStreamReader;
    L:  string;
begin
  MS := TMemoryStream.Create;
  try
    // TStreamWriter com UTF-8 + BOM
    SW := TStreamWriter.Create(MS, TEncoding.UTF8);
    try
      SW.NewLine := #13#10;  // CRLF explícito
      SW.AutoFlush := False;
      SW.WriteLine('Primeira linha — caracteres especiais: ção âê ü');
      SW.WriteLine('Segunda linha — números: 123.456,78');
      SW.WriteLine('Terceira linha');
      SW.Flush;
    finally
      SW.Free;
    end;

    Writeln('MemoryStream Size: ', MS.Size);

    // Salvar para arquivo e reler
    MS.SaveToFile(ARQ);

    // TStreamReader detecta BOM automaticamente (True = detectBOM)
    SR := TStreamReader.Create(ARQ, TEncoding.UTF8, True);
    try
      Writeln('CurrentEncoding: ', SR.CurrentEncoding.EncodingName);
      while not SR.EndOfStream do
      begin
        L := SR.ReadLine;
        Writeln('> ', L);
      end;
    finally
      SR.Free;
    end;
  finally
    MS.Free;
  end;
  DeleteFile(ARQ);
end;

// ---------------------------------------------------------------------------
// DemoDetectEncoding — detectar encoding de arquivo existente
// ---------------------------------------------------------------------------

procedure DemoDetectEncoding;
var Preamble: TBytes;
    Raw:      TBytes;
    Enc:      TEncoding;
    BOMLen:   Integer;
begin
  // Simular arquivo UTF-16 LE com BOM
  var MS := TMemoryStream.Create;
  try
    // Escrever BOM manualmente + conteúdo UTF-16
    Preamble := TEncoding.Unicode.GetPreamble;  // FF FE
    MS.WriteBuffer(Preamble[0], Length(Preamble));
    Raw := TEncoding.Unicode.GetBytes('Texto em UTF-16 com BOM');
    MS.WriteBuffer(Raw[0], Length(Raw));
    MS.Position := 0;

    // Ler todos os bytes
    SetLength(Raw, MS.Size);
    MS.Read(Raw[0], MS.Size);

    // TEncoding.GetBufferEncoding detecta pelo preamble
    BOMLen := TEncoding.GetBufferEncoding(Raw, Enc);
    try
      Writeln('Encoding detectado: ', Enc.EncodingName);
      Writeln('BOM length: ', BOMLen);

      // Decodificar o conteúdo (pular o BOM)
      var Conteudo := Enc.GetString(Raw, BOMLen, Length(Raw) - BOMLen);
      Writeln('Conteúdo: ', Conteudo);
    finally
      // GetBufferEncoding pode retornar encoding singleton — não liberar se for padrão
      if not TEncoding.IsStandardEncoding(Enc) then Enc.Free;
    end;
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoConversaoEncoding — converter arquivo de uma encoding para outra
// ---------------------------------------------------------------------------

procedure DemoConversaoEncoding;
const
  ARQ_IN  = 'input_utf8.txt';
  ARQ_OUT = 'output_utf16.txt';
var SR: TStreamReader;
    SW: TStreamWriter;
    L:  string;
begin
  // Criar arquivo UTF-8 de origem
  var SW1 := TStreamWriter.Create(ARQ_IN, False, TEncoding.UTF8);
  try
    SW1.WriteLine('Conteúdo UTF-8: ação, coração, ü, ñ');
    SW1.WriteLine('Segunda linha com acentos: até, além, já');
  finally
    SW1.Free;
  end;

  // Converter UTF-8 → UTF-16
  SR := TStreamReader.Create(ARQ_IN,  TEncoding.UTF8,    True);
  SW := TStreamWriter.Create(ARQ_OUT, False, TEncoding.Unicode);
  try
    while not SR.EndOfStream do
    begin
      L := SR.ReadLine;
      SW.WriteLine(L);
    end;
    SW.Flush;
  finally
    SR.Free;
    SW.Free;
  end;

  // Verificar arquivo de saída
  var SR2 := TStreamReader.Create(ARQ_OUT, TEncoding.Unicode, True);
  try
    Writeln('Encoding saída: ', SR2.CurrentEncoding.EncodingName);
    while not SR2.EndOfStream do
      Writeln(SR2.ReadLine);
  finally
    SR2.Free;
  end;

  DeleteFile(ARQ_IN);
  DeleteFile(ARQ_OUT);
end;

// ---------------------------------------------------------------------------
// DemoBOMHandling — escrever e ler com/sem BOM
// ---------------------------------------------------------------------------

procedure DemoBOMHandling;
const
  ARQ_COM_BOM    = 'com_bom.txt';
  ARQ_SEM_BOM    = 'sem_bom.txt';
var MS:  TMemoryStream;
    SW:  TStreamWriter;
    Enc: TEncoding;
    Raw: TBytes;
begin
  // Com BOM — TStreamWriter inclui BOM por padrão ao usar TEncoding
  SW := TStreamWriter.Create(ARQ_COM_BOM, False, TEncoding.UTF8);
  try
    SW.WriteLine('Arquivo com BOM UTF-8');
  finally
    SW.Free;
  end;

  // Sem BOM — usar TStreamWriter.Create com WriteBOM=False (Delphi 10.3+)
  // Alternativa: escrever no MemoryStream sem preamble
  MS := TMemoryStream.Create;
  try
    var Bytes := TEncoding.UTF8.GetBytes('Arquivo sem BOM'#13#10);
    MS.WriteBuffer(Bytes[0], Length(Bytes));
    MS.SaveToFile(ARQ_SEM_BOM);
  finally
    MS.Free;
  end;

  // Verificar tamanhos
  Writeln('Com BOM: ', TFile.GetSize(ARQ_COM_BOM), ' bytes');
  Writeln('Sem BOM: ', TFile.GetSize(ARQ_SEM_BOM), ' bytes');
  // Com BOM é 3 bytes maior (EF BB BF)

  // Detectar BOM ao ler
  Raw := TFile.ReadAllBytes(ARQ_COM_BOM);
  var BOMLen := TEncoding.GetBufferEncoding(Raw, Enc);
  try
    Writeln('Com BOM — encoding: ', Enc.EncodingName, '  BOM bytes: ', BOMLen);
  finally
    if not TEncoding.IsStandardEncoding(Enc) then Enc.Free;
  end;

  DeleteFile(ARQ_COM_BOM);
  DeleteFile(ARQ_SEM_BOM);
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoEncodingBasico;
//   DemoStreamReaderWriter;
//   DemoDetectEncoding;
//   DemoConversaoEncoding;
//   DemoBOMHandling;
// ---------------------------------------------------------------------------

end.
