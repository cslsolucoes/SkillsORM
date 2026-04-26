unit observer;
{
  Observer Pattern em Delphi — IObserver/ISubject com multicast
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections, System.SyncObjs, System.Rtti;

// ---------------------------------------------------------------------------
// Interface Observer
// ---------------------------------------------------------------------------
type
  IObserver = interface
  ['{OB000001-0000-0000-0000-000000000001}']
    procedure Update(const AEvento: string; const ADados: TValue);
    function  GetId: string;
    property Id: string read GetId;
  end;

// ---------------------------------------------------------------------------
// Interface Subject
// ---------------------------------------------------------------------------
  ISubject = interface
  ['{OB000002-0000-0000-0000-000000000002}']
    procedure Inscrever(AObs: IObserver);
    procedure Desinscrever(AObs: IObserver);
    procedure Notificar(const AEvento: string; const ADados: TValue);
  end;

// ---------------------------------------------------------------------------
// Base abstrata para subjects — reutilizável
// ---------------------------------------------------------------------------
type
  TSubjectBase = class(TInterfacedObject, ISubject)
  private
    FObservadores: TList<IObserver>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Inscrever(AObs: IObserver);
    procedure Desinscrever(AObs: IObserver);
    procedure Notificar(const AEvento: string; const ADados: TValue);
  end;

// ---------------------------------------------------------------------------
// Subject concreto 1 — TContaBancaria
// ---------------------------------------------------------------------------
type
  TContaBancaria = class(TSubjectBase)
  private
    FNumero: string;
    FSaldo:  Currency;
  public
    constructor Create(const ANumero: string; ASaldoInicial: Currency);
    procedure Depositar(AValor: Currency);
    procedure Sacar(AValor: Currency);
    function  ObterSaldo: Currency;
    property Numero: string read FNumero;
  end;

// ---------------------------------------------------------------------------
// Subject concreto 2 — TEstoque (modelo com propriedade observável)
// ---------------------------------------------------------------------------
type
  TEstoque = class(TSubjectBase)
  private
    FProduto:    string;
    FQuantidade: Integer;
    procedure SetQuantidade(AVal: Integer);
  public
    constructor Create(const AProduto: string; AQtd: Integer);
    property Produto: string read FProduto;
    property Quantidade: Integer read FQuantidade write SetQuantidade;
  end;

// ---------------------------------------------------------------------------
// Observers concretos
// ---------------------------------------------------------------------------
type
  TLogObserver = class(TInterfacedObject, IObserver)
  private
    FNome: string;
    FLog:  TStringList;
  public
    constructor Create(const ANome: string);
    destructor Destroy; override;
    procedure Update(const AEvento: string; const ADados: TValue);
    function  GetId: string;
    function  ObterLog: string;
  end;

  TAlertaObserver = class(TInterfacedObject, IObserver)
  private
    FLimite: Currency;
  public
    constructor Create(ALimite: Currency);
    procedure Update(const AEvento: string; const ADados: TValue);
    function  GetId: string;
  end;

  TEmailObserver = class(TInterfacedObject, IObserver)
  private
    FDestinatario: string;
  public
    constructor Create(const ADestinatario: string);
    procedure Update(const AEvento: string; const ADados: TValue);
    function  GetId: string;
  end;

  // Observer com lambda — sem criar classe dedicada
  TLambdaObserver = class(TInterfacedObject, IObserver)
  private
    FId:      string;
    FHandler: reference to procedure(const AEvt: string; const ADados: TValue);
  public
    constructor Create(const AId: string;
      AHandler: reference to procedure(const AEvt: string; const ADados: TValue));
    procedure Update(const AEvento: string; const ADados: TValue);
    function  GetId: string;
  end;

implementation

// ---------------------------------------------------------------------------
// TSubjectBase
// ---------------------------------------------------------------------------

constructor TSubjectBase.Create;
begin
  inherited Create;
  FObservadores := TList<IObserver>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TSubjectBase.Destroy;
begin FObservadores.Free; FLock.Free; inherited; end;

procedure TSubjectBase.Inscrever(AObs: IObserver);
begin
  FLock.Enter;
  try
    if FObservadores.IndexOf(AObs) < 0 then
      FObservadores.Add(AObs);
  finally FLock.Leave; end;
end;

procedure TSubjectBase.Desinscrever(AObs: IObserver);
begin
  FLock.Enter;
  try FObservadores.Remove(AObs);
  finally FLock.Leave; end;
end;

procedure TSubjectBase.Notificar(const AEvento: string; const ADados: TValue);
var Copia: TArray<IObserver>;
    I: Integer;
    Obs: IObserver;
begin
  // Copiar lista para notificar fora do lock (evitar deadlock se observer chamar Inscrever)
  FLock.Enter;
  try
    SetLength(Copia, FObservadores.Count);
    for I := 0 to FObservadores.Count - 1 do
      Copia[I] := FObservadores[I];
  finally FLock.Leave; end;

  for Obs in Copia do
    Obs.Update(AEvento, ADados);
end;

// ---------------------------------------------------------------------------
// TContaBancaria
// ---------------------------------------------------------------------------

constructor TContaBancaria.Create(const ANumero: string; ASaldoInicial: Currency);
begin inherited Create; FNumero := ANumero; FSaldo := ASaldoInicial; end;

procedure TContaBancaria.Depositar(AValor: Currency);
begin
  FSaldo := FSaldo + AValor;
  Notificar('deposito', TValue.From<Currency>(AValor));
  Notificar('saldo_atualizado', TValue.From<Currency>(FSaldo));
end;

procedure TContaBancaria.Sacar(AValor: Currency);
begin
  if AValor > FSaldo then
    raise EInvalidOperation.CreateFmt('Saldo insuficiente (%.2f < %.2f)', [FSaldo, AValor]);
  FSaldo := FSaldo - AValor;
  Notificar('saque', TValue.From<Currency>(AValor));
  Notificar('saldo_atualizado', TValue.From<Currency>(FSaldo));
end;

function TContaBancaria.ObterSaldo: Currency;
begin Result := FSaldo; end;

// ---------------------------------------------------------------------------
// TEstoque
// ---------------------------------------------------------------------------

constructor TEstoque.Create(const AProduto: string; AQtd: Integer);
begin inherited Create; FProduto := AProduto; FQuantidade := AQtd; end;

procedure TEstoque.SetQuantidade(AVal: Integer);
var Anterior: Integer;
begin
  Anterior := FQuantidade;
  FQuantidade := AVal;
  Notificar('quantidade_mudou', TValue.From<Integer>(AVal));
  if (Anterior > 0) and (AVal <= 0) then
    Notificar('estoque_zerado', TValue.From<string>(FProduto));
  if AVal < 5 then
    Notificar('estoque_critico', TValue.From<Integer>(AVal));
end;

// ---------------------------------------------------------------------------
// TLogObserver
// ---------------------------------------------------------------------------

constructor TLogObserver.Create(const ANome: string);
begin inherited Create; FNome := ANome; FLog := TStringList.Create; end;

destructor TLogObserver.Destroy;
begin FLog.Free; inherited; end;

procedure TLogObserver.Update(const AEvento: string; const ADados: TValue);
begin
  FLog.Add(Format('[%s] %s = %s',
    [FormatDateTime('hh:nn:ss', Now), AEvento, ADados.ToString]));
end;

function TLogObserver.GetId: string;      begin Result := 'log:' + FNome; end;
function TLogObserver.ObterLog: string;   begin Result := FLog.Text; end;

// ---------------------------------------------------------------------------
// TAlertaObserver
// ---------------------------------------------------------------------------

constructor TAlertaObserver.Create(ALimite: Currency);
begin inherited Create; FLimite := ALimite; end;

procedure TAlertaObserver.Update(const AEvento: string; const ADados: TValue);
begin
  if AEvento = 'saldo_atualizado' then
  begin
    var Saldo := ADados.AsType<Currency>;
    if Saldo < FLimite then
      Writeln(Format('*** ALERTA: Saldo R$%.2f abaixo do limite R$%.2f ***',
        [Saldo, FLimite]));
  end;
end;

function TAlertaObserver.GetId: string;
begin Result := Format('alerta:%.2f', [FLimite]); end;

// ---------------------------------------------------------------------------
// TEmailObserver
// ---------------------------------------------------------------------------

constructor TEmailObserver.Create(const ADestinatario: string);
begin inherited Create; FDestinatario := ADestinatario; end;

procedure TEmailObserver.Update(const AEvento: string; const ADados: TValue);
begin
  if AEvento = 'estoque_critico' then
    Writeln(Format('[Email→%s] Estoque crítico: %s unidades',
      [FDestinatario, ADados.ToString]));
end;

function TEmailObserver.GetId: string;
begin Result := 'email:' + FDestinatario; end;

// ---------------------------------------------------------------------------
// TLambdaObserver
// ---------------------------------------------------------------------------

constructor TLambdaObserver.Create(const AId: string;
  AHandler: reference to procedure(const AEvt: string; const ADados: TValue));
begin inherited Create; FId := AId; FHandler := AHandler; end;

procedure TLambdaObserver.Update(const AEvento: string; const ADados: TValue);
begin FHandler(AEvento, ADados); end;

function TLambdaObserver.GetId: string;
begin Result := FId; end;

// ---------------------------------------------------------------------------
// USO:
//   // Conta bancária com observers
//   var Conta := TContaBancaria.Create('001-001', 1000);
//   var Log   := TLogObserver.Create('auditoria');
//   var Alert := TAlertaObserver.Create(200);
//
//   Conta.Inscrever(Log);
//   Conta.Inscrever(Alert);
//
//   Conta.Depositar(500);    // notifica 'deposito' e 'saldo_atualizado'
//   Conta.Sacar(1400);       // notifica 'saque' + dispara alerta (saldo=100 < 200)
//   Writeln(Log.ObterLog);
//
//   // Lambda observer — sem nova classe
//   Conta.Inscrever(TLambdaObserver.Create('sms',
//     procedure(const AEvt: string; const ADados: TValue)
//     begin
//       if AEvt = 'saldo_atualizado' then
//         Writeln('[SMS] Novo saldo: R$', ADados.ToString);
//     end));
//
//   // Estoque com alertas
//   var Est := TEstoque.Create('Caneta', 10);
//   Est.Inscrever(TLambdaObserver.Create('dashboard',
//     procedure(const AEvt: string; const ADados: TValue)
//     begin Writeln('[Dashboard] ', AEvt, ': ', ADados.ToString); end));
//   Est.Quantidade := 3;  // dispara quantidade_mudou + estoque_critico
// ---------------------------------------------------------------------------

end.
