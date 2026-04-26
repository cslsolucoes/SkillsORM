unit TEMPLATE_conv_stdcall;
// TEMPLATE: Funcao assembly com convencao `stdcall`
// Usar para: WinAPI, DLLs, interfaces que requerem stdcall
// Substituir: NOME_FUNCAO, N_PARAMS, N_BYTES_PILHA (N_PARAMS * 4 em Win32)
{$APPTYPE CONSOLE}
interface

function NOME_FUNCAO(Param1, Param2: Integer): Integer; stdcall;

implementation

function NOME_FUNCAO(Param1, Param2: Integer): Integer; stdcall;
asm
  // stdcall Win32: parametros na pilha
  // Frame apos PUSH EBP + MOV EBP,ESP:
  //   [EBP+4]  = endereco de retorno
  //   [EBP+8]  = Param1
  //   [EBP+12] = Param2
  //   [EBP+N]  = ParamN

  PUSH EBP
  MOV  EBP, ESP
  // Salvar registradores non-volatile se necessario:
  // PUSH EBX
  // PUSH ESI
  // PUSH EDI

  // TODO: implementar logica
  MOV  EAX, [EBP+8]    // Param1
  ADD  EAX, [EBP+12]   // + Param2

  // Restaurar registradores (ordem inversa do PUSH):
  // POP  EDI
  // POP  ESI
  // POP  EBX
  POP  EBP
  RET  8               // N_BYTES_PILHA = N_PARAMS * 4
                       // 2 params * 4 bytes = 8
end;

end.
