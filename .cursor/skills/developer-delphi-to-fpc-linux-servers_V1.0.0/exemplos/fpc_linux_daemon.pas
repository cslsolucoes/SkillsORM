program fpc_linux_daemon;

{
  fpc_linux_daemon.pas
  ====================
  Daemon Linux nativo em FPC/Lazarus usando BaseUnix e Unix.

  Este exemplo usa EXCLUSIVAMENTE as APIs do FPC (BaseUnix, Unix) sem
  blocos {$IFDEF}. É o equivalente FPC do console_daemon_basic.pas
  (que usa Posix.* do Delphi).

  Diferenças chave vs Delphi:
  - fork()   → fpFork()
  - setsid() → fpSetsid()
  - signal() → fpSigAction() com SigActionRec
  - getpid() → fpGetPID()
  - open()   → fpOpen()
  - close()  → fpClose()
  - dup2()   → fpDup2()

  Compilar:
    fpc -Tlinux -Px86_64 -O2 fpc_linux_daemon.pas
    # ou no Linux:
    fpc -O2 fpc_linux_daemon.pas

  Executar:
    ./fpc_linux_daemon                    # foreground
    ./fpc_linux_daemon --daemon           # daemon (background)
    ./fpc_linux_daemon --daemon --log /var/log/fpc_daemon.log
}

{$MODE DELPHI}
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  BaseUnix,  // fpFork, fpSetsid, fpGetPID, fpOpen, fpClose, fpDup2, fpChDir,
             // fpSigAction, fpSigEmptySet, SigActionRec, SIGTERM, SIGINT, etc.
  Unix;      // sleep (Unix sleep, diferente de SysUtils.Sleep)

// ============================================================
// Constantes
// ============================================================

const
  DAEMON_NAME   = 'fpc_linux_daemon';
  DEFAULT_LOG   = '/tmp/fpc_linux_daemon.log';
  PID_FILE      = '/var/run/fpc_linux_daemon.pid';
  LOOP_SLEEP_MS = 1000;

// ============================================================
// Variáveis globais
// ============================================================

var
  GTerminating: Boolean = False;
  GReloadCfg  : Boolean = False;
  GLogFile    : TextFile;
  GLogOpen    : Boolean = False;
  GLogPath    : string  = DEFAULT_LOG;

// ============================================================
// Logging
// ============================================================

procedure LogMsg(const ALevel, AMsg: string);
var
  LLine: string;
begin
  LLine := Format('[%s] [%s] [PID=%d] %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
     ALevel,
     Integer(fpGetPID()),
     AMsg]);
  if GLogOpen then
  begin
    try
      WriteLn(GLogFile, LLine);
      Flush(GLogFile);
    except end;
  end;
  WriteLn(LLine);
end;

procedure LogInfo (const AMsg: string); begin LogMsg('INFO ', AMsg); end;
procedure LogWarn (const AMsg: string); begin LogMsg('WARN ', AMsg); end;
procedure LogError(const AMsg: string); begin LogMsg('ERROR', AMsg); end;

procedure OpenLog(const APath: string);
begin
  GLogPath := APath;
  AssignFile(GLogFile, APath);
  try
    if FileExists(APath) then
      Append(GLogFile)
    else
      Rewrite(GLogFile);
    GLogOpen := True;
  except
    on E: Exception do
      WriteLn(StdErr, 'Não foi possível abrir log: ' + E.Message);
  end;
end;

procedure CloseLog;
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

procedure WritePID;
var
  LF: TextFile;
begin
  AssignFile(LF, PID_FILE);
  try
    Rewrite(LF);
    WriteLn(LF, Integer(fpGetPID()));
    CloseFile(LF);
  except
    on E: Exception do
      LogWarn('Não foi possível criar PID file: ' + E.Message);
  end;
end;

procedure RemovePID;
begin
  if FileExists(PID_FILE) then
    try DeleteFile(PID_FILE); except end;
end;

// ============================================================
// Signal Handlers com fpSigAction (método recomendado no FPC)
//
// Diferença vs signal() simples:
//   fpSignal(SIGTERM, @handler) — forma simples, mesma semântica que C signal()
//   fpSigAction() — controlo completo sobre flags e máscara de sinais
//
// fpSigAction é preferível porque permite:
//   - SA_RESTART: reiniciar syscalls interrompidas automaticamente
//   - sa_mask: bloquear outros sinais durante o handler
// ============================================================

procedure HandleSIGTERM(ASig: cint); cdecl;
begin
  GTerminating := True;
  // Nota: handlers de sinal devem ser signal-safe (async-signal-safe).
  // Modificar apenas variáveis voláteis do tipo Boolean/Integer é seguro.
end;

procedure HandleSIGHUP(ASig: cint); cdecl;
begin
  // SIGHUP: sinal convencional para reload de configuração
  GReloadCfg := True;
end;

procedure InstallSignalHandlers;
var
  LSA: SigActionRec;
begin
  FillChar(LSA, SizeOf(LSA), 0);

  // Handler SIGTERM (kill PID) e SIGINT (Ctrl+C)
  LSA.sa_Handler := @HandleSIGTERM;
  fpSigEmptySet(LSA.sa_mask);         // não bloquear outros sinais durante o handler
  LSA.sa_flags := SA_RESTART;         // reiniciar syscalls interrompidas (ex.: read())
  fpSigAction(SIGTERM, @LSA, nil);
  fpSigAction(SIGINT,  @LSA, nil);

  // Handler SIGHUP (kill -HUP PID) — reload de config
  LSA.sa_Handler := @HandleSIGHUP;
  fpSigAction(SIGHUP, @LSA, nil);

  // Ignorar SIGPIPE — importante para servidores com conexões TCP
  LSA.sa_Handler := SIG_IGN;
  fpSigEmptySet(LSA.sa_mask);
  LSA.sa_flags := 0;
  fpSigAction(SIGPIPE, @LSA, nil);

  // Ignorar SIGCHLD — evitar processos zombie se lançar filhos
  fpSigAction(SIGCHLD, @LSA, nil);
