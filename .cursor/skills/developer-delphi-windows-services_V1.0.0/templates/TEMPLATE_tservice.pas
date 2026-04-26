unit u{NOME_SERVICO};

{
  TEMPLATE — Windows Service com TService (Delphi/RAD Studio)
  ===========================================================

  Substituir:
    {NOME_SERVICO}         → nome da unit (ex.: GestorERPService)
    {CLASSE_SERVICO}       → nome da classe (ex.: TGestorERPService)
    {VAR_SERVICO}          → variável global (ex.: GestorERPService)
    {PIPE_NAME}            → nome do pipe (ex.: \\.\pipe\GestorERPPipe) ou remover se não usar
    {SERVICE_DISPLAY_NAME} → nome exibido no services.msc
    {SERVICE_VERSION}      → versão do serviço

  Estrutura do .dpr (gerada pelo wizard, adaptar):
    program {NOME_SERVICO};
    uses
      Vcl.SvcMgr,
      u{NOME_SERVICO} in 'u{NOME_SERVICO}.pas' {{CLASSE_SERVICO}: TService};
    {$R *.res}
    begin
      if not Application.DelayInitialize or Application.Installing then
        Application.Initialize;
      Application.Title := '{SERVICE_DISPLAY_NAME}';
      Application.CreateForm(T{CLASSE_SERVICO}, {VAR_SERVICO});
      Application.Run;
    end.
}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  Vcl.SvcMgr;

const
  SERVICE_VERSION      = '{SERVICE_VERSION}';
  SERVICE_DISPLAY_NAME = '{SERVICE_DISPLAY_NAME}';

type
  // ---------------------------------------------------------------------------
  // Worker Thread — executa o trabalho real em background
  // ---------------------------------------------------------------------------
  T{CLASSE_SERVICO}Worker = class(TThread)
  private
    FStopEvent  : THandle;
    FServiceRef : Pointer;
    procedure DoWork;
  protected
    procedure Execute; override;
  public
    constructor Create(AServiceRef: Pointer);
    destructor Destroy; override;
    /// <summary>Sinaliza paragem imediata via evento Win32 (mais rápido que Terminated).</summary>
    procedure RequestStop;
  end;

  // ---------------------------------------------------------------------------
  // Serviço principal — herda de TService
  // ---------------------------------------------------------------------------
  T{CLASSE_SERVICO} = class(TService)
    // --- Eventos de ciclo de vida ---
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceInterrogate(Sender: TService);
    procedure ServiceCustomControl(Sender: TService; Control: DWORD);
    // --- Eventos de instalação ---
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceAfterUninstall(Sender: TService);
  private
    FWorkerThread : T{CLASSE_SERVICO}Worker;
    FPaused       : Boolean;
    // Helpers internos
    procedure StopWorker(ATimeoutMs: DWORD = 15000);
    procedure ConfigureRecovery;
  public
    // Métodos de log — convenientes para uso fora do contexto TService
    procedure LogInfo(const AMessage: string);
    procedure LogWarning(const AMessage: string);
    procedure LogError(const AMessage: string);
    // ServiceController — obrigatório em todos os TService
    function GetServiceController: TServiceController; override;
    class procedure ServiceController(CtrlCode: DWord); static; stdcall;
    // Propriedades de estado (thread-safe via leitura atómica)
    property IsPaused: Boolean read FPaused;
  end;

var
  {VAR_SERVICO}: T{CLASSE_SERVICO};

implementation

{$R *.DFM}

// =============================================================================
// T{CLASSE_SERVICO} — ServiceController (obrigatório em todos os TService)
// =============================================================================

class procedure T{CLASSE_SERVICO}.ServiceController(CtrlCode: DWord); stdcall;
begin
  {VAR_SERVICO}.Controller(CtrlCode);
end;

function T{CLASSE_SERVICO}.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

// =============================================================================
// Logging
// =============================================================================

