unit TEMPLATE_inline_resultado;
// TEMPLATE: Funcao com bloco asm retornando valor
// Substituir: NOME_FUNCAO, PARAM_A, TIPO_A, TIPO_RETORNO
{$APPTYPE CONSOLE}
interface

function NOME_FUNCAO(PARAM_A: TIPO_A): TIPO_RETORNO;

implementation

function NOME_FUNCAO(PARAM_A: TIPO_A): TIPO_RETORNO;
begin
  asm
{$IFDEF WIN32}
    // Win32 register: PARAM_A em EAX (1o param inteiro)
    // Retorno: EAX (Integer), ST(0) (Double), AL (Boolean)
    // TODO: implementar
    MOV EAX, PARAM_A
    // ... operacoes ...
    MOV Result, EAX
{$ENDIF WIN32}
{$IFDEF WIN64}
    // Win64: PARAM_A em ECX/RCX (1o param)
    // Retorno: EAX/RAX (Integer/Pointer), XMM0 (Double/Single)
    // TODO: implementar
    MOV EAX, ECX
    // ... operacoes ...
    // Para Integer: resultado em EAX automaticamente via RAX
{$ENDIF WIN64}
  end;
end;

end.
