program lock_free;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Threading;

// ============================================================
// Exemplo: TInterlocked — operacoes atomicas lock-free
//
// TInterlocked oferece operacoes atomicas que nao exigem
// TCriticalSection, evitando overhead de context switch.
//
// Operacoes disponiveis:
//   Increment/Decrement  — contador atomico
//   Exchange             — troca e retorna valor anterior
//   CompareExchange      — CAS (Compare-And-Swap)
//   Add                  — soma atomica
//
// Compilar:
//   dcc32 lock_free.pas
//   dcc64 lock_free.pas
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
// Parte 1: Increment/Decrement — contador compartilhado
// ----------------------------------------------------------
procedure DemonstrarContador;
const N_THREADS = 8; ITERACOES = 1000;
var
  ContadorSemLock  : Integer;  // race condition (para comparacao)
  ContadorComAtomic: Integer;
  Tasks            : array[0..N_THREADS-1] of ITask;
  I                : Integer;
begin
  WriteLn('--- Increment/Decrement atomico ---');

  ContadorSemLock   := 0;
  ContadorComAtomic := 0;

  // Threads sem protecao (race condition intencional)
  for I := 0 to N_THREADS - 1 do
    Tasks[I] := TTask.Run(procedure
    var J: Integer;
    begin
      for J := 1 to ITERACOES do
        Inc(ContadorSemLock);   // NAO atomico — race condition
    end);
  TTask.WaitForAll(Tasks);
  WriteLn(Format('Sem protecao (race condition): %d (esperado: %d)',
    [ContadorSemLock, N_THREADS * ITERACOES]));

  // Threads com TInterlocked (correto)
  for I := 0 to N_THREADS - 1 do
    Tasks[I] := TTask.Run(procedure
    var J: Integer;
    begin
      for J := 1 to ITERACOES do
        TInterlocked.Increment(ContadorComAtomic);  // atomico
    end);
  TTask.WaitForAll(Tasks);
  WriteLn(Format('Com TInterlocked.Increment    : %d (esperado: %d)',
    [ContadorComAtomic, N_THREADS * ITERACOES]));
  WriteLn(Format('Correto: %s', [BoolToStr(ContadorComAtomic = N_THREADS * ITERACOES, True)]));

  // Decrement — retorna o NOVO valor
  var V := TInterlocked.Decrement(ContadorComAtomic);
  WriteLn(Format('Apos Decrement: %d (novo=%d)', [ContadorComAtomic, V]));
end;

// ----------------------------------------------------------
// Parte 2: Exchange — trocar valor atomicamente
// ----------------------------------------------------------
procedure DemonstrarExchange;
var
  Estado   : Integer;
  Anterior : Integer;
const
  LIVRE  = 0;
  OCUPADO = 1;
begin
  WriteLn;
  WriteLn('--- Exchange ---');

  Estado := LIVRE;
  WriteLn(Format('Estado inicial: %d (LIVRE)', [Estado]));

  // Trocar para OCUPADO e obter o valor anterior
  Anterior := TInterlocked.Exchange(Estado, OCUPADO);
  WriteLn(Format('Apos Exchange: atual=%d, anterior=%d', [Estado, Anterior]));

  // Restaurar
  Anterior := TInterlocked.Exchange(Estado, LIVRE);
  WriteLn(Format('Restaurado: atual=%d, anterior=%d', [Estado, Anterior]));
end;

// ----------------------------------------------------------
// Parte 3: CompareExchange (CAS) — lock-free condicional
// ----------------------------------------------------------
procedure DemonstrarCAS;
var
  Estado  : Integer;
  Lido    : Integer;
const
  LIVRE   = 0;
  OCUPADO = 1;
begin
  WriteLn;
  WriteLn('--- CompareExchange (CAS) ---');

  Estado := LIVRE;

  // CAS: troca Estado para OCUPADO apenas se Estado = LIVRE
  // Retorna o valor LIDO (pode ser diferente se outra thread mudou)
  Lido := TInterlocked.CompareExchange(Estado, {novo=}OCUPADO, {esperado=}LIVRE);
  if Lido = LIVRE then
    WriteLn('CAS 1: adquiriu lock (LIVRE → OCUPADO)')
  else
    WriteLn(Format('CAS 1: nao adquiriu — estado era %d', [Lido]));

  // Tentar novamente (Estado ja e OCUPADO — deve falhar)
  Lido := TInterlocked.CompareExchange(Estado, {novo=}OCUPADO, {esperado=}LIVRE);
  if Lido = LIVRE then
    WriteLn('CAS 2: adquiriu (nao esperado)')
  else
    WriteLn(Format('CAS 2: nao adquiriu — estado era %d (OCUPADO)', [Lido]));

  // Liberar
  TInterlocked.Exchange(Estado, LIVRE);
  WriteLn(Format('Lock liberado: Estado=%d', [Estado]));
