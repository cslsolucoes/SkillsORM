program parallel_aggregate;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  System.Threading,
  System.SyncObjs,
  System.Math;

// ============================================================
// Exemplo: Agregacao paralela — Map/Reduce com TParallel.For
//
// Demonstra:
//   - Soma paralela com TInterlocked.Add
//   - Minimo/Maximo paralelo com CompareExchange
//   - Map paralelo sobre array de doubles
//   - Reduce com acumuladores locais por thread (evita falsa contenção)
//   - Pipeline map-reduce com TTask
//
// Compilar:
//   dcc32 parallel_aggregate.pas
//   dcc64 parallel_aggregate.pas
// ============================================================

const
  N = 100_000;  // tamanho do dataset

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
// Inicializar array de dados
// ----------------------------------------------------------
procedure GerarDados(var ADados: TArray<Double>; ACount: Integer);
var I: Integer;
begin
  SetLength(ADados, ACount);
  for I := 0 to ACount - 1 do
    ADados[I] := (I mod 1000) + 1.0;  // valores 1..1000 repetidos
end;

// ----------------------------------------------------------
// Parte 1: Soma paralela com TInterlocked (soma de inteiros)
// ----------------------------------------------------------
procedure DemonstrarSomaParalela;
var
  Dados   : TArray<Integer>;
  I       : Integer;
  SomaSeq : Int64;
  SomaPar : Int64;  // Int64 nao suportado por TInterlocked.Add diretamente
  SomaInt : Integer;
  Inicio  : TDateTime;
  Ms      : Integer;
begin
  WriteLn('--- Soma paralela com TInterlocked.Add ---');

  SetLength(Dados, N);
  for I := 0 to N - 1 do Dados[I] := (I mod 100) + 1;

  // Sequencial
  SomaSeq := 0;
  Inicio  := Now;
  for I := 0 to N - 1 do Inc(SomaSeq, Dados[I]);
  Ms := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
  WriteLn(Format('Sequencial: %d em %d ms', [SomaSeq, Ms]));

  // Paralela com TInterlocked.Add (Integer 32-bit)
  SomaInt := 0;
  Inicio  := Now;
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    TInterlocked.Add(SomaInt, Dados[I]);
  end);
  Ms := Round((Now - Inicio) * 24 * 60 * 60 * 1000);
  WriteLn(Format('Paralela   : %d em %d ms', [SomaInt, Ms]));
  WriteLn(Format('Correto    : %s', [BoolToStr(SomaSeq = SomaInt, True)]));
end;

// ----------------------------------------------------------
// Parte 2: Maximo paralelo com CompareExchange
// ----------------------------------------------------------
procedure DemonstrarMaximoParalelo;
var
  Dados   : TArray<Integer>;
  I, MaxSeq, MaxPar, Atual, Lido: Integer;
begin
  WriteLn;
  WriteLn('--- Maximo paralelo com CompareExchange ---');

  SetLength(Dados, N);
  for I := 0 to N - 1 do Dados[I] := Random(1000000);

  // Sequencial
  MaxSeq := Low(Integer);
  for I := 0 to N - 1 do
    if Dados[I] > MaxSeq then MaxSeq := Dados[I];

  // Paralelo — atualizar maximo atomicamente com CAS loop
  MaxPar := Low(Integer);
  TParallel.For(0, N - 1, procedure(I: Integer)
  var Atual, Lido: Integer;
  begin
    Atual := Dados[I];
    // Loop CAS: tentar atualizar MaxPar se Dados[I] > MaxPar
    while True do
    begin
      Lido := MaxPar;                   // ler valor atual
      if Atual <= Lido then Break;      // nao e maior — nada a fazer
      // Tentar trocar Lido por Atual se MaxPar ainda for Lido
      if TInterlocked.CompareExchange(MaxPar, Atual, Lido) = Lido then
        Break;  // sucesso — atualizamos o maximo
      // Se falhou: outra thread atualizou MaxPar — tentar de novo
    end;
  end);

  WriteLn(Format('Maximo sequencial: %d', [MaxSeq]));
  WriteLn(Format('Maximo paralelo  : %d', [MaxPar]));
  WriteLn(Format('Correto          : %s', [BoolToStr(MaxSeq = MaxPar, True)]));
end;

// ----------------------------------------------------------
// Parte 3: Map paralelo — transformar array in-place
// ----------------------------------------------------------
procedure DemonstrarMapParalelo;
var
  Dados  : TArray<Double>;
  SomaSeq, SomaPar: Double;
  I      : Integer;
