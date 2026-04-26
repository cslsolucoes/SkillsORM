unit TEMPLATE_mock_service;
///  TEMPLATE: Mock de servico com verificacao usando Delphi-Mocks.
///  ===============================================================
///  Como usar:
///   1. Substituir ITODO_Servico pela interface real a ser mockada
///   2. Substituir TTODO_Classe pela classe que recebe o mock via construtor
///   3. Implementar os casos de teste marcados com {TODO}
///   4. Incluir esta unit no projeto DUnitX principal
///
///  PRE-REQUISITO: Delphi-Mocks no Search Path.
///  GitHub: https://github.com/VSoftTechnologies/Delphi-Mocks

interface

uses
  System.SysUtils,
  DUnitX.TestFramework
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  , Delphi.Mocks
  {$ENDIF};

type
  // ---------------------------------------------------------------------------
  // {TODO} Definir interface do servico a ser mockado
  // ---------------------------------------------------------------------------

  ITODO_Servico = interface
    ['{F6A7B8C9-0040-0000-0000-000000000040}']
    function  Buscar(const AChave: string): string;
    procedure Processar(const ADado: string);
    function  Validar(const ADado: string): Boolean;
  end;

  // ---------------------------------------------------------------------------
  // {TODO} Definir a classe que usa o servico via injecao de dependencia
  // ---------------------------------------------------------------------------

  TTODO_Classe = class
  private
    FServico: ITODO_Servico;
  public
    constructor Create(const AServico: ITODO_Servico);
    function  ExecutarBusca(const AChave: string): string;
    procedure ExecutarProcessamento(const ADado: string);
  end;

  // ---------------------------------------------------------------------------
  // TestFixture com TMock<I>
  // ---------------------------------------------------------------------------

  [TestFixture]
  [Category('MockService')]
  TTODO_ClasseTests = class
  private
    {$IFNDEF DELPHI_MOCKS_AUSENTE}
    FMock:   TMock<ITODO_Servico>;
    {$ENDIF}
    FClasse: TTODO_Classe;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    // {TODO} Adicionar casos de teste

    [Test]
    procedure ExecutarBusca_ChaveValida_RetornaResultadoDoServico;

    [Test]
    procedure ExecutarBusca_ChaveVazia_NaoChama_Servico;

    [Test]
    procedure ExecutarProcessamento_DadoValido_ChamaProcessarUmaVez;

    [Test]
    procedure ExecutarProcessamento_ServicoValidaFalso_NaoChama_Processar;
  end;

implementation

// ---------------------------------------------------------------------------
// TTODO_Classe — implementacao
// ---------------------------------------------------------------------------

constructor TTODO_Classe.Create(const AServico: ITODO_Servico);
begin
  inherited Create;
  FServico := AServico;
end;

function TTODO_Classe.ExecutarBusca(const AChave: string): string;
begin
  if AChave = '' then
  begin
    Result := '';
    Exit;
  end;
  Result := FServico.Buscar(AChave);
end;

procedure TTODO_Classe.ExecutarProcessamento(const ADado: string);
begin
  if FServico.Validar(ADado) then
    FServico.Processar(ADado);
end;

// ---------------------------------------------------------------------------
// TTODO_ClasseTests
// ---------------------------------------------------------------------------

procedure TTODO_ClasseTests.Setup;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  FMock   := TMock<ITODO_Servico>.Create;
  FClasse := TTODO_Classe.Create(FMock);
  {$ELSE}
  FClasse := TTODO_Classe.Create(nil); // sem mock — testes serao ignorados
  {$ENDIF}
end;

procedure TTODO_ClasseTests.TearDown;
begin
  FClasse.Free;
  FClasse := nil;
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  FMock.Free;
  {$ENDIF}
end;

procedure TTODO_ClasseTests.ExecutarBusca_ChaveValida_RetornaResultadoDoServico;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Buscar('chave') retorna 'valor-esperado'
  FMock.Setup.WillReturn('valor-esperado').When.Buscar('chave');
  // Expectativa: deve ser chamado exatamente uma vez
  FMock.Setup.Expect.Once.When.Buscar('chave');

  var Resultado := FClasse.ExecutarBusca('chave');

  Assert.AreEqual('valor-esperado', Resultado,
    'Resultado deve ser o retorno do servico mockado');
  FMock.Verify('Buscar("chave") deve ter sido chamado uma vez');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TTODO_ClasseTests.ExecutarBusca_ChaveVazia_NaoChama_Servico;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Servico.Buscar nunca deve ser chamado
  FMock.Setup.Expect.Never.When.Buscar(It.IsAny<string>);

  var Resultado := FClasse.ExecutarBusca('');

  Assert.AreEqual('', Resultado,
    'Chave vazia deve retornar string vazia sem chamar o servico');
  FMock.Verify('Buscar nao deve ter sido chamado com chave vazia');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TTODO_ClasseTests.ExecutarProcessamento_DadoValido_ChamaProcessarUmaVez;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Validar retorna True → Processar deve ser chamado
  FMock.Setup.WillReturn(True).When.Validar('dado-valido');
  FMock.Setup.Expect.Once.When.Processar('dado-valido');

  FClasse.ExecutarProcessamento('dado-valido');

  FMock.Verify('Processar deve ter sido chamado uma vez para dado valido');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

procedure TTODO_ClasseTests.ExecutarProcessamento_ServicoValidaFalso_NaoChama_Processar;
begin
  {$IFNDEF DELPHI_MOCKS_AUSENTE}
  // Configurar: Validar retorna False → Processar NAO deve ser chamado
  FMock.Setup.WillReturn(False).When.Validar(It.IsAny<string>);
  FMock.Setup.Expect.Never.When.Processar(It.IsAny<string>);

  FClasse.ExecutarProcessamento('dado-invalido');

  FMock.Verify('Processar nao deve ser chamado quando validacao falha');
  {$ELSE}
  Assert.Ignore('Delphi-Mocks ausente');
  {$ENDIF}
end;

initialization
  TDUnitX.RegisterTestFixture(TTODO_ClasseTests);

end.
