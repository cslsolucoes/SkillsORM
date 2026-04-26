unit preservar_obrigatorios;
{
  preservar_obrigatorios.pas
  Demonstra como salvar e restaurar corretamente EDI, ESI, EBX em 32-bit.
  Estes registradores são callee-saved: toda função que os usa DEVE preservá-los.

  Compilar: dcc32 preservar_obrigatorios.pas
}

{$APPTYPE CONSOLE}
program preservar_obrigatorios;

// ---------------------------------------------------------------------------
// ERRADO: usa EDI/ESI/EBX sem preservar — pode corromper dados do chamador
// (Descomentado apenas para ilustração — NÃO usar em produção)
// ---------------------------------------------------------------------------
{
function SomaErrada(P1, P2: Integer): Integer;
asm
  MOV EBX, P1    // EBX modificado sem PUSH/POP — PROBLEMA!
  MOV ESI, P2
  ADD EBX, ESI
  MOV EAX, EBX
  // EBX e ESI foram destruídos — violação da ABI!
end;
}

// ---------------------------------------------------------------------------
// CORRETO: salvar e restaurar EDI, ESI, EBX com PUSH/POP
// ---------------------------------------------------------------------------
function SomaArrayComPreservacao(Arr: PInteger; N: Integer): Integer;
// Soma N inteiros a partir de Arr
// Usa EDI (ponteiro) e EBX (contador) — ambos devem ser preservados
// EAX = Arr (ponteiro), EDX = N
asm
  // === SALVAR registradores não-voláteis que vamos usar ===
  PUSH EBX              // salva EBX (vamos usar como acumulador)
  PUSH EDI              // salva EDI (vamos usar como ponteiro de loop)
  PUSH ESI              // salva ESI (vamos usar como contador)

  // === Implementação ===
  MOV  EDI, EAX         // EDI = Arr (ponteiro para o início)
  MOV  ESI, EDX         // ESI = N (contador)
  XOR  EBX, EBX         // EBX = 0 (acumulador — xor é mais rápido que mov eax,0)

  TEST ESI, ESI         // N == 0?
  JZ   @fim             // se sim, pula

@loop:
  ADD  EBX, [EDI]       // EBX += *EDI (somar elemento atual)
  ADD  EDI, 4           // avança ponteiro (Integer = 4 bytes)
  DEC  ESI              // decrementa contador
  JNZ  @loop            // continua se ESI != 0

@fim:
  MOV  EAX, EBX         // retornar o acumulador em EAX

  // === RESTAURAR na ordem INVERSA (LIFO — Last In First Out) ===
  POP  ESI              // restaura ESI
  POP  EDI              // restaura EDI
  POP  EBX              // restaura EBX
end;

// ---------------------------------------------------------------------------
// Demonstra que os registradores NÃO foram corrompidos pelo asm
// ---------------------------------------------------------------------------
procedure TestIntegridade;
var
  Arr: array[0..4] of Integer;
  Soma: Integer;
  TestEBX: Integer;
begin
  Arr[0] := 10; Arr[1] := 20; Arr[2] := 30; Arr[3] := 40; Arr[4] := 50;

  // Colocar valor específico em EBX antes de chamar a função
  TestEBX := 0;
  asm
    MOV EBX, 0xCAFEBABE  // valor teste em EBX
  end;

  // Chamar função que usa EBX internamente mas o preserva
  Soma := SomaArrayComPreservacao(@Arr[0], 5);

  // Verificar que EBX foi preservado
  asm
    MOV TestEBX, EBX     // EBX deve ainda ser 0xCAFEBABE
    // Limpar para não vazar para fora
    XOR EBX, EBX
  end;

  WriteLn('Soma do array: ', Soma);
  WriteLn('EBX preservado? ', TestEBX = Integer($CAFEBABE));
end;

// ---------------------------------------------------------------------------
// Função com uso pesado de registradores preservados
// Conta zeros em um array
// ---------------------------------------------------------------------------
function ContarZeros(Arr: PInteger; N: Integer): Integer;
// EAX = Arr, EDX = N
asm
  PUSH EBX              // contador de zeros
  PUSH ESI              // contador de loop
  PUSH EDI              // ponteiro ao array

  MOV  EDI, EAX         // EDI = Arr
  MOV  ESI, EDX         // ESI = N
  XOR  EBX, EBX         // EBX = 0 (contagem de zeros)

  TEST ESI, ESI
  JZ   @feito

@verifica:
  CMP  dword ptr [EDI], 0   // arr[i] == 0?
  JNZ  @proximo
  INC  EBX              // sim: incrementa contador

@proximo:
  ADD  EDI, 4           // ponteiro += sizeof(Integer)
  DEC  ESI
  JNZ  @verifica

@feito:
  MOV  EAX, EBX         // resultado em EAX

  POP  EDI
  POP  ESI
  POP  EBX
end;

var
  TestArr: array[0..7] of Integer;
  I: Integer;

begin
  WriteLn('=== Preservação de Registradores 32-bit ===');
  WriteLn;

  // Teste de integridade
  TestIntegridade;
  WriteLn;

  // Teste com array de zeros e não-zeros
  for I := 0 to 7 do
    TestArr[I] := I mod 3;   // 0, 1, 2, 0, 1, 2, 0, 1

  WriteLn('Array: ', TestArr[0], ' ', TestArr[1], ' ', TestArr[2], ' ', TestArr[3],
          ' ', TestArr[4], ' ', TestArr[5], ' ', TestArr[6], ' ', TestArr[7]);
  WriteLn('Zeros: ', ContarZeros(@TestArr[0], 8));  // deve ser 3 (índices 0, 3, 6)

  ReadLn;
end.
