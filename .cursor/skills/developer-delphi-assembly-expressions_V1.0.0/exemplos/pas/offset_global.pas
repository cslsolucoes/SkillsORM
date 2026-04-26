unit offset_global;
// Uso de OFFSET para obter endereco de variaveis globais em asm Delphi
{$APPTYPE CONSOLE}
interface

var
  GContador: Integer = 0;
  GBuffer: array[0..15] of Byte;

function ObterEnderecoContador: Pointer; assembler;
function LerContador: Integer; assembler;
procedure IncrementarContador; assembler;
function SomaBytesBuffer: Integer; assembler;

implementation

function ObterEnderecoContador: Pointer; assembler;
asm
  // OFFSET retorna endereco estatico da variavel global
  MOV EAX, OFFSET GContador   // EAX = endereco de GContador
  // Alternativa equivalente:
  // LEA EAX, GContador
end;

function LerContador: Integer; assembler;
asm
  MOV EAX, OFFSET GContador   // EAX = ponteiro
  MOV EAX, [EAX]              // EAX = valor (*ponteiro = GContador)
  // Mais simples:
  // MOV EAX, GContador  (Delphi resolve como [OFFSET GContador])
end;

procedure IncrementarContador; assembler;
asm
  MOV EAX, OFFSET GContador
  INC DWORD PTR [EAX]         // (*EAX)++
end;

function SomaBytesBuffer: Integer; assembler;
// Soma todos os bytes de GBuffer usando OFFSET e SIZE
asm
  PUSH ESI
  MOV  ESI, OFFSET GBuffer    // ESI = endereco base do array
  MOV  ECX, SIZE GBuffer      // ECX = tamanho total em bytes (16)
  XOR  EAX, EAX               // EAX = acumulador

@loop:
  MOVZX EDX, BYTE PTR [ESI]   // EDX = byte atual (zero-extended)
  ADD   EAX, EDX
  INC   ESI
  DEC   ECX
  JNZ   @loop

  POP  ESI
end;

end.
