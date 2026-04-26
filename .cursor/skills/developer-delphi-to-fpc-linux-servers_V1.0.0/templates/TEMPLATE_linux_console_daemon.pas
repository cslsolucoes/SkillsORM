program TEMPLATE_linux_console_daemon;

{
  TEMPLATE_linux_console_daemon.pas
  ==================================
  Template completo de daemon Linux para Delphi e FPC/Lazarus.

  Funcionalidades incluídas:
  - Suporte Delphi + FPC via {$IFDEF FPC}
  - Daemonização opcional via argumento --daemon (double-fork + setsid)
  - Signal handling: SIGTERM (terminação), SIGHUP (reload), SIGPIPE (ignorar)
  - Loop principal com verificação de Terminated e GReloadConfig
  - Log para ficheiro com timestamp e PID
  - PID file em /var/run/
  - Cleanup garantido com try/finally
  - Gestão de erros com logging
  - Parse de argumentos de linha de comandos

  Como usar:
  1. Renomear o ficheiro e o programa para o nome do seu daemon
  2. Substituir as constantes DAEMON_NAME, DEFAULT_LOG, PID_FILE
  3. Implementar LoadConfig() com a lógica real de configuração
  4. Implementar DoWork() com a lógica principal do daemon
  5. Ajustar LOOP_INTERVAL_MS conforme necessário

  Compilar (Delphi):
    dcclinux64 -B -O2 TEMPLATE_linux_console_daemon.dpr

  Compilar (FPC):
    fpc -Tlinux -Px86_64 -O2 -MDelphi TEMPLATE_linux_console_daemon.pas

  Executar:
    ./TEMPLATE_linux_console_daemon --daemon --log /var/log/meudaemon.log
    ./TEMPLATE_linux_console_daemon                    # modo foreground (debug)
}

{$APPTYPE CONSOLE}

{$IFDEF FPC}
  {$MODE DELPHI}
  {$LONGSTRINGS ON}
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
  Posix.Stdlib,
  Posix.Errno
{$ENDIF}
  ;

// ============================================================
// CONFIGURAÇÃO — Substituir com os valores do seu daemon
// ============================================================

const
  DAEMON_NAME       = 'meu-daemon';       // Nome do daemon (usado em logs e PID file)
  DAEMON_VERSION    = '1.0.0';            // Versão para log de arranque
  DEFAULT_LOG_PATH  = '/tmp/meu-daemon.log'; // Caminho padrão do log
  PID_FILE_PATH     = '/var/run/meu-daemon.pid'; // Caminho do PID file
  LOOP_INTERVAL_MS  = 1000;              // Intervalo do loop principal (ms)

// ============================================================
// Variáveis globais de controlo
// (volatile — modificadas por signal handlers)
// ============================================================

var
  GTerminating : Boolean = False; // True quando SIGTERM/SIGINT recebido
  GReloadConfig: Boolean = False; // True quando SIGHUP recebido
  GDaemonMode  : Boolean = False; // True se a correr como daemon
  GLogFilePath : string  = DEFAULT_LOG_PATH;

// ============================================================
// Logging thread-safe para ficheiro
// ============================================================

var
  GLogFile : TextFile;
  GLogOpen : Boolean = False;
  GLogLock : TCriticalSection = nil; // Para uso em threads

type
  TLogLevel = (llDebug, llInfo, llWarn, llError, llFatal);

const
  LOG_LEVEL_NAMES: array[TLogLevel] of string = ('DEBUG', 'INFO ', 'WARN ', 'ERROR', 'FATAL');

procedure OpenLog(const APath: string);
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
      WriteLn(StdErr, Format('ERRO: Não foi possível abrir log "%s": %s', [APath, E.Message]));
  end;
end;

procedure CloseLog;
begin
  if GLogOpen then
  begin
    try CloseFile(GLogFile); except end;
    GLogOpen := False;
  end;
end;

procedure Log(ALevel: TLogLevel; const AMsg: string);
var
  LLine: string;
