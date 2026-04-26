unit cpuid_avx_check;
// Verificacao de suporte a extensoes SIMD em runtime via CPUID
// Usar ANTES de chamar qualquer codigo SSE/AVX/AVX-512
{$APPTYPE CONSOLE}
interface

type
  TSIMDSupport = record
    SSE2:    Boolean;   // Pentium 4+ (2001)
    SSE3:    Boolean;   // Prescott (2004)
    SSSE3:   Boolean;   // Core 2 (2007)
    SSE41:   Boolean;   // Penryn (2008)
    SSE42:   Boolean;   // Nehalem (2008)
    AVX:     Boolean;   // Sandy Bridge (2011)
    AVX2:    Boolean;   // Haswell (2013)
    FMA:     Boolean;   // Haswell (2013) — Fused Multiply-Add
    AVX512F: Boolean;   // Skylake-X (2017) — Foundation
    POPCNT:  Boolean;
    BMI1:    Boolean;
    BMI2:    Boolean;
  end;

function VerificarSIMD: TSIMDSupport;
function SuportaSSE2: Boolean; assembler;
function SuportaAVX2: Boolean; assembler;

implementation

function SuportaSSE2: Boolean; assembler;
asm
{$IFDEF WIN32}
  PUSH EBX
  MOV  EAX, 1
  CPUID              // EDX bit 26 = SSE2
  BT   EDX, 26      // CF = bit 26 de EDX
  SETC AL            // AL = 1 se CF=1 (SSE2 disponivel)
  POP  EBX
{$ENDIF WIN32}
{$IFDEF WIN64}
  PUSH RBX
  MOV  EAX, 1
  CPUID
  BT   EDX, 26
  SETC AL
  POP  RBX
{$ENDIF WIN64}
end;

function SuportaAVX2: Boolean; assembler;
asm
{$IFDEF WIN32}
  PUSH EBX
  MOV  EAX, 7        // leaf 7 = extended feature flags
  XOR  ECX, ECX      // sub-leaf 0
  CPUID              // EBX bit 5 = AVX2
  BT   EBX, 5
  SETC AL
  POP  EBX
{$ENDIF WIN32}
{$IFDEF WIN64}
  PUSH RBX
  MOV  EAX, 7
  XOR  ECX, ECX
  CPUID
  BT   EBX, 5
  SETC AL
  POP  RBX
{$ENDIF WIN64}
end;

function VerificarSIMD: TSIMDSupport;
// Consulta CPUID leaves 1 e 7 para preencher o record
var
  EAX_, EBX_, ECX_, EDX_: Cardinal;
begin
  FillChar(Result, SizeOf(Result), 0);

  // CPUID leaf 1: features basicas
  asm
{$IFDEF WIN32}
    PUSH EBX
    MOV  EAX, 1
    CPUID
    MOV  EAX_, EAX
    MOV  EBX_, EBX
    MOV  ECX_, ECX
    MOV  EDX_, EDX
    POP  EBX
{$ENDIF WIN32}
{$IFDEF WIN64}
    PUSH RBX
    MOV  EAX, 1
    CPUID
    MOV  EAX_, EAX
    MOV  EBX_, EBX
    MOV  ECX_, ECX
    MOV  EDX_, EDX
    POP  RBX
{$ENDIF WIN64}
  end;

  Result.SSE2   := (EDX_ shr 26) and 1 = 1;   // EDX bit 26
  Result.SSE3   := (ECX_) and 1 = 1;           // ECX bit 0
  Result.SSSE3  := (ECX_ shr 9) and 1 = 1;    // ECX bit 9
  Result.SSE41  := (ECX_ shr 19) and 1 = 1;   // ECX bit 19
  Result.SSE42  := (ECX_ shr 20) and 1 = 1;   // ECX bit 20
  Result.AVX    := (ECX_ shr 28) and 1 = 1;   // ECX bit 28
  Result.FMA    := (ECX_ shr 12) and 1 = 1;   // ECX bit 12
  Result.POPCNT := (ECX_ shr 23) and 1 = 1;   // ECX bit 23

  // CPUID leaf 7: extended features (AVX2, AVX-512, BMI)
  asm
{$IFDEF WIN32}
    PUSH EBX
    MOV  EAX, 7
    XOR  ECX, ECX
    CPUID
    MOV  EBX_, EBX
    MOV  ECX_, ECX
    POP  EBX
{$ENDIF WIN32}
{$IFDEF WIN64}
    PUSH RBX
    MOV  EAX, 7
    XOR  ECX, ECX
    CPUID
    MOV  EBX_, EBX
    MOV  ECX_, ECX
    POP  RBX
{$ENDIF WIN64}
  end;

  Result.AVX2    := (EBX_ shr 5) and 1 = 1;   // EBX bit 5
  Result.AVX512F := (EBX_ shr 16) and 1 = 1;  // EBX bit 16
  Result.BMI1    := (EBX_ shr 3) and 1 = 1;   // EBX bit 3
  Result.BMI2    := (EBX_ shr 8) and 1 = 1;   // EBX bit 8
end;

end.
