unit xmm_preserve;
// Demonstra preservacao correta de XMM non-volatile no Win64
// XMM0-XMM5: volateis (pode destruir)
// XMM6-XMM15: NON-VOLATILE (deve preservar com .SAVENV)
{$APPTYPE CONSOLE}
interface

// Funcao que usa XMM6 e XMM7 (non-volatile) de forma correta
function ProcessarComXMM(A, B: Single): Single; assembler;

// ERRADO: usa XMM6 sem .SAVENV (corromperia o caller)
// function ProcessarERRADO(A, B: Single): Single; assembler;

implementation

function ProcessarComXMM(A, B: Single): Single; assembler;
asm
{$IFDEF WIN64}
  // .SAVENV instrui Delphi a salvar no prologo e restaurar no epilogo:
  .PARAMS 2        // A em XMM0, B em XMM1 (float params Win64)
  .SAVENV XMM6     // salva XMM6 (non-volatile)
  .SAVENV XMM7     // salva XMM7 (non-volatile)

  // A = XMM0 (1o param float), B = XMM1 (2o param float)
  MOVAPS XMM6, XMM0    // XMM6 = A (salvo -- pode usar livremente)
  MOVAPS XMM7, XMM1    // XMM7 = B

  // Operacao: resultado = (A + B) * A
  ADDSS  XMM6, XMM7    // XMM6 = A + B
  MULSS  XMM6, XMM0    // XMM6 = (A+B) * A
  MOVAPS XMM0, XMM6    // XMM0 = resultado (retorno float)

  // XMM6 e XMM7 restaurados automaticamente pelo epilogo gerado por .SAVENV
{$ENDIF WIN64}
{$IFDEF WIN32}
  // Win32: Single retornado em ST(0) (FPU x87)
  // XMM nao e non-volatile da mesma forma em Win32
  // Parametros em pilha (stdcall) ou EAX/EDX (register -- mas nao floats!)
  // Para Single em Win32 register: parametros passados na pilha mesmo!
  // Esta implementacao e simplificada:
  FLD  DWORD PTR [ESP+4]    // ST(0) = A
  FADD DWORD PTR [ESP+8]    // ST(0) = A + B
  FMUL DWORD PTR [ESP+4]    // ST(0) = (A+B) * A
  // ST(0) e o retorno automaticamente em Win32
{$ENDIF WIN32}
end;

end.