begin
  LLine := Format('[%s] [%s] [%s] [PID=%d] %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now),
     LOG_LEVEL_NAMES[ALevel],
     DAEMON_NAME,
     {$IFDEF FPC}Integer(fpGetPID()){$ELSE}getpid(){$ENDIF},
     AMsg]);

  if GLogOpen then
    try
      WriteLn(GLogFile, LLine);
      Flush(GLogFile);
    except end;

  // Em modo foreground, escrever também no stdout
  if not GDaemonMode then
    WriteLn(LLine);
end;

procedure LogDebug(const AMsg: string); begin Log(llDebug, AMsg); end;
procedure LogInfo (const AMsg: string); begin Log(llInfo,  AMsg); end;
procedure LogWarn (const AMsg: string); begin Log(llWarn,  AMsg); end;
procedure LogError(const AMsg: string); begin Log(llError, AMsg); end;
procedure LogFatal(const AMsg: string); begin Log(llFatal, AMsg); end;

// ============================================================
// PID File
// ============================================================

procedure WritePIDFile;
var
  LF: TextFile;
begin
  AssignFile(LF, PID_FILE_PATH);
  try
    Rewrite(LF);
    WriteLn(LF, {$IFDEF FPC}Integer(fpGetPID()){$ELSE}getpid(){$ENDIF});
    CloseFile(LF);
    LogInfo(Format('PID file criado: %s', [PID_FILE_PATH]));
  except
    on E: Exception do
      LogWarn(Format('Não foi possível criar PID file: %s', [E.Message]));
  end;
end;

procedure RemovePIDFile;
begin
  if FileExists(PID_FILE_PATH) then
    try
      DeleteFile(PID_FILE_PATH);
    except end;
end;

// ============================================================
// Signal Handlers
// ============================================================

{$IFDEF FPC}
procedure SigHandler_SIGTERM(ASig: cint); cdecl;
begin
  GTerminating := True;
end;

procedure SigHandler_SIGHUP(ASig: cint); cdecl;
begin
  GReloadConfig := True;
end;

procedure InstallSignalHandlers;
var
  LSA: SigActionRec;
begin
  FillChar(LSA, SizeOf(LSA), 0);

  // SIGTERM e SIGINT → terminação limpa
  LSA.sa_Handler := @SigHandler_SIGTERM;
  fpSigEmptySet(LSA.sa_mask);
  LSA.sa_flags := SA_RESTART;
  fpSigAction(SIGTERM, @LSA, nil);
  fpSigAction(SIGINT,  @LSA, nil);

  // SIGHUP → reload de configuração
  LSA.sa_Handler := @SigHandler_SIGHUP;
  fpSigAction(SIGHUP, @LSA, nil);

  // SIGPIPE → ignorar (conexões TCP quebradas não devem matar o daemon)
  LSA.sa_Handler := SIG_IGN;
  fpSigEmptySet(LSA.sa_mask);
  LSA.sa_flags := 0;
  fpSigAction(SIGPIPE, @LSA, nil);

  // SIGCHLD → ignorar (evitar processos zombie se lançar filhos)
  fpSigAction(SIGCHLD, @LSA, nil);
end;
{$ELSE}
procedure SigHandler_SIGTERM(ASig: Integer); cdecl;
begin
  GTerminating := True;
end;

procedure SigHandler_SIGHUP(ASig: Integer); cdecl;
begin
  GReloadConfig := True;
end;

procedure InstallSignalHandlers;
begin
  signal(SIGTERM, SigHandler_SIGTERM);
  signal(SIGINT,  SigHandler_SIGTERM);
  signal(SIGHUP,  SigHandler_SIGHUP);
  signal(SIGPIPE, SIG_IGN);
end;
{$ENDIF}

// ============================================================
// Daemonização (double-fork + setsid)
// Só chamar se --daemon foi passado como argumento
// ============================================================

procedure Daemonize;
{$IFDEF FPC}
var
  LPid: TPid;
  LFd : cint;
begin
  // Fork #1 — pai termina, filho continua
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #1 falhou: errno=%d', [fpgeterrno()]);
  if LPid > 0 then
    Halt(0);

  // Criar nova sessão UNIX
  if fpSetsid() < 0 then
    raise Exception.CreateFmt('fpSetsid() falhou: errno=%d', [fpgeterrno()]);

  // Fork #2 — impede readquisição de terminal de controlo
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #2 falhou: errno=%d', [fpgeterrno()]);
  if LPid > 0 then
    Halt(0);

  // Mudar directório de trabalho para /
  fpChDir('/');

  // Redirigir stdin/stdout/stderr para /dev/null
  LFd := fpOpen('/dev/null', O_RDWR);
  if LFd >= 0 then
  begin
    fpDup2(LFd, 0);
    fpDup2(LFd, 1);
    fpDup2(LFd, 2);
    if LFd > 2 then fpClose(LFd);
  end;
