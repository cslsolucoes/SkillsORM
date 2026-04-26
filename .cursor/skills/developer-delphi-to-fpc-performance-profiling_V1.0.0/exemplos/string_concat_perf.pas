program string_concat_perf;
{$APPTYPE CONSOLE}
{$R *.res}
///  Benchmark comparativo: concatenacao de strings em Delphi.
///  Compilavel com: dcc32 string_concat_perf.pas  ou  dcc64 string_concat_perf.pas
///
///  Implementacoes comparadas:
///   A. Operador + em loop            (O(n^2) — cria nova string a cada iteracao)
///   B. TStringBuilder                (O(n)   — buffer mutavel)
///   C. TStringList + CommaText       (O(n)   — join com separador)
///   D. SetLength + Move (buffer raw) (O(n)   — controle manual; mais rapido)
///
///  Resultado esperado em Release x64:
///   B, C, D sao significativamente mais rapidos que A para N >= 1000.

uses
  System.SysUtils,
  System.Classes,
  System.Diagnostics,
  System.Text;   // TStringBuilder em algumas versoes usa System.Text

const
  N            = 5000;   // numero de strings a concatenar
  WARMUP_RUNS  = 2;
  MEASURE_RUNS = 10;

// ---------------------------------------------------------------------------
// Implementacao A: operador + (O(n^2))
// ---------------------------------------------------------------------------
function ConcatOperador(ACount: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ACount do
    Result := Result + 'item_' + IntToStr(I) + ';';
end;

// ---------------------------------------------------------------------------
// Implementacao B: TStringBuilder (O(n))
// ---------------------------------------------------------------------------
function ConcatStringBuilder(ACount: Integer): string;
var
  SB: TStringBuilder;
  I:  Integer;
begin
  SB := TStringBuilder.Create;
  try
    for I := 1 to ACount do
      SB.Append('item_').Append(I).Append(';');
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

// ---------------------------------------------------------------------------
// Implementacao C: array de strings + string.Join (O(n))
// ---------------------------------------------------------------------------
function ConcatArrayJoin(ACount: Integer): string;
var
  Arr: TArray<string>;
  I:   Integer;
begin
  SetLength(Arr, ACount);
  for I := 0 to ACount - 1 do
    Arr[I] := 'item_' + IntToStr(I + 1);
  Result := string.Join(';', Arr) + ';';
end;

// ---------------------------------------------------------------------------
// Implementacao D: SetLength pre-alocado com Write direto (O(n))
// ---------------------------------------------------------------------------
function ConcatPreAlocado(ACount: Integer): string;
var
  Buffer: string;
  Pos:    Integer;
  Parte:  string;
  I:      Integer;
begin
  // Estimativa de tamanho: "item_NNNNN;" ~= 12 chars por item
  SetLength(Buffer, ACount * 12);
  Pos := 1;
  for I := 1 to ACount do
  begin
    Parte := 'item_' + IntToStr(I) + ';';
    Move(Parte[1], Buffer[Pos], Length(Parte) * SizeOf(Char));
    Inc(Pos, Length(Parte));
  end;
  SetLength(Buffer, Pos - 1);
  Result := Buffer;
end;

// ---------------------------------------------------------------------------
// Benchmark engine
// ---------------------------------------------------------------------------
type
  TBenchFunc = reference to function(ACount: Integer): string;

function Medir(const AFunc: TBenchFunc; ACount: Integer): Int64;
var
  SW:    TStopwatch;
  I:     Integer;
  Dummy: string;
begin
  // Aquecimento
  for I := 1 to WARMUP_RUNS do
    Dummy := AFunc(ACount);

  // Medicao
  var SumTicks: Int64 := 0;
  for I := 1 to MEASURE_RUNS do
  begin
    SW := TStopwatch.StartNew;
    Dummy := AFunc(ACount);
    SW.Stop;
    SumTicks := SumTicks + SW.ElapsedTicks;
  end;

  Result := SumTicks div MEASURE_RUNS; // media em ticks
end;

function TicksParaUs(ATicks: Int64): Double;
begin
  if TStopwatch.Frequency > 0 then
    Result := ATicks / TStopwatch.Frequency * 1_000_000.0
  else
    Result := 0;
end;

procedure ExibirResultado(const ANome: string; ATicks: Int64; ABaselineTicks: Int64);
var
  Speedup: Double;
begin
  if ABaselineTicks > 0 then
    Speedup := ABaselineTicks / ATicks
  else
    Speedup := 1.0;

  WriteLn(Format('  %-28s %8.1f us   (speedup vs A: %.1fx)',
    [ANome, TicksParaUs(ATicks), Speedup]));
end;

begin
  try
    WriteLn(Format('=== Benchmark: concatenar %d strings (media de %d runs) ===',
      [N, MEASURE_RUNS]));
    WriteLn;

    var TicksA := Medir(ConcatOperador,    N);
    var TicksB := Medir(ConcatStringBuilder, N);
    var TicksC := Medir(ConcatArrayJoin,   N);
    var TicksD := Medir(ConcatPreAlocado,  N);

    WriteLn('Resultados (media de runs, build Release recomendado):');
    ExibirResultado('A. Operador + (O(n^2))',    TicksA, TicksA);
    ExibirResultado('B. TStringBuilder (O(n))',  TicksB, TicksA);
    ExibirResultado('C. Array + Join (O(n))',    TicksC, TicksA);
    ExibirResultado('D. Pre-alocado (O(n))',     TicksD, TicksA);

    WriteLn;
    WriteLn('Conclusao esperada: B, C e D sao O(n); A e O(n^2) — evitar em loops grandes.');
    WriteLn;
    WriteLn('OK -- developer-delphi-to-fpc-performance-profiling / string_concat_perf');
    Halt(0);
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(1);
    end;
  end;
end.
