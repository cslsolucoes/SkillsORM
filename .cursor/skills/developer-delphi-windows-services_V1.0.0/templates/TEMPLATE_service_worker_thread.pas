unit u{NOME_WORKER}Thread;

{
  TEMPLATE — Worker Thread para Windows Service Delphi
  =====================================================

  Substituir:
    {NOME_WORKER}    → nome da thread (ex.: GestorERPImport)
    {NOME_SERVICO}   → nome do serviço (ex.: GestorERPService)

  Características:
    - Loop principal com verificação de Terminated
    - Paragem limpa via evento Win32 (mais rápida que Terminated poll)
    - Override de Terminate para sinalizar evento
    - Uso correcto de WaitResult
    - Suporte a Pause/Resume via evento de pausa
    - Tratamento de erros recuperáveis no loop (sem crash)
    - Logging thread-safe via referência ao serviço
}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes;

type
  /// <summary>
  ///   Worker thread projetada para execução dentro de um Windows Service.
  ///   Suporta paragem limpa via evento Win32 (RequestStop) e pausa/resume.
  /// </summary>
  T{NOME_WORKER}Thread = class(TThread)
  private
    FStopEvent   : THandle; // evento de paragem (manual reset)
    FPauseEvent  : THandle; // evento de pausa (quando sinalizado = pausado)
    FResumeEvent : THandle; // evento de resume (quando sinalizado = pode continuar)
    FServiceRef  : Pointer; // referência ao serviço para logging

    function  IsStopRequested: Boolean; inline;
    function  WaitForWorkInterval(AIntervalMs: DWORD): Boolean; // False = deve parar
    procedure HandlePauseIfRequested;
  protected
    procedure Execute; override;
    /// <summary>Executar um ciclo de trabalho. Chamar LogError em caso de exceção.</summary>
    procedure DoWork; virtual; abstract;
    /// <summary>Inicialização antes do loop principal (opcional).</summary>
    procedure DoInitialize; virtual;
    /// <summary>Finalização após o loop principal (opcional).</summary>
    procedure DoFinalize; virtual;
    /// <summary>Chamado quando o serviço solicita pausa. Subclasse pode sobrescrever.</summary>
    procedure DoPause; virtual;
    /// <summary>Chamado quando o serviço retoma após pausa. Subclasse pode sobrescrever.</summary>
    procedure DoResume; virtual;
  public
    constructor Create(AServiceRef: Pointer; AWorkIntervalMs: DWORD = 5000);
    destructor Destroy; override;

    // --- Controle externo ---
    /// <summary>Sinaliza paragem. Chame antes de WaitFor.</summary>
    procedure RequestStop;
    /// <summary>Pausa o ciclo de trabalho (não suspende a thread OS).</summary>
    procedure RequestPause;
    /// <summary>Retoma após pausa.</summary>
    procedure RequestResume;
    /// <summary>Override de Terminate — também sinaliza o evento de paragem.</summary>
    procedure Terminate; reintroduce;

    // --- Log helpers (thread-safe via referência ao serviço) ---
    procedure LogInfo(const AMsg: string);
    procedure LogWarning(const AMsg: string);
    procedure LogError(const AMsg: string);

    // --- Configuração ---
    property WorkIntervalMs: DWORD read FWorkIntervalMs write FWorkIntervalMs;
  private
    FWorkIntervalMs: DWORD;
    FPaused: Boolean;
  end;

implementation

uses
  Vcl.SvcMgr; // para aceder ao método LogMessage do TService

// =============================================================================
// Constructor / Destructor
// =============================================================================

constructor T{NOME_WORKER}Thread.Create(AServiceRef: Pointer; AWorkIntervalMs: DWORD = 5000);
begin
  FServiceRef     := AServiceRef;
  FWorkIntervalMs := AWorkIntervalMs;
  FPaused         := False;

  // Criar eventos:
  FStopEvent := CreateEvent(nil, True, False, nil);   // manual reset, não sinalizado
  if FStopEvent = 0 then
    raise EOSError.CreateFmt('Falha ao criar FStopEvent: %s', [SysErrorMessage(GetLastError)]);

  FPauseEvent := CreateEvent(nil, True, False, nil);  // manual reset, não sinalizado
  if FPauseEvent = 0 then
    raise EOSError.CreateFmt('Falha ao criar FPauseEvent: %s', [SysErrorMessage(GetLastError)]);

  FResumeEvent := CreateEvent(nil, True, True, nil);  // manual reset, SINALIZADO por padrão
  if FResumeEvent = 0 then                             // sinalizado = pode executar
    raise EOSError.CreateFmt('Falha ao criar FResumeEvent: %s', [SysErrorMessage(GetLastError)]);

  FreeOnTerminate := False; // serviço é responsável por Free
  inherited Create(False);  // False = iniciar imediatamente
end;

destructor T{NOME_WORKER}Thread.Destroy;
begin
  if FStopEvent   <> 0 then CloseHandle(FStopEvent);
  if FPauseEvent  <> 0 then CloseHandle(FPauseEvent);
  if FResumeEvent <> 0 then CloseHandle(FResumeEvent);
  inherited;
end;

// =============================================================================
// Controle externo
// =============================================================================

procedure T{NOME_WORKER}Thread.Terminate;
begin
  inherited Terminate; // seta Terminated := True
  RequestStop;         // também sinaliza o evento para desbloqueio imediato
end;

