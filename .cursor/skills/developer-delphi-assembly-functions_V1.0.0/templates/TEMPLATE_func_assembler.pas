unit TEMPLATE_func_assembler;
// TEMPLATE: Funcao `assembler` Win32 — substituir NOME_FUNCAO e logica
{$APPTYPE CONSOLE}
{$IFDEF WIN32}
interface

function NOME_FUNCAO(Param1: Integer; Param2: Integer): Integer; assembler;

implementation

function NOME_FUNCAO(Param1: Integer; Param2: Integer): Integer; assembler;
asm
  // Win32 register: Param1=EAX, Param2=EDX, retorno=EAX
  // Salvar registradores non-volatile se usados:
  // PUSH EBX  (se usar EBX)
  // PUSH ESI  (se usar ESI)
  // PUSH EDI  (se usar EDI)

  // TODO: implementar logica
  ADD EAX, EDX

  // Restaurar (ordem inversa):
  // POP EDI
  // POP ESI
  // POP EBX
end;
{$ENDIF WIN32}

end.
