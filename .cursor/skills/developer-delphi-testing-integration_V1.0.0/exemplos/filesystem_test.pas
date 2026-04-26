program filesystem_test;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra testes de integracao com sistema de arquivos.
///  Compilavel com: dcc32 filesystem_test.pas  ou  dcc64 filesystem_test.pas
///
///  Estrategia de isolamento:
///   - [SetupFixture]: criar pasta temporaria exclusiva para a suite
///   - [Setup]:        limpar conteudo da pasta antes de cada teste
///   - [TearDown]:     verificar e limpar estado residual
///   - [TearDownFixture]: remover pasta temporaria inteira
///
///  Regra: NUNCA usar pasta de producao. Sempre usar TempDir unico por suite.

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console;

// ---------------------------------------------------------------------------
// Servico de exemplo que manipula arquivos
// ---------------------------------------------------------------------------

type
  TRelatorioServico = class
  private
    FDiretorio: string;
  public
    constructor Create(const ADiretorio: string);
    procedure   GerarRelatorio(const ANome, AConteudo: string);
    function    LerRelatorio(const ANome: string): string;
    function    RelatorioExiste(const ANome: string): Boolean;
    procedure   ExcluirRelatorio(const ANome: string);
    function    ListarRelatorios: TArray<string>;
  end;

constructor TRelatorioServico.Create(const ADiretorio: string);
begin
  inherited Create;
  FDiretorio := ADiretorio;
  if not TDirectory.Exists(FDiretorio) then
    TDirectory.CreateDirectory(FDiretorio);
end;

procedure TRelatorioServico.GerarRelatorio(const ANome, AConteudo: string);
begin
  TFile.WriteAllText(TPath.Combine(FDiretorio, ANome + '.txt'), AConteudo, TEncoding.UTF8);
end;

function TRelatorioServico.LerRelatorio(const ANome: string): string;
var
  Caminho: string;
begin
  Caminho := TPath.Combine(FDiretorio, ANome + '.txt');
  if TFile.Exists(Caminho) then
    Result := TFile.ReadAllText(Caminho, TEncoding.UTF8)
  else
    Result := '';
end;

function TRelatorioServico.RelatorioExiste(const ANome: string): Boolean;
begin
  Result := TFile.Exists(TPath.Combine(FDiretorio, ANome + '.txt'));
end;

procedure TRelatorioServico.ExcluirRelatorio(const ANome: string);
var
  Caminho: string;
begin
  Caminho := TPath.Combine(FDiretorio, ANome + '.txt');
  if TFile.Exists(Caminho) then
    TFile.Delete(Caminho);
end;

function TRelatorioServico.ListarRelatorios: TArray<string>;
var
  Arquivos: TArray<string>;
  I:        Integer;
begin
  Arquivos := TDirectory.GetFiles(FDiretorio, '*.txt');
  SetLength(Result, Length(Arquivos));
  for I := 0 to High(Arquivos) do
    Result[I] := TPath.GetFileNameWithoutExtension(Arquivos[I]);
end;

// ---------------------------------------------------------------------------
// TestFixture de integracao com filesystem
// ---------------------------------------------------------------------------

type
  [TestFixture]
  TRelatorioServicoIntegrationTests = class
  private
    FTempDir: string;
    FServico: TRelatorioServico;

    procedure LimparDiretorioTemp;
  public
    [SetupFixture]
    procedure SetupFixture;

    [TearDownFixture]
    procedure TearDownFixture;

    [Setup]
    procedure Setup;    // limpar temp antes de cada teste

    [TearDown]
    procedure TearDown; // verificar limpeza (opcional)

    [Test]
    procedure GerarRelatorio_ConteudoValido_CriaArquivo;

    [Test]
    procedure LerRelatorio_ArquivoExistente_RetornaConteudo;

    [Test]
    procedure LerRelatorio_ArquivoInexistente_RetornaVazio;

    [Test]
    procedure RelatorioExiste_ArquivoCriado_RetornaTrue;

    [Test]
    procedure RelatorioExiste_ArquivoNaoCriado_RetornaFalse;

    [Test]
    procedure ExcluirRelatorio_ArquivoExistente_RemoveDoFS;

    [Test]
    procedure ListarRelatorios_DoisArquivos_RetornaLista2Itens;

    [Test]
    procedure GerarRelatorio_ConteudoUnicode_PreservaCodificacao;
  end;

procedure TRelatorioServicoIntegrationTests.LimparDiretorioTemp;
var
  Arquivo: string;
begin
  for Arquivo in TDirectory.GetFiles(FTempDir) do
    TFile.Delete(Arquivo);
end;

