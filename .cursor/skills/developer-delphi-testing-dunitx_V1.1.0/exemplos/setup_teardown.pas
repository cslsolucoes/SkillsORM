unit setup_teardown;
///  Demonstra a diferenca entre Setup/TearDown por teste vs. SetupFixture/TearDownFixture.
///  Compilavel como unit de projeto DUnitX.
///
///  Regra geral:
///   - [Setup]/[TearDown]        → recursos criados/destruidos POR TESTE (isolamento total)
///   - [SetupFixture]/[TearDownFixture] → recursos criados UMA VEZ para a suite (performance)
///
///  Usar [SetupFixture] apenas para recursos caros e read-only durante os testes
///  (ex.: conexao de banco em modo leitura, arquivo de configuracao grande).
///  NUNCA compartilhar estado mutavel entre testes via [SetupFixture].

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework;

type
  // ---------------------------------------------------------------------------
  // Exemplo 1: Setup/TearDown por teste — isolamento total
  // Cada teste recebe um objeto novo; falhas nao afetam outros testes.
  // ---------------------------------------------------------------------------
  [TestFixture]
  [Category('SetupTearDown')]
  TSetupPorTesteFixture = class
  private
    FLista: TStringList; // criado em cada Setup; destruido em cada TearDown
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure PrimeiroTeste_AdicionarItem_ContagemCorreta;

    [Test]
    procedure SegundoTeste_ListaComeca_Vazia;
  end;

  // ---------------------------------------------------------------------------
  // Exemplo 2: SetupFixture/TearDownFixture — recurso compartilhado read-only
  // Util para recursos caros que nao mudam entre testes (config, fixtures pesadas).
  // ---------------------------------------------------------------------------
  [TestFixture]
  [Category('SetupFixture')]
  TSetupFixtureExemplo = class
  private
    FConfig:    TStringList;   // criado UMA vez em SetupFixture
    FResultado: string;        // estado per-test criado no Setup
  public
    /// Executado UMA VEZ antes de todos os testes desta fixture.
    /// Carregar recursos caros e read-only aqui.
    [SetupFixture]
    procedure SetupFixture;

    /// Executado UMA VEZ apos todos os testes.
    [TearDownFixture]
    procedure TearDownFixture;

    /// Executado antes de CADA teste.
    /// Pode usar FConfig (ja inicializado) para preparar estado mutavel.
    [Setup]
    procedure Setup;

    /// Executado apos cada teste para limpar estado mutavel.
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Teste1_Config_ContemChave;

    [Test]
    procedure Teste2_Config_NaoContemChaveInexistente;

    [Test]
    procedure Teste3_ResultadoMutavel_EhIndependente;
  end;

implementation

// ---------------------------------------------------------------------------
// TSetupPorTesteFixture
// ---------------------------------------------------------------------------

procedure TSetupPorTesteFixture.Setup;
begin
  FLista := TStringList.Create;
  // FLista sempre comeca vazia — garantia de isolamento
end;

procedure TSetupPorTesteFixture.TearDown;
begin
  FLista.Free;
  FLista := nil;
end;

procedure TSetupPorTesteFixture.PrimeiroTeste_AdicionarItem_ContagemCorreta;
begin
  FLista.Add('item-A');
  FLista.Add('item-B');
  Assert.AreEqual(2, FLista.Count,
    'Lista deve conter 2 itens apos adicionar 2');
  Assert.AreEqual('item-A', FLista[0]);
end;

procedure TSetupPorTesteFixture.SegundoTeste_ListaComeca_Vazia;
begin
  // FLista foi criado NOVAMENTE no Setup deste teste — sempre Count = 0
  Assert.AreEqual(0, FLista.Count,
    'Lista deve comecar vazia em cada teste (isolamento via Setup/TearDown)');
end;

// ---------------------------------------------------------------------------
// TSetupFixtureExemplo
// ---------------------------------------------------------------------------

procedure TSetupFixtureExemplo.SetupFixture;
begin
  // Simulacao de recurso caro carregado uma so vez
  FConfig := TStringList.Create;
  FConfig.Add('host=localhost');
  FConfig.Add('port=5432');
  FConfig.Add('db=teste');
  WriteLn('[SetupFixture] Config carregada uma vez.');
end;

procedure TSetupFixtureExemplo.TearDownFixture;
begin
  FConfig.Free;
  FConfig := nil;
  WriteLn('[TearDownFixture] Config liberada.');
end;

procedure TSetupFixtureExemplo.Setup;
begin
  // Estado mutavel por teste — independente de FConfig
  FResultado := '';
end;

procedure TSetupFixtureExemplo.TearDown;
begin
  FResultado := '';
end;

procedure TSetupFixtureExemplo.Teste1_Config_ContemChave;
begin
  Assert.IsTrue(FConfig.IndexOfName('host') >= 0,
    'Config deve conter a chave "host"');
  Assert.AreEqual('localhost', FConfig.Values['host']);
end;

procedure TSetupFixtureExemplo.Teste2_Config_NaoContemChaveInexistente;
begin
  Assert.IsTrue(FConfig.IndexOfName('senha') < 0,
    'Config nao deve conter a chave "senha"');
end;

procedure TSetupFixtureExemplo.Teste3_ResultadoMutavel_EhIndependente;
begin
  // FResultado foi reiniciado no Setup deste teste
  Assert.AreEqual('', FResultado,
    'Estado mutavel deve comecar vazio em cada teste');
  FResultado := 'modificado';
  Assert.AreEqual('modificado', FResultado);
  // No proximo teste, Setup reiniciara FResultado novamente
end;

initialization
  TDUnitX.RegisterTestFixture(TSetupPorTesteFixture);
  TDUnitX.RegisterTestFixture(TSetupFixtureExemplo);

end.
