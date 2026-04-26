unit rtti_auto_bind;
{
  RTTI — Auto-binding de TEdit/TLabel em formulário FMX/VCL via RTTI
  Convenção: TEdit com Name = 'edt' + NomeProp → property NomeProp
  Compilavel: dcc32 / dcc64 (comentários para FMX; adaptar para VCL se necessário)
  Requer: System.Rtti, FMX.Controls, FMX.StdCtrls (ou VCL equivalentes)
}

interface

uses
  System.SysUtils, System.Rtti, System.Classes;

// ---------------------------------------------------------------------------
// Atributos de binding
// ---------------------------------------------------------------------------
type
  // Liga uma propriedade a um campo UI pelo nome do controle
  TBindToAttribute = class(TCustomAttribute)
  private
    FNomeControle: string;
  public
    constructor Create(const ANomeControle: string);
    property NomeControle: string read FNomeControle;
  end;

  // Marca propriedade como somente exibição (UI → objeto desativado)
  TReadOnlyBindAttribute = class(TCustomAttribute);

// ---------------------------------------------------------------------------
// Engine de binding via RTTI
// ---------------------------------------------------------------------------
type
  TAutoBindEngine = class
  private
    class function ObterControle(AOwner: TComponent;
      const ANome: string): TComponent;
    class function ObterTextoControle(ACtrl: TComponent): string;
    class procedure DefinirTextoControle(ACtrl: TComponent;
      const ATexto: string);
  public
    // Preencher controles do form a partir do objeto (object → UI)
    class procedure CarregarEmForm(AOwner: TComponent; AInstance: TObject);

    // Ler controles do form e salvar no objeto (UI → object)
    class procedure SalvarDeForm(AOwner: TComponent; AInstance: TObject);

    // Limpar todos os controles ligados ao objeto
    class procedure LimparForm(AOwner: TComponent; AInstance: TObject);
  end;

// ---------------------------------------------------------------------------
// Objeto de domínio com binding declarativo
// ---------------------------------------------------------------------------
type
  TFormCliente = class
  private
    FId    : Integer;
    FNome  : string;
    FEmail : string;
    FTelefone: string;
  public
    // Sem atributo: convenção automática edt + NomeProp
    property Id      : Integer read FId      write FId;

    [TBindTo('edtNomeCompleto')]  // nome de controle explícito
    property Nome    : string  read FNome    write FNome;

    property Email   : string  read FEmail   write FEmail;
    property Telefone: string  read FTelefone write FTelefone;

    [TReadOnlyBind]
    property IdReadOnly: Integer read FId;  // só carrega, nunca salva
  end;

implementation

// ---------------------------------------------------------------------------
// TBindToAttribute
// ---------------------------------------------------------------------------

constructor TBindToAttribute.Create(const ANomeControle: string);
begin inherited Create; FNomeControle := ANomeControle; end;

// ---------------------------------------------------------------------------
// TAutoBindEngine — helpers privados
// ---------------------------------------------------------------------------

class function TAutoBindEngine.ObterControle(AOwner: TComponent;
  const ANome: string): TComponent;
begin
  Result := AOwner.FindComponent(ANome);
end;

class function TAutoBindEngine.ObterTextoControle(ACtrl: TComponent): string;
begin
  // Usa RTTI para ler prop 'Text' ou 'Caption' (FMX e VCL)
  var Ctx := TRttiContext.Create;
  try
    var Tipo := Ctx.GetType(ACtrl.ClassType);
    var PropText := Tipo.GetProperty('Text');
    if PropText <> nil then
      Exit(PropText.GetValue(ACtrl).AsString);
    var PropCaption := Tipo.GetProperty('Caption');
    if PropCaption <> nil then
      Exit(PropCaption.GetValue(ACtrl).AsString);
  finally
    Ctx.Free;
  end;
  Result := '';
end;

class procedure TAutoBindEngine.DefinirTextoControle(ACtrl: TComponent;
  const ATexto: string);
begin
  var Ctx := TRttiContext.Create;
  try
    var Tipo := Ctx.GetType(ACtrl.ClassType);
    var PropText := Tipo.GetProperty('Text');
    if PropText <> nil then
    begin
      PropText.SetValue(ACtrl, TValue.From<string>(ATexto));
      Exit;
    end;
    var PropCaption := Tipo.GetProperty('Caption');
    if PropCaption <> nil then
      PropCaption.SetValue(ACtrl, TValue.From<string>(ATexto));
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// CarregarEmForm — objeto → UI
// ---------------------------------------------------------------------------