procedure TRelatorioServicoIntegrationTests.SetupFixture;
begin
  // Criar diretorio temporario unico para esta suite (evitar conflito entre runs)
  FTempDir := TPath.Combine(TPath.GetTempPath,
    'delphi_test_' + FormatDateTime('yyyymmddhhnnss', Now));
  TDirectory.CreateDirectory(FTempDir);
  FServico := TRelatorioServico.Create(FTempDir);
  WriteLn(Format('[SetupFixture] Diretorio de teste: %s', [FTempDir]));
end;

procedure TRelatorioServicoIntegrationTests.TearDownFixture;
begin
  FServico.Free;
  if TDirectory.Exists(FTempDir) then
    TDirectory.Delete(FTempDir, True {recursivo});
  WriteLn('[TearDownFixture] Diretorio temporario removido.');
end;

procedure TRelatorioServicoIntegrationTests.Setup;
begin
  // Limpar arquivos antes de cada teste — equivalente ao ROLLBACK de banco
  LimparDiretorioTemp;
end;

procedure TRelatorioServicoIntegrationTests.TearDown;
begin
  // Opcional: verificar que nenhum arquivo residual foi deixado
  // Na pratica, o Setup do proximo teste limpa tudo
end;

procedure TRelatorioServicoIntegrationTests.GerarRelatorio_ConteudoValido_CriaArquivo;
begin
  FServico.GerarRelatorio('relatorio-jan', 'Conteudo do relatorio de janeiro');

  Assert.IsTrue(FServico.RelatorioExiste('relatorio-jan'),
    'Arquivo deve existir apos GerarRelatorio');
end;

procedure TRelatorioServicoIntegrationTests.LerRelatorio_ArquivoExistente_RetornaConteudo;
begin
  FServico.GerarRelatorio('vendas', 'Total: R$ 10.000,00');

  var Conteudo := FServico.LerRelatorio('vendas');

  Assert.AreEqual('Total: R$ 10.000,00', Conteudo,
    'Conteudo lido deve ser identico ao escrito');
end;

procedure TRelatorioServicoIntegrationTests.LerRelatorio_ArquivoInexistente_RetornaVazio;
begin
  var Conteudo := FServico.LerRelatorio('nao-existe');
  Assert.AreEqual('', Conteudo,
    'Arquivo inexistente deve retornar string vazia');
end;

procedure TRelatorioServicoIntegrationTests.RelatorioExiste_ArquivoCriado_RetornaTrue;
begin
  FServico.GerarRelatorio('teste', 'x');
  Assert.IsTrue(FServico.RelatorioExiste('teste'));
end;

procedure TRelatorioServicoIntegrationTests.RelatorioExiste_ArquivoNaoCriado_RetornaFalse;
begin
  Assert.IsFalse(FServico.RelatorioExiste('fantasma'),
    'Arquivo nao criado nao deve existir');
end;

procedure TRelatorioServicoIntegrationTests.ExcluirRelatorio_ArquivoExistente_RemoveDoFS;
begin
  FServico.GerarRelatorio('temp', 'conteudo');
  Assert.IsTrue(FServico.RelatorioExiste('temp'), 'Pre-condicao: arquivo deve existir');

  FServico.ExcluirRelatorio('temp');

  Assert.IsFalse(FServico.RelatorioExiste('temp'),
    'Arquivo deve ter sido removido apos ExcluirRelatorio');
end;

procedure TRelatorioServicoIntegrationTests.ListarRelatorios_DoisArquivos_RetornaLista2Itens;
begin
  FServico.GerarRelatorio('rel-a', 'A');
  FServico.GerarRelatorio('rel-b', 'B');

  var Lista := FServico.ListarRelatorios;

  Assert.AreEqual(2, Length(Lista),
    'Deve retornar exatamente 2 relatorios');
end;

procedure TRelatorioServicoIntegrationTests.GerarRelatorio_ConteudoUnicode_PreservaCodificacao;
var
  Conteudo: string;
begin
  Conteudo := 'Acento: aeiou AEIOU acao notificacao orcamento';
  FServico.GerarRelatorio('unicode', Conteudo);

  var Lido := FServico.LerRelatorio('unicode');

  Assert.AreEqual(Conteudo, Lido,
    'Conteudo com acentos deve ser preservado em UTF-8');
end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.RegisterTestFixture(TRelatorioServicoIntegrationTests);
    Runner  := TDUnitX.CreateRunner;
    Results := Runner.Execute;
    WriteLn;
    if Results.AllPassed then
    begin
      WriteLn('OK -- developer-delphi-testing-integration / filesystem_test');
      Halt(0);
    end
    else
    begin
      WriteLn('FAIL -- alguns testes de filesystem falharam');
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
