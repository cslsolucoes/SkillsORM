unit conv_cdecl;
// Exemplo: convencao `cdecl` — usada em DLLs C/C++
// Parametros: pilha (direita para esquerda)
// Quem limpa: CALLER (Delphi gera ADD ESP, N automaticamente)
// Vantagem sobre stdcall: suporta funcoes variadic (argc variaveis)
{$APPTYPE CONSOLE}
interface

// Funcao cdecl interna (bloco asm)
function SomarCdecl(A, B: Integer): Integer; cdecl;

// Funcao cdecl externa — linkada de DLL C
// Exemplo: funcao C: int __cdecl c_strlen(const char* s);
function c_strlen(S: PAnsiChar): Integer; cdecl; external 'msvcrt.dll' name 'strlen';

implementation

function SomarCdecl(A, B: Integer): Integer; cdecl;
asm
  // cdecl: parametros na pilha, igual a stdcall
  // Diferenca: RET sem N (caller limpa)
  PUSH EBP
  MOV  EBP, ESP
  MOV  EAX, [EBP+8]    // A
  ADD  EAX, [EBP+12]   // A + B
  POP  EBP
  RET                  // RET simples — sem N!
  // Delphi gera: ADD ESP, 8 no caller automaticamente
end;

end.
