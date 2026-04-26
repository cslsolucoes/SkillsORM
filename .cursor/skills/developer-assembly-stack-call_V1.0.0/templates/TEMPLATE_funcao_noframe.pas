unit TEMPLATE_funcao_noframe;
{
  TEMPLATE_funcao_noframe.pas
  Esqueleto de função leaf Win64 com .NOFRAME.
  Use para funções simples que NÃO fazem chamadas internas.

  QUANDO USAR .NOFRAME:
    ✓ Função não chama nenhuma outra função
    ✓ Função não precisa de variáveis locais na stack
    ✓ Função é chamada com alta frequência (hot path)
    ✓ Objetivo: eliminar overhead de prologue/epilogue

  QUANDO NÃO USAR .NOFRAME:
    ✗ Função faz CALL (sem shadow space → comportamento indefinido)
    ✗ Função pode ter exceção atravessando o frame (sem unwind info)
    ✗ Função usa variáveis locais na stack
}

{$APPTYPE CONSOLE}
program TEMPLATE_funcao_noframe;

// ---------------------------------------------------------------------------
// TEMPLATE: Operação matemática simples
// ---------------------------------------------------------------------------
function Incrementar(X: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME          // sem prologue/epilogue
  // RCX = X (Windows x64)
  MOV EAX, ECX
  INC EAX           // EAX = X + 1
  {$ELSE}
  // 32-bit: EAX = X
  INC EAX
  {$ENDIF}
end;

function SomarLeaf(A, B: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  MOV EAX, ECX
  ADD EAX, EDX      // EAX = A + B
  {$ELSE}
  ADD EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Operação lógica sem branch
// ---------------------------------------------------------------------------
function MaxLeaf(A, B: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX=A, RDX=B
  MOV   EAX, ECX
  CMP   EAX, EDX
  CMOVL EAX, EDX    // se A < B, EAX = B
  {$ELSE}
  CMP  EAX, EDX
  CMOVL EAX, EDX
  {$ENDIF}
end;

function AbsLeaf(X: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  MOV   EAX, ECX
  MOV   EDX, EAX
  SAR   EDX, 31     // EDX = -1 se X < 0, 0 se X >= 0
  XOR   EAX, EDX
  SUB   EAX, EDX    // abs sem branch
  {$ELSE}
  MOV   EDX, EAX
  SAR   EDX, 31
  XOR   EAX, EDX
  SUB   EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Operação bit a bit
// ---------------------------------------------------------------------------
function TestarBitLeaf(V: Cardinal; Bit: Byte): Boolean;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX=V, RDX=Bit (byte)
  MOV   EAX, ECX    // EAX = V
  MOV   CL,  DL     // CL = Bit
  SHR   EAX, CL     // EAX = V >> Bit
  AND   EAX, 1      // EAX = bit isolado (0 ou 1)
  {$ELSE}
  // EAX=V, DL=Bit
  MOV  CL, DL
  SHR  EAX, CL
  AND  EAX, 1
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// TEMPLATE: Conversão de tipo sem branch
// ---------------------------------------------------------------------------
function BoolParaInt(B: Boolean): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX = B (0 ou 1 como Boolean)
  MOVZX EAX, CL     // zero-extend byte para dword
  {$ELSE}
  MOVZX EAX, AL
  {$ENDIF}
end;

begin
  WriteLn('=== Template Função Leaf com .NOFRAME ===');
  WriteLn;

  WriteLn('Incrementar(41) = ', Incrementar(41));         // 42
  WriteLn('SomarLeaf(7, 8) = ', SomarLeaf(7, 8));         // 15
  WriteLn('MaxLeaf(10, 20) = ', MaxLeaf(10, 20));          // 20
  WriteLn('MaxLeaf(-5, -10) = ', MaxLeaf(-5, -10));        // -5
  WriteLn('AbsLeaf(-99) = ', AbsLeaf(-99));                 // 99
  WriteLn('AbsLeaf(99) = ', AbsLeaf(99));                   // 99
  WriteLn;
  WriteLn('TestarBitLeaf($42, 6) = ', TestarBitLeaf($42, 6)); // True (bit 6 de 0x42)
  WriteLn('TestarBitLeaf($42, 0) = ', TestarBitLeaf($42, 0)); // False
  WriteLn;
  WriteLn('BoolParaInt(True) = ', BoolParaInt(True));   // 1
  WriteLn('BoolParaInt(False) = ', BoolParaInt(False)); // 0

  ReadLn;
end.
