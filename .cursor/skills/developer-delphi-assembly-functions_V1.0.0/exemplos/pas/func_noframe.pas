unit func_noframe;
// Funcoes assembly com NOSTACKFRAME — sem prologo/epilogo
// Ideal para: funcoes leaf ultra-rapidas, hot paths criticos
{$APPTYPE CONSOLE}
interface

// NOSTACKFRAME: sem PUSH EBP / MOV EBP,ESP
// Restricoes:
//   - NAO pode ter variaveis locais
//   - NAO deve chamar outras funcoes (leaf function)
//   - NAO deve usar registradores non-volatile sem salvar manualmente
function SomaSemFrame(A, B: Integer): Integer; assembler; nostackframe;
function AbsSemFrame(N: Integer): Integer; assembler; nostackframe;
function IsZeroSemFrame(N: Integer): Boolean; assembler; nostackframe;

implementation

function SomaSemFrame(A, B: Integer): Integer; assembler; nostackframe;
asm
  // Win32: A=EAX, B=EDX
  // Sem frame — instrucoes diretas
  ADD EAX, EDX
  // RET implicit ou explicito
end;

function AbsSemFrame(N: Integer): Integer; assembler; nostackframe;
asm
  // N=EAX
  TEST EAX, EAX
  JNS  @fim      // se positivo, ja esta correto
  NEG  EAX       // se negativo, inverter sinal
@fim:
end;

function IsZeroSemFrame(N: Integer): Boolean; assembler; nostackframe;
asm
  // N=EAX, retorno=AL (Boolean)
  TEST EAX, EAX
  SETZ AL        // AL = 1 se EAX = 0, 0 caso contrario
  // Boolean em Delphi: 0=False, 1=True (byte)
end;

end.
