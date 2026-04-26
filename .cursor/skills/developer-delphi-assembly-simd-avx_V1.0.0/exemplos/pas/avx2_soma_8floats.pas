unit avx2_soma_8floats;
// Soma de arrays de float usando AVX2 (YMM 256-bit) — 8 floats por iteracao
// REQUISITO: CPU com AVX2. Verificar com cpuid_avx_check.pas antes de chamar.
{$APPTYPE CONSOLE}
interface

// Soma elemento-a-elemento: Dest[i] = A[i] + B[i]
procedure SomaArrayAVX2(Dest, A, B: PSingle; Count: Integer);

// Multiplicacao: Dest[i] = A[i] * B[i]
procedure MultiplicaArrayAVX2(Dest, A, B: PSingle; Count: Integer);

// FMA: Dest[i] = A[i] * B[i] + C[i]
procedure FMAArrayAVX2(Dest, A, B, C: PSingle; Count: Integer);

implementation

procedure SomaArrayAVX2(Dest, A, B: PSingle; Count: Integer);
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    PUSH EBX

    MOV  EDI, Dest
    MOV  ESI, A
    MOV  EBX, B
    MOV  ECX, Count

    // Processar 8 floats por vez com AVX (YMM = 256-bit):
    MOV  EAX, ECX
    SHR  EAX, 3          // EAX = Count / 8
    AND  ECX, 7          // ECX = Count mod 8

    TEST EAX, EAX
    JZ   @residuo4

  @loop_avx2:
    VMOVUPS YMM0, [ESI]     // 8 floats de A (nao-alinhado)
    VMOVUPS YMM1, [EBX]     // 8 floats de B
    VADDPS  YMM0, YMM0, YMM1  // YMM0 = A + B (8 somas)
    VMOVUPS [EDI], YMM0
    ADD    ESI, 32
    ADD    EBX, 32
    ADD    EDI, 32
    DEC    EAX
    JNZ    @loop_avx2

    VZEROUPPER              // OBRIGATORIO antes de SSE ou FPU!

  @residuo4:
    // Processar 4 floats com SSE:
    CMP  ECX, 4
    JL   @residuo1
    MOVUPS XMM0, [ESI]
    MOVUPS XMM1, [EBX]
    ADDPS  XMM0, XMM1
    MOVUPS [EDI], XMM0
    ADD    ESI, 16
    ADD    EBX, 16
    ADD    EDI, 16
    SUB    ECX, 4

  @residuo1:
    TEST ECX, ECX
    JZ   @fim
  @loop_escalar:
    FLD  DWORD PTR [ESI]
    FADD DWORD PTR [EBX]
    FSTP DWORD PTR [EDI]
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

procedure MultiplicaArrayAVX2(Dest, A, B: PSingle; Count: Integer);
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    PUSH EBX
    MOV  EDI, Dest
    MOV  ESI, A
    MOV  EBX, B
    MOV  ECX, Count
    MOV  EAX, ECX
    SHR  EAX, 3
    AND  ECX, 7
    TEST EAX, EAX
    JZ   @res_mul
  @loop_mul:
    VMOVUPS YMM0, [ESI]
    VMOVUPS YMM1, [EBX]
    VMULPS  YMM0, YMM0, YMM1   // YMM0 = A * B (8 multiplicacoes)
    VMOVUPS [EDI], YMM0
    ADD ESI, 32
    ADD EBX, 32
    ADD EDI, 32
    DEC EAX
    JNZ @loop_mul
    VZEROUPPER
  @res_mul:
    TEST ECX, ECX
    JZ @fim_mul
  @esc_mul:
    FLD  DWORD PTR [ESI]
    FMUL DWORD PTR [EBX]
    FSTP DWORD PTR [EDI]
    ADD  ESI, 4
    ADD  EBX, 4
    ADD  EDI, 4
    DEC  ECX
    JNZ  @esc_mul
  @fim_mul:
    POP EBX
    POP EDI
    POP ESI
{$ENDIF WIN32}
  end;
end;

procedure FMAArrayAVX2(Dest, A, B, C: PSingle; Count: Integer);
// FMA: Dest = A * B + C usando VFMADD132PS (Fused Multiply-Add)
// Requer FMA3 (Haswell 2013+) — verificar CPUID bit 12 de ECX (leaf 1)
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    PUSH EBX
    MOV  EDI, Dest
    MOV  ESI, A
    MOV  EBX, B
    MOV  ECX, Count
    // C e quinto param (na pilha em convencao register):
    // Acessar via nome C (Delphi resolve)

    MOV  EAX, ECX
    SHR  EAX, 3
    AND  ECX, 7
    TEST EAX, EAX
    JZ   @res_fma
  @loop_fma:
    VMOVUPS YMM0, [ESI]         // YMM0 = A
    VMOVUPS YMM1, [EBX]         // YMM1 = B
    VMOVUPS YMM2, C             // YMM2 = C (Delphi resolve ponteiro C)
    // VFMADD132PS YMM0, YMM1, YMM2 = YMM0 * YMM2 + YMM1
    // (A * C + B — variante 132)
    // Para A*B+C usar VFMADD213PS:
    VFMADD213PS YMM0, YMM1, YMM2  // YMM0 = YMM0 * YMM1 + YMM2 = A*B + C
    VMOVUPS [EDI], YMM0
    ADD ESI, 32
    ADD EBX, 32
    ADD EDI, 32
    DEC EAX
    JNZ @loop_fma
    VZEROUPPER
  @res_fma:
    POP EBX
    POP EDI
    POP ESI
{$ENDIF WIN32}
  end;
end;

end.
