program smoke_test;
{$APPTYPE CONSOLE}
{$R *.res}
///  Demonstra smoke test: verificar que todos os modulos inicializam sem excecao.
///  Compilavel com: dcc32 smoke_test.pas  ou  dcc64 smoke_test.pas
///
///  Smoke test NÃO verifica comportamento detalhado — apenas que:
///   1. O modulo pode ser criado (construtor nao lanca excecao)
///   2. O modulo pode ser destruido (destrutor nao lanca excecao)
///   3. Operacao basica retorna sem crash
///
///  Este nivel de teste e util como "gate de sanidade" em CI:
///  se o smoke test falha, o build inteiro e bloqueado antes de testes mais lentos.

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console;

// ---------------------------------------------------------------------------
// Modulos de exemplo — substituir pelos modulos reais do projeto
// ---------------------------------------------------------------------------

type
  IConexao = interface
    ['{A1B2C3D4-0050-0000-0000-000000000050}']
    function  EstaConectado: Boolean;
    procedure Conectar;
    procedure Desconectar;
  end;

  ILogger = interface
    ['{B2C3D4E5-0051-0000-0000-000000000051}']
    procedure Log(const AMensagem: string);
  end;

  ICache = interface
    ['{C3D4E5F6-0052-0000-0000-000000000052}']
    procedure Armazenar(const AChave, AValor: string);
    function  Recuperar(const AChave: string): string;
    procedure Limpar;
  end;

  // --- Implementacoes minimas de exemplo ---

  TConexaoSQLite = class(TInterfacedObject, IConexao)
  private FConectado: Boolean;
  public
    class function New: IConexao;
    function  EstaConectado: Boolean;
    procedure Conectar;
    procedure Desconectar;
  end;

  TLoggerConsole = class(TInterfacedObject, ILogger)
  public
    class function New: ILogger;
    procedure Log(const AMensagem: string);
  end;

  TCacheMemoria = class(TInterfacedObject, ICache)
  private FDados: TStringList;
  public
    constructor Create;
    destructor  Destroy; override;
    class function New: ICache;
    procedure Armazenar(const AChave, AValor: string);
    function  Recuperar(const AChave: string): string;
    procedure Limpar;
  end;

// Implementacoes

class function TConexaoSQLite.New: IConexao;
begin Result := TConexaoSQLite.Create; end;

function TConexaoSQLite.EstaConectado: Boolean;
begin Result := FConectado; end;

procedure TConexaoSQLite.Conectar;
begin FConectado := True; end;

procedure TConexaoSQLite.Desconectar;
begin FConectado := False; end;

class function TLoggerConsole.New: ILogger;
begin Result := TLoggerConsole.Create; end;

procedure TLoggerConsole.Log(const AMensagem: string);
begin WriteLn('[LOG] ' + AMensagem); end;

constructor TCacheMemoria.Create;
begin inherited; FDados := TStringList.Create; end;

destructor TCacheMemoria.Destroy;
begin FDados.Free; inherited; end;

class function TCacheMemoria.New: ICache;
begin Result := TCacheMemoria.Create; end;

procedure TCacheMemoria.Armazenar(const AChave, AValor: string);
begin FDados.Values[AChave] := AValor; end;

function TCacheMemoria.Recuperar(const AChave: string): string;
begin Result := FDados.Values[AChave]; end;

procedure TCacheMemoria.Limpar;
begin FDados.Clear; end;

// ---------------------------------------------------------------------------
// Smoke TestFixture
// ---------------------------------------------------------------------------

type
  [TestFixture]
  [Category('Smoke')]
  TSmokeTests = class
  public
    // Nota: smoke tests geralmente NAO precisam de Setup/TearDown
    // pois cada teste e completamente independente (cria e destroi seu proprio objeto)

    [Test]
    procedure Smoke_TConexaoSQLite_InicializaSemExcecao;

    [Test]
    procedure Smoke_TConexaoSQLite_ConectarEDesconectar;

    [Test]
    procedure Smoke_TLoggerConsole_InicializaSemExcecao;

    [Test]
    procedure Smoke_TLoggerConsole_LogNaoLancaExcecao;

    [Test]
    procedure Smoke_TCacheMemoria_InicializaSemExcecao;

    [Test]
    procedure Smoke_TCacheMemoria_ArmazenarERecuperar;

    [Test]
    procedure Smoke_TCacheMemoria_LimparNaoLancaExcecao;

    // Smoke test de integracao de modulos: todos os modulos juntos
    [Test]
    procedure Smoke_TodosOsModulos_InicializamJuntos;
  end;

