unit frame_64bit;
{
  frame_64bit.pas
  Função ASM pura 64-bit com .PARAMS, .PUSHNV, shadow space.
  Demonstra o uso das pseudo-ops do built-in assembler Delphi 64-bit.
  Compilar: dcc64 frame_64bit.pas
}

{$APPTYPE CONSOLE}
program frame_64bit;

// ---------------------------------------------------------------------------
// Função 64-bit usando .PARAMS (gera shadow space automático)
// ---------------------------------------------------------------------------
function Soma64(A, B: Int64): Int64;
// RCX = A, RDX = B, Retorno: RAX
asm
  {$IFDEF CPUX64}
  .PARAMS 2           // Declara 2 parâmetros — gera shadow space de 32 bytes
  MOV RAX, RCX        // RAX = A
  ADD RAX, RDX        // RAX = A + B
  {$ELSE}
  ADD EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Função 64-bit usando .PUSHNV para registradores callee-saved
// .PUSHNV gera PUSH + unwind information (para SEH/exceções)
// ---------------------------------------------------------------------------
function ProcessarComRegistradores(Arr: PInt64; N: Integer): Int64;
// RCX = Arr, RDX = N, Retorno: RAX = soma
asm
  {$IFDEF CPUX64}
  .PARAMS 2
  .PUSHNV RBX         // salva RBX + gera unwind info
  .PUSHNV RSI         // salva RSI + gera unwind info
  .PUSHNV RDI         // salva RDI + gera unwind info

  MOV     RSI, RCX    // RSI = Arr
  MOVSXD  RDI, EDX   // RDI = N (sign-extend 32→64)
  XOR     RBX, RBX    // RBX = acumulador = 0

  TEST    RDI, RDI
  JLE     @fim64

  LEA     RCX, [RSI + RDI*8]  // RCX = Arr + N (one past end)

@loop64:
  CMP     RSI, RCX
  JGE     @fim64
  ADD     RBX, [RSI]
  ADD     RSI, 8
  JMP     @loop64

@fim64:
  MOV     RAX, RBX    // retorno em RAX
  // Epilogue automático: POP RDI, POP RSI, POP RBX, RET
  {$ELSE}
  // Fallback 32-bit
  XOR EAX, EAX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Função 64-bit com acesso a variável local via [RBP-N]
// (usando Pascal var + asm combinados)
// ---------------------------------------------------------------------------
function ComputarComLocais(A, B, C: Int64): Int64;
var
  Temp1, Temp2: Int64;
begin
  Temp1 := 0;
  Temp2 := 0;
  asm
    {$IFDEF CPUX64}
    // RCX=A, RDX=B, R8=C
    // Variáveis locais acessíveis pelo nome
    MOV  RAX, RCX
    IMUL RAX, RDX     // RAX = A * B
    MOV  Temp1, RAX   // Temp1 = A*B

    MOV  RAX, R8
    IMUL RAX, RCX     // RAX = C * A
    MOV  Temp2, RAX   // Temp2 = C*A
    {$ELSE}
    MOV  EAX, A
    IMUL EAX, B
    MOV  Temp1, EAX
    MOV  EAX, C
    IMUL EAX, A
    MOV  Temp2, EAX
    {$ENDIF}
  end;
  Result := Temp1 + Temp2;  // A*B + C*A = A*(B+C)
end;

// ---------------------------------------------------------------------------
// Demonstra retorno de float via XMM0 em 64-bit
// ---------------------------------------------------------------------------
function MultDouble(A, B: Double): Double;
// A em XMM0, B em XMM1 (Windows x64 ABI)
asm
  {$IFDEF CPUX64}
  MULSD XMM0, XMM1    // XMM0 = A * B (scalar double)
  // Retorno em XMM0
  {$ELSE}
  FLD   A
  FMUL  B
  FSTP  Result
  {$ENDIF}
end;

const
  N_ELEM = 5;

var
  Arr: array[0..N_ELEM-1] of Int64;
  I: Integer;

begin
  WriteLn('=== Stack Frame 64-bit (dcc64) ===');
  WriteLn;

  WriteLn('Soma64(100, 200) = ', Soma64(100, 200));            // 300
  WriteLn;

  for I := 0 to N_ELEM-1 do Arr[I] := (I + 1) * 10;         // 10,20,30,40,50
  WriteLn('ProcessarComRegistradores (soma): ', ProcessarComRegistradores(@Arr[0], N_ELEM)); // 150
  WriteLn;

  WriteLn('ComputarComLocais(3, 4, 5) = 3*4 + 5*3 = ', ComputarComLocais(3, 4, 5)); // 27
  WriteLn;

  WriteLn('MultDouble(3.14, 2.0) = ', MultDouble(3.14, 2.0):0:4);
  WriteLn;

  ReadLn;
end.
