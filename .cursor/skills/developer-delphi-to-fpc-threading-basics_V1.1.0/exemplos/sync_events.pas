program sync_events;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

// ============================================================
// Exemplo: TEvent e TMREWSync
//
// TEvent — sinalizar entre threads (ex.: "dado pronto", "parar")
// TMREWSync — multiple readers / exclusive writer lock
//
// Compilar:
//   dcc32 sync_events.pas
//   dcc64 sync_events.pas
// ============================================================

// ============================================================
// PARTE 1: TEvent — carga inicial de dados
//
// Cenario: Thread de inicializacao carrega dados do "banco".
// A main thread aguarda o sinal antes de continuar.
// ============================================================

type
  TInicializador = class(TThread)
  private
    FEventoPronto: TEvent;
    FDados: TList<Integer>;
  protected
    procedure Execute; override;
  public
    constructor Create(AEvento: TEvent; ADados: TList<Integer>);
  end;

constructor TInicializador.Create(AEvento: TEvent; ADados: TList<Integer>);
begin
  inherited Create(True);
  FEventoPronto := AEvento;
  FDados        := ADados;
  FreeOnTerminate := False;
end;

procedure TInicializador.Execute;
var
  I: Integer;
begin
  WriteLn('[INIT] Carregando dados...');
  Sleep(400);  // simula carga do banco

  for I := 1 to 5 do
    FDados.Add(I * 10);

  WriteLn('[INIT] Dados prontos. Sinalizando evento.');
  FEventoPronto.SetEvent;  // libera quem estiver em WaitFor
end;

procedure DemonstrarTEvent;
var
  Evento: TEvent;
  Dados : TList<Integer>;
  Init  : TInicializador;
  V     : Integer;
begin
  WriteLn('=== TEvent — Aguardar inicializacao ===');

  // ManualReset=False: auto-reset apos liberar a primeira thread
  // InitialState=False: comeca nao sinalizado
  Evento := TEvent.Create(nil, {ManualReset=}False, {Initial=}False, '');
  Dados  := TList<Integer>.Create;
  try
    Init := TInicializador.Create(Evento, Dados);
    try
      Init.Start;

      WriteLn('[MAIN] Aguardando inicializacao (timeout 2s)...');
      case Evento.WaitFor(2000) of
        wrSignaled:
        begin
          Write('[MAIN] Dados recebidos: ');
          for V in Dados do Write(V, ' ');
          WriteLn;
        end;
        wrTimeout:
          WriteLn('[MAIN] TIMEOUT — inicializacao nao concluiu em 2s');
        wrAbandoned:
          WriteLn('[MAIN] Evento abandonado');
        wrError:
          WriteLn('[MAIN] Erro no evento');
      end;

      Init.WaitFor;
    finally
      Init.Free;
    end;
  finally
    Dados.Free;
    Evento.Free;
  end;
end;

// ============================================================
// PARTE 2: TEvent manual reset — broadcast para multiplas threads
// ============================================================

procedure DemonstrarManualReset;
const
  N = 3;
var
  Sinal  : TEvent;
  Threads: array[0..N-1] of TThread;
  Lock   : TCriticalSection;
  I      : Integer;
begin
  WriteLn;
  WriteLn('=== TEvent ManualReset — liberar N threads simultaneamente ===');

  // ManualReset=True: permanece sinalizado ate ResetEvent ser chamado
  // Todas as threads em WaitFor sao liberadas simultaneamente
  Sinal := TEvent.Create(nil, {ManualReset=}True, {Initial=}False, '');
  Lock  := TCriticalSection.Create;
  try
    for I := 0 to N - 1 do
    begin
      var Indice := I;
      Threads[Indice] := TThread.CreateAnonymousThread(procedure
      begin
        Lock.Enter; try WriteLn(Format('[WORKER %d] Aguardando largada...', [Indice])); finally Lock.Leave; end;
        Sinal.WaitFor(INFINITE);
        Lock.Enter; try WriteLn(Format('[WORKER %d] Largada! Executando.', [Indice])); finally Lock.Leave; end;
        Sleep(100 + Indice * 50);
        Lock.Enter; try WriteLn(Format('[WORKER %d] Concluido.', [Indice])); finally Lock.Leave; end;
      end);
      Threads[Indice].FreeOnTerminate := False;
      Threads[Indice].Start;
    end;

    Sleep(200);  // aguardar threads chegarem ao WaitFor
    WriteLn('[MAIN] Dando largada para todas as threads...');
    Sinal.SetEvent;  // libera TODAS simultaneamente (ManualReset)

    for I := 0 to N - 1 do
    begin
      Threads[I].WaitFor;
      Threads[I].Free;
    end;

    Sinal.ResetEvent;  // preparar para reusar o evento
    WriteLn('[MAIN] Evento resetado.');
  finally
    Lock.Free;
    Sinal.Free;
  end;
