program console_daemon_basic;

{
  console_daemon_basic.pas
  ========================
  Daemon Linux básico em Delphi com suporte a FPC via blocos {$IFDEF FPC}.

  Funcionalidades:
  - Detecção de argumento --daemon para daemonização automática
  - Signal handler para SIGTERM (saída limpa)
  - Loop principal com Sleep(1000) e log para ficheiro
  - Cleanup garantido com try/finally
  - PID file em /var/run/meudaemon.pid

  Compilar (Delphi):
    dcclinux64 -B console_daemon_basic.dpr

  Compilar (FPC):
    fpc -Tlinux -Px86_64 console_daemon_basic.pas

  Executar:
    ./console_daemon_basic                # Modo interactivo (foreground)
    ./console_daemon_basic --daemon       # Modo daemon (background)
    ./console_daemon_basic --daemon --log /var/log/meudaemon.log
}

{$APPTYPE CONSOLE}

{$IFDEF FPC}
  {$MODE DELPHI}  // Compatibilidade com sintaxe Delphi no FPC
{$ENDIF}

uses
  SysUtils,
  Classes,
{$IFDEF FPC}
  BaseUnix,
  Unix
{$ELSE}
  Posix.Unistd,
  Posix.Signal,
  Posix.Fcntl,
  Posix.Stdlib
{$ENDIF}
  ;

// ============================================================
// Constantes e variáveis globais
// ============================================================

const
  DAEMON_NAME    = 'console_daemon_basic';
  DEFAULT_LOG    = '/tmp/console_daemon_basic.log';
  PID_FILE       = '/var/run/console_daemon_basic.pid';
  LOOP_INTERVAL  = 1000; // ms entre iterações do loop principal

var
  GTerminating  : Boolean = False;
  GLogFilePath  : string  = DEFAULT_LOG;
  GLogFile      : TextFile;
  GLogOpen      : Boolean = False;

// ============================================================
// Logging para ficheiro
// ============================================================

procedure LogMessage(const AMsg: string);
var
  LTimestamp: string;
  LLine: string;
begin
  LTimestamp := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
  LLine := Format('[%s] [PID=%d] %s', [LTimestamp, {$IFDEF FPC}fpGetPID{$ELSE}getpid{$ENDIF}(), AMsg]);

  // Escrever no log file se aberto
  if GLogOpen then
  begin
    try
      WriteLn(GLogFile, LLine);
      Flush(GLogFile);
    except
      // Não propagar excepções do log
    end;
  end;

  // Em modo foreground, também escrever no stdout
  WriteLn(LLine);
end;

procedure OpenLogFile(const APath: string);
begin
  GLogFilePath := APath;
  AssignFile(GLogFile, APath);
  try
    if FileExists(APath) then
      Append(GLogFile)
    else
      Rewrite(GLogFile);
    GLogOpen := True;
  except
    on E: Exception do
    begin
      WriteLn(StdErr, Format('AVISO: Não foi possível abrir log "%s": %s', [APath, E.Message]));
      GLogOpen := False;
    end;
  end;
end;

procedure CloseLogFile;
begin
  if GLogOpen then
  begin
    CloseFile(GLogFile);
    GLogOpen := False;
  end;
end;

// ============================================================
// PID file
// ============================================================

procedure WritePidFile;
var
  LFile: TextFile;
begin
  AssignFile(LFile, PID_FILE);
  try
    Rewrite(LFile);
    WriteLn(LFile, {$IFDEF FPC}fpGetPID{$ELSE}getpid{$ENDIF}());
    CloseFile(LFile);
  except
    on E: Exception do
      LogMessage(Format('AVISO: Não foi possível criar PID file "%s": %s', [PID_FILE, E.Message]));
  end;
end;

procedure RemovePidFile;
begin
  if FileExists(PID_FILE) then
  begin
    try
      DeleteFile(PID_FILE);
    except
      // Ignorar erro ao remover PID file
    end;
  end;
end;

// ============================================================
// Signal handlers
// ============================================================

{$IFDEF FPC}
procedure HandleSIGTERM(ASig: cint); cdecl;
begin
  GTerminating := True;
end;

procedure InstallSignalHandlers;
var
  LSA: SigActionRec;
begin
  FillChar(LSA, SizeOf(LSA), 0);
  LSA.sa_Handler := @HandleSIGTERM;
  fpSigEmptySet(LSA.sa_mask);
  LSA.sa_flags := 0;

  fpSigAction(SIGTERM, @LSA, nil);
  fpSigAction(SIGINT,  @LSA, nil);

  // Ignorar SIGPIPE (conexões quebradas não devem matar o daemon)
  LSA.sa_Handler := SIG_IGN;
  fpSigAction(SIGPIPE, @LSA, nil);

  // Ignorar SIGHUP (usar SIGTERM para terminação; SIGHUP via outra estratégia)
  LSA.sa_Handler := SIG_IGN;
  fpSigAction(SIGHUP, @LSA, nil);
end;
{$ELSE}
procedure HandleSIGTERM(ASig: Integer); cdecl;
begin
  GTerminating := True;
end;

