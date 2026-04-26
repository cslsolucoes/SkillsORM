unit mediator;
{
  Mediator Pattern em Delphi — componentes UI desacoplados via mediador
  Compilavel: dcc32 / dcc64
}

interface

uses
  System.SysUtils, System.Generics.Collections;

// ---------------------------------------------------------------------------
// Interface do Mediator
// ---------------------------------------------------------------------------
type
  IMediator = interface
  ['{MD000001-0000-0000-0000-000000000001}']
    procedure Notificar(const AOrigem, AEvento: string; const ADados: string);
  end;

// ---------------------------------------------------------------------------
// Interface do Componente — conhece o mediador, não os outros componentes
// ---------------------------------------------------------------------------
type
  IComponente = interface
  ['{MD000002-0000-0000-0000-000000000002}']
    procedure SetMediator(AMediator: IMediator);
    function  GetNome: string;
    property Nome: string read GetNome;
  end;

// ---------------------------------------------------------------------------
// Base abstrata dos componentes
// ---------------------------------------------------------------------------
type
  TComponenteBase = class abstract(TInterfacedObject, IComponente)
  protected
    FMediator: IMediator;
    FNome:     string;
  public
    constructor Create(const ANome: string);
    procedure SetMediator(AMediator: IMediator);
    function  GetNome: string;
  end;

// ---------------------------------------------------------------------------
// Componentes concretos de um formulário de login
// ---------------------------------------------------------------------------
type
  TComponenteLogin = class(TComponenteBase)
  private
    FUsuario: string;
    FSenha:   string;
    FAtivo:   Boolean;
  public
    constructor Create;
    procedure SetUsuario(const AUsuario: string);
    procedure SetSenha(const ASenha: string);
    procedure TentarLogin;
    procedure LimparCampos;
    function  GetAtivo: Boolean;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

  TComponenteBotoes = class(TComponenteBase)
  private
    FBtnLoginEnabled:    Boolean;
    FBtnCancelarEnabled: Boolean;
    FBtnLogoutEnabled:   Boolean;
  public
    constructor Create;
    procedure ClicarLogin;
    procedure ClicarCancelar;
    procedure ClicarLogout;
    procedure AtualizarEstado(ALoginEnabled, ACancelEnabled, ALogoutEnabled: Boolean);
    procedure Mostrar;
  end;

  TComponenteStatus = class(TComponenteBase)
  private
    FMensagem: string;
    FTipo:     string;  // info, erro, sucesso
  public
    constructor Create;
    procedure ExibirMensagem(const AMensagem, ATipo: string);
    procedure Limpar;
    procedure Mostrar;
  end;

  TComponenteMenu = class(TComponenteBase)
  private
    FVisivel: Boolean;
    FUsuarioLogado: string;
  public
    constructor Create;
    procedure Mostrar;
    procedure Ocultar;
    procedure SetUsuario(const AUsuario: string);
    procedure Mostrar; reintroduce;
  end;

// ---------------------------------------------------------------------------
// Mediador concreto — orquestra o formulário de login
// ---------------------------------------------------------------------------
type
  TLoginMediator = class(TInterfacedObject, IMediator)
  private
    FLogin:  TComponenteLogin;
    FBotoes: TComponenteBotoes;
    FStatus: TComponenteStatus;
    FMenu:   TComponenteMenu;
    FLogado: Boolean;
    FUsuario: string;
  public
    constructor Create;
    destructor Destroy; override;
    // IMediator
    procedure Notificar(const AOrigem, AEvento: string; const ADados: string);
    // Setup inicial
    procedure InicializarFormulario;
    // Acesso aos componentes (para o código do form)
    property Login:  TComponenteLogin  read FLogin;
    property Botoes: TComponenteBotoes read FBotoes;
    property Status: TComponenteStatus read FStatus;
    property Menu:   TComponenteMenu   read FMenu;
  end;

implementation

// ---------------------------------------------------------------------------
// TComponenteBase
// ---------------------------------------------------------------------------

constructor TComponenteBase.Create(const ANome: string);
begin inherited Create; FNome := ANome; end;

procedure TComponenteBase.SetMediator(AMediator: IMediator);
begin FMediator := AMediator; end;

function TComponenteBase.GetNome: string;
begin Result := FNome; end;

// ---------------------------------------------------------------------------
// TComponenteLogin
// ---------------------------------------------------------------------------

constructor TComponenteLogin.Create;
begin inherited Create('login'); FAtivo := True; end;

procedure TComponenteLogin.SetUsuario(const AUsuario: string);
begin
  FUsuario := AUsuario;
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'usuario_digitado', AUsuario);
end;

procedure TComponenteLogin.SetSenha(const ASenha: string);
begin
  FSenha := ASenha;
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'senha_digitada', '***');
end;

procedure TComponenteLogin.TentarLogin;
begin
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'login_tentativa', FUsuario + ':' + FSenha);
end;

procedure TComponenteLogin.LimparCampos;
begin FUsuario := ''; FSenha := ''; end;

function TComponenteLogin.GetAtivo: Boolean;
begin Result := FAtivo; end;

// ---------------------------------------------------------------------------
// TComponenteBotoes
// ---------------------------------------------------------------------------

constructor TComponenteBotoes.Create;
begin inherited Create('botoes');
  FBtnLoginEnabled := True; FBtnCancelarEnabled := True; FBtnLogoutEnabled := False; end;

procedure TComponenteBotoes.ClicarLogin;
begin
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'btn_login_click', '');
end;

procedure TComponenteBotoes.ClicarCancelar;
begin
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'btn_cancelar_click', '');
end;

procedure TComponenteBotoes.ClicarLogout;
begin
  if Assigned(FMediator) then
    FMediator.Notificar(FNome, 'btn_logout_click', '');
