unit inline_variaveis;
// Acesso a variaveis locais e globais dentro de blocos asm
// Delphi built-in assembler: referenciar pelo nome (resolucao automatica)
{$APPTYPE CONSOLE}
interface

var
  GVarGlobal: Integer = 100;

function UsarGlobal: Integer;
function UsarLocais: Integer;
function OffsetDemo: Pointer;

implementation

function UsarGlobal: Integer;
begin
  asm
    // OFFSET: endereco em tempo de compilacao de variavel global
    MOV EAX, OFFSET GVarGlobal   // EAX = endereco de GVarGlobal
    MOV EAX, [EAX]               // EAX = valor de GVarGlobal

    // Alternativa mais simples (Delphi resolve automaticamente):
    // MOV EAX, GVarGlobal  // funciona se GVarGlobal e global
    MOV Result, EAX
  end;
end;

function UsarLocais: Integer;
var
  X, Y: Integer;
begin
  X := 10;
  Y := 20;
  asm
    // Variaveis locais: Delphi resolve pelo nome
    // Internamente sao [EBP-N] mas nao precisamos saber o offset exato
    MOV EAX, X       // EAX = X (valor 10)
    ADD EAX, Y       // EAX = X + Y (30)

    // Escrever de volta para variavel local:
    MOV X, EAX       // X = 30

    MOV Result, EAX
  end;
end;

function OffsetDemo: Pointer;
// Demonstra OFFSET para obter endereco de global
begin
  asm
    MOV EAX, OFFSET GVarGlobal   // EAX = ponteiro para GVarGlobal
    MOV Result, EAX
    // Equivalente Pascal: Result := @GVarGlobal;
  end;
end;

end.