procedure InstallSignalHandlers;
begin
  signal(SIGTERM, HandleSIGTERM);
  signal(SIGINT,  HandleSIGTERM);
  signal(SIGPIPE, SIG_IGN);
  signal(SIGHUP,  SIG_IGN);
end;
{$ENDIF}

// ============================================================
// Daemonização (fork + setsid)
// ============================================================

procedure DaemonizeProcess;
{$IFDEF FPC}
var
  LPid: TPid;
  LFd:  cint;
begin
  // Fork #1: pai termina, filho continua
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #1 falhou: errno=%d', [fpgeterrno()]);
  if LPid > 0 then
    Halt(0); // pai termina

  // Nova sessão
  if fpSetsid() < 0 then
    raise Exception.CreateFmt('fpSetsid() falhou: errno=%d', [fpgeterrno()]);

  // Fork #2: evita readquisição de terminal de controlo
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #2 falhou: errno=%d', [fpgeterrno()]);
  if LPid > 0 then
    Halt(0); // segundo pai termina

  // Mudar directório de trabalho
  fpChDir('/');

  // Redirigir stdin/stdout/stderr para /dev/null
  LFd := fpOpen('/dev/null', O_RDWR);
  if LFd >= 0 then
  begin
    fpDup2(LFd, 0); // stdin
    fpDup2(LFd, 1); // stdout
    fpDup2(LFd, 2); // stderr
    if LFd > 2 then
      fpClose(LFd);
  end;
end;
{$ELSE}
var
  LPid: pid_t;
  LFd:  Integer;
begin
  // Fork #1
  LPid := fork();
  if LPid < 0 then
    raise Exception.CreateFmt('fork() #1 falhou: errno=%d', [errno]);
  if LPid > 0 then
    Halt(0);

  // Nova sessão
  if setsid() < 0 then
    raise Exception.CreateFmt('setsid() falhou: errno=%d', [errno]);

  // Fork #2
  LPid := fork();
  if LPid < 0 then
    raise Exception.CreateFmt('fork() #2 falhou: errno=%d', [errno]);
  if LPid > 0 then
    Halt(0);

  // Mudar para /
  chdir('/');

  // Redirigir stdio para /dev/null
  LFd := __open('/dev/null', O_RDWR);
  if LFd >= 0 then
  begin
    __dup2(LFd, STDIN_FILENO);
    __dup2(LFd, STDOUT_FILENO);
    __dup2(LFd, STDERR_FILENO);
    if LFd > STDERR_FILENO then
      __close(LFd);
  end;
end;
{$ENDIF}

// ============================================================
// Parse de argumentos de linha de comandos
// ============================================================

function ParamExists(const AParam: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AParam) then
    begin
      Result := True;
      Exit;
    end;
end;

function ParamValue(const AParam: string; const ADefault: string = ''): string;
var
  I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), AParam) then
    begin
      Result := ParamStr(I + 1);
      Exit;
    end;
end;

// ============================================================
// Trabalho principal do daemon
// ============================================================

procedure DoWork(const AIteration: Int64);
begin
  // Substituir por lógica real do daemon
  // Exemplo: processar ficheiros, monitorizar recursos, etc.
  LogMessage(Format('Iteração #%d — daemon em execução (PID=%d)',
    [AIteration, {$IFDEF FPC}Integer(fpGetPID()){$ELSE}getpid(){$ENDIF}]));
end;

// ============================================================
// Programa principal
// ============================================================

var
  LDaemonMode : Boolean;
  LLogPath    : string;
  LIteration  : Int64;
begin
  LDaemonMode := ParamExists('--daemon');
  LLogPath    := ParamValue('--log', DEFAULT_LOG);

  // Instalar signal handlers ANTES de daemonizar
  InstallSignalHandlers;

  // Daemonizar se solicitado
  if LDaemonMode then
  begin
    DaemonizeProcess;
    // Após daemonizar, stdout/stderr estão em /dev/null — apenas o log file funciona
  end;

  // Abrir log file (após daemonização para ter o PID correcto)
  OpenLogFile(LLogPath);

  try
    LogMessage(Format('%s iniciando (modo=%s)', [DAEMON_NAME,
      IfThen(LDaemonMode, 'daemon', 'foreground')]));

    // Escrever PID file
    WritePidFile;
    LogMessage(Format('PID file escrito: %s (PID=%d)', [PID_FILE,
      {$IFDEF FPC}Integer(fpGetPID()){$ELSE}getpid(){$ENDIF}]));

    // Loop principal
    LIteration := 0;
    while not GTerminating do
    begin
      Inc(LIteration);
      try
        DoWork(LIteration);
      except
        on E: Exception do
          LogMessage(Format('ERRO em DoWork(): %s', [E.Message]));
      end;
      Sleep(LOOP_INTERVAL);
    end;

    LogMessage(Format('%s: SIGTERM recebido — terminando normalmente', [DAEMON_NAME]));

  finally
    // Cleanup garantido
    RemovePidFile;
    LogMessage(Format('%s terminado', [DAEMON_NAME]));
    CloseLogFile;
  end;

  ExitCode := 0;
end.
