program tthread_basico;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils;

// ============================================================
// Exemplo: TThread basico — Execute, Synchronize, Queue,
//          Terminate/Terminated, FreeOnTerminate
//
// Compilar:
//   dcc32 tthread_basico.pas
//   dcc64 tthread_basico.pas
// ============================================================

type
  // ----------------------------------------------------------
  // Worker que processa itens numerados e reporta progresso
  // ----------------------------------------------------------
  TProgressoEvent = procedure(AValor: Integer; const AMensagem: string) of object;

  TWorkerThread = class(TThread)
  private
    FTotalItens   : Integer;
    FOnProgresso  : TProgressoEvent;
    FItemAtual    : Integer;
    FMensagemAtual: string;

    procedure DoProgresso;  // chamado via Synchronize na main thread
  protected
    procedure Execute; override;
  public
    constructor Create(ATotalItens: Integer; AOnProgresso: TProgressoEvent);
    property OnProgresso: TProgressoEvent read FOnProgresso write FOnProgresso;
  end;

// ----------------------------------------------------------
constructor TWorkerThread.Create(ATotalItens: Integer; AOnProgresso: TProgressoEvent);
begin
  inherited Create(True);            // True = suspenso; chamar Start manualmente
  FTotalItens  := ATotalItens;
  FOnProgresso := AOnProgresso;
  FreeOnTerminate := False;          // False = controlamos o ciclo de vida
  Priority := tpNormal;
end;

procedure TWorkerThread.DoProgresso;
begin
  // Este procedimento roda na main thread (chamado via Synchronize)
  if Assigned(FOnProgresso) then
    FOnProgresso(FItemAtual, FMensagemAtual);
end;

procedure TWorkerThread.Execute;
var
  I: Integer;
begin
  for I := 1 to FTotalItens do
  begin
    // Verificar se foi pedido cancelamento
    if Terminated then
    begin
      FItemAtual    := I;
      FMensagemAtual := Format('Cancelado em %d/%d', [I, FTotalItens]);
      // Queue: nao bloqueia a thread, enfileira para main thread
      Queue(procedure
      begin
        if Assigned(FOnProgresso) then
          FOnProgresso(-1, 'Worker cancelado pelo usuario');
      end);
      Break;
    end;

    // Simular trabalho
    Sleep(200);

    // Preparar dados para reportar (campos privados — acesso seguro aqui
    // porque DoProgresso so eh chamado via Synchronize, nao concorrentemente)
    FItemAtual    := I;
    FMensagemAtual := Format('Processando item %d de %d', [I, FTotalItens]);

    // Synchronize: BLOQUEIA esta thread ate que DoProgresso termine na main thread
    // Usar quando o resultado da UI e necessario antes de continuar
    Synchronize(DoProgresso);

    // Alternativa com procedimento anonimo (nao bloqueante):
    // Queue(procedure
    // begin
    //   WriteLn(Format('[UI] Item %d concluido', [I]));
    // end);
  end;

  // Notificacao final — nao precisa esperar (nao temos mais trabalho apos isso)
  if not Terminated then
  begin
    Queue(procedure
    begin
      WriteLn('[UI] Worker concluiu todos os itens.');
    end);
  end;
end;

// ----------------------------------------------------------
// Simulacao de "main thread" em console
// ----------------------------------------------------------

procedure OnProgresso(AValor: Integer; const AMensagem: string);
begin
  if AValor = -1 then
    WriteLn('[PROGRESSO] ' + AMensagem)
  else
    WriteLn(Format('[PROGRESSO %3d%%] %s', [AValor * 10, AMensagem]));
end;

var
  Worker: TWorkerThread;
begin
  WriteLn('=== Exemplo TThread Basico ===');
  WriteLn;

  Worker := TWorkerThread.Create(5, OnProgresso);
  try
    Worker.Start;

    // Simular cancelamento apos 700 ms
    // Em aplicacao real: botao "Cancelar" chama Worker.Terminate
    Sleep(750);
    WriteLn('[MAIN] Solicitando cancelamento...');
    Worker.Terminate;   // Sinaliza Terminated := True — nao e forcado

    // Aguardar a thread finalizar graciosamente
    Worker.WaitFor;
    WriteLn('[MAIN] Worker finalizado. ExitCode: ' + IntToStr(Worker.ReturnValue));
  finally
    Worker.Free;        // FreeOnTerminate = False: liberamos manualmente
  end;

  WriteLn;
  WriteLn('=== Thread anonima (fire-and-forget) ===');

  var TAnonima := TThread.CreateAnonymousThread(procedure
  begin
    Sleep(100);
    // Queue sem referencia a TThread especifica: usa nil (main thread)
    TThread.Queue(nil, procedure
    begin
      WriteLn('[ANONIMA] Concluida e notificou main thread.');
    end);
  end);
  TAnonima.FreeOnTerminate := True;
  TAnonima.Start;

  Sleep(300);  // aguardar a anonima (em app real: use evento ou WaitFor)
  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
