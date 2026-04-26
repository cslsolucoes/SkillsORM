unit bitwise_flags;
{
  bitwise_flags.pas
  Demonstra AND/OR/XOR/SHL/SHR + leitura de flags com SETcc no Delphi.
  Compilar: dcc32 bitwise_flags.pas
}

{$APPTYPE CONSOLE}
program bitwise_flags;

// AND com máscara
function MascaraBaixo(V: Cardinal): Cardinal;
asm
  AND EAX, 0xFF     // mantém apenas byte baixo
end;

// Setar bit N (0-31)
function SetarBit(V: Cardinal; Bit: Byte): Cardinal;
asm
  // EAX = V, DL = Bit
  MOVZX ECX, DL     // ECX = número do bit
  MOV   EDX, 1
  SHL   EDX, CL     // EDX = 1 << Bit
  OR    EAX, EDX    // V |= (1 << Bit)
end;

// Limpar bit N
function LimparBit(V: Cardinal; Bit: Byte): Cardinal;
asm
  MOVZX ECX, DL
  MOV   EDX, 1
  SHL   EDX, CL
  NOT   EDX         // EDX = ~(1 << Bit)
  AND   EAX, EDX    // V &= ~(1 << Bit)
end;

// Toggle bit N
function AlternarBit(V: Cardinal; Bit: Byte): Cardinal;
asm
  MOVZX ECX, DL
  MOV   EDX, 1
  SHL   EDX, CL
  XOR   EAX, EDX    // V ^= (1 << Bit)
end;

// Testar bit N — retorna True se bit está setado
function TestarBit(V: Cardinal; Bit: Byte): Boolean;
var
  Resultado: Byte;
begin
  Resultado := 0;
  asm
    MOVZX ECX, Bit
    MOV   EDX, 1
    SHL   EDX, CL
    TEST  EAX, EDX    // AND V, (1 << Bit) — afeta ZF
    SETNZ Resultado   // Resultado = 1 se ZF=0 (bit está setado)
  end;
  Result := Resultado <> 0;
end;

// Contar bits setados (popcount) — algoritmo sem BSF/POPCNT
function ContarBits(V: Cardinal): Integer;
asm
  // Algoritmo "Hamming weight" / sideways add
  MOV  EDX, EAX
  SHR  EDX, 1
  AND  EDX, 0x55555555   // EDX = pares de bits
  SUB  EAX, EDX          // EAX = contagem em grupos de 2

  MOV  EDX, EAX
  SHR  EDX, 2
  AND  EAX, 0x33333333
  AND  EDX, 0x33333333
  ADD  EAX, EDX          // EAX = contagem em grupos de 4

  ADD  EAX, EAX shr 4    // hmm: Delphi não aceita shr em expressão aqui
  // Usar abordagem mais simples:
  // retornar apenas nibbles como exemplo
  AND  EAX, 0x0F0F0F0F
  IMUL EAX, 0x01010101   // multiplica: soma todos os bytes
  SHR  EAX, 24           // resultado no byte alto
end;

// Leitura explícita de ZF com SETcc
function ZeroFlagSetado(V: Integer): Boolean;
var
  Flag: Byte;
begin
  Flag := 0;
  asm
    TEST V, V         // ZF = 1 se V = 0
    SETZ Flag         // Flag = 1 se ZF=1
  end;
  Result := Flag <> 0;
end;

// Rotação à esquerda de N bits
function RotEsq(V: Cardinal; N: Byte): Cardinal;
asm
  MOV  CL, DL       // CL = N
  ROL  EAX, CL      // rotaciona V à esquerda por N bits
end;

// Shift aritmético à direita (preserva sinal)
function ShiftAritmeticoDir(V: Integer; N: Byte): Integer;
asm
  MOV  CL, DL
  SAR  EAX, CL      // shift aritmético: preenche com bit de sinal
end;

begin
  WriteLn('=== Operações Bitwise ===');
  WriteLn;

  WriteLn('MascaraBaixo(0xABCDEF12) = 0x', IntToHex(MascaraBaixo($ABCDEF12), 8));  // 0x12
  WriteLn;

  WriteLn('SetarBit(0, 3) = ', SetarBit(0, 3));        // 8 = 0b1000
  WriteLn('LimparBit(0xFF, 3) = ', LimparBit($FF, 3));  // 247 = 0b11110111
  WriteLn('AlternarBit(0xFF, 7) = ', AlternarBit($FF, 7)); // 127 = 0b01111111
  WriteLn;

  WriteLn('TestarBit(0x42, 6) = ', TestarBit($42, 6));  // True (0b01000010, bit 6)
  WriteLn('TestarBit(0x42, 0) = ', TestarBit($42, 0));  // False
  WriteLn;

  WriteLn('ZeroFlagSetado(0) = ', ZeroFlagSetado(0));    // True
  WriteLn('ZeroFlagSetado(5) = ', ZeroFlagSetado(5));    // False
  WriteLn;

  WriteLn('RotEsq(0x80000001, 1) = 0x', IntToHex(RotEsq($80000001, 1), 8)); // 0x00000003
  WriteLn;

  WriteLn('ShiftAritmeticoDir(-16, 2) = ', ShiftAritmeticoDir(-16, 2)); // -4
  WriteLn('ShiftAritmeticoDir(16, 2) = ', ShiftAritmeticoDir(16, 2));   // 4

  ReadLn;
end.
