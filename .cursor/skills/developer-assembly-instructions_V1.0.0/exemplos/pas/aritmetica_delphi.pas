unit aritmetica_delphi;
{
  aritmetica_delphi.pas
  Demonstra ADD/SUB/IMUL/IDIV em asm..end com variáveis Pascal.
  Compilar: dcc32 aritmetica_delphi.pas
}

{$APPTYPE CONSOLE}
program aritmetica_delphi;

// Soma dois inteiros
function Soma(A, B: Integer): Integer;
asm
  ADD EAX, EDX      // EAX = A + B (EAX=A, EDX=B em 32-bit)
end;

// Subtração
function Subtrair(A, B: Integer): Integer;
asm
  SUB EAX, EDX      // EAX = A - B
end;

// Multiplicação com sinal (IMUL 2 operandos — resultado truncado)
function Multiplicar(A, B: Integer): Integer;
asm
  IMUL EAX, EDX     // EAX = A * B (truncado — overflow silencioso)
end;

// Divisão com sinal: retorna quociente
function Dividir(Dividendo, Divisor: Integer): Integer;
var
  Q, R: Integer;
begin
  Q := 0; R := 0;
  if Divisor = 0 then
    raise EDivByZero.Create('Divisao por zero');
  asm
    MOV  EAX, Dividendo
    CDQ                       // sign-extend EAX → EDX:EAX
    IDIV Divisor              // EAX = quociente, EDX = resto
    MOV  Q, EAX
    MOV  R, EDX
  end;
  Result := Q;
  // WriteLn('Resto: ', R);  // descomente para ver o resto
end;

// Resto da divisão
function Modulo(Dividendo, Divisor: Integer): Integer;
var
  M: Integer;
begin
  M := 0;
  if Divisor = 0 then
    raise EDivByZero.Create('Divisao por zero');
  asm
    MOV  EAX, Dividendo
    CDQ
    IDIV Divisor              // EDX = resto
    MOV  M, EDX
  end;
  Result := M;
end;

// Negação
function Negar(X: Integer): Integer;
asm
  NEG EAX               // EAX = -EAX
end;

// Valor absoluto via NEG + CMOV (sem branch — 32-bit)
function AbsoluteValue(X: Integer): Integer;
asm
  MOV  EDX, EAX        // EDX = X
  NEG  EDX             // EDX = -X
  CMOVL EAX, EDX       // se X < 0 (SF=1 após NEG set flags? Não — usar CMP)
  // Forma mais correta:
  MOV  EDX, EAX        // EDX = X
  SAR  EDX, 31         // EDX = 0 se X>=0, 0xFFFFFFFF se X<0
  XOR  EAX, EDX        // complementa bits se negativo
  SUB  EAX, EDX        // adiciona 1 se negativo
end;

// Incremento e decremento
procedure IncrementoDecremento(var V: Integer);
asm
  // Em 32-bit: EAX = @V (ponteiro para a variável)
  INC dword ptr [EAX]   // (*V)++
  INC dword ptr [EAX]   // (*V)++
  DEC dword ptr [EAX]   // (*V)-- → líquido: +1
end;

// Operação combinada: resultado = A*B + C*D
function MAC(A, B, C, D: Integer): Int64;
// A=EAX, B=EDX, C=ECX, D=[EBP+...]
var
  AB, CD: Int64;
begin
  AB := 0; CD := 0;
  asm
    PUSH EBX          // preservar EBX

    // A * B → EDX:EAX
    MOV  EBX, EDX     // EBX = B
    IMUL EBX          // EDX:EAX = A * B
    MOV  dword ptr [AB],   EAX
    MOV  dword ptr [AB+4], EDX

    // C * D
    MOV  EAX, C
    MOV  EBX, D
    IMUL EBX
    MOV  dword ptr [CD],   EAX
    MOV  dword ptr [CD+4], EDX

    POP  EBX
  end;
  Result := AB + CD;  // usa Pascal para a soma final de Int64
end;

var
  V: Integer;

begin
  WriteLn('=== Aritmetica com asm..end ===');
  WriteLn;
  WriteLn('3 + 7 = ', Soma(3, 7));               // 10
  WriteLn('15 - 6 = ', Subtrair(15, 6));          // 9
  WriteLn('7 * 8 = ', Multiplicar(7, 8));          // 56
  WriteLn('100 / 7 = ', Dividir(100, 7));          // 14
  WriteLn('100 mod 7 = ', Modulo(100, 7));         // 2
  WriteLn('-5 * 3 = ', Multiplicar(-5, 3));         // -15
  WriteLn('-15 / 4 = ', Dividir(-15, 4));           // -3
  WriteLn('-15 mod 4 = ', Modulo(-15, 4));          // -3 (Delphi: truncação para zero)
  WriteLn;
  WriteLn('Negar(42) = ', Negar(42));              // -42
  WriteLn('Negar(-42) = ', Negar(-42));            // 42
  WriteLn('AbsoluteValue(-99) = ', AbsoluteValue(-99));  // 99
  WriteLn('AbsoluteValue(99) = ', AbsoluteValue(99));    // 99
  WriteLn;

  V := 10;
  IncrementoDecremento(V);
  WriteLn('Após IncrementoDecremento(10) = ', V);  // 11

  WriteLn;
  WriteLn('MAC(3, 4, 5, 6) = 3*4 + 5*6 = ', MAC(3, 4, 5, 6));  // 42

  ReadLn;
end.
