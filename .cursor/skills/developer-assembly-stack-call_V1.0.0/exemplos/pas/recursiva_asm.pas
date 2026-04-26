unit recursiva_asm;
{
  recursiva_asm.pas
  Fatorial recursivo em ASM puro no Delphi.
  Demonstra frames aninhados e preservação de registradores em recursão.
  Compilar: dcc32 recursiva_asm.pas
}

{$APPTYPE CONSOLE}
program recursiva_asm;

// ---------------------------------------------------------------------------
// Fatorial recursivo 32-bit puro em asm
// Convenção register: EAX = N
// Retorno: EAX = N!
// ---------------------------------------------------------------------------
function FatorialAsm(N: Integer): Integer;
asm
  // EAX = N
  PUSH EBX              // preservar EBX (callee-saved)

  MOV  EBX, EAX        // EBX = N (guardar para multiplicação)

  // Caso base: N <= 1 → retorna 1
  CMP  EBX, 1
  JLE  @base

  // Caso recursivo: fatorial(N-1)
  DEC  EAX              // EAX = N-1
  CALL FatorialAsm      // EAX = fatorial(N-1)

  // N * fatorial(N-1)
  IMUL EAX, EBX         // EAX = N * fatorial(N-1)
  JMP  @fim

@base:
  MOV  EAX, 1           // fatorial(0) = fatorial(1) = 1

@fim:
  POP  EBX
  // Retorno implícito em EAX
end;

// ---------------------------------------------------------------------------
// Fibonacci recursivo 32-bit
// (apenas para demonstrar múltiplos níveis de recursão no CPU View)
// ---------------------------------------------------------------------------
function FibAsm(N: Integer): Integer;
asm
  // EAX = N
  PUSH EBX
  PUSH ESI

  MOV  EBX, EAX          // EBX = N

  CMP  EBX, 1
  JLE  @fib_base          // N <= 1: retorna N

  // fib(N-1)
  LEA  EAX, [EBX-1]       // EAX = N-1
  CALL FibAsm             // EAX = fib(N-1)
  MOV  ESI, EAX           // ESI = fib(N-1)

  // fib(N-2)
  LEA  EAX, [EBX-2]       // EAX = N-2
  CALL FibAsm             // EAX = fib(N-2)

  ADD  EAX, ESI           // EAX = fib(N-1) + fib(N-2)
  JMP  @fib_fim

@fib_base:
  MOV  EAX, EBX           // retorna N

@fib_fim:
  POP  ESI
  POP  EBX
end;

// ---------------------------------------------------------------------------
// Potência recursiva: base^exp
// EAX = Base, EDX = Exp
// ---------------------------------------------------------------------------
function PotenciaAsm(Base, Exp: Integer): Integer;
asm
  // EAX = Base, EDX = Exp
  PUSH EBX
  PUSH ESI

  MOV  EBX, EAX     // EBX = Base
  MOV  ESI, EDX     // ESI = Exp

  // Caso base: Exp <= 0 → retorna 1
  TEST ESI, ESI
  JLE  @pot_base

  // Caso recursivo: Base * potencia(Base, Exp-1)
  MOV  EAX, EBX     // EAX = Base
  LEA  EDX, [ESI-1] // EDX = Exp-1
  CALL PotenciaAsm   // EAX = potencia(Base, Exp-1)
  IMUL EAX, EBX     // EAX = Base * potencia(Base, Exp-1)
  JMP  @pot_fim

@pot_base:
  MOV  EAX, 1       // base^0 = 1

@pot_fim:
  POP  ESI
  POP  EBX
end;

var
  I: Integer;

begin
  WriteLn('=== Recursão em ASM Puro ===');
  WriteLn;

  WriteLn('Fatorial:');
  for I := 0 to 10 do
    WriteLn(Format('  %2d! = %d', [I, FatorialAsm(I)]));
  WriteLn;

  WriteLn('Fibonacci:');
  for I := 0 to 10 do
    Write(FibAsm(I), ' ');
  WriteLn;
  WriteLn;

  WriteLn('Potência:');
  WriteLn('  2^8 = ', PotenciaAsm(2, 8));   // 256
  WriteLn('  3^4 = ', PotenciaAsm(3, 4));   // 81
  WriteLn('  10^3 = ', PotenciaAsm(10, 3)); // 1000

  ReadLn;
end.
