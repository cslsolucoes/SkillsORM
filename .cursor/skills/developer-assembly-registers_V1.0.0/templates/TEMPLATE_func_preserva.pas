unit TEMPLATE_func_preserva;
{
  TEMPLATE_func_preserva.pas
  Template de função que usa EDI/ESI/EBX com PUSH/POP correto.
  Padrão seguro para qualquer função que precisa de múltiplos registradores temporários.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear
  2. Adicionar a lógica entre os blocos PUSH e POP
  3. Certificar que toda saída (JMP/@label) só ocorre APÓS os POPs

  NOTA: Versão para Win32 (dcc32). Para Win64 usar .PUSHNV no lugar de PUSH/POP.
}

{$APPTYPE CONSOLE}
program TEMPLATE_func_preserva;

// ---------------------------------------------------------------------------
// Função que usa EBX, ESI, EDI com preservação completa
// Implementa busca linear em array retornando índice do primeiro valor >= Alvo
// ---------------------------------------------------------------------------
function BuscaLinear(Arr: PInteger; N, Alvo: Integer): Integer;
// Entrada (convenção register):
//   EAX = Arr (ponteiro para início do array)
//   EDX = N   (número de elementos)
//   ECX = Alvo (valor a buscar)
// Saída:
//   EAX = índice do primeiro elemento >= Alvo, ou -1 se não encontrado
asm
  // =========================================================================
  // SALVAR registradores não-voláteis que vamos usar
  // Ordem: PUSH em sequência; POP na ordem INVERSA
  // =========================================================================
  PUSH EBX              // EBX = índice atual
  PUSH ESI              // ESI = Arr (ponteiro de base)
  PUSH EDI              // EDI = Alvo

  // =========================================================================
  // Inicialização
  // =========================================================================
  MOV  ESI, EAX         // ESI = Arr
  MOV  EDI, ECX         // EDI = Alvo
  XOR  EBX, EBX         // EBX = 0 (índice = 0)

  // Verificar N > 0
  TEST EDX, EDX
  JLE  @nao_encontrado   // N <= 0: retorna -1

@loop:
  CMP  EBX, EDX         // índice >= N?
  JGE  @nao_encontrado  // sim: não encontrou

  MOV  EAX, [ESI + EBX*4]  // EAX = Arr[índice]
  CMP  EAX, EDI             // Arr[índice] >= Alvo?
  JGE  @encontrado          // sim: retorna índice

  INC  EBX               // índice++
  JMP  @loop

@encontrado:
  MOV  EAX, EBX          // EAX = índice encontrado
  JMP  @fim

@nao_encontrado:
  MOV  EAX, -1           // EAX = -1 (não encontrado)

@fim:
  // =========================================================================
  // RESTAURAR na ordem INVERSA (LIFO)
  // TODOS os caminhos de saída devem passar por aqui!
  // =========================================================================
  POP  EDI
  POP  ESI
  POP  EBX
  // RET gerado automaticamente pelo Delphi
end;

// ---------------------------------------------------------------------------
// Versão com 64-bit usando .PUSHNV (mais idiomático no Delphi 64-bit)
// ---------------------------------------------------------------------------
{$IFDEF CPUX64}
function BuscaLinear64(Arr: PInteger; N, Alvo: Integer): Integer;
// RCX = Arr, RDX = N, R8 = Alvo
asm
  .PUSHNV RBX            // preservar RBX com unwind info
  .PUSHNV RSI
  .PUSHNV RDI

  MOV  RSI, RCX          // RSI = Arr
  MOVSXD RDI, R8D        // RDI = Alvo (sign-extend para 64-bit)
  XOR  RBX, RBX          // RBX = 0 (índice)

  TEST EDX, EDX
  JLE  @nao_encontrado64

@loop64:
  CMP  RBX, RDX          // índice >= N?
  JGE  @nao_encontrado64

  MOV  EAX, [RSI + RBX*4]
  MOVSXD RAX, EAX        // sign-extend para comparação correta
  CMP  RAX, RDI          // Arr[índice] >= Alvo?
  JGE  @encontrado64

  INC  RBX
  JMP  @loop64

@encontrado64:
  MOV  EAX, EBX          // retorno em EAX (inteiro 32-bit)
  JMP  @fim64

@nao_encontrado64:
  MOV  EAX, -1

@fim64:
  // .PUSHNV gera POP automático no epilogue
end;
{$ENDIF}

const
  TAM = 8;

var
  Arr: array[0..TAM-1] of Integer;
  I: Integer;

begin
  // Inicializar array: 5, 10, 15, 20, 25, 30, 35, 40
  for I := 0 to TAM - 1 do
    Arr[I] := (I + 1) * 5;

  WriteLn('=== Template Funcao com Preservacao ===');
  Write('Array: ');
  for I := 0 to TAM - 1 do Write(Arr[I], ' ');
  WriteLn;
  WriteLn;

  WriteLn('BuscaLinear(Alvo=22): índice ', BuscaLinear(@Arr[0], TAM, 22));  // 4 (Arr[4]=25 >= 22)
  WriteLn('BuscaLinear(Alvo=5):  índice ', BuscaLinear(@Arr[0], TAM, 5));   // 0
  WriteLn('BuscaLinear(Alvo=40): índice ', BuscaLinear(@Arr[0], TAM, 40));  // 7
  WriteLn('BuscaLinear(Alvo=41): índice ', BuscaLinear(@Arr[0], TAM, 41));  // -1

  {$IFDEF CPUX64}
  WriteLn;
  WriteLn('BuscaLinear64(Alvo=22): índice ', BuscaLinear64(@Arr[0], TAM, 22));
  {$ENDIF}

  ReadLn;
end.