end;

// ----------------------------------------------------------
// Parte 4: Lazy initialization thread-safe com CAS
// ----------------------------------------------------------
type
  TServico = class
    Nome: string;
    constructor Create(const ANome: string);
  end;

constructor TServico.Create(const ANome: string);
begin
  inherited Create;
  Nome := ANome;
  Log(Format('[SERVICO] Criado: %s', [ANome]));
end;

var
  GServico: TServico = nil;  // nil = nao inicializado

function ObterServico: TServico;
var
  Novo: TServico;
begin
  // Double-check com CAS — garante criacao unica mesmo com N threads
  if GServico = nil then
  begin
    Novo := TServico.Create('ServicoSingleton');  // criar candidato

    // CompareExchange de ponteiro: troca GServico para Novo apenas se GServico = nil
    if TInterlocked.CompareExchange(Pointer(GServico), Pointer(Novo), nil) <> nil then
    begin
      // Outra thread ganhou a corrida — descartar o nosso candidato
      Novo.Free;
    end;
    // Se CAS retornou nil, nosso Novo virou o singleton
  end;
  Result := GServico;
end;

procedure DemonstrarLazyInit;
const N = 5;
var
  Tasks: array[0..N-1] of ITask;
  I    : Integer;
begin
  WriteLn;
  WriteLn('--- Lazy Init thread-safe com CompareExchange ---');
  WriteLn('(Apenas 1 instancia deve ser criada entre ', N, ' threads concorrentes)');

  GServico := nil;

  for I := 0 to N - 1 do
    Tasks[I] := TTask.Run(procedure
    var S: TServico;
    begin
      S := ObterServico;
      Log(Format('[THREAD] Servico obtido: %s (ptr=%p)', [S.Nome, Pointer(S)]));
    end);

  TTask.WaitForAll(Tasks);
  WriteLn(Format('[MAIN] GServico final: %s', [GServico.Nome]));

  GServico.Free;
  GServico := nil;
end;

// ----------------------------------------------------------
// Parte 5: Add atomico e comparacao com lock
// ----------------------------------------------------------
procedure DemonstrarAdd;
const N = 4; ITER = 500;
var
  TotalAtomic: Integer;
  TotalLock  : Integer;
  Lock       : TCriticalSection;
  Tasks      : array[0..N-1] of ITask;
  I          : Integer;
begin
  WriteLn;
  WriteLn('--- TInterlocked.Add ---');

  TotalAtomic := 0;
  TotalLock   := 0;
  Lock := TCriticalSection.Create;
  try
    // Com Add atomico
    for I := 0 to N - 1 do
      Tasks[I] := TTask.Run(procedure
      var J: Integer;
      begin
        for J := 1 to ITER do
          TInterlocked.Add(TotalAtomic, J);   // soma J atomicamente
      end);
    TTask.WaitForAll(Tasks);

    // Com TCriticalSection (referencia)
    for I := 0 to N - 1 do
      Tasks[I] := TTask.Run(procedure
      var J: Integer;
      begin
        for J := 1 to ITER do
        begin
          Lock.Enter;
          try Inc(TotalLock, J);
          finally Lock.Leave; end;
        end;
      end);
    TTask.WaitForAll(Tasks);

    var Esperado := N * (ITER * (ITER + 1) div 2);
    WriteLn(Format('TInterlocked.Add : %d | Com Lock: %d | Esperado: %d',
      [TotalAtomic, TotalLock, Esperado]));
    WriteLn(Format('Ambos corretos   : %s', [BoolToStr((TotalAtomic = Esperado) and (TotalLock = Esperado), True)]));
  finally
    Lock.Free;
  end;
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Exemplos TInterlocked — Lock-Free ===');
    WriteLn;

    DemonstrarContador;
    DemonstrarExchange;
    DemonstrarCAS;
    DemonstrarLazyInit;
    DemonstrarAdd;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
