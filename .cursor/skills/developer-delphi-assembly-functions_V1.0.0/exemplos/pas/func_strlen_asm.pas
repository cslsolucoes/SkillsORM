unit func_strlen_asm;
// Exemplos de strlen em assembly Delphi (inline e com .obj NASM)
{$APPTYPE CONSOLE}
interface

// Versao 1: inline assembly Delphi
function StrLenInline(S: PAnsiChar): Integer; assembler;

// Versao 2: linkagem de .obj NASM externo
// Requer: nasm -f win32 strlen_nasm.asm -o strlen_nasm.obj
// {$L strlen_nasm.obj}
// function StrLenNasm(S: PAnsiChar): Integer; external;

implementation

function StrLenInline(S: PAnsiChar): Integer; assembler;
// Conta caracteres ate o null terminator
// Win32: S=EAX
asm
  PUSH EDI
  MOV  EDI, EAX    // EDI = S
  XOR  ECX, ECX    // ECX = 0
  NOT  ECX         // ECX = 0xFFFFFFFF
  XOR  AL, AL      // AL = 0 (buscar null byte)
  CLD
  REPNE SCASB      // busca null em [EDI], decrementa ECX
  NOT  ECX         // complemento
  DEC  ECX         // nao contar o null
  MOV  EAX, ECX   // retorno
  POP  EDI
end;

end.
