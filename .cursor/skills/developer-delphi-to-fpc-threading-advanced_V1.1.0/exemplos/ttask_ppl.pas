program ttask_ppl;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs;

// ============================================================
// Exemplo: TTask (PPL) — Run, Wait, WaitForAll, WaitForAny,
//          TTask<T> (Future), TCancellationTokenSource
//
// Compilar:
//   dcc32 ttask_ppl.pas
//   dcc64 ttask_ppl.pas
// ============================================================

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
// Parte 1: TTask.Run basico e Wait
// ----------------------------------------------------------
procedure DemonstrarTaskBasico;
var
  T: ITask;
begin
  WriteLn('--- TTask.Run e Wait ---');

  T := TTask.Run(procedure
  begin
    Log('[TASK] Iniciou trabalho');
    Sleep(300);
    Log('[TASK] Concluiu trabalho');
  end);

  Log('[MAIN] Task criada — fazendo outras coisas...');
  Sleep(100);
  Log('[MAIN] Aguardando task...');

  T.Wait;   // bloqueia ate T terminar

  Log('[MAIN] Task concluida. Status: ' + IntToStr(Ord(T.Status)));
  // TTaskStatus.Completed = 5
end;

// ----------------------------------------------------------
// Parte 2: WaitForAll — multiplas tasks em paralelo
// ----------------------------------------------------------
procedure DemonstrarWaitForAll;
var
  T1, T2, T3: ITask;
  Inicio: TDateTime;
begin
  WriteLn;
  WriteLn('--- TTask.WaitForAll (paralelo) ---');

  Inicio := Now;

  // Tres tarefas que rodariam 300ms em sequencia rodam em ~100ms em paralelo
  T1 := TTask.Run(procedure begin Sleep(100); Log('[T1] Concluida'); end);
  T2 := TTask.Run(procedure begin Sleep(80);  Log('[T2] Concluida'); end);
  T3 := TTask.Run(procedure begin Sleep(90);  Log('[T3] Concluida'); end);

  TTask.WaitForAll([T1, T2, T3]);

  var Ms := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
  WriteLn(Format('[MAIN] Todas concluidas em %d ms (sequencial seria ~270 ms)', [Ms]));
end;

// ----------------------------------------------------------
// Parte 3: WaitForAny — primeiro a terminar
// ----------------------------------------------------------
procedure DemonstrarWaitForAny;
var
  T1, T2, T3: ITask;
  Indice: Integer;
begin
  WriteLn;
  WriteLn('--- TTask.WaitForAny ---');

  T1 := TTask.Run(procedure begin Sleep(300); Log('[T1] Concluida'); end);
  T2 := TTask.Run(procedure begin Sleep(50);  Log('[T2] Concluida (PRIMEIRA)'); end);
  T3 := TTask.Run(procedure begin Sleep(200); Log('[T3] Concluida'); end);

  Indice := TTask.WaitForAny([T1, T2, T3]);  // retorna indice da primeira
  Log(Format('[MAIN] Primeira concluida: indice %d', [Indice]));

  // Aguardar as restantes se necessario
  TTask.WaitForAll([T1, T2, T3]);
end;

// ----------------------------------------------------------
// Parte 4: TTask<T> — Future pattern (valor de retorno)
// ----------------------------------------------------------
procedure DemonstrarFuture;
var
  TF1: ITask<Integer>;
  TF2: ITask<string>;
begin
  WriteLn;
  WriteLn('--- TTask<T> — Future pattern ---');

  // Calcular valores em paralelo
  TF1 := TTask<Integer>.Run(function: Integer
  begin
    Log('[FUTURE-INT] Calculando...');
    Sleep(200);
    Result := 42;
  end);

  TF2 := TTask<string>.Run(function: string
  begin
    Log('[FUTURE-STR] Processando...');
    Sleep(150);
    Result := 'Resposta do servidor';
  end);

  Log('[MAIN] Futures criados — aguardando valores...');

  // .Value bloqueia ate concluir e retorna o resultado
  var V1: Integer := TF1.Value;
  var V2: string  := TF2.Value;

  WriteLn(Format('[MAIN] Inteiro: %d | String: %s', [V1, V2]));
end;

// ----------------------------------------------------------
// Parte 5: Tratamento de excecoes em TTask
// ----------------------------------------------------------
procedure DemonstrarExcecao;
var
  T: ITask;
begin
  WriteLn;
  WriteLn('--- Excecao em TTask ---');

  T := TTask.Run(procedure
  begin
    Sleep(50);
    raise EInvalidOperation.Create('Erro simulado dentro da task');
  end);

  try
    T.Wait;   // NÃO lança automaticamente — verificar status
  except
    on E: Exception do
      Log('[MAIN] Wait nao lança: ' + E.Message);
  end;

  // Verificar status e relançar
  if T.Status = TTaskStatus.Exception then
  begin
    Log('[MAIN] Task falhou. Excecao: ' + T.Exception.Message);
    // Para relançar: T.Exception.RaiseOuterException;
  end;

  // WaitForAll SIM lança EAggregateException se alguma task falhou
  var TF := TTask.Run(procedure begin raise EInvalidOperation.Create('Erro em WaitForAll'); end);
  try
    TTask.WaitForAll([TF]);
  except
    on E: EAggregateException do
      Log('[MAIN] EAggregateException capturada: ' + E.InnerException.Message);
  end;
end;

// ----------------------------------------------------------
// Parte 6: Cancelamento com TCancellationTokenSource
// ----------------------------------------------------------
procedure DemonstrarCancelamento;
var
  Cancel: TCancellationTokenSource;
  Token : TCancellationToken;
  T     : ITask;
begin
  WriteLn;
  WriteLn('--- Cancelamento com TCancellationTokenSource ---');

  Cancel := TCancellationTokenSource.Create;
  try
    Token := Cancel.Token;

    T := TTask.Run(procedure
    var I: Integer;
    begin
      for I := 1 to 20 do
      begin
        if Token.IsCancellationRequested then
        begin
          Log(Format('[TASK] Cancelado em iteracao %d', [I]));
          Exit;
        end;
        Sleep(50);
        Log(Format('[TASK] Iteracao %d', [I]));
      end;
    end, Token);

    Sleep(180);   // deixar rodar 3-4 iteracoes
    Log('[MAIN] Solicitando cancelamento...');
    Cancel.Cancel;

    T.Wait;
    Log('[MAIN] Task encerrou apos cancelamento. Status: ' + IntToStr(Ord(T.Status)));
  finally
    Cancel.Free;
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Exemplos TTask (PPL) ===');
    WriteLn;

    DemonstrarTaskBasico;
    DemonstrarWaitForAll;
    DemonstrarWaitForAny;
    DemonstrarFuture;
    DemonstrarExcecao;
    DemonstrarCancelamento;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
