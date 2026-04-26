program tthread_anonymous;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs;

// ============================================================
// Exemplo: TThread.CreateAnonymousThread — uso e padroes
//
// CreateAnonymousThread e util para:
//   - Tarefas pontuais sem necessidade de herdar TThread
//   - Fire-and-forget com FreeOnTerminate = True
//   - Operacoes simples de background com captura de closures
//
// ATENCAO: para tarefas mais complexas (pool, cancelamento,
// continuacoes), prefira TTask da PPL.
//
// Compilar:
//   dcc32 tthread_anonymous.pas
//   dcc64 tthread_anonymous.pas
// ============================================================

var
  GLock: TCriticalSection;

procedure Log(const S: string);
begin
  GLock.Enter;
  try
    WriteLn(S);
  finally
    GLock.Leave;
  end;
end;

// ----------------------------------------------------------
// Padrao 1: Fire-and-forget (FreeOnTerminate = True)
//   - Nao guardar referencia apos Start
//   - Nao chamar WaitFor (a thread se destroi sozinha)
// ----------------------------------------------------------
procedure ExemploFireAndForget;
var
  T: TThread;
begin
  WriteLn('--- Padrao 1: Fire-and-Forget ---');

  T := TThread.CreateAnonymousThread(procedure
  var
    I: Integer;
  begin
    for I := 1 to 3 do
    begin
      Sleep(100);
      Log(Format('[ANONIMA] Iteracao %d', [I]));
    end;
    TThread.Queue(nil, procedure
    begin
      Log('[UI] Thread anonima concluiu (via Queue).');
    end);
  end);

  T.FreeOnTerminate := True;
  T.Start;
  // NAO usar T apos Start com FreeOnTerminate = True
end;

// ----------------------------------------------------------
// Padrao 2: Com WaitFor (FreeOnTerminate = False)
//   - Guardar referencia e liberar manualmente
// ----------------------------------------------------------
procedure ExemploComWaitFor;
var
  T: TThread;
  Resultado: Integer;
begin
  WriteLn;
  WriteLn('--- Padrao 2: Com WaitFor ---');

  Resultado := 0;

  T := TThread.CreateAnonymousThread(procedure
  begin
    Sleep(200);
    // Closure captura Resultado por referencia
    // CUIDADO: variavel deve estar viva enquanto a thread rodar
    Resultado := 42;
    Log('[ANONIMA] Calculou resultado = 42');
  end);

  T.FreeOnTerminate := False;  // controlamos o ciclo de vida
  T.Start;
  T.WaitFor;                   // espera terminar

  WriteLn(Format('[MAIN] Resultado calculado pela thread: %d', [Resultado]));
  T.Free;
end;

// ----------------------------------------------------------
// Padrao 3: Multiplas threads anonimas com sincronizacao
// ----------------------------------------------------------
procedure ExemploMultiplas;
const
  N = 4;
var
  Threads: array[0..N-1] of TThread;
  I: Integer;
  TotalProcessado: Integer;
  Lock: TCriticalSection;
begin
  WriteLn;
  WriteLn('--- Padrao 3: Multiplas threads anonimas ---');

  TotalProcessado := 0;
  Lock := TCriticalSection.Create;
  try
    for I := 0 to N - 1 do
    begin
      // Captura de I: ATENCAO ao closure em loops!
      // Delphi captura por referencia — usar variavel local para "fixar" o valor
      var Indice := I;  // variavel local capturada corretamente pelo closure
      Threads[Indice] := TThread.CreateAnonymousThread(procedure
      begin
        Sleep(50 + Indice * 30);
        Log(Format('[THREAD %d] Processando lote %d', [Indice, Indice]));
        Lock.Enter;
        try
          Inc(TotalProcessado);
        finally
          Lock.Leave;
        end;
      end);
      Threads[Indice].FreeOnTerminate := False;
      Threads[Indice].Start;
    end;

    // Aguardar todas
    for I := 0 to N - 1 do
    begin
      Threads[I].WaitFor;
      Threads[I].Free;
    end;
  finally
    Lock.Free;
  end;

  WriteLn(Format('[MAIN] Total processado por %d threads: %d', [N, TotalProcessado]));
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  WriteLn('=== Exemplo TThread.CreateAnonymousThread ===');
  WriteLn;

  GLock := TCriticalSection.Create;
  try
    ExemploFireAndForget;
    Sleep(500);  // aguardar fire-and-forget terminar (em app real, use evento)

    ExemploComWaitFor;
    ExemploMultiplas;
  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