procedure T{CLASSE_SERVICO}.LogInfo(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure T{CLASSE_SERVICO}.LogWarning(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_WARNING_TYPE, 0, 0);
end;

procedure T{CLASSE_SERVICO}.LogError(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_ERROR_TYPE, 0, 0);
end;

// =============================================================================
// Eventos de ciclo de vida
// =============================================================================

procedure T{CLASSE_SERVICO}.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  FPaused := False;

  try
    LogInfo(SERVICE_DISPLAY_NAME + ' v' + SERVICE_VERSION + ': iniciando...');

    // --- Inicializar recursos aqui ---
    // Ex.: abrir conexão a base de dados, carregar configuração, etc.

    // Criar e iniciar thread worker
    FWorkerThread := T{CLASSE_SERVICO}Worker.Create(Self);
    // Create(False) inicia imediatamente — não precisa de Resume

    Started := True;
    LogInfo(SERVICE_DISPLAY_NAME + ': pronto.');
  except
    on E: Exception do
    begin
      LogError(SERVICE_DISPLAY_NAME + ': falha ao iniciar — ' + E.ClassName + ': ' + E.Message);
      StopWorker; // limpar recursos parcialmente inicializados
      // Started permanece False → SCM marca serviço como falho
    end;
  end;
end;

procedure T{CLASSE_SERVICO}.ServiceStop(Sender: TService);
begin
  LogInfo(SERVICE_DISPLAY_NAME + ': parando...');
  StopWorker;
  // --- Libertar outros recursos aqui ---
  LogInfo(SERVICE_DISPLAY_NAME + ': parado.');
end;

procedure T{CLASSE_SERVICO}.ServiceExecute(Sender: TService);
begin
  // Alternativa ao padrão OnStart+thread.
  // Se implementado, este método bloqueia até o serviço terminar.
  // Neste template usamos OnStart+thread, portanto apenas processamos mensagens.
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(False);
    Sleep(100); // evitar 100% CPU no loop de polling
  end;
end;

procedure T{CLASSE_SERVICO}.ServicePause(Sender: TService; var Paused: Boolean);
begin
  LogInfo(SERVICE_DISPLAY_NAME + ': pausando...');
  try
    if Assigned(FWorkerThread) then
      SuspendThread(FWorkerThread.Handle);
    // Alternativa: usar flag FPaused que a thread verifica no loop
    FPaused := True;
    Paused := True;
    LogInfo(SERVICE_DISPLAY_NAME + ': pausado.');
  except
    on E: Exception do
    begin
      LogError('Falha ao pausar: ' + E.Message);
      Paused := False;
    end;
  end;
end;

procedure T{CLASSE_SERVICO}.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  LogInfo(SERVICE_DISPLAY_NAME + ': retomando...');
  try
    if Assigned(FWorkerThread) then
      ResumeThread(FWorkerThread.Handle);
    FPaused := False;
    Continued := True;
    LogInfo(SERVICE_DISPLAY_NAME + ': retomado.');
  except
    on E: Exception do
    begin
      LogError('Falha ao retomar: ' + E.Message);
      Continued := False;
    end;
  end;
end;

procedure T{CLASSE_SERVICO}.ServiceShutdown(Sender: TService);
begin
  // Sistema a desligar — menos tempo que OnStop (default ~20s)
  LogWarning(SERVICE_DISPLAY_NAME + ': shutdown do sistema detectado — parando...');
  StopWorker(5000); // timeout reduzido para shutdown
  LogInfo(SERVICE_DISPLAY_NAME + ': parado por shutdown.');
end;

procedure T{CLASSE_SERVICO}.ServiceInterrogate(Sender: TService);
begin
  // SCM a pedir estado — TService responde automaticamente
  // Implementar apenas se precisar de lógica customizada de estado
end;

procedure T{CLASSE_SERVICO}.ServiceCustomControl(Sender: TService; Control: DWORD);
begin
  // Comandos personalizados (128–255) via ControlService Win32 API
  case Control of
    128: begin
      LogInfo('Controle customizado 128: reload config');
      // recarregar configuração...
    end;
    129: begin
      LogInfo('Controle customizado 129: flush logs');
      // flush de logs...
    end;
  else
    LogWarning('Controle customizado desconhecido: ' + IntToStr(Control));
  end;
end;

procedure T{CLASSE_SERVICO}.ServiceAfterInstall(Sender: TService);
begin
  LogInfo(SERVICE_DISPLAY_NAME + ': instalado.');
  // Configurar recovery actions programaticamente após instalação:
  ConfigureRecovery;
end;

procedure T{CLASSE_SERVICO}.ServiceAfterUninstall(Sender: TService);
begin
  LogInfo(SERVICE_DISPLAY_NAME + ': desinstalado.');
  // Limpar recursos de instalação: chaves de registo, ficheiros temporários, etc.
end;

// =============================================================================
// Helpers internos
// =============================================================================

procedure T{CLASSE_SERVICO}.StopWorker(ATimeoutMs: DWORD = 15000);
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.RequestStop; // sinalizar via evento Win32 (mais rápido)
    FWorkerThread.Terminate;   // sinalizar via Terminated (redundante mas seguro)

    // Aguardar finalização com timeout via WaitFor
    // (WaitFor internamente chama WaitForSingleObject sem timeout — cuidado em shutdown)
    FWorkerThread.WaitFor;
    FreeAndNil(FWorkerThread);
  end;
end;

procedure T{CLASSE_SERVICO}.ConfigureRecovery;
var
  LScHandle, LSvcHandle: THandle;
  LFailureActions: SERVICE_FAILURE_ACTIONS;
  LActions: array[0..2] of SC_ACTION;
begin
  // Configurar recovery via API Win32 (alternativa ao sc failure):
  LScHandle := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if LScHandle = 0 then
    Exit;
  try
    LSvcHandle := OpenService(LScHandle, PChar(Name), SERVICE_ALL_ACCESS);
    if LSvcHandle = 0 then
      Exit;
    try
      LActions[0].&Type := SC_ACTION_RESTART;
      LActions[0].Delay := 60000; // 1 min

      LActions[1].&Type := SC_ACTION_RESTART;
      LActions[1].Delay := 120000; // 2 min

      LActions[2].&Type := SC_ACTION_RESTART;
      LActions[2].Delay := 300000; // 5 min

      FillChar(LFailureActions, SizeOf(LFailureActions), 0);
      LFailureActions.dwResetPeriod := 86400; // 24h
      LFailureActions.cActions := 3;
      LFailureActions.lpsaActions := @LActions[0];

      ChangeServiceConfig2(LSvcHandle, SERVICE_CONFIG_FAILURE_ACTIONS, @LFailureActions);
    finally
      CloseServiceHandle(LSvcHandle);
    end;
  finally
    CloseServiceHandle(LScHandle);
  end;
end;

// =============================================================================
// T{CLASSE_SERVICO}Worker
// =============================================================================

constructor T{CLASSE_SERVICO}Worker.Create(AServiceRef: Pointer);
begin
  FServiceRef := AServiceRef;

  FStopEvent := CreateEvent(
    nil,   // atributos de segurança padrão
    True,  // manual reset (não é resetado automaticamente após sinalização)
    False, // estado inicial: não sinalizado
    nil    // sem nome — privado a este processo
  );

  if FStopEvent = 0 then
    raise EOSError.CreateFmt('Falha ao criar StopEvent: %s', [SysErrorMessage(GetLastError)]);

  FreeOnTerminate := False; // o serviço é responsável por libertar (via FreeAndNil)
  inherited Create(False);  // False = iniciar imediatamente
end;

destructor T{CLASSE_SERVICO}Worker.Destroy;
begin
  if FStopEvent <> 0 then
  begin
    CloseHandle(FStopEvent);
    FStopEvent := 0;
  end;
  inherited;
end;

procedure T{CLASSE_SERVICO}Worker.RequestStop;
begin
  if FStopEvent <> 0 then
    SetEvent(FStopEvent);
end;

procedure T{CLASSE_SERVICO}Worker.DoWork;
var
  LService: T{CLASSE_SERVICO};
begin
  LService := T{CLASSE_SERVICO}(FServiceRef);
  try
    // === IMPLEMENTAR LÓGICA DE NEGÓCIO AQUI ===
    //
    // Exemplos:
    //   - Polling de base de dados por novos registos
    //   - Processamento de ficheiros numa pasta monitorizada
    //   - Verificação de integridade de dados
    //   - Sincronização com sistema externo
    //   - Envio de alertas e notificações
    //
    LService.LogInfo('Worker: ciclo de trabalho executado.');
  except
    on E: Exception do
      LService.LogError('Worker: erro em DoWork — ' + E.ClassName + ': ' + E.Message);
      // Não relançar — o loop continua mesmo após erros recuperáveis
  end;
end;

procedure T{CLASSE_SERVICO}Worker.Execute;
var
  LService: T{CLASSE_SERVICO};
  LWaitResult: DWORD;
const
  WORK_INTERVAL_MS = 5000; // intervalo entre ciclos de trabalho (5s)
begin
  LService := T{CLASSE_SERVICO}(FServiceRef);
  LService.LogInfo('Worker thread iniciada (TID=' + IntToStr(GetCurrentThreadId) + ').');

  while not Terminated do
  begin
    // Executar trabalho real
    DoWork;

    // Aguardar próximo ciclo OU sinal de paragem
    // WaitForSingleObject é mais eficiente que Sleep para interrupção imediata
    LWaitResult := WaitForSingleObject(FStopEvent, WORK_INTERVAL_MS);

    case LWaitResult of
      WAIT_OBJECT_0:
        begin
          // Evento de paragem sinalizado — sair imediatamente
          Break;
        end;
      WAIT_TIMEOUT:
        // Timeout normal — continuar próximo ciclo
        Continue;
      WAIT_FAILED:
        begin
          LService.LogError('Worker: WaitForSingleObject falhou — ' + SysErrorMessage(GetLastError));
          Break;
        end;
    end;
  end;

  LService.LogInfo('Worker thread finalizada.');
end;

end.
