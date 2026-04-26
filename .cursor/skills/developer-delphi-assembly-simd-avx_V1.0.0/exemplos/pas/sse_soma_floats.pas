unit sse_soma_floats;
// Soma de arrays de Single usando SSE2 — built-in assembler Delphi
// 4 floats por iteracao com ADDPS (XMM 128-bit)
{$APPTYPE CONSOLE}
interface

// Soma elemento-a-elemento: Dest[i] = A[i] + B[i]
procedure SomaArraySSE(Dest, A, B: PSingle; Count: Integer);

// Produto escalar: sum(A[i] * B[i])
function DotProductSSE(A, B: PSingle; Count: Integer): Single;

implementation

procedure SomaArraySSE(Dest, A, B: PSingle; Count: Integer);
// Win32: Dest=EAX, A=EDX, Count=ECX; B na pilha como 4o param
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    PUSH EBX

    MOV  EDI, EAX         // EDI = Dest
    MOV  ESI, EDX         // ESI = A
    MOV  EBX, B           // EBX = B (quarto param — Delphi resolve)
    MOV  ECX, Count       // ECX = Count

    // Processar 4 floats por vez:
    MOV  EAX, ECX
    SHR  EAX, 2           // EAX = Count / 4
    AND  ECX, 3           // ECX = Count mod 4

    TEST EAX, EAX
    JZ   @residuo

  @loop_sse:
    MOVUPS XMM0, [ESI]     // 4 floats de A
    MOVUPS XMM1, [EBX]     // 4 floats de B
    ADDPS  XMM0, XMM1      // XMM0 = A + B (4 somas em paralelo)
    MOVUPS [EDI], XMM0     // gravar em Dest
    ADD    ESI, 16
    ADD    EBX, 16
    ADD    EDI, 16
    DEC    EAX
    JNZ    @loop_sse

  @residuo:
    TEST ECX, ECX
    JZ   @fim
  @loop_escalar:
    FLD  DWORD PTR [ESI]   // ST(0) = *A
    FADD DWORD PTR [EBX]   // ST(0) += *B
    FSTP DWORD PTR [EDI]   // *Dest = ST(0)
    ADD  ESI, 4
    ADD  EBX, 4
    ADD  EDI, 4
    DEC  ECX
    JNZ  @loop_escalar

  @fim:
    POP  EBX
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

function DotProductSSE(A, B: PSingle; Count: Integer): Single;
// Produto escalar: resultado = sum(A[i] * B[i])
// Retorno: Single — em Win32 via ST(0) (FPU), em Win64 via XMM0
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI

    MOV  ESI, A
    MOV  EDI, B
    MOV  ECX, Count

    // XMM7 = acumulador (zero)
    XORPS XMM7, XMM7

    MOV  EAX, ECX
    SHR  EAX, 2
    AND  ECX, 3

    TEST EAX, EAX
    JZ   @residuo_dot

  @loop_dot:
    MOVUPS XMM0, [ESI]     // 4 floats de A
    MOVUPS XMM1, [EDI]     // 4 floats de B
    MULPS  XMM0, XMM1      // XMM0 = A * B (4 multiplicacoes)
    ADDPS  XMM7, XMM0      // acumular no XMM7
    ADD    ESI, 16
    ADD    EDI, 16
    DEC    EAX
    JNZ    @loop_dot

    // Reduzir XMM7 (4 floats) para escalar:
    // XMM7 = [a, b, c, d] -> precisa de a+b+c+d
    HADDPS XMM7, XMM7      // [a+b, c+d, a+b, c+d]
    HADDPS XMM7, XMM7      // [a+b+c+d, ...]
    MOVSS  [Result], XMM7  // gravar resultado (Single)
    JMP    @fim_dot

  @residuo_dot:
    TEST ECX, ECX
    JZ   @fim_dot
  @loop_escalar_dot:
    FLD  DWORD PTR [ESI]
    FMUL DWORD PTR [EDI]
    // Adicionar ao resultado
    ADD  ESI, 4
    ADD  EDI, 4
    DEC  ECX
    JNZ  @loop_escalar_dot

  @fim_dot:
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

end.
