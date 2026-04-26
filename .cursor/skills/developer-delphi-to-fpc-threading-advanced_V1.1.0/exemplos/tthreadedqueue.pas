program tthreadedqueue;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Threading,
  System.Generics.Collections;

// ============================================================
// Exemplo: TThreadedQueue<T> — produtor-consumidor N:M
//
// TThreadedQueue<T> e uma fila thread-safe embutida no RTL do Delphi.
// Suporta:
//   - PushItem: inserir (bloqueia se fila cheia)
//   - PopItem:  remover (bloqueia se fila vazia)
//   - DoShutDown: sinalizar encerramento
//
// Compilar:
//   dcc32 tthreadedqueue.pas
//   dcc64 tthreadedqueue.pas
// ============================================================

const
  CAPACIDADE     = 20;    // maximo de itens na fila
  NUM_PRODUTORES = 2;
  NUM_CONSUMIDORES = 3;
  ITENS_POR_PRODUTOR = 10;

type
  TItemTrabalho = record
    ProdutorId: Integer;
    Sequencia : Integer;
    Payload   : string;
  end;

var
  GLock: TCriticalSection;

procedure Log(const S: string);
begin
  GLock.Enter;
  try WriteLn(S);
  finally GLock.Leave;
  end;
end;

// ----------------------------------------------------------
// Parte 1: Uso basico de TThreadedQueue<string>
// ----------------------------------------------------------
procedure DemonstrarBasico;
var
  Q: TThreadedQueue<string>;
  Produtor, Consumidor: TThread;
  Item: string;
begin
  WriteLn('--- TThreadedQueue<string> basico ---');

  // Criar fila: (capacidade, push_timeout_ms, pop_timeout_ms)
  Q := TThreadedQueue<string>.Create(10, INFINITE, 500);
  try
    // Produtor
    Produtor := TThread.CreateAnonymousThread(procedure
    var I: Integer;
    begin
      for I := 1 to 5 do
      begin
        Sleep(80);
        var R := Q.PushItem(Format('msg-%d', [I]));
        Log(Format('[PROD] PushItem msg-%d: %s', [I, GetEnumName(TypeInfo(TWaitResult), Ord(R))]));
      end;
      // Sentinela para encerrar o consumidor
      Q.PushItem('FIM');
    end);

    // Consumidor
    Consumidor := TThread.CreateAnonymousThread(procedure
    var Item: string;
    var Res : TWaitResult;
    begin
      while True do
      begin
        Res := Q.PopItem(Item);
        if Res = wrSignaled then
        begin
          if Item = 'FIM' then Break;
          Log(Format('[CONS] Processou: %s', [Item]));
          Sleep(60);
        end
        else if Res = wrAbandoned then
          Break;
        // wrTimeout: tentar novamente (loop continua)
      end;
      Log('[CONS] Encerrado.');
    end);

    Produtor.FreeOnTerminate   := False;
    Consumidor.FreeOnTerminate := False;

    Consumidor.Start;
    Produtor.Start;

    Produtor.WaitFor;
    Consumidor.WaitFor;
    Produtor.Free;
    Consumidor.Free;
  finally
    Q.Free;
  end;
end;

// ----------------------------------------------------------
// Parte 2: N produtores, M consumidores com fila tipada
// ----------------------------------------------------------
procedure DemonstrarNxM;
var
  Q        : TThreadedQueue<TItemTrabalho>;
  Produtores: array[0..NUM_PRODUTORES-1] of ITask;
  Consumidores: array[0..NUM_CONSUMIDORES-1] of ITask;
  Processados: Integer;
  I          : Integer;
