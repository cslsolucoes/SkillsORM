unit TEMPLATE_worker_thread;

// ============================================================
// TEMPLATE: Worker Thread com fila de tarefas e Synchronize/Queue para UI
//
// Como usar:
//   1. Copie esta unit para seu projeto
//   2. Renomeie a unit e a classe (TWorkerThread → TMinhaThread)
//   3. Implemente ProcessarItem conforme sua necessidade
//   4. Ajuste TItemFila com os campos que seu trabalho requer
//   5. Remova os comentários de instrução antes de colocar em produção
//
// Compilar:
//   dcc32 TEMPLATE_worker_thread.pas   (requer programa principal)
//   dcc64 TEMPLATE_worker_thread.pas
// ============================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

type
  // ----------------------------------------------------------
  // Tipo do item que a thread processa
  // Substituir pelos campos necessários
  // ----------------------------------------------------------
  TItemFila = record
    Id    : Integer;
    Dados : string;
    // Adicione campos conforme necessário
  end;

  // ----------------------------------------------------------
  // Eventos de callback para a UI (executados na main thread)
  // ----------------------------------------------------------
  TWorkerProgressoEvent = procedure(AProgresso: Integer; const AMensagem: string) of object;
  TWorkerConcluidoEvent = procedure(ASucesso: Boolean; const AMensagem: string) of object;
  TWorkerErroEvent      = procedure(const AErro: string) of object;

  // ----------------------------------------------------------
  // Worker Thread principal
  // ----------------------------------------------------------
  TWorkerThread = class(TThread)
  private
    // ---- Fila de trabalho (thread-safe via TMonitor) ----
    FFila       : TQueue<TItemFila>;
    FFilaParar  : Boolean;            // sinal de encerramento

    // ---- Estado de progresso (escrito pela thread, lido via callbacks) ----
    FProgresso  : Integer;
    FMensagem   : string;
    FSucesso    : Boolean;
    FErro       : string;

    // ---- Callbacks para a UI ----
    FOnProgresso: TWorkerProgressoEvent;
    FConcluido  : TWorkerConcluidoEvent;
    FOnErro     : TWorkerErroEvent;

    // ---- Métodos internos ----
    procedure NotificarProgresso(AProgresso: Integer; const AMensagem: string);
    procedure NotificarConcluido(ASucesso: Boolean; const AMensagem: string);
    procedure NotificarErro(const AErro: string);

    function  ObterProximoItem(out AItem: TItemFila): Boolean;

  protected
    procedure Execute; override;

    // ---- Override para lógica específica ----
    // IMPLEMENTAR: processar um item da fila
    procedure ProcessarItem(const AItem: TItemFila); virtual;

  public
    constructor Create;
    destructor Destroy; override;

    // ---- API pública ----
    procedure EnfileirarItem(const AItem: TItemFila);
    procedure Encerrar;       // pede parada graciosamente após processar itens pendentes
    procedure EncerrarImediato; // cancela imediatamente (Terminated = True)

    // ---- Eventos (configurar antes de Start) ----
    property OnProgresso: TWorkerProgressoEvent read FOnProgresso write FOnProgresso;
    property OnConcluido: TWorkerConcluidoEvent read FConcluido  write FConcluido;
    property OnErro     : TWorkerErroEvent      read FOnErro     write FOnErro;
  end;

implementation

// ----------------------------------------------------------
// Construtor / Destrutor
// ----------------------------------------------------------

constructor TWorkerThread.Create;
begin
  inherited Create(True);     // True = suspenso; chamar Start após configurar eventos
  FFila      := TQueue<TItemFila>.Create;
  FFilaParar := False;
  FSucesso   := True;
  FreeOnTerminate := False;   // controlamos o ciclo de vida
end;

destructor TWorkerThread.Destroy;
begin
  FFila.Free;
  inherited;
end;

// ----------------------------------------------------------
// Encerramento
// ----------------------------------------------------------

procedure TWorkerThread.Encerrar;
begin
  // Sinaliza parada: thread processa itens pendentes e então sai
  TMonitor.Enter(FFila);
  try
    FFilaParar := True;
    TMonitor.PulseAll(FFila);
  finally
    TMonitor.Exit(FFila);
  end;
end;

procedure TWorkerThread.EncerrarImediato;
begin
  Terminate;      // Terminated := True (verifica no loop de Execute)
  Encerrar;       // acorda a thread caso esteja em Wait
end;

// ----------------------------------------------------------
// Enfileirar item (chamado de qualquer thread)
// ----------------------------------------------------------

procedure TWorkerThread.EnfileirarItem(const AItem: TItemFila);
begin
  TMonitor.Enter(FFila);
  try
    if FFilaParar then
      raise EInvalidOperation.Create('Worker encerrado: não aceita novos itens');
    FFila.Enqueue(AItem);
    TMonitor.Pulse(FFila);    // acorda a thread se estiver em Wait
  finally
    TMonitor.Exit(FFila);
  end;
end;

