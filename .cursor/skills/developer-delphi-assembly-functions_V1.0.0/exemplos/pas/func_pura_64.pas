unit func_pura_64;
// Funcoes assembly puras Win64 com pseudo-ops Delphi
// Valido: dcc64 (Win64)
{$APPTYPE CONSOLE}
interface

function SomaPura64(A, B: Integer): Integer; assembler;
function Somar64bit(A, B: Int64): Int64; assembler;
function Calcular4Params(A, B, C, D: Integer): Integer; assembler;

implementation

function SomaPura64(A, B: Integer): Integer; assembler;
asm
  // Win64: A=ECX (RCX), B=EDX (RDX), retorno=EAX (RAX)
  // Funcao leaf simples: sem .PARAMS necessario
  MOV EAX, ECX
  ADD EAX, EDX
end;

function Somar64bit(A, B: Int64): Int64; assembler;
asm
  // Int64 em Win64: A=RCX, B=RDX, retorno=RAX
  MOV RAX, RCX
  ADD RAX, RDX
end;

function Calcular4Params(A, B, C, D: Integer): Integer; assembler;
// 4 parametros: A=ECX, B=EDX, C=R8D, D=R9D
// .PARAMS 4 habilita frame e shadow space (obrigatorio para nao-leaf ou muitos params)
asm
  .PARAMS 4              // declara 4 params — Delphi gera prologo correto
  // Calculo: A + B + C + D
  MOV EAX, ECX          // EAX = A
  ADD EAX, EDX          // EAX = A + B
  ADD EAX, R8D          // EAX = A + B + C
  ADD EAX, R9D          // EAX = A + B + C + D
end;

end.
