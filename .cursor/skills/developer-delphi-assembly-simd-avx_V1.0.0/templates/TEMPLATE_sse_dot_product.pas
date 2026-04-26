unit TEMPLATE_sse_dot_product;
// TEMPLATE: Produto escalar de dois arrays de Single com SSE
// dot = sum(A[i] * B[i]) para i = 0..Count-1
// Substituir Count minimo, tipo de dado conforme necessidade
{$APPTYPE CONSOLE}
interface

function DotProduct(A, B: PSingle; Count: Integer): Single;

implementation

function DotProduct(A, B: PSingle; Count: Integer): Single;
// Win32: A=EAX, B=EDX, Count=ECX
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI

    MOV  ESI, A         // ESI = A
    MOV  EDI, B         // EDI = B
    MOV  ECX, Count     // ECX = Count

    XORPS XMM7, XMM7    // XMM7 = acumulador = {0,0,0,0}

    MOV  EAX, ECX
    SHR  EAX, 2         // EAX = Count / 4 (blocos SSE)
    AND  ECX, 3         // ECX = Count mod 4

    TEST EAX, EAX
    JZ   @residuo

  @loop_sse:
    MOVUPS XMM0, [ESI]  // 4 floats de A
    MOVUPS XMM1, [EDI]  // 4 floats de B
    MULPS  XMM0, XMM1   // XMM0 = A * B
    ADDPS  XMM7, XMM0   // acumular
    ADD    ESI, 16
    ADD    EDI, 16
    DEC    EAX
    JNZ    @loop_sse

    // Reducao horizontal: somar os 4 elementos de XMM7
    HADDPS XMM7, XMM7   // [a+b, c+d, a+b, c+d]
    HADDPS XMM7, XMM7   // [a+b+c+d, ...]
    MOVSS  [Result], XMM7

    TEST   ECX, ECX
    JZ     @fim

  @residuo:
    // Somar os elementos residuais (1-3) escalarmente:
    FLDZ                    // ST(0) = 0 (acumulador FPU)
  @loop_escalar:
    FLD  DWORD PTR [ESI]
    FMUL DWORD PTR [EDI]
    FADD ST(0), ST(1)       // adicionar ao acumulador
    FXCH                    // trocar ST(0) e ST(1)
    ADD  ESI, 4
    ADD  EDI, 4
    DEC  ECX
    JNZ  @loop_escalar
    FSTP ST(0)              // descartar acumulador antigo
    // ST(0) = resultado do residuo
    // TODO: combinar com o resultado SSE em [Result]

  @fim:
    POP  EDI
    POP  ESI
{$ENDIF WIN32}
  end;
end;

end.
