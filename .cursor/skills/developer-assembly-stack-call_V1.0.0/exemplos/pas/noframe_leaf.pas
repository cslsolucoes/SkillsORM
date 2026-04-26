unit noframe_leaf;
{
  noframe_leaf.pas
  Demonstra funções leaf com .NOFRAME — sem overhead de prologue/epilogue.
  Uma função leaf não chama nenhuma outra função.
  Compilar: dcc64 noframe_leaf.pas
}

{$APPTYPE CONSOLE}
program noframe_leaf;

// ---------------------------------------------------------------------------
// Função leaf simples com .NOFRAME
// Não chama outras funções → pode omitir PUSH RBP / MOV RBP,RSP
// ---------------------------------------------------------------------------
function IncrementarLeaf(X: Integer): Integer;
// RCX = X (Windows x64), Retorno: EAX
asm
  {$IFDEF CPUX64}
  .NOFRAME               // Sem prologue/epilogue gerado
  // RCX = X
  MOV  EAX, ECX
  INC  EAX               // EAX = X + 1
  // Sem .PARAMS → sem shadow space → não pode chamar CALL dentro!
  {$ELSE}
  INC  EAX               // 32-bit: EAX = X + 1 (X em EAX)
  {$ENDIF}
end;

function SomarLeaf(A, B: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX = A, RDX = B
  MOV  EAX, ECX
  ADD  EAX, EDX          // EAX = A + B
  {$ELSE}
  ADD  EAX, EDX
  {$ENDIF}
end;

function IsPositivo(X: Integer): Boolean;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX = X
  TEST ECX, ECX
  SETG AL                // AL = 1 se X > 0, 0 caso contrário
  MOVZX EAX, AL         // zero-extend para limpar bits superiores
  {$ELSE}
  TEST EAX, EAX
  SETG AL
  MOVZX EAX, AL
  {$ENDIF}
end;

// Operação bitwise leaf
function MascaraLeaf(V, Mascara: Cardinal): Cardinal;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  // RCX = V, RDX = Mascara
  MOV  EAX, ECX
  AND  EAX, EDX          // EAX = V AND Mascara
  {$ELSE}
  AND  EAX, EDX
  {$ENDIF}
end;

// Comparação sem branch (leaf)
function MaxLeaf(A, B: Integer): Integer;
asm
  {$IFDEF CPUX64}
  .NOFRAME
  MOV   EAX, ECX         // EAX = A
  CMP   EAX, EDX         // A vs B
  CMOVL EAX, EDX         // se A < B, EAX = B
  {$ELSE}
  CMP  EAX, EDX
  CMOVL EAX, EDX
  {$ENDIF}
end;

// ---------------------------------------------------------------------------
// Contrastando: versão COM frame (overhead de prologue/epilogue)
// ---------------------------------------------------------------------------
function IncrementarComFrame(X: Integer): Integer;
asm
  {$IFDEF CPUX64}
  // SEM .NOFRAME → gera prologue/epilogue automaticamente
  // Custos extras: PUSH RBP + MOV RBP,RSP + ... + POP RBP
  // Para uma função tão simples, isso é overhead desnecessário
  MOV  EAX, ECX
  INC  EAX
  {$ELSE}
  INC  EAX
  {$ENDIF}
end;

begin
  WriteLn('=== Funções Leaf com .NOFRAME ===');
  WriteLn;

  WriteLn('IncrementarLeaf(41) = ', IncrementarLeaf(41));    // 42
  WriteLn('SomarLeaf(7, 8) = ', SomarLeaf(7, 8));            // 15
  WriteLn('IsPositivo(5) = ', IsPositivo(5));                  // True
  WriteLn('IsPositivo(-5) = ', IsPositivo(-5));                // False
  WriteLn('IsPositivo(0) = ', IsPositivo(0));                  // False
  WriteLn;
  WriteLn('MascaraLeaf($FF, $0F) = ', MascaraLeaf($FF, $0F)); // 15
  WriteLn('MaxLeaf(10, 20) = ', MaxLeaf(10, 20));              // 20
  WriteLn('MaxLeaf(-5, -10) = ', MaxLeaf(-5, -10));            // -5

  ReadLn;
end.
