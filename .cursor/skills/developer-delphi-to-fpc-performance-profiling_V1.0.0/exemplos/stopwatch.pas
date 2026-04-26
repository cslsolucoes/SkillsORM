program stopwatch;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra TStopwatch (System.Diagnostics) para micro-benchmarks em Delphi.
///  Compilavel com: dcc32 stopwatch.pas  ou  dcc64 stopwatch.pas
///
///  Tecnicas demonstradas:
///   1. TStopwatch.StartNew / Stop / ElapsedMilliseconds / ElapsedTicks
///   2. Aquecimento de cache (warm-up) antes das medicoes reais
///   3. Loop de N iteracoes; calculo de min/avg/max em ticks de alta resolucao
///   4. Conversao ticks -> microsegundos via TStopwatch.Frequency

uses
  System.Diagnostics,
  System.SysUtils,
  System.Math;

const
  WARMUP_RUNS  = 3;
  MEASURE_RUNS = 20;

/// Operacao de exemplo: concatenar 1000 strings com operador +
/// (intencional; sera comparada com TStringBuilder em string_concat_perf.pas)
function ConcatComOperador(ACount: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ACount do
    Result := Result + 'item_' + IntToStr(I);
end;

/// Executa o benchmark de uma funcao anonima retornando ticks decorridos.
function MedirTicks(const AOp: TProc): Int64;
var
  SW: TStopwatch;
begin
  SW := TStopwatch.StartNew;
  AOp;
  SW.Stop;
  Result := SW.ElapsedTicks;
end;

/// Converte ticks para microsegundos (us).
function TicksParaUs(ATicks: Int64): Double;
begin
  Result := ATicks / TStopwatch.Frequency * 1_000_000.0;
end;

procedure RunBenchmark;
var
  I:        Integer;
  Ticks:    Int64;
  MinTicks: Int64;
  MaxTicks: Int64;
  SumTicks: Int64;
  Dummy:    string;
begin
  WriteLn('=== Benchmark: ConcatComOperador(1000) ===');
  WriteLn(Format('Frequencia do contador: %d ticks/s', [TStopwatch.Frequency]));
  WriteLn;

  // --- Aquecimento (warm-up) ---
  WriteLn(Format('Aquecimento: %d execucoes...', [WARMUP_RUNS]));
  for I := 1 to WARMUP_RUNS do
    Dummy := ConcatComOperador(1000);

  // --- Medicoes reais ---
  MinTicks := High(Int64);
  MaxTicks := 0;
  SumTicks := 0;

  WriteLn(Format('Medicao: %d execucoes...', [MEASURE_RUNS]));
  for I := 1 to MEASURE_RUNS do
  begin
    Ticks := MedirTicks(procedure begin Dummy := ConcatComOperador(1000) end);
    if Ticks < MinTicks then MinTicks := Ticks;
    if Ticks > MaxTicks then MaxTicks := Ticks;
    SumTicks := SumTicks + Ticks;
  end;

  WriteLn;
  WriteLn('--- Resultados ---');
  WriteLn(Format('  Min : %.2f us (%d ticks)', [TicksParaUs(MinTicks), MinTicks]));
  WriteLn(Format('  Avg : %.2f us (%d ticks)', [TicksParaUs(SumTicks div MEASURE_RUNS), SumTicks div MEASURE_RUNS]));
  WriteLn(Format('  Max : %.2f us (%d ticks)', [TicksParaUs(MaxTicks), MaxTicks]));
end;

procedure DemonstrarElapsedMilliseconds;
var
  SW: TStopwatch;
  I:  Integer;
  S:  string;
begin
  WriteLn;
  WriteLn('=== Demo ElapsedMilliseconds ===');
  SW := TStopwatch.StartNew;
  S  := '';
  for I := 1 to 50000 do
    S := S + 'x';
  SW.Stop;
  WriteLn(Format('50.000 concatenacoes: %d ms | %d ticks',
    [SW.ElapsedMilliseconds, SW.ElapsedTicks]));
end;

begin
  try
    RunBenchmark;
    DemonstrarElapsedMilliseconds;
    WriteLn;
    WriteLn('OK -- developer-delphi-to-fpc-performance-profiling / stopwatch');
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(1);
    end;
  end;
end.
