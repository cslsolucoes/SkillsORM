unit TEMPLATE_inline_loop;
// TEMPLATE: Loop assembly inline com contador e ponteiro
// Uso: processar arrays, strings, buffers de memoria
{$APPTYPE CONSOLE}
interface

// Substituir: NOME_FUNCAO, TIPO_ELEMENTO, operacao no loop
function NOME_FUNCAO(P: Pointer; Count: Integer): Integer;

implementation

function NOME_FUNCAO(P: Pointer; Count: Integer): Integer;
// Win32 register: P=EAX, Count=EDX
// Retorno acumulador em EAX
begin
  asm
{$IFDEF WIN32}
    PUSH ESI
    PUSH EBX
    MOV  ESI, EAX      // ESI = P
    MOV  ECX, EDX      // ECX = Count (contador do loop)
    XOR  EBX, EBX      // EBX = acumulador = 0
    TEST ECX, ECX
    JZ   @fim

  @loop:
    // TODO: operacao por elemento:
    // ADD EBX, [ESI]     // acumular Integer
    // MOVZX EAX, BYTE PTR [ESI]; ADD EBX, EAX  // acumular Byte
    NOP                  // substituir por operacao real

    ADD  ESI, 4          // TODO: ajustar tamanho do elemento (4=Integer, 1=Byte, 8=Int64)
    DEC  ECX
    JNZ  @loop

  @fim:
    MOV  EAX, EBX        // resultado = acumulador
    POP  EBX
    POP  ESI
{$ENDIF WIN32}
{$IFDEF WIN64}
    PUSH RSI
    PUSH RBX
    MOV  RSI, RCX       // RSI = P
    MOV  RCX, RDX       // RCX = Count (EDX como 32-bit ou R8)
    XOR  RBX, RBX       // acumulador
    TEST RCX, RCX
    JZ   @fim64

  @loop64:
    // TODO: operacao
    NOP
    ADD  RSI, 4
    DEC  RCX
    JNZ  @loop64

  @fim64:
    MOV  RAX, RBX
    POP  RBX
    POP  RSI
{$ENDIF WIN64}
  end;
end;

end.
