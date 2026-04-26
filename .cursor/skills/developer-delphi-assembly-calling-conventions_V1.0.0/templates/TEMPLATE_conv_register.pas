unit TEMPLATE_conv_register;
// TEMPLATE: Funcao assembly com convencao `register` (padrao Delphi Win32)
// Substituir: NOME_FUNCAO, TIPO_RETORNO, PARAM_A, PARAM_B, TIPO_A, TIPO_B
// Valido: Win32 (dcc32) — para Win64 usar TEMPLATE_func_x64.pas
{$IFDEF WIN32}
interface

function NOME_FUNCAO(PARAM_A: TIPO_A; PARAM_B: TIPO_B): TIPO_RETORNO; register;

implementation

function NOME_FUNCAO(PARAM_A: TIPO_A; PARAM_B: TIPO_B): TIPO_RETORNO; register;
asm
  // Win32 register calling convention:
  // PARAM_A → EAX
  // PARAM_B → EDX
  // PARAM_C → ECX (se houver terceiro parametro)
  // Retorno → EAX (Integer/Pointer) ou ST(0) (Double/Single)

  // TODO: implementar logica aqui
  // Exemplo (soma dois inteiros):
  // ADD EAX, EDX   // EAX = PARAM_A + PARAM_B
  //                // Resultado em EAX automaticamente
end;
{$ENDIF WIN32}

end.
