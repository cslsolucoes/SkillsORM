program TEMPLATE_test_fixture;
{$APPTYPE CONSOLE}
{$R *.res}
///  TEMPLATE: TestFixture DUnitX completo com Setup, TearDown e TestCase.
///  ========================================================================
///  Como usar:
///   1. Renomear o arquivo para NomeModulo_tests.pas (ou criar como unit separada)
///   2. Substituir TODO_Classe pela classe a ser testada
///   3. Substituir TODO_Interface pela interface da dependencia
///   4. Implementar os metodos marcados com {TODO}
///   5. Compilar como projeto DUnitX: dcc32 TEMPLATE_test_fixture.pas
///
///  Compilavel sem modificacoes com: dcc32 TEMPLATE_test_fixture.pas

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console;

// ---------------------------------------------------------------------------
// {TODO} Substituir por interfaces e classes reais do projeto
// ---------------------------------------------------------------------------

type
  /// Interface de dependencia externa — deve ser mockada ou stubada nos testes
  ITODO_Dependencia = interface
    ['{E5F6A7B8-0030-0000-0000-000000000030}']
    function BuscarDado(AId: Integer): string;
    procedure Salvar(const ADado: string);
  end;

  /// Stub simples da dependencia para uso nos testes
  TTODO_DependenciaStub = class(TInterfacedObject, ITODO_Dependencia)
  private
    FDados:           TStringList;
    FUltimoSalvo:     string;
    FTotalChamadasBuscar: Integer;
    FTotalChamadasSalvar: Integer;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   AdicionarDado(AId: Integer; const AValor: string);
    function    BuscarDado(AId: Integer): string;
    procedure   Salvar(const ADado: string);
    // Metodos de verificacao (sem framework de mock externo)
    function    UltimoSalvo: string;
    function    TotalChamadasBuscar: Integer;
    function    TotalChamadasSalvar: Integer;
  end;

  /// {TODO} Substituir pela classe real a ser testada
  TTODO_Servico = class
  private
    FDep: ITODO_Dependencia;
  public
    constructor Create(const ADep: ITODO_Dependencia);
    function  ProcessarDado(AId: Integer): string;   // {TODO} implementar
    procedure GravarDado(const ADado: string);        // {TODO} implementar
  end;

// ---------------------------------------------------------------------------
// TestFixture completo
// ---------------------------------------------------------------------------

  [TestFixture]
  TTODO_ServicoTests = class
  private
    FDepStub: TTODO_DependenciaStub;
    FServico: TTODO_Servico;
  public
    // Ciclo de vida por TESTE (isolamento total)
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // -----------------------------------------------------------------------
    // Testes — convencao: Contexto_Acao_ResultadoEsperado
    // -----------------------------------------------------------------------

    [Test]
    procedure ProcessarDado_IdValido_RetornaDadoDoRepositorio;

    [Test]
    procedure ProcessarDado_IdInexistente_RetornaStringVazia;

    [Test]
    procedure GravarDado_DadoValido_ChamaSalvarUmaVez;

    [Test]
    procedure GravarDado_DadoVazio_NaoChama_Salvar; // {TODO} ajustar regra

    // Teste parametrizado — cobrir valores de borda
    [Test]
    [TestCase('ID zero',       '0,')]
    [TestCase('ID um',         '1,dado-1')]
    [TestCase('ID grande',     '9999,dado-9999')]
    procedure ProcessarDado_IdsParametrizados(AId: Integer; AEsperado: string);

    // Teste de excecao
    [Test]
    procedure GravarDado_DependenciaLancaExcecao_PropagaExcecao;

    // Teste ignorado com justificativa
    [Test]
    [Ignore('Regra de negocio pendente — issue #TODO')]
    procedure ProcessarDado_ComFiltro_AplicaFiltro;
  end;

// ---------------------------------------------------------------------------
// Implementacoes
// ---------------------------------------------------------------------------

constructor TTODO_DependenciaStub.Create;
begin
  inherited Create;
  FDados := TStringList.Create;
end;

destructor TTODO_DependenciaStub.Destroy;
begin
  FDados.Free;
  inherited;
end;

procedure TTODO_DependenciaStub.AdicionarDado(AId: Integer; const AValor: string);
begin
  FDados.Values[IntToStr(AId)] := AValor;
end;

function TTODO_DependenciaStub.BuscarDado(AId: Integer): string;
begin
  Inc(FTotalChamadasBuscar);
  Result := FDados.Values[IntToStr(AId)]; // '' se nao existir
end;

