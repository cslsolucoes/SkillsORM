unit conv_safecall;
// Exemplo: convencao `safecall` — usada em COM/Automation
// Identica a stdcall em passagem de args (pilha, direita-esq)
// Diferenca: retorno real e HResult; valor de retorno Pascal
// vira ultimo parametro OUT adicional na pilha
// Excecoes sao capturadas e convertidas para HResult automaticamente
{$APPTYPE CONSOLE}
interface

// Interface COM tipica com safecall
type
  ICalculadora = interface(IInterface)
    ['{12345678-1234-1234-1234-123456789ABC}']
    function Somar(A, B: Integer): Integer; safecall;
    function Dividir(A, B: Integer): Double; safecall;
  end;

  TCalculadora = class(TInterfacedObject, ICalculadora)
  public
    function Somar(A, B: Integer): Integer; safecall;
    function Dividir(A, B: Integer): Double; safecall;
  end;

implementation

// safecall: Delphi gera automaticamente o wrapper HResult
// O compilador transforma:
//   function Somar(A, B: Integer): Integer; safecall;
// na ABI real:
//   function Somar(A, B: Integer; out Result: Integer): HResult; stdcall;
// Excecoes internas sao capturadas e retornadas como HResult de erro

function TCalculadora.Somar(A, B: Integer): Integer; safecall;
begin
  // Implementacao normal — Delphi cuida do HResult
  Result := A + B;
  // Se levantar excecao, Delphi converte para HResult E_FAIL ou equivalente
end;

function TCalculadora.Dividir(A, B: Integer): Double; safecall;
begin
  if B = 0 then
    raise EDivByZero.Create('Divisao por zero')
    // ^ Delphi captura, retorna HResult, caller recebe excecao COM
  else
    Result := A / B;
end;

end.