end;

// ============================================================
// Daemonização completa (double-fork)
//
// Sequência:
//   1. fork() #1 → pai termina, filho continua
//   2. setsid() → filho torna-se líder de nova sessão (sem terminal de controlo)
//   3. fork() #2 → garante que o processo nunca pode readquirir terminal
//   4. chdir('/') → não bloquear desmontagem de filesystems
//   5. Redirigir fd 0/1/2 para /dev/null
// ============================================================

procedure Daemonize;
var
  LPid: TPid;
  LFd : cint;
begin
  // Fork #1
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #1 falhou: errno=%d (%s)',
      [fpgeterrno(), SysErrorMessage(fpgeterrno())]);
  if LPid > 0 then
    Halt(0); // processo pai termina aqui

  // Nova sessão UNIX (setsid)
  if fpSetsid() < 0 then
    raise Exception.CreateFmt('fpSetsid() falhou: errno=%d (%s)',
      [fpgeterrno(), SysErrorMessage(fpgeterrno())]);

  // Fork #2 (opcional mas recomendado)
  LPid := fpFork();
  if LPid < 0 then
    raise Exception.CreateFmt('fpFork() #2 falhou: errno=%d (%s)',
      [fpgeterrno(), SysErrorMessage(fpgeterrno())]);
  if LPid > 0 then
    Halt(0); // segundo pai termina

  // Mudar directório de trabalho para /
  // (evita bloquear umount de filesystems montados)
  fpChDir('/');

  // Redirigir stdin (0), stdout (1), stderr (2) para /dev/null
  // Sequência: abrir /dev/null, dup2 para 0/1/2, fechar fd original
  LFd := fpOpen('/dev/null', O_RDWR);
  if LFd < 0 then
  begin
    // Falha não crítica — continuar sem redirecção
    WriteLn(StdErr, 'AVISO: não foi possível abrir /dev/null');
    Exit;
  end;

  fpDup2(LFd, 0); // stdin  → /dev/null
  fpDup2(LFd, 1); // stdout → /dev/null
  fpDup2(LFd, 2); // stderr → /dev/null

  if LFd > 2 then
    fpClose(LFd); // fechar fd extra (> 2)
end;

// ============================================================
// Parse de argumentos simples
// ============================================================

function HasArg(const A: string): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), A) then Exit(True);
end;

function ArgVal(const A, ADefault: string): string;
var I: Integer;
begin
  Result := ADefault;
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), A) then
    begin Result := ParamStr(I + 1); Exit; end;
end;

// ============================================================
// Lógica de negócio do daemon (substituir pelo código real)
// ============================================================

procedure LoadConfig;
begin
  LogInfo('Configuração carregada (simulação)');
  // Aqui: ler INI file, JSON, base de dados, etc.
end;

procedure DoWork(const AIteration: Int64);
begin
  // Trabalho real do daemon: processar filas, monitorizar ficheiros, etc.
  LogInfo(Format('Ciclo #%d — processando', [AIteration]));

  // Simular trabalho de 100ms (substituir por lógica real)
  SysUtils.Sleep(100);
end;

// ============================================================
// Entrada principal
// ============================================================

var
  LDaemon   : Boolean;
  LIteration: Int64;
begin
  LDaemon := HasArg('--daemon');

  // Instalar signal handlers ANTES do fork
  // (os handlers são preservados pelo fork no filho)
  InstallSignalHandlers;

  if LDaemon then
    Daemonize;

  // Abrir log APÓS daemonização (PID correcto, stdout já redirigido)
  OpenLog(ArgVal('--log', DEFAULT_LOG));

  try
    LogInfo(Format('%s iniciando (modo=%s, compilador=FPC)',
      [DAEMON_NAME, IfThen(LDaemon, 'daemon', 'foreground')]));

    // Carregar configuração inicial
    LoadConfig;

    // Registar PID
    WritePID;
    LogInfo(Format('PID=%d registado em %s', [Integer(fpGetPID()), PID_FILE]));

    // ──────────────────────────────────────────────
    // Loop principal
    // ──────────────────────────────────────────────
    LIteration := 0;
    while not GTerminating do
    begin
      // Verificar pedido de reload (SIGHUP)
      if GReloadCfg then
      begin
        GReloadCfg := False;
        LogInfo('SIGHUP recebido — recarregando configuração');
        try
          LoadConfig;
        except
          on E: Exception do
            LogError('Erro ao recarregar config: ' + E.Message);
        end;
      end;

      Inc(LIteration);
      try
        DoWork(LIteration);
      except
        on E: Exception do
          LogError(Format('Erro em DoWork() iteração #%d: %s', [LIteration, E.Message]));
      end;

      // Dormir o restante do intervalo
      // Usar SysUtils.Sleep (não Unix.sleep) para poder ser interrompido por sinal
      // com SA_RESTART, ou usar nanosleep para granularidade maior
      if not GTerminating then
        SysUtils.Sleep(LOOP_SLEEP_MS);
    end;
    // ──────────────────────────────────────────────

    LogInfo('SIGTERM recebido — terminando normalmente');

  except
    on E: Exception do
    begin
      LogError('Excepção fatal: ' + E.Message);
      ExitCode := 1;
    end;
  end;

  // Cleanup garantido (finally implícito via try/except acima)
  RemovePID;
  LogInfo(Format('%s terminado (ExitCode=%d)', [DAEMON_NAME, ExitCode]));
  CloseLog;

  Halt(ExitCode);
end.
