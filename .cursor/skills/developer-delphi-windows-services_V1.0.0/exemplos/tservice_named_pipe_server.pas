unit uGestorERPPipeService;

{
  Exemplo de Windows Service que expõe um Named Pipe para IPC.

  Demonstra:
    - OnStart abre pipe e inicia thread de escuta (TPipeListenThread)
    - Thread loop: ConnectNamedPipe → ler comando → responder → DisconnectNamedPipe
    - OnStop fecha pipe e termina thread de forma limpa
    - Protocolo simples de comandos texto (UTF-8)

  Pipe name: \\.\pipe\GestorERPServicePipe

  Protocolo:
    Comando (texto UTF-8) → Serviço processa → Resposta (texto UTF-8)

  Comandos suportados (exemplo):
    STATUS        → retorna "RUNNING" ou "PAUSED"
    VERSION       → retorna versão do serviço
    RELOAD_CONFIG → recarrega configuração; retorna "OK" ou "ERROR: <detalhe>"
    STOP_WORKER   → para o worker; retorna "OK"
    START_WORKER  → inicia o worker; retorna "OK"
    PING          → retorna "PONG"
}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.SvcMgr;

const
  PIPE_NAME = '\\.\pipe\GestorERPServicePipe';
  PIPE_BUFFER_SIZE = 4096;
  PIPE_CONNECT_TIMEOUT = 5000; // ms

type
  // ---------------------------------------------------------------------------
  // Thread de escuta do Named Pipe
  // ---------------------------------------------------------------------------
  TPipeListenThread = class(TThread)
  private
    FPipeHandle: THandle;
    FServiceRef: Pointer;
    function ProcessarComando(const AComando: string): string;
  protected
    procedure Execute; override;
  public
    constructor Create(APipeHandle: THandle; AServiceRef: Pointer);
  end;

  // ---------------------------------------------------------------------------
  // Serviço com Named Pipe
  // ---------------------------------------------------------------------------
  TGestorERPPipeService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
  private
    FPipeHandle: THandle;
    FPipeThread: TPipeListenThread;
    procedure LogInfo(const AMessage: string);
    procedure LogError(const AMessage: string);
    function CriarPipe: THandle;
    procedure FecharPipe;
  public
    function GetServiceController: TServiceController; override;
    class procedure ServiceController(CtrlCode: DWord); static; stdcall;
    // Métodos públicos acessados pelos comandos do pipe:
    function GetStatus: string;
    function GetVersion: string;
    function ReloadConfig: string;
  end;

var
  GestorERPPipeService: TGestorERPPipeService;

implementation

{$R *.DFM}

const
  SERVICE_VERSION = '1.0.0';

// =============================================================================
// TGestorERPPipeService — controller obrigatório
// =============================================================================

class procedure TGestorERPPipeService.ServiceController(CtrlCode: DWord); stdcall;
begin
  GestorERPPipeService.Controller(CtrlCode);
end;

function TGestorERPPipeService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

// =============================================================================
// Helpers de log
// =============================================================================

procedure TGestorERPPipeService.LogInfo(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_INFORMATION_TYPE, 0, 0);
end;

procedure TGestorERPPipeService.LogError(const AMessage: string);
begin
  LogMessage(AMessage, EVENTLOG_ERROR_TYPE, 0, 0);
end;

// =============================================================================
// Implementação de comandos do pipe
// =============================================================================

function TGestorERPPipeService.GetStatus: string;
begin
  Result := 'RUNNING'; // substituir por estado real
end;

function TGestorERPPipeService.GetVersion: string;
begin
  Result := SERVICE_VERSION;
end;

function TGestorERPPipeService.ReloadConfig: string;
begin
  try
    // TODO: recarregar configuração real
    Result := 'OK';
  except
    on E: Exception do
      Result := 'ERROR: ' + E.Message;
  end;
end;

// =============================================================================
// Gestão do pipe
// =============================================================================

function TGestorERPPipeService.CriarPipe: THandle;
begin
  Result := CreateNamedPipe(
    PIPE_NAME,
    PIPE_ACCESS_DUPLEX or FILE_FLAG_FIRST_PIPE_INSTANCE,
    PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT,
    1,                    // máximo 1 instância (single-client)
    PIPE_BUFFER_SIZE,     // buffer de saída
    PIPE_BUFFER_SIZE,     // buffer de entrada
    PIPE_CONNECT_TIMEOUT, // timeout padrão de cliente
    nil                   // SECURITY_ATTRIBUTES = nil → herdar do processo
  );

  if Result = INVALID_HANDLE_VALUE then
    raise Exception.CreateFmt(
      'Falha ao criar named pipe "%s": %s',
      [PIPE_NAME, SysErrorMessage(GetLastError)]
    );
end;

procedure TGestorERPPipeService.FecharPipe;
begin
  if FPipeHandle <> INVALID_HANDLE_VALUE then
  begin
    // Cancelar qualquer ConnectNamedPipe pendente na thread de escuta
    DisconnectNamedPipe(FPipeHandle);
    CloseHandle(FPipeHandle);
    FPipeHandle := INVALID_HANDLE_VALUE;
  end;
end;

// =============================================================================
// Ciclo de vida do serviço
// =============================================================================