begin
  WriteLn;
  WriteLn('--- Map paralelo (sqrt de cada elemento) ---');

  GerarDados(Dados, N);

  // Map: cada elemento e independente — perfeito para TParallel.For
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    Dados[I] := Sqrt(Dados[I]);  // escrita em posicao exclusiva — sem lock
  end);

  // Verificar: somar resultados
  SomaPar := 0;
  for I := 0 to N - 1 do SomaPar := SomaPar + Dados[I];
  WriteLn(Format('Soma apos map paralelo: %.2f', [SomaPar]));
end;

// ----------------------------------------------------------
// Parte 4: Reduce com acumuladores locais (evita falsa contencao)
//
// Tecnica: dividir o array em segmentos, processar cada segmento
// em uma TTask separada, acumular localmente, combinar ao final.
// Muito mais eficiente que TInterlocked em cada iteracao.
// ----------------------------------------------------------
procedure DemonstrarReduceLocal;
const
  NUM_TASKS = 4;
var
  Dados    : TArray<Double>;
  Parciais : TArray<Double>;
  TotalFinal: Double;
  Tasks    : array[0..NUM_TASKS-1] of ITask;
  I        : Integer;
  ChunkSize: Integer;
begin
  WriteLn;
  WriteLn('--- Reduce com acumuladores locais por task ---');

  GerarDados(Dados, N);
  SetLength(Parciais, NUM_TASKS);
  for I := 0 to NUM_TASKS - 1 do Parciais[I] := 0;

  ChunkSize := N div NUM_TASKS;

  // Cada task acumula sua fatia sem lock
  for I := 0 to NUM_TASKS - 1 do
  begin
    var TaskId  := I;
    var InicioDo := TaskId * ChunkSize;
    var FimDo   := IfThen(TaskId = NUM_TASKS - 1, N - 1, InicioDo + ChunkSize - 1);

    Tasks[TaskId] := TTask.Run(procedure
    var J: Integer; SomaLocal: Double;
    begin
      SomaLocal := 0;
      for J := InicioDo to FimDo do
        SomaLocal := SomaLocal + Dados[J];  // sem lock — variavel local
      Parciais[TaskId] := SomaLocal;          // escrita em posicao exclusiva
    end);
  end;

  TTask.WaitForAll(Tasks);

  // Fase final: combinar parciais (rapido, feito pela main thread)
  TotalFinal := 0;
  for I := 0 to NUM_TASKS - 1 do TotalFinal := TotalFinal + Parciais[I];

  WriteLn(Format('Total (reduce local, %d tasks): %.2f', [NUM_TASKS, TotalFinal]));
end;

// ----------------------------------------------------------
// Parte 5: Pipeline Map-Reduce completo com TTask
// ----------------------------------------------------------
procedure DemonstrarMapReduce;
var
  Dados     : TArray<Integer>;
  MapResult : TArray<Double>;
  SomaParcial: TArray<Double>;
  Tasks     : array[0..3] of ITask;
  I, Chunk  : Integer;
  TotalFinal: Double;
begin
  WriteLn;
  WriteLn('--- Pipeline Map-Reduce completo ---');

  SetLength(Dados, N);
  SetLength(MapResult, N);
  SetLength(SomaParcial, 4);

  for I := 0 to N - 1 do Dados[I] := (I mod 100) + 1;
  for I := 0 to 3 do SomaParcial[I] := 0;

  // MAP: transformar (sqrt) em paralelo
  TParallel.For(0, N - 1, procedure(I: Integer)
  begin
    MapResult[I] := Sqrt(Dados[I]);
  end);

  // REDUCE: somar por chunks em paralelo
  Chunk := N div 4;
  for I := 0 to 3 do
  begin
    var TaskIdx    := I;
    var InicioChunk := TaskIdx * Chunk;
    var FimChunk   := IfThen(TaskIdx = 3, N - 1, InicioChunk + Chunk - 1);

    Tasks[TaskIdx] := TTask.Run(procedure
    var J: Integer; Soma: Double;
    begin
      Soma := 0;
      for J := InicioChunk to FimChunk do
        Soma := Soma + MapResult[J];
      SomaParcial[TaskIdx] := Soma;
    end);
  end;

  TTask.WaitForAll(Tasks);

  TotalFinal := 0;
  for I := 0 to 3 do TotalFinal := TotalFinal + SomaParcial[I];

  WriteLn(Format('Map-Reduce final (N=%d): %.4f', [N, TotalFinal]));
end;

// ----------------------------------------------------------
// Programa principal
// ----------------------------------------------------------
begin
  Randomize;
  GLock := TCriticalSection.Create;
  try
    WriteLn('=== Agregacao Paralela (Map/Reduce) ===');
    WriteLn;

    DemonstrarSomaParalela;
    DemonstrarMaximoParalelo;
    DemonstrarMapParalelo;
    DemonstrarReduceLocal;
    DemonstrarMapReduce;

  finally
    GLock.Free;
  end;

  WriteLn;
  WriteLn('Pressione Enter para sair.');
  ReadLn;
end.
