unit singleton;
{
  Singleton em Delphi — Double-Checked Locking thread-safe
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.SyncObjs, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Singleton genérico thread-safe — base reutilizável
// ---------------------------------------------------------------------------
type
  TSingleton<T: class, constructor> = class
  private
    class var FInstancia: T;
    class var FLock: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance: T;
    class procedure ResetInstance;  // uso em testes apenas
  end;

// ---------------------------------------------------------------------------
// Aplicação concreta 1 — TConfiguracao (singleton de configurações)
// ---------------------------------------------------------------------------
type
  TConfiguracao = class
  private
    FValores: TDictionary<string, string>;
    FArquivo: string;
    constructor CreateInternal;
    class var FInstancia: TConfiguracao;
    class var FLock: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetInstance: TConfiguracao;
    procedure Carregar(const AArquivo: string);
    procedure Salvar;
    function  Get(const AChave: string; const APadrao: string = ''): string;
    procedure Put(const AChave, AValor: string);
    function  GetAsInteger(const AChave: string; APadrao: Integer = 0): Integer;
    function  GetAsBoolean(const AChave: string; APadrao: Boolean = False): Boolean;
  end;

// ---------------------------------------------------------------------------
// Aplicação concreta 2 — TEventBus simples (singleton de pub/sub)
// ---------------------------------------------------------------------------
type
  TEventHandler = reference to procedure(const AEvento: string; const ADados: string);

  TEventBusSingleton = class
  private
    FSubscribers: TDictionary<string, TList<TEventHandler>>;
    class var FInstancia: TEventBusSingleton;
    class var FLock: TCriticalSection;
    class constructor Create;
    class destructor Destroy;
    constructor CreateInternal;
  public
    class function GetInstance: TEventBusSingleton;
    procedure Subscribe(const AEvento: string; AHandler: TEventHandler);
    procedure Publish(const AEvento, ADados: string);
    procedure Clear;
    destructor Destroy; override;
  end;

implementation

// ---------------------------------------------------------------------------
// TSingleton<T>
// ---------------------------------------------------------------------------

class constructor TSingleton<T>.Create;
begin FLock := TCriticalSection.Create; end;

class destructor TSingleton<T>.Destroy;
begin
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;

class function TSingleton<T>.GetInstance: T;
begin
  if FInstancia = nil then
  begin
    FLock.Enter;
    try
      if FInstancia = nil then   // double-checked
        FInstancia := T.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;

class procedure TSingleton<T>.ResetInstance;
begin
  FLock.Enter;
  try FreeAndNil(FInstancia);
  finally FLock.Leave; end;
end;

// ---------------------------------------------------------------------------
// TConfiguracao
// ---------------------------------------------------------------------------

class constructor TConfiguracao.Create;
begin FLock := TCriticalSection.Create; end;

class destructor TConfiguracao.Destroy;
begin
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;

constructor TConfiguracao.CreateInternal;
begin
  inherited Create;
  FValores := TDictionary<string, string>.Create;
end;

class function TConfiguracao.GetInstance: TConfiguracao;
begin
  if FInstancia = nil then
  begin
    FLock.Enter;
    try
      if FInstancia = nil then
        FInstancia := TConfiguracao.CreateInternal;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;

procedure TConfiguracao.Carregar(const AArquivo: string);
begin
  FArquivo := AArquivo;
  // Simulação — em produção usaria TIniFile ou TJSONObject
  FValores.Clear;
  FValores.Add('app.nome',    'GestorERP');
  FValores.Add('app.versao',  '2.0.0');
  FValores.Add('db.host',     'localhost');
  FValores.Add('db.porta',    '5432');
  FValores.Add('debug',       'false');
  Writeln('[Config] Carregado: ', AArquivo);
end;

procedure TConfiguracao.Salvar;
begin
  Writeln('[Config] Salvo: ', FArquivo);
end;

function TConfiguracao.Get(const AChave: string; const APadrao: string): string;
begin
  if not FValores.TryGetValue(AChave, Result) then
    Result := APadrao;
end;

procedure TConfiguracao.Put(const AChave, AValor: string);
begin FValores.AddOrSetValue(AChave, AValor); end;

function TConfiguracao.GetAsInteger(const AChave: string; APadrao: Integer): Integer;
begin Result := StrToIntDef(Get(AChave), APadrao); end;

function TConfiguracao.GetAsBoolean(const AChave: string; APadrao: Boolean): Boolean;
var S: string;
begin
  S := Get(AChave).ToLower;
  if S = 'true' then Result := True
  else if S = 'false' then Result := False
  else Result := APadrao;
end;

// ---------------------------------------------------------------------------
// TEventBusSingleton
// ---------------------------------------------------------------------------

class constructor TEventBusSingleton.Create;
begin FLock := TCriticalSection.Create; end;

class destructor TEventBusSingleton.Destroy;
begin
  FreeAndNil(FInstancia);
  FreeAndNil(FLock);
end;

constructor TEventBusSingleton.CreateInternal;
begin
  inherited Create;
  FSubscribers := TDictionary<string, TList<TEventHandler>>.Create;
end;

destructor TEventBusSingleton.Destroy;
var L: TList<TEventHandler>;
begin
  for L in FSubscribers.Values do L.Free;
  FSubscribers.Free;
  inherited;
end;

class function TEventBusSingleton.GetInstance: TEventBusSingleton;
begin
  if FInstancia = nil then
  begin
    FLock.Enter;
    try
      if FInstancia = nil then
        FInstancia := TEventBusSingleton.CreateInternal;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstancia;
end;

procedure TEventBusSingleton.Subscribe(const AEvento: string; AHandler: TEventHandler);
var Lista: TList<TEventHandler>;
begin
  if not FSubscribers.TryGetValue(AEvento, Lista) then
  begin
    Lista := TList<TEventHandler>.Create;
    FSubscribers.Add(AEvento, Lista);
  end;
  Lista.Add(AHandler);
end;

procedure TEventBusSingleton.Publish(const AEvento, ADados: string);
var Lista: TList<TEventHandler>;
    H: TEventHandler;
begin
  if FSubscribers.TryGetValue(AEvento, Lista) then
    for H in Lista do H(AEvento, ADados);
end;

procedure TEventBusSingleton.Clear;
var L: TList<TEventHandler>;
begin
  for L in FSubscribers.Values do L.Free;
  FSubscribers.Clear;
end;

// ---------------------------------------------------------------------------
// USO:
//   // TSingleton<T> genérico
//   type TMinhaClasse = class
//   public
//     procedure DoSomething;
//   end;
//   var Obj := TSingleton<TMinhaClasse>.GetInstance;
//   Obj.DoSomething;
//   // segunda chamada retorna mesma instância
//   Assert(TSingleton<TMinhaClasse>.GetInstance = Obj);
//
//   // TConfiguracao singleton concreto
//   TConfiguracao.GetInstance.Carregar('app.ini');
//   Writeln(TConfiguracao.GetInstance.Get('app.nome'));  // GestorERP
//   TConfiguracao.GetInstance.Put('debug', 'true');
//   // mesma instância em qualquer parte do código:
//   Assert(TConfiguracao.GetInstance.GetAsBoolean('debug'));
//
//   // TEventBus singleton
//   TEventBusSingleton.GetInstance.Subscribe('usuario.login',
//     procedure(const AEvt, ADados: string)
//     begin Writeln('Login: ', ADados); end);
//   TEventBusSingleton.GetInstance.Publish('usuario.login', 'alice');
//   // → Login: alice
// ---------------------------------------------------------------------------

end.
