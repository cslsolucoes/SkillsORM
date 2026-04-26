unit rtti_json_map;
{
  RTTI — Mapeamento JSON <-> objeto via RTTI + System.JSON
  Compilavel: dcc32 / dcc64
  Requer: System.JSON, System.Rtti
}

interface

uses
  System.SysUtils, System.Rtti, System.JSON, System.TypInfo;

// ---------------------------------------------------------------------------
// Atributos de mapeamento JSON
// ---------------------------------------------------------------------------
type
  TJsonPropertyAttribute = class(TCustomAttribute)
  private
    FNome: string;
  public
    constructor Create(const ANome: string);
    property Nome: string read FNome;
  end;

  TJsonIgnoreAttribute = class(TCustomAttribute);

// ---------------------------------------------------------------------------
// Classes de domínio
// ---------------------------------------------------------------------------
type
  TEndereco = class
  private
    FRua    : string;
    FCidade : string;
    FCEP    : string;
  public
    [TJsonProperty('rua')]    property Rua   : string read FRua    write FRua;
    [TJsonProperty('cidade')] property Cidade: string read FCidade write FCidade;
    [TJsonProperty('cep')]    property CEP   : string read FCEP    write FCEP;
  end;

  TUsuario = class
  private
    FId    : Integer;
    FNome  : string;
    FEmail : string;
    FSenha : string;
  public
    [TJsonProperty('id')]    property Id   : Integer read FId    write FId;
    [TJsonProperty('nome')]  property Nome : string  read FNome  write FNome;
    [TJsonProperty('email')] property Email: string  read FEmail write FEmail;
    [TJsonIgnore]            property Senha: string  read FSenha write FSenha;
  end;

// ---------------------------------------------------------------------------
// Mapper RTTI genérico
// ---------------------------------------------------------------------------
type
  TRttiJsonMapper = class
  private
    class function ObterNomeJson(AProp: TRttiProperty): string;
    class function DeveIgnorar(AProp: TRttiProperty): Boolean;
    class procedure PopularPropriedade(AInstance: TObject;
      AProp: TRttiProperty; AJson: TJSONObject);
  public
    // Objeto -> JSON
    class function Serializar(AInstance: TObject): TJSONObject;

    // JSON -> Objeto
    class procedure Deserializar(AJson: TJSONObject; AInstance: TObject);

    // Conveniência: JSON string -> objeto
    class procedure DeserializarStr(const AJsonStr: string; AInstance: TObject);

    // Conveniência: objeto -> JSON string
    class function SerializarStr(AInstance: TObject): string;
  end;

implementation

// ---------------------------------------------------------------------------
// TJsonPropertyAttribute
// ---------------------------------------------------------------------------

constructor TJsonPropertyAttribute.Create(const ANome: string);
begin inherited Create; FNome := ANome; end;

// ---------------------------------------------------------------------------
// TRttiJsonMapper
// ---------------------------------------------------------------------------

class function TRttiJsonMapper.ObterNomeJson(AProp: TRttiProperty): string;
var Attr: TCustomAttribute;
begin
  Result := AProp.Name.ToLower; // default: lowercase do nome da prop
  for Attr in AProp.GetAttributes do
    if Attr is TJsonPropertyAttribute then
    begin
      Result := (Attr as TJsonPropertyAttribute).Nome;
      Exit;
    end;
end;

class function TRttiJsonMapper.DeveIgnorar(AProp: TRttiProperty): Boolean;
var Attr: TCustomAttribute;
begin
  for Attr in AProp.GetAttributes do
    if Attr is TJsonIgnoreAttribute then
      Exit(True);
  Result := False;
end;

class function TRttiJsonMapper.Serializar(AInstance: TObject): TJSONObject;
var
  Ctx  : TRttiContext;
  Tipo : TRttiType;
  Prop : TRttiProperty;
  Val  : TValue;
  Nome : string;
