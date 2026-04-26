unit TEMPLATE_func_simd;
// TEMPLATE: Funcao assembly com instrucoes SIMD (SSE/AVX)
// Substitui: NOME_FUNCAO, operacao SIMD, tipo de dado
// Ver skill `developer-delphi-assembly-simd-avx` para instrucoes completas
{$APPTYPE CONSOLE}
interface

// Prototipo: processar array de floats com SSE (4 por iteracao)
procedure NOME_FUNCAO_SSE(Dest, Src: PSingle; Count: Integer);

// Prototipo: processar array de floats com AVX (8 por iteracao)
procedure NOME_FUNCAO_AVX(Dest, Src: PSingle; Count: Integer);

implementation

procedure NOME_FUNCAO_SSE(Dest, Src: PSingle; Count: Integer);
// Win32: Dest=EAX, Src=EDX, Count=ECX
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    MOV  EDI, EAX      // EDI = Dest
    MOV  ESI, EDX      // ESI = Src
    // Count ja em ECX
    SHR  ECX, 2        // ECX = Count / 4 (blocos SSE de 4 floats)
    TEST ECX, ECX
    JZ   @fim_sse

  @loop_sse:
    MOVUPS XMM0, [ESI]         // carregar 4 floats de Src (nao-alinhado)
    // TODO: operacao SIMD:
    // ADDPS XMM0, [outro]     // somar
    // MULPS XMM0, [fator]     // multiplicar
    // SQRTPS XMM0, XMM0       // raiz quadrada
    NOP                        // substituir por operacao real
    MOVUPS [EDI], XMM0         // gravar 4 floats em Dest
    ADD    ESI, 16             // Src += 4 * 4 bytes
    ADD    EDI, 16             // Dest += 4 * 4 bytes
    DEC    ECX
    JNZ    @loop_sse

  @fim_sse:
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

procedure NOME_FUNCAO_AVX(Dest, Src: PSingle; Count: Integer);
// Versao AVX: 8 floats por iteracao (YMM registers 256-bit)
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    MOV  EDI, EAX
    MOV  ESI, EDX
    SHR  ECX, 3        // ECX = Count / 8 (blocos AVX)
    TEST ECX, ECX
    JZ   @fim_avx

  @loop_avx:
    VMOVUPS YMM0, [ESI]        // carregar 8 floats (nao-alinhado)
    // TODO: operacao AVX (3 operandos - nao-destrutivo):
    // VADDPS YMM0, YMM0, YMM1
    // VMULPS YMM1, YMM0, [fator]
    NOP
    VMOVUPS [EDI], YMM0
    ADD    ESI, 32
    ADD    EDI, 32
    DEC    ECX
    JNZ    @loop_avx

  @fim_avx:
    VZEROUPPER             // limpar bits altos YMM (obrigatorio antes de SSE)
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

end.
