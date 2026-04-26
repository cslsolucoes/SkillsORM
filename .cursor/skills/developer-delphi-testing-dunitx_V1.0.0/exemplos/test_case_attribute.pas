unit test_case_attribute;
///  Demonstra o atributo [TestCase] para testes parametrizados em DUnitX.
///  Compilavel como unit de projeto DUnitX.
///
///  [TestCase('nome_do_caso', 'param1,param2,...')]
///  O nome aparece no relatorio de testes; os parametros sao passados
///  como string CSV e convertidos automaticamente para os tipos do metodo.

interface

uses
  System.SysUtils,
  DUnitX.TestFramework;

type
  /// Funcao de negocio de exemplo: validar CPF (simplificado para demo)
  function ValidarCPF(const ACPF: string): Boolean;

  /// Calcular desconto por categoria de cliente
  function CalcularDesconto(const ACategoria: string; AValor: Double): Double;

  [TestFixture]
  [Category('TestCase')]
  TTestCaseDemo = class
  public
    // -----------------------------------------------------------------------
    // Testes parametrizados com [TestCase]
    // Cada [TestCase] gera uma execucao separada do metodo.
    // O nome do caso aparece no relatorio como 'NomeMetodo(nome_do_caso)'.
    // -----------------------------------------------------------------------

    [Test]
    [TestCase('CPF valido classico',    '111.444.777-35,True')]
    [TestCase('CPF invalido digito',    '111.444.777-00,False')]
    [TestCase('CPF vazio',              ',False')]
    [TestCase('CPF apenas numeros',     '11144477735,True')]
    [TestCase('CPF com zeros',          '000.000.000-00,False')]
    procedure ValidarCPF_Parametrizado(const ACPF: string; AEsperado: Boolean);

    [Test]
    [TestCase('Cliente ouro 10%',    'ouro,100.0,90.0')]
    [TestCase('Cliente prata 5%',    'prata,100.0,95.0')]
    [TestCase('Cliente padrao 0%',   'padrao,100.0,100.0')]
    [TestCase('Cliente invalido',    'desconhecido,100.0,100.0')]
    [TestCase('Valor zero',          'ouro,0.0,0.0')]
    procedure CalcularDesconto_Parametrizado(
      const ACategoria: string;
      AValor:           Double;
      AEsperado:        Double);

    // -----------------------------------------------------------------------
    // Teste de valores de borda (edge cases) — boa pratica com [TestCase]
    // -----------------------------------------------------------------------
    [Test]
    [TestCase('Limite inferior',  '0,0')]
    [TestCase('Valor negativo',   '-1,-1')]
    [TestCase('Valor maximo',     '2147483647,2147483647')]
    [TestCase('Um',               '1,1')]
    procedure Identidade_Parametrizada(AEntrada: Integer; AEsperado: Integer);
  end;

implementation

// ---------------------------------------------------------------------------
// Implementacoes de exemplo
// ---------------------------------------------------------------------------

function ValidarCPF(const ACPF: string): Boolean;
var
  Numeros: string;
  I, Soma, Resto: Integer;
  D1, D2: Integer;
begin
  Result := False;
  if ACPF = '' then Exit;

  // Extrair apenas digitos
  Numeros := '';
  for I := 1 to Length(ACPF) do
    if ACPF[I].IsDigit then
      Numeros := Numeros + ACPF[I];

  if Length(Numeros) <> 11 then Exit;

  // Verificar se todos os digitos sao iguais (invalido)
  var Todos := True;
  for I := 2 to 11 do
    if Numeros[I] <> Numeros[1] then begin Todos := False; Break; end;
  if Todos then Exit;

  // Calcular primeiro digito verificador
  Soma := 0;
  for I := 1 to 9 do
    Soma := Soma + StrToInt(Numeros[I]) * (11 - I + 1);
  Resto := Soma mod 11;
  if Resto < 2 then D1 := 0 else D1 := 11 - Resto;
  if D1 <> StrToInt(Numeros[10]) then Exit;

  // Calcular segundo digito verificador
  Soma := 0;
  for I := 1 to 10 do
    Soma := Soma + StrToInt(Numeros[I]) * (12 - I + 1);
  Resto := Soma mod 11;
  if Resto < 2 then D2 := 0 else D2 := 11 - Resto;
  if D2 <> StrToInt(Numeros[11]) then Exit;

  Result := True;
end;

function CalcularDesconto(const ACategoria: string; AValor: Double): Double;
begin
  if ACategoria = 'ouro'  then Result := AValor * 0.90
  else if ACategoria = 'prata' then Result := AValor * 0.95
  else Result := AValor; // sem desconto
end;

// ---------------------------------------------------------------------------
// TTestCaseDemo — implementacao dos testes parametrizados
// ---------------------------------------------------------------------------

procedure TTestCaseDemo.ValidarCPF_Parametrizado(
  const ACPF: string; AEsperado: Boolean);
begin
  var Obtido := ValidarCPF(ACPF);
  Assert.AreEqual(AEsperado, Obtido,
    Format('ValidarCPF("%s"): esperado %s, obtido %s',
      [ACPF,
       BoolToStr(AEsperado, True),
       BoolToStr(Obtido, True)]));
end;

procedure TTestCaseDemo.CalcularDesconto_Parametrizado(
  const ACategoria: string;
  AValor:           Double;
  AEsperado:        Double);
begin
  var Obtido := CalcularDesconto(ACategoria, AValor);
  Assert.AreEqual(AEsperado, Obtido, 0.001,
    Format('CalcularDesconto("%s", %.2f): esperado %.2f, obtido %.2f',
      [ACategoria, AValor, AEsperado, Obtido]));
end;

procedure TTestCaseDemo.Identidade_Parametrizada(
  AEntrada: Integer; AEsperado: Integer);
begin
  Assert.AreEqual(AEsperado, AEntrada,
    Format('Identidade(%d) deve retornar %d', [AEntrada, AEsperado]));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCaseDemo);

end.
