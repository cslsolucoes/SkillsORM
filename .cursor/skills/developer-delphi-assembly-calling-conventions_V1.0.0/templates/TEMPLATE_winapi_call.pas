unit TEMPLATE_winapi_call;
// TEMPLATE: Chamar WinAPI de dentro de bloco asm Delphi Win32
// Demonstra: shadow space nao necessario em Win32, apenas alinhar ESP
{$APPTYPE CONSOLE}
{$IFDEF WIN32}
interface

// Declarar a WinAPI que sera chamada
// (normalmente ja disponivel via Windows unit)
function MessageBoxA(hWnd: Cardinal; lpText, lpCaption: PAnsiChar; uType: Cardinal): Integer; stdcall; external 'user32.dll';

// Wrapper assembly que chama WinAPI
procedure MostrarMensagem(const Titulo, Texto: PAnsiChar);

implementation

procedure MostrarMensagem(const Titulo, Texto: PAnsiChar);
asm
  // register convention: Titulo=EAX, Texto=EDX
  // Preparar chamada stdcall para MessageBoxA:
  // MessageBoxA(hWnd=0, lpText, lpCaption, uType=0)
  // Empilhar da direita para esquerda:
  PUSH 0          // uType = MB_OK
  PUSH EAX        // lpCaption = Titulo
  PUSH EDX        // lpText = Texto
  PUSH 0          // hWnd = 0 (desktop)
  CALL MessageBoxA
  // MessageBoxA e stdcall: ela mesma limpa a pilha (RET 16)
  // Nao precisamos de ADD ESP, 16
end;
{$ENDIF WIN32}

end.