begin
  Result := TJSONObject.Create;
  Ctx    := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      if DeveIgnorar(Prop) then Continue;
      Nome := ObterNomeJson(Prop);
      Val  := Prop.GetValue(AInstance);
      case Val.Kind of
        tkInteger, tkInt64:
          Result.AddPair(Nome, TJSONNumber.Create(Val.AsInt64));
        tkFloat:
          Result.AddPair(Nome, TJSONNumber.Create(Val.AsExtended));
        tkUString, tkString:
          Result.AddPair(Nome, TJSONString.Create(Val.AsString));
        tkEnumeration:
          if GetTypeData(Val.TypeInfo)^.BaseType^ = TypeInfo(Boolean) then
            Result.AddPair(Nome, TJSONBool.Create(Val.AsBoolean))
          else
            Result.AddPair(Nome, TJSONNumber.Create(Val.AsOrdinal));
        tkClass:
          if not Val.AsObject.Equals(nil) then
            Result.AddPair(Nome, Serializar(Val.AsObject))
          else
            Result.AddPair(Nome, TJSONNull.Create);
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

class procedure TRttiJsonMapper.PopularPropriedade(AInstance: TObject;
  AProp: TRttiProperty; AJson: TJSONObject);
var
  Nome  : string;
  JVal  : TJSONValue;
begin
  Nome := ObterNomeJson(AProp);
  JVal := AJson.GetValue(Nome);
  if JVal = nil then Exit;

  case AProp.PropertyType.TypeKind of
    tkInteger:
      AProp.SetValue(AInstance, TValue.From<Integer>((JVal as TJSONNumber).AsInt));
    tkInt64:
      AProp.SetValue(AInstance, TValue.From<Int64>((JVal as TJSONNumber).AsInt64));
    tkFloat:
      AProp.SetValue(AInstance, TValue.From<Double>((JVal as TJSONNumber).AsDouble));
    tkUString, tkString:
      AProp.SetValue(AInstance, TValue.From<string>(JVal.Value));
    tkEnumeration:
      if AProp.PropertyType.Handle = TypeInfo(Boolean) then
        AProp.SetValue(AInstance, TValue.From<Boolean>(JVal is TJSONTrue))
      else
        AProp.SetValue(AInstance, TValue.FromOrdinal(
          AProp.PropertyType.Handle, (JVal as TJSONNumber).AsInt));
  end;
end;

class procedure TRttiJsonMapper.Deserializar(AJson: TJSONObject; AInstance: TObject);
var
  Ctx  : TRttiContext;
  Tipo : TRttiType;
  Prop : TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      if not Prop.IsWritable then Continue;
      if DeveIgnorar(Prop) then Continue;
      PopularPropriedade(AInstance, Prop, AJson);
    end;
  finally
    Ctx.Free;
  end;
end;

class procedure TRttiJsonMapper.DeserializarStr(const AJsonStr: string;
  AInstance: TObject);
var JObj: TJSONObject;
begin
  JObj := TJSONObject.ParseJSONValue(AJsonStr) as TJSONObject;
  if JObj = nil then
    raise EArgumentException.Create('JSON inválido');
  try
    Deserializar(JObj, AInstance);
  finally
    JObj.Free;
  end;
end;

class function TRttiJsonMapper.SerializarStr(AInstance: TObject): string;
var JObj: TJSONObject;
begin
  JObj := Serializar(AInstance);
  try
    Result := JObj.ToJSON;
  finally
    JObj.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var U := TUsuario.Create;
//   U.Id    := 1;
//   U.Nome  := 'Maria';
//   U.Email := 'maria@x.com';
//   U.Senha := 'secreta';
//
//   // Serializar (Senha ignorada)
//   var JSON := TRttiJsonMapper.SerializarStr(U);
//   Writeln(JSON);
//   // {"id":1,"nome":"Maria","email":"maria@x.com"}
//
//   // Deserializar
//   var U2 := TUsuario.Create;
//   TRttiJsonMapper.DeserializarStr('{"id":2,"nome":"João","email":"j@x.com"}', U2);
//   Writeln(U2.Nome);  // João
//
//   U.Free; U2.Free;
// ---------------------------------------------------------------------------

end.
