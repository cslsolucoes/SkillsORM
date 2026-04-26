unit frame_32bit;
{
  frame_32bit.pas
  Função ASM pura 32-bit com prologue/epilogue manual.
  Demonstra stack frame, variáveis locais e acesso a parâmetros via pilha.
  Compilar: dcc32 frame_32bit.pas
}

{$APPTYPE CONSOLE}
program frame_32bit;

// ---------------------------------------------------------------------------
// Função com prologue/epilogue explícito e variáveis locais
// Parâmetros passados via stack (convenção stdcall ou pascal):
// ---------------------------------------------------------------------------
// NOTA: Em Delphi, funções com convenção "register" (padrão) recebem
// os primeiros 3 parâmetros em EAX, EDX, ECX.
// Para demonstrar acesso via pilha, usamos "stdcall" que passa tudo na stack.
// ---------------------------------------------------------------------------

function SomaComFrame(A, B, C: Integer): Integer; stdcall;
// Parâmetros na stack (stdcall): [EBP+8]=A, [EBP+12]=B, [EBP+16]=C
// O Delphi gera o frame automaticamente, mas demonstramos aqui como seria manualmente
var
  LocalX, LocalY: Integer;
begin
  LocalX := 0;
  LocalY := 0;
  asm
    // Neste ponto, o Delphi já gerou o prologue:
    //   PUSH EBP
    //   MOV EBP, ESP
    //   SUB ESP, N  (N = espaço para variáveis locais)
    //
    // Layout do frame neste momento:
    //   [EBP+16] = C (3° param stdcall)
    //   [EBP+12] = B (2° param stdcall)
    //   [EBP+8]  = A (1° param stdcall)
    //   [EBP+4]  = return address (CALL empilhou)
    //   [EBP+0]  = saved EBP ← EBP aponta aqui
    //   [EBP-4]  = LocalX
    //   [EBP-8]  = LocalY

    // Acessar parâmetros via nome (Delphi resolve o offset)
    MOV  EAX, A         // EAX = A
    MOV  ECX, B         // ECX = B
    ADD  EAX, ECX       // EAX = A + B
    MOV  LocalX, EAX   // salva em variável local

    MOV  EAX, C
    MOV  LocalY, EAX   // LocalY = C

    MOV  EAX, LocalX
    ADD  EAX, LocalY   // EAX = A + B + C

    // Sem RET manual — o Delphi gera o epilogue:
    //   MOV ESP, EBP
    //   POP EBP
    //   RET 12   (stdcall: callee limpa os 3 params = 12 bytes)
  end;
  Result := LocalX + LocalY;  // não usado diretamente — o asm já colocou em EAX
end;

// ---------------------------------------------------------------------------
// Demonstra acesso explícito à pilha sem usar nomes de variáveis
// (uso didático — normalmente usar nomes Pascal)
// ---------------------------------------------------------------------------
function SomaDireta(A, B: Integer): Integer;
// Em convenção register: EAX=A, EDX=B
asm
  // Prologue manual para demonstração
  PUSH EBP
  MOV  EBP, ESP
  SUB  ESP, 8          // 2 variáveis locais de 4 bytes cada

  // Salvar parâmetros nas variáveis locais
  MOV  [EBP-4], EAX   // local_a = A
  MOV  [EBP-8], EDX   // local_b = B

  // Computar
  MOV  EAX, [EBP-4]
  ADD  EAX, [EBP-8]

  // Epilogue manual
  MOV  ESP, EBP
  POP  EBP
  // Sem RET — Delphi gera o RET
end;

// ---------------------------------------------------------------------------
// Função que usa registradores callee-saved (com PUSH/POP correto)
// ---------------------------------------------------------------------------
function MultiplicarSomar(A, B, C: Integer): Integer;
// EAX=A, EDX=B, ECX=C
// Retorno: EAX = A*B + C
asm
  PUSH EBX          // EBX é callee-saved!
  PUSH ESI

  MOV  EBX, EAX    // EBX = A
  MOV  ESI, ECX    // ESI = C
  IMUL EBX, EDX    // EBX = A * B
  ADD  EBX, ESI    // EBX = A*B + C
  MOV  EAX, EBX   // retorno em EAX

  POP  ESI
  POP  EBX
end;

begin
  WriteLn('=== Stack Frame 32-bit ===');
  WriteLn;

  WriteLn('SomaComFrame(10, 20, 30) = ', SomaComFrame(10, 20, 30));   // 60
  WriteLn('SomaDireta(100, 200) = ', SomaDireta(100, 200));            // 300
  WriteLn('MultiplicarSomar(3, 4, 5) = ', MultiplicarSomar(3, 4, 5)); // 3*4+5 = 17

  ReadLn;
end.
