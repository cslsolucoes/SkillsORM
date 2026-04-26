unit TEMPLATE_binary_serializer;
{
  TEMPLATE: Serialização/deserialização binária com TBinaryWriter/Reader
  Inclui: magic header, versionamento, registro de tipos, array de registros.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Classes, System.IOUtils;

// ---------------------------------------------------------------------------
// Constantes do formato
// ---------------------------------------------------------------------------
const
  // Substitua pelos 4 bytes que identificam seu formato
  FILE_MAGIC: array[0..3] of Byte = ($4D, $59, $44, $42);  // 'MYDB'
  FILE_VERSION_CURRENT = 1;

// ---------------------------------------------------------------------------
// Tipo de dado a serializar — substitua pelos seus campos
// ---------------------------------------------------------------------------
type
  TRegistro = record
    Id:        Integer;
    Codigo:    string;
    Valor:     Double;
    Ativo:     Boolean;
    Timestamp: TDateTime;
    Tags:      TArray<string>;  // array dinâmico
  end;

// ---------------------------------------------------------------------------
// Interface do serializador
// ---------------------------------------------------------------------------
  IBinarySerializer<T> = interface
    ['{ABCDEF01-2345-6789-ABCD-EF0123456789}']
    procedure SalvarParaArquivo(const ACaminho: string; const AItens: TArray<T>);
    procedure SalvarParaStream(AStream: TStream; const AItens: TArray<T>);
    function  CarregarDeArquivo(const ACaminho: string): TArray<T>;
    function  CarregarDeStream(AStream: TStream): TArray<T>;
  end;

// ---------------------------------------------------------------------------
// Implementação
// ---------------------------------------------------------------------------
  TRegistroSerializer = class(TInterfacedObject, IBinarySerializer<TRegistro>)
  private
    procedure EscreverCabecalho(BW: TBinaryWriter);
    procedure ValidarCabecalho(BR: TBinaryReader);
    procedure EscreverRegistro(BW: TBinaryWriter; const R: TRegistro);
    procedure LerRegistro(BR: TBinaryReader; out R: TRegistro);
  public
    procedure SalvarParaArquivo(const ACaminho: string; const AItens: TArray<TRegistro>);
    procedure SalvarParaStream(AStream: TStream; const AItens: TArray<TRegistro>);
    function  CarregarDeArquivo(const ACaminho: string): TArray<TRegistro>;
    function  CarregarDeStream(AStream: TStream): TArray<TRegistro>;
  end;

function NewRegistroSerializer: IBinarySerializer<TRegistro>;

implementation

// ---------------------------------------------------------------------------
// TRegistroSerializer — cabeçalho
// ---------------------------------------------------------------------------

procedure TRegistroSerializer.EscreverCabecalho(BW: TBinaryWriter);
var I: Integer;
begin
  // Magic (4 bytes fixos)
  for I := 0 to 3 do BW.Write(FILE_MAGIC[I]);
  // Versão do formato
  BW.Write(FILE_VERSION_CURRENT);
  // Timestamp de criação
  BW.Write(Double(Now));
end;

procedure TRegistroSerializer.ValidarCabecalho(BR: TBinaryReader);
var MagicLido: array[0..3] of Byte;
    Versao:    Integer;
    I:         Integer;
begin
  for I := 0 to 3 do MagicLido[I] := BR.ReadByte;

  for I := 0 to 3 do
    if MagicLido[I] <> FILE_MAGIC[I] then
      raise EInvalidOperation.Create('Arquivo inválido: magic incorreto');

  Versao := BR.ReadInt32;
  if Versao > FILE_VERSION_CURRENT then
    raise ENotSupportedException.CreateFmt(
      'Versão %d não suportada (máx: %d)', [Versao, FILE_VERSION_CURRENT]);

  // Pular timestamp de criação
  BR.ReadDouble;
end;

// ---------------------------------------------------------------------------
// Serialização de um registro
// ---------------------------------------------------------------------------

procedure TRegistroSerializer.EscreverRegistro(BW: TBinaryWriter;
  const R: TRegistro);
var I: Integer;
begin
  BW.Write(R.Id);
  BW.Write(R.Codigo);
  BW.Write(R.Valor);
  BW.Write(R.Ativo);
  BW.Write(Double(R.Timestamp));

  // Array dinâmico: escrever contagem + itens
  BW.Write(Integer(Length(R.Tags)));
  for I := 0 to High(R.Tags) do
    BW.Write(R.Tags[I]);
end;

procedure TRegistroSerializer.LerRegistro(BR: TBinaryReader; out R: TRegistro);
var NTags, I: Integer;
begin
  R.Id        := BR.ReadInt32;
  R.Codigo    := BR.ReadString;
  R.Valor     := BR.ReadDouble;
  R.Ativo     := BR.ReadBoolean;
  R.Timestamp := BR.ReadDouble;

  NTags := BR.ReadInt32;
  SetLength(R.Tags, NTags);
  for I := 0 to NTags - 1 do
    R.Tags[I] := BR.ReadString;
end;

// ---------------------------------------------------------------------------
// Salvar
// ---------------------------------------------------------------------------

procedure TRegistroSerializer.SalvarParaStream(AStream: TStream;
  const AItens: TArray<TRegistro>);
var BW: TBinaryWriter;
    I:  Integer;
begin
  BW := TBinaryWriter.Create(AStream, TEncoding.UTF8, True {leaveOpen});
  try
    EscreverCabecalho(BW);
    // Escrever contagem de registros
    BW.Write(Integer(Length(AItens)));
    for I := 0 to High(AItens) do
      EscreverRegistro(BW, AItens[I]);
  finally
    BW.Free;
  end;
end;

procedure TRegistroSerializer.SalvarParaArquivo(const ACaminho: string;
  const AItens: TArray<TRegistro>);
var FS: TFileStream;
begin
  TDirectory.CreateDirectory(TPath.GetDirectoryName(
    TPath.GetFullPath(ACaminho)));

  FS := TFileStream.Create(ACaminho, fmCreate);
  try
    SalvarParaStream(FS, AItens);
  finally
    FS.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Carregar
// ---------------------------------------------------------------------------

function TRegistroSerializer.CarregarDeStream(
  AStream: TStream): TArray<TRegistro>;
var BR:     TBinaryReader;
    NItens, I: Integer;
begin
  BR := TBinaryReader.Create(AStream, TEncoding.UTF8, True);
  try
    ValidarCabecalho(BR);
    NItens := BR.ReadInt32;
    SetLength(Result, NItens);
    for I := 0 to NItens - 1 do
      LerRegistro(BR, Result[I]);
  finally
    BR.Free;
  end;
end;

function TRegistroSerializer.CarregarDeArquivo(
  const ACaminho: string): TArray<TRegistro>;
var FS: TFileStream;
begin
  if not TFile.Exists(ACaminho) then
    raise EFileNotFoundException.Create('Arquivo não encontrado: ' + ACaminho);

  FS := TFileStream.Create(ACaminho, fmOpenRead or fmShareDenyNone);
  try
    Result := CarregarDeStream(FS);
  finally
    FS.Free;
  end;
end;

function NewRegistroSerializer: IBinarySerializer<TRegistro>;
begin
  Result := TRegistroSerializer.Create;
end;

// ---------------------------------------------------------------------------
// Exemplo de uso (comentado — descomente para testar)
// ---------------------------------------------------------------------------
(*
procedure DemoBinarySerializer;
var Ser:   IBinarySerializer<TRegistro>;
    Itens: TArray<TRegistro>;
    R:     TRegistro;
    I:     Integer;
begin
  Ser := NewRegistroSerializer;

  // Montar dados
  SetLength(Itens, 3);
  Itens[0].Id := 1; Itens[0].Codigo := 'A001'; Itens[0].Valor := 99.99;
  Itens[0].Ativo := True; Itens[0].Timestamp := Now;
  Itens[0].Tags := ['promo', 'novo'];

  Itens[1].Id := 2; Itens[1].Codigo := 'B002'; Itens[1].Valor := 149.50;
  Itens[1].Ativo := False; Itens[1].Timestamp := Now - 1;
  Itens[1].Tags := [];

  Itens[2].Id := 3; Itens[2].Codigo := 'C003'; Itens[2].Valor := 75.00;
  Itens[2].Ativo := True; Itens[2].Timestamp := Now - 7;
  Itens[2].Tags := ['destaque'];

  // Salvar
  Ser.SalvarParaArquivo('dados.mydb', Itens);
  Writeln('Salvo: ', TFile.GetSize('dados.mydb'), ' bytes');

  // Carregar
  Itens := Ser.CarregarDeArquivo('dados.mydb');
  Writeln('Carregados: ', Length(Itens), ' registros');
  for R in Itens do
  begin
    Write(Format('Id=%d Cod=%s Val=%.2f Ativo=%s Tags=[',
      [R.Id, R.Codigo, R.Valor, BoolToStr(R.Ativo, True)]));
    for I := 0 to High(R.Tags) do
    begin
      if I > 0 then Write(',');
      Write(R.Tags[I]);
    end;
    Writeln(']');
  end;

  TFile.Delete('dados.mydb');
end;
*)

end.
