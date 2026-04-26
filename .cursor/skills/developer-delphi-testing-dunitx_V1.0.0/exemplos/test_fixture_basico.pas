unit test_fixture_basico;
///  Demonstra a estrutura minima de um TestFixture DUnitX.
///  Compilavel com: dcc32 test_fixture_basico.pas (como parte de um projeto DUnitX)
///
///  PRE-REQUISITO: DUnitX instalado via GetIt ou referenciado no Search Path.
///
///  Este arquivo e uma UNIT (nao program) para ser incluida num projeto
///  de testes. Veja TEMPLATE_test_fixture.pas para o program completo.

interface

uses
  DUnitX.TestFramework;

type
  /// Classe de negocio de exemplo que sera testada.
  TCliente = class
  private
    FNome:   string;
    FIdade:  Integer;
    FAtivo:  Boolean;
  public
    constructor Create(const ANome: string; AIdade: Integer);
    function    NomeCompleto: string;
    function    EhMaiorDeIdade: Boolean;
    procedure   Desativar;
    property Nome:  string  read FNome;
    property Idade: Integer read FIdade;
    property Ativo: Boolean read FAtivo;
  end;

  /// TestFixture: [TestFixture] marca a classe como suite de testes DUnitX.
  /// Convencao de nome: T<Classe>Tests ou T<Classe>Fixture.
  [TestFixture]
  TClienteTests = class
  private
    // Instancia criada no Setup e destruida no TearDown de cada teste
    FCliente: TCliente;
  public
    /// [Setup] e executado ANTES de CADA teste individual.
    /// Usar para criar o objeto e seus colaboradores em estado limpo.
    [Setup]
    procedure Setup;

    /// [TearDown] e executado APOS cada teste, mesmo se o teste falhar.
    /// Usar para liberar recursos; garantir que nao ha leaks.
    [TearDown]
    procedure TearDown;

    // -----------------------------------------------------------------------
    // Testes — [Test] marca o metodo como caso de teste.
    // Convencao de nome: Dado_Quando_Entao ou Contexto_Comportamento.
    // -----------------------------------------------------------------------

    [Test]
    procedure NomeCompleto_ClienteValido_RetornaONome;

    [Test]
    procedure EhMaiorDeIdade_Idade18_RetornaTrue;

    [Test]
    procedure EhMaiorDeIdade_Idade17_RetornaFalse;

    [Test]
    procedure Desativar_ClienteAtivo_DefineAtivoFalse;

    [Test]
    procedure Create_NomeVazio_NaoLancaExcecao;

    [Test]
    [Ignore('Regra de negocio pendente de definicao — issue #123')]
    procedure NomeCompleto_ComSobrenome_RetornaFormatoCompleto;
  end;

implementation

// ---------------------------------------------------------------------------
// TCliente — implementacao
// ---------------------------------------------------------------------------

constructor TCliente.Create(const ANome: string; AIdade: Integer);
begin
  inherited Create;
  FNome  := ANome;
  FIdade := AIdade;
  FAtivo := True;
end;

function TCliente.NomeCompleto: string;
begin
  Result := FNome;
end;

function TCliente.EhMaiorDeIdade: Boolean;
begin
  Result := FIdade >= 18;
end;

procedure TCliente.Desativar;
begin
  FAtivo := False;
end;

// ---------------------------------------------------------------------------
// TClienteTests — implementacao da fixture
// ---------------------------------------------------------------------------

procedure TClienteTests.Setup;
begin
  FCliente := TCliente.Create('Joao Silva', 25);
end;

procedure TClienteTests.TearDown;
begin
  FCliente.Free;
  FCliente := nil;
end;

procedure TClienteTests.NomeCompleto_ClienteValido_RetornaONome;
begin
  Assert.AreEqual('Joao Silva', FCliente.NomeCompleto,
    'NomeCompleto deve retornar o nome informado no construtor');
end;

procedure TClienteTests.EhMaiorDeIdade_Idade18_RetornaTrue;
var
  C: TCliente;
begin
  C := TCliente.Create('Maria', 18);
  try
    Assert.IsTrue(C.EhMaiorDeIdade,
      'Cliente com 18 anos deve ser considerado maior de idade');
  finally
    C.Free;
  end;
end;

procedure TClienteTests.EhMaiorDeIdade_Idade17_RetornaFalse;
var
  C: TCliente;
begin
  C := TCliente.Create('Pedro', 17);
  try
    Assert.IsFalse(C.EhMaiorDeIdade,
      'Cliente com 17 anos nao deve ser maior de idade');
  finally
    C.Free;
  end;
end;

procedure TClienteTests.Desativar_ClienteAtivo_DefineAtivoFalse;
begin
  Assert.IsTrue(FCliente.Ativo, 'Cliente recem criado deve estar ativo');
  FCliente.Desativar;
  Assert.IsFalse(FCliente.Ativo,
    'Apos Desativar, propriedade Ativo deve ser False');
end;

procedure TClienteTests.Create_NomeVazio_NaoLancaExcecao;
begin
  Assert.WillNotRaise(
    procedure
    var C: TCliente;
    begin
      C := TCliente.Create('', 0);
      C.Free;
    end,
    'Criar cliente com nome vazio nao deve lancar excecao');
end;

procedure TClienteTests.NomeCompleto_ComSobrenome_RetornaFormatoCompleto;
begin
  // {TODO} implementar quando regra for definida
  Assert.Fail('Teste pendente de implementacao');
end;

initialization
  // Registrar esta fixture na suite global do DUnitX
  TDUnitX.RegisterTestFixture(TClienteTests);

end.