// ----------------------------------------------------------
// Obter próximo item da fila (bloqueia até haver item ou parar)
// ----------------------------------------------------------

function TWorkerThread.ObterProximoItem(out AItem: TItemFila): Boolean;
begin
  Result := False;
  TMonitor.Enter(FFila);
  try
    while (FFila.Count = 0) and not FFilaParar and not Terminated do
      TMonitor.Wait(FFila, 500);  // 500ms timeout para verificar Terminated

    if Terminated or (FFilaParar and (FFila.Count = 0)) then
      Exit;   // Result = False → thread deve encerrar

    AItem  := FFila.Dequeue;
    Result := True;
  finally
    TMonitor.Exit(FFila);
  end;
end;

// ----------------------------------------------------------
// Loop principal de execução
// ----------------------------------------------------------

procedure TWorkerThread.Execute;
var
  Item      : TItemFila;
  ItensTotais: Integer;
  ItensFeitos: Integer;
begin
  ItensTotais := 0;  // incrementar à medida que itens chegam se quiser % real
  ItensFeitos := 0;

  NotificarProgresso(0, 'Worker iniciado');

  try
    while not Terminated do
    begin
      if not ObterProximoItem(Item) then
        Break;   // parada sinalizada ou Terminated

      Inc(ItensFeitos);

      try
        // ---- Processar o item ----
        ProcessarItem(Item);
        // -------------------------

        NotificarProgresso(ItensFeitos, Format('Item %d processado: %s', [Item.Id, Item.Dados]));

      except
        on E: Exception do
        begin
          FSucesso := False;
          FErro    := Format('Erro no item %d: %s', [Item.Id, E.Message]);
          NotificarErro(FErro);
          // Continua processando itens restantes (remova se quiser abortar)
        end;
      end;
    end;

    if FSucesso then
      NotificarConcluido(True,  Format('Worker concluiu %d itens com sucesso', [ItensFeitos]))
    else
      NotificarConcluido(False, Format('Worker concluiu com erros após %d itens', [ItensFeitos]));

  except
    on E: Exception do
    begin
      NotificarErro('Erro fatal no worker: ' + E.Message);
      NotificarConcluido(False, 'Worker abortou por erro fatal');
    end;
  end;
end;

// ----------------------------------------------------------
// ProcessarItem — IMPLEMENTAR nesta unit ou em descendente
// ----------------------------------------------------------

procedure TWorkerThread.ProcessarItem(const AItem: TItemFila);
begin
  // TODO: implementar lógica real
  // Exemplo:
  Sleep(100);  // simula trabalho
  // DAO.Salvar(AItem.Dados);
  // RelatorioBuilder.AdicionarLinha(AItem);
end;

// ----------------------------------------------------------
// Notificações para a UI (via Queue — não bloqueante)
// ----------------------------------------------------------

procedure TWorkerThread.NotificarProgresso(AProgresso: Integer; const AMensagem: string);
begin
  if Assigned(FOnProgresso) then
  begin
    var P := AProgresso;
    var M := AMensagem;
    Queue(procedure
    begin
      if Assigned(FOnProgresso) then
        FOnProgresso(P, M);
    end);
  end;
end;

procedure TWorkerThread.NotificarConcluido(ASucesso: Boolean; const AMensagem: string);
begin
  if Assigned(FConcluido) then
  begin
    var S := ASucesso;
    var M := AMensagem;
    Queue(procedure
    begin
      if Assigned(FConcluido) then
        FConcluido(S, M);
    end);
  end;
end;

procedure TWorkerThread.NotificarErro(const AErro: string);
begin
  if Assigned(FOnErro) then
  begin
    var E := AErro;
    Queue(procedure
    begin
      if Assigned(FOnErro) then
        FOnErro(E);
    end);
  end;
end;

end.

// ============================================================
// EXEMPLO DE USO (Form ou DataModule):
//
// var FWorker: TWorkerThread;
//
// procedure TForm1.BtnIniciarClick(Sender: TObject);
// var Item: TItemFila;
// begin
//   FWorker := TWorkerThread.Create;
//   FWorker.OnProgresso := HandleProgresso;
//   FWorker.OnConcluido := HandleConcluido;
//   FWorker.OnErro      := HandleErro;
//   FWorker.Start;
//
//   Item.Id    := 1;
//   Item.Dados := 'Primeiro item';
//   FWorker.EnfileirarItem(Item);
//
//   FWorker.Encerrar;   // sinaliza que não haverá mais itens
// end;
//
// procedure TForm1.HandleProgresso(AProgresso: Integer; const AMensagem: string);
// begin
//   ProgressBar1.Position := AProgresso;
//   StatusBar1.SimpleText  := AMensagem;
// end;
//
// procedure TForm1.HandleConcluido(ASucesso: Boolean; const AMensagem: string);
// begin
//   FWorker.Free;
//   FWorker := nil;
//   ShowMessage(AMensagem);
// end;
//
// procedure TForm1.HandleErro(const AErro: string);
// begin
//   Memo1.Lines.Add('[ERRO] ' + AErro);
// end;
// ============================================================
