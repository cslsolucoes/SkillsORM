unit test_isolation;
///  Demonstra isolamento de unidades de codigo via injecao de dependencia.
///  Compilavel como unit de projeto DUnitX.
///
///  Sem mocking externo — usa implementacoes "stub" simples para isolar.
///  Util quando Delphi-Mocks nao esta disponivel ou para dependencias simples.

interface

uses
  System.SysUtils,
  System.Classes,
  DUnitX.TestFramework;

type
  // ---------------------------------------------------------------------------
  // Interfaces e stubs — definir interfaces para todas as dependencias externas
  // ---------------------------------------------------------------------------

  IEmailSender = interface
    ['{C3D4E5F6-0020-0000-0000-000000000020}']
    procedure Enviar(const ADestino, AAssunto, ACorpo: string);
    function UltimoDestinoEnviado: string;
  end;

  IRegistroAuditoria = interface
    ['{D4E5F6A7-0021-0000-0000-000000000021}']
    procedure Registrar(const AEvento: string);
    function TotalRegistros: Integer;
  end;

  // ---------------------------------------------------------------------------
  // Stubs de teste — implementacoes minimas que registram interacoes
  // ---------------------------------------------------------------------------

  /// Stub de EmailSender: nao envia email real; apenas registra chamadas
  TEmailSenderStub = class(TInterfacedObject, IEmailSender)
  private
    FUltimoDestino: string;
    FUltimoAssunto: string;
    FTotalEnviados: Integer;
  public
    procedure Enviar(const ADestino, AAssunto, ACorpo: string);
    function  UltimoDestinoEnviado: string;
    // Metodos de verificacao (usados nos testes)
    function  TotalEnviados: Integer;
    function  UltimoAssunto: string;
  end;

  /// Stub de RegistroAuditoria: registra em lista em memoria
  TRegistroAuditoriaStub = class(TInterfacedObject, IRegistroAuditoria)
  private
    FRegistros: TStringList;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Registrar(const AEvento: string);
    function  TotalRegistros: Integer;
    // Metodos de verificacao
    function  ContemEvento(const AEvento: string): Boolean;
    function  Eventos: TStrings;
  end;

  // ---------------------------------------------------------------------------
  // Classe de servico a ser testada
  // ---------------------------------------------------------------------------

  TServicoNotificacao = class
  private
    FEmail:     IEmailSender;
    FAuditoria: IRegistroAuditoria;
  public
    constructor Create(
      const AEmail:     IEmailSender;
      const AAuditoria: IRegistroAuditoria);

    procedure NotificarUsuario(const AEmail, AMensagem: string);
    procedure NotificarAdmin(const AMensagem: string);
  end;

  // ---------------------------------------------------------------------------
  // TestFixture com stubs (sem framework de mock externo)
  // ---------------------------------------------------------------------------

  [TestFixture]
  [Category('Isolamento')]
  TServicoNotificacaoTests = class
  private
    FEmailStub:     TEmailSenderStub;
    FAuditoriaStub: TRegistroAuditoriaStub;
    FServico:       TServicoNotificacao;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure NotificarUsuario_EmailValido_EnviaEmail;

    [Test]
    procedure NotificarUsuario_QualquerEmail_RegistraAuditoria;

    [Test]
    procedure NotificarAdmin_SempreEnviaParaAdminEmail;

    [Test]
    procedure NotificarUsuario_EmailVazio_NaoEnviaEmail;
  end;

implementation

// ---------------------------------------------------------------------------
// TEmailSenderStub
// ---------------------------------------------------------------------------

procedure TEmailSenderStub.Enviar(const ADestino, AAssunto, ACorpo: string);
begin
  FUltimoDestino := ADestino;
  FUltimoAssunto := AAssunto;
  Inc(FTotalEnviados);
end;

function TEmailSenderStub.UltimoDestinoEnviado: string;
begin
  Result := FUltimoDestino;
end;

function TEmailSenderStub.TotalEnviados: Integer;
begin
  Result := FTotalEnviados;
end;

function TEmailSenderStub.UltimoAssunto: string;
begin
  Result := FUltimoAssunto;
end;

// ---------------------------------------------------------------------------
// TRegistroAuditoriaStub
// ---------------------------------------------------------------------------

constructor TRegistroAuditoriaStub.Create;
begin
  inherited Create;
  FRegistros := TStringList.Create;
end;

destructor TRegistroAuditoriaStub.Destroy;
begin
  FRegistros.Free;
  inherited;