procedure T{NOME_WORKER}Thread.RequestStop;
begin
  if FStopEvent <> 0 then
    SetEvent(FStopEvent);
  // Se estiver em pausa, sinalizar resume também para desbloquear o WaitFor
  if FResumeEvent <> 0 then
    SetEvent(FResumeEvent);
end;

procedure T{NOME_WORKER}Thread.RequestPause;
begin
  if not FPaused then
  begin
    FPaused := True;
    SetEvent(FPauseEvent);   // sinalizar que deve pausar
    ResetEvent(FResumeEvent); // bloquear o resume
    DoPause;
  end;
end;

procedure T{NOME_WORKER}Thread.RequestResume;
begin
  if FPaused then
  begin
    FPaused := False;
    ResetEvent(FPauseEvent);  // limpar flag de pausa
    SetEvent(FResumeEvent);   // liberar bloqueio de resume
    DoResume;
  end;
end;

// =============================================================================
// Helpers privados
// =============================================================================

function T{NOME_WORKER}Thread.IsStopRequested: Boolean;
begin
  Result := Terminated or (WaitForSingleObject(FStopEvent, 0) = WAIT_OBJECT_0);
end;

function T{NOME_WORKER}Thread.WaitForWorkInterval(AIntervalMs: DWORD): Boolean;
// Retorna False se deve parar, True se deve continuar (timeout ou resume após pausa)
var
  LHandles: array[0..1] of THandle;
  LWaitResult: DWORD;
begin
  LHandles[0] := FStopEvent;
  LHandles[1] := FResumeEvent; // se em pausa, ResumeEvent está não-sinalizado

  LWaitResult := WaitForMultipleObjects(2, @LHandles[0], False, AIntervalMs);

  case LWaitResult of
    WAIT_OBJECT_0:     Result := False; // FStopEvent — deve parar
    WAIT_OBJECT_0 + 1: Result := not IsStopRequested; // FResumeEvent — continuar se não parar
    WAIT_TIMEOUT:      Result := not IsStopRequested; // timeout — continuar ciclo
  else
    // WAIT_FAILED
    LogError('WaitForMultipleObjects falhou: ' + SysErrorMessage(GetLastError));
    Result := False;
  end;
end;

procedure T{NOME_WORKER}Thread.HandlePauseIfRequested;
begin
  // Se pausado, aguardar ResumeEvent indefinidamente (ou StopEvent)
  if WaitForSingleObject(FPauseEvent, 0) = WAIT_OBJECT_0 then
  begin
    LogInfo('{NOME_WORKER}Thread: modo pausa — aguardando resume...');
    // Bloquear até resume ou stop:
    WaitForWorkInterval(INFINITE);
  end;
end;

// =============================================================================
// Execute — loop principal
// =============================================================================

procedure T{NOME_WORKER}Thread.Execute;
begin
  LogInfo('{NOME_WORKER}Thread iniciada (TID=' + IntToStr(GetCurrentThreadId) + ').');

  try
    DoInitialize;
  except
    on E: Exception do
    begin
      LogError('{NOME_WORKER}Thread: falha na inicialização — ' + E.Message);
      Exit; // thread não pode iniciar — sair limpo
    end;
  end;

  while not IsStopRequested do
  begin
    // Verificar e aguardar pausa se solicitada
    HandlePauseIfRequested;

    if IsStopRequested then
      Break;

    // Executar ciclo de trabalho com protecção total
    try
      DoWork;
    except
      on E: EAbort do
        Break; // paragem solicitada via EAbort
      on E: Exception do
      begin
        // Erro recuperável — logar e continuar no próximo ciclo
        LogError('{NOME_WORKER}Thread: erro em DoWork — ' + E.ClassName + ': ' + E.Message);
        // Pequeno delay extra após erro para evitar loop de erros rápidos:
        Sleep(1000);
      end;
    end;

    // Aguardar intervalo de trabalho ou sinal de paragem
    if not WaitForWorkInterval(FWorkIntervalMs) then
      Break;
  end;

  try
    DoFinalize;
  except
    on E: Exception do
      LogError('{NOME_WORKER}Thread: erro na finalização — ' + E.Message);
  end;

  LogInfo('{NOME_WORKER}Thread finalizada.');
end;

// =============================================================================
// Hooks virtuais (subclasse pode sobrescrever)
// =============================================================================

procedure T{NOME_WORKER}Thread.DoInitialize;
begin
  // Subclasse pode inicializar recursos (conexão DB, ficheiro de log, etc.)
end;

procedure T{NOME_WORKER}Thread.DoFinalize;
begin
  // Subclasse pode libertar recursos
end;

procedure T{NOME_WORKER}Thread.DoPause;
begin
  LogInfo('{NOME_WORKER}Thread: pausada.');
end;

procedure T{NOME_WORKER}Thread.DoResume;
begin
  LogInfo('{NOME_WORKER}Thread: retomada.');
end;

// =============================================================================
// Log helpers
// =============================================================================

procedure T{NOME_WORKER}Thread.LogInfo(const AMsg: string);
begin
  if Assigned(FServiceRef) then
    TService(FServiceRef).LogMessage(AMsg, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure T{NOME_WORKER}Thread.LogWarning(const AMsg: string);
begin
  if Assigned(FServiceRef) then
    TService(FServiceRef).LogMessage(AMsg, EVENTLOG_WARNING_TYPE, 0, 0);
end;

procedure T{NOME_WORKER}Thread.LogError(const AMsg: string);
begin
  if Assigned(FServiceRef) then
    TService(FServiceRef).LogMessage(AMsg, EVENTLOG_ERROR_TYPE, 0, 0);
end;

end.
