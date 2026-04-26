unit TEMPLATE_debug_benchmark;
// TEMPLATE: Wrapper RDTSC para benchmarking de rotinas assembly
// Substituir: MinhaRotina, parametros
{$APPTYPE CONSOLE}
interface

type
  TBenchmark = record
    Nome: string;
    Ciclos: Int64;
    Repeticoes: Integer;
    function CiclosMedio: Double;
  end;

// Medir ciclos de uma procedure anonima
function MedirCiclos(const Proc: TProc; Repeticoes: Integer = 1000): TBenchmark;

implementation

function LerTSCSerializado: Int64; assembler;
asm
  LFENCE
  RDTSC
{$IFDEF WIN64}
  SHL RDX, 32
  OR  RAX, RDX
{$ENDIF}
  LFENCE
end;

function TBenchmark.CiclosMedio: Double;
begin
  if Repeticoes > 0 then
    Result := Ciclos / Repeticoes
  else
    Result := 0;
end;

function MedirCiclos(const Proc: TProc; Repeticoes: Integer): TBenchmark;
var
  I: Integer;
  T1, T2: Int64;
begin
  Result.Nome := 'benchmark';
  Result.Repeticoes := Repeticoes;

  // Warmup (cachear instrucoes e dados):
  for I := 1 to 10 do
    Proc;

  // Medicao real:
  T1 := LerTSCSerializado;
  for I := 1 to Repeticoes do
    Proc;
  T2 := LerTSCSerializado;

  Result.Ciclos := T2 - T1;
end;

// EXEMPLO DE USO:
//
// var B: TBenchmark;
// B := MedirCiclos(
//   procedure
//   begin
//     MinhaRotinaASM(dados, count);
//   end,
//   10000  // 10000 repeticoes
// );
// WriteLn(Format('Media: %.1f ciclos por chamada', [B.CiclosMedio]));

end.