end;

procedure TRegistroAuditoriaStub.Registrar(const AEvento: string);
begin
  FRegistros.Add(AEvento);
end;

function TRegistroAuditoriaStub.TotalRegistros: Integer;
begin
  Result := FRegistros.Count;
end;

function TRegistroAuditoriaStub.ContemEvento(const AEvento: string): Boolean;
begin
  Result := FRegistros.IndexOf(AEvento) >= 0;
end;

function TRegistroAuditoriaStub.Eventos: TStrings;
begin
  Result := FRegistros;
end;

// ---------------------------------------------------------------------------
// TServicoNotificacao
// ---------------------------------------------------------------------------

constructor TServicoNotificacao.Create(
  const AEmail:     IEmailSender;
  const AAuditoria: IRegistroAuditoria);
begin
  inherited Create;
  FEmail     := AEmail;
  FAuditoria := AAuditoria;
end;

procedure TServicoNotificacao.NotificarUsuario(
  const AEmail, AMensagem: string);
begin
  if AEmail = '' then Exit;
  FEmail.Enviar(AEmail, 'Notificacao', AMensagem);
  FAuditoria.Registrar(Format('Notificado: %s', [AEmail]));
end;

procedure TServicoNotificacao.NotificarAdmin(const AMensagem: string);
begin
  FEmail.Enviar('admin@empresa.com', 'Admin Alert', AMensagem);
  FAuditoria.Registrar('Admin notificado');
end;

// ---------------------------------------------------------------------------
// TServicoNotificacaoTests
// ---------------------------------------------------------------------------

procedure TServicoNotificacaoTests.Setup;
begin
  // Stubs sao criados manualmente — sem dependencia de Delphi-Mocks
  FEmailStub     := TEmailSenderStub.Create;
  FAuditoriaStub := TRegistroAuditoriaStub.Create;
  FServico       := TServicoNotificacao.Create(FEmailStub, FAuditoriaStub);
end;

procedure TServicoNotificacaoTests.TearDown;
begin
  FServico.Free;
  FServico := nil;
  // Stubs: interfaces gerenciam via ref-count; mas foram criados como objetos
  // — liberar manualmente pois FServico nao e o unico detentor
  FEmailStub     := nil; // ref-count cai para 0 se FServico.Free ja ocorreu
  FAuditoriaStub := nil;
end;

procedure TServicoNotificacaoTests.NotificarUsuario_EmailValido_EnviaEmail;
begin
  FServico.NotificarUsuario('joao@exemplo.com', 'Mensagem de teste');

  Assert.AreEqual(1, FEmailStub.TotalEnviados,
    'Deve ter enviado exatamente 1 email');
  Assert.AreEqual('joao@exemplo.com', FEmailStub.UltimoDestinoEnviado,
    'Destino do email deve corresponder ao informado');
end;

procedure TServicoNotificacaoTests.NotificarUsuario_QualquerEmail_RegistraAuditoria;
begin
  FServico.NotificarUsuario('maria@exemplo.com', 'Teste');

  Assert.AreEqual(1, FAuditoriaStub.TotalRegistros,
    'Deve ter registrado 1 evento de auditoria');
  Assert.IsTrue(
    FAuditoriaStub.ContemEvento('Notificado: maria@exemplo.com'),
    'Auditoria deve conter o evento com o email do usuario');
end;

procedure TServicoNotificacaoTests.NotificarAdmin_SempreEnviaParaAdminEmail;
begin
  FServico.NotificarAdmin('Alerta critico');

  Assert.AreEqual('admin@empresa.com', FEmailStub.UltimoDestinoEnviado,
    'Notificacao de admin deve sempre ir para admin@empresa.com');
  Assert.IsTrue(
    FAuditoriaStub.ContemEvento('Admin notificado'),
    'Auditoria deve registrar notificacao de admin');
end;

procedure TServicoNotificacaoTests.NotificarUsuario_EmailVazio_NaoEnviaEmail;
begin
  FServico.NotificarUsuario('', 'Mensagem ignorada');

  Assert.AreEqual(0, FEmailStub.TotalEnviados,
    'Email vazio nao deve enviar nenhuma mensagem');
  Assert.AreEqual(0, FAuditoriaStub.TotalRegistros,
    'Email vazio nao deve gerar registro de auditoria');
end;

initialization
  TDUnitX.RegisterTestFixture(TServicoNotificacaoTests);

end.
