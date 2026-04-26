unit mock_interface;
///  Demonstra mocking de interfaces com Delphi-Mocks (TMock<I>).
///  Compilavel como unit de projeto DUnitX.
///
///  PRE-REQUISITO: Delphi-Mocks instalado via GetIt ou referenciado no Search Path.
///  GitHub: https://github.com/VSoftTechnologies/Delphi-Mocks
///
///  Tecnicas demonstradas:
///   1. TMock<I>.Create — criar um mock de interface
///   2. Setup.Expect.Once/AtLeastOnce/Never — configurar expectativas
///   3. Setup.WillReturn — configurar valor de retorno
///   4. Setup.WillRaise — configurar excecao a ser lancada
///   5. Mock.Verify — verificar que as expectativas foram satisfeitas
///   6. Injecao de dependencia: passar mock pelo construtor

interface

uses
  System.SysUtils,
  DUnitX.TestFramework
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  , Delphi.Mocks
  {$ENDIF};

type
  // ---------------------------------------------------------------------------
  // Interfaces e classes de dominio (o que seria testado em producao)
  // ---------------------------------------------------------------------------

  /// Interface de repositorio de clientes — dependencia externa
  IClienteRepository = interface
    ['{A1B2C3D4-0010-0000-0000-000000000010}']
    function BuscarPorId(AId: Integer): string;
    procedure Salvar(const ANome: string; AId: Integer);
    function Existe(AId: Integer): Boolean;
  end;

  /// Interface de logger — dependencia externa
  ILogger = interface
    ['{B2C3D4E5-0011-0000-0000-000000000011}']
    procedure Log(const AMensagem: string);
  end;

  /// Servico de negocio que depende do repositorio e do logger
  TClienteServico = class
  private
    FRepository: IClienteRepository;
    FLogger:     ILogger;
  public
    constructor Create(
      const ARepository: IClienteRepository;
      const ALogger:     ILogger);

    function BuscarCliente(AId: Integer): string;
    procedure CriarCliente(const ANome: string; AId: Integer);
  end;

  // ---------------------------------------------------------------------------
  // TestFixture com mocks
  // ---------------------------------------------------------------------------

  [TestFixture]
  [Category('Mocking')]
  TClienteServicoTests = class
  private
    {$IFNDEF DELPHI_MOCKS_AUSENTE}
    FMockRepository: TMock<IClienteRepository>;
    FMockLogger:     TMock<ILogger>;
    {$ENDIF}
    FServico:        TClienteServico;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure BuscarCliente_IdValido_RetornaONomeDoRepositorio;

    [Test]
    procedure BuscarCliente_IdInexistente_LogaMensagemDeErro;

    [Test]
    procedure CriarCliente_NomeValido_SalvaNoRepositorio;

    [Test]
    procedure CriarCliente_RepositorioLancaExcecao_PropagaExcecao;
  end;

implementation

// ---------------------------------------------------------------------------
// TClienteServico — implementacao
// ---------------------------------------------------------------------------

constructor TClienteServico.Create(
  const ARepository: IClienteRepository;
  const ALogger:     ILogger);
begin
  inherited Create;
  FRepository := ARepository;
  FLogger     := ALogger;
end;

function TClienteServico.BuscarCliente(AId: Integer): string;
begin
  if not FRepository.Existe(AId) then
  begin
    FLogger.Log(Format('Cliente %d nao encontrado', [AId]));
    Result := '';
    Exit;
  end;
  Result := FRepository.BuscarPorId(AId);
end;

procedure TClienteServico.CriarCliente(const ANome: string; AId: Integer);
begin
  FLogger.Log(Format('Criando cliente: %s (id=%d)', [ANome, AId]));
  FRepository.Salvar(ANome, AId);
end;

// ---------------------------------------------------------------------------
// TClienteServicoTests — testes com mocks
// ---------------------------------------------------------------------------

procedure TClienteServicoTests.Setup;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  FMockRepository := TMock<IClienteRepository>.Create;
  FMockLogger     := TMock<ILogger>.Create;
  FServico        := TClienteServico.Create(FMockRepository, FMockLogger);
  {$ELSE}
  WriteLn('[Mock] Delphi-Mocks ausente — testes de mock desabilitados.');
  {$ENDIF}
end;

procedure TClienteServicoTests.TearDown;
begin
  FServico.Free;
  FServico := nil;
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  FMockRepository.Free;
  FMockLogger.Free;
  {$ENDIF}
end;

procedure TClienteServicoTests.BuscarCliente_IdValido_RetornaONomeDoRepositorio;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Existe(42) retorna True
  FMockRepository.Setup.WillReturn(True).When.Existe(42);
  // Configurar: BuscarPorId(42) retorna 'Joao'
  FMockRepository.Setup.WillReturn('Joao').When.BuscarPorId(42);
  // Logger nao deve ser chamado neste cenario
  FMockLogger.Setup.Expect.Never.When.Log(It.IsAny<string>);

  var Resultado := FServico.BuscarCliente(42);

  Assert.AreEqual('Joao', Resultado, 'Deve retornar o nome do repositorio');
  FMockRepository.Verify('BuscarPorId deve ter sido chamado uma vez');
  FMockLogger.Verify('Log nao deve ter sido chamado');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TClienteServicoTests.BuscarCliente_IdInexistente_LogaMensagemDeErro;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Existe(99) retorna False
  FMockRepository.Setup.WillReturn(False).When.Existe(99);
  // Logger DEVE ser chamado uma vez
  FMockLogger.Setup.Expect.Once.When.Log(It.IsAny<string>);

  var Resultado := FServico.BuscarCliente(99);

  Assert.AreEqual('', Resultado, 'Deve retornar string vazia para id inexistente');
  FMockLogger.Verify('Logger deve ter sido chamado para registrar o erro');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TClienteServicoTests.CriarCliente_NomeValido_SalvaNoRepositorio;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Logger deve ser chamado ao criar
  FMockLogger.Setup.Expect.Once.When.Log(It.IsAny<string>);
  // Repositorio.Salvar deve ser chamado uma vez
  FMockRepository.Setup.Expect.Once.When.Salvar('Maria', 10);

  FServico.CriarCliente('Maria', 10);

  FMockRepository.Verify('Salvar deve ter sido chamado com os dados corretos');
  FMockLogger.Verify('Log deve ter sido chamado ao criar cliente');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TClienteServicoTests.CriarCliente_RepositorioLancaExcecao_PropagaExcecao;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Salvar lanca excecao
  FMockRepository.Setup
    .WillRaise(EAccessViolation, 'Falha de banco simulada')
    .When.Salvar(It.IsAny<string>, It.IsAny<Integer>);
  FMockLogger.Setup.Expect.Once.When.Log(It.IsAny<string>);

  Assert.WillRaise(
    procedure begin FServico.CriarCliente('Teste', 1) end,
    EAccessViolation,
    'Excecao do repositorio deve ser propagada pelo servico');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

initialization
  TDUnitX.RegisterTestFixture(TClienteServicoTests);

end.
