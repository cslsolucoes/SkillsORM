unit parametros_x64;
{
  parametros_x64.pas
  Demonstra a convenção Windows x64 ABI no Delphi 64-bit:
  RCX = 1° parâmetro, RDX = 2° parâmetro, R8 = 3° parâmetro, R9 = 4° parâmetro

  Compilar: dcc64 parametros_x64.pas
}

{$APPTYPE CONSOLE}
program parametros_x64;

// ---------------------------------------------------------------------------
// Função com 4 parâmetros — Windows x64 ABI
// RCX = P1, RDX = P2, R8 = P3, R9 = P4
// Retorno: RAX
// ---------------------------------------------------------------------------
function Soma4x64(P1, P2, P3, P4: Int64): Int64;
// Entrada: RCX=P1, RDX=P2, R8=P3, R9=P4
// Saída:   RAX = P1 + P2 + P3 + P4
asm
  {$IFDEF CPUX64}
  MOV RAX, RCX     // RAX = P1
  ADD RAX, RDX     // RAX += P2
  ADD RAX, R8      // RAX += P3
  ADD RAX, R9      // RAX += P4
  {$ELSE}
  // Fallback 32-bit (não deve chegar aqui se compilado com dcc64)
  XOR EAX, EAX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Método de objeto em 64-bit: Self = RCX (1° slot)
// Parâmetros deslocam: RDX=P1, R8=P2, R9=P3
// ---------------------------------------------------------------------------
type
  TCalculo = class
  private
    FBase: Int64;
  public
    constructor Create(Base: Int64);
    function AdicionarViaAsm(Incremento: Int64): Int64;
    function MultiplicarViaAsm(Fator: Int64): Int64;
  end;

constructor TCalculo.Create(Base: Int64);
begin
  inherited Create;
  FBase := Base;
end;

function TCalculo.AdicionarViaAsm(Incremento: Int64): Int64;
// RCX = Self, RDX = Incremento
// Retorno: RAX = Self.FBase + Incremento
asm
  {$IFDEF CPUX64}
  // Acessar FBase pelo nome do campo (Delphi resolve o offset)
  MOV RAX, [RCX].TCalculo.FBase   // RAX = Self.FBase
  ADD RAX, RDX                    // RAX += Incremento
  {$ELSE}
  MOV EAX, [EAX].TCalculo.FBase
  ADD EAX, EDX
  {$ENDIF}
end;

function TCalculo.MultiplicarViaAsm(Fator: Int64): Int64;
// RCX = Self, RDX = Fator
asm
  {$IFDEF CPUX64}
  MOV  RAX, [RCX].TCalculo.FBase  // RAX = FBase
  IMUL RAX, RDX                   // RAX = FBase * Fator
  {$ELSE}
  MOV  EAX, [EAX].TCalculo.FBase
  IMUL EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Demonstra retorno de float via XMM0 em 64-bit
// ---------------------------------------------------------------------------
function MultiplicaDouble(A, B: Double): Double;
// Windows x64: A em XMM0, B em XMM1
// Retorno: XMM0
asm
  {$IFDEF CPUX64}
  // XMM0 = A, XMM1 = B
  MULSD XMM0, XMM1    // XMM0 = A * B (multiply scalar double)
  // Retorno em XMM0
  {$ELSE}
  // 32-bit: operação na FPU
  FLD   A
  FMUL  B
  FSTP  Result
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// 5° parâmetro — vai para stack (acima do shadow space)
// ---------------------------------------------------------------------------
function Soma5x64(P1, P2, P3, P4, P5: Int64): Int64;
// P1=RCX, P2=RDX, P3=R8, P4=R9
// P5 = [RSP+40] (após prologue: [RBP+48] com shadow space de 32 bytes)
// Melhor usar Pascal + asm combinados para parâmetros de stack
var
  S: Int64;
begin
  S := 0;
  asm
    {$IFDEF CPUX64}
    MOV  RAX, P1
    ADD  RAX, P2
    ADD  RAX, P3
    ADD  RAX, P4
    ADD  RAX, P5     // P5 acessado como variável (Delphi resolve offset)
    MOV  S, RAX
    {$ELSE}
    XOR EAX, EAX
    {$ENDIF}
  end;
  Result := S;
end;

var
  Calc: TCalculo;

begin
  WriteLn('=== Windows x64 ABI — Parametros em Registradores ===');
  WriteLn;

  WriteLn('Soma4x64(1,2,3,4) = ', Soma4x64(1, 2, 3, 4));         // 10
  WriteLn('Soma4x64(100,200,300,400) = ', Soma4x64(100,200,300,400)); // 1000
  WriteLn;

  Calc := TCalculo.Create(100);
  try
    WriteLn('Base = ', Calc.FBase);
    WriteLn('Adicionar(50) = ', Calc.AdicionarViaAsm(50));   // 150
    WriteLn('Multiplicar(3) = ', Calc.MultiplicarViaAsm(3)); // 300
  finally
    Calc.Free;
  end;
  WriteLn;

  WriteLn('3.14 * 2.0 = ', MultiplicaDouble(3.14, 2.0):0:4);
  WriteLn;

  WriteLn('Soma5x64(1,2,3,4,5) = ', Soma5x64(1, 2, 3, 4, 5)); // 15
  WriteLn;

  ReadLn;
end.
