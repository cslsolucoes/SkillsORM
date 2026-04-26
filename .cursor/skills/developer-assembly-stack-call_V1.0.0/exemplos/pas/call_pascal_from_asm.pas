unit call_pascal_from_asm;
{
  call_pascal_from_asm.pas
  Demonstra como chamar uma função Pascal de dentro de um bloco asm..end.
  Compilar: dcc32 call_pascal_from_asm.pas
}

{$APPTYPE CONSOLE}
program call_pascal_from_asm;

uses
  SysUtils;

// ---------------------------------------------------------------------------
// Função Pascal simples que será chamada pelo asm
// ---------------------------------------------------------------------------
function Dobrar(X: Integer): Integer;
begin
  Result := X * 2;
end;

function SomarPascal(A, B: Integer): Integer;
begin
  Result := A + B;
end;

// ---------------------------------------------------------------------------
// Procedure Pascal que será chamada pelo asm
// ---------------------------------------------------------------------------
procedure LogarValor(V: Integer);
begin
  WriteLn('  [log] valor = ', V);
end;

// ---------------------------------------------------------------------------
// Demonstra CALL a função Pascal de dentro do bloco asm..end
// Em Delphi 32-bit: Dobrar tem convenção "register" (EAX=X, retorno EAX)
// ---------------------------------------------------------------------------
function ProcessarComChamadaPascal(N: Integer): Integer;
// EAX = N
var
  Resultado: Integer;
begin
  Resultado := 0;
  asm
    // EAX = N (1° param em convenção register)
    PUSH EBX              // preservar EBX

    MOV  EBX, EAX         // EBX = N

    // Chamar Dobrar(N): coloca N em EAX e faz CALL
    MOV  EAX, EBX
    CALL Dobrar           // EAX = Dobrar(N) = N*2

    // EAX agora tem N*2
    // Chamar SomarPascal(N*2, 10)
    MOV  EDX, 10          // 2° param = 10
    // EAX já tem N*2 (1° param)
    CALL SomarPascal      // EAX = N*2 + 10

    MOV  Resultado, EAX

    POP  EBX
  end;
  Result := Resultado;
end;

// ---------------------------------------------------------------------------
// Demonstra: salvar registradores antes de CALL (CALL pode destrui-los)
// CALL Pascal preserva EBX, ESI, EDI, EBP — mas destrói EAX, EDX, ECX
// ---------------------------------------------------------------------------
procedure DemoSalvarAntesDaCALL;
var
  Val: Integer;
begin
  Val := 0;
  asm
    PUSH EBX

    // Salvar EAX e ECX (serão destruídos pelo CALL)
    MOV  EBX, 42      // EBX = 42 (callee-saved: seguro durante CALL)

    // Chamar Dobrar(EBX) — EBX é salvo pelo Dobrar (callee-saved)
    MOV  EAX, EBX
    CALL Dobrar        // EAX = 84; ECX e EDX podem ter mudado
    // EBX ainda é 42 (callee-saved em Dobrar)

    // Verificar que EBX foi preservado
    ADD  EAX, EBX     // EAX = 84 + 42 = 126
    MOV  Val, EAX

    POP  EBX
  end;
  WriteLn('Resultado: ', Val);  // 126
end;

// ---------------------------------------------------------------------------
// Demonstra: loop em asm que chama função Pascal a cada iteração
// ---------------------------------------------------------------------------
procedure LoopComChamadas(N: Integer);
asm
  PUSH EBX
  PUSH ESI

  MOV  EBX, EAX     // EBX = N (salvo de EAX, que será destruído pelo CALL)
  MOV  ESI, 1       // ESI = i = 1

@loop:
  CMP  ESI, EBX
  JG   @fim

  // Chamar LogarValor(i)
  MOV  EAX, ESI    // EAX = i (1° param em register)
  CALL LogarValor  // CALL pode destruir EAX, EDX, ECX — mas EBX, ESI são callee-saved

  // ESI e EBX foram preservados pelo LogarValor
  INC  ESI          // i++
  JMP  @loop

@fim:
  POP  ESI
  POP  EBX
end;

begin
  WriteLn('=== CALL a Funções Pascal de dentro do ASM ===');
  WriteLn;

  WriteLn('ProcessarComChamadaPascal(5) = ', ProcessarComChamadaPascal(5)); // 5*2+10 = 20
  WriteLn('ProcessarComChamadaPascal(10) = ', ProcessarComChamadaPascal(10)); // 10*2+10 = 30
  WriteLn;

  WriteLn('DemoSalvarAntesDaCALL:');
  DemoSalvarAntesDaCALL;
  WriteLn;

  WriteLn('LoopComChamadas(3):');
  LoopComChamadas(3);

  ReadLn;
end.
