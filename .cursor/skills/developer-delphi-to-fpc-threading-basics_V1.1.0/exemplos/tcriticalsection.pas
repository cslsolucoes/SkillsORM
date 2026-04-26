program tcriticalsection;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

// ============================================================
// Exemplo: TCriticalSection — Enter/Leave, TryEnter, try/finally
//
// Demonstra:
//   - Protecao de lista compartilhada entre N threads produtoras
//   - Padrao correto: Enter + try/finally + Leave
//   - TryEnter para tentativa nao bloqueante
//   - Comparacao com acesso sem lock (race condition intencional)
//
// Compilar:
//   dcc32 tcriticalsection.pas
//   dcc64 tcriticalsection.pas
// ============================================================

const
  NUM_THREADS  = 4;
  ITENS_POR_THREAD = 50;

type
  // ----------------------------------------------------------
  // Thread produtora que insere itens em lista compartilhada
  // ----------------------------------------------------------
  TProdutora = class(TThread)
  private
    FId    : Integer;
    FLista : TList<string>;
    FLock  : TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(AId: Integer; ALista: TList<string>; ALock: TCriticalSection);
  end;

constructor TProdutora.Create(AId: Integer; ALista: TList<string>; ALock: TCriticalSection);
begin
  inherited Create(True);
  FId    := AId;
  FLista := ALista;
  FLock  := ALock;
  FreeOnTerminate := False;
end;

procedure TProdutora.Execute;
var
  I: Integer;
  Item: string;
begin
  for I := 1 to ITENS_POR_THREAD do
  begin
    if Terminated then Break;

    Item := Format('T%d-Item%d', [FId, I]);

    // ---- PADRAO OBRIGATORIO: Enter + try/finally + Leave ----
    FLock.Enter;
    try
      // Somente 1 thread executa este bloco por vez
      FLista.Add(Item);
    finally
      FLock.Leave;  // SEMPRE no finally — libera mesmo se Add lancar excecao
    end;
    // ---------------------------------------------------------

    Sleep(1);  // ceder CPU brevemente
  end;
end;

// ----------------------------------------------------------
// Demonstracao de TryEnter — nao bloqueante
// ----------------------------------------------------------
procedure DemonstrarTryEnter;
var
  Lock: TCriticalSection;
  Adquiriu: Boolean;
begin
  WriteLn;
  WriteLn('--- TryEnter (nao bloqueante) ---');
  Lock := TCriticalSection.Create;
  try
    Lock.Enter;
    try
      // Tenta adquirir lock que ja esta preso (mesma thread — CS e reentrante)
      // Em threads diferentes, TryEnter retornaria False
      Adquiriu := Lock.TryEnter;
      try
        if Adquiriu then
          WriteLn('TryEnter: adquiriu (reentrancia em mesma thread)')
        else
          WriteLn('TryEnter: nao adquiriu — outra thread segura o lock');
      finally
        if Adquiriu then Lock.Leave;  // Leave extra pelo TryEnter
      end;
    finally
      Lock.Leave;
    end;
  finally
    Lock.Free;
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
var
  Lock  : TCriticalSection;
  Lista : TList<string>;
  Threads: array[0..NUM_THREADS - 1] of TProdutora;
  I, Esperado: Integer;
begin
  WriteLn('=== Exemplo TCriticalSection ===');
  WriteLn(Format('Threads: %d | Itens por thread: %d', [NUM_THREADS, ITENS_POR_THREAD]));
  WriteLn;

  Lock  := TCriticalSection.Create;
  Lista := TList<string>.Create;
  try
    // Criar e iniciar threads
    for I := 0 to NUM_THREADS - 1 do
    begin
      Threads[I] := TProdutora.Create(I + 1, Lista, Lock);
      Threads[I].Start;
    end;

    // Aguardar todas terminarem
    for I := 0 to NUM_THREADS - 1 do
    begin
      Threads[I].WaitFor;
      Threads[I].Free;
    end;

    // Verificar resultado
    Esperado := NUM_THREADS * ITENS_POR_THREAD;
    WriteLn(Format('Itens esperados : %d', [Esperado]));
    WriteLn(Format('Itens inseridos : %d', [Lista.Count]));
    if Lista.Count = Esperado then
      WriteLn('CORRETO: nenhum item perdido com TCriticalSection')
    else
      WriteLn('ERRO: itens perdidos (nao deveria ocorrer com lock correto)');

  finally
    Lista.Free;
    Lock.Free;  // Liberar APOS todas as threads terminarem
  end;

  DemonstrarTryEnter;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