class procedure TAutoBindEngine.CarregarEmForm(AOwner: TComponent;
  AInstance: TObject);
var
  Ctx      : TRttiContext;
  Tipo     : TRttiType;
  Prop     : TRttiProperty;
  Attr     : TCustomAttribute;
  NomeCtrl : string;
  Ctrl     : TComponent;
  Val      : TValue;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;

      // Determinar nome do controle
      NomeCtrl := 'edt' + Prop.Name; // convenção padrão
      for Attr in Prop.GetAttributes do
        if Attr is TBindToAttribute then
          NomeCtrl := (Attr as TBindToAttribute).NomeControle;

      Ctrl := ObterControle(AOwner, NomeCtrl);
      if Ctrl = nil then Continue;

      Val := Prop.GetValue(AInstance);
      DefinirTextoControle(Ctrl, Val.ToString);
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// SalvarDeForm — UI → objeto
// ---------------------------------------------------------------------------

class procedure TAutoBindEngine.SalvarDeForm(AOwner: TComponent;
  AInstance: TObject);
var
  Ctx      : TRttiContext;
  Tipo     : TRttiType;
  Prop     : TRttiProperty;
  Attr     : TCustomAttribute;
  NomeCtrl : string;
  Ctrl     : TComponent;
  Texto    : string;
  EhRO     : Boolean;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      if not Prop.IsWritable then Continue;

      EhRO     := False;
      NomeCtrl := 'edt' + Prop.Name;
      for Attr in Prop.GetAttributes do
      begin
        if Attr is TReadOnlyBindAttribute then begin EhRO := True; Break; end;
        if Attr is TBindToAttribute then
          NomeCtrl := (Attr as TBindToAttribute).NomeControle;
      end;
      if EhRO then Continue;

      Ctrl := ObterControle(AOwner, NomeCtrl);
      if Ctrl = nil then Continue;

      Texto := ObterTextoControle(Ctrl);

      case Prop.PropertyType.TypeKind of
        tkInteger : Prop.SetValue(AInstance, TValue.From<Integer>(StrToIntDef(Texto, 0)));
        tkInt64   : Prop.SetValue(AInstance, TValue.From<Int64>(StrToInt64Def(Texto, 0)));
        tkFloat   : Prop.SetValue(AInstance,
                      TValue.From<Double>(StrToFloatDef(Texto.Replace(',','.'), 0)));
        tkUString,
        tkString  : Prop.SetValue(AInstance, TValue.From<string>(Texto));
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// LimparForm
// ---------------------------------------------------------------------------

class procedure TAutoBindEngine.LimparForm(AOwner: TComponent; AInstance: TObject);
var
  Ctx      : TRttiContext;
  Tipo     : TRttiType;
  Prop     : TRttiProperty;
  Attr     : TCustomAttribute;
  NomeCtrl : string;
  Ctrl     : TComponent;
begin
  Ctx := TRttiContext.Create;
  try
    Tipo := Ctx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      NomeCtrl := 'edt' + Prop.Name;
      for Attr in Prop.GetAttributes do
        if Attr is TBindToAttribute then
          NomeCtrl := (Attr as TBindToAttribute).NomeControle;
      Ctrl := ObterControle(AOwner, NomeCtrl);
      if Ctrl <> nil then
        DefinirTextoControle(Ctrl, '');
    end;
  finally
    Ctx.Free;
  end;
end;

// ---------------------------------------------------------------------------
// USO (em um TForm / TFrame FMX):
//
//   // No form, com TEdit nomeados: edtEmail, edtTelefone, edtNomeCompleto
//   var Cliente := TFormCliente.Create;
//
//   // Carregar dados no form
//   Cliente.Id      := 1;
//   Cliente.Nome    := 'Maria';
//   Cliente.Email   := 'maria@x.com';
//   TAutoBindEngine.CarregarEmForm(Self, Cliente);
//   // → edtNomeCompleto.Text = 'Maria', edtEmail.Text = 'maria@x.com'
//
//   // Ler dados do form e salvar no objeto (no evento btnSalvar.OnClick)
//   TAutoBindEngine.SalvarDeForm(Self, Cliente);
//   // → Cliente.Nome = conteúdo de edtNomeCompleto
//
//   Cliente.Free;
// ---------------------------------------------------------------------------

end.
