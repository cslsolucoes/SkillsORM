unit TEMPLATE_decorator_chain;
{
  TEMPLATE: Cadeia de Decorators com interface comum
  ──────────────────────────────────────────────────
  Substituir:
    IServico        → interface do componente
    TServicoBase    → implementação concreta base
    TDecorador      → base abstrata dos decoradores
    TDecorador_X/Y  → decoradores concretos
    Execute()       → método(s) da interface
  ──────────────────────────────────────────────────
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// 1. Interface do componente — MESMO contrato para base e decoradores
// ---------------------------------------------------------------------------
type
  IServico = interface
  ['{00000000-0000-0000-0000-000000000010}']  // gerar novo GUID
    function Execute(const AInput: string): string;
    procedure Processar(const AMsg: string);
  end;

// ---------------------------------------------------------------------------
// 2. Componente base concreto
// ---------------------------------------------------------------------------
type
  TServicoBase = class(TInterfacedObject, IServico)
  public
    function Execute(const AInput: string): string;
    procedure Processar(const AMsg: string);
  end;

// ---------------------------------------------------------------------------
// 3. Base abstrata dos decoradores — delega para FInner
//    Todos os decoradores herdam daqui
// ---------------------------------------------------------------------------
type
  TDecorador = class abstract(TInterfacedObject, IServico)
  protected
    FInner: IServico;
  public
    constructor Create(AInner: IServico);
    // Delegação padrão — override apenas no que adiciona comportamento
    function Execute(const AInput: string): string; virtual;
    procedure Processar(const AMsg: string); virtual;
  end;

// ---------------------------------------------------------------------------
// 4. Decoradores concretos — cada um adiciona UMA responsabilidade
// ---------------------------------------------------------------------------
type
  // Decorador A: adiciona prefixo/contexto
  TDecoradorContexto = class(TDecorador)
  private
    FContexto: string;
  public
    constructor Create(AInner: IServico; const AContexto: string);
    function Execute(const AInput: string): string; override;
    procedure Processar(const AMsg: string); override;
  end;

  // Decorador B: adiciona log
  TDecoradorLog = class(TDecorador)
  private
    FLog: TStringList;
  public
    constructor Create(AInner: IServico);
    destructor Destroy; override;
    function Execute(const AInput: string): string; override;
    procedure Processar(const AMsg: string); override;
    function ObterLog: string;
  end;

  // Decorador C: adiciona retry automático
  TDecoradorRetry = class(TDecorador)
  private
    FMaxTentativas: Integer;
  public
    constructor Create(AInner: IServico; AMaxTentativas: Integer = 3);
    function Execute(const AInput: string): string; override;
  end;

// ---------------------------------------------------------------------------
// 5. Factory fluente para construir cadeia
// ---------------------------------------------------------------------------
function ServicoPara(ABase: IServico): IServico;
function ComContexto(AServico: IServico; const ACtx: string): IServico;
function ComLog(AServico: IServico): TDecoradorLog;
function ComRetry(AServico: IServico; ATentativas: Integer = 3): IServico;

implementation

// ---------------------------------------------------------------------------
// TServicoBase
// ---------------------------------------------------------------------------

function TServicoBase.Execute(const AInput: string): string;
begin Result := 'Resultado(' + AInput + ')'; end;

procedure TServicoBase.Processar(const AMsg: string);
begin Writeln('[Base] Processando: ', AMsg); end;

// ---------------------------------------------------------------------------
// TDecorador — base abstrata
// ---------------------------------------------------------------------------

constructor TDecorador.Create(AInner: IServico);
begin inherited Create; FInner := AInner; end;

function TDecorador.Execute(const AInput: string): string;
begin Result := FInner.Execute(AInput); end;  // delegação padrão

procedure TDecorador.Processar(const AMsg: string);
begin FInner.Processar(AMsg); end;  // delegação padrão

// ---------------------------------------------------------------------------
// TDecoradorContexto
// ---------------------------------------------------------------------------

constructor TDecoradorContexto.Create(AInner: IServico; const AContexto: string);
begin inherited Create(AInner); FContexto := AContexto; end;

function TDecoradorContexto.Execute(const AInput: string): string;
begin Result := FInner.Execute('[' + FContexto + '] ' + AInput); end;

procedure TDecoradorContexto.Processar(const AMsg: string);
begin FInner.Processar('[' + FContexto + '] ' + AMsg); end;

// ---------------------------------------------------------------------------
// TDecoradorLog
// ---------------------------------------------------------------------------

constructor TDecoradorLog.Create(AInner: IServico);
begin inherited Create(AInner); FLog := TStringList.Create; end;

destructor TDecoradorLog.Destroy;
begin FLog.Free; inherited; end;

function TDecoradorLog.Execute(const AInput: string): string;
begin
  FLog.Add('Execute in: ' + AInput);
  Result := FInner.Execute(AInput);
  FLog.Add('Execute out: ' + Result);
end;

procedure TDecoradorLog.Processar(const AMsg: string);
begin
  FLog.Add('Processar: ' + AMsg);
  FInner.Processar(AMsg);
end;

function TDecoradorLog.ObterLog: string;
begin Result := FLog.Text; end;

// ---------------------------------------------------------------------------
// TDecoradorRetry
// ---------------------------------------------------------------------------

constructor TDecoradorRetry.Create(AInner: IServico; AMaxTentativas: Integer);
begin inherited Create(AInner); FMaxTentativas := AMaxTentativas; end;

function TDecoradorRetry.Execute(const AInput: string): string;
var Tentativa: Integer;
begin
  for Tentativa := 1 to FMaxTentativas do
  begin
    try
      Result := FInner.Execute(AInput);
      Exit;  // sucesso
    except
      on E: Exception do
      begin
        if Tentativa = FMaxTentativas then raise;
        Writeln(Format('[Retry] Tentativa %d/%d falhou: %s',
          [Tentativa, FMaxTentativas, E.Message]));
      end;
    end;
  end;
end;

// ---------------------------------------------------------------------------
// Factory fluente
// ---------------------------------------------------------------------------

function ServicoPara(ABase: IServico): IServico;
begin Result := ABase; end;

function ComContexto(AServico: IServico; const ACtx: string): IServico;
begin Result := TDecoradorContexto.Create(AServico, ACtx); end;

function ComLog(AServico: IServico): TDecoradorLog;
begin Result := TDecoradorLog.Create(AServico); end;

function ComRetry(AServico: IServico; ATentativas: Integer): IServico;
begin Result := TDecoradorRetry.Create(AServico, ATentativas); end;

// ---------------------------------------------------------------------------
// COMO USAR ESTE TEMPLATE
//
// 1. Renomeie IServico, TServicoBase e os decoradores.
// 2. Cada decorador adiciona UM aspecto — não misture responsabilidades.
// 3. Delegação padrão em TDecorador garante que métodos não sobrepostos
//    passam transparentemente ao inner.
//
// Encadeamento básico:
//   var S: IServico := ComRetry(
//     ComContexto(
//       TServicoBase.Create, 'API'),
//     3);
//   Writeln(S.Execute('dados'));
//
// Com log capturado:
//   var Logger := ComLog(TServicoBase.Create);
//   var S: IServico := ComContexto(Logger, 'REQ');
//   S.Execute('payload');
//   Writeln(Logger.ObterLog);
//
// Fluent:
//   var S := ServicoPara(TServicoBase.Create);
//   S := ComContexto(S, 'job-1');
//   S := ComRetry(S, 5);
//   S.Processar('tarefa');
// ---------------------------------------------------------------------------

end.