procedure TTODO_DependenciaStub.Salvar(const ADado: string);
begin
  Inc(FTotalChamadasSalvar);
  FUltimoSalvo := ADado;
end;

function TTODO_DependenciaStub.UltimoSalvo: string;
begin Result := FUltimoSalvo; end;

function TTODO_DependenciaStub.TotalChamadasBuscar: Integer;
begin Result := FTotalChamadasBuscar; end;

function TTODO_DependenciaStub.TotalChamadasSalvar: Integer;
begin Result := FTotalChamadasSalvar; end;

// TTODO_Servico

constructor TTODO_Servico.Create(const ADep: ITODO_Dependencia);
begin
  inherited Create;
  FDep := ADep;
end;

function TTODO_Servico.ProcessarDado(AId: Integer): string;
begin
  // {TODO} implementar logica real
  Result := FDep.BuscarDado(AId);
end;

procedure TTODO_Servico.GravarDado(const ADado: string);
begin
  // {TODO} implementar logica real
  if ADado = '' then Exit;
  FDep.Salvar(ADado);
end;

// TTODO_ServicoTests

procedure TTODO_ServicoTests.Setup;
begin
  FDepStub := TTODO_DependenciaStub.Create;
  FDepStub.AdicionarDado(1,    'dado-1');
  FDepStub.AdicionarDado(9999, 'dado-9999');
  FServico := TTODO_Servico.Create(FDepStub);
end;

procedure TTODO_ServicoTests.TearDown;
begin
  FServico.Free;
  FServico := nil;
  FDepStub := nil; // ref-count → Free automatico
end;

procedure TTODO_ServicoTests.ProcessarDado_IdValido_RetornaDadoDoRepositorio;
begin
  var Resultado := FServico.ProcessarDado(1);
  Assert.AreEqual('dado-1', Resultado,
    'ProcessarDado(1) deve retornar o dado do stub');
end;

procedure TTODO_ServicoTests.ProcessarDado_IdInexistente_RetornaStringVazia;
begin
  var Resultado := FServico.ProcessarDado(0);
  Assert.AreEqual('', Resultado,
    'ID inexistente deve retornar string vazia');
end;

procedure TTODO_ServicoTests.GravarDado_DadoValido_ChamaSalvarUmaVez;
begin
  FServico.GravarDado('novo-dado');
  Assert.AreEqual(1, FDepStub.TotalChamadasSalvar,
    'Salvar deve ter sido chamado exatamente uma vez');
  Assert.AreEqual('novo-dado', FDepStub.UltimoSalvo,
    'O dado passado deve ser o que foi salvo');
end;

procedure TTODO_ServicoTests.GravarDado_DadoVazio_NaoChama_Salvar;
begin
  FServico.GravarDado('');
  Assert.AreEqual(0, FDepStub.TotalChamadasSalvar,
    'Dado vazio nao deve chamar Salvar no repositorio');
end;

procedure TTODO_ServicoTests.ProcessarDado_IdsParametrizados(
  AId: Integer; AEsperado: string);
begin
  var Resultado := FServico.ProcessarDado(AId);
  Assert.AreEqual(AEsperado, Resultado,
    Format('ProcessarDado(%d): esperado "%s", obtido "%s"',
      [AId, AEsperado, Resultado]));
end;

procedure TTODO_ServicoTests.GravarDado_DependenciaLancaExcecao_PropagaExcecao;
begin
  // {TODO} configurar stub para lancar excecao ou usar Delphi-Mocks
  // Exemplo sem Delphi-Mocks: testar via chamada direta com mock que raise
  Assert.WillRaise(
    procedure
    begin
      raise EInvalidOperation.Create('Banco indisponivel');
    end,
    EInvalidOperation,
    'Excecao do repositorio deve ser propagada');
end;

procedure TTODO_ServicoTests.ProcessarDado_ComFiltro_AplicaFiltro;
begin
  Assert.Fail('Implementar apos definicao da regra');
end;

// ---------------------------------------------------------------------------
// Main — executar a suite e retornar exit code
// ---------------------------------------------------------------------------
var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.RegisterTestFixture(TTODO_ServicoTests);
    Runner  := TDUnitX.CreateRunner;
    Results := Runner.Execute;
    if Results.AllPassed then
    begin
      WriteLn('OK -- TEMPLATE_test_fixture');
      Halt(0);
    end
    else
    begin
      WriteLn('FAIL -- alguns testes falharam');
      Halt(1);
    end;
  except
    on E: Exception do
    begin
      WriteLn('ERRO: ' + E.Message);
      Halt(2);
    end;
  end;
end.
