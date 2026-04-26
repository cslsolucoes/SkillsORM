unit TEMPLATE_memset_asm;
{
  TEMPLATE_memset_asm.pas
  Template para inicializar bloco de memória com STOSD/STOSQ.

  INSTRUÇÕES DE USO:
  1. Usar MemSetByte para preenchimento por byte (mais lento mas flexível)
  2. Usar MemSetDword para preenchimento por dword (4x mais rápido)
  3. MemSetQword disponível apenas em 64-bit
  4. MemZero é o caso especial de MemSetByte com Valor=0 (use ZeroMemory do RTL em produção)
}

{$APPTYPE CONSOLE}
program TEMPLATE_memset_asm;

// Preenche N bytes em Dst com Valor (1 byte por iteração)
procedure MemSetByte(Dst: Pointer; Valor: Byte; N: Integer);
// EAX = Dst, DL = Valor (byte), ECX = N
asm
  PUSH  EDI
  MOV   EDI, EAX     // EDI = Dst
  MOV   AL,  DL      // AL = Valor
  CLD
  REP   STOSB         // [EDI] = AL; EDI++; ECX--
  POP   EDI
end;

// Preenche N dwords em Dst com ValorDword (4x mais eficiente que por byte)
// Dst DEVE estar alinhado a 4 bytes para máxima performance
procedure MemSetDword(Dst: PCardinal; ValorDword: Cardinal; N: Integer);
// EAX = Dst, EDX = ValorDword, ECX = N
asm
  PUSH  EDI
  MOV   EDI, EAX     // EDI = Dst
  MOV   EAX, EDX     // EAX = ValorDword (STOSD usa EAX)
  CLD
  REP   STOSD         // [EDI] = EAX; EDI+=4; ECX--
  POP   EDI
end;

// Preenche memória com padrão de 16 bytes (4 dwords iguais)
// Útil para inicializar estruturas de 16-byte
procedure MemSetPattern16(Dst: Pointer; PatternDword: Cardinal; N: Integer);
// N = número de grupos de 4 dwords (N*16 bytes total)
asm
  PUSH  EDI
  PUSH  EBX
  MOV   EDI, EAX          // EDI = Dst
  MOV   EBX, ECX          // EBX = N (loop counter)
  MOV   EAX, EDX          // EAX = pattern

  TEST  EBX, EBX
  JLE   @fim

@loop_16:
  // Escreve 4 dwords por iteração
  MOV   [EDI],    EAX
  MOV   [EDI+4],  EAX
  MOV   [EDI+8],  EAX
  MOV   [EDI+12], EAX
  ADD   EDI, 16
  DEC   EBX
  JNZ   @loop_16

@fim:
  POP   EBX
  POP   EDI
end;

// Zera bloco de memória (equivale a ZeroMemory)
procedure MemZero(Dst: Pointer; N: Integer);
// EAX = Dst, EDX = N
asm
  PUSH  EDI
  MOV   EDI, EAX
  MOV   ECX, EDX
  XOR   EAX, EAX     // AL = 0
  CLD
  REP   STOSB
  POP   EDI
end;

// Versão otimizada de MemZero: zera em dwords (mais rápido para N múltiplo de 4)
procedure MemZeroDword(Dst: Pointer; NDwords: Integer);
asm
  PUSH  EDI
  MOV   EDI, EAX
  MOV   ECX, EDX
  XOR   EAX, EAX     // EAX = 0
  CLD
  REP   STOSD         // zera 4 bytes por vez
  POP   EDI
end;

const
  TAMANHO = 20;

type
  TRegistro = record
    ID: Cardinal;
    Valor: Cardinal;
    Flags: Cardinal;
    Reservado: Cardinal;
  end;

var
  Buffer: array[0..TAMANHO-1] of Byte;
  DwordBuf: array[0..TAMANHO-1] of Cardinal;
  Reg: TRegistro;
  I: Integer;

begin
  WriteLn('=== Template MemSet com STOSD/STOSB ===');
  WriteLn;

  // Preencher com 0xAB
  MemSetByte(@Buffer[0], $AB, TAMANHO);
  Write('MemSetByte(0xAB): ');
  for I := 0 to 9 do Write('0x', IntToHex(Buffer[I], 2), ' ');
  WriteLn('...');

  // Preencher dwords com padrão
  MemSetDword(@DwordBuf[0], $CAFEBABE, TAMANHO);
  Write('MemSetDword(0xCAFEBABE): ');
  for I := 0 to 4 do Write('0x', IntToHex(DwordBuf[I], 8), ' ');
  WriteLn('...');

  // Zerar estrutura
  FillChar(Reg, SizeOf(Reg), $FF);    // primeiro preencher com FF
  WriteLn;
  WriteLn('Antes de MemZero: ID=', Reg.ID);
  MemZeroDword(@Reg, SizeOf(Reg) div 4);
  WriteLn('Após MemZero:     ID=', Reg.ID, ' Valor=', Reg.Valor, ' Flags=', Reg.Flags);

  ReadLn;
end.
