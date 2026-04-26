unit TEMPLATE_simd_dispatch;
// TEMPLATE: Dispatch dinamico por nivel de suporte SIMD em runtime
// Padrao recomendado: verificar uma vez na inicializacao e usar funcao pointer
{$APPTYPE CONSOLE}
interface

// Ponteiro de funcao para a implementacao selecionada
type
  TProcessarFn = procedure(Dest, Src: PSingle; Count: Integer);

// Selecionar implementacao otima em runtime
function SelecionarImplementacao: TProcessarFn;

// Implementacoes por nivel:
procedure ProcessarEscalar(Dest, Src: PSingle; Count: Integer);
procedure ProcessarSSE2(Dest, Src: PSingle; Count: Integer);
procedure ProcessarAVX2(Dest, Src: PSingle; Count: Integer);

// Variavel global com a funcao selecionada (inicializar na startup)
var
  ProcessarOtimo: TProcessarFn;

implementation

uses cpuid_avx_check;  // unit de verificacao CPUID (ver exemplos/pas/cpuid_avx_check.pas)

procedure ProcessarEscalar(Dest, Src: PSingle; Count: Integer);
// Fallback sem SIMD — compativel com qualquer CPU
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Dest[I] := Src[I]; // TODO: substituir por operacao real
  end;
end;

procedure ProcessarSSE2(Dest, Src: PSingle; Count: Integer);
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    MOV  EDI, Dest
    MOV  ESI, Src
    MOV  ECX, Count
    MOV  EAX, ECX
    SHR  EAX, 2
    AND  ECX, 3
    TEST EAX, EAX
    JZ   @res_sse2
  @loop_sse2:
    MOVUPS XMM0, [ESI]
    // TODO: operacao SSE2
    MOVUPS [EDI], XMM0
    ADD ESI, 16
    ADD EDI, 16
    DEC EAX
    JNZ @loop_sse2
  @res_sse2:
    POP EDI
    POP ESI
{$ENDIF WIN32}
  end;
end;

procedure ProcessarAVX2(Dest, Src: PSingle; Count: Integer);
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EDI
    MOV  EDI, Dest
    MOV  ESI, Src
    MOV  ECX, Count
    MOV  EAX, ECX
    SHR  EAX, 3
    AND  ECX, 7
    TEST EAX, EAX
    JZ   @res_avx2
  @loop_avx2:
    VMOVUPS YMM0, [ESI]
    // TODO: operacao AVX2
    VMOVUPS [EDI], YMM0
    ADD ESI, 32
    ADD EDI, 32
    DEC EAX
    JNZ @loop_avx2
    VZEROUPPER
  @res_avx2:
    POP EDI
    POP ESI
{$ENDIF WIN32}
  end;
end;

function SelecionarImplementacao: TProcessarFn;
var
  SIMD: TSIMDSupport;
begin
  SIMD := VerificarSIMD;
  if SIMD.AVX2 then
    Result := ProcessarAVX2
  else if SIMD.SSE2 then
    Result := ProcessarSSE2
  else
    Result := ProcessarEscalar;
end;

initialization
  // Selecionar uma vez na startup — sem overhead em cada chamada
  ProcessarOtimo := SelecionarImplementacao;

end.