end;
{$ELSE}
var
  LPid: pid_t;
  LFd : Integer;
begin
  LPid := fork();
  if LPid < 0 then
    raise Exception.CreateFmt('fork() #1 falhou: errno=%d', [errno]);
  if LPid > 0 then
    Halt(0);

  if setsid() < 0 then
    raise Exception.CreateFmt('setsid() falhou: errno=%d', [errno]);

  LPid := fork();
  if LPid < 0 then
    raise Exception.CreateFmt('fork() #2 falhou: errno=%d', [errno]);
  if LPid > 0 then
    Halt(0);

  chdir('/');

  LFd := __open('/dev/null', O_RDWR);
  if LFd >= 0 then
  begin
    __dup2(LFd, STDIN_FILENO);
    __dup2(LFd, STDOUT_FILENO);
    __dup2(LFd, STDERR_FILENO);
    if LFd > STDERR_FILENO then __close(LFd);
  end;
end;
{$ENDIF}

// ============================================================
// Parse de Argumentos
// ============================================================

function HasArg(const AArg: string): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), AArg) then
      Exit(True);
end;

function ArgValue(const AArg: string; const ADefault: string = ''): string;
var I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), AArg) then
    begin
      Result := ParamStr(I + 1);
      Exit;
    end;
end;

procedure PrintUsage;
begin
  WriteLn(Format('%s v%s', [DAEMON_NAME, DAEMON_VERSION]));
  WriteLn('');
  WriteLn('Uso: ' + DAEMON_NAME + ' [opções]');
  WriteLn('');
  WriteLn('Opções:');
  WriteLn('  --daemon              Executar em modo daemon (background)');
  WriteLn('  --log <caminho>       Caminho do ficheiro de log (padrão: ' + DEFAULT_LOG_PATH + ')');
  WriteLn('  --config <caminho>    Caminho do ficheiro de configuração');
  WriteLn('  --help                Mostrar esta ajuda');
  WriteLn('  --version             Mostrar versão');
end;

// ============================================================
// LÓGICA DE NEGÓCIO — Implementar aqui
// ============================================================

var
  GConfigPath: string = '/etc/' + DAEMON_NAME + '/config.ini';

procedure LoadConfig;
begin
  // TODO: Implementar carregamento de configuração
  // Exemplo: TIniFile, TJSONObject, etc.
  LogInfo(Format('Configuração carregada de: %s', [GConfigPath]));

  // Exemplo de leitura de INI:
  {
  var LIni: TIniFile;
  LIni := TIniFile.Create(GConfigPath);
  try
    GAlgumParâmetro := LIni.ReadString('Section', 'Key', 'default');
  finally
    LIni.Free;
  end;
  }
end;

procedure InitializeResources;
begin
  // TODO: Inicializar conexões, threads, etc.
  LogInfo('Recursos inicializados');
end;

procedure FinalizeResources;
begin
  // TODO: Libertar recursos, fechar conexões, etc.
  LogInfo('Recursos libertados');
end;

var
  GIterationCount: Int64 = 0;

procedure DoWork;
begin
  // TODO: Substituir com a lógica real do daemon
  // Esta procedure é chamada a cada LOOP_INTERVAL_MS millisegundos

  Inc(GIterationCount);

  // Exemplo: processar fila de mensagens, monitorizar ficheiros, etc.
  LogDebug(Format('Iteração #%d', [GIterationCount]));

  // ATENÇÃO: Se DoWork() demorar mais que LOOP_INTERVAL_MS,
  // o loop atrasará. Considerar mover trabalho pesado para TThread.
end;

// ============================================================
// PROGRAMA PRINCIPAL
// ============================================================

var
  LExitCode: Integer = 0;
