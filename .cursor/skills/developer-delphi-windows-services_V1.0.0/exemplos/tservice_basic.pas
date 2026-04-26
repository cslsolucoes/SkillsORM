unit uGestorERPService;

{
  Exemplo mínimo compilável de Windows Service com TService.

  Demonstra:
    - Herança de TService
    - OnStart cria TWorkerThread
    - OnStop termina e aguarda thread
    - Worker thread com loop e Terminated check
    - TEventLogger para log de erros e informações

  Para compilar:
    dcc32 GestorERPService.dpr   (Win32)
    dcc64 GestorERPService.dpr   (Win64 — recomendado para produção)

  Para instalar:
    GestorERPService.exe -install
    sc start "GestorERPService"
}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.SvcMgr;

type
  // ---------------------------------------------------------------------------
  // Thread worker — executa o trabalho real em background
  // ---------------------------------------------------------------------------
  TGestorERPWorkerThread = class(TThread)
  private
    FStopEvent: THandle;       // evento Win32 para sinalização de paragem
    FServiceRef: Pointer;      // referência ao serviço (para logging)
  protected
    procedure Execute; override;
  public
    constructor Create(AServiceRef: Pointer);
    destructor Destroy; override;
    procedure RequestStop;     // sinaliza paragem via evento (mais rápido que Terminated)
  end;

  // ---------------------------------------------------------------------------
  // Serviço principal
  // ---------------------------------------------------------------------------
  TGestorERPService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
  private
    FWorkerThread: TGestorERPWorkerThread;
    procedure LogInfo(const AMessage: string);
    procedure LogWarning(const AMessage: string);
    procedure LogError(const AMessage: string);
    procedure StopWorker;
  public
    function GetServiceController: TServiceController; override;
    class procedure ServiceController(CtrlCode: DWord); static; stdcall;
  end;

var
  GestorERPService: TGestorERPService;

implementation

{$R *.DFM}

// =============================================================================
// TGestorERPService — Service Controller (obrigatório em todos os TService)
// =============================================================================

class procedure TGestorERPService.ServiceController(CtrlCode: DWord); stdcall;
begin
  GestorERPService.Controller(CtrlCode);
end;

function TGestorERPService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

// =============================================================================
// Helpers de log
// =============================================================================

