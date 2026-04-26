program TEMPLATE_integration_db;
{$APPTYPE CONSOLE}
{$R *.res}
///  TEMPLATE: Integration Test com banco de dados real (SQLite/FireDAC) + ROLLBACK.
///  ==============================================================================
///  Como usar:
///   1. Substituir TODO_Repositorio pelo repositorio real a testar
///   2. Substituir o DDL na secao SetupFixture pelo schema real
///   3. Implementar os metodos de fixture de dados (CriarEntidade...)
///   4. Escrever os casos de teste na secao [Test]
///   5. Compilar: dcc32 TEMPLATE_integration_db.pas
///
///  PRE-REQUISITO: FireDAC com driver SQLite instalado e no Search Path.
///
///  Compilavel sem modificacoes: dcc32 TEMPLATE_integration_db.pas

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Comp.Client,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console;

// ---------------------------------------------------------------------------
// {TODO} Record de entidade do dominio
// ---------------------------------------------------------------------------

type
  TTODO_Entidade = record
    Id:    Integer;
    Nome:  string;
    Valor: Double;
    Ativo: Boolean;
  end;

  // ---------------------------------------------------------------------------
  // {TODO} Repositorio a ser testado
  // ---------------------------------------------------------------------------

  TTODO_Repositorio = class
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    procedure Salvar(const AEntidade: TTODO_Entidade);
    function  BuscarPorId(AId: Integer): TTODO_Entidade;
    function  Contar: Integer;
    function  Existe(AId: Integer): Boolean;
  end;

  // ---------------------------------------------------------------------------
  // Fixture de dados — builder de entidades de teste
  // ---------------------------------------------------------------------------

  TTODO_EntidadeBuilder = class
  private
    FId:    Integer;
    FNome:  string;
    FValor: Double;
    FAtivo: Boolean;
  public
    constructor Create;
    function ComId(AId: Integer): TTODO_EntidadeBuilder;
    function ComNome(const ANome: string): TTODO_EntidadeBuilder;
    function ComValor(AValor: Double): TTODO_EntidadeBuilder;
    function Inativa: TTODO_EntidadeBuilder;
    function Build: TTODO_Entidade;
    class function Padrao: TTODO_Entidade; // factory com valores default
  end;

  // ---------------------------------------------------------------------------
  // TestFixture de integracao
  // ---------------------------------------------------------------------------

  [TestFixture]
  TTODO_RepositorioIntegrationTests = class
  private
    FConn: TFDConnection;
    FRepo: TTODO_Repositorio;

    // Metodo auxiliar de fixture de dados — use em vez de hardcodar nos testes
    function CriarEntidade(AId: Integer;
      const ANome: string = 'Entidade Padrao';
      AValor: Double = 0.0): TTODO_Entidade;
  public
    [SetupFixture]
    procedure SetupFixture;    // Conectar; criar schema (UMA vez)

    [TearDownFixture]
    procedure TearDownFixture; // Fechar conexao

    [Setup]
    procedure Setup;           // BEGIN TRANSACTION (cada teste)

    [TearDown]
    procedure TearDown;        // ROLLBACK — SEMPRE (cada teste)

    // -----------------------------------------------------------------------
    // Testes de CRUD
    // -----------------------------------------------------------------------

    [Test]
    procedure Salvar_EntidadeValida_PersisteDoBanco;

    [Test]
    procedure BuscarPorId_IdExistente_RetornaEntidadeCorreta;

    [Test]
    procedure BuscarPorId_IdInexistente_RetornaEntidadeVazia;

    [Test]
    procedure Contar_DuasInsercoes_Retorna2;

    [Test]
    procedure Existe_IdExistente_RetornaTrue;

    [Test]
    procedure Existe_IdInexistente_RetornaFalse;

    // Teste de isolamento — garante que ROLLBACK funciona
    [Test]
    procedure Isolamento_TabelaDeveEstarVaziaEmCadaTeste;

    // {TODO} Adicionar casos de teste especificos do modulo
    // [Test]
    // procedure Regra_Negocio_Especifica_DoModulo;
  end;

// ---------------------------------------------------------------------------
// Implementacoes
// ---------------------------------------------------------------------------

constructor TTODO_Repositorio.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

procedure TTODO_Repositorio.Salvar(const AEntidade: TTODO_Entidade);
begin
  FConn.ExecSQL(
    'INSERT INTO entidades (id, nome, valor, ativo) VALUES (:id, :nome, :valor, :ativo)',
    [AEntidade.Id, AEntidade.Nome, AEntidade.Valor, Ord(AEntidade.Ativo)]);
end;

function TTODO_Repositorio.BuscarPorId(AId: Integer): TTODO_Entidade;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT id, nome, valor, ativo FROM entidades WHERE id=:id';
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    if Q.IsEmpty then
    begin
      Result.Id    := 0;
      Result.Nome  := '';
      Result.Valor := 0;
      Result.Ativo := False;
    end
    else
    begin
      Result.Id    := Q.FieldByName('id').AsInteger;
      Result.Nome  := Q.FieldByName('nome').AsString;
      Result.Valor := Q.FieldByName('valor').AsFloat;
      Result.Ativo := Q.FieldByName('ativo').AsInteger = 1;
    end;
  finally
    Q.Free;
  end;
end;

function TTODO_Repositorio.Contar: Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM entidades';
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

function TTODO_Repositorio.Existe(AId: Integer): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM entidades WHERE id=:id';
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    Result := Q.Fields[0].AsInteger > 0;
  finally
    Q.Free;
  end;
end;

// TTODO_EntidadeBuilder

constructor TTODO_EntidadeBuilder.Create;
begin
  inherited Create;
  FId    := 1;
  FNome  := 'Entidade Padrao';
  FValor := 0.0;
  FAtivo := True;