procedure TSmokeTests.Smoke_TConexaoSQLite_InicializaSemExcecao;
var
  Conn: IConexao;
begin
  Assert.WillNotRaise(
    procedure begin Conn := TConexaoSQLite.New end,
    'TConexaoSQLite.New nao deve lancar excecao');
  Assert.IsNotNull(Conn, 'Instancia nao deve ser nil');
end;

procedure TSmokeTests.Smoke_TConexaoSQLite_ConectarEDesconectar;
var
  Conn: IConexao;
begin
  Conn := TConexaoSQLite.New;

  Assert.IsFalse(Conn.EstaConectado, 'Deve iniciar desconectado');

  Assert.WillNotRaise(
    procedure begin Conn.Conectar end,
    'Conectar nao deve lancar excecao');

  Assert.IsTrue(Conn.EstaConectado, 'Deve estar conectado apos Conectar');

  Assert.WillNotRaise(
    procedure begin Conn.Desconectar end,
    'Desconectar nao deve lancar excecao');

  Assert.IsFalse(Conn.EstaConectado, 'Deve estar desconectado apos Desconectar');
end;

procedure TSmokeTests.Smoke_TLoggerConsole_InicializaSemExcecao;
var
  Logger: ILogger;
begin
  Assert.WillNotRaise(
    procedure begin Logger := TLoggerConsole.New end,
    'TLoggerConsole.New nao deve lancar excecao');
  Assert.IsNotNull(Logger);
end;

procedure TSmokeTests.Smoke_TLoggerConsole_LogNaoLancaExcecao;
var
  Logger: ILogger;
begin
  Logger := TLoggerConsole.New;
  Assert.WillNotRaise(
    procedure begin Logger.Log('mensagem de smoke test') end,
    'Logger.Log nao deve lancar excecao');
end;

procedure TSmokeTests.Smoke_TCacheMemoria_InicializaSemExcecao;
var
  Cache: ICache;
begin
  Assert.WillNotRaise(
    procedure begin Cache := TCacheMemoria.New end,
    'TCacheMemoria.New nao deve lancar excecao');
  Assert.IsNotNull(Cache);
end;

procedure TSmokeTests.Smoke_TCacheMemoria_ArmazenarERecuperar;
var
  Cache: ICache;
begin
  Cache := TCacheMemoria.New;
  Cache.Armazenar('chave', 'valor');
  Assert.AreEqual('valor', Cache.Recuperar('chave'));
end;

procedure TSmokeTests.Smoke_TCacheMemoria_LimparNaoLancaExcecao;
var
  Cache: ICache;
begin
  Cache := TCacheMemoria.New;
  Cache.Armazenar('k', 'v');
  Assert.WillNotRaise(
    procedure begin Cache.Limpar end,
    'Limpar nao deve lancar excecao');
  Assert.AreEqual('', Cache.Recuperar('k'),
    'Apos Limpar, recuperar qualquer chave deve retornar vazio');
end;

procedure TSmokeTests.Smoke_TodosOsModulos_InicializamJuntos;
var
  Conn:   IConexao;
  Logger: ILogger;
  Cache:  ICache;
begin
  Assert.WillNotRaise(
    procedure
    begin
      Conn   := TConexaoSQLite.New;
      Logger := TLoggerConsole.New;
      Cache  := TCacheMemoria.New;
      // Interacao basica entre modulos
      Conn.Conectar;
      Logger.Log('Conexao estabelecida');
      Cache.Armazenar('status', 'conectado');
      Conn.Desconectar;
    end,
    'Todos os modulos devem inicializar e interagir sem excecao');

  Assert.AreEqual('conectado', Cache.Recuperar('status'),
    'Cache deve conter o status armazenado');
end;

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
var
  Runner:  ITestRunner;
  Results: IRunResults;
begin
  try
    TDUnitX.RegisterTestFixture(TSmokeTests);
    Runner  := TDUnitX.CreateRunner;
    Results := Runner.Execute;
    WriteLn;
    if Results.AllPassed then
    begin
      WriteLn('OK -- developer-delphi-testing-integration / smoke_test');
      Halt(0);
    end
    else
    begin
      WriteLn('FAIL -- smoke test falhou — verificar inicializacao dos modulos');
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