procedure TGestorERPService.LogInfo(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure TGestorERPService.LogWarning(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_WARNING_TYPE, 0, 0);
end;

procedure TGestorERPService.LogError(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_ERROR_TYPE, 0, 0);
end;

// =============================================================================
// Eventos do ciclo de vida do serviço
// =============================================================================

procedure TGestorERPService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  try
    LogInfo('GestorERP Service: iniciando...');

    FWorkerThread := TGestorERPWorkerThread.Create(Self);
    // TThread.Create(False) inicia imediatamente — não precisa de Resume

    Started := True;
    LogInfo('GestorERP Service: iniciado com sucesso.');
  except
    on E: Exception do
    begin
      LogError('GestorERP Service: falha ao iniciar — ' + E.Message);
      // Started permanece False → SCM marca serviço como falho
      StopWorker; // limpar recursos parciais
    end;
  end;
end;

procedure TGestorERPService.ServiceStop(Sender: TService);
begin
  LogInfo('GestorERP Service: parando...');
  StopWorker;
  LogInfo('GestorERP Service: parado.');
end;

procedure TGestorERPService.ServiceExecute(Sender: TService);
begin
  // OnExecute alternativo ao padrão OnStart+thread.
  // Se implementado, bloqueia aqui até o serviço parar.
  // Neste exemplo, usamos OnStart+thread, então processamos apenas mensagens.
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(False);
    // Pequeno sleep para não consumir 100% CPU no loop de polling
    Sleep(100);
  end;
end;

procedure TGestorERPService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  LogInfo('GestorERP Service: pausando...');
  // Suspender o worker (ou sinalizar via flag)
  if Assigned(FWorkerThread) then
    SuspendThread(FWorkerThread.Handle);
  Paused := True;
  LogInfo('GestorERP Service: pausado.');
end;

procedure TGestorERPService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  LogInfo('GestorERP Service: retomando...');
  if Assigned(FWorkerThread) then
    ResumeThread(FWorkerThread.Handle);
  Continued := True;
  LogInfo('GestorERP Service: retomado.');
end;

procedure TGestorERPService.ServiceShutdown(Sender: TService);
begin
  // Sistema a desligar — comportamento idêntico ao Stop, mas com tempo limitado
  LogWarning('GestorERP Service: sistema a desligar — iniciando paragem de emergência...');
  StopWorker;
  LogInfo('GestorERP Service: parado por shutdown do sistema.');
end;

procedure TGestorERPService.ServiceAfterInstall(Sender: TService);
begin
  // Executado após sc install / -install
  // Configura recovery actions programaticamente se necessário
  LogInfo('GestorERP Service: instalado com sucesso.');
end;

procedure TGestorERPService.ServiceAfterUninstall(Sender: TService);
begin
  LogInfo('GestorERP Service: desinstalado.');
end;

// =============================================================================
// Helper interno — parar e libertar o worker
// =============================================================================

procedure TGestorERPService.StopWorker;
const
  STOP_TIMEOUT_MS = 15000; // 15 segundos — ajustar conforme necessidade
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.RequestStop;   // sinalizar via evento Win32 (mais rápido)
    FWorkerThread.Terminate;     // sinalizar via Terminated flag (redundante mas seguro)
    FWorkerThread.WaitFor;       // aguardar finalização limpa
    FreeAndNil(FWorkerThread);
  end;
end;

// =============================================================================
// TGestorERPWorkerThread
// =============================================================================

constructor TGestorERPWorkerThread.Create(AServiceRef: Pointer);
begin
  FServiceRef := AServiceRef;
  FStopEvent := CreateEvent(nil, True, False, nil); // manual reset, não sinalizado
  if FStopEvent = 0 then
    raise Exception.Create('Falha ao criar evento de paragem: ' + SysErrorMessage(GetLastError));

  // FreeOnTerminate := False — o serviço é responsável por libertar a thread
  inherited Create(False); // False = iniciar imediatamente
end;

destructor TGestorERPWorkerThread.Destroy;
begin
  if FStopEvent <> 0 then
    CloseHandle(FStopEvent);
  inherited;
end;

procedure TGestorERPWorkerThread.RequestStop;
begin
  // Sinalizar o evento — WaitForSingleObject no Execute será desbloqueado imediatamente
  SetEvent(FStopEvent);
end;

procedure TGestorERPWorkerThread.Execute;
var
  LWaitResult: DWORD;
  LService: TGestorERPService;
const
  INTERVAL_MS = 5000; // intervalo de trabalho em ms
begin
  LService := TGestorERPService(FServiceRef);
  LService.LogInfo('Worker thread iniciada (TID=' + IntToStr(GetCurrentThreadId) + ').');

  while not Terminated do
  begin
    try
      // === TRABALHO REAL AQUI ===
      // Substituir pelo código de processamento real:
      //   - Polling de base de dados
      //   - Processamento de fila de mensagens
      //   - Sincronização de dados
      //   - Monitorização de recursos

      LService.LogInfo('Worker: executando ciclo de processamento...');
      // TODO: implementar lógica de negócio

    except
      on E: Exception do
        LService.LogError('Worker: erro no ciclo — ' + E.ClassName + ': ' + E.Message);
        // Não relançar — manter o worker vivo mesmo após erros recuperáveis
    end;

    // Aguardar próximo ciclo OU sinal de paragem (mais eficiente que Sleep)
    LWaitResult := WaitForSingleObject(FStopEvent, INTERVAL_MS);
    case LWaitResult of
      WAIT_OBJECT_0:
        begin
          // Evento de paragem sinalizado — sair do loop imediatamente
          LService.LogInfo('Worker: evento de paragem recebido.');
          Break;
        end;
      WAIT_TIMEOUT:
        // Timeout normal — continuar ciclo
        Continue;
    else
      // WAIT_FAILED ou outro — logar e sair
      LService.LogError('Worker: WaitForSingleObject falhou — ' + SysErrorMessage(GetLastError));
      Break;
    end;
  end;

  LService.LogInfo('Worker thread finalizada.');
end;

end.
