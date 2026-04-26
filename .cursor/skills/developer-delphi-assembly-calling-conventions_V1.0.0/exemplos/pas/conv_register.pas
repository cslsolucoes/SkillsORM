unit conv_register;
// Exemplo: convencao `register` (padrao Delphi Win32)
// Passagem: EAX=primeiro, EDX=segundo, ECX=terceiro param inteiro
// Para metodos: Self=EAX, 1o param=EDX, 2o param=ECX
{$APPTYPE CONSOLE}
interface

// register e o padrao — palavra-chave opcional mas explicita
function SomarRegister(A, B: Integer): Integer; register;
function TriploRegister(A, B, C: Integer): Integer; register;

type
  TMinhaClasse = class
  public
    Valor: Integer;
    // Metodo com convencao register:
    // Self=EAX, A=EDX, B=ECX
    function Calcular(A, B: Integer): Integer; register;
  end;

implementation

function SomarRegister(A, B: Integer): Integer; register;
asm
  // Win32 register: A=EAX, B=EDX
  // Retorno: EAX
  ADD EAX, EDX    // EAX = A + B
  // EAX ja contem o resultado — Delphi usa automaticamente
end;

function TriploRegister(A, B, C: Integer): Integer; register;
asm
  // A=EAX, B=EDX, C=ECX
  ADD EAX, EDX    // EAX = A + B
  ADD EAX, ECX    // EAX = A + B + C
end;

function TMinhaClasse.Calcular(A, B: Integer): Integer; register;
asm
  // Metodo: Self=EAX, A=EDX, B=ECX
  // Acesso a campo: MOV ECX, [EAX].TMinhaClasse.Valor
  // Mas aqui apenas soma A + B como exemplo
  MOV EAX, EDX   // EAX = A
  ADD EAX, ECX   // EAX = A + B
end;

end.