end;

function TTODO_EntidadeBuilder.ComId(AId: Integer): TTODO_EntidadeBuilder;
begin FId := AId; Result := Self; end;

function TTODO_EntidadeBuilder.ComNome(const ANome: string): TTODO_EntidadeBuilder;
begin FNome := ANome; Result := Self; end;

function TTODO_EntidadeBuilder.ComValor(AValor: Double): TTODO_EntidadeBuilder;
begin FValor := AValor; Result := Self; end;

function TTODO_EntidadeBuilder.Inativa: TTODO_EntidadeBuilder;
begin FAtivo := False; Result := Self; end;

function TTODO_EntidadeBuilder.Build: TTODO_Entidade;
begin
  Result.Id    := FId;
  Result.Nome  := FNome;
  Result.Valor := FValor;
  Result.Ativo := FAtivo;
end;

class function TTODO_EntidadeBuilder.Padrao: TTODO_Entidade;
begin
  Result := TTODO_EntidadeBuilder.Create.Build;
end;

// TTODO_RepositorioIntegrationTests

function TTODO_RepositorioIntegrationTests.CriarEntidade(
  AId: Integer; const ANome: string; AValor: Double): TTODO_Entidade;
begin
  Result := TTODO_EntidadeBuilder.Create
    .ComId(AId)
    .ComNome(ANome)
    .ComValor(AValor)
    .Build;
end;

procedure TTODO_RepositorioIntegrationTests.SetupFixture;
begin
  FConn := TFDConnection.Create(nil);
  FConn.DriverName := 'SQLite';
  // {TODO} trocar por arquivo para depuracao: 'test.db'
  FConn.Params.Database := ':memory:';
  FConn.Connected := True;

  // {TODO} Substituir pelo DDL real das tabelas do modulo
  FConn.ExecSQL(
    'CREATE TABLE entidades (' +
    '  id    INTEGER PRIMARY KEY,' +
    '  nome  TEXT    NOT NULL,' +
    '  valor REAL    NOT NULL DEFAULT 0,' +
    '  ativo INTEGER NOT NULL DEFAULT 1' +
    ')');

  FRepo := TTODO_Repositorio.Create(FConn);
  WriteLn('[SetupFixture] Banco de teste inicializado (SQLite in-memory).');
end;

procedure TTODO_RepositorioIntegrationTests.TearDownFixture;
begin
  FRepo.Free;
  FConn.Free;
  WriteLn('[TearDownFixture] Banco de teste encerrado.');
end;

procedure TTODO_RepositorioIntegrationTests.Setup;
begin
  FConn.StartTransaction; // BEGIN
end;

procedure TTODO_RepositorioIntegrationTests.TearDown;
begin
  FConn.Rollback; // SEMPRE ROLLBACK — nunca Commit aqui
end;

procedure TTODO_RepositorioIntegrationTests.Salvar_EntidadeValida_PersisteDoBanco;
begin
  FRepo.Salvar(CriarEntidade(1, 'Entidade A', 100.0));
  Assert.IsTrue(FRepo.Existe(1), 'Entidade deve existir apos Salvar');
end;

procedure TTODO_RepositorioIntegrationTests.BuscarPorId_IdExistente_RetornaEntidadeCorreta;
var
  E, Obtida: TTODO_Entidade;
begin
  E := CriarEntidade(2, 'Entidade B', 250.75);
  FRepo.Salvar(E);

  Obtida := FRepo.BuscarPorId(2);

  Assert.AreEqual(2,         Obtida.Id,    'ID deve corresponder');
  Assert.AreEqual('Entidade B', Obtida.Nome, 'Nome deve corresponder');
  Assert.AreEqual(250.75,    Obtida.Valor, 0.001, 'Valor deve corresponder');
  Assert.IsTrue(Obtida.Ativo, 'Ativo deve ser True');
end;

procedure TTODO_RepositorioIntegrationTests.BuscarPorId_IdInexistente_RetornaEntidadeVazia;
var
  Obtida: TTODO_Entidade;
begin
  Obtida := FRepo.BuscarPorId(9999);
  Assert.AreEqual(0, Obtida.Id, 'ID deve ser 0 para entidade inexistente');
  Assert.AreEqual('', Obtida.Nome);
end;

procedure TTODO_RepositorioIntegrationTests.Contar_DuasInsercoes_Retorna2;
begin
  FRepo.Salvar(CriarEntidade(3, 'A'));
  FRepo.Salvar(CriarEntidade(4, 'B'));
  Assert.AreEqual(2, FRepo.Contar, 'Deve haver 2 registros apos 2 insercoes');
end;

procedure TTODO_RepositorioIntegrationTests.Existe_IdExistente_RetornaTrue;
begin
  FRepo.Salvar(CriarEntidade(5));
  Assert.IsTrue(FRepo.Existe(5));
end;

procedure TTODO_RepositorioIntegrationTests.Existe_IdInexistente_RetornaFalse;
begin
  Assert.IsFalse(FRepo.Existe(7777));
end;

procedure TTODO_RepositorioIntegrationTests.Isolamento_TabelaDeveEstarVaziaEmCadaTeste;
begin
  Assert.AreEqual(0, FRepo.Contar,
    'ROLLBACK deve garantir tabela vazia no inicio de cada teste');
end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.RegisterTestFixture(TTODO_RepositorioIntegrationTests);
    Runner  := TDUnitX.CreateRunner;
    Results := Runner.Execute;
    WriteLn;
    if Results.AllPassed then
    begin
      WriteLn('OK -- TEMPLATE_integration_db');
      Halt(0);
    end
    else
    begin
      WriteLn('FAIL -- testes de integracao falharam');
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
