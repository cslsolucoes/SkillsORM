unit TEMPLATE_auto_inject;
{
  TEMPLATE: DI automático via RTTI + attributes
  Uso: copie, renomeie e registre seus tipos.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections, System.TypInfo;

// ---------------------------------------------------------------------------
// Attributes de DI
// ---------------------------------------------------------------------------
type
  // Marcar campo/propriedade para injeção automática
  TInjectAttribute = class(TCustomAttribute)
  private
    FNomeRegistro: string;
  public
    constructor Create(const ANomeRegistro: string = '');
    property NomeRegistro: string read FNomeRegistro;
  end;

  // Marcar classe como singleton no container
  TSingletonAttribute = class(TCustomAttribute);

  // Marcar classe como transient (nova instância a cada resolução)
  TTransientAttribute = class(TCustomAttribute);

// ---------------------------------------------------------------------------
// Container de DI leve
// ---------------------------------------------------------------------------
type
  TLifetime = (ltSingleton, ltTransient);

  TRegistro = record
    Classe  : TClass;
    Lifetime: TLifetime;
    Instance: TObject;  // só usado para ltSingleton
  end;

  TDIContainer = class
  private
    FRegistros: TDictionary<string, TRegistro>;
    FCtx      : TRttiContext;

    function ChaveDe(AInterface: PTypeInfo): string; overload;
    function ChaveDe(const ANome: string): string; overload;
    procedure InjetarPropriedades(AInstance: TObject);
    function ResolverPorChave(const AChave: string): TObject;
  public
    constructor Create;
    destructor Destroy; override;

    // Registro
    procedure Registrar(AInterface: PTypeInfo; AClasse: TClass;
      ALifetime: TLifetime = ltTransient);
    procedure RegistrarPorNome(const ANome: string; AClasse: TClass;
      ALifetime: TLifetime = ltTransient);
    procedure RegistrarInstancia(AInterface: PTypeInfo; AInstance: TObject);

    // Resolução
    function Resolver<T: IInterface>: T; overload;
    function ResolverClasse<T: class, constructor>: T; overload;
    function Resolver(AInterface: PTypeInfo): IInterface; overload;

    // Injeção em instância existente
    procedure Injetar(AInstance: TObject);
  end;

// Container global (opcional)
function Container: TDIContainer;

implementation

var
  GContainer: TDIContainer = nil;

function Container: TDIContainer;
begin
  if GContainer = nil then
    GContainer := TDIContainer.Create;
  Result := GContainer;
end;

// ---------------------------------------------------------------------------
// TInjectAttribute
// ---------------------------------------------------------------------------

constructor TInjectAttribute.Create(const ANomeRegistro: string);
begin inherited Create; FNomeRegistro := ANomeRegistro; end;

// ---------------------------------------------------------------------------
// TDIContainer
// ---------------------------------------------------------------------------

constructor TDIContainer.Create;
begin
  inherited Create;
  FRegistros := TDictionary<string, TRegistro>.Create;
  FCtx       := TRttiContext.Create;
end;

destructor TDIContainer.Destroy;
var Par: TPair<string, TRegistro>;
begin
  // Liberar singletons
  for Par in FRegistros do
    if (Par.Value.Lifetime = ltSingleton) and (Par.Value.Instance <> nil) then
      Par.Value.Instance.Free;
  FRegistros.Free;
  FCtx.Free;
  inherited;
end;

function TDIContainer.ChaveDe(AInterface: PTypeInfo): string;
begin
  Result := string(AInterface^.Name);
end;

function TDIContainer.ChaveDe(const ANome: string): string;
begin
  Result := ANome;
end;

procedure TDIContainer.Registrar(AInterface: PTypeInfo; AClasse: TClass;
  ALifetime: TLifetime);
var R: TRegistro;
begin
  R.Classe   := AClasse;
  R.Lifetime := ALifetime;
  R.Instance := nil;
  FRegistros.AddOrSetValue(ChaveDe(AInterface), R);
end;

procedure TDIContainer.RegistrarPorNome(const ANome: string; AClasse: TClass;
  ALifetime: TLifetime);
var R: TRegistro;
begin
  R.Classe   := AClasse;
  R.Lifetime := ALifetime;
  R.Instance := nil;
  FRegistros.AddOrSetValue(ChaveDe(ANome), R);
end;

procedure TDIContainer.RegistrarInstancia(AInterface: PTypeInfo; AInstance: TObject);
var R: TRegistro;
begin
  R.Classe   := AInstance.ClassType;
  R.Lifetime := ltSingleton;
  R.Instance := AInstance;
  FRegistros.AddOrSetValue(ChaveDe(AInterface), R);
end;

function TDIContainer.ResolverPorChave(const AChave: string): TObject;
var
  R: TRegistro;
begin
  if not FRegistros.TryGetValue(AChave, R) then
    raise EArgumentException.CreateFmt('Tipo "%s" não registrado no container', [AChave]);

  if (R.Lifetime = ltSingleton) and (R.Instance <> nil) then
    Exit(R.Instance);

  Result := R.Classe.Create;
  InjetarPropriedades(Result);

  if R.Lifetime = ltSingleton then
  begin
    R.Instance := Result;
    FRegistros[AChave] := R;
  end;
end;

procedure TDIContainer.InjetarPropriedades(AInstance: TObject);
var
  Tipo     : TRttiType;
  Prop     : TRttiProperty;
  Attr     : TCustomAttribute;
  Chave    : string;
  Dep      : TObject;
  InjectAt : TInjectAttribute;
begin
  Tipo := FCtx.GetType(AInstance.ClassType);
  for Prop in Tipo.GetProperties do
  begin
    if Prop.Visibility < mvPublic then Continue;
    if not Prop.IsWritable then Continue;
    InjectAt := nil;
    for Attr in Prop.GetAttributes do
      if Attr is TInjectAttribute then
      begin
        InjectAt := Attr as TInjectAttribute;
        Break;
      end;
    if InjectAt = nil then Continue;

    // Determinar chave: nome explícito ou nome do tipo da propriedade
    if InjectAt.NomeRegistro <> '' then
      Chave := InjectAt.NomeRegistro
    else if Prop.PropertyType <> nil then
      Chave := Prop.PropertyType.Name
    else
      Continue;

    try
      Dep := ResolverPorChave(Chave);
      if Prop.PropertyType.TypeKind = tkInterface then
      begin
        var Intf: IInterface;
        if Supports(Dep, IInterface, Intf) then
          Prop.SetValue(AInstance, TValue.From<IInterface>(Intf));
      end
      else
        Prop.SetValue(AInstance, TValue.From<TObject>(Dep));
    except
      // Dependência não encontrada — ignora (opcional: logar)
    end;
  end;
end;

function TDIContainer.Resolver<T>: T;
var
  Obj : TObject;
  Intf: IInterface;
begin
  Obj := ResolverPorChave(string(TypeInfo(T)^.Name));
  if Supports(Obj, GetTypeData(TypeInfo(T))^.Guid, Intf) then
    Result := T(Intf)
  else
    raise EInvalidCastException.CreateFmt('Objeto não implementa %s', [string(TypeInfo(T)^.Name)]);
end;

function TDIContainer.ResolverClasse<T>: T;
begin
  Result := T(ResolverPorChave(T.ClassName));
end;

function TDIContainer.Resolver(AInterface: PTypeInfo): IInterface;
var Obj: TObject;
begin
  Obj := ResolverPorChave(ChaveDe(AInterface));
  if not Supports(Obj, GetTypeData(AInterface)^.Guid, Result) then
    raise EInvalidCastException.Create('Cast de interface falhou');
end;

procedure TDIContainer.Injetar(AInstance: TObject);
begin
  InjetarPropriedades(AInstance);
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // 1. Declarar interfaces e implementações
//   type
//     ILogger = interface ['{GUID}'] procedure Log(const AMsg: string); end;
//     TConsoleLogger = class(TInterfacedObject, ILogger)
//       procedure Log(const AMsg: string);
//     end;
//
//     IEmailService = interface ['{GUID2}'] procedure EnviarEmail(const ATo, AMsg: string); end;
//     TSmtpService = class(TInterfacedObject, IEmailService)
//       [TInject]
//       property Logger: ILogger ...;  // injetado automaticamente
//       procedure EnviarEmail(const ATo, AMsg: string);
//     end;
//
//   // 2. Configurar container (startup)
//   Container.Registrar(TypeInfo(ILogger), TConsoleLogger, ltSingleton);
//   Container.Registrar(TypeInfo(IEmailService), TSmtpService, ltTransient);
//
//   // 3. Resolver dependência
//   var Svc := Container.Resolver<IEmailService>;
//   Svc.EnviarEmail('user@x.com', 'Olá!');
//   // Logger foi injetado automaticamente em TSmtpService
//
//   // 4. Injetar em instância existente (ex.: TForm)
//   Container.Injetar(Self);  // injeta props marcadas com [TInject]
// ---------------------------------------------------------------------------

initialization
  // Inicializar container global se necessário

finalization
  FreeAndNil(GContainer);

end.
