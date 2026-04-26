unit inline_small_large;
// FastMove com SSE2 — bloco asm dentro de funcao Pascal
// Demonstra MOVDQU (move 16 bytes nao-alinhados) para copia rapida
// Valido: Win32 e Win64 com suporte SSE2 (Pentium 4+)
{$APPTYPE CONSOLE}
interface

// Copia rapida de bloco de memoria usando SSE2 (MOVDQU = 16 bytes por iteracao)
procedure FastMove(Dest, Src: Pointer; Count: NativeUInt);

// Versao simples sem SSE para comparacao
procedure SlowMove(Dest, Src: Pointer; Count: NativeUInt);

implementation

procedure SlowMove(Dest, Src: Pointer; Count: NativeUInt);
// Referencia: copia byte a byte
begin
  asm
{$IFDEF WIN32}
    // Dest=EAX, Src=EDX, Count=ECX
    PUSH ESI
    PUSH EDI
    MOV  EDI, EAX     // EDI = Dest
    MOV  ESI, EDX     // ESI = Src
    // Count ja em ECX
    REP MOVSB          // copia ECX bytes de [ESI] para [EDI]
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
{$IFDEF WIN64}
    // Dest=RCX, Src=RDX, Count=R8
    // REP MOVSB em x64: RDI=dest, RSI=src, RCX=count
    PUSH RSI
    PUSH RDI
    MOV  RDI, RCX     // RDI = Dest
    MOV  RSI, RDX     // RSI = Src
    MOV  RCX, R8      // RCX = Count
    REP  MOVSB
    POP  RDI
    POP  RSI
{$ENDIF WIN64}
  end;
end;

procedure FastMove(Dest, Src: Pointer; Count: NativeUInt);
// SSE2: MOVDQU copia 16 bytes por iteracao (sem requisito de alinhamento)
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    MOV  EDI, EAX      // EDI = Dest
    MOV  ESI, EDX      // ESI = Src
    MOV  ECX, Count    // ECX = Count (nao e terceiro arg em register)
    // Blocos de 16 bytes com SSE2:
    MOV  EAX, ECX
    SHR  EAX, 4        // EAX = Count / 16 (numero de blocos SSE)
    AND  ECX, 15       // ECX = Count mod 16 (bytes restantes)
    TEST EAX, EAX
    JZ   @bytes_finais
  @loop_sse:
    MOVDQU XMM0, [ESI]   // carregar 16 bytes da fonte
    MOVDQU [EDI], XMM0   // gravar 16 bytes no destino
    ADD    ESI, 16
    ADD    EDI, 16
    DEC    EAX
    JNZ    @loop_sse
  @bytes_finais:
    REP MOVSB            // copiar bytes restantes (0-15)
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
{$IFDEF WIN64}
    // Win64: Dest=RCX, Src=RDX, Count=R8
    PUSH RSI
    PUSH RDI
    MOV  RDI, RCX
    MOV  RSI, RDX
    MOV  RCX, R8
    MOV  RAX, RCX
    SHR  RAX, 4
    AND  RCX, 15
    TEST RAX, RAX
    JZ   @bytes_finais64
  @loop_sse64:
    MOVDQU XMM0, [RSI]
    MOVDQU [RDI], XMM0
    ADD    RSI, 16
    ADD    RDI, 16
    DEC    RAX
    JNZ    @loop_sse64
  @bytes_finais64:
    REP  MOVSB
    POP  RDI
    POP  RSI
{$ENDIF WIN64}
  end;
end;

end.
