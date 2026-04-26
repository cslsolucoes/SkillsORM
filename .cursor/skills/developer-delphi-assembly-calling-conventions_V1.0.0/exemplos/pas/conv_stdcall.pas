unit conv_stdcall;
// Exemplo: convencao `stdcall` — usada em WinAPI
// Parametros: pilha (direita para esquerda)
// Quem limpa: callee (RET N)
// Retorno: EAX (inteiro) ou ST(0) (float x87 em Win32)
{$APPTYPE CONSOLE}
interface

function SomarStdcall(A, B: Integer): Integer; stdcall;
function MultiplicarStdcall(A, B, C: Integer): Integer; stdcall;

// Exemplo de uso com WinAPI real:
// MessageBox e declarada assim na Windows unit:
// function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;

implementation

function SomarStdcall(A, B: Integer): Integer; stdcall;
asm
  // stdcall Win32: parametros na pilha
  // Apos CALL + PUSH EBP:
  // [EBP+8]  = A
  // [EBP+12] = B
  PUSH EBP
  MOV  EBP, ESP
  MOV  EAX, [EBP+8]    // A
  ADD  EAX, [EBP+12]   // A + B
  POP  EBP
  RET  8               // callee remove 2*4=8 bytes da pilha
end;

function MultiplicarStdcall(A, B, C: Integer): Integer; stdcall;
asm
  // [EBP+8]=A, [EBP+12]=B, [EBP+16]=C
  PUSH EBP
  MOV  EBP, ESP
  PUSH EBX             // EBX e non-volatile!
  MOV  EAX, [EBP+8]
  IMUL EAX, [EBP+12]   // EAX = A * B
  ADD  EAX, [EBP+16]   // EAX = A*B + C
  POP  EBX
  POP  EBP
  RET  12              // 3 parametros * 4 bytes = 12
end;

end.
