unit cpuid_info;
{
  cpuid_info.pas
  Usa CPUID para obter informações do processador:
  - Vendor string (AuthenticAMD / GenuineIntel)
  - Família, modelo, stepping
  - Feature flags: SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2, AVX, AVX2, AES-NI

  Referência de funções CPUID:
    EAX=0: vendor string e max leaf
    EAX=1: feature flags (ECX e EDX)
    EAX=7, ECX=0: extended features (EBX, ECX, EDX)

  Compilar: dcc32 cpuid_info.pas
}

{$APPTYPE CONSOLE}

program cpuid_info;

type
  TCPUIDResult = record
    EAX, EBX, ECX, EDX: Cardinal;
  end;

// Executa CPUID com a função especificada em AFunc (EAX) e subfunção ASubFunc (ECX)
function CPUID(AFunc, ASubFunc: Cardinal): TCPUIDResult;
begin
  FillChar(Result, SizeOf(Result), 0);
  asm
    // Salvar EBX — callee-saved em 32-bit!
    PUSH EBX

    MOV EAX, AFunc
    MOV ECX, ASubFunc
    CPUID                   // destrói EAX, EBX, ECX, EDX

    MOV Result.EAX, EAX
    MOV Result.EBX, EBX
    MOV Result.ECX, ECX
    MOV Result.EDX, EDX

    POP EBX
  end;
end;

// Extrai vendor string de CPUID leaf 0
function GetVendorString: string;
var
  R: TCPUIDResult;
  Vendor: array[0..12] of Char;
begin
  R := CPUID(0, 0);
  // Vendor: EBX || EDX || ECX (em bytes)
  Move(R.EBX, Vendor[0], 4);
  Move(R.EDX, Vendor[4], 4);
  Move(R.ECX, Vendor[8], 4);
  Vendor[12] := #0;
  Result := string(Vendor);
end;

// Verifica flags de feature (CPUID leaf 1)
procedure MostrarFeatures;
var
  R: TCPUIDResult;
  Familia, Modelo, Stepping: Integer;
begin
  R := CPUID(1, 0);

  // Decodificar família/modelo/stepping de EAX
  Stepping := R.EAX and $0F;
  Modelo   := (R.EAX shr 4) and $0F;
  Familia  := (R.EAX shr 8) and $0F;
  if Familia = $0F then
    Familia := Familia + ((R.EAX shr 20) and $FF);
  if (Familia = $06) or (Familia = $0F) then
    Modelo := Modelo + (((R.EAX shr 16) and $0F) shl 4);

  WriteLn(Format('  Familia: %d  Modelo: %d  Stepping: %d', [Familia, Modelo, Stepping]));
  WriteLn;

  // Feature flags em EDX (clássico)
  WriteLn('=== Features EDX (classico) ===');
  WriteLn('  FPU (x87):    ', (R.EDX and (1 shl 0))  <> 0);
  WriteLn('  CMOV:         ', (R.EDX and (1 shl 15)) <> 0);
  WriteLn('  MMX:          ', (R.EDX and (1 shl 23)) <> 0);
  WriteLn('  SSE:          ', (R.EDX and (1 shl 25)) <> 0);
  WriteLn('  SSE2:         ', (R.EDX and (1 shl 26)) <> 0);

  // Feature flags em ECX (extendido)
  WriteLn('=== Features ECX (extendido) ===');
  WriteLn('  SSE3:         ', (R.ECX and (1 shl 0))  <> 0);
  WriteLn('  SSSE3:        ', (R.ECX and (1 shl 9))  <> 0);
  WriteLn('  SSE4.1:       ', (R.ECX and (1 shl 19)) <> 0);
  WriteLn('  SSE4.2:       ', (R.ECX and (1 shl 20)) <> 0);
  WriteLn('  AES-NI:       ', (R.ECX and (1 shl 25)) <> 0);
  WriteLn('  AVX:          ', (R.ECX and (1 shl 28)) <> 0);
  WriteLn('  F16C:         ', (R.ECX and (1 shl 29)) <> 0);
  WriteLn('  RDRAND:       ', (R.ECX and (1 shl 30)) <> 0);

  // Extended features (leaf 7, subleaf 0)
  R := CPUID(7, 0);
  WriteLn('=== Extended Features (leaf 7) ===');
  WriteLn('  AVX2:         ', (R.EBX and (1 shl 5))  <> 0);
  WriteLn('  BMI1:         ', (R.EBX and (1 shl 3))  <> 0);
  WriteLn('  BMI2:         ', (R.EBX and (1 shl 8))  <> 0);
  WriteLn('  AVX-512F:     ', (R.EBX and (1 shl 16)) <> 0);
  WriteLn('  SHA:          ', (R.EBX and (1 shl 29)) <> 0);
end;

var
  R: TCPUIDResult;
  MaxLeaf: Cardinal;

begin
  WriteLn('=== CPUID Info ===');
  WriteLn;

  R := CPUID(0, 0);
  MaxLeaf := R.EAX;
  WriteLn('Vendor:        ', GetVendorString);
  WriteLn('Max CPUID leaf: ', MaxLeaf);
  WriteLn;

  MostrarFeatures;

  WriteLn;
  ReadLn;
end.
