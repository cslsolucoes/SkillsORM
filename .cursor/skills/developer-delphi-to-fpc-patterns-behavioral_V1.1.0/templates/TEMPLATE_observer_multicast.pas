unit TEMPLATE_observer_multicast;
{
  TEMPLATE: Observer com lista thread-safe + lambda support
  ──────────────────────────────────────────────────────────
  Substituir:
    IObservador     → interface dos observadores
    TSubjectBase    → base do subject (pode reutilizar direto)
    TAssunto        → subject concreto com campos observáveis
    TEvento         → tipo do evento (string ou enum)
    TDados          → tipo dos dados do evento (TValue ou específico)
  ──────────────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs, System.Rtti;

// ---------------------------------------------------------------------------
// 1. Interface do observador
// ---------------------------------------------------------------------------
type
  IObservador = interface
  ['{00000000-0000-0000-0000-000000000040}']  // gerar novo GUID
    procedure OnEvento(const AEvento: string; const ADados: TValue);
    function  GetId: string;
    property Id: string read GetId;
  end;

// ---------------------------------------------------------------------------
// 2. Base do subject — thread-safe, cópia da lista antes de notificar
// ---------------------------------------------------------------------------
type
  TSubjectBase = class(TInterfacedObject)
  private
    FObservadores: TList<IObservador>;
    FLock: TCriticalSection;
  protected
    procedure Notificar(const AEvento: string; const ADados: TValue); overload;
    procedure Notificar(const AEvento: string); overload;
    procedure NotificarStr(const AEvento, ADados: string);
    procedure NotificarInt(const AEvento: string; ADados: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Inscrever(AObs: IObservador);
    procedure Desinscrever(AObs: IObservador);
    procedure DesinscreverPorId(const AId: string);
    function  TotalObservadores: Integer;
  end;

// ---------------------------------------------------------------------------
// 3. Subject concreto — adicionar campos e chamar Notificar nas mudanças
// ---------------------------------------------------------------------------
type
  TAssunto = class(TSubjectBase)
  private
    FValor:  string;
    FAtivo:  Boolean;
    procedure SetValor(const AVal: string);
    procedure SetAtivo(AVal: Boolean);
  public
    constructor Create(const AValorInicial: string = '');
    property Valor: string  read FValor  write SetValor;
    property Ativo: Boolean read FAtivo  write SetAtivo;
  end;

// ---------------------------------------------------------------------------
// 4. Observadores concretos
// ---------------------------------------------------------------------------
type
  TLogObservador = class(TInterfacedObject, IObservador)
  private
    FId:  string;
    FLog: TStringList;
  public
    constructor Create(const AId: string);
    destructor Destroy; override;
    procedure OnEvento(const AEvento: string; const ADados: TValue);
    function  GetId: string;
    function  ObterLog: string;
  end;

  // Observador inline — sem criar classe
  TLambdaObservador = class(TInterfacedObject, IObservador)
  private
    FId:      string;
    FHandler: reference to procedure(const AEvt: string; const ADados: TValue);
  public
    constructor Create(const AId: string;
      AHandler: reference to procedure(const AEvt: string; const ADados: TValue));
    procedure OnEvento(const AEvento: string; const ADados: TValue);
    function  GetId: string;
  end;

// ---------------------------------------------------------------------------
// 5. Multicast genérico — para eventos fortemente tipados
// ---------------------------------------------------------------------------
type
  TMulticastEvent<T> = class
  private
    FHandlers: TList<reference to procedure(const ADados: T)>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Subscribe(AHandler: reference to procedure(const ADados: T));
    procedure Fire(const ADados: T);
    function  Count: Integer;
  end;

implementation

// ---------------------------------------------------------------------------
// TSubjectBase
// ---------------------------------------------------------------------------

constructor TSubjectBase.Create;
begin
  inherited Create;
  FObservadores := TList<IObservador>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TSubjectBase.Destroy;
begin FObservadores.Free; FLock.Free; inherited; end;

procedure TSubjectBase.Inscrever(AObs: IObservador);
begin
  FLock.Enter;
  try if FObservadores.IndexOf(AObs) < 0 then FObservadores.Add(AObs);
  finally FLock.Leave; end;
end;

procedure TSubjectBase.Desinscrever(AObs: IObservador);
begin FLock.Enter; try FObservadores.Remove(AObs); finally FLock.Leave; end; end;

procedure TSubjectBase.DesinscreverPorId(const AId: string);
var I: Integer;
begin
  FLock.Enter;
  try
    for I := FObservadores.Count - 1 downto 0 do
      if FObservadores[I].Id = AId then FObservadores.Delete(I);
  finally FLock.Leave; end;
end;

function TSubjectBase.TotalObservadores: Integer;
begin FLock.Enter; try Result := FObservadores.Count; finally FLock.Leave; end; end;

procedure TSubjectBase.Notificar(const AEvento: string; const ADados: TValue);
var Copia: TArray<IObservador>;
    Obs: IObservador;
begin
  FLock.Enter;
  try Copia := FObservadores.ToArray;
  finally FLock.Leave; end;
  for Obs in Copia do Obs.OnEvento(AEvento, ADados);
end;

procedure TSubjectBase.Notificar(const AEvento: string);
begin Notificar(AEvento, TValue.Empty); end;

procedure TSubjectBase.NotificarStr(const AEvento, ADados: string);
begin Notificar(AEvento, TValue.From<string>(ADados)); end;

procedure TSubjectBase.NotificarInt(const AEvento: string; ADados: Integer);
begin Notificar(AEvento, TValue.From<Integer>(ADados)); end;

// ---------------------------------------------------------------------------
// TAssunto
// ---------------------------------------------------------------------------

constructor TAssunto.Create(const AValorInicial: string);
begin inherited Create; FValor := AValorInicial; FAtivo := True; end;

procedure TAssunto.SetValor(const AVal: string);
var Anterior: string;
begin
  Anterior := FValor;
  FValor   := AVal;
  if Anterior <> AVal then
    NotificarStr('valor_mudou', AVal);
end;

procedure TAssunto.SetAtivo(AVal: Boolean);
begin
  if FAtivo <> AVal then
  begin
    FAtivo := AVal;
    Notificar(IfThen(AVal, 'ativado', 'desativado'));
  end;
end;

// ---------------------------------------------------------------------------
// TLogObservador
// ---------------------------------------------------------------------------

constructor TLogObservador.Create(const AId: string);
begin inherited Create; FId := AId; FLog := TStringList.Create; end;

destructor TLogObservador.Destroy;
begin FLog.Free; inherited; end;

procedure TLogObservador.OnEvento(const AEvento: string; const ADados: TValue);
begin FLog.Add(Format('[%s] %s = %s', [FId, AEvento, ADados.ToString])); end;

function TLogObservador.GetId: string; begin Result := FId; end;
function TLogObservador.ObterLog: string; begin Result := FLog.Text; end;

// ---------------------------------------------------------------------------
// TLambdaObservador
// ---------------------------------------------------------------------------

constructor TLambdaObservador.Create(const AId: string;
  AHandler: reference to procedure(const AEvt: string; const ADados: TValue));
begin inherited Create; FId := AId; FHandler := AHandler; end;

procedure TLambdaObservador.OnEvento(const AEvento: string; const ADados: TValue);
begin FHandler(AEvento, ADados); end;

function TLambdaObservador.GetId: string; begin Result := FId; end;

// ---------------------------------------------------------------------------
// TMulticastEvent<T>
// ---------------------------------------------------------------------------

constructor TMulticastEvent<T>.Create;
begin
  inherited Create;
  FHandlers := TList<reference to procedure(const ADados: T)>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TMulticastEvent<T>.Destroy;
begin FHandlers.Free; FLock.Free; inherited; end;

procedure TMulticastEvent<T>.Subscribe(AHandler: reference to procedure(const ADados: T));
begin FLock.Enter; try FHandlers.Add(AHandler); finally FLock.Leave; end; end;

procedure TMulticastEvent<T>.Fire(const ADados: T);
var Copia: TArray<reference to procedure(const ADados: T)>;
    H: reference to procedure(const ADados: T);
begin
  FLock.Enter; try Copia := FHandlers.ToArray; finally FLock.Leave; end;
  for H in Copia do H(ADados);
end;

function TMulticastEvent<T>.Count: Integer;
begin FLock.Enter; try Result := FHandlers.Count; finally FLock.Leave; end; end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. TSubjectBase é reutilizável — herde dela para qualquer subject.
// 2. Nos setters, chame Notificar/NotificarStr/NotificarInt.
// 3. Para eventos fortemente tipados, use TMulticastEvent<T>.
//
// Observer clássico:
//   var S := TAssunto.Create('inicial');
//   var Log := TLogObservador.Create('auditoria');
//   S.Inscrever(Log);
//   S.Inscrever(TLambdaObservador.Create('dashboard',
//     procedure(const AEvt: string; const ADados: TValue)
//     begin Writeln('[Dashboard] ', AEvt, ': ', ADados.ToString); end));
//   S.Valor := 'novo_valor';   // dispara 'valor_mudou'
//   S.Ativo := False;          // dispara 'desativado'
//   Writeln(Log.ObterLog);
//
// Multicast tipado:
//   var OnSaldoMudou := TMulticastEvent<Currency>.Create;
//   OnSaldoMudou.Subscribe(procedure(V: Currency) begin FLabel.Caption := CurrToStr(V); end);
//   OnSaldoMudou.Subscribe(procedure(V: Currency) begin FGrafico.Atualizar(V); end);
//   OnSaldoMudou.Fire(1250.00);  // ambos os handlers chamados
// ---------------------------------------------------------------------------

end.