end;

procedure TComponenteBotoes.AtualizarEstado(ALoginEnabled, ACancelEnabled, ALogoutEnabled: Boolean);
begin
  FBtnLoginEnabled    := ALoginEnabled;
  FBtnCancelarEnabled := ACancelEnabled;
  FBtnLogoutEnabled   := ALogoutEnabled;
end;

procedure TComponenteBotoes.Mostrar;
begin
  Writeln(Format('[Botões] Login=%s Cancelar=%s Logout=%s',
    [IfThen(FBtnLoginEnabled, 'ativo', 'inativo'),
     IfThen(FBtnCancelarEnabled, 'ativo', 'inativo'),
     IfThen(FBtnLogoutEnabled, 'ativo', 'inativo')]));
end;

// ---------------------------------------------------------------------------
// TComponenteStatus
// ---------------------------------------------------------------------------

constructor TComponenteStatus.Create;
begin inherited Create('status'); end;

procedure TComponenteStatus.ExibirMensagem(const AMensagem, ATipo: string);
begin FMensagem := AMensagem; FTipo := ATipo; Mostrar; end;

procedure TComponenteStatus.Limpar;
begin FMensagem := ''; FTipo := ''; end;

procedure TComponenteStatus.Mostrar;
begin
  if FMensagem <> '' then
    Writeln(Format('[Status/%s] %s', [FTipo, FMensagem]));
end;

// ---------------------------------------------------------------------------
// TComponenteMenu
// ---------------------------------------------------------------------------

constructor TComponenteMenu.Create;
begin inherited Create('menu'); FVisivel := False; end;

procedure TComponenteMenu.Mostrar;
begin FVisivel := True; Writeln(Format('[Menu] Visível — usuário: %s', [FUsuarioLogado])); end;

procedure TComponenteMenu.Ocultar;
begin FVisivel := False; Writeln('[Menu] Ocultado'); end;

procedure TComponenteMenu.SetUsuario(const AUsuario: string);
begin FUsuarioLogado := AUsuario; end;

// ---------------------------------------------------------------------------
// TLoginMediator
// ---------------------------------------------------------------------------

constructor TLoginMediator.Create;
begin
  inherited Create;
  FLogin  := TComponenteLogin.Create;
  FBotoes := TComponenteBotoes.Create;
  FStatus := TComponenteStatus.Create;
  FMenu   := TComponenteMenu.Create;
  // Registrar mediador em todos os componentes
  FLogin.SetMediator(Self);
  FBotoes.SetMediator(Self);
  FStatus.SetMediator(Self);
  FMenu.SetMediator(Self);
  FLogado := False;
end;

destructor TLoginMediator.Destroy;
begin FLogin.Free; FBotoes.Free; FStatus.Free; FMenu.Free; inherited; end;

procedure TLoginMediator.InicializarFormulario;
begin
  FBotoes.AtualizarEstado(True, True, False);
  FStatus.Limpar;
  FMenu.Ocultar;
end;

procedure TLoginMediator.Notificar(const AOrigem, AEvento, ADados: string);
begin
  // Toda lógica de interação entre componentes centralizada aqui
  if (AOrigem = 'login') and (AEvento = 'usuario_digitado') then
  begin
    FStatus.Limpar;
  end

  else if (AOrigem = 'login') and (AEvento = 'login_tentativa') then
  begin
    // Validar credenciais (simulado)
    var Partes := ADados.Split([':']);
    if (Length(Partes) = 2) and (Partes[0] = 'admin') and (Partes[1] = '1234') then
    begin
      FLogado   := True;
      FUsuario  := Partes[0];
      FStatus.ExibirMensagem('Login realizado com sucesso!', 'sucesso');
      FMenu.SetUsuario(FUsuario);
      FMenu.Mostrar;
      FBotoes.AtualizarEstado(False, False, True);
      FLogin.Ativo := False;
    end
    else
    begin
      FStatus.ExibirMensagem('Usuário ou senha inválidos.', 'erro');
      FBotoes.AtualizarEstado(True, True, False);
    end;
  end

  else if (AOrigem = 'botoes') and (AEvento = 'btn_login_click') then
  begin
    FLogin.TentarLogin;
  end

  else if (AOrigem = 'botoes') and (AEvento = 'btn_cancelar_click') then
  begin
    FLogin.LimparCampos;
    FStatus.Limpar;
    InicializarFormulario;
  end

  else if (AOrigem = 'botoes') and (AEvento = 'btn_logout_click') then
  begin
    FLogado  := False;
    FUsuario := '';
    FMenu.Ocultar;
    FLogin.LimparCampos;
    FLogin.Ativo := True;
    FStatus.ExibirMensagem('Sessão encerrada.', 'info');
    FBotoes.AtualizarEstado(True, True, False);
  end;
end;

// ---------------------------------------------------------------------------
// USO:
//   var M := TLoginMediator.Create;
//   M.InicializarFormulario;
//   M.Botoes.Mostrar;    // Login=ativo Cancelar=ativo Logout=inativo
//
//   // Simular digitação e login com sucesso
//   M.Login.SetUsuario('admin');
//   M.Login.SetSenha('1234');
//   M.Botoes.ClicarLogin;
//   // → [Status/sucesso] Login realizado com sucesso!
//   // → [Menu] Visível — usuário: admin
//   M.Botoes.Mostrar;    // Login=inativo Cancelar=inativo Logout=ativo
//
//   // Logout
//   M.Botoes.ClicarLogout;
//   // → [Menu] Ocultado
//   // → [Status/info] Sessão encerrada.
// ---------------------------------------------------------------------------

end.
