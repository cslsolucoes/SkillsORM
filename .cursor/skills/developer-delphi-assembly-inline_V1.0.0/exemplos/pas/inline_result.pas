unit inline_result;
// Uso de @Result e Result dentro de blocos asm Delphi
// @Result = endereco do espaco de retorno (para tipos compostos)
// Result = variavel direta (para tipos simples)
{$APPTYPE CONSOLE}
interface

function RetornarConstante: Integer;
function RetornarNegativo(N: Integer): Integer;
function RetornarPonteiro(P: Pointer): Pointer;

implementation

function RetornarConstante: Integer;
// Forma 1: escrever em EAX diretamente (EAX = registrador de retorno)
begin
  asm
    MOV EAX, 42      // EAX e o registrador de retorno para Integer
    // Delphi entende que EAX = Result ao final do bloco asm
  end;
end;

function RetornarNegativo(N: Integer): Integer;
// Forma 2: usar variavel Result explicitamente
begin
  asm
    MOV EAX, N
    NEG EAX
    MOV Result, EAX  // Result e alias para a variavel de retorno Pascal
  end;
end;

function RetornarPonteiro(P: Pointer): Pointer;
// Retorno de Pointer: mesmo mecanismo — EAX em Win32, RAX em Win64
begin
  asm
{$IFDEF WIN32}
    // P ja esta em EAX (convencao register)
    // Nao precisa fazer nada — EAX ja e o retorno
    // Mas para demonstrar @Result:
    LEA EAX, [EAX]   // identidade (P := P)
{$ENDIF WIN32}
{$IFDEF WIN64}
    // P em RCX (Win64)
    MOV RAX, RCX     // RAX = retorno
{$ENDIF WIN64}
  end;
end;

end.
