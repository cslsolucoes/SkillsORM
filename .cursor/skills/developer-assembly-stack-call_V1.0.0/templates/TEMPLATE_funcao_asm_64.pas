unit TEMPLATE_funcao_asm_64;
{
  TEMPLATE_funcao_asm_64.pas
  Esqueleto completo de função ASM pura Win64 com .PARAMS e .PUSHNV.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Ajustar .PARAMS N para o número real de parâmetros (1-4)
  3. Adicionar .PUSHNV para cada registrador callee-saved que for usar
  4. Implementar a lógica entre as pseudo-ops e o fim do bloco asm
  5. Certificar que o retorno está em RAX (inteiro) ou XMM0 (float)

  WINDOWS x64 ABI:
    RCX = 1° param ou Self
    RDX = 2° param
    R8  = 3° param
    R9  = 4° param
    Retorno: RAX (inteiro/ponteiro), XMM0 (float/double)
    Callee-saved: RBX, RSI, RDI, RBP, R12-R15, XMM4-XMM15
}

{$APPTYPE CONSOLE}
program TEMPLATE_funcao_asm_64;

// ---------------------------------------------------------------------------
// TEMPLATE: Função com 2 parâmetros e registradores callee-saved
// ---------------------------------------------------------------------------
function MinhaFuncao64(A, B: Int64): Int64;
// RCX = A, RDX = B, Retorno: RAX
asm
  {$IFDEF CPUX64}
  .PARAMS 2         // shadow space para 2 parâmetros (32 bytes)
  .PUSHNV RBX       // salva RBX + unwind info

  // === IMPLEMENTAÇÃO ===
  MOV  RBX, RCX     // RBX = A
  ADD  RBX, RDX     // RBX = A + B
  MOV  RAX, RBX     // RAX = resultado

  // Epilogue gerado automaticamente: POP RBX, ADD RSP,32, RET
  {$ELSE}
  // Fallback 32-bit
  ADD EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Método de objeto em 64-bit (Self em RCX)
// ---------------------------------------------------------------------------
type
  TClasse64 = class
  private
    FValor: Int64;
  public
    constructor Create(V: Int64);
    function Calcular(Fator: Int64): Int64;
    procedure Somar(N: Int64);
  end;

constructor TClasse64.Create(V: Int64);
begin
  inherited Create;
  FValor := V;
end;

function TClasse64.Calcular(Fator: Int64): Int64;
// RCX = Self, RDX = Fator, Retorno: RAX
asm
  {$IFDEF CPUX64}
  .PARAMS 2
  MOV  RAX, [RCX].TClasse64.FValor   // RAX = Self.FValor
  IMUL RAX, RDX                        // RAX = FValor * Fator
  {$ELSE}
  MOV  EAX, [EAX].TClasse64.FValor
  IMUL EAX, EDX
  {$ENDIF}
end;

procedure TClasse64.Somar(N: Int64);
// RCX = Self, RDX = N
asm
  {$IFDEF CPUX64}
  .PARAMS 2
  ADD  [RCX].TClasse64.FValor, RDX   // Self.FValor += N
  {$ELSE}
  ADD  [EAX].TClasse64.FValor, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Função com loop sobre array Int64
// ---------------------------------------------------------------------------
function SomarArray64(Arr: PInt64; N: Integer): Int64;
// RCX = Arr, RDX = N, Retorno: RAX
asm
  {$IFDEF CPUX64}
  .PARAMS 2
  .PUSHNV RBX       // acumulador
  .PUSHNV RSI       // ponteiro

  MOV     RSI, RCX          // RSI = Arr
  MOVSXD  RCX, EDX         // RCX = N (sign-extend)
  XOR     RBX, RBX          // RBX = 0 (acumulador)

  TEST    RCX, RCX
  JLE     @fim64

  LEA     RDX, [RSI + RCX*8]  // RDX = Arr + N (one past end)

@loop64:
  CMP     RSI, RDX
  JGE     @fim64
  ADD     RBX, [RSI]
  ADD     RSI, 8
  JMP     @loop64

@fim64:
  MOV     RAX, RBX          // retorno em RAX
  // Epilogue automático: POP RSI, POP RBX, ADD RSP,32, RET
  {$ELSE}
  XOR EAX, EAX
  {$ENDIF}
end;

const
  N_ELEM = 5;

var
  Arr: array[0..N_ELEM-1] of Int64;
  Obj: TClasse64;
  I: Integer;

begin
  WriteLn('=== Template Função ASM Win64 ===');
  WriteLn;

  WriteLn('MinhaFuncao64(10, 20) = ', MinhaFuncao64(10, 20));  // 30

  Obj := TClasse64.Create(100);
  try
    WriteLn('FValor = 100');
    WriteLn('Calcular(5) = ', Obj.Calcular(5));    // 500
    Obj.Somar(50);
    WriteLn('Após Somar(50): Calcular(1) = ', Obj.Calcular(1));  // 150
  finally
    Obj.Free;
  end;

  for I := 0 to N_ELEM-1 do Arr[I] := (I+1) * 10;
  WriteLn('SomarArray64([10,20,30,40,50]) = ', SomarArray64(@Arr[0], N_ELEM)); // 150

  ReadLn;
end.