begin
  // Verificar argumentos de ajuda/versão (antes de qualquer outra coisa)
  if HasArg('--help') then begin PrintUsage; Halt(0); end;
  if HasArg('--version') then begin WriteLn(DAEMON_NAME + ' v' + DAEMON_VERSION); Halt(0); end;

  // Ler argumentos
  GDaemonMode := HasArg('--daemon');
  GLogFilePath := ArgValue('--log', DEFAULT_LOG_PATH);
  GConfigPath  := ArgValue('--config', GConfigPath);

  // Instalar signal handlers ANTES de qualquer fork
  InstallSignalHandlers;

  // Daemonizar se solicitado (ANTES de abrir o log, para obter PID correcto)
  if GDaemonMode then
  begin
    try
      Daemonize;
    except
      on E: Exception do
      begin
        WriteLn(StdErr, 'FATAL: Falha na daemonização: ' + E.Message);
        Halt(1);
      end;
    end;
  end;

  // Abrir log APÓS daemonização (PID já é o do processo filho)
  OpenLog(GLogFilePath);

  // ──────────────────────────────────────────────────────────
  // Bloco principal com cleanup garantido
  // ──────────────────────────────────────────────────────────
  try
    LogInfo(Format('=== %s v%s iniciando ===', [DAEMON_NAME, DAEMON_VERSION]));
    LogInfo(Format('Modo: %s | Log: %s | Config: %s',
      [IfThen(GDaemonMode, 'daemon', 'foreground'), GLogFilePath, GConfigPath]));
    LogInfo(Format('Compilador: %s | Plataforma: Linux 64-bit',
      [{$IFDEF FPC}'FPC/Lazarus'{$ELSE}'Delphi dcclinux64'{$ENDIF}]));

    // Escrever PID file
    WritePIDFile;

    // Carregar configuração inicial
    try
      LoadConfig;
    except
      on E: Exception do
      begin
        LogFatal('Falha ao carregar configuração: ' + E.Message);
        LExitCode := 1;
        GTerminating := True;
      end;
    end;

    // Inicializar recursos (conexões, threads, etc.)
    if not GTerminating then
    begin
      try
        InitializeResources;
      except
        on E: Exception do
        begin
          LogFatal('Falha ao inicializar recursos: ' + E.Message);
          LExitCode := 1;
          GTerminating := True;
        end;
      end;
    end;

    // ──────────────────────────────────────────────
    // Loop principal
    // ──────────────────────────────────────────────
    if not GTerminating then
      LogInfo(Format('Loop principal iniciado (intervalo=%dms)', [LOOP_INTERVAL_MS]));

    while not GTerminating do
    begin
      // Verificar pedido de reload de config (SIGHUP)
      if GReloadConfig then
      begin
        GReloadConfig := False;
        LogInfo('SIGHUP recebido — recarregando configuração');
        try
          LoadConfig;
        except
          on E: Exception do
            LogError('Erro ao recarregar configuração: ' + E.Message);
        end;
      end;

      // Executar trabalho principal
      try
        DoWork;
      except
        on E: Exception do
        begin
          LogError(Format('Erro em DoWork(): %s [iteração #%d]', [E.Message, GIterationCount]));
          // Continuar o loop após erro não-fatal
          // Para erros fatais: GTerminating := True; LExitCode := 1;
        end;
      end;

      // Aguardar próximo ciclo (Sleep pode ser interrompido por sinal)
      if not GTerminating then
        Sleep(LOOP_INTERVAL_MS);
    end;
    // ──────────────────────────────────────────────

    LogInfo(Format('Sinal de terminação recebido após %d iterações', [GIterationCount]));

  except
    on E: Exception do
    begin
      LogFatal('Excepção não tratada no loop principal: ' + E.Message);
      LExitCode := 1;
    end;
  end;

  // ──────────────────────────────────────────────
  // Cleanup garantido (executa sempre)
  // ──────────────────────────────────────────────
  LogInfo('Iniciando sequência de terminação...');

  try
    FinalizeResources;
  except
    on E: Exception do
      LogError('Erro durante FinalizeResources: ' + E.Message);
  end;

  RemovePIDFile;

  LogInfo(Format('=== %s terminado (ExitCode=%d) ===', [DAEMON_NAME, LExitCode]));
  CloseLog;

  Halt(LExitCode);
end.
