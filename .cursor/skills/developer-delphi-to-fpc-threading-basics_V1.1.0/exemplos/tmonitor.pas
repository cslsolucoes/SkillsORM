program tmonitor;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

// ============================================================
// Exemplo: TMonitor — Enter/Exit, Wait, Pulse, PulseAll
//
// Demonstra produtor-consumidor usando TMonitor sobre
// um objeto TQueue<string> compartilhado.
//
// TMonitor e baseado em "object-level locking" — nao e necessario
// criar um objeto TCriticalSection separado; o proprio objeto
// serve como mutex e variavel de condicao.
//
// Compilar:
//   dcc32 tmonitor.pas
//   dcc64 tmonitor.pas
// ============================================================

const
  TOTAL_MENSAGENS = 10;  // quantas mensagens o produtor envia

type
  TFila = TQueue<string>;

  // ----------------------------------------------------------
  // Thread produtora — gera mensagens e as enfileira
  // ----------------------------------------------------------
  TProdutor = class(TThread)
  private
    FFila: TFila;
  protected
    procedure Execute; override;
  public
    constructor Create(AFila: TFila);
  end;

  // ----------------------------------------------------------
  // Thread consumidora — retira mensagens da fila e processa
  // ----------------------------------------------------------
  TConsumidor = class(TThread)
  private
    FFila   : TFila;
    FParar  : Boolean;  // sinal de encerramento
  protected
    procedure Execute; override;
  public
    constructor Create(AFila: TFila);
    procedure Parar;   // chamado pela main thread para encerrar
  end;

// ------ Produtor ------

constructor TProdutor.Create(AFila: TFila);
begin
  inherited Create(True);
  FFila := AFila;
  FreeOnTerminate := False;
end;

procedure TProdutor.Execute;
var
  I: Integer;
  Msg: string;
begin
  for I := 1 to TOTAL_MENSAGENS do
  begin
    if Terminated then Break;
    Sleep(150);  // simula geracao de dado

    Msg := Format('Mensagem %d de %d', [I, TOTAL_MENSAGENS]);

    // --- Produtor: adquire lock, enfileira, pulsa consumidor ---
    TMonitor.Enter(FFila);
    try
      FFila.Enqueue(Msg);
      WriteLn(Format('[PRODUTOR] Enfileirou: %s  (fila=%d)', [Msg, FFila.Count]));
      TMonitor.Pulse(FFila);  // acorda UM consumidor bloqueado em Wait
    finally
      TMonitor.Exit(FFila);
    end;
    // -----------------------------------------------------------
  end;
  WriteLn('[PRODUTOR] Concluiu producao.');
end;

// ------ Consumidor ------

constructor TConsumidor.Create(AFila: TFila);
begin
  inherited Create(True);
  FFila  := AFila;
  FParar := False;
  FreeOnTerminate := False;
end;

procedure TConsumidor.Parar;
begin
  // Sinaliza que deve encerrar e acorda a thread caso esteja em Wait
  TMonitor.Enter(FFila);
  try
    FParar := True;
    TMonitor.PulseAll(FFila);  // garante que o consumidor acorda para ver FParar
  finally
    TMonitor.Exit(FFila);
  end;
end;

procedure TConsumidor.Execute;
var
  Item: string;
begin
  while True do
  begin
    // --- Consumidor: adquire lock, espera item, consome ---
    TMonitor.Enter(FFila);
    try
      // SEMPRE usar loop while — protege contra spurious wakeups
      while (FFila.Count = 0) and not FParar do
        TMonitor.Wait(FFila, INFINITE);  // libera lock, dorme; acorda com Pulse

      if FParar and (FFila.Count = 0) then
        Break;  // encerramento solicitado e fila vazia

      Item := FFila.Dequeue;
    finally
      TMonitor.Exit(FFila);
    end;
    // -----------------------------------------------------

    // Processar o item FORA do lock (nao bloqueia o produtor durante o processamento)
    Sleep(200);  // simula processamento
    WriteLn(Format('[CONSUMIDOR] Processou: %s', [Item]));
  end;
  WriteLn('[CONSUMIDOR] Encerrado.');
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
var
  Fila     : TFila;
  Produtor : TProdutor;
  Consumidor: TConsumidor;
begin
  WriteLn('=== Exemplo TMonitor — Produtor/Consumidor ===');
  WriteLn;

  Fila := TFila.Create;
  try
    Consumidor := TConsumidor.Create(Fila);
    Produtor   := TProdutor.Create(Fila);
    try
      Consumidor.Start;
      Produtor.Start;

      // Aguardar produtor terminar
      Produtor.WaitFor;

      // Sinalizar consumidor para encerrar apos processar o que sobrou
      Consumidor.Parar;
      Consumidor.WaitFor;

    finally
      Produtor.Free;
      Consumidor.Free;
    end;
  finally
    Fila.Free;
  end;

  WriteLn;
  WriteLn('Fila processada com sucesso. Pressione Enter.');
  ReadLn;
end.
