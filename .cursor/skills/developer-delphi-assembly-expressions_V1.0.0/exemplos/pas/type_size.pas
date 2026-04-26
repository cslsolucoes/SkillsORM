unit type_size;
// Uso de TYPE e SIZE em expressoes asm Delphi
{$APPTYPE CONSOLE}
interface

type
  TRegistro = record
    ID:    Integer;   // 4 bytes — offset 0
    Valor: Double;    // 8 bytes — offset 4 (ou 8 se alinhado)
    Flag:  Boolean;   // 1 byte  — offset 12
  end;

var
  GArray: array[0..9] of Integer;    // 10 elementos = 40 bytes
  GRegistro: TRegistro;

function TamanhoInteger: Integer; assembler;
function TamanhoDouble: Integer; assembler;
function TamanhoRegistro: Integer; assembler;
function TamanhoTotalArray: Integer; assembler;
function TamanhoElementoArray: Integer; assembler;

implementation

function TamanhoInteger: Integer; assembler;
asm
  MOV EAX, TYPE Integer     // EAX = 4 (bytes)
end;

function TamanhoDouble: Integer; assembler;
asm
  MOV EAX, TYPE Double      // EAX = 8 (bytes)
end;

function TamanhoRegistro: Integer; assembler;
asm
  // TYPE TRegistro = SizeOf(TRegistro) calculado em tempo de compilacao
  MOV EAX, TYPE TRegistro   // EAX = tamanho do record (pode variar com alinhamento)
end;

function TamanhoTotalArray: Integer; assembler;
asm
  // SIZE = tamanho total da variavel, incluindo dimensoes do array
  MOV EAX, SIZE GArray      // EAX = 40 (10 elementos * 4 bytes cada)
end;

function TamanhoElementoArray: Integer; assembler;
asm
  // TYPE de array = tamanho de 1 ELEMENTO (nao o total!)
  MOV EAX, TYPE GArray      // EAX = 4 (tamanho de Integer, nao o array inteiro)
end;

end.
