unit TEMPLATE_loop_array;
{
  TEMPLATE_loop_array.pas
  Template: loop com ponteiro em EDI/RDI sobre array Pascal.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Ajustar tipo do array (Integer, Cardinal, Int64...)
  3. Substituir a lógica do loop pela operação desejada
  4. Manter os PUSH/POP dos registradores preservados
}

{$APPTYPE CONSOLE}
program TEMPLATE_loop_array;

// Operação sobre array 32-bit com ponteiro ESI (loop com CMP+JNZ)
function ProcessarArray32(Arr: PInteger; N: Integer): Integer;
// EAX = Arr, EDX = N
// Retorno: EAX = resultado da operação
asm
  // SALVAR registradores preservados que serão usados
  PUSH ESI            // ESI = ponteiro atual ao array
  PUSH EDI            // EDI = ponteiro fim do array
  PUSH EBX            // EBX = acumulador/resultado

  // INICIALIZAR
  MOV  ESI, EAX       // ESI = &Arr[0]
  LEA  EDI, [EAX + EDX*4]   // EDI = &Arr[N] (one past end)
  XOR  EBX, EBX       // EBX = 0 (acumulador)

  // VERIFICAR array vazio
  CMP  ESI, EDI
  JGE  @fim

  // LOOP COM PONTEIRO (evita escala na instrução — mais direto)
@loop:
  // === OPERAÇÃO SOBRE CADA ELEMENTO ===
  // Substituir esta seção pela lógica desejada:
  MOV  EAX, [ESI]     // EAX = *ptr (elemento atual)
  ADD  EBX, EAX       // EBX += elemento (exemplo: soma)
  // === FIM DA OPERAÇÃO ===

  ADD  ESI, 4         // ptr++ (4 bytes por Integer)
  CMP  ESI, EDI       // chegou no fim?
  JL   @loop          // não: continua

@fim:
  MOV  EAX, EBX       // retorno em EAX

  // RESTAURAR na ordem inversa
  POP  EBX
  POP  EDI
  POP  ESI
end;

// Versão 64-bit com RSI/RDI (comentar/descomentar conforme plataforma)
{$IFDEF CPUX64}
function ProcessarArray64(Arr: PInteger; N: Int64): Int64;
// RCX = Arr, RDX = N
asm
  .PUSHNV RBX
  .PUSHNV RSI
  .PUSHNV RDI

  MOV     RSI, RCX           // RSI = &Arr[0]
  LEA     RDI, [RCX + RDX*4] // RDI = &Arr[N]
  XOR     RBX, RBX            // RBX = acumulador

  CMP     RSI, RDI
  JGE     @fim64

@loop64:
  MOVSXD  RAX, dword ptr [RSI]  // RAX = *ptr (sign-extend)
  ADD     RBX, RAX
  ADD     RSI, 4
  CMP     RSI, RDI
  JL      @loop64

@fim64:
  MOV     RAX, RBX
end;
{$ENDIF}

const
  N = 5;

var
  Arr: array[0..N-1] of Integer;
  I: Integer;

begin
  for I := 0 to N-1 do
    Arr[I] := (I + 1) * 10;   // 10, 20, 30, 40, 50

  Write('Array: ');
  for I := 0 to N-1 do Write(Arr[I], ' ');
  WriteLn;

  WriteLn('Soma (32-bit) = ', ProcessarArray32(@Arr[0], N));   // 150

  {$IFDEF CPUX64}
  WriteLn('Soma (64-bit) = ', ProcessarArray64(@Arr[0], N));
  {$ENDIF}

  ReadLn;
end.
