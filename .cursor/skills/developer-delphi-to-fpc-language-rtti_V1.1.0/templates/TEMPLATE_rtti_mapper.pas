unit TEMPLATE_rtti_mapper;
{
  TEMPLATE: Mapper objeto<->record via RTTI genérico
  Uso: copie, renomeie e adapte para seus tipos.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Attribute para controle de mapeamento
// ---------------------------------------------------------------------------
type
  TMapFromAttribute = class(TCustomAttribute)
  private
    FNomeCampo: string;
  public
    constructor Create(const ANomeCampo: string);
    property NomeCampo: string read FNomeCampo;
  end;

  TMapIgnoreAttribute = class(TCustomAttribute);

// ---------------------------------------------------------------------------
// Mapper genérico bidirecional
// ---------------------------------------------------------------------------
type
  TRttiMapper = class
  private
    FCtx: TRttiContext;

    function ObterNomeCampo(AProp: TRttiProperty): string;
    function DeveIgnorar(AProp: TRttiProperty): Boolean;
    function ConverterValor(const AVal: TValue; ATargetKind: TTypeKind): TValue;
  public
    constructor Create;
    destructor Destroy; override;

    // Copiar propriedades de mesmo nome (ou mapeadas) entre dois objetos
    procedure MapearObjetos(AOrigem, ADestino: TObject);

    // Copiar propriedades de objeto para record (retorna TValue)
    function  MapearParaRecord<TRecord: record>(AOrigem: TObject): TRecord;

    // Preencher objeto a partir de dicionário de valores
    procedure MapearDicionario(ADict: TDictionary<string, TValue>;
      ADestino: TObject);

    // Exportar objeto para dicionário de valores
    function  ExportarDicionario(AOrigem: TObject): TDictionary<string, TValue>;
  end;

// ---------------------------------------------------------------------------
// Exemplo de uso: DTOs e entidades
// ---------------------------------------------------------------------------
type
  // Entidade rica com lógica de negócio
  TClienteEntity = class
  private
    FId   : Integer;
    FNome : string;
    FEmail: string;
  public
    property Id   : Integer read FId    write FId;
    property Nome : string  read FNome  write FNome;
    property Email: string  read FEmail write FEmail;
  end;

  // DTO para transferência/serialização
  TClienteDTO = class
  private
    FId       : Integer;
    FNomeComp : string;  // nome diferente
    FEmail    : string;
  public
    property Id      : Integer read FId       write FId;
    [TMapFrom('Nome')]          // mapeia de 'Nome' da entidade
    property NomeComp: string  read FNomeComp write FNomeComp;
    property Email   : string  read FEmail    write FEmail;
  end;

implementation

// ---------------------------------------------------------------------------
// TMapFromAttribute
// ---------------------------------------------------------------------------

constructor TMapFromAttribute.Create(const ANomeCampo: string);
begin inherited Create; FNomeCampo := ANomeCampo; end;

// ---------------------------------------------------------------------------
// TRttiMapper
// ---------------------------------------------------------------------------

constructor TRttiMapper.Create;
begin
  inherited Create;
  FCtx := TRttiContext.Create;
end;

destructor TRttiMapper.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TRttiMapper.ObterNomeCampo(AProp: TRttiProperty): string;
var Attr: TCustomAttribute;
begin
  Result := AProp.Name;
  for Attr in AProp.GetAttributes do
    if Attr is TMapFromAttribute then
    begin
      Result := (Attr as TMapFromAttribute).NomeCampo;
      Exit;
    end;
end;

function TRttiMapper.DeveIgnorar(AProp: TRttiProperty): Boolean;
var Attr: TCustomAttribute;
begin
  for Attr in AProp.GetAttributes do
    if Attr is TMapIgnoreAttribute then Exit(True);
  Result := False;
end;

function TRttiMapper.ConverterValor(const AVal: TValue;
  ATargetKind: TTypeKind): TValue;
begin
  Result := AVal;
  // Conversão automática string <-> número
  if (AVal.Kind in [tkUString, tkString]) and (ATargetKind = tkInteger) then
    Result := TValue.From<Integer>(StrToIntDef(AVal.AsString, 0))
  else if (AVal.Kind = tkInteger) and (ATargetKind in [tkUString, tkString]) then
    Result := TValue.From<string>(AVal.AsInteger.ToString)
  else if (AVal.Kind in [tkUString, tkString]) and (ATargetKind = tkFloat) then
    Result := TValue.From<Double>(StrToFloatDef(AVal.AsString.Replace(',','.'), 0));
end;

procedure TRttiMapper.MapearObjetos(AOrigem, ADestino: TObject);
var
  TipoOrig : TRttiType;
  TipoDest : TRttiType;
  PropDest : TRttiProperty;
  PropOrig : TRttiProperty;
  NomeCampo: string;
  Val      : TValue;
begin
  TipoOrig := FCtx.GetType(AOrigem.ClassType);
  TipoDest := FCtx.GetType(ADestino.ClassType);

  for PropDest in TipoDest.GetProperties do
  begin
    if PropDest.Visibility < mvPublic then Continue;
    if not PropDest.IsWritable then Continue;
    if DeveIgnorar(PropDest) then Continue;

    NomeCampo := ObterNomeCampo(PropDest);
    PropOrig  := TipoOrig.GetProperty(NomeCampo);
    if PropOrig = nil then Continue;

    Val := PropOrig.GetValue(AOrigem);
    Val := ConverterValor(Val, PropDest.PropertyType.TypeKind);
    PropDest.SetValue(ADestino, Val);
  end;
end;

function TRttiMapper.MapearParaRecord<TRecord>(AOrigem: TObject): TRecord;
var
  TipoOrig  : TRttiType;
  TipoRecord: TRttiType;
  FieldRec  : TRttiField;
  PropOrig  : TRttiProperty;
  Val       : TValue;
  PtrResult : Pointer;
begin
  System.FillChar(Result, SizeOf(TRecord), 0);
  TipoOrig   := FCtx.GetType(AOrigem.ClassType);
  TipoRecord := FCtx.GetType(TypeInfo(TRecord));
  PtrResult  := @Result;

  for FieldRec in TipoRecord.GetFields do
  begin
    PropOrig := TipoOrig.GetProperty(FieldRec.Name);
    if PropOrig = nil then Continue;
    Val := PropOrig.GetValue(AOrigem);
    FieldRec.SetValue(PtrResult, Val);
  end;
end;

procedure TRttiMapper.MapearDicionario(ADict: TDictionary<string, TValue>;
  ADestino: TObject);
var
  Tipo : TRttiType;
  Prop : TRttiProperty;
  Val  : TValue;
begin
  Tipo := FCtx.GetType(ADestino.ClassType);
  for Prop in Tipo.GetProperties do
  begin
    if Prop.Visibility < mvPublic then Continue;
    if not Prop.IsWritable then Continue;
    if ADict.TryGetValue(Prop.Name, Val) then
      Prop.SetValue(ADestino, ConverterValor(Val, Prop.PropertyType.TypeKind));
  end;
end;

function TRttiMapper.ExportarDicionario(AOrigem: TObject): TDictionary<string, TValue>;
var
  Tipo: TRttiType;
  Prop: TRttiProperty;
begin
  Result := TDictionary<string, TValue>.Create;
  Tipo   := FCtx.GetType(AOrigem.ClassType);
  for Prop in Tipo.GetProperties do
  begin
    if Prop.Visibility < mvPublic then Continue;
    if DeveIgnorar(Prop) then Continue;
    Result.Add(Prop.Name, Prop.GetValue(AOrigem));
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var Mapper := TRttiMapper.Create;
//   try
//     // Entidade → DTO (com mapeamento de nomes via [TMapFrom])
//     var Ent := TClienteEntity.Create;
//     Ent.Id    := 1;
//     Ent.Nome  := 'Maria';
//     Ent.Email := 'maria@x.com';
//
//     var DTO := TClienteDTO.Create;
//     Mapper.MapearObjetos(Ent, DTO);
//     Writeln(DTO.NomeComp);  // 'Maria' (mapeado de 'Nome')
//
//     // Exportar para dicionário
//     var Dict := Mapper.ExportarDicionario(Ent);
//     for var Par in Dict do
//       Writeln(Par.Key, ': ', Par.Value.ToString);
//     Dict.Free;
//
//     Ent.Free; DTO.Free;
//   finally
//     Mapper.Free;
//   end;
// ---------------------------------------------------------------------------

end.
