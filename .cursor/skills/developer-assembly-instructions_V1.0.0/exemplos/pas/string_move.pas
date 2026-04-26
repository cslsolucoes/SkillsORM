unit string_move;
{
  string_move.pas
  Demonstra MOVS/STOS/LODS com REP para copiar/inicializar arrays Pascal.
  Compilar: dcc32 string_move.pas
}

{$APPTYPE CONSOLE}
program string_move;

// Copia N bytes de Src para Dst usando REP MOVSB
procedure CopiarBytes(Dst, Src: Pointer; N: Integer);
asm
  // EAX = Dst, EDX = Src, ECX = N
  PUSH ESI
  PUSH EDI
  MOV  EDI, EAX   // EDI = destino
  MOV  ESI, EDX   // ESI = fonte
  // ECX já tem N
  CLD              // DF=0: incrementar
  REP  MOVSB       // copia ECX bytes: [ESI] → [EDI], ESI++, EDI++, ECX--
  POP  EDI
  POP  ESI
end;

// Copia N dwords (usa REP MOVSD — mais eficiente que MOVSB para blocos grandes)
procedure CopiarDwords(Dst, Src: PCardinal; N: Integer);
asm
  PUSH ESI
  PUSH EDI
  MOV  EDI, EAX   // EDI = Dst
  MOV  ESI, EDX   // ESI = Src
  CLD
  REP  MOVSD       // copia ECX dwords
  POP  EDI
  POP  ESI
end;

// Inicializa N bytes em Dst com Valor usando REP STOSB
procedure PreencherBytes(Dst: Pointer; Valor: Byte; N: Integer);
asm
  // EAX = Dst, EDX = Valor (byte), ECX = N
  PUSH EDI
  MOV  EDI, EAX
  MOV  AL, DL     // AL = byte de preenchimento
  CLD
  REP  STOSB       // [EDI] = AL; EDI++; ECX--
  POP  EDI
end;

// Inicializa N dwords em Dst com ValorDword usando REP STOSD
procedure PreencherDwords(Dst: PCardinal; ValorDword: Cardinal; N: Integer);
asm
  // EAX = Dst, EDX = ValorDword, ECX = N
  PUSH EDI
  MOV  EDI, EAX
  MOV  EAX, EDX   // EAX = valor (STOSD usa EAX)
  CLD
  REP  STOSD       // [EDI] = EAX; EDI+=4; ECX--
  POP  EDI
end;

// strlen via REPNE SCASB (busca null byte)
function ComprimentoString(S: PAnsiChar): Integer;
asm
  // EAX = S (ponteiro para string)
  PUSH ECX
  PUSH EDI
  MOV  EDI, EAX    // EDI = S
  XOR  AL, AL      // AL = 0 (null byte a buscar)
  MOV  ECX, -1     // contador máximo
  CLD
  REPNE SCASB       // busca null: enquanto AL != [EDI], avança
  NOT  ECX          // ECX = comprimento + 1
  DEC  ECX          // ECX = comprimento (sem null)
  MOV  EAX, ECX
  POP  EDI
  POP  ECX
end;

// Comparação de N bytes via REPE CMPSB
function CompararBytes(A, B: Pointer; N: Integer): Integer;
var
  Diff: Integer;
begin
  Diff := 0;
  asm
    PUSH ESI
    PUSH EDI
    MOV  EDI, A       // EDI = A
    MOV  ESI, B       // ESI = B
    CLD
    REPE CMPSB         // compara enquanto iguais; para quando diferente ou ECX=0
    JE   @iguais       // ZF=1: todos iguais
    MOVZX EAX, byte ptr [EDI-1]   // byte de A
    MOVZX ECX, byte ptr [ESI-1]   // byte de B
    SUB  EAX, ECX
    MOV  Diff, EAX
    JMP  @fim
  @iguais:
    MOV  Diff, 0
  @fim:
    POP  EDI
    POP  ESI
  end;
  Result := Diff;
end;

const
  TAMANHO = 10;

var
  Origem: array[0..TAMANHO-1] of Integer;
  Destino: array[0..TAMANHO-1] of Integer;
  Str1: array[0..19] of AnsiChar;
  Str2: array[0..19] of AnsiChar;
  I: Integer;

begin
  WriteLn('=== MOVS/STOS/SCAS com REP ===');
  WriteLn;

  // Inicializar array de origem
  for I := 0 to TAMANHO - 1 do
    Origem[I] := (I + 1) * 10;

  // Copiar usando CopiarDwords
  CopiarDwords(@Destino[0], @Origem[0], TAMANHO);

  Write('Destino após cópia: ');
  for I := 0 to TAMANHO - 1 do
    Write(Destino[I], ' ');
  WriteLn;

  // Preencher com padrão
  PreencherDwords(@Destino[0], $CAFEBABE, TAMANHO);
  WriteLn('Após preencher com 0xCAFEBABE:');
  Write('  ');
  for I := 0 to TAMANHO - 1 do
    Write('0x', IntToHex(Destino[I], 8), ' ');
  WriteLn;

  // Teste de strlen
  Move('Hello, Assembly!', Str1, 17);
  WriteLn;
  WriteLn('Comprimento de "Hello, Assembly!" = ', ComprimentoString(Str1)); // 16

  // Teste de comparação
  Move('Hello, Assembly!', Str1, 17);
  Move('Hello, Assembly!', Str2, 17);
  WriteLn('Comparação de strings iguais: ', CompararBytes(@Str1, @Str2, 16)); // 0

  Str2[5] := 'X';
  WriteLn('Após modificar Str2[5] para X: ', CompararBytes(@Str1, @Str2, 16)); // não zero

  ReadLn;
end.
