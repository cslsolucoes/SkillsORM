program db_real_test;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra testes de integracao com banco de dados real (SQLite via FireDAC).
///  Compilavel com: dcc32 db_real_test.pas  ou  dcc64 db_real_test.pas
///
///  PRE-REQUISITO: FireDAC com driver SQLite no Search Path.
///  Instalar via GetIt: "FireDAC SQLite" ou incluir no .dproj.
///
///  Estrategia de isolamento:
///   - [SetupFixture]: conectar ao SQLite in-memory; criar schema
///   - [Setup]:        BEGIN TRANSACTION
///   - [Test]:         executar operacoes; verificar
///   - [TearDown]:     ROLLBACK — banco volta ao estado limpo
///   - [TearDownFixture]: fechar conexao

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
// Classes de dominio — o que seria testado em producao
// ---------------------------------------------------------------------------

type
  TClienteRecord = record
    Id:    Integer;
    Nome:  string;
    Email: string;
    Ativo: Boolean;
  end;

  /// Repositorio simples de clientes usando FireDAC diretamente
  TClienteRepository = class
  private
    FConn: TFDConnection;
  public
    constructor Create(AConn: TFDConnection);
    procedure   Salvar(const ACliente: TClienteRecord);
    function    BuscarPorId(AId: Integer): TClienteRecord;
    function    Existe(AId: Integer): Boolean;
    function    Contar: Integer;
    procedure   Atualizar(const ACliente: TClienteRecord);
  end;

constructor TClienteRepository.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

procedure TClienteRepository.Salvar(const ACliente: TClienteRecord);
begin
  FConn.ExecSQL(
    'INSERT INTO clientes (id, nome, email, ativo) VALUES (:id, :nome, :email, :ativo)',
    [ACliente.Id, ACliente.Nome, ACliente.Email, Ord(ACliente.Ativo)]);
end;

function TClienteRepository.BuscarPorId(AId: Integer): TClienteRecord;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT id, nome, email, ativo FROM clientes WHERE id = :id';
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    if Q.IsEmpty then
    begin
      Result.Id    := 0;
      Result.Nome  := '';
      Result.Email := '';
      Result.Ativo := False;
    end
    else
    begin
      Result.Id    := Q.FieldByName('id').AsInteger;
      Result.Nome  := Q.FieldByName('nome').AsString;
      Result.Email := Q.FieldByName('email').AsString;
      Result.Ativo := Q.FieldByName('ativo').AsInteger = 1;
    end;
  finally
    Q.Free;
  end;
end;

function TClienteRepository.Existe(AId: Integer): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM clientes WHERE id = :id';
    Q.ParamByName('id').AsInteger := AId;
    Q.Open;
    Result := Q.Fields[0].AsInteger > 0;
  finally
    Q.Free;
  end;
end;

function TClienteRepository.Contar: Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text   := 'SELECT COUNT(*) FROM clientes';
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

procedure TClienteRepository.Atualizar(const ACliente: TClienteRecord);
begin
  FConn.ExecSQL(
    'UPDATE clientes SET nome=:nome, email=:email, ativo=:ativo WHERE id=:id',
    [ACliente.Nome, ACliente.Email, Ord(ACliente.Ativo), ACliente.Id]);
end;

// ---------------------------------------------------------------------------
// TestFixture de integracao
// ---------------------------------------------------------------------------

type
  [TestFixture]
  TClienteRepositoryIntegrationTests = class
  private
    FConn:      TFDConnection;
    FRepo:      TClienteRepository;

    /// Metodo auxiliar: criar cliente de teste com valores padrao
    function CriarCliente(AId: Integer; const ANome: string = 'Cliente Teste';
      const AEmail: string = 'teste@exemplo.com'): TClienteRecord;
  public
    [SetupFixture]
    procedure SetupFixture;    // Conectar; criar schema

    [TearDownFixture]
    procedure TearDownFixture; // Fechar conexao

    [Setup]
    procedure Setup;           // BEGIN TRANSACTION

    [TearDown]
    procedure TearDown;        // ROLLBACK — SEMPRE

    // Testes de CRUD basico
    [Test]
    procedure Salvar_ClienteValido_PersisteDoBanco;

    [Test]
    procedure BuscarPorId_IdExistente_RetornaClienteCorreto;

    [Test]
    procedure BuscarPorId_IdInexistente_RetornaRegistroVazio;

    [Test]
    procedure Existe_IdExistente_RetornaTrue;

    [Test]
    procedure Existe_IdInexistente_RetornaFalse;

    [Test]
    procedure Salvar_DoisClientes_ContadorRetorna2;

    [Test]
    procedure Atualizar_ClienteExistente_AlteraNome;

    // Teste de isolamento: ROLLBACK garante que cada teste comeca limpo
    [Test]
    procedure Isolamento_TabelaDeveEstarVaziaEmCadaTeste;
  end;

function TClienteRepositoryIntegrationTests.CriarCliente(
  AId: Integer; const ANome, AEmail: string): TClienteRecord;
begin
  Result.Id    := AId;
  Result.Nome  := ANome;
  Result.Email := AEmail;
  Result.Ativo := True;
end;

