unit TEMPLATE_builder_anon;
{
  TEMPLATE: Builder configurável com anonymous methods
  Uso: copie, renomeie e substitua ENTIDADE.
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Tipo de configurador (anonymous method como DSL de configuração)
// ---------------------------------------------------------------------------
type
  TConfigurador<T> = reference to procedure(AConfig: T);

// ---------------------------------------------------------------------------
// Objeto de configuração que o builder constrói
// ---------------------------------------------------------------------------
type
  TConexaoConfig = class
  public
    Host      : string;
    Porta     : Integer;
    Database  : string;
    Usuario   : string;
    Senha     : string;
    Timeout   : Integer;
    PoolSize  : Integer;
    SSL       : Boolean;
    AutoCommit: Boolean;
    constructor Create;
  end;

// ---------------------------------------------------------------------------
// Builder com anonymous methods (Fluent + Lambda config)
// ---------------------------------------------------------------------------
type
  IConexaoBuilder = interface
  ['{60000006-0000-0000-0000-000000000006}']
    // Fluent setters
    function ComHost(const AHost: string): IConexaoBuilder;
    function ComPorta(APorta: Integer): IConexaoBuilder;
    function ComDatabase(const ADB: string): IConexaoBuilder;
    function ComCredenciais(const AUser, ASenha: string): IConexaoBuilder;
    function ComTimeout(ASeconds: Integer): IConexaoBuilder;
    function ComPool(ASize: Integer): IConexaoBuilder;
    function ComSSL(AEnabled: Boolean = True): IConexaoBuilder;
    function ComAutoCommit(AEnabled: Boolean = True): IConexaoBuilder;

    // Configurador lambda (recebe TConexaoConfig diretamente)
    function Configurar(ASetup: TConfigurador<TConexaoConfig>): IConexaoBuilder;

    // Build
    function Build: TConexaoConfig;
    function BuildValidated: TConexaoConfig;  // valida antes de retornar
  end;

  TConexaoBuilder = class(TInterfacedObject, IConexaoBuilder)
  private
    FConfig: TConexaoConfig;
    procedure Validar;
  public
    constructor Create;
    destructor Destroy; override;

    function ComHost(const AHost: string): IConexaoBuilder;
    function ComPorta(APorta: Integer): IConexaoBuilder;
    function ComDatabase(const ADB: string): IConexaoBuilder;
    function ComCredenciais(const AUser, ASenha: string): IConexaoBuilder;
    function ComTimeout(ASeconds: Integer): IConexaoBuilder;
    function ComPool(ASize: Integer): IConexaoBuilder;
    function ComSSL(AEnabled: Boolean): IConexaoBuilder;
    function ComAutoCommit(AEnabled: Boolean): IConexaoBuilder;
    function Configurar(ASetup: TConfigurador<TConexaoConfig>): IConexaoBuilder;
    function Build: TConexaoConfig;
    function BuildValidated: TConexaoConfig;
  end;

// Factory
function NovoConexaoBuilder: IConexaoBuilder;

// ---------------------------------------------------------------------------
// Padrão: Builder com lista de configuradores acumulados
// ---------------------------------------------------------------------------
type
  THttpClientConfig = class
  public
    BaseURL    : string;
    TimeoutMs  : Integer;
    RetryCount : Integer;
    Headers    : TDictionary<string, string>;
    OnBeforeReq: TProc<string>;   // callback antes de cada request
    OnAfterResp: TProc<Integer>;  // callback após resposta (recebe status)
    constructor Create;
    destructor Destroy; override;
  end;

  THttpClientBuilder = class
  private
    FConfigs: TList<TConfigurador<THttpClientConfig>>;
  public
    constructor Create;
    destructor Destroy; override;

    // Acumular configuradores
    function Use(ASetup: TConfigurador<THttpClientConfig>): THttpClientBuilder;
    function Build: THttpClientConfig;
  end;

implementation

// ---------------------------------------------------------------------------
// TConexaoConfig
// ---------------------------------------------------------------------------

constructor TConexaoConfig.Create;
begin
  inherited Create;
  Porta      := 5432;
  Timeout    := 30;
  PoolSize   := 10;
  SSL        := False;
  AutoCommit := True;
end;

// ---------------------------------------------------------------------------
// TConexaoBuilder
// ---------------------------------------------------------------------------

constructor TConexaoBuilder.Create;
begin
  inherited Create;
  FConfig := TConexaoConfig.Create;
end;

destructor TConexaoBuilder.Destroy;
begin
  FConfig.Free;
  inherited;
end;

function TConexaoBuilder.ComHost(const AHost: string): IConexaoBuilder;
begin FConfig.Host := AHost; Result := Self; end;

function TConexaoBuilder.ComPorta(APorta: Integer): IConexaoBuilder;
begin FConfig.Porta := APorta; Result := Self; end;

function TConexaoBuilder.ComDatabase(const ADB: string): IConexaoBuilder;
begin FConfig.Database := ADB; Result := Self; end;

function TConexaoBuilder.ComCredenciais(const AUser, ASenha: string): IConexaoBuilder;
begin FConfig.Usuario := AUser; FConfig.Senha := ASenha; Result := Self; end;

function TConexaoBuilder.ComTimeout(ASeconds: Integer): IConexaoBuilder;
begin FConfig.Timeout := ASeconds; Result := Self; end;

function TConexaoBuilder.ComPool(ASize: Integer): IConexaoBuilder;
begin FConfig.PoolSize := ASize; Result := Self; end;

function TConexaoBuilder.ComSSL(AEnabled: Boolean): IConexaoBuilder;
begin FConfig.SSL := AEnabled; Result := Self; end;

function TConexaoBuilder.ComAutoCommit(AEnabled: Boolean): IConexaoBuilder;
begin FConfig.AutoCommit := AEnabled; Result := Self; end;

function TConexaoBuilder.Configurar(ASetup: TConfigurador<TConexaoConfig>): IConexaoBuilder;
begin
  ASetup(FConfig);  // executa o anonymous method com acesso direto ao config
  Result := Self;
end;

procedure TConexaoBuilder.Validar;
begin
  if FConfig.Host.IsEmpty     then raise EArgumentException.Create('Host obrigatório');
  if FConfig.Database.IsEmpty then raise EArgumentException.Create('Database obrigatória');
  if FConfig.Porta <= 0       then raise EArgumentException.Create('Porta inválida');
end;

function TConexaoBuilder.Build: TConexaoConfig;
var C: TConexaoConfig;
begin
  C := TConexaoConfig.Create;
  C.Host       := FConfig.Host;
  C.Porta      := FConfig.Porta;
  C.Database   := FConfig.Database;
  C.Usuario    := FConfig.Usuario;
  C.Senha      := FConfig.Senha;
  C.Timeout    := FConfig.Timeout;
  C.PoolSize   := FConfig.PoolSize;
  C.SSL        := FConfig.SSL;
  C.AutoCommit := FConfig.AutoCommit;
  Result := C;
end;

function TConexaoBuilder.BuildValidated: TConexaoConfig;
begin
  Validar;
  Result := Build;
end;

function NovoConexaoBuilder: IConexaoBuilder;
begin
  Result := TConexaoBuilder.Create;
end;

// ---------------------------------------------------------------------------
// THttpClientConfig
// ---------------------------------------------------------------------------

constructor THttpClientConfig.Create;
begin
  inherited Create;
  TimeoutMs  := 5000;
  RetryCount := 3;
  Headers    := TDictionary<string, string>.Create;
end;

destructor THttpClientConfig.Destroy;
begin
  Headers.Free;
  inherited;
end;

// ---------------------------------------------------------------------------
// THttpClientBuilder
// ---------------------------------------------------------------------------

constructor THttpClientBuilder.Create;
begin
  inherited Create;
  FConfigs := TList<TConfigurador<THttpClientConfig>>.Create;
end;

destructor THttpClientBuilder.Destroy;
begin
  FConfigs.Free;
  inherited;
end;

function THttpClientBuilder.Use(ASetup: TConfigurador<THttpClientConfig>): THttpClientBuilder;
begin
  FConfigs.Add(ASetup);
  Result := Self;
end;

function THttpClientBuilder.Build: THttpClientConfig;
var Setup: TConfigurador<THttpClientConfig>;
begin
  Result := THttpClientConfig.Create;
  for Setup in FConfigs do
    Setup(Result);
end;

// ---------------------------------------------------------------------------
// USO:
//
//   // Builder fluente clássico
//   var Config := NovoConexaoBuilder
//     .ComHost('db.empresa.com')
//     .ComPorta(5432)
//     .ComDatabase('gestordb')
//     .ComCredenciais('admin', 'senha123')
//     .ComPool(20)
//     .ComSSL
//     .BuildValidated;
//   Writeln(Config.Host);  // db.empresa.com
//   Config.Free;
//
//   // Com configurador lambda (acesso direto ao objeto config)
//   var Config2 := NovoConexaoBuilder
//     .ComHost('localhost')
//     .Configurar(procedure(C: TConexaoConfig)
//       begin
//         C.Database   := 'testdb';
//         C.AutoCommit := False;
//         C.Timeout    := 60;
//       end)
//     .Build;
//   Config2.Free;
//
//   // Builder com lista de middlewares (Use pattern)
//   var Http := THttpClientBuilder.Create;
//   Http
//     .Use(procedure(C: THttpClientConfig) begin C.BaseURL := 'https://api.x.com'; end)
//     .Use(procedure(C: THttpClientConfig) begin C.TimeoutMs := 10000; end)
//     .Use(procedure(C: THttpClientConfig) begin C.Headers.Add('Auth', 'Bearer token'); end)
//     .Use(procedure(C: THttpClientConfig)
//       begin
//         C.OnBeforeReq := procedure(URL: string) begin Writeln('→ ', URL); end;
//       end);
//   var HttpConfig := Http.Build;
//   Http.Free; HttpConfig.Free;
// ---------------------------------------------------------------------------

end.
