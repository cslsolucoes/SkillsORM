unit binary_io;
{
  TBinaryWriter / TBinaryReader — leitura e escrita binária tipada
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

procedure DemoBinaryWriterReader;
procedure DemoBinaryStrings;
procedure DemoBinaryRecord;
procedure DemoBinaryArray;
procedure DemoBinaryComMagicHeader;

implementation

// ---------------------------------------------------------------------------
// DemoBinaryWriterReader — tipos primitivos
// ---------------------------------------------------------------------------

procedure DemoBinaryWriterReader;
var MS: TMemoryStream;
    BW: TBinaryWriter;
    BR: TBinaryReader;
begin
  MS := TMemoryStream.Create;
  try
    // Escrita — TBinaryWriter usa Little Endian por padrão
    BW := TBinaryWriter.Create(MS, TEncoding.UTF8, True {leaveOpen});
    try
      BW.Write(True);           // 1 byte
      BW.Write(Byte(255));      // 1 byte
      BW.Write(SmallInt(-32));  // 2 bytes
      BW.Write(Integer(12345)); // 4 bytes
      BW.Write(Int64(9876543210)); // 8 bytes
      BW.Write(Single(3.14));   // 4 bytes
      BW.Write(Double(2.71828)); // 8 bytes
    finally
      BW.Free;
    end;

    Writeln('Escrito: ', MS.Size, ' bytes  (esperado: 1+1+2+4+8+4+8=28)');
    MS.Position := 0;

    // Leitura
    BR := TBinaryReader.Create(MS, TEncoding.UTF8, True);
    try
      Writeln('Boolean: ',  BR.ReadBoolean);
      Writeln('Byte: ',     BR.ReadByte);
      Writeln('SmallInt: ', BR.ReadInt16);
      Writeln('Integer: ',  BR.ReadInt32);
      Writeln('Int64: ',    BR.ReadInt64);
      Writeln('Single: ',   BR.ReadSingle:0:2);
      Writeln('Double: ',   BR.ReadDouble:0:5);
    finally
      BR.Free;
    end;
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBinaryStrings — strings com prefixo de comprimento (7-bit encoding)
// ---------------------------------------------------------------------------

procedure DemoBinaryStrings;
var MS: TMemoryStream;
    BW: TBinaryWriter;
    BR: TBinaryReader;
begin
  MS := TMemoryStream.Create;
  try
    BW := TBinaryWriter.Create(MS, TEncoding.UTF8, True);
    try
      // Write(string) escreve comprimento como 7-bit encoded int + bytes UTF-8
      BW.Write('Olá, Mundo!');
      BW.Write('Delphi Streams');
      BW.Write(string(''));  // string vazia
      BW.Write('ação coração ü ñ ê');  // acentos
    finally
      BW.Free;
    end;

    Writeln('Stream Size: ', MS.Size);
    MS.Position := 0;

    BR := TBinaryReader.Create(MS, TEncoding.UTF8, True);
    try
      Writeln('S1: ', BR.ReadString);
      Writeln('S2: ', BR.ReadString);
      Writeln('S3 (empty): "', BR.ReadString, '"');
      Writeln('S4 (acentos): ', BR.ReadString);
    finally
      BR.Free;
    end;
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBinaryRecord — serialização manual de record
// ---------------------------------------------------------------------------

type
  TCliente = record
    Id:     Integer;
    Nome:   string;
    Saldo:  Double;
    Ativo:  Boolean;
    DataCad: TDateTime;
  end;

procedure SerializarCliente(BW: TBinaryWriter; const C: TCliente);
begin
  BW.Write(C.Id);
  BW.Write(C.Nome);
  BW.Write(C.Saldo);
  BW.Write(C.Ativo);
  BW.Write(C.DataCad);
end;

procedure DeserializarCliente(BR: TBinaryReader; out C: TCliente);
begin
  C.Id     := BR.ReadInt32;
  C.Nome   := BR.ReadString;
  C.Saldo  := BR.ReadDouble;
  C.Ativo  := BR.ReadBoolean;
  C.DataCad := BR.ReadDouble;  // TDateTime = Double
end;

procedure DemoBinaryRecord;
var MS:      TMemoryStream;
    BW:      TBinaryWriter;
    BR:      TBinaryReader;
    C1, C2:  TCliente;
    NClientes, I: Integer;
begin
  // Criar clientes
  C1.Id := 1; C1.Nome := 'Alice'; C1.Saldo := 1500.50;
  C1.Ativo := True;  C1.DataCad := EncodeDate(2024, 1, 15);

  C2.Id := 2; C2.Nome := 'Bob';   C2.Saldo := 800.00;
  C2.Ativo := False; C2.DataCad := EncodeDate(2023, 6, 20);

  MS := TMemoryStream.Create;
  try
    BW := TBinaryWriter.Create(MS, TEncoding.UTF8, True);
    try
      // Escrever número de registros primeiro
      NClientes := 2;
      BW.Write(NClientes);
      SerializarCliente(BW, C1);
      SerializarCliente(BW, C2);
    finally
      BW.Free;
    end;

    Writeln('Serializado: ', MS.Size, ' bytes');
    MS.Position := 0;

    BR := TBinaryReader.Create(MS, TEncoding.UTF8, True);
    try
      NClientes := BR.ReadInt32;
      Writeln('NClientes: ', NClientes);
      for I := 1 to NClientes do
      begin
        var C: TCliente;
        DeserializarCliente(BR, C);
        Writeln(Format('Id=%d Nome=%s Saldo=%.2f Ativo=%s Data=%s',
          [C.Id, C.Nome, C.Saldo, BoolToStr(C.Ativo, True),
           DateToStr(C.DataCad)]));
      end;
    finally
      BR.Free;
    end;
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBinaryArray — arrays de bytes e primitivos
// ---------------------------------------------------------------------------

procedure DemoBinaryArray;
var MS:    TMemoryStream;
    BW:    TBinaryWriter;
    BR:    TBinaryReader;
    Dados: TBytes;
    I:     Integer;
begin
  MS := TMemoryStream.Create;
  try
    BW := TBinaryWriter.Create(MS, TEncoding.UTF8, True);
    try
      // Escrever TBytes (prefixado com tamanho Int32)
      Dados := TBytes.Create(10, 20, 30, 40, 50);
      BW.Write(Integer(Length(Dados)));
      BW.Write(Dados);

      // Escrever array de inteiros
      var Ints: TArray<Integer> := [100, 200, 300, 400];
      BW.Write(Integer(Length(Ints)));
      for I := 0 to High(Ints) do
        BW.Write(Ints[I]);
    finally
      BW.Free;
    end;

    MS.Position := 0;
    BR := TBinaryReader.Create(MS, TEncoding.UTF8, True);
    try
      // Ler TBytes
      var Len := BR.ReadInt32;
      Dados   := BR.ReadBytes(Len);
      Write('Bytes: ');
      for I := 0 to High(Dados) do Write(Dados[I], ' ');
      Writeln;

      // Ler array de inteiros
      Len := BR.ReadInt32;
      Write('Ints: ');
      for I := 0 to Len - 1 do Write(BR.ReadInt32, ' ');
      Writeln;
    finally
      BR.Free;
    end;
  finally
    MS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// DemoBinaryComMagicHeader — cabeçalho mágico + versão para validação
// ---------------------------------------------------------------------------

const
  MAGIC: array[0..3] of AnsiChar = ('D','B','I','N');
  FILE_VERSION = 2;

procedure DemoBinaryComMagicHeader;
const ARQ = 'dados.dbin';
var FS: TFileStream;
    BW: TBinaryWriter;
    BR: TBinaryReader;
    MagicRead: array[0..3] of AnsiChar;
    Versao: Integer;
begin
  // Escrever
  FS := TFileStream.Create(ARQ, fmCreate);
  try
    BW := TBinaryWriter.Create(FS, TEncoding.UTF8, True);
    try
      // Cabeçalho: magic + versão
      BW.Write(Byte(Ord(MAGIC[0])));
      BW.Write(Byte(Ord(MAGIC[1])));
      BW.Write(Byte(Ord(MAGIC[2])));
      BW.Write(Byte(Ord(MAGIC[3])));
      BW.Write(FILE_VERSION);

      // Dados
      BW.Write('Registro de teste');
      BW.Write(Integer(42));
      BW.Write(Double(9.99));
    finally
      BW.Free;
    end;
    Writeln('Arquivo criado: ', ARQ, '  Size=', FS.Size);
  finally
    FS.Free;
  end;

  // Ler e validar
  FS := TFileStream.Create(ARQ, fmOpenRead or fmShareDenyNone);
  try
    BR := TBinaryReader.Create(FS, TEncoding.UTF8, True);
    try
      // Validar magic
      MagicRead[0] := AnsiChar(BR.ReadByte);
      MagicRead[1] := AnsiChar(BR.ReadByte);
      MagicRead[2] := AnsiChar(BR.ReadByte);
      MagicRead[3] := AnsiChar(BR.ReadByte);

      if (MagicRead[0] <> MAGIC[0]) or (MagicRead[1] <> MAGIC[1]) or
         (MagicRead[2] <> MAGIC[2]) or (MagicRead[3] <> MAGIC[3]) then
        raise EInvalidOperation.Create('Arquivo inválido — magic incorreto');

      Versao := BR.ReadInt32;
      Writeln('Versão do arquivo: ', Versao);
      if Versao > FILE_VERSION then
        raise ENotSupportedException.Create('Versão não suportada');

      Writeln('Dados: ', BR.ReadString);
      Writeln('Int:   ', BR.ReadInt32);
      Writeln('Double:', BR.ReadDouble:0:2);
    finally
      BR.Free;
    end;
  finally
    FS.Free;
  end;

  DeleteFile(ARQ);
end;

// ---------------------------------------------------------------------------
// USO:
//   DemoBinaryWriterReader;
//   DemoBinaryStrings;
//   DemoBinaryRecord;
//   DemoBinaryArray;
//   DemoBinaryComMagicHeader;
// ---------------------------------------------------------------------------

end.