procedure TGestorERPPipeService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  FPipeHandle := INVALID_HANDLE_VALUE;

  try
    LogInfo('GestorERP Pipe Service: iniciando...');

    FPipeHandle := CriarPipe;
    LogInfo('Named Pipe criado: ' + PIPE_NAME);

    FPipeThread := TPipeListenThread.Create(FPipeHandle, Self);
    Started := True;

    LogInfo('GestorERP Pipe Service: pronto para conexões em ' + PIPE_NAME);
  except
    on E: Exception do
    begin
      LogError('Falha ao iniciar: ' + E.Message);
      FecharPipe;
    end;
  end;
end;

procedure TGestorERPPipeService.ServiceStop(Sender: TService);
begin
  LogInfo('GestorERP Pipe Service: parando...');

  // Parar thread de escuta primeiro
  if Assigned(FPipeThread) then
  begin
    FPipeThread.Terminate;
    // Fechar o pipe forçará o ConnectNamedPipe/ReadFile a retornar erro
    FecharPipe;
    FPipeThread.WaitFor;
    FreeAndNil(FPipeThread);
  end
  else
    FecharPipe;

  LogInfo('GestorERP Pipe Service: parado.');
end;

procedure TGestorERPPipeService.ServiceShutdown(Sender: TService);
begin
  ServiceStop(Sender);
end;

// =============================================================================
// TPipeListenThread
// =============================================================================

constructor TPipeListenThread.Create(APipeHandle: THandle; AServiceRef: Pointer);
begin
  FPipeHandle := APipeHandle;
  FServiceRef := AServiceRef;
  FreeOnTerminate := False;
  inherited Create(False); // iniciar imediatamente
end;

function TPipeListenThread.ProcessarComando(const AComando: string): string;
var
  LService: TGestorERPPipeService;
  LCmd: string;
begin
  LService := TGestorERPPipeService(FServiceRef);
  LCmd := Trim(AComando.ToUpper);

  if LCmd = 'PING' then
    Result := 'PONG'
  else if LCmd = 'STATUS' then
    Result := LService.GetStatus
  else if LCmd = 'VERSION' then
    Result := LService.GetVersion
  else if LCmd = 'RELOAD_CONFIG' then
    Result := LService.ReloadConfig
  else
    Result := 'ERROR: Comando desconhecido: ' + AComando;
end;

procedure TPipeListenThread.Execute;
var
  LService: TGestorERPPipeService;
  LBuffer: array[0..PIPE_BUFFER_SIZE - 1] of Byte;
  LBytesRead, LBytesWritten: DWORD;
  LComando, LResposta: string;
  LRespostaBytes: TBytes;
  LConectado: Boolean;
begin
  LService := TGestorERPPipeService(FServiceRef);

  while not Terminated do
  begin
    LService.LogInfo('Pipe: aguardando conexão de cliente...');

    // Bloqueante — aguarda cliente conectar
    // Se o pipe for fechado (ServiceStop), retorna imediatamente com erro
    LConectado := ConnectNamedPipe(FPipeHandle, nil);

    if Terminated then
      Break;

    if not LConectado then
    begin
      // Verificar se cliente já estava conectado quando chamámos ConnectNamedPipe
      if GetLastError = ERROR_PIPE_CONNECTED then
        LConectado := True
      else if GetLastError = ERROR_NO_DATA then
        // Cliente conectou e desconectou rapidamente
        LConectado := False
      else
      begin
        // Erro real — logar e tentar reconectar
        LService.LogError('Pipe: ConnectNamedPipe falhou — ' + SysErrorMessage(GetLastError));
        Continue;
      end;
    end;

    if LConectado then
    begin
      LService.LogInfo('Pipe: cliente conectado.');

      // Loop de leitura/escrita com este cliente
      while not Terminated do
      begin
        FillChar(LBuffer, SizeOf(LBuffer), 0);
        LBytesRead := 0;

        if not ReadFile(FPipeHandle, LBuffer[0], SizeOf(LBuffer), LBytesRead, nil) then
        begin
          // Erro ou cliente desconectou
          if GetLastError <> ERROR_BROKEN_PIPE then
            LService.LogError('Pipe: ReadFile falhou — ' + SysErrorMessage(GetLastError));
          Break; // cliente desconectou — ir para DisconnectNamedPipe
        end;

        if LBytesRead = 0 then
          Break;

        // Decodificar comando
        LComando := TEncoding.UTF8.GetString(LBuffer, 0, LBytesRead);
        LService.LogInfo('Pipe: comando recebido — ' + LComando);

        // Processar e preparar resposta
        try
          LResposta := ProcessarComando(LComando);
        except
          on E: Exception do
            LResposta := 'ERROR: ' + E.Message;
        end;

        // Enviar resposta
        LRespostaBytes := TEncoding.UTF8.GetBytes(LResposta);
        if not WriteFile(FPipeHandle, LRespostaBytes[0], Length(LRespostaBytes), LBytesWritten, nil) then
        begin
          LService.LogError('Pipe: WriteFile falhou — ' + SysErrorMessage(GetLastError));
          Break;
        end;
      end;

      // Desconectar cliente e aguardar próxima conexão
      DisconnectNamedPipe(FPipeHandle);
      LService.LogInfo('Pipe: cliente desconectado.');
    end;
  end;

  LService.LogInfo('Pipe: thread de escuta finalizada.');
end;

end.
