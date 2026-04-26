unit TEMPLATE_cpuid_check;
{
  TEMPLATE_cpuid_check.pas
  Template para verificação de suporte a AVX2 e AVX-512 via CPUID.

  INSTRUÇÕES DE USO:
  1. Copiar e renomear conforme necessário
  2. Chamar HasAVX2 / HasAVX512 antes de usar instruções AVX2/AVX-512
  3. Implementar caminhos alternativos (SSE2, scalar) quando feature não disponível

  REFERÊNCIA CPUID:
    Leaf 1, ECX bit 28 = AVX
    Leaf 7, ECX=0, EBX bit 5 = AVX2
    Leaf 7, ECX=0, EBX bit 16 = AVX-512F
    Leaf 7, ECX=0, EBX bit 17 = AVX-512DQ
    Leaf 7, ECX=0, EBX bit 30 = AVX-512BW
}

{$APPTYPE CONSOLE}
program TEMPLATE_cpuid_check;

// Executa CPUID e retorna os 4 registradores
procedure ExecCPUID(ALeaf, ASubLeaf: Cardinal;
  out OutEAX, OutEBX, OutECX, OutEDX: Cardinal);
begin
  OutEAX := 0; OutEBX := 0; OutECX := 0; OutEDX := 0;
  asm
    PUSH EBX            // callee-saved em 32-bit!
    MOV  EAX, ALeaf
    MOV  ECX, ASubLeaf
    CPUID
    MOV  OutEAX, EAX
    MOV  OutEBX, EBX
    MOV  OutECX, ECX
    MOV  OutEDX, EDX
    POP  EBX
  end;
end;

// Verifica se o OS habilitou o contexto YMM (necessário para AVX/AVX2)
function OSSupportsAVX: Boolean;
var
  XCR0: Int64;
begin
  // XGETBV ECX=0 → retorna XCR0 em EDX:EAX
  // Bit 1 = SSE state, Bit 2 = AVX/YMM state
  // OS habilita estes bits ao suportar AVX via xsave
  XCR0 := 0;
  asm
    PUSH EBX
    // Primeiro verificar se XSAVE é suportado (CPUID leaf 1, ECX bit 26)
    MOV  EAX, 1
    XOR  ECX, ECX
    CPUID
    TEST ECX, (1 shl 26)   // bit 26 = XSAVE
    JZ   @sem_xsave
    // XGETBV ECX=0
    XOR  ECX, ECX
    DB   $0F, $01, $D0     // XGETBV (instrução raramente suportada por montadores antigos)
    // EDX:EAX = XCR0
    AND  EAX, 0x6          // bits 1 e 2
    CMP  EAX, 0x6          // ambos setados?
    JNE  @sem_xsave
    MOV  EAX, 1
    MOV  dword ptr [XCR0], EAX
    JMP  @fim
  @sem_xsave:
    MOV  dword ptr [XCR0], 0
  @fim:
    POP  EBX
  end;
  Result := XCR0 <> 0;
end;

function HasAVX: Boolean;
var
  EAX, EBX, ECX, EDX: Cardinal;
begin
  ExecCPUID(1, 0, EAX, EBX, ECX, EDX);
  // ECX bit 28 = AVX support no hardware
  Result := ((ECX and (1 shl 28)) <> 0) and OSSupportsAVX;
end;

function HasAVX2: Boolean;
var
  EAX, EBX, ECX, EDX: Cardinal;
begin
  if not HasAVX then
  begin
    Result := False;
    Exit;
  end;
  ExecCPUID(7, 0, EAX, EBX, ECX, EDX);
  // EBX bit 5 = AVX2
  Result := (EBX and (1 shl 5)) <> 0;
end;

function HasAVX512F: Boolean;
var
  EAX, EBX, ECX, EDX: Cardinal;
begin
  if not HasAVX then
  begin
    Result := False;
    Exit;
  end;
  ExecCPUID(7, 0, EAX, EBX, ECX, EDX);
  // EBX bit 16 = AVX-512F (Foundation)
  Result := (EBX and (1 shl 16)) <> 0;
end;

function HasSSE2: Boolean;
var
  EAX, EBX, ECX, EDX: Cardinal;
begin
  ExecCPUID(1, 0, EAX, EBX, ECX, EDX);
  // EDX bit 26 = SSE2 (presente em todos os CPUs x64)
  Result := (EDX and (1 shl 26)) <> 0;
end;

// ---------------------------------------------------------------------------
// Exemplo de uso: despacho de implementação baseado em feature disponível
// ---------------------------------------------------------------------------
procedure ProcessarDados(Dados: PByte; Tamanho: Integer);
begin
  if HasAVX512F then
  begin
    WriteLn('Usando implementacao AVX-512 (512-bit)');
    // Chamar versão AVX-512 aqui
  end
  else if HasAVX2 then
  begin
    WriteLn('Usando implementacao AVX2 (256-bit)');
    // Chamar versão AVX2 aqui
  end
  else if HasSSE2 then
  begin
    WriteLn('Usando implementacao SSE2 (128-bit)');
    // Chamar versão SSE2 aqui
  end
  else
  begin
    WriteLn('Usando implementacao scalar (sem SIMD)');
    // Fallback scalar
  end;
end;

begin
  WriteLn('=== Deteccao de Features CPU ===');
  WriteLn('SSE2:    ', HasSSE2);
  WriteLn('AVX:     ', HasAVX);
  WriteLn('AVX2:    ', HasAVX2);
  WriteLn('AVX-512: ', HasAVX512F);
  WriteLn;
  ProcessarDados(nil, 0);
  ReadLn;
end.
