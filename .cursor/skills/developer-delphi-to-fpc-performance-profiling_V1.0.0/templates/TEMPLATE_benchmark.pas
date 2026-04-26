program TEMPLATE_benchmark;
{$APPTYPE CONSOLE}
{$R *.res}
///  TEMPLATE: Micro-benchmark com TStopwatch — min/max/avg
///  =========================================================
///  Como usar:
///   1. Renomear o arquivo para o nome do benchmark (ex.: benchmark_parse_json.pas)
///   2. Substituir TODO_NomeBenchmark pelo nome descritivo
///   3. Implementar as funcoes de benchmark nas secoes marcadas com {TODO}
///   4. Ajustar N_WARMUP e N_MEASURE conforme duracao esperada da operacao
///   5. Compilar: dcc32 benchmark_parse_json.pas  ou  dcc64 ...
///
///  Compilavel sem modificacoes com: dcc32 TEMPLATE_benchmark.pas

uses
  System.Diagnostics,
  System.SysUtils,
  System.Math;

const
  N_WARMUP  = 3;    // execucoes de aquecimento (nao entram na media)
  N_MEASURE = 20;   // execucoes de medicao

// ---------------------------------------------------------------------------
// {TODO} Definir os tipos de entrada necessarios para o benchmark
// ---------------------------------------------------------------------------
type
  TEntrada = record
    // {TODO} campos de entrada
    Valor: Integer;
  end;

// ---------------------------------------------------------------------------
// {TODO} Implementar a operacao A a ser medida
// ---------------------------------------------------------------------------
function OperacaoA(const AEntrada: TEntrada): string;
begin
  // {TODO} implementar
  Result := IntToStr(AEntrada.Valor);
end;

// ---------------------------------------------------------------------------
// {TODO} Implementar a operacao B a ser comparada (opcional)
// ---------------------------------------------------------------------------
function OperacaoB(const AEntrada: TEntrada): string;
begin
  // {TODO} implementar
  Result := Format('%d', [AEntrada.Valor]);
end;

// ---------------------------------------------------------------------------
// Engine de benchmark — nao modificar
// ---------------------------------------------------------------------------
type
  TBenchResult = record
    MinUs:  Double;
    MaxUs:  Double;
    AvgUs:  Double;
    Runs:   Integer;
  end;

function TicksParaUs(ATicks: Int64): Double;
begin
  if TStopwatch.Frequency > 0 then
    Result := ATicks / TStopwatch.Frequency * 1_000_000.0
  else
    Result := 0;
end;

function RunBench(const AOp: TProc; AWarmup, AMeasure: Integer): TBenchResult;
var
  I:       Integer;
  SW:      TStopwatch;
  Ticks:   Int64;
  MinT:    Int64;
  MaxT:    Int64;
  SumT:    Int64;
begin
  // Aquecimento
  for I := 1 to AWarmup do
    AOp;

  // Medicao
  MinT := High(Int64);
  MaxT := 0;
  SumT := 0;
  for I := 1 to AMeasure do
  begin
    SW    := TStopwatch.StartNew;
    AOp;
    SW.Stop;
    Ticks := SW.ElapsedTicks;
    if Ticks < MinT then MinT := Ticks;
    if Ticks > MaxT then MaxT := Ticks;
    SumT := SumT + Ticks;
  end;

  Result.MinUs  := TicksParaUs(MinT);
  Result.MaxUs  := TicksParaUs(MaxT);
  Result.AvgUs  := TicksParaUs(SumT div AMeasure);
  Result.Runs   := AMeasure;
end;

procedure ExibirResultado(const ANome: string; const R: TBenchResult);
begin
  WriteLn(Format('  %-30s  min=%6.1f us  avg=%6.1f us  max=%6.1f us  (%d runs)',
    [ANome, R.MinUs, R.AvgUs, R.MaxUs, R.Runs]));
end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Entrada: TEntrada;
  RA, RB:  TBenchResult;
  Dummy:   string;
begin
  try
    // {TODO} Preparar dados de entrada
    Entrada.Valor := 42;

    WriteLn('=== Benchmark: TODO_NomeBenchmark ===');
    WriteLn(Format('Warmup=%d | Medicoes=%d | Frequencia=%d Hz',
      [N_WARMUP, N_MEASURE, TStopwatch.Frequency]));
    WriteLn;

    RA := RunBench(procedure begin Dummy := OperacaoA(Entrada) end, N_WARMUP, N_MEASURE);
    RB := RunBench(procedure begin Dummy := OperacaoB(Entrada) end, N_WARMUP, N_MEASURE);

    ExibirResultado('A. {TODO descricao A}', RA);
    ExibirResultado('B. {TODO descricao B}', RB);

    WriteLn;
    if RA.AvgUs > 0 then
      WriteLn(Format('Speedup B vs A: %.2fx', [RA.AvgUs / RB.AvgUs]));

    WriteLn;
    WriteLn('OK -- TEMPLATE_benchmark');
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(1);
    end;
  end;
end.
