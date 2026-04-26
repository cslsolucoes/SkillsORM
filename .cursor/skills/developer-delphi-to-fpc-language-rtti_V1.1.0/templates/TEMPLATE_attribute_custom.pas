unit TEMPLATE_attribute_custom;
{
  TEMPLATE: Attribute personalizado + leitura via RTTI
  Uso: copie, renomeie e substitua ENTIDADE.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. DECLARAR ATTRIBUTE (copiar e renomear)
// ---------------------------------------------------------------------------
type
  // Substituir ATRIBUTO pelo nome desejado
  TAtributoAttribute = class(TCustomAttribute)
  private
    FValor    : string;
    FObrigatorio: Boolean;
  public
    constructor Create(const AValor: string = ''; AObrigatorio: Boolean = False);
    property Valor      : string  read FValor;
    property Obrigatorio: Boolean read FObrigatorio;
  end;

  // Attribute de marcação simples (sem parâmetros)
  TMarcadorAttribute = class(TCustomAttribute);

// ---------------------------------------------------------------------------
// 2. APLICAR NO DOMÍNIO (copiar e renomear)
// ---------------------------------------------------------------------------
type
  [TAtributo('entidades')]              // na classe
  TEntidade = class
  private
    FId   : Integer;
    FNome : string;
    FSenha: string;
  public
    [TAtributo('id', True)]             // na propriedade
    property Id   : Integer read FId    write FId;

    [TAtributo('nome', True)]
    [TMarcador]
    property Nome : string  read FNome  write FNome;

    [TMarcador]                          // só marcação
    property Senha: string  read FSenha write FSenha;
  end;

// ---------------------------------------------------------------------------
// 3. LEITOR GENÉRICO DE ATTRIBUTES
// ---------------------------------------------------------------------------
type
  TAtributoInfo = record
    NomeProp  : string;
    AtribValor: string;
    Obrigatorio: Boolean;
  end;

  TLeitorAtributo = class
  private
    FCtx: TRttiContext;
  public
    constructor Create;
    destructor Destroy; override;

    // Ler TAtributoAttribute de todas as propriedades
    function LerAtributos(AClass: TClass): TArray<TAtributoInfo>;

    // Ler attribute da CLASSE
    function LerAtributoClasse(AClass: TClass): TAtributoAttribute;

    // Verificar se propriedade tem TMarcadorAttribute
    function TemMarcador(AClass: TClass; const ANomeProp: string): Boolean;

    // Genérico: verificar se membro tem attribute de tipo T
    function TemAtribute<T: TCustomAttribute>(AMembro: TRttiMember): Boolean;
  end;

// ---------------------------------------------------------------------------
// 4. VALIDADOR BASEADO EM ATTRIBUTE
// ---------------------------------------------------------------------------
type
  TErroValidacao = record
    Campo   : string;
    Mensagem: string;
  end;

  TValidadorAtribute = class
  private
    FCtx: TRttiContext;
  public
    constructor Create;
    destructor Destroy; override;
    function Validar(AInstance: TObject): TArray<TErroValidacao>;
    function EhValido(AInstance: TObject): Boolean;
  end;

implementation

// ---------------------------------------------------------------------------
// TAtributoAttribute
// ---------------------------------------------------------------------------

constructor TAtributoAttribute.Create(const AValor: string; AObrigatorio: Boolean);
begin
  inherited Create;
  FValor      := AValor;
  FObrigatorio:= AObrigatorio;
end;

// ---------------------------------------------------------------------------
// TLeitorAtributo
// ---------------------------------------------------------------------------

constructor TLeitorAtributo.Create;
begin
  inherited Create;
  FCtx := TRttiContext.Create;
end;

destructor TLeitorAtributo.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TLeitorAtributo.LerAtributos(AClass: TClass): TArray<TAtributoInfo>;
var
  Tipo  : TRttiType;
  Prop  : TRttiProperty;
  Attr  : TCustomAttribute;
  Lista : TList<TAtributoInfo>;
  Info  : TAtributoInfo;
begin
  Lista := TList<TAtributoInfo>.Create;
  try
    Tipo := FCtx.GetType(AClass);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      for Attr in Prop.GetAttributes do
        if Attr is TAtributoAttribute then
        begin
          Info.NomeProp   := Prop.Name;
          Info.AtribValor := (Attr as TAtributoAttribute).Valor;
          Info.Obrigatorio:= (Attr as TAtributoAttribute).Obrigatorio;
          Lista.Add(Info);
        end;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function TLeitorAtributo.LerAtributoClasse(AClass: TClass): TAtributoAttribute;
var Attr: TCustomAttribute;
begin
  for Attr in FCtx.GetType(AClass).GetAttributes do
    if Attr is TAtributoAttribute then
      Exit(Attr as TAtributoAttribute);
  Result := nil;
end;

function TLeitorAtributo.TemMarcador(AClass: TClass; const ANomeProp: string): Boolean;
var
  Prop: TRttiProperty;
  Attr: TCustomAttribute;
begin
  Prop := FCtx.GetType(AClass).GetProperty(ANomeProp);
  if Prop = nil then Exit(False);
  for Attr in Prop.GetAttributes do
    if Attr is TMarcadorAttribute then Exit(True);
  Result := False;
end;

function TLeitorAtributo.TemAtribute<T>(AMembro: TRttiMember): Boolean;
var Attr: TCustomAttribute;
begin
  for Attr in AMembro.GetAttributes do
    if Attr is T then Exit(True);
  Result := False;
end;

// ---------------------------------------------------------------------------
// TValidadorAtribute
// ---------------------------------------------------------------------------

constructor TValidadorAtribute.Create;
begin
  inherited Create;
  FCtx := TRttiContext.Create;
end;

destructor TValidadorAtribute.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TValidadorAtribute.Validar(AInstance: TObject): TArray<TErroValidacao>;
var
  Tipo  : TRttiType;
  Prop  : TRttiProperty;
  Attr  : TCustomAttribute;
  Val   : TValue;
  Lista : TList<TErroValidacao>;
  Erro  : TErroValidacao;
  A     : TAtributoAttribute;
begin
  Lista := TList<TErroValidacao>.Create;
  try
    Tipo := FCtx.GetType(AInstance.ClassType);
    for Prop in Tipo.GetProperties do
    begin
      if Prop.Visibility < mvPublic then Continue;
      for Attr in Prop.GetAttributes do
        if Attr is TAtributoAttribute then
        begin
          A := Attr as TAtributoAttribute;
          if A.Obrigatorio then
          begin
            Val := Prop.GetValue(AInstance);
            if Val.IsEmpty or
               ((Val.Kind in [tkUString, tkString]) and (Val.AsString.Trim = '')) or
               ((Val.Kind = tkInteger) and (Val.AsInteger = 0)) then
            begin
              Erro.Campo    := Prop.Name;
              Erro.Mensagem := Format('%s [%s] é obrigatório', [Prop.Name, A.Valor]);
              Lista.Add(Erro);
            end;
          end;
        end;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function TValidadorAtribute.EhValido(AInstance: TObject): Boolean;
begin
  Result := Length(Validar(AInstance)) = 0;
end;

// ---------------------------------------------------------------------------
// USO:
//   var Ent := TEntidade.Create;
//   Ent.Id   := 0;      // Id = 0 → falha validação (Obrigatorio=True)
//   Ent.Nome := '';     // Nome vazio → falha validação
//
//   var Val := TValidadorAtribute.Create;
//   try
//     var Erros := Val.Validar(Ent);
//     for var E in Erros do
//       Writeln(E.Campo, ': ', E.Mensagem);
//   finally
//     Val.Free;
//   end;
//
//   // Ler atributos
//   var Leitor := TLeitorAtributo.Create;
//   try
//     var AtClasse := Leitor.LerAtributoClasse(TEntidade);
//     if AtClasse <> nil then Writeln('Tabela: ', AtClasse.Valor);
//     for var Info in Leitor.LerAtributos(TEntidade) do
//       Writeln(Info.NomeProp, ' → ', Info.AtribValor);
//   finally
//     Leitor.Free;
//   end;
//
//   Ent.Free;
// ---------------------------------------------------------------------------

end.
