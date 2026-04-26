unit TEMPLATE_asm_minimo;
{
  TEMPLATE_asm_minimo.pas
  Template mínimo de procedure com bloco asm..end comentado.

  INSTRUÇÕES DE USO:
  1. Copiar esta unit
  2. Renomear a unit e o arquivo
  3. Implementar a lógica assembly no bloco asm..end
  4. Ajustar parâmetros e tipo de retorno conforme necessário

  REGRAS OBRIGATÓRIAS:
  - Em 32-bit: preservar EBX, ESI, EDI, EBP (push/pop)
  - Em 64-bit: preservar RBX, RSI, RDI, RBP, R12-R15 (.PUSHNV ou push/pop manual)
  - Nunca emitir RET manualmente — o Delphi gera o epilogue
  - Variáveis locais acessíveis pelo nome diretamente
  - Parâmetros "register" chegam em EAX/RCX, EDX/RDX, ECX/R8
}

{$APPTYPE CONSOLE}
program TEMPLATE_asm_minimo;

// ---------------------------------------------------------------------------
// Procedure simples sem retorno
// ---------------------------------------------------------------------------
procedure ProceduraSemRetorno(Param1: Integer);
var
  VarLocal: Integer;
begin
  VarLocal := 0;
  asm
    // [32-bit] Param1 está em EAX (convenção register)
    // [64-bit] Param1 está em ECX (Windows x64 ABI)

    // --- SALVAR registradores que DEVEM ser preservados ---
    // (descomente conforme os registradores que vai usar)
    // PUSH EBX   // 32-bit
    // PUSH ESI
    // PUSH EDI

    // --- Implementação ---
    MOV EAX, Param1    // carrega parâmetro
    ADD EAX, 1         // incrementa
    MOV VarLocal, EAX  // salva em variável local

    // --- RESTAURAR registradores (na ordem inversa) ---
    // POP EDI
    // POP ESI
    // POP EBX

    // Sem RET — o Delphi gera o epilogue automático
  end;

  // Código Pascal pode continuar após o bloco asm
  WriteLn('VarLocal = ', VarLocal);
end;

// ---------------------------------------------------------------------------
// Função com retorno inteiro
// ---------------------------------------------------------------------------
function FuncaoComRetorno(A, B: Integer): Integer;
// 32-bit: EAX = A, EDX = B → retorno em EAX
// 64-bit: ECX = A, EDX = B → retorno em EAX/RAX
asm
  // --- SALVAR registradores preservados ---
  // (neste exemplo simples, não precisamos)

  // --- Implementação ---
  {$IFDEF CPUX64}
    // Windows x64 ABI
    MOV EAX, ECX    // EAX = A
    ADD EAX, EDX    // EAX = A + B
  {$ELSE}
    // Delphi 32-bit "register" convention
    ADD EAX, EDX    // EAX = A + B (EAX já tem A)
  {$ENDIF}

  // Resultado: valor em EAX é o retorno
end;

// ---------------------------------------------------------------------------
// Procedure com preservação explícita (template para funções que usam EBX/ESI/EDI)
// ---------------------------------------------------------------------------
procedure ProceduraComPreservacao(N: Integer);
var
  Resultado: Integer;
begin
  Resultado := 0;
  asm
    // SALVAR registradores não-voláteis usados
    PUSH EBX
    PUSH ESI

    // Implementação usando EBX e ESI livremente
    MOV EBX, N
    MOV ESI, 7
    IMUL EBX, ESI   // EBX = N * 7
    MOV Resultado, EBX

    // RESTAURAR na ordem inversa
    POP ESI
    POP EBX
  end;

  WriteLn('N * 7 = ', Resultado);
end;

begin
  ProceduraSemRetorno(10);
  WriteLn('3 + 4 = ', FuncaoComRetorno(3, 4));
  ProceduraComPreservacao(6);
  ReadLn;
end.
