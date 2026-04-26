unit loop_counter;
{
  loop_counter.pas
  Demonstra loop com ECX como contador via instrução LOOP.
  Compilar: dcc32 loop_counter.pas
}

{$APPTYPE CONSOLE}
program loop_counter;

// Soma de 1 a N usando instrução LOOP
function SomaDe1aN(N: Integer): Integer;
// EAX = N
asm
  MOV   ECX, EAX   // ECX = N (contador para LOOP)
  XOR   EAX, EAX   // EAX = 0 (acumulador)
  TEST  ECX, ECX
  JLE   @fim        // N <= 0: retorna 0

@loop:
  ADD   EAX, ECX   // EAX += ECX (10 + 9 + 8 + ... + 1)
  LOOP  @loop       // ECX--; se ECX != 0, salta para @loop

@fim:
  // EAX = N*(N+1)/2 = resultado da soma
end;

// Cópia de array usando LOOP + LODSB/STOSB (demonstração didática)
// (Na prática, REP MOVSB é mais eficiente)
procedure CopiarComLoop(Dst, Src: PByte; N: Integer);
asm
  // EAX = Dst, EDX = Src, ECX = N
  PUSH ESI
  PUSH EDI

  MOV  EDI, EAX    // EDI = Dst
  MOV  ESI, EDX    // ESI = Src
  CLD              // DF=0: incrementar

  TEST ECX, ECX
  JLE  @fim_copia

@copia_loop:
  LODSB            // AL = [ESI]; ESI++
  STOSB            // [EDI] = AL; EDI++
  LOOP @copia_loop  // ECX--; repete se ECX != 0

@fim_copia:
  POP  EDI
  POP  ESI
end;

// Fatorial usando LOOP (N! para N <= 12 cabe em Integer)
function Fatorial(N: Integer): Integer;
asm
  MOV  ECX, EAX    // ECX = N (contador)
  MOV  EAX, 1      // EAX = 1 (resultado inicial)
  TEST ECX, ECX
  JLE  @fatorial_fim // N <= 0: retorna 1 (0! = 1)

@fatorial_loop:
  IMUL EAX, ECX    // EAX *= ECX
  LOOP @fatorial_loop

@fatorial_fim:
  // EAX = N!
end;

// Potência: base^exp usando LOOP
function Potencia(Base, Exp: Integer): Integer;
// Base = EAX, Exp = EDX
asm
  PUSH EBX
  MOV  EBX, EAX    // EBX = Base
  MOV  ECX, EDX    // ECX = Exp (contador)
  MOV  EAX, 1      // EAX = 1 (resultado)

  TEST ECX, ECX
  JLE  @pot_fim

@pot_loop:
  IMUL EAX, EBX    // EAX *= Base
  LOOP @pot_loop

@pot_fim:
  POP  EBX
end;

// Demonstra que LOOP não afeta CF (diferença de INC/DEC)
procedure DemoLoopNaoCF;
var
  ValCF: Byte;
begin
  ValCF := 0;
  asm
    STC              // CF = 1
    MOV  ECX, 3
  @cf_loop:
    NOP
    LOOP @cf_loop    // LOOP não modifica CF
    SETC ValCF       // ValCF = CF (deve ainda ser 1)
  end;
  WriteLn('CF preservado após LOOP: ', ValCF = 1);
end;

var
  Buf1: array[0..9] of Byte;
  Buf2: array[0..9] of Byte;
  I: Integer;

begin
  WriteLn('=== Loop com ECX e instrução LOOP ===');
  WriteLn;

  WriteLn('Soma de 1 a 10 = ', SomaDe1aN(10));   // 55
  WriteLn('Soma de 1 a 100 = ', SomaDe1aN(100)); // 5050
  WriteLn('Soma de 1 a 0 = ', SomaDe1aN(0));     // 0
  WriteLn;

  for I := 0 to 9 do Buf1[I] := I * 10;         // 0, 10, 20, ..., 90
  CopiarComLoop(@Buf2[0], @Buf1[0], 10);
  Write('Após cópia com LOOP: ');
  for I := 0 to 9 do Write(Buf2[I], ' ');
  WriteLn;
  WriteLn;

  WriteLn('0! = ', Fatorial(0));   // 1
  WriteLn('1! = ', Fatorial(1));   // 1
  WriteLn('5! = ', Fatorial(5));   // 120
  WriteLn('10! = ', Fatorial(10)); // 3628800
  WriteLn;

  WriteLn('2^0 = ', Potencia(2, 0));   // 1
  WriteLn('2^8 = ', Potencia(2, 8));   // 256
  WriteLn('3^4 = ', Potencia(3, 4));   // 81
  WriteLn;

  DemoLoopNaoCF;

  ReadLn;
end.
