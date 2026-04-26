unit file_stream;
{
  TFileStream — modos de abertura, append, leitura linha a linha, grande arquivo
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

procedure DemoFileStreamEscrever;
procedure DemoFileStreamLer;
procedure DemoFileStreamAppend;
procedure DemoFileStreamLinhaALinha;
procedure DemoFileStreamGrande;

implementation

const
  ARQ_TESTE = 'demo_filestream.txt';
  ARQ_BIN   = 'demo_filestream.bin';

// ---------------------------------------------------------------------------
// DemoFileStreamEscrever — criar arquivo e escrever
// ---------------------------------------------------------------------------

procedure DemoFileStreamEscrever;
var FS:    TFileStream;
    SW:    TStreamWriter;
begin
  // fmCreate — cria ou sobrescreve
  FS := TFileStream.Create(ARQ_TESTE, fmCreate);
  try
    // Usar TStreamWriter para escrita de texto sobre qualquer TStream
    SW := TStreamWriter.Create(FS, TEncoding.UTF8);
    try
      SW.WriteLine('Linha 1 — conteúdo de teste');
      SW.WriteLine('Linha 2 — Delphi TFileStream');
      SW.WriteLine('Linha 3 — escrita com TStreamWriter');
      SW.Flush;
    finally
      SW.Free;  // NÃO libera FS — apenas fecha o writer
    end;
    Writeln('Arquivo criado: ', ARQ_TESTE, '  Size=', FS.Size);
  finally
    FS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoFileStreamLer — abrir para leitura
// ---------------------------------------------------------------------------

procedure DemoFileStreamLer;
var FS:  TFileStream;
    SR:  TStreamReader;
    Linha: string;
    NLinha: Integer;
begin
  // fmOpenRead + fmShareDenyNone — leitura compartilhada
  FS := TFileStream.Create(ARQ_TESTE, fmOpenRead or fmShareDenyNone);
  try
    Writeln('Size: ', FS.Size, ' bytes');
    SR := TStreamReader.Create(FS, TEncoding.UTF8);
    try
      NLinha := 0;
      while not SR.EndOfStream do
      begin
        Linha := SR.ReadLine;
        Inc(NLinha);
        Writeln(NLinha, ': ', Linha);
      end;
    finally
      SR.Free;
    end;
  finally
    FS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoFileStreamAppend — acrescentar ao final
// ---------------------------------------------------------------------------

procedure DemoFileStreamAppend;
var FS: TFileStream;
    SW: TStreamWriter;
begin
  // fmOpenWrite: abre para escrita
  FS := TFileStream.Create(ARQ_TESTE, fmOpenWrite or fmShareDenyWrite);
  try
    // Posiciona no final para append
    FS.Seek(0, soEnd);
    SW := TStreamWriter.Create(FS, TEncoding.UTF8);
    try
      SW.WriteLine('Linha 4 — append com fmOpenWrite+soEnd');
      SW.WriteLine('Linha 5 — última linha');
      SW.Flush;
    finally
      SW.Free;
    end;
    Writeln('Após append, Size=', FS.Size);
  finally
    FS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoFileStreamLinhaALinha — TStreamReader direto sobre arquivo
// ---------------------------------------------------------------------------

procedure DemoFileStreamLinhaALinha;
var SR:     TStreamReader;
    Linha:  string;
    Total:  Integer;
    TotalBytes: Int64;
begin
  // TStreamReader pode abrir arquivo diretamente
  SR := TStreamReader.Create(ARQ_TESTE, TEncoding.UTF8, True {detectBOM});
  try
    Total := 0;
    TotalBytes := 0;
    while not SR.EndOfStream do
    begin
      Linha := SR.ReadLine;
      Inc(Total);
      Inc(TotalBytes, Length(Linha));
    end;
    Writeln('Total de linhas: ', Total);
    Writeln('Total de chars: ', TotalBytes);

    // Voltar ao início e ler tudo de uma vez
    SR.BaseStream.Position := 0;
    SR.DiscardBufferedData;
    var Tudo := SR.ReadToEnd;
    Writeln('ReadToEnd chars: ', Length(Tudo));
  finally
    SR.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoFileStreamGrande — escrita/leitura de arquivo binário com buffer
// ---------------------------------------------------------------------------

procedure DemoFileStreamGrande;
const
  NUM_REGISTROS = 1000;
  TAM_BUF = 4096;
type
  TRegistro = record
    Id:    Integer;
    Valor: Double;
    Flag:  Boolean;
  end;
var FS:    TFileStream;
    Reg:   TRegistro;
    I:     Integer;
    Total: Int64;
begin
  // Escrever 1000 registros binários
  FS := TFileStream.Create(ARQ_BIN, fmCreate);
  try
    for I := 1 to NUM_REGISTROS do
    begin
      Reg.Id    := I;
      Reg.Valor := I * 1.5;
      Reg.Flag  := Odd(I);
      FS.WriteBuffer(Reg, SizeOf(TRegistro));
    end;
    Writeln('Escrito: ', FS.Size, ' bytes (', NUM_REGISTROS, ' registros)');
  finally
    FS.Free;
  end;

  // Ler e somar Valor com fmShareDenyNone
  FS := TFileStream.Create(ARQ_BIN, fmOpenRead or fmShareDenyNone);
  try
    Total := 0;
    I     := 0;
    while FS.Position < FS.Size do
    begin
      FS.ReadBuffer(Reg, SizeOf(TRegistro));
      Total := Total + Round(Reg.Valor);
      Inc(I);
    end;
    Writeln('Registros lidos: ', I);
    Writeln('Soma inteira de Valor: ', Total);

    // Acesso aleatório — pular para registro 500 (índice 499)
    FS.Seek(Int64(499) * SizeOf(TRegistro), soBeginning);
    FS.ReadBuffer(Reg, SizeOf(TRegistro));
    Writeln('Registro 500: Id=', Reg.Id, ' Valor=', Reg.Valor:0:1);
  finally
    FS.Free;
  end;

  DeleteFile(ARQ_BIN);
  DeleteFile(ARQ_TESTE);
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoFileStreamEscrever;
//   DemoFileStreamLer;
//   DemoFileStreamAppend;
//   DemoFileStreamLinhaALinha;
//   DemoFileStreamGrande;
// ---------------------------------------------------------------------------

end.
