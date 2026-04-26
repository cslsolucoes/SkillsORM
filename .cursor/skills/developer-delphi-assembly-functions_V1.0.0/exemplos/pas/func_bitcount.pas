unit func_bitcount;
// Contagem de bits (popcount) e operacoes de bit manipulation em assembly
{$APPTYPE CONSOLE}
interface

function PopCount32(N: Cardinal): Integer; assembler;
function PopCount64(N: UInt64): Integer; assembler;
function ContarZerosBSF(N: Cardinal): Integer; assembler; // trailing zeros
function ContarZerosBSR(N: Cardinal): Integer; assembler; // leading zeros

implementation

function PopCount32(N: Cardinal): Integer; assembler;
// Conta bits setados usando POPCNT (SSE4.2)
// N=EAX (Win32)
asm
  POPCNT EAX, EAX
  // Resultado em EAX = numero de bits 1
end;

function PopCount64(N: UInt64): Integer; assembler;
// Win32: N em EDX:EAX (high:low)
// Win64: N em RCX, resultado em EAX
asm
{$IFDEF WIN32}
  // EDX:EAX = N
  POPCNT ECX, EAX     // ECX = popcount do low word
  POPCNT EAX, EDX     // EAX = popcount do high word
  ADD    EAX, ECX     // EAX = total
{$ENDIF WIN32}
{$IFDEF WIN64}
  POPCNT RAX, RCX     // RAX = popcount do N inteiro (64-bit)
{$ENDIF WIN64}
end;

function ContarZerosBSF(N: Cardinal): Integer; assembler;
// BSF = Bit Scan Forward: posicao do bit 1 menos significativo
// = numero de trailing zeros
// N=EAX (Win32), N=ECX (Win64)
asm
{$IFDEF WIN32}
  TEST EAX, EAX
  JZ   @zero
  BSF  EAX, EAX     // EAX = posicao do bit 1 mais baixo
  RET
@zero:
  MOV  EAX, 32      // N=0: convencionalmente 32 trailing zeros
{$ENDIF WIN32}
{$IFDEF WIN64}
  TEST ECX, ECX
  JZ   @zero64
  BSF  EAX, ECX
  RET
@zero64:
  MOV  EAX, 32
{$ENDIF WIN64}
end;

function ContarZerosBSR(N: Cardinal): Integer; assembler;
// BSR = Bit Scan Reverse: posicao do bit 1 mais significativo
// leading zeros = 31 - BSR(N)
asm
{$IFDEF WIN32}
  TEST EAX, EAX
  JZ   @zero
  BSR  EAX, EAX
  SUB  EAX, 31      // posicao a partir do topo
  NEG  EAX          // leading zeros = 31 - posicao
  RET
@zero:
  MOV  EAX, 32
{$ENDIF WIN32}
{$IFDEF WIN64}
  TEST ECX, ECX
  JZ   @zero64
  BSR  EAX, ECX
  SUB  EAX, 31
  NEG  EAX
  RET
@zero64:
  MOV  EAX, 32
{$ENDIF WIN64}
end;

end.
