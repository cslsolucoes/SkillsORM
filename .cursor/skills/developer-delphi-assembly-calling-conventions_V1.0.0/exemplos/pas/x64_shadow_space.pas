unit x64_shadow_space;
// Exemplo: Windows x64 ABI no Delphi (dcc64)
// Demonstra como o built-in assembler do Delphi lida com x64
// e como usar pseudo-ops para garantir shadow space correto
{$APPTYPE CONSOLE}
interface

// Funcao assembler pura x64 — Delphi cuida do shadow space automaticamente
// quando se usa a keyword `assembler` + pseudo-ops
function SomarX64(A, B: Integer): Integer; assembler;

// Funcao que chama outra (nao-leaf): precisa de .PARAMS
function ContarAteX64(Inicio, Fim: Int64): Int64; assembler;

implementation

function SomarX64(A, B: Integer): Integer; assembler;
asm
  // Windows x64: A=ECX (RCX baixo 32), B=EDX (RDX baixo 32)
  // Retorno: EAX (RAX baixo 32)
  // Funcao leaf simples: Delphi nao gera prologo/epilogo complexo
  MOV EAX, ECX    // EAX = A
  ADD EAX, EDX    // EAX = A + B
end;

function ContarAteX64(Inicio, Fim: Int64): Int64; assembler;
asm
  // Int64 em x64: passa em RCX e RDX completos (64-bit)
  // .PARAMS 2 instrui Delphi a gerar frame + shadow space de 32B
  .PARAMS 2
  // RCX = Inicio, RDX = Fim
  XOR   RAX, RAX          // contador = 0
  CMP   RCX, RDX
  JGE   @fim

@loop:
  INC   RAX
  INC   RCX
  CMP   RCX, RDX
  JL    @loop

@fim:
  // RAX = contagem — retorno automatico
end;

end.
