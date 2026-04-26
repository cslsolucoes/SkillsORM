unit tstream_basico;
{
  TStream API — Read, Write, Seek, CopyFrom, Position, Size, TMemoryStream
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes;

procedure DemoMemoryStreamBasico;
procedure DemoStreamReadWrite;
procedure DemoStreamSeek;
procedure DemoCopyFrom;
procedure DemoStringStream;
procedure DemoBytesStream;

implementation

// ---------------------------------------------------------------------------
// DemoMemoryStreamBasico — TMemoryStream como buffer em memória
// ---------------------------------------------------------------------------

procedure DemoMemoryStreamBasico;
var MS: TMemoryStream;
    Dados: TBytes;
    Lido: Integer;
begin
  MS := TMemoryStream.Create;
  try
    // Escrever bytes
    Dados := TEncoding.UTF8.GetBytes('Olá, Delphi Streams!');
    MS.WriteBuffer(Dados[0], Length(Dados));

    Writeln('Position após escrita: ', MS.Position);  // aponta para o fim
    Writeln('Size: ', MS.Size);

    // Voltar ao início para leitura
    MS.Position := 0;

    // Ler de volta
    SetLength(Dados, MS.Size);
    Lido := MS.Read(Dados[0], MS.Size);
    Writeln('Bytes lidos: ', Lido);
    Writeln('Conteúdo: ', TEncoding.UTF8.GetString(Dados));

    // SaveToFile / LoadFromFile
    MS.SaveToFile('teste_stream.bin');
    Writeln('Arquivo salvo.');

    // Limpar e recarregar
    MS.Clear;
    Writeln('Após Clear, Size=', MS.Size);
    MS.LoadFromFile('teste_stream.bin');
    Writeln('Após LoadFromFile, Size=', MS.Size);

    // Limpeza
    DeleteFile('teste_stream.bin');
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStreamReadWrite — escrita/leitura de tipos primitivos
// ---------------------------------------------------------------------------

procedure DemoStreamReadWrite;
var MS: TMemoryStream;
    ValInt:   Integer;
    ValDouble: Double;
    ValBool:   Boolean;
begin
  MS := TMemoryStream.Create;
  try
    // Escrever valores
    ValInt    := 42;
    ValDouble := 3.14159;
    ValBool   := True;

    MS.Write(ValInt,    SizeOf(Integer));
    MS.Write(ValDouble, SizeOf(Double));
    MS.Write(ValBool,   SizeOf(Boolean));

    Writeln('Escrito: ', SizeOf(Integer)+SizeOf(Double)+SizeOf(Boolean), ' bytes');

    // Voltar ao início
    MS.Seek(0, soBeginning);

    // Ler de volta
    MS.Read(ValInt,    SizeOf(Integer));
    MS.Read(ValDouble, SizeOf(Double));
    MS.Read(ValBool,   SizeOf(Boolean));

    Writeln('Int: ',    ValInt);
    Writeln('Double: ', ValDouble:0:5);
    Writeln('Bool: ',   ValBool);
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStreamSeek — posicionamento com soBeginning/soCurrent/soEnd
// ---------------------------------------------------------------------------

procedure DemoStreamSeek;
var MS:  TMemoryStream;
    Buf: array[0..9] of Byte;
    I:   Integer;
    B:   Byte;
begin
  MS := TMemoryStream.Create;
  try
    // Preencher com 0..9
    for I := 0 to 9 do
    begin
      B := I;
      MS.Write(B, 1);
    end;

    // Seek absoluto do início
    MS.Seek(5, soBeginning);
    MS.Read(B, 1);
    Writeln('Seek(5, soBeginning) → Byte lido: ', B);  // 5

    // Seek relativo à posição atual (volta 2)
    MS.Seek(-2, soCurrent);
    MS.Read(B, 1);
    Writeln('Seek(-2, soCurrent) → Byte lido: ', B);   // 4

    // Seek do final (último byte)
    MS.Seek(-1, soEnd);
    MS.Read(B, 1);
    Writeln('Seek(-1, soEnd) → Byte lido: ', B);        // 9

    // Position como atalho para Seek absoluto
    MS.Position := 0;
    Writeln('Position=0, posição atual: ', MS.Position);

    Writeln('Size total: ', MS.Size);
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoCopyFrom — copiar entre streams
// ---------------------------------------------------------------------------

procedure DemoCopyFrom;
var Origem:  TMemoryStream;
    Destino: TMemoryStream;
    Texto:   TBytes;
begin
  Origem  := TMemoryStream.Create;
  Destino := TMemoryStream.Create;
  try
    // Popular origem
    Texto := TEncoding.UTF8.GetBytes('Conteúdo a copiar — 1234567890');
    Origem.WriteBuffer(Texto[0], Length(Texto));
    Origem.Position := 0;

    // CopyFrom(Source, Count) — Count=0 copia tudo
    Destino.CopyFrom(Origem, 0);
    Writeln('Destino Size após CopyFrom: ', Destino.Size);

    // Cópia parcial — só os primeiros 10 bytes
    Origem.Position  := 0;
    Destino.Position := 0;
    Destino.Size     := 0;
    Destino.CopyFrom(Origem, 10);
    Writeln('Destino Size (parcial 10): ', Destino.Size);

    // Ler destino parcial
    Destino.Position := 0;
    SetLength(Texto, Destino.Size);
    Destino.Read(Texto[0], Destino.Size);
    Writeln('Parcial: ', TEncoding.UTF8.GetString(Texto));
  finally
    Origem.Free;
    Destino.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoStringStream — TStringStream para conteúdo texto
// ---------------------------------------------------------------------------

procedure DemoStringStream;
var SS:    TStringStream;
    Linha: string;
begin
  // TStringStream — stream sobre string (UTF-8 por padrão no Delphi moderno)
  SS := TStringStream.Create('', TEncoding.UTF8);
  try
    SS.WriteString('Linha 1'#13#10);
    SS.WriteString('Linha 2'#13#10);
    SS.WriteString('Linha 3');

    Writeln('Size: ', SS.Size);

    // Recuperar toda a string
    Writeln('DataString:');
    Writeln(SS.DataString);

    // Ler como stream normal
    SS.Position := 0;
    var Buf: TBytes;
    SetLength(Buf, SS.Size);
    SS.Read(Buf[0], SS.Size);
    Writeln('Bytes diretos: ', Length(Buf));
  finally
    SS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBytesStream — TBytesStream sobre TBytes
// ---------------------------------------------------------------------------

procedure DemoBytesStream;
var BS:    TBytesStream;
    Raw:   TBytes;
    I:     Integer;
begin
  // Inicializar com bytes existentes
  Raw := TBytes.Create(10, 20, 30, 40, 50);
  BS  := TBytesStream.Create(Raw);
  try
    Writeln('Size inicial: ', BS.Size);

    // Acessar bytes subjacentes
    Writeln('Byte[0]: ', BS.Bytes[0]);
    Writeln('Byte[4]: ', BS.Bytes[4]);

    // Adicionar mais bytes
    BS.Position := BS.Size;
    var Extra: Byte := 60;
    BS.Write(Extra, 1);
    Extra := 70;
    BS.Write(Extra, 1);
    Writeln('Size após append: ', BS.Size);

    // Converter de volta para TBytes
    Raw := BS.Bytes;
    Write('Bytes: ');
    for I := 0 to BS.Size - 1 do Write(Raw[I], ' ');
    Writeln;
  finally
    BS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoMemoryStreamBasico;
//   DemoStreamReadWrite;
//   DemoStreamSeek;
//   DemoCopyFrom;
//   DemoStringStream;
//   DemoBytesStream;
// ---------------------------------------------------------------------------

end.
