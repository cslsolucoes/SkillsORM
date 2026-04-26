unit func_pura_32;
// Funcoes puramente assembly Win32 usando keyword `assembler`
// Valido: dcc32 (Win32 somente neste arquivo — sem {$IFDEF})
{$APPTYPE CONSOLE}
interface

function SomaPura(A, B: Integer): Integer; assembler;
function MaximoPuro(A, B: Integer): Integer; assembler;
function ContarBitsPuro(N: Cardinal): Integer; assembler;
function BitScanForwardPuro(N: Cardinal): Integer; assembler;

implementation

function SomaPura(A, B: Integer): Integer; assembler;
asm
  // register: A=EAX, B=EDX
  ADD EAX, EDX
  // Resultado automaticamente em EAX
end;

function MaximoPuro(A, B: Integer): Integer; assembler;
asm
  // A=EAX, B=EDX
  CMP EAX, EDX
  JGE @retorna_a
  MOV EAX, EDX   // B e maior
@retorna_a:
  // EAX = max(A, B)
end;

function ContarBitsPuro(N: Cardinal): Integer; assembler;
// Conta quantos bits estao setados em N (popcount)
asm
  // N=EAX
  // Algoritmo: POPCNT (SSE4.2) ou fallback manual
  POPCNT EAX, EAX    // EAX = numero de bits 1 em EAX
  // NOTA: POPCNT requer CPU com suporte SSE4.2
  // Para CPU mais antiga, usar algoritmo manual:
  // XOR ECX, ECX
  // @loop: TEST EAX, EAX; JZ @fim; INC ECX; AND EAX, EAX-1; JMP @loop
  // @fim: MOV EAX, ECX
end;

function BitScanForwardPuro(N: Cardinal): Integer; assembler;
// Retorna posicao do bit menos significativo setado (0-31), ou -1 se N=0
asm
  // N=EAX
  TEST EAX, EAX
  JZ   @zero
  BSF  EAX, EAX      // EAX = posicao do bit mais baixo setado
  RET
@zero:
  MOV  EAX, -1
end;

end.
