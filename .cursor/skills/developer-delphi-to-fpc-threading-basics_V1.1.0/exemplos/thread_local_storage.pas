program thread_local_storage;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs;

// ============================================================
// Exemplo: threadvar — Thread-Local Storage (TLS)
//
// threadvar declara variaveis onde cada thread tem sua PROPRIA
// copia independente. Nao ha necessidade de lock porque cada
// thread so acessa a sua propria instancia.
//
// Casos de uso:
//   - Contexto de transacao por thread
//   - Buffer de formatacao por thread
//   - Contador de erros local por thread
//   - Conexao de banco de dados por thread
//
// Compilar:
//   dcc32 thread_local_storage.pas
//   dcc64 thread_local_storage.pas
// ============================================================

// ---- Declaracao global de threadvar ----
// Cada thread tem sua propria copia destas variaveis
threadvar
  GContextoThread : string;    // nome/contexto da thread atual
  GContadorLocal  : Integer;   // contador individual por thread
  GUltimoErro     : string;    // ultimo erro na thread (sem lock necessario)

// Lock apenas para saida no console (WriteLn nao e thread-safe)
var
  GLockConsole: TCriticalSection;

procedure EscreverLinha(const S: string);
begin
  GLockConsole.Enter;
  try
    WriteLn(S);
  finally
    GLockConsole.Leave;
  end;
end;

type
  // ----------------------------------------------------------
  // Thread que usa threadvar para armazenar contexto local
  // ----------------------------------------------------------
  TThreadTLS = class(TThread)
  private
    FNome    : string;
    FIteracoes: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(const ANome: string; AIteracoes: Integer);
  end;

constructor TThreadTLS.Create(const ANome: string; AIteracoes: Integer);
begin
  inherited Create(True);
  FNome     := ANome;
  FIteracoes := AIteracoes;
  FreeOnTerminate := False;
end;

procedure TThreadTLS.Execute;
var
  I: Integer;
begin
  // Inicializar o contexto TLS desta thread
  // Cada thread escreve em sua PROPRIA copia — sem conflito
  GContextoThread := FNome;
  GContadorLocal  := 0;
  GUltimoErro     := '';

  EscreverLinha(Format('[%s] Iniciando — GContextoThread = "%s"', [FNome, GContextoThread]));

  for I := 1 to FIteracoes do
  begin
    if Terminated then Break;

    Inc(GContadorLocal);  // incrementa copia LOCAL desta thread

    // Simular erro esporadico
    if I mod 3 = 0 then
      GUltimoErro := Format('%s: erro simulado em iteracao %d', [GContextoThread, I]);

    Sleep(50);
  end;

  EscreverLinha(Format('[%s] Finalizando — GContadorLocal = %d | GUltimoErro = "%s"',
    [GContextoThread, GContadorLocal, GUltimoErro]));

  // IMPORTANTE: GContextoThread aqui AINDA e o valor desta thread,
  // mesmo que outra thread tenha modificado a variavel global "GContextoThread"
  // em sua propria copia. Isso e a essencia do TLS.
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
const
  NUM_THREADS = 3;

var
  Threads: array[0..NUM_THREADS - 1] of TThreadTLS;
  Nomes  : array[0..NUM_THREADS - 1] of string;
  I      : Integer;
begin
  Nomes[0] := 'Alpha';
  Nomes[1] := 'Beta';
  Nomes[2] := 'Gamma';

  WriteLn('=== Exemplo Thread-Local Storage (threadvar) ===');
  WriteLn('Cada thread tem sua propria copia de GContextoThread e GContadorLocal.');
  WriteLn;

  GLockConsole := TCriticalSection.Create;
  try
    // Inicializar threadvar na main thread (copia da main thread)
    GContextoThread := 'MainThread';
    GContadorLocal  := 999;  // valor que as threads filhas NAO devem ver

    // Criar e iniciar threads
    for I := 0 to NUM_THREADS - 1 do
    begin
      Threads[I] := TThreadTLS.Create(Nomes[I], 5);
      Threads[I].Start;
    end;

    // Aguardar todas
    for I := 0 to NUM_THREADS - 1 do
      Threads[I].WaitFor;

    // Main thread: suas variaveis TLS permanecem intactas
    WriteLn;
    WriteLn(Format('[MAIN] GContextoThread ainda = "%s"', [GContextoThread]));
    WriteLn(Format('[MAIN] GContadorLocal ainda  = %d',  [GContadorLocal]));
    WriteLn('(As threads filhas NAO alteraram os valores da main thread)');

  finally
    for I := 0 to NUM_THREADS - 1 do
      Threads[I].Free;
    GLockConsole.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