end;

// ============================================================
// PARTE 3: TMREWSync — cache com multiplos leitores, 1 escritor
// ============================================================

type
  TCache = class
  private
    FLock  : TMREWSync;
    FDados : TDictionary<string, string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Escrever(const Chave, Valor: string);
    function  Ler(const Chave: string): string;
  end;

constructor TCache.Create;
begin
  inherited;
  FLock  := TMREWSync.Create;
  FDados := TDictionary<string, string>.Create;
end;

destructor TCache.Destroy;
begin
  FDados.Free;
  FLock.Free;
  inherited;
end;

procedure TCache.Escrever(const Chave, Valor: string);
begin
  FLock.BeginWrite;   // exclusivo: bloqueia leitores e outros escritores
  try
    FDados.AddOrSetValue(Chave, Valor);
  finally
    FLock.EndWrite;
  end;
end;

function TCache.Ler(const Chave: string): string;
begin
  FLock.BeginRead;    // compartilhado: multiplos leitores simultaneos
  try
    if not FDados.TryGetValue(Chave, Result) then
      Result := '(nao encontrado)';
  finally
    FLock.EndRead;
  end;
end;

procedure DemonstrarMREW;
const
  N_LEITORES = 3;
var
  Cache  : TCache;
  Leitores: array[0..N_LEITORES-1] of TThread;
  Escritor: TThread;
  ConsoleLock: TCriticalSection;
  I: Integer;
begin
  WriteLn;
  WriteLn('=== TMREWSync — Multiplos leitores, 1 escritor ===');

  Cache       := TCache.Create;
  ConsoleLock := TCriticalSection.Create;
  try
    Cache.Escrever('versao', '1.0');  // escrita inicial

    // Criar leitores concorrentes
    for I := 0 to N_LEITORES - 1 do
    begin
      var Indice := I;
      Leitores[Indice] := TThread.CreateAnonymousThread(procedure
      var
        J: Integer;
        V: string;
      begin
        for J := 1 to 3 do
        begin
          V := Cache.Ler('versao');
          ConsoleLock.Enter;
          try
            WriteLn(Format('[LEITOR %d] versao = %s', [Indice, V]));
          finally
            ConsoleLock.Leave;
          end;
          Sleep(80);
        end;
      end);
      Leitores[Indice].FreeOnTerminate := False;
      Leitores[Indice].Start;
    end;

    // Escritor concorrente
    Escritor := TThread.CreateAnonymousThread(procedure
    var
      K: Integer;
    begin
      for K := 1 to 2 do
      begin
        Sleep(120);
        Cache.Escrever('versao', Format('1.%d', [K]));
        ConsoleLock.Enter;
        try
          WriteLn(Format('[ESCRITOR] Atualizou versao para 1.%d', [K]));
        finally
          ConsoleLock.Leave;
        end;
      end;
    end);
    Escritor.FreeOnTerminate := False;
    Escritor.Start;

    // Aguardar todos
    for I := 0 to N_LEITORES - 1 do
    begin
      Leitores[I].WaitFor;
      Leitores[I].Free;
    end;
    Escritor.WaitFor;
    Escritor.Free;

  finally
    ConsoleLock.Free;
    Cache.Free;
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  DemonstrarTEvent;
  DemonstrarManualReset;
  DemonstrarMREW;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
