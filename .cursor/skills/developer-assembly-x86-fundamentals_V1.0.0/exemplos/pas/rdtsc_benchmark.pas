unit rdtsc_benchmark;
{
  rdtsc_benchmark.pas
  Usa RDTSC para medir ciclos de CPU antes e depois de um bloco de código.
  Útil para micro-benchmarks de código assembly ou Pascal crítico.

  RDTSC (Read Time-Stamp Counter):
  - Lê o contador de ciclos do processador desde o último reset
  - Resultado em EDX:EAX (parte baixa em EAX, alta em EDX)
  - Em 64-bit: combinar SHL RDX,32 + OR RAX,RDX para obter Int64

  AVISO: RDTSC pode ser afetado por:
  - Mudança de frequência de CPU (SpeedStep/Turbo)
  - Migração de thread entre cores
  - Reordenamento de instruções (usar CPUID ou LFENCE como barreira)

  Compilar: dcc32 rdtsc_benchmark.pas
}

{$APPTYPE CONSOLE}

program rdtsc_benchmark;

uses
  SysUtils;

// Lê o TSC como valor de 64-bit
// Em 32-bit: Delphi monta EDX:EAX como Int64 automaticamente
function ReadTSC: Int64;
asm
  RDTSC
  // Delphi 32-bit: EAX = parte baixa (retorno Int64 em EDX:EAX)
  // Delphi 64-bit: RAX = EDX:EAX combinados manualmente
  {$IFDEF CPUX64}
  SHL   RDX, 32     // RDX = parte alta deslocada
  OR    RAX, RDX    // RAX = qword completo
  {$ENDIF}
end;

// Barreira de serialização: evita que a CPU reordene instruções ao redor do RDTSC
procedure SerializationBarrier;
asm
  {$IFDEF CPUX64}
  // CPUID é instrução serializante (mais pesada, mas garante ordenamento)
  PUSH  RBX           // CPUID destrói EBX — preservar!
  XOR   EAX, EAX
  CPUID
  POP   RBX
  {$ELSE}
  PUSH  EBX
  XOR   EAX, EAX
  CPUID
  POP   EBX
  {$ENDIF}
end;

// Código a ser medido: exemplo simples de loop
procedure CodigoAMedir(Iteracoes: Integer);
var
  I: Integer;
begin
  for I := 1 to Iteracoes do
  begin
    // Trabalho simulado: operação que o compilador não otimiza away
    asm
      MOV EAX, I
      IMUL EAX, 7
      ADD  EAX, 3
    end;
  end;
end;

// Realiza N execuções e retorna a mediana de ciclos por execução
function MedirCiclos(Iteracoes: Integer): Int64;
var
  TInicio, TFim: Int64;
begin
  // Barreira antes de iniciar medição
  SerializationBarrier;
  TInicio := ReadTSC;
  SerializationBarrier;

  // Código medido
  CodigoAMedir(Iteracoes);

  // Barreira após o código medido
  SerializationBarrier;
  TFim := ReadTSC;
  SerializationBarrier;

  Result := TFim - TInicio;
end;

const
  ITERACOES = 1000;
  REPETICOES = 5;

var
  I: Integer;
  Ciclos: Int64;
  Melhor: Int64;

begin
  WriteLn('=== RDTSC Benchmark ===');
  WriteLn(Format('Iteracoes por run: %d', [ITERACOES]));
  WriteLn(Format('Repeticoes: %d', [REPETICOES]));
  WriteLn;

  Melhor := High(Int64);
  for I := 1 to REPETICOES do
  begin
    Ciclos := MedirCiclos(ITERACOES);
    WriteLn(Format('Run %d: %d ciclos totais / %.2f ciclos por iteracao',
      [I, Ciclos, Ciclos / ITERACOES]));
    if Ciclos < Melhor then
      Melhor := Ciclos;
  end;

  WriteLn;
  WriteLn(Format('Melhor resultado: %d ciclos totais', [Melhor]));
  WriteLn(Format('Melhor por iteracao: %.2f ciclos', [Melhor / ITERACOES]));
  ReadLn;
end.
