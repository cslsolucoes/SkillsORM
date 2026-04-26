unit rdtsc_profiling;
// RDTSC/RDTSCP — Medicao de ciclos de CPU para benchmarking de asm
// RDTSC: Read Time-Stamp Counter (64-bit, incrementado em cada ciclo)
{$APPTYPE CONSOLE}
interface

// Ler o timestamp counter (ciclos desde o boot)
function LerTSC: Int64; assembler;

// Ler TSC com serializacao (LFENCE + RDTSC + LFENCE)
// Mais preciso para benchmarking — impede reordenamento de instrucoes
function LerTSCSerializado: Int64; assembler;

// Wrapper conveniente para medir ciclos de uma operacao
type
  TTicTac = record
    Inicio, Fim: Int64;
    function Ciclos: Int64;
    function Nanosegundos(FreqMHz: Double): Double;
  end;

procedure Tic(var T: TTicTac);  // marcar inicio
procedure Tac(var T: TTicTac);  // marcar fim

implementation

function LerTSC: Int64; assembler;
asm
  RDTSC           // EDX:EAX = timestamp counter
  // Win32: retorno Int64 automaticamente em EDX:EAX
  // Win64: RAX = RDTSC result (64-bit); EDX:EAX partes do RAX
{$IFDEF WIN64}
  SHL  RDX, 32
  OR   RAX, RDX   // RAX = (EDX << 32) | EAX (Int64 completo)
{$ENDIF WIN64}
end;

function LerTSCSerializado: Int64; assembler;
asm
  LFENCE          // barreira: todas instrucoes anteriores completadas antes de RDTSC
  RDTSC
{$IFDEF WIN64}
  SHL  RDX, 32
  OR   RAX, RDX
{$ENDIF WIN64}
  LFENCE          // barreira: RDTSC completa antes de instrucoes seguintes
end;

function TTicTac.Ciclos: Int64;
begin
  Result := Fim - Inicio;
end;

function TTicTac.Nanosegundos(FreqMHz: Double): Double;
begin
  // Ciclos / (FreqMHz * 10^6) = segundos
  // * 10^9 = nanosegundos
  Result := (Fim - Inicio) / FreqMHz * 1000.0;
end;

procedure Tic(var T: TTicTac);
begin
  T.Inicio := LerTSCSerializado;
end;

procedure Tac(var T: TTicTac);
begin
  T.Fim := LerTSCSerializado;
end;

// EXEMPLO DE USO:
// var T: TTicTac;
// Tic(T);
// MinhaRotina;
// Tac(T);
// WriteLn('Ciclos: ', T.Ciclos);
// WriteLn('Nanosegundos (@3GHz): ', T.Nanosegundos(3000):0:2, ' ns');

end.
