unit condicional_cmov;
{
  condicional_cmov.pas
  Demonstra CMOVcc: max(a,b) sem branch — técnica performance-critical.
  Compilar: dcc32 condicional_cmov.pas
}

{$APPTYPE CONSOLE}
program condicional_cmov;

// max(A, B) com sinal — sem branch usando CMOVL
function MaxSigned(A, B: Integer): Integer;
asm
  // EAX = A, EDX = B (convenção register)
  CMP   EAX, EDX    // A vs B
  CMOVL EAX, EDX    // se A < B (signed), EAX = B
  // else EAX já tem A
end;

// min(A, B) com sinal
function MinSigned(A, B: Integer): Integer;
asm
  CMP   EAX, EDX
  CMOVG EAX, EDX    // se A > B, EAX = B
end;

// max(A, B) sem sinal
function MaxUnsigned(A, B: Cardinal): Cardinal;
asm
  CMP   EAX, EDX
  CMOVB EAX, EDX    // se A < B (unsigned/below), EAX = B
end;

// Clamp: limita V ao intervalo [Lo, Hi]
function Clamp(V, Lo, Hi: Integer): Integer;
// V=EAX, Lo=EDX, Hi=ECX
asm
  CMP   EAX, EDX
  CMOVL EAX, EDX    // se V < Lo, V = Lo
  CMP   EAX, ECX
  CMOVG EAX, ECX    // se V > Hi, V = Hi
end;

// Valor absoluto sem branch usando CMOV
function AbsValor(X: Integer): Integer;
asm
  // EAX = X
  MOV   EDX, EAX
  NEG   EDX         // EDX = -X
  CMP   EAX, 0
  CMOVL EAX, EDX    // se X < 0, EAX = -X
end;

// Seleção: se Cond = True, retorna A, senão B
function Selecionar(Cond: Boolean; A, B: Integer): Integer;
// Cond = AL (byte), A = EDX (2° param), B = ECX (3° param)
// (Nota: Boolean em EAX como 1° param; A em EDX, B em ECX)
asm
  // EAX = Cond (0 ou 1), EDX = A, ECX = B
  TEST  AL, AL      // ZF=1 se Cond=False
  CMOVNZ EAX, EDX  // se Cond != 0, EAX = A
  CMOVZ  EAX, ECX  // se Cond = 0, EAX = B
end;

// Demonstração de performance: loop com CMOVcc vs branch
// Encontra o máximo em um array sem misprediction
function MaxNoArray(Arr: PInteger; N: Integer): Integer;
// EAX = Arr, EDX = N
asm
  PUSH EBX
  PUSH ESI

  MOV  EBX, EAX        // EBX = Arr
  MOV  ESI, EDX        // ESI = N

  TEST ESI, ESI
  JLE  @vazio
  MOV  EAX, [EBX]      // EAX = Arr[0] (máximo inicial)
  MOV  ECX, 1          // índice = 1

@loop:
  CMP  ECX, ESI        // índice >= N?
  JGE  @fim
  MOV  EDX, [EBX + ECX*4]   // EDX = Arr[índice]
  CMP  EDX, EAX
  CMOVG EAX, EDX       // se Arr[i] > max, max = Arr[i] (SEM BRANCH!)
  INC  ECX
  JMP  @loop

@vazio:
  MOV  EAX, 0
@fim:
  POP  ESI
  POP  EBX
end;

const
  N_ELEM = 10;

var
  Arr: array[0..N_ELEM-1] of Integer;
  I: Integer;

begin
  WriteLn('=== CMOVcc — Operações Condicionais Sem Branch ===');
  WriteLn;

  WriteLn('MaxSigned(7, 3) = ', MaxSigned(7, 3));           // 7
  WriteLn('MaxSigned(-5, -10) = ', MaxSigned(-5, -10));     // -5
  WriteLn('MinSigned(7, 3) = ', MinSigned(7, 3));           // 3
  WriteLn;

  WriteLn('Clamp(5, 1, 10) = ', Clamp(5, 1, 10));          // 5
  WriteLn('Clamp(-5, 1, 10) = ', Clamp(-5, 1, 10));        // 1 (clamped to lo)
  WriteLn('Clamp(15, 1, 10) = ', Clamp(15, 1, 10));        // 10 (clamped to hi)
  WriteLn;

  WriteLn('AbsValor(-42) = ', AbsValor(-42));               // 42
  WriteLn('AbsValor(42) = ', AbsValor(42));                 // 42
  WriteLn;

  WriteLn('Selecionar(True, 100, 200) = ', Selecionar(True, 100, 200));   // 100
  WriteLn('Selecionar(False, 100, 200) = ', Selecionar(False, 100, 200)); // 200
  WriteLn;

  // Array com valores variados
  Arr[0] := 5; Arr[1] := 12; Arr[2] := 3; Arr[3] := 99;
  Arr[4] := 7; Arr[5] := 42; Arr[6] := 1; Arr[7] := 0;
  Arr[8] := 55; Arr[9] := 8;

  Write('Array: ');
  for I := 0 to N_ELEM - 1 do Write(Arr[I], ' ');
  WriteLn;
  WriteLn('Máximo: ', MaxNoArray(@Arr[0], N_ELEM));  // 99

  ReadLn;
end.
