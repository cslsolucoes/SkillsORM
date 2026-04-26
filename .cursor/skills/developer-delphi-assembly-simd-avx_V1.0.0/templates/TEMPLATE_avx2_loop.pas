unit TEMPLATE_avx2_loop;
// TEMPLATE: Loop AVX2 com 8 floats por iteracao + fallback SSE + escalar
// Padrao: processar N floats com dispatch por nivel de suporte
{$APPTYPE CONSOLE}
interface

// Substituir: NOME_FUNCAO, operacao AVX, operacao SSE, operacao escalar
procedure NOME_FUNCAO(Dest, Src: PSingle; Count: Integer);

implementation

procedure NOME_FUNCAO(Dest, Src: PSingle; Count: Integer);
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI

    MOV  EDI, Dest
    MOV  ESI, Src
    MOV  ECX, Count

    // --- Bloco AVX2: 8 floats por iteracao ---
    MOV  EAX, ECX
    SHR  EAX, 3           // EAX = Count / 8
    AND  ECX, 7           // ECX = Count mod 8 (residuo apos AVX)
    TEST EAX, EAX
    JZ   @bloco_sse

  @loop_avx2:
    VMOVUPS YMM0, [ESI]   // carregar 8 floats (nao-alinhado)
    // TODO: operacao AVX2:
    // VMULPS YMM0, YMM0, [constante]
    // VADDPS YMM1, YMM0, YMM2
    NOP
    VMOVUPS [EDI], YMM0   // gravar 8 floats
    ADD    ESI, 32
    ADD    EDI, 32
    DEC    EAX
    JNZ    @loop_avx2
    VZEROUPPER             // OBRIGATORIO antes de SSE/FPU!

    // --- Bloco SSE: 4 floats por iteracao ---
  @bloco_sse:
    MOV  EAX, ECX
    SHR  EAX, 2           // EAX = residuo / 4
    AND  ECX, 3           // ECX = residuo mod 4
    TEST EAX, EAX
    JZ   @bloco_escalar

  @loop_sse:
    MOVUPS XMM0, [ESI]
    // TODO: operacao SSE:
    NOP
    MOVUPS [EDI], XMM0
    ADD    ESI, 16
    ADD    EDI, 16
    DEC    EAX
    JNZ    @loop_sse

    // --- Bloco escalar: 1 float por iteracao ---
  @bloco_escalar:
    TEST ECX, ECX
    JZ   @fim

  @loop_escalar:
    FLD  DWORD PTR [ESI]
    // TODO: operacao escalar:
    NOP
    FSTP DWORD PTR [EDI]
    ADD  ESI, 4
    ADD  EDI, 4
    DEC  ECX
    JNZ  @loop_escalar

  @fim:
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

end.
