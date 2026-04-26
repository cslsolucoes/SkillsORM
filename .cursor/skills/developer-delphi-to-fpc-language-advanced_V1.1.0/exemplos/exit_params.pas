unit exit_params;
{
  Exit(value), guard clauses e early return em Delphi
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils;

// ---------------------------------------------------------------------------
// Exit com valor — Delphi 2006+
// Permite retorno antecipado sem variável Result intermediária
// ---------------------------------------------------------------------------

// Sem guard clause — estilo "nested if" (difícil de ler)
function ValidarEmailSemGuard(const AEmail: string): string;

// Com guard clause — estilo "early return" (claro e linear)
function ValidarEmailComGuard(const AEmail: string): string;

// ---------------------------------------------------------------------------
// Padrões de guard clause
// ---------------------------------------------------------------------------

// Guard: validar parâmetros de entrada
function ProcessarPedido(AId: Integer; const ACliente: string;
  AQuantidade: Integer): string;

// Guard: verificar estado interno
type
  TConexao = class
  private
    FConectado: Boolean;
    FHost     : string;
  public
    constructor Create(const AHost: string);
    function Conectar: Boolean;
    // Guard no método: sair cedo se não conectado
    function ExecutarQuery(const ASQL: string): string;
    property Conectado: Boolean read FConectado;
  end;

// ---------------------------------------------------------------------------
// Exit em loops — break+return equivalente
// ---------------------------------------------------------------------------
function EncontrarPrimeiroImpar(const AArray: TArray<Integer>): Integer;
function ContarAteCondicao(const AArray: TArray<Integer>;
  ALimite: Integer): Integer;

// ---------------------------------------------------------------------------
// Padrão: Result := Default + guard chain
// ---------------------------------------------------------------------------
function ClassificarIdade(AIdade: Integer): string;
function CalcularDesconto(AValor: Double; APercentual: Double): Double;

implementation

// ---------------------------------------------------------------------------
// Sem guard — difícil de seguir
// ---------------------------------------------------------------------------

function ValidarEmailSemGuard(const AEmail: string): string;
begin
  if AEmail.Trim.IsEmpty then
    Result := 'E-mail vazio'
  else
  begin
    if Pos('@', AEmail) = 0 then
      Result := 'Sem @'
    else
    begin
      if Pos('.', AEmail) = 0 then
        Result := 'Sem domínio'
      else
        Result := '';  // OK
    end;
  end;
end;

// ---------------------------------------------------------------------------
// Com guard — linear e fácil de ler
// ---------------------------------------------------------------------------

function ValidarEmailComGuard(const AEmail: string): string;
begin
  if AEmail.Trim.IsEmpty then Exit('E-mail vazio');
  if Pos('@', AEmail) = 0  then Exit('Sem @');
  if Pos('.', AEmail) = 0  then Exit('Sem domínio');
  Result := '';  // OK — só chega aqui se passou todas as guards
end;

// ---------------------------------------------------------------------------
// Guard: validação de parâmetros
// ---------------------------------------------------------------------------

function ProcessarPedido(AId: Integer; const ACliente: string;
  AQuantidade: Integer): string;
begin
  // Guards para parâmetros inválidos — todas as condições de falha primeiro
  if AId <= 0          then Exit('ID inválido');
  if ACliente.Trim.IsEmpty then Exit('Cliente obrigatório');
  if AQuantidade <= 0  then Exit('Quantidade deve ser > 0');
  if AQuantidade > 999 then Exit('Quantidade máxima: 999');

  // Lógica principal — garantidamente com dados válidos
  Result := Format('Pedido %d para %s: %d unidades', [AId, ACliente, AQuantidade]);
end;

// ---------------------------------------------------------------------------
// TConexao
// ---------------------------------------------------------------------------

constructor TConexao.Create(const AHost: string);
begin inherited Create; FHost := AHost; end;

function TConexao.Conectar: Boolean;
begin
  FConectado := True;  // simulado
  Result     := True;
end;

function TConexao.ExecutarQuery(const ASQL: string): string;
begin
  // Guard: estado inválido
  if not FConectado         then Exit('ERRO: não conectado');
  if ASQL.Trim.IsEmpty      then Exit('ERRO: SQL vazio');
  if Length(ASQL) > 10000   then Exit('ERRO: SQL muito longo');

  // Execução normal — sabemos que estamos conectados e SQL é válido
  Result := Format('[%s] Resultado de: %s', [FHost, ASQL]);
end;

// ---------------------------------------------------------------------------
// Exit em loops
// ---------------------------------------------------------------------------

function EncontrarPrimeiroImpar(const AArray: TArray<Integer>): Integer;
var N: Integer;
begin
  for N in AArray do
    if Odd(N) then Exit(N);  // sai do loop E da função
  Result := -1;  // não encontrado
end;

function ContarAteCondicao(const AArray: TArray<Integer>;
  ALimite: Integer): Integer;
var N: Integer;
begin
  Result := 0;
  for N in AArray do
  begin
    if N > ALimite then Exit;  // para de contar (Result permanece com valor atual)
    Inc(Result);
  end;
end;

// ---------------------------------------------------------------------------
// Result := Default + guards
// ---------------------------------------------------------------------------

function ClassificarIdade(AIdade: Integer): string;
begin
  // Guards ordenadas do mais restritivo para o menos
  if AIdade < 0    then Exit('Inválido');
  if AIdade < 12   then Exit('Criança');
  if AIdade < 18   then Exit('Adolescente');
  if AIdade < 60   then Exit('Adulto');
  if AIdade < 120  then Exit('Idoso');
  Result := 'Centenário';
end;

function CalcularDesconto(AValor: Double; APercentual: Double): Double;
begin
  // Guards de validação + conversão de casos especiais
  if AValor <= 0       then Exit(0);
  if APercentual <= 0  then Exit(AValor);      // sem desconto
  if APercentual >= 100 then Exit(0);           // gratuito
  Result := AValor * (1 - APercentual / 100);
end;

// ---------------------------------------------------------------------------
// USO:
//   Writeln(ValidarEmailSemGuard('abc'));  // Sem @
//   Writeln(ValidarEmailComGuard('abc'));  // Sem @
//   Writeln(ValidarEmailComGuard('a@b.c')); // (vazio = OK)
//
//   Writeln(ProcessarPedido(0, 'X', 1));   // ID inválido
//   Writeln(ProcessarPedido(1, '',  1));   // Cliente obrigatório
//   Writeln(ProcessarPedido(1, 'X', 5));   // Pedido 1 para X: 5 unidades
//
//   var C := TConexao.Create('db.local');
//   Writeln(C.ExecutarQuery('SELECT 1'));   // ERRO: não conectado
//   C.Conectar;
//   Writeln(C.ExecutarQuery('SELECT 1'));   // [db.local] Resultado de: SELECT 1
//   C.Free;
//
//   Writeln(EncontrarPrimeiroImpar([2,4,7,8,9]));  // 7
//   Writeln(ClassificarIdade(25));                  // Adulto
//   Writeln(CalcularDesconto(100, 30):0:2);         // 70.00
// ---------------------------------------------------------------------------

end.