begin
  WriteLn;
  WriteLn(Format('--- %dxM: %d produtores x %d consumidores ---',
    [NUM_PRODUTORES, NUM_PRODUTORES, NUM_CONSUMIDORES]));

  Q := TThreadedQueue<TItemTrabalho>.Create(CAPACIDADE, 2000, 500);
  Processados := 0;
  try
    // Criar e iniciar produtores
    for I := 0 to NUM_PRODUTORES - 1 do
    begin
      var ProdId := I + 1;
      Produtores[I] := TTask.Run(procedure
      var J: Integer; Item: TItemTrabalho;
      begin
        for J := 1 to ITENS_POR_PRODUTOR do
        begin
          Item.ProdutorId := ProdId;
          Item.Sequencia  := J;
          Item.Payload    := Format('P%d-S%d', [ProdId, J]);
          Sleep(30 + ProdId * 10);
          var R := Q.PushItem(Item);
          if R = wrSignaled then
            Log(Format('[PROD %d] PushItem S%d OK (fila=%d)', [ProdId, J, Q.QueueSize]))
          else
            Log(Format('[PROD %d] PushItem FALHOU: %s', [ProdId, GetEnumName(TypeInfo(TWaitResult), Ord(R))]));
        end;
        Log(Format('[PROD %d] Producao concluida.', [ProdId]));
      end);
    end;

    // Criar e iniciar consumidores
    for I := 0 to NUM_CONSUMIDORES - 1 do
    begin
      var ConsId := I + 1;
      Consumidores[I] := TTask.Run(procedure
      var Item: TItemTrabalho; Res: TWaitResult;
      begin
        while True do
        begin
          Res := Q.PopItem(Item);
          case Res of
            wrSignaled:
            begin
              if Item.ProdutorId = -1 then  // sentinela
              begin
                Log(Format('[CONS %d] Sentinela recebida — encerrando.', [ConsId]));
                Break;
              end;
              Sleep(50);  // simula processamento
              TInterlocked.Increment(Processados);
              Log(Format('[CONS %d] Processou %s (total=%d)', [ConsId, Item.Payload, Processados]));
            end;
            wrTimeout  : { sem item — recheck loop };
            wrAbandoned: Break;  // DoShutDown chamado
            wrError    : Break;
          end;
        end;
      end);
    end;

    // Aguardar produtores
    TTask.WaitForAll(Produtores);
    Log('[MAIN] Todos produtores concluiram. Enviando sentinelas...');

    // Enviar sentinela para cada consumidor
    for I := 1 to NUM_CONSUMIDORES do
    begin
      var Sentinela: TItemTrabalho;
      Sentinela.ProdutorId := -1;
      Sentinela.Sequencia  := 0;
      Sentinela.Payload    := 'FIM';
      Q.PushItem(Sentinela);
    end;

    // Aguardar consumidores
    TTask.WaitForAll(Consumidores);

  finally
    Q.Free;
  end;

  WriteLn(Format('[MAIN] Total processado: %d de %d esperado.',
    [Processados, NUM_PRODUTORES * ITENS_POR_PRODUTOR]));
end;

// ----------------------------------------------------------
// Parte 3: DoShutDown para encerramento forcado
// ----------------------------------------------------------
procedure DemonstrarShutDown;
var
  Q: TThreadedQueue<Integer>;
  T: ITask;
begin
  WriteLn;
  WriteLn('--- DoShutDown para encerramento forcado ---');

  Q := TThreadedQueue<Integer>.Create(5, INFINITE, INFINITE);
  try
    T := TTask.Run(procedure
    var Item: Integer; Res: TWaitResult;
    begin
      while True do
      begin
        Res := Q.PopItem(Item);  // bloqueia com INFINITE
        if Res = wrAbandoned then
        begin
          Log('[TASK] PopItem retornou wrAbandoned — encerrando.');
          Break;
        end;
        if Res = wrSignaled then
          Log(Format('[TASK] Recebeu item: %d', [Item]));
      end;
    end);

    Q.PushItem(1);
    Q.PushItem(2);
    Sleep(100);

    Log('[MAIN] Chamando DoShutDown...');
    Q.DoShutDown;   // faz PopItem retornar wrAbandoned para todos em espera

    T.Wait;
    Log(Format('[MAIN] Fila: pushed=%d popped=%d',
      [Q.TotalItemsPushed, Q.TotalItemsPopped]));
  finally
    Q.Free;
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Exemplos TThreadedQueue<T> ===');
    WriteLn;

    DemonstrarBasico;
    DemonstrarNxM;
    DemonstrarShutDown;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