procedure TClienteRepositoryIntegrationTests.SetupFixture;
begin
  FConn := TFDConnection.Create(nil);
  FConn.DriverName := 'SQLite';
  FConn.Params.Database := ':memory:';
  FConn.Params.Add('LockingMode=Normal');
  FConn.Connected := True;

  // Criar schema de teste
  FConn.ExecSQL(
    'CREATE TABLE clientes (' +
    '  id    INTEGER PRIMARY KEY, ' +
    '  nome  TEXT    NOT NULL, ' +
    '  email TEXT    NOT NULL, ' +
    '  ativo INTEGER NOT NULL DEFAULT 1' +
    ')');

  FRepo := TClienteRepository.Create(FConn);
  WriteLn('[SetupFixture] Banco SQLite in-memory criado e schema inicializado.');
end;

procedure TClienteRepositoryIntegrationTests.TearDownFixture;
begin
  FRepo.Free;
  FConn.Free;
  WriteLn('[TearDownFixture] Conexao encerrada.');
end;

procedure TClienteRepositoryIntegrationTests.Setup;
begin
  FConn.StartTransaction;
end;

procedure TClienteRepositoryIntegrationTests.TearDown;
begin
  // SEMPRE rollback — garante tabela limpa para o proximo teste
  FConn.Rollback;
end;

procedure TClienteRepositoryIntegrationTests.Salvar_ClienteValido_PersisteDoBanco;
var
  C: TClienteRecord;
begin
  C := CriarCliente(1, 'Joao Silva', 'joao@exemplo.com');
  FRepo.Salvar(C);

  Assert.IsTrue(FRepo.Existe(1), 'Cliente 1 deve existir apos salvar');
end;

procedure TClienteRepositoryIntegrationTests.BuscarPorId_IdExistente_RetornaClienteCorreto;
var
  C, Obtido: TClienteRecord;
begin
  C := CriarCliente(2, 'Maria Santos', 'maria@exemplo.com');
  FRepo.Salvar(C);

  Obtido := FRepo.BuscarPorId(2);

  Assert.AreEqual(2,                Obtido.Id,    'ID deve corresponder');
  Assert.AreEqual('Maria Santos',   Obtido.Nome,  'Nome deve corresponder');
  Assert.AreEqual('maria@exemplo.com', Obtido.Email, 'Email deve corresponder');
  Assert.IsTrue(Obtido.Ativo, 'Cliente deve estar ativo');
end;

procedure TClienteRepositoryIntegrationTests.BuscarPorId_IdInexistente_RetornaRegistroVazio;
var
  Obtido: TClienteRecord;
begin
  Obtido := FRepo.BuscarPorId(9999);
  Assert.AreEqual(0,  Obtido.Id,   'ID deve ser 0 para registro inexistente');
  Assert.AreEqual('', Obtido.Nome, 'Nome deve ser vazio para registro inexistente');
end;

procedure TClienteRepositoryIntegrationTests.Existe_IdExistente_RetornaTrue;
begin
  FRepo.Salvar(CriarCliente(3));
  Assert.IsTrue(FRepo.Existe(3), 'Existe deve retornar True para id inserido');
end;

procedure TClienteRepositoryIntegrationTests.Existe_IdInexistente_RetornaFalse;
begin
  Assert.IsFalse(FRepo.Existe(8888), 'Existe deve retornar False para id nao inserido');
end;

procedure TClienteRepositoryIntegrationTests.Salvar_DoisClientes_ContadorRetorna2;
begin
  FRepo.Salvar(CriarCliente(4, 'Cliente A'));
  FRepo.Salvar(CriarCliente(5, 'Cliente B'));

  Assert.AreEqual(2, FRepo.Contar,
    'Deve haver exatamente 2 clientes apos 2 insercoes');
end;

procedure TClienteRepositoryIntegrationTests.Atualizar_ClienteExistente_AlteraNome;
var
  C, Atualizado: TClienteRecord;
begin
  C := CriarCliente(6, 'Nome Original');
  FRepo.Salvar(C);

  C.Nome := 'Nome Atualizado';
  FRepo.Atualizar(C);

  Atualizado := FRepo.BuscarPorId(6);
  Assert.AreEqual('Nome Atualizado', Atualizado.Nome,
    'Nome deve estar atualizado apos Atualizar');
end;

procedure TClienteRepositoryIntegrationTests.Isolamento_TabelaDeveEstarVaziaEmCadaTeste;
begin
  // Este teste nao insere nada — verifica que o ROLLBACK do teste anterior funcionou.
  // Se algum [TearDown] nao fizer rollback, este teste falharia.
  Assert.AreEqual(0, FRepo.Contar,
    'Tabela deve estar vazia no inicio de cada teste (ROLLBACK garantido)');
end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.RegisterTestFixture(TClienteRepositoryIntegrationTests);
    Runner  := TDUnitX.CreateRunner;
    Results := Runner.Execute;
    WriteLn;
    if Results.AllPassed then
    begin
      WriteLn('OK -- developer-delphi-testing-integration / db_real_test');
      Halt(0);
    end
    else
    begin
      WriteLn('FAIL -- alguns testes de integracao falharam');
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
