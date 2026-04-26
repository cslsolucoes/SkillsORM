unit TEMPLATE_func_x64;
// TEMPLATE: Funcao `assembler` Win64 com pseudo-ops
// Substituir: NOME_FUNCAO, N_PARAMS, logica
{$APPTYPE CONSOLE}
{$IFDEF WIN64}
interface

function NOME_FUNCAO(Param1: Integer; Param2: Integer): Integer; assembler;

implementation

function NOME_FUNCAO(Param1: Integer; Param2: Integer): Integer; assembler;
asm
  .PARAMS 2          // N_PARAMS = numero de parametros declarados
  // Opcoes adicionais (descomentar se necessario):
  // .PUSHNV R12     // salvar R12 (se usar)
  // .PUSHNV R13     // salvar R13 (se usar)
  // .SAVENV XMM6    // salvar XMM6 (se usar SIMD non-volatile)

  // Win64 params: Param1=ECX (RCX), Param2=EDX (RDX)
  // Retorno: EAX (RAX para 64-bit, XMM0 para float)

  // TODO: implementar logica
  MOV EAX, ECX    // EAX = Param1
  ADD EAX, EDX    // EAX = Param1 + Param2

  // Registradores salvos com .PUSHNV/.SAVENV sao restaurados automaticamente
end;
{$ENDIF WIN64}

end.
