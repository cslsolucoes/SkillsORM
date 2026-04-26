unit TEMPLATE_inline_string_op;
// TEMPLATE: Operacao em buffer de caracteres via asm (PAnsiChar/PChar)
// NOTA: Nao usar string/UnicodeString diretamente em asm — usar PChar/PAnsiChar
{$APPTYPE CONSOLE}
interface

// Exemplo: contar caracteres em buffer PAnsiChar (strlen simplificado)
function ContarChars(P: PAnsiChar): Integer;

// Exemplo: converter buffer para maiusculas (in-place)
procedure ParaMaiusculas(P: PAnsiChar; Len: Integer);

implementation

function ContarChars(P: PAnsiChar): Integer;
// Win32: P=EAX; Win64: P=RCX
begin
  asm
{$IFDEF WIN32}
    MOV  EDI, EAX    // EDI = P
    XOR  ECX, ECX    // ECX = contador = 0
    DEC  EDI         // preparar para loop: EDI aponta para pos-1
  @loop:
    INC  EDI
    INC  ECX
    CMP  BYTE PTR [EDI], 0   // chegou ao null terminator?
    JNZ  @loop
    DEC  ECX                 // nao contar o null
    MOV  EAX, ECX            // resultado
{$ENDIF WIN32}
{$IFDEF WIN64}
    MOV  RDI, RCX
    XOR  ECX, ECX
    DEC  RDI
  @loop64:
    INC  RDI
    INC  ECX
    CMP  BYTE PTR [RDI], 0
    JNZ  @loop64
    DEC  ECX
    MOV  EAX, ECX
{$ENDIF WIN64}
  end;
end;

procedure ParaMaiusculas(P: PAnsiChar; Len: Integer);
// Win32: P=EAX, Len=EDX
begin
  asm
{$IFDEF WIN32}
    MOV  ECX, EDX    // ECX = Len
    MOV  EDI, EAX    // EDI = P
    TEST ECX, ECX
    JZ   @fim
  @loop:
    MOV  AL, [EDI]
    CMP  AL, 'a'
    JB   @proximo
    CMP  AL, 'z'
    JA   @proximo
    SUB  AL, 32      // converter para maiusculo (a-z -> A-Z)
    MOV  [EDI], AL
  @proximo:
    INC  EDI
    DEC  ECX
    JNZ  @loop
  @fim:
{$ENDIF WIN32}
  end;
end;

end.
